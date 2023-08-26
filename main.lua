local Interpreter = require("interpreter.interpreter")

local game_configuration_str, player_input_str  = assert(io.open(arg[1], "r")):read("*a"), assert(io.open(arg[2], "r")):read("*a")
local int = Interpreter:new(game_configuration_str, player_input_str)
local judge = require("judges."..int.game.type.."-judge"):attach_to_interpreter(int)


while true do
  judge:judge_next_command()
  if judge.judgment_received then
    io.write(tostring(judge.interpreter.game))
    io.write(judge.judgment_success and "SUCCESS" or "FAIL: " .. judge.judgment_verdict)
    break
  end
  io.write(judge.interpreter.instruction_no .. " " .. judge.interpreter:last_command_executed().."\n")
  io.write(tostring(judge.interpreter.game))
  os.execute("sleep 0.1")
end
