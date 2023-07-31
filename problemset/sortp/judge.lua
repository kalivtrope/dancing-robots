local Judge = require("problemset.judge")

local SortpJudge = Judge:new()

function SortpJudge:test_if_sorted()
  local error_encountered = false
  for col=2,self.maze.width-1,2 do
    for row=self.maze.height-1,self.maze.height+1-col,-2 do
      if not self.maze[row][col]:is_item() then
        self:add_verdict(string.format("missing item at pos (%d,%d)", row, col))
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
