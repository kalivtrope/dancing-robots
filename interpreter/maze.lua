local Cell = require("cell")
local enums = require("enums")
local utils = require("utils")
local FenwickTree = require("fenwick-tree")
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
    print(line)
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
