local type_str = io.read("*line")
assert(type_str == "wave", string.format("wrong game type (expected 'wave', got '%s')", type_str))
local n = (io.read("*n") - 7) // 4

local item_cnt = 0

local function movetoitem()
  io.write("movetoitem\n")
end

local function turnright()
  io.write("turnright\n")
end

local function turnleft()
  io.write("turnleft\n")
end

local function collect()
  item_cnt = item_cnt + 1
  io.write("collect\n")
end

local function drop()
  item_cnt = item_cnt - 1
  io.write("drop\n")
end

local function movetowall()
  io.write("movetowall\n")
end

local function movetoend()
  io.write("movetoend\n")
end

movetoitem()
collect()
for i=1,n do
  movetowall()
  turnright()
  movetowall()
  turnright()
  for _=1,i+1 do
    movetowall()
    turnleft()
    movetowall()
    turnright()
  end
  movetoitem()
  collect()
  turnleft()
end
movetoend()
for _=1,item_cnt do
  drop()
end
