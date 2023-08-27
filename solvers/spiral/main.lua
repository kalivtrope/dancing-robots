local type_str = io.read("*line")
assert(type_str == "spiral", string.format("wrong game type (expected 'spiral', got '%s')", type_str))
local n = io.read("*n") - 2

local function turn_left()
  io.write("turnleft\n")
end

local function move_to_wall()
  io.write("movetowall\n")
end

for _=1,n do
 turn_left()
 move_to_wall()
end
