local Judge = require("judges.common")
local Graph = require("data_structures.graph")

local MatrixJudge = Judge:new()

function MatrixJudge:process_graph()
  local maze = self.interpreter.game.maze
  local n = maze.width
  self.graph = Graph:new(n)
  for u=2,n-1 do
    for v=2,n-1 do
      if maze[u][v]:is_item() then
        self.graph:add_edge_uni(u,v)
      end
      if maze[u][v]:is_start() and maze[u][v]:is_end() then
        self.source = u
        self.sink = v
      end
    end
  end
  assert(self.source and self.sink, "missing start or end position")
end

function MatrixJudge:test_if_shortest_path_found()
  local shortest_path = self.graph:shortest_path(self.source, self.sink)
  local reported_len = self.maze[self.source][self.sink]:count_items()
  if reported_len ~= #shortest_path-1 then
    self:add_verdict(string.format("reported path wasn't the shortest (got length %d from dropped items)",reported_len))
    return false
  end
  return true
end


function MatrixJudge:test_if_path_found()
  local n = self.maze.width
  local succ, pred = {}, {}
  local error_encountered = false
  for u=1,n do
    for v=1,n do
      if not (u == self.source and v == self.sink) then
        if self.maze[u][v]:is_item() and not self.graph:get_edge(u, v) then
          self:add_verdict(string.format("extra edge (%d,%d) found", v-1, u-1))
          error_encountered = true
        end
        if not self.maze[u][v]:is_item() and self.graph:get_edge(u, v) then
          if succ[u] then
            self:add_verdict(string.format("reported edges don't form a path (extra edge: (%d,%d))", v-1, u-1))
            error_encountered = true
          end
          if pred[v] then
            self:add_verdict(string.format("reported edges don't form a path (extra edge: (%d,%d))", v-1, u-1))
            error_encountered = true
          end
          pred[v] = u
          succ[u] = v
        end
      end
    end
  end
  if not error_encountered then
    local curr_v = self.source
    while curr_v and curr_v ~= self.sink do
      curr_v = succ[curr_v]
    end
    if not curr_v then
      self:add_verdict(string.format("described path isn't a path from node %d to node %d", self.sink-1, self.source-1))
      error_encountered = true
    end
  end
  return not error_encountered
end

function MatrixJudge:make_judgment()
  self:add_judgment(self:test_if_robot_is_at_end())
  self:add_judgment(self:test_if_path_found())
  if self.judgment_success then
    self:add_judgment(self:test_if_shortest_path_found())
  end
  self.judgment_received = true
end

function MatrixJudge:judge_next_command(randomize)
  if self.interpreter.instruction_no == 0 then
    self:process_graph()
  end
  return Judge.judge_next_command(self,randomize)
end

return MatrixJudge
