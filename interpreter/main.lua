package.path = "../?.lua;" .. package.path -- TODO: decide about execution path
local Interpreter = require("interpreter")
--local MatrixJudge = require("problemset.matrix.judge")

local player_input, game_configuration = arg[1], arg[2]
local int = Interpreter:new(player_input, game_configuration)
local judge = require("problemset."..int.game.type..".judge"):attach_to_interpreter(int)


while true do
  judge:judge_next_command()
  if judge.judgment_received then break end
  io.write(judge.interpreter.instruction_no .. " " .. judge.interpreter:last_command_executed().."\n")
  io.write(tostring(judge.interpreter.game))
  os.execute("sleep 0.1")
end
