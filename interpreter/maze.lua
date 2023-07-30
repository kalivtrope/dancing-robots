local Cell = require("interpreter.cell")
local enums = require("interpreter.enums")
local utils = require("interpreter.utils")
local FenwickTree = require("data_structures.fenwick-tree")
local ObjectType, Direction = enums.ObjectType, enums.Direction
local assert_type, assert_bounds = utils.assert_type, utils.assert_bounds


local Maze = {
  width = -1,
  height = -1,
  start_cell = nil,
  end_cell = nil,
  item_rows = nil,
  item_cols = nil,
}

Maze.__index = Maze
Maze.__tostring = function(self)
  local res = ""
  for y=1,self.height do
    for x=1,self.width do
      res = res .. tostring(self[x][y]) .. " "
    end
    res = res .. "\n"
  end
  return res
end


local ItemRow = {}
ItemRow.__index = ItemRow

function ItemRow:new(len)
  local res = {}
  setmetatable(res, self)
  res.len = len
  res.items = FenwickTree:new(len)
 -- virtual items with boundary purposes
  res[0] = {left = 0, right = len+1}
  res[len+1] = {left = 0, right = len+1}
  return res
end

function ItemRow:index_of_lower_bound(pos)
  -- return greatest value p <= pos such that there's an item at position p
  assert_type(pos, "pos", "number")
  assert_bounds(pos, "pos", 1, self.len)
  if self[pos] then
    return pos
  end
  return self.items:sum(pos)
end

function ItemRow:left(pos)
  assert_type(pos, "pos", "number")
  assert_bounds(pos, "pos", 1, self.len)
  if self[pos] then return self[pos].left end
  return self:index_of_lower_bound(pos)
end

function ItemRow:right(pos)
  assert_type(pos, "pos", "number")
  assert_bounds(pos, "pos", 1, self.len)
  if self[pos] then return self[pos].right end
  return self[self:index_of_lower_bound(pos)].right
end

function ItemRow:add_item(pos)
  if self[pos] then
    error("attempt to insert already existing item!", 2)
  end
  local left_idx = self:index_of_lower_bound(pos)
  assert_type(left_idx, "left_idx", "number")
  local right_idx = self[left_idx].right
  assert_type(right_idx, "right_idx", "number")

  self.items:add(pos, pos-left_idx)
  self.items:add(right_idx,left_idx-pos)
  self[pos] = {left = left_idx, right = right_idx}
  self[left_idx].right = pos
  self[right_idx].left = pos
end

function ItemRow:remove_item(pos)
  if not self[pos] then
    error("attempt to remove nonexistent item!", 2)
  end
  local left_idx = self[pos].left
  local right_idx = self[pos].right
  assert_type(left_idx, "left_idx", "number")
  assert_type(right_idx, "right_idx", "number")

  self.items:add(pos, -(pos-left_idx))
  self.items:add(right_idx, -(left_idx-pos))
  self[pos] = nil
  self[left_idx].right = right_idx
  self[right_idx].left = left_idx
end

local function init_item_rows(num_rows, row_width)
  local res = {}
  for i=1,num_rows do
    res[i] = ItemRow:new(row_width)
  end
  return res
end

local function maze_from_str(maze_str, height, width)
  assert(type(maze_str) == 'string', string.format("maze_str must be a string (got type '%s')", type(maze_str)))
  local item_rows = init_item_rows(height, width)
  local item_cols = init_item_rows(width, height)
  local maze = { height = height, width = width, item_rows=item_rows, item_cols = item_cols }
  local y = 1
  local last_wall_up = {}
  --local last_item_up = {}
  for line in (maze_str .. '\n'):gmatch('(.-)\r?\n') do
    --print(line)
    local last_wall_left = nil
    --local last_item_left = nil
    local x = 1
    local line_has_data = false
    for cell_data in line:gmatch('[#ISE%.]+') do
      line_has_data = true
      local cell = Cell:new {x=x, y=y}
      for object_char in cell_data:gmatch('.') do
        local object_type = ObjectType.from_char(object_char)
        cell:add_object(object_type)
      end

      if not maze[x] then
        maze[x] = {}
      end
      maze[x][y] = cell

      cell:add_neighbour_wall(last_wall_left, Direction.WEST)
      cell:add_neighbour_wall(last_wall_up[x], Direction.NORTH)

      if cell:is_item() then
        item_rows[y]:add_item(x)
        item_cols[x]:add_item(y)
      end

      if cell:is_start() then
        maze.start_cell = cell
      end
      if cell:is_end() then
        maze.end_cell = cell
      end

      if cell:is_wall() then
        for i=x-1,1,-1 do
          maze[i][y]:add_neighbour_wall(cell, Direction.EAST)
          if maze[i][y]:is_wall() then break end
        end
        for i=y-1,1,-1 do
          maze[x][i]:add_neighbour_wall(cell, Direction.SOUTH)
          if maze[x][i]:is_wall() then break end
        end
        last_wall_left = cell
        last_wall_up[x] = cell
      end
      x = x + 1
    end
    if line_has_data then
      y = y + 1
    end
  end
  assert(maze.start_cell, "no start cell found in the maze")
  assert(maze.end_cell, "no end cell found in the maze")
  return maze
end

local function move(x, y, dir)
  local d_x, d_y = Direction.dir_delta(dir)
  return x + d_x, y + d_y
end

function Maze:collect(x, y)
  local was_last_item = self[x][y]:count_items() == 1
  if was_last_item then
    self.item_rows[y]:remove_item(x)
    self.item_cols[x]:remove_item(y)
  end
  return self[x][y]:remove_item()
end

function Maze:drop(x, y)
  local was_first_item = self[x][y]:count_items() == 0
  if was_first_item then
    self.item_rows[y]:add_item(x)
    self.item_cols[x]:add_item(y)
  end
  self[x][y]:add_item()
end

function Maze:move_to_item(x, y, dir)
  -- TODO: simplify
  local wall_x, wall_y = self[x][y].neighbour_walls[dir].x, self[x][y].neighbour_walls[dir].y
  if dir == Direction.NORTH then
    local item_y = self.item_cols[x]:left(y)
    if wall_y > item_y then
      return x,wall_y+1,false,false
    end
    if item_y < 1 or item_y > self.height then
      error("maze is missing borders", 2)
    end
    return x,item_y,true,false
  elseif dir == Direction.EAST then
    local item_x = self.item_rows[y]:right(x)
    if wall_x < item_x then
      return wall_x-1,y,false,false
    end
    if item_x < 1 or item_x > self.width then
      error("maze is missing borders", 2)
    end
    return item_x,y,true,false
  elseif dir == Direction.SOUTH then
    local item_y = self.item_cols[x]:right(y)
    if wall_y < item_y then
      return x,wall_y-1,false,false
    end
    if item_y < 1 or item_y > self.height then
      error("maze is missing borders", 2)
    end
    return x,item_y,true,false
  elseif dir == Direction.WEST then
    local item_x = self.item_rows[y]:left(x)
    if wall_x > item_x then
      return wall_x+1,y,false,false
    end
    if item_x < 1 or item_x > self.width then
      error("maze is missing borders", 2)
    end
    return item_x,y,true,false
  else
    error("unknown direction " .. dir, 2)
  end
end

local function one_block_before(x, y, dir)
  return move(x, y, Direction.opposite_direction(dir))
end

function Maze:move_to_wall(x, y, dir)
  local wall = self[x][y].neighbour_walls[dir]
  if not wall then
    return nil,nil,nil
  end
  local ret_x, ret_y = one_block_before(wall.x, wall.y, dir)
  return ret_x,ret_y,true
end

local function normalize_delta(d_x, d_y)
  return d_x ~= 0 and d_x // math.abs(d_x) or 0,
         d_y ~= 0 and d_y // math.abs(d_y) or 0
end

local function reachable_from_pos(src_x, src_y, dst_x, dst_y, dir)
  local diff_x, diff_y = normalize_delta(dst_x - src_x, dst_y - src_y)
  local dir_x, dir_y = Direction.dir_delta(dir)
  return dir_x == diff_x and dir_y == diff_y
end

local function is_closer(src_x, src_y, a_x, a_y, b_x, b_y, dir)
  assert(reachable_from_pos(src_x, src_y, a_x, a_y, dir))
  assert(reachable_from_pos(src_x, src_y, b_x, b_y, dir))
  local d_ax, d_ay = normalize_delta(a_x-src_x,a_y-src_y)
  local d_bx, d_by = normalize_delta(b_x-src_x,b_y-src_y)
  return math.abs(d_ax) <= math.abs(d_bx) and math.abs(d_ay) <= math.abs(d_by)
end

function Maze:move_to_pos(src_x, src_y, dst_x, dst_y, dir)
  local wall_x, wall_y, success = self:move_to_wall(src_x, src_y, dir)
  if reachable_from_pos(src_x, src_y, dst_x, dst_y, dir)
    and (not success or is_closer(src_x, src_y, dst_x, dst_y, wall_x, wall_y, dir)) then
    return dst_x, dst_y, true
  end
  return wall_x, wall_y, false
end

function Maze:move_to_start(x, y, dir)
  return self:move_to_pos(x, y, self.start_cell.x, self.start_cell.y, dir)
end

function Maze:move_to_end(x, y, dir)
  return self:move_to_pos(x, y, self.end_cell.x, self.end_cell.y, dir)
end

function Maze:new(params)
  -- params: table with entries:
    -- `maze_str` describes the textual representation of the maze
    -- `width` -> maze width
    -- `height` -> maze height
  local o =  maze_from_str(params.maze_str, params.height, params.width)
  setmetatable(o, self)
  return o
end

return Maze
