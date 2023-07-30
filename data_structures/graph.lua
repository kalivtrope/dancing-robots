local Graph = {}
Graph.__index = Graph

function Graph:new(n)
  if type(n) ~= "number" or n < 0 then
    error(string.format("invalid value for n: %s (expected a non-negative number)", n), 2)
  end
  local o = {}
  o.n = n
  o.m = 0
  setmetatable(o, self)
  return o
end

function Graph:add_edge_uni(u, v)
  self[u] = self[u] or {}
  if type(self[u][v]) == "number" then return false end
  local weight = 1
  self[u][v] = weight
  self.m = self.m + 1
  return true
end

function Graph:get_edge(u, v)
  return self[u] and self[u][v]
end

function Graph:add_edge(u, v)
  self[u] = self[u] or {}
  self[v] = self[v] or {}
  if type(self[u][v]) == "number" or type(self[v][u]) == "number" then return false end
  return self:add_edge_uni(u, v) and (v == u or self:add_edge_uni(v, u))

end

function Graph:remove_edge(u, v)
  if not self[u] or not self[v] or type(self[u][v]) ~= "number" or type(self[v][u]) ~= "number" then return false end
  self[u][v] = nil
  self[v][u] = nil
  self.m = self.m - 1
  return true
end

local function reverse(list)
  local len = #list
  for i=1,len//2 do
    list[i], list[len-i+1] = list[len-i+1], list[i]
  end
end

function Graph:shortest_path(s, t)
  local pred = {[s] = s}
  local path = {}
  local curr, next = {s}, {}
  while #curr > 0 and not pred[t] do
    for _,u in pairs(curr) do
      for v in pairs(self[u]) do
        if not pred[v] then
          pred[v] = u
          next[#next+1] = v
        end
      end
    end
    curr, next = next, {}
  end
  local v = t
  while v ~= s do
    path[#path + 1] = v
    v = pred[v]
  end
  path[#path+1] = s
  reverse(path)
  return path
end

function Graph.new_random_tree(n, seed)
  math.randomseed(seed)
  local graph = Graph:new(n)
  for i=2,n do
    local other = math.random(i-1)
    if i ~= other then
      assert(graph:add_edge(i, other))
    end
  end
  return graph
end

function Graph.new_random_component(n, m, seed)
  if m < n-1 then error("not enough edges for a connected graph", 2) end
  if 2*m > n*(n-1) then error("too many edges for a connected graph", 2) end
  seed = seed or 42
  math.randomseed(seed)
  local graph = Graph.new_random_tree(n, seed)
  m = m - n + 1
  for _=1,m do
    local fin = false
    while not fin do
      local u, v = math.random(n), math.random(n)
      fin = graph:add_edge(u, v) and u ~= v
    end
  end
  return graph
end

function Graph:__tostring()
  local res = ""
  for i=1,self.n do
    local row = ""
    for j=1,self.n do
      if (self[i] or {})[j] then row = row .. self[i][j] .. " "
      else row = row .. ". " end
    end
    res = res .. row .. "\n"
  end
  return res
end

return Graph
