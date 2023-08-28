local WaveGenerator = require("generators.common"):new()

function WaveGenerator.generate(params)
  local n = tonumber(params.n)
  if type(n) ~= "number" or n < 1 then n=10 end
  local gen = WaveGenerator:new()
  local size = 4*n+7
  gen:init("wave", size, size)
  gen:add_borders()
  local center = size//2+1
  gen.grid[center][center]:add_start()
  local hole_delta_row, hole_delta_col = -1, 0
  local function generate_wave(m)
    for i=1,m do
      gen.grid[center-(m//2+1-i)][center-(m+1)]:add_wall()
      gen.grid[center-(m+1)][center-(m//2+1-i)]:add_wall()
      gen.grid[center+(m//2+1-i)][center+(m+1)]:add_wall()
      gen.grid[center+(m+1)][center+(m//2+1-i)]:add_wall()

      if i <= m//2+1 then
        gen.grid[center-m//2-i][center-(m+1)+i]:add_wall()
        gen.grid[center+m//2+i][center-(m+1)+i]:add_wall()
        gen.grid[center-(m+1)+i][center+m//2+i]:add_wall()
        gen.grid[center+(m+1)-i][center+m//2+i]:add_wall()
      end
    end
    gen.grid[center+(m+1)*hole_delta_row][center+(m+1)*hole_delta_col]:remove_wall()
    gen.grid[center+m*hole_delta_row][center+m*hole_delta_col]:add_item()
    hole_delta_row, hole_delta_col = hole_delta_col, -hole_delta_row
  end
  for m=1,n+1 do
    generate_wave(2*m-1)
  end
  hole_delta_row, hole_delta_col = -hole_delta_col, hole_delta_row
  local m=2*n+1
  gen.grid[center+(m+1)*hole_delta_row][center+(m+1)*hole_delta_col]:add_end()
  return tostring(gen)
end


-- example usage:
--[[
io.write(WaveGenerator.generate({n=10}))
--]]


return WaveGenerator
