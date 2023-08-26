local Judge = require("judges.common")

local SpiralJudge = Judge:new()

function SpiralJudge:make_judgment()
  self:add_judgment(self:test_if_robot_is_at_end())
  self.judgment_received = true
end


return SpiralJudge
