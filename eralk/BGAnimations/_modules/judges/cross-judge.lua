local Judge = require("judges.common")


local CrossJudge = Judge:new()

function CrossJudge:make_judgment()
  self:add_judgment(self:test_if_robot_is_at_end())
  self:add_judgment(self:test_if_everything_collected())
  self:add_judgment(self:test_if_inventory_emptied())
  self.judgment_received = true
end

return CrossJudge
