local Interpreter = require("interpreter")

local player_input, game_configuration = arg[1], arg[2]
int = Interpreter:new(player_input, game_configuration)
while not int.out_of_instructions and not int.error_encountered do
  local cmd = int:execute_next_command()
  print(cmd)
  print(int.game)
end
