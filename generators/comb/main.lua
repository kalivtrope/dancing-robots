local CombGenerator = require("generators.common"):new()

function CombGenerator.generate(params)
  local n = tonumber(params.n)
  local m = tonumber(params.m)
  if type(n) ~= "number" or n < 1 then n=10 end
  if type(m) ~= "number" or m < 1 then m=8 end
  local seed = tonumber(params.seed) or 42
  math.randomseed(seed)
  local height = m + 3
  local width = 4*n+3
  local gen = CombGenerator:new()
  gen:init("comb", height, width)
  gen:add_borders()
  gen.grid[2][2]:add_start()
  gen.grid[height-1][width-1]:add_end()

  for wall_col=3,width-1,2 do
    for r = 2,height-2 do
      local wall_row = wall_col%4 == 3 and r or r+1
      gen.grid[wall_row][wall_col]:add_wall()
    end
    if math.random() > 0.5 then
      local item_row = wall_col%4 == 3 and height - 1 or 2
      gen.grid[item_row][wall_col]:add_item()
    end
  end

  return tostring(gen)
end

-- example usage:
--[[
io.write(CombGenerator.generate({n=2}))
--]]


return CombGenerator
