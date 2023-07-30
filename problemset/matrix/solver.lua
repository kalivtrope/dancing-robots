local type_str = io.read("*line")
assert(type_str == "matrix", string.format("wrong game type (expected 'sortp', got '%s')", type_str))
--local height, width = io.read("*n", "*n", "*l")
local n = (io.read("*n", "*n", "*l") - 2)
local graph = {}

local Direction = {
  North = 1,
  East  = 2,
  South = 3,
  West  = 4,
}
local state = {
  dir = Direction.North,
  row = -1,
  col = -1,
}

local function shortest_path(source, sink)
  local pred = {[source] = source}
  local path = {}
  local curr, nxt = {source}, {}
  while #curr > 0 and not pred[sink] do
    for _,u in pairs(curr) do
      for v in pairs(graph[u]) do
        if not( (u == source and v == sink) or (u == sink and v == source) ) then
        if not pred[v] then
          pred[v] = u
          nxt[#nxt+1] = v
        end
        end
      end
    end
    curr, nxt = nxt, {}
  end
  --print(source, sink)
  --print(table.unpack(pred))
  local v = sink
  while v ~= source do
    path[#path+1] = v
    v = pred[v]
  end
  path[#path+1] = source
  for i=1,#path//2 do
    path[i], path[#path-i+1] = path[#path-i+1], path[i]
  end
  return path
end

local function turnleft()
  io.write("turnleft\n")
  state.dir = (state.dir - 2) % 4 + 1
end

local function turnright()
  io.write("turnright\n")
  state.dir = state.dir % 4 + 1
end

local function movetoitem()
  io.write("movetoitem\n")
end

local function movetowall()
  io.write("movetowall\n")
end

local function collect()
  io.write("collect\n")
end

local function movetoend()
  io.write("movetoend\n")
end

local function drop()
  io.write("drop\n")
end

local function turn_dir(dir)
  local diff = state.dir - dir
  if math.abs(diff) == 3 then
    if diff < 0 then turnleft() else turnright() end
  elseif math.abs(diff) == 2 then
    turnright() turnright()
  elseif math.abs(diff) == 1 then
    if diff < 0 then turnright() else turnleft() end
  end
  assert(dir == state.dir)
end

local function turn_north()
  turn_dir(Direction.North)
end

local function turn_south()
  turn_dir(Direction.South)
end

local function turn_west()
  turn_dir(Direction.West)
end

local function turn_east()
  turn_dir(Direction.East)
end

local function move_to_column(col_no)
  if col_no == state.col then return end
  if col_no < state.col then
    turn_west()
  else
    turn_east()
  end
  if col_no == 1 or col_no == n then movetowall() state.col = 1 return end
  while col_no ~= state.col do
    movetoitem()
    if col_no < state.col then
      assert(graph[state.row][state.col].left)
      state.col = graph[state.row][state.col].left
    else
      --print(state.row, state.col, graph[state.row][state.col])
      assert(graph[state.row][state.col].right, state.row .. " " .. state.col)
      state.col = graph[state.row][state.col].right
    end
  end
end

local function move_to_row(row_no)
  if row_no == state.row then return end
  if row_no < state.row then
    turn_north()
  else
    turn_south()
  end
  if row_no == 1 or row_no == n then movetowall() state.row = 1 return end
  while row_no ~= state.row do
    movetoitem()
    if row_no < state.row then
      assert(graph[state.row][state.col].up)
      state.row = graph[state.row][state.col].up
    else
      assert(graph[state.row][state.col].down)
      state.row = graph[state.row][state.col].down
    end
  end
end

local row = 0
local source, sink
local up = {}
for line in (io.read("*all") .. "\n"):gmatch('(.-)\r?\n') do
  local col = 0
  local left
  for cell in line:gmatch("[#ISE%.]+") do
    for obj_type in cell:gmatch(".") do
      if obj_type == 'I' then
          graph[row] = graph[row] or {}
          graph[row][col] = {left = left}
          if left then graph[row][left].right = col end
          if up[col] then graph[row][col].up = up[col] graph[up[col]][col].down = row end
          up[col] = row
          left = col
          if row == source and not graph[row][sink].right then graph[row][sink].right = col end
          if col == sink and not graph[source][col].up then graph[source][col].up = row end
      end
      if obj_type == 'S' or obj_type == 'E' then
        graph[row] = graph[row] or nil
        graph[row][col] = graph[row][col] or {}
        graph[row][col].left = left
        graph[row][col].up = up[col]
        source = row
        sink = col
      end
    end
    col = col+1
  end
  row = row+1
end
state.row, state.col = source, sink

local path = shortest_path(source, sink)
--print(table.unpack(path))
local prev = nil
for k,v in ipairs(path) do
  if prev then move_to_row(prev) end
  prev = v
  --if k%2 == 0 then
  --print("move_to_column", v)
  if k > 1 then
      move_to_column(v)
      collect()
    end
    --else
      --print("move_to_row", v)
      --move_to_row(v)
    --end
  --end
end

move_to_row(prev)
if source < state.row then turn_north() else turn_south() end
movetoend()
for _=1,#path-1 do
  drop()
end
