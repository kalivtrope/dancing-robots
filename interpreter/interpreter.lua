local error_encountered = false
local Tokens = {
  TURNLEFT = 1,
  TURNRIGHT = 2,
  COLLECT = 3,
  DROP = 4,
  MOVETOITEM = 5,
  MOVETOWALL = 6,
  MOVETOSTART = 7,
  MOVETOEND = 8,
  NOP = 9,
}

local function write_stderr(msg)
  io.stderr:write(msg)
end

local function report_error(line_no, err)
  error_encountered = true
  write_stderr(string.format("[line %d] error: %s\n", line_no, err))
end

local function tokenize_one_line(line_no, line)
  local tokens = {}
  local undashed_line = string.gsub(line, '[%-_]', '')
  for raw_token in string.gmatch(undashed_line, "%a+") do
    local token = string.upper(raw_token)
    if not Tokens[token] then
      report_error(line_no, string.format("unknown command '%s'", raw_token))
    else
      tokens[#tokens + 1] = token
    end
  end
  return tokens
end



local function tokenize_all_lines(file_handle)
  local tokens = {}
  local line_no = 1
  for line in file_handle:lines() do
    for _,new_token in ipairs(tokenize_one_line(line_no,line)) do
      tokens[#tokens + 1] = new_token
    end
    line_no = line_no + 1
  end
  return tokens
end

local filename=... or arg[1]
local file = filename and assert(io.open(filename, "r")) or io.stdin

local tokens = tokenize_all_lines(file)

if error_encountered then
  write_stderr("errors were encountered, refusing to continue.\n")
end

print(table.unpack(tokens))
return tokens

--local tokens = assert(tokenize(data))
--print(data)
