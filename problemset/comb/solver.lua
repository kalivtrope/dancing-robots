local type_str = io.read("*line")
assert(type_str == "comb", string.format("wrong game type (expected 'comb', got '%s')", type_str))

local function turnright()
  io.write("turnright\n")
end

local function turnleft()
  io.write("turnleft\n")
end

local function movetowall()
  io.write("movetowall\n")
end

local function movetoitem()
  io.write("movetoitem\n")
end

local function collect()
  io.write("collect\n")
end

local function drop()
  io.write("drop\n")
end

local height, width = io.read("*n", "*n", "*l")
local grid = {}
local row = 1
for line in (io.read("*all") .. "\n"):gmatch('(.-)\r?\n') do
  grid[row] = grid[row] or {}
  local col = 1
  for cell in line:gmatch("[#ISE%.]+") do
    grid[row][col] = cell
    col = col + 1
  end
  row = row + 1
end

turnright()
turnright()
local item_cnt = 0
for i=2,width-1,2 do
  movetowall()
  if i%4 == 2 then
    turnleft()
  else
    turnright()
  end
  if i%4 == 2 and grid[height-1][i+1] == 'I' or grid[2][i+1] == 'I' then
    movetoitem()
    collect()
    item_cnt = item_cnt + 1
  end
  movetowall()
  if i%4 == 2 then
    turnleft()
  else
    turnright()
  end
end

for i=1,item_cnt do
  drop()
end
