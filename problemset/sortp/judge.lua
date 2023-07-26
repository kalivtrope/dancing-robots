local Judge = require("problemset.judge")

local SortpJudge = Judge:new()
SortpJudge.__index = SortpJudge

function SortpJudge:test_if_sorted()
  local error_encountered = false
  for x=2,self.maze.width-1,2 do
    for y=self.maze.height-1,self.maze.height+1-x,-2 do
      if not self.maze[x][y]:is_item() then
        self:add_verdict(string.format("missing item at pos (%d,%d)", x, y))
        error_encountered = true
      end
    end
  end
  return not error_encountered
end

function SortpJudge:make_judgment()
  self:add_judgment(self:test_if_robot_survived())
  self:add_judgment(self:test_if_robot_is_at_end())
  self:add_judgment(self:test_if_sorted())
  self.judgment_received = true
end

return SortpJudge
