local enums = require("enums")
local RobotState = require("robot-state")
local Maze = require("maze")
local GameType, GameResult = enums.GameType, enums.GameResult

local Game = {
  maze = nil,
  over = false,
  type = GameType.NONE,
  robot_state = nil,
  code = nil,
}

Game.__index = Game

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
