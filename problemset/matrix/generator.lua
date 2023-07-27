local Generator = require("problemset.generator")
local MatrixGenerator = Generator:new()
local Graph = require("data_structures.graph")

function MatrixGenerator.generate(n, seed)
  -- n >= 3: number of vertices of the generated graph
  if type(n) ~= "number" or n <3 then return nil end
  seed = seed or 42
  local total_n = n+2
  math.randomseed(seed)
  local m = math.random(n-1,math.min(4*n, n*(n-1)//2-1))
  local graph = Graph.new_random_component(n, m, seed)
  local gen = MatrixGenerator:new()
  gen:init("matrix", total_n, total_n)
  gen:add_borders()
  local a, b
  repeat
    a, b = math.random(n), math.random(n)
  until a ~= b and not (graph[a] or {})[b]
  for x=1,n do
    for y=1,n do
      if graph[x][y] then
        gen.grid[x+1][y+1]:add_item()
      end
      if x == a and y == b then
        gen.grid[x+1][y+1]:add_start()
        gen.grid[x+1][y+1]:add_end()
      end
    end
  end
  return tostring(gen)
end

--[[ Example usage:
local seed = nil --or os.time()
io.write(MatrixGenerator.generate(5, seed))
--]]

return MatrixGenerator
