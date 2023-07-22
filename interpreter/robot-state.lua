local enums = require("enums")
local Direction = enums.Direction

local RobotState = {
  x = -1,
  y = -1,
  orientation = Direction.NORTH,
  items_collected = 0,
}
RobotState.__index = RobotState

function RobotState:new(o)
  o = o or {}
  setmetatable(o, self)
  return o
end

return RobotState
