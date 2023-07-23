local enums = require("enums")
local RobotState = require("robot-state")
local Maze = require("maze")
local utils = require("utils")
local write_stderr = utils.write_stderr
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

function Game:report_warning(instruction_no, instruction_type, msg)
  self.warning_encountered = true
  write_stderr(string.format("[instruction %d %s] warning: %s\n", instruction_no, instruction_type, msg))
end

function Game:report_error(instruction_no, instruction_type, msg)
  self.error_encountered = true
  write_stderr(string.format("[instruction %d %s] error: %s\n", instruction_no, instruction_type, msg))
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
  -- if there's no item in the robot's direction, this command behaves the same as MOVETOWALL

  -- HOWEVER, since robot is guaranteed to make at least one step in here,
  -- it is possible to crash into a wall if standing directly in front of it
  local x,y,success,err = self.maze:move_to_item(self.robot_state.x, self.robot_state.y, self.robot_state.orientation)
  if err == true then
      self:report_error(instruction_no, Tokens.MOVE_TO_ITEM, "attempted to move to item but instead crashed into a wall")
  end
  if success == false then
    self:report_warning_wall(instruction_no, Tokens.MOVE_TO_ITEM, "item")
  end
  self.robot_state.x, self.robot_state.y = x, y
end

function Game:move_to_wall(instruction_no)
  local x,y,success = self.maze:move_to_wall(self.robot_state.x, self.robot_state.y, self.robot_state.orientation)
  if success == false then
      self:report_error(instruction_no, Tokens.MOVE_TO_WALL, "attempted to move to wall but instead exited the maze")
  end
  self.robot_state.x, self.robot_state.y = x, y
end

function Game:move_to_start(instruction_no)
  -- if there's no start in the robot's direction, this command behaves the same as MOVETOWALL
  local x,y,success = self.maze:move_to_start(self.robot_state.x, self.robot_state.y, self.robot_state.orientation)
  if success == false then
    self:report_warning_wall(instruction_no, Tokens.MOVE_TO_START, "start")
  end
  self.robot_state.x, self.robot_state.y = x, y
end

function Game:move_to_end(instruction_no)
  -- if there's no end in the robot's direction, this command behaves the same as MOVETOWALL
  local x,y,success = self.maze:move_to_start(self.robot_state.x, self.robot_state.y, self.robot_state.orientation)
  if success == false then
    self:report_warning_wall(instruction_no, Tokens.MOVE_TO_END, "end")
  end
  self.robot_state.x, self.robot_state.y = x, y
end

function Game:nop()

end


function Game:new(params)
  -- params: table with entries:
    -- 'type_str' describes the according GameType
    -- 'maze_str'
    -- `width`
    -- `height`  parameters to Maze:new()
  local game_type_key = string.upper(params.type_str)
  --assert(GameType[game_type_key], _ENV.string.format("unknown game type '%s'", params.type_str))
  local o = { type = GameType[game_type_key], result = {type = GameResult.NONE, message = ""}, }
  setmetatable(o, self)
  o.maze = Maze:new(params)
  o.robot_state = RobotState:new{x = o.maze.start_cell.x, y = o.maze.start_cell.y}
  return o
end

return Game
