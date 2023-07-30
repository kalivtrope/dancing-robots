local Generator = require("problemset.generator")
local MatrixGenerator = Generator:new()
local Graph = require("data_structures.graph")

function MatrixGenerator.generate(params)
  -- n >= 3: number of vertices of the generated graph
  -- it is guaranteed that the shortest path always exists
      -- and is at least 2 edges long
      -- however, the shortest path is NOT guaranteed to be unique
  local n = params.n
  if type(n) ~= "number" or n <3 then return nil end
  local seed = params.seed or 42
  local total_n = params.n+2
  math.randomseed(seed)
  local m = params.m or math.random(2*n-1,math.min(4*n, n*(n-1)//2-1))
  local graph = Graph.new_random_component(n, m, seed)
  for i=1,n do
    graph:add_edge(i, i)
  end
  local gen = MatrixGenerator:new()
  gen:init("matrix", total_n, total_n)
  gen:add_borders()
  local a, b
  repeat
    a, b = math.random(n), math.random(n)
  until a ~= b and not (graph[a] or {})[b]
  for x=1,n do
    for y=1,n do
      if graph[y][x] then
        gen.grid[x+1][y+1]:add_item()
      end
      if x == b and y == a then
        gen.grid[x+1][y+1]:add_start()
        gen.grid[x+1][y+1]:add_end()
      end
    end
  end
  return tostring(gen)
end

--[[ Example usage:
local seed = nil or os.time()
io.write(MatrixGenerator.generate({n=10, m=10, seed=seed}))
--]]

return MatrixGenerator
