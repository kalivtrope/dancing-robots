local type_str = io.read("*line")
assert(type_str == "sortp", string.format("wrong game type (expected 'sortp', got '%s')", type_str))
--local height, width = io.read("*n", "*n", "*l")
local n = (io.read("*n", "*n", "*l") - 2) // 2
local grid = {}

local function is_item(x,y)
  return (grid[x][y]['I'] or 0) > 0
end

local function is_wall(x,y)
  return (grid[x][y]['#'] or 0) > 0
end

local function is_start(x,y)
  return (grid[x][y]['S'] or 0) > 0
end

local function is_end(x,y)
  return (grid[x][y]['E'] or 0) > 0
end

local function is_empty(x,y)
  return (grid[x][y]['.'] or 0) > 0
end

local function column_to_grid_coords(column_x, column_y)
  return 2*column_x,2*n+3-2*column_y
end

local function collect()
  io.write("collect\n")
end

local function drop()
  io.write("drop\n")
end

local function turnright()
  io.write("turnright\n")
end

local function turnleft()
  io.write("turnleft\n")
end

local function movetoitem()
  io.write("movetoitem\n")
end

local function movetowall()
  io.write("movetowall\n")
end

local function movetostart()
  io.write("movetostart\n")
end

local function movetoend()
  io.write("movetoend\n")
end
do
local y = 1
local start_x, start_y, end_x, end_y
for line in (io.read("*all") .. '\n'):gmatch('(.-)\r?\n') do
  local x = 1
  for cell in line:gmatch("[#ISE%.]+") do
    grid[x] = grid[x] or {}
    grid[x][y] = {}
    for obj_type in cell:gmatch(".") do
      grid[x][y][obj_type] = (grid[x][y][obj_type] or 0) + 1
    end
    if is_start(x,y) then start_x, start_y = x,y end
    if is_end(x,y) then end_x, end_y = x,y end
    x = x+1
  end
  y = y+1
end
end

local seq={}
-- obtain the permutation from the placed items
for i=1,n do
  local val = 0
  local x, y = column_to_grid_coords(i, val+1)
  while y > 1 and is_item(x, y) do
    val = val+1
    x, y = column_to_grid_coords(i, val+1)
  end
  seq[#seq+1] = val
end
--print(table.unpack(seq))


-- iterate over rows from bottom to top
for i=1,n do
  -- assume north orientation
  local items_to_collect = 0
  for j=1,i-1 do
    if seq[j] >= i then items_to_collect = items_to_collect + 1 end
  end
  turnleft() movetowall()
  local x,y = column_to_grid_coords(1, i)
  if i ~= 1 and is_item(x,y) then
    collect()
    items_to_collect = items_to_collect - 1
  end
  turnright() turnright()
  for _=1,items_to_collect do
    movetoitem()
    collect()
  end
  movetowall()
  x,y = column_to_grid_coords(i, i)
  if not is_item(x,y) then
    drop()
  end

  if i > 2 then
    turnright()
    local col_x, col_y = i, i
    for j=i,math.min(2*i-3,n-1) do
        movetowall() turnleft() col_y = col_y - 1
        local g_x,g_y = column_to_grid_coords(col_x, col_y)
        if not is_item(g_x,g_y) then drop() end
        movetowall() turnright() col_x = col_x + 1
        g_x,g_y = column_to_grid_coords(col_x, col_y)
        if not is_item(g_x,g_y) then drop() end
    end
    movetowall()
    col_y = col_y - 1
    local g_x,g_y = column_to_grid_coords(col_x, col_y)
    if not is_item(g_x,g_y) then drop() end
    turnright() turnright() movetoitem() turnleft()
    for _=i,math.min(2*i-3,n-1) do
      movetoitem() turnright() movetoitem() turnleft()
    end
    turnright() turnright()
  end
  turnleft()
  movetowall()
end

turnright()
movetoend()
