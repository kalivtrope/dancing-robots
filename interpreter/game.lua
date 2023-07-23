local enums = require("enums")
local RobotState = require("robot-state")
local Maze = require("maze")
local utils = require("utils")
local write_stderr, assert_bounds = utils.write_stderr, utils.assert_bounds
local GameType, GameResult, Tokens = enums.GameType, enums.GameResult, enums.Tokens

local Game = {
  maze = nil,
  over = false,
  warning_encountered = false,
  error_encountered = false,
  type = GameType.NONE,
  robot_state = nil,
  code = nil,
}

Game.__tostring = function(self)
  local res = ""
  for y=1,self.maze.height do
    for x=1,self.maze.width do
      local robot_str = ""
      if x==self.robot_state.x and y==self.robot_state.y then
        robot_str = string.sub("nesw", self.robot_state.orientation, self.robot_state.orientation)
      end
      res = res .. robot_str .. tostring(self.maze[x][y]) .. " "
    end
    res = res .. "\n"
  end
  res = res.."number of items: "..self.robot_state.items_collected.."\n"
  return res
end

function Game:report_warning(instruction_no, instruction_type, msg)
  self.warning_encountered = true
  write_stderr(string.format("[instruction #%d %s] warning: %s\n", instruction_no, instruction_type, msg))
end

function Game:report_error(instruction_no, instruction_type, msg)
  self.error_encountered = true
  write_stderr(string.format("[instruction #%d %s] error: %s\n", instruction_no, instruction_type, msg))
end

function Game:report_warning_wall(instruction_no, instruction_type, obj_name)
  self:report_warning(instruction_no, instruction_type,
        string.format("attempted to move to %s but instead stopped before a wall", obj_name))
end
Game.__index = Game

function Game:turn_left()
  self.robot_state:turn_left()
end

function Game:turn_right()
  self.robot_state:turn_right()
end

function Game:collect(instruction_no)
  local collect_successful = self.maze:collect(self.robot_state.x, self.robot_state.y)
  if collect_successful == true then
    self.robot_state:collect()
  else
    self:report_warning(instruction_no, Tokens.COLLECT, "attempted to collect nothing")
  end
end

function Game:drop(instruction_no)
  if  self.robot_state:drop() == false then
    self:report_warning(instruction_no, Tokens.DROP, "attempted to drop from an empty inventory")
    return
  end
  self.maze:drop(self.robot_state.x, self.robot_state.y)
end

function Game:move_to_item(instruction_no)
  -- if there's no item in the robot's direction, this command follows the behaviour of self:move_to_wall

  -- NOTE: since robot is guaranteed to make at least one step in here,
  -- it is possible to crash into a wall if standing directly in front of it
  local x,y,success,err = self.maze:move_to_item(self.robot_state.x, self.robot_state.y, self.robot_state.orientation)
  if err == true then
      self:report_error(instruction_no, Tokens.MOVETOITEM, "attempted to move to item but instead crashed into a wall")
  end
  if success == false then
    self:report_warning_wall(instruction_no, Tokens.MOVETOITEM, "item")
  end
  self.robot_state.x, self.robot_state.y = x, y
  --print("move_to_item", x, y)
  assert_bounds(self.robot_state.x, "robot_state.x", 1, self.maze.width)
  assert_bounds(self.robot_state.y, "robot_state.y", 1, self.maze.height)
end

function Game:move_to_wall(instruction_no)
  local x,y,success = self.maze:move_to_wall(self.robot_state.x, self.robot_state.y, self.robot_state.orientation)
  if success == false then -- this shouldn't happen on well-defined grids
      self:report_error(instruction_no, Tokens.MOVETOWALL, "attempted to move to wall but instead exited the maze")
      error("maze is missing borders", 2)
  end
  self.robot_state.x, self.robot_state.y = x, y
  --print("move_to_wall", x, y)
  assert_bounds(self.robot_state.x, "robot_state.x", 1, self.maze.width)
  assert_bounds(self.robot_state.y, "robot_state.y", 1, self.maze.height)
end

function Game:move_to_start(instruction_no)
  -- if there's no start in the robot's direction, this command follows the behaviour of self:move_to_wall
  local x,y,success = self.maze:move_to_start(self.robot_state.x, self.robot_state.y, self.robot_state.orientation)
  if success == false then
    self:report_warning_wall(instruction_no, Tokens.MOVETOSTART, "start")
  end
  self.robot_state.x, self.robot_state.y = x, y
  --print("move_to_start", x, y)
  assert_bounds(self.robot_state.x, "robot_state.x", 1, self.maze.width)
  assert_bounds(self.robot_state.y, "robot_state.y", 1, self.maze.height)
end

function Game:move_to_end(instruction_no)
  -- if there's no end in the robot's direction, this command follows the behaviour of self:move_to_wall
  local x,y,success = self.maze:move_to_start(self.robot_state.x, self.robot_state.y, self.robot_state.orientation)
  if success == false then
    self:report_warning_wall(instruction_no, Tokens.MOVETOEND, "end")
  end
  self.robot_state.x, self.robot_state.y = x, y
  --print("move_to_end", x, y)
  assert_bounds(self.robot_state.x, "robot_state.x", 1, self.maze.width)
  assert_bounds(self.robot_state.y, "robot_state.y", 1, self.maze.height)
end

function Game:nop()

end


function Game:new(file)
  -- params: table with entries:
    -- 'type_str' describes the according GameType
    -- 'maze_str'
    -- `width`
    -- `height`  parameters to Maze:new()
  local type_str = file:read("*line")
  local height, width = file:read("*n", "*n")
  local maze_str = file:read("*all")
  local game_type_key = string.upper(type_str)
  --assert(GameType[game_type_key], _ENV.string.format("unknown game type '%s'", params.type_str))
  local o = { type = GameType[game_type_key], result = {type = GameResult.NONE, message = ""}, }
  setmetatable(o, self)
  o.maze = Maze:new({maze_str = maze_str, width=width, height=height})
  o.robot_state = RobotState:new{x = o.maze.start_cell.x, y = o.maze.start_cell.y}
  return o
end

return Game
