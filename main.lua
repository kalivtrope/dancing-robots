local Interpreter = require("interpreter.interpreter")

local game_configuration, player_input  = arg[1], arg[2]
local int = Interpreter:new(player_input, game_configuration)
local judge = require("judges."..int.game.type.."-judge"):attach_to_interpreter(int)


while true do
  judge:judge_next_command()
  if judge.judgment_received then
    print(judge.judgment_success and "SUCCESS" or "FAIL: "..judge.judgment_verdict)
    break
  end
  io.write(judge.interpreter.instruction_no .. " " .. judge.interpreter:last_command_executed().."\n")
  io.write(tostring(judge.interpreter.game))
  os.execute("sleep 0.05")
end
