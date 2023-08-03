local enums = require("interpreter.enums")
local Direction = enums.Direction

local RobotState = {
  row = -1,
  col = -1,
  orientation = Direction.NORTH,
  items_collected = 0,
}
RobotState.__index = RobotState

function RobotState:turn_left()
  self.orientation = (self.orientation - 2) % Direction._NUM_DIRS + 1
end

function RobotState:turn_right()
  self.orientation = self.orientation % Direction._NUM_DIRS + 1
end

function RobotState:collect()
  self.items_collected = self.items_collected + 1
end

function RobotState:drop()
  if self.items_collected == 0 then
    return false
  end
  self.items_collected = self.items_collected - 1
  return true
end


function RobotState:new(o)
  o = o or {}
  setmetatable(o, self)
  return o
end

return RobotState
