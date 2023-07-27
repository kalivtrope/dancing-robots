local Judge = require("problemset.judge")

local MatrixJudge = Judge:new()
MatrixJudge.__index = MatrixJudge


function MatrixJudge:make_judgment()
  print("custom judgment")
  self.judgment_received = true
end

return MatrixJudge
