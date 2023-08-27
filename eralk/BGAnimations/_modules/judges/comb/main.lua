local Judge = require("judges.common")

local CombJudge = Judge:new()

function CombJudge:make_judgment()
  self:add_judgment(self:test_if_robot_is_at_end())
  self:add_judgment(self:test_if_everything_collected())
  self:add_judgment(self:test_if_inventory_emptied())
  self.judgment_received = true
end

return CombJudge
