#!/usr/bin/lua

local function help()
  return
[[
Usage: main.lua [-h|--help]
                [-p|--show-progress]
                [-w|--show-warnings]
                [-s <num>|--seed <num>]
                [-d <seconds>|--delay <seconds>]
                [--stdout]
                <command> [<args>]

COMMANDS
  generate <problem-class> <input-name>
    Generate a file called <input-name>.in of class <problem-class> to the Inputs folder.
    If the generator requires N additional named args (with names <arg1>,...,<argN>
    and respective values <val1>,...,<valN>), specify them space-separated like this:
      <arg1> <val1> <arg2> <val2> ... <argN> <valN>
  test <input-name> OR <input-path> <output-path>
    Test a single problem instance.
    You can either specify just an <input-name> which is equivalent to calling
    test Inputs/<input-name>.in Outputs/<input-name>.out
    OR provide a full path (relative or absolute) for both the input and output files.

OPTIONS
  -h, --help
      Print this help.
  -p, --show-progress
      Display current game configuration after every command execution.
      in the test mode.
  -w, --show-warnings
      Display warnings occurring during the gameplay.
      These can be triggered for example by dropping from an empty inventory
      or stopping in front of a wall while intending to move to an item.
  -s, --seed <num>
      Specify a numeric seed for the generator. Must be an integer. Defaults to 42.
  -d, --delay <seconds>
      Specify a delay between two command executions in seconds. Must be a non-negative number.
      Only effective with --show-progress. Defaults to 0.1.
  --stdout
      Print the generator output to stdout instead of a file.
      If you intend to use this option, you should do it before specifying
      any positional arguments to the generator.
]]
end

local function fail(msg)
  io.write("ERROR: " .. msg .. "\n\n")
  io.write(help())
  os.exit(1)
end

local function msg_missing_arg(arg_name, command_name)
  return string.format("missing <%s> for the '%s' command.", arg_name, command_name)
end

local function msg_slash_in_filename(arg_name)
  return string.format("<%s> MUST NOT contain a / (forward slash)", arg_name)
end

local print_help = false
local show_progress = false
local show_warnings = false
local delay
local command_name
local args = {}
local kwargs = {}
local curr_key
local awaiting_value = false
local default_input_path = "./Inputs/"
local default_output_path = "./Outputs/"
local use_stdout = false
for _,str in ipairs(arg) do
  if awaiting_value then
    kwargs[curr_key] = str
    awaiting_value = false
  elseif str == "-h" or str == "--help" then
    print_help = true
  elseif str == "-p" or str == "--show-progress" then
    show_progress = true
  elseif str == "-w" or str == "--show-warnings" then
    show_warnings = true
  elseif str == '-s' or str == '--seed' then
    curr_key = "seed"
    awaiting_value = true
  elseif str == '-d' or str == '--delay' then
    curr_key = "delay"
    awaiting_value = true
  elseif str == '--stdout' then
    use_stdout = true
  elseif (str == "generate" or str == "test") and not command_name then
    command_name = str
  else
    if not command_name then
      fail(string.format("expected one of {generate,test} at position 1, got '%s' instead", str))
    end
    if (command_name == "generate" and #args < 2 - (use_stdout and 1 or 0))
      or (command_name == "test" and #args < 2) then
      args[#args+1] = str
    else
      curr_key = str
      awaiting_value = true
    end
  end
end

if print_help or not command_name then
  io.write(help())
end

if not kwargs.seed then
  kwargs.seed = 42
else
  local seed = tonumber(kwargs.seed)
  if not seed or seed%1 ~= 0 then
    fail(string.format("value associated with 'seed' is not an integer: '%s'", kwargs.seed))
  end
  kwargs.seed = seed
end


if not kwargs.delay then
  delay = 0.1
else
  delay = tonumber(kwargs.delay)
  if not delay or delay < 0 then
    fail(string.format("value associated with 'delay' is not a non-negative number: '%s'", kwargs.delay))
  end
end

local function generate()
  local input_handle
  if use_stdout then
    input_handle = io.stdout
  else
    local input_file_path = default_input_path .. args[2] .. ".in"
    input_handle = assert(io.open(input_file_path, "w"))
  end
  local Generator = require("generators." .. args[1] .. ".main")
  input_handle:write(Generator.generate(kwargs))
  input_handle:close()
end

local function test()
  local Interpreter = require("interpreter.interpreter")
  local game_conf_path = default_input_path .. args[1] .. ".in"
  local player_input_path = default_output_path .. args[1] .. ".out"
  if args[2] then
    game_conf_path = args[1]
    player_input_path = args[2]
  end
  local game_configuration_str  = assert(io.open(game_conf_path, "r")):read("*a")
  local player_input_str = assert(io.open(player_input_path, "r")):read("*a")
  local int = Interpreter:new(game_configuration_str, player_input_str, show_warnings)

  local judge = require("judges."..int.game.type..".main"):attach_to_interpreter(int)

  while true do
    judge:judge_next_command()
    if judge.judgment_received then
      io.write(tostring(judge.interpreter.game))
      io.write(judge.judgment_success and "SUCCESS\n" or "FAIL: " .. judge.judgment_verdict)
      if judge.judgment_success then
        os.exit(42)
      else
        os.exit(43)
      end
      break
    end
    if show_progress then
      io.write(judge.interpreter.instruction_no .. " " .. judge.interpreter:last_command_executed().."\n")
      io.write(tostring(judge.interpreter.game))
      os.execute("sleep ".. delay)
    end
  end

end


if command_name == "generate" then
  if not args[1] then
    fail(msg_missing_arg("problem-class", "generate"))
  end
  if not use_stdout and not args[2] then
    fail(msg_missing_arg("input-name", "generate"))
  end
  if not use_stdout and string.find(args[2], "/") then
    fail(msg_slash_in_filename("input-name"))
  end
  generate()
elseif command_name == "test" then
  if not args[1] then
    fail(msg_missing_arg("input-name", "test"))
  end
  if not args[2] and string.find(args[1], "/") then
    fail(msg_slash_in_filename("input-name"))
  end
  test()
end
