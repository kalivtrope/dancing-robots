local enums = require("interpreter.enums")
local RobotState = require("interpreter.robot-state")
local Maze = require("interpreter.maze")
local utils = require("interpreter.utils")
local write_stderr, assert_bounds = utils.write_stderr, utils.assert_bounds
local GameType, GameResult, Tokens = enums.GameType, enums.GameResult, enums.Tokens
local show_warnings = false

local Game = {
  maze = nil,
  over = false,
  warning_encountered = false,
  error_encountered = false,
  type = GameType.NONE,
  robot_state = nil,
  code = nil,
  uniform_cell_print=true,
}

Game.__tostring = function(self)
  local res = ""
  for row=1,self.maze.height do
    for col=1,self.maze.width do
      local robot_str = ""
      local cell_data = self.maze[row][col]:stringify(self.uniform_cell_print)
      if row==self.robot_state.row and col==self.robot_state.col then
        robot_str = string.sub("nesw", self.robot_state.orientation, self.robot_state.orientation)
      end
      if self.uniform_cell_print and #robot_str > 0 then cell_data = "" end
      res = res .. robot_str .. cell_data .. " "
    end
    res = res .. "\n"
  end
  res = res.."number of items: "..self.robot_state.items_collected.."\n"
  return res
end

function Game:report_warning(instruction_no, instruction_type, msg)
  self.warning_encountered = true
  if show_warnings then
    write_stderr(string.format("[instruction #%d %s] warning: %s\n", instruction_no, instruction_type, msg))
  end
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
  local collect_successful = self.maze:collect(self.robot_state.row, self.robot_state.col)
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
  self.maze:drop(self.robot_state.row, self.robot_state.col)
end

function Game:move_to_item(instruction_no)
  -- if there's no item in the robot's direction, this command follows the behaviour of self:move_to_wall

  local row,col,success = self.maze:move_to_item(self.robot_state.row,
                                                 self.robot_state.col,
                                                 self.robot_state.orientation)
  if success == false then
    self:report_warning_wall(instruction_no, Tokens.MOVETOITEM, "item")
  end
  self.robot_state.row, self.robot_state.col = row, col
  assert_bounds(self.robot_state.row, "robot_state.row", 1, self.maze.height)
  assert_bounds(self.robot_state.col, "robot_state.col", 1, self.maze.width)
end

function Game:move_to_wall(instruction_no)
  local row,col,success = self.maze:move_to_wall(self.robot_state.row, self.robot_state.col, self.robot_state.orientation)
  if success == false then -- this shouldn't happen on well-defined grids
      self:report_error(instruction_no, Tokens.MOVETOWALL, "attempted to move to wall but instead exited the maze")
      error("maze is missing borders", 2)
  end
  self.robot_state.row, self.robot_state.col = row, col
  assert_bounds(self.robot_state.row, "robot_state.row", 1, self.maze.height)
  assert_bounds(self.robot_state.col, "robot_state.col", 1, self.maze.width)
end

function Game:move_to_start(instruction_no)
  -- if there's no start in the robot's direction, this command follows the behaviour of self:move_to_wall
  local row,col,success = self.maze:move_to_start(self.robot_state.row, self.robot_state.col, self.robot_state.orientation)
  if success == false then
    self:report_warning_wall(instruction_no, Tokens.MOVETOSTART, "start")
  end
  self.robot_state.row, self.robot_state.col = row, col
  assert_bounds(self.robot_state.row, "robot_state.row", 1, self.maze.height)
  assert_bounds(self.robot_state.col, "robot_state.col", 1, self.maze.width)
end

function Game:move_to_end(instruction_no)
  -- if there's no end in the robot's direction, this command follows the behaviour of self:move_to_wall
  local row,col,success = self.maze:move_to_end(self.robot_state.row, self.robot_state.col, self.robot_state.orientation)
  if success == false then
    self:report_warning_wall(instruction_no, Tokens.MOVETOEND, "end")
  end
  self.robot_state.row, self.robot_state.col = row, col
  assert_bounds(self.robot_state.row, "robot_state.row", 1, self.maze.height)
  assert_bounds(self.robot_state.col, "robot_state.col", 1, self.maze.width)
end

function Game:nop()

end


function Game:new(str, _show_warnings)
  -- expecting to parse this data:
    -- 'type_str' describes the according GameType
    -- 'maze_str'
    -- `width`
    -- `height`  parameters to Maze:new()
  local start = 1
  local type_str, dim_line
  _,start,type_str = str:find('(.-)\r?\n', start)
  if not type_str then
    error("no game type found! please check the input file", 2)
  end
  _,start,dim_line = str:find('(.-)\r?\n', start+1)
  local height, width = dim_line:gmatch("(%d+)%s+(%d+)")()
  height, width = tonumber(height), tonumber(width)
  if type(height) ~= "number" or type(width) ~= "number" then
    error(string.format("invalid dimensions (got height = '%s', width = '%s'), refusing to continue", height, width))
  end
  local maze_str = str:sub(start+1)
  local game_type_key = string.upper(type_str)
  if not GameType[game_type_key] then
    error(string.format("unknown game type '%s', refusing to continue", type_str), 2)
  end
  --assert(GameType[game_type_key], _ENV.string.format("unknown game type '%s'", params.type_str))
  local o = { type = GameType[game_type_key], result = {type = GameResult.NONE, message = ""}, }
  setmetatable(o, self)
  o.maze = Maze:new({maze_str = maze_str, width=width, height=height})
  o.robot_state = RobotState:new{row = o.maze.start_cell.row, col = o.maze.start_cell.col }
  show_warnings = _show_warnings
  return o
end

return Game
