local SpiralGenerator = require("problemset.generator"):new()

function SpiralGenerator.generate(params)
  local n = params.n
  if type(n) ~= "number" or n < 1 then error(string.format("invalid value for n: '%s'"), n) return nil end
  local gen = SpiralGenerator:new()
  local height = 4*n+2
  local width = 4*n+1
  gen:init("spiral", height, width)
  gen:add_borders()

  local start_row, start_col = 2, width-1
  local end_row, end_col = height // 2 + 1, width // 2 + 2
  gen.grid[start_row][start_col]:add_start()
  gen.grid[end_row][end_col]:add_end()

  local curr_row, curr_col = start_row+1, start_col
  local curr_row_delta, curr_col_delta = 0, -1
  while true do
    gen.grid[curr_row][curr_col]:add_wall()
    for i=1,2 do
      local test_row, test_col = curr_row + 2*curr_row_delta, curr_col + 2*curr_col_delta
      if test_row < 1 or test_row > height or test_col < 1 or test_col > width
        or not gen.grid[test_row][test_col]:is_empty() then
        if i == 2 then return tostring(gen) end
        curr_row_delta, curr_col_delta = -curr_col_delta, curr_row_delta
      else
        curr_row, curr_col = curr_row + curr_row_delta, curr_col + curr_col_delta
        break
      end
    end
  end

  return tostring(gen)
end

-- example usage:
--[[
io.write(SpiralGenerator.generate({n=10}))
--]]


return SpiralGenerator
