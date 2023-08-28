local Generator = require("generators.common")
local MatrixGenerator = Generator:new()
local Graph = require("data_structures.graph")

function MatrixGenerator.generate(params)
  -- n >= 3: number of vertices of the generated graph
  -- it is guaranteed that the shortest path always exists
      -- and is at least 2 edges long
      -- however, the shortest path is NOT guaranteed to be unique
  local n = tonumber(params.n)
  if type(n) ~= "number" or n <10 then n=10 end
  local seed = tonumber(params.seed) or 42
  local total_n = n+2
  math.randomseed(seed)
  local m = tonumber(params.m) or math.random(2*n-1,math.min(4*n, n*(n-1)//2-1))
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
  for row=1,n do
    for col=1,n do
      if graph[row][col] then
        gen.grid[row+1][col+1]:add_item()
      end
      if col == b and row == a then
        gen.grid[row+1][col+1]:add_start()
        gen.grid[row+1][col+1]:add_end()
      end
    end
  end
  return tostring(gen)
end

--[[ Example usage:
local seed = nil or os.time()
io.write(MatrixGenerator.generate({n=5, m=8, seed=seed}))
--]]

return MatrixGenerator
