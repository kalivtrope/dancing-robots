local utils = require("interpreter.utils")
local write_stderr = utils.write_stderr
local enums = require("interpreter.enums")
local Tokens = enums.Tokens
local Game = require("interpreter.game")


local Interpreter = {
  instruction_no = 0,
  error_encountered = false,
  out_of_instructions = false,
  tokens = nil,
  game = nil,
}

Interpreter.__index = Interpreter

local OUT_OF_INSTRUCTIONS = "OUT_OF_INSTRUCTIONS"

function Interpreter:count_instructions()
  return #self.tokens
end

function Interpreter:report_error(line_no, err)
  self.error_encountered = true
  write_stderr(string.format("[line %d] error: %s\n", line_no, err))
end

local function tokenize_one_line(self, line_no, line)
  local tokens = {}
  local undashed_line = string.gsub(line, '[%-_]', '')
  for raw_token in string.gmatch(undashed_line, "%a+") do
    local token = string.upper(raw_token)
    if not Tokens[token] then
      self:report_error(line_no, string.format("unknown command '%s'", raw_token))
    else
      tokens[#tokens + 1] = token
    end
  end
  return tokens
end


local function tokenize_file(self, file_contents)
  local tokens = {}
  local line_no = 1
  for line in (file_contents .. '\n'):gmatch('(.-)\r?\n') do
    for _,new_token in ipairs(tokenize_one_line(self,line_no,line)) do
      tokens[#tokens + 1] = new_token
    end
    line_no = line_no + 1
  end
  return tokens
end

function Interpreter:last_command_executed()
  return Tokens[self.tokens[self.instruction_no]]
end

function Interpreter:execute_next_command(randomize)
  if self.out_of_instructions or self.error_encountered then return false end
  self.instruction_no = self.instruction_no + 1
  local _cmd = randomize and Tokens[math.random(1, Tokens._len)] or Tokens[self.tokens[self.instruction_no]]
  if not _cmd then
    self.out_of_instructions = true
    return OUT_OF_INSTRUCTIONS
  end
  self.game[string.lower(_cmd)](self.game, self.instruction_no)
  if self.game.error_encountered then
    self.error_encountered = true
  end
  return _cmd
end

function Interpreter:execute_n_commands(n)
  local cmd_list = {}
  for _=1,n do
    local cmd_name = self:execute_next_command()
    if cmd_name == OUT_OF_INSTRUCTIONS or self.error_encountered then
      return cmd_list
    end
    cmd_list[#cmd_list+1] = cmd_name
  end
  return cmd_list
end

function Interpreter:new(maze_configuration_str, player_input_str)
  local o = {}
  setmetatable(o, self)
  o.tokens = tokenize_file(o, player_input_str)
  if (#o.tokens) == 0 then o.tokens[1] = "NOP" end
  if o.error_encountered then
    write_stderr("errors were encountered, refusing to continue.\n")
    return nil
  end
  o.game = Game:new(maze_configuration_str)
  return o
end

-- local player_input =... or arg[1]
-- local player_input_handle = player_input and assert(io.open(player_input, "r")) or io.stdin
--
-- local tokens = tokenize_file(player_input_handle)



--print(table.unpack(tokens))
--return tokens

--local tokens = assert(tokenize(data))
--print(data)

return Interpreter
