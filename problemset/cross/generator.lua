local CrossGenerator = require("problemset.generator"):new()

function CrossGenerator.generate(params)
  local n = params.n
  if type(n) ~= "number" or n < 1 then error(string.format("invalid value for n: '%s'"), n) return nil end
  local gen = CrossGenerator:new()
  local size = 4*n+7
  gen:init("cross", size, size)
  gen:add_borders()
  local center = size//2+1
  gen.grid[center][center]:add_start()
  local hole_delta_row, hole_delta_col = -1, 0
  local function generate_cross(m)
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
    generate_cross(2*m-1)
  end
  hole_delta_row, hole_delta_col = -hole_delta_col, hole_delta_row
  local m=2*n+1
  gen.grid[center+(m+1)*hole_delta_row][center+(m+1)*hole_delta_col]:add_end()
  return tostring(gen)
end


-- example usage:
--[[
io.write(CrossGenerator.generate({n=10}))
--]]


return CrossGenerator
