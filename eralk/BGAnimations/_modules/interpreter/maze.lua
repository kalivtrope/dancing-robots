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
  for row=1,self.height do
    for col=1,self.width do
      res = res .. tostring(self[row][col]) .. " "
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

local function next_item_in_dir(self, row, col, dir)
  if dir == Direction.NORTH then
    return self.item_cols[col]:left(row), col
  elseif dir == Direction.EAST then
    return row, self.item_rows[row]:right(col)
  elseif dir == Direction.SOUTH then
    return self.item_cols[col]:right(row), col
  elseif dir == Direction.WEST then
    return row,self.item_rows[row]:left(col)
  else
    error("unknown direction " .. tostring(dir), 2)
  end

end

local function maze_from_str(maze_str, height, width)
  assert(type(maze_str) == 'string', string.format("maze_str must be a string (got type '%s')", type(maze_str)))
  local item_rows = init_item_rows(height, width)
  local item_cols = init_item_rows(width, height)
  local maze = { height = height, width = width, item_rows=item_rows, item_cols = item_cols }
  local row = 1
  local last_wall_up = {}
  --local last_item_up = {}
  for line in (maze_str .. '\n'):gmatch('(.-)\r?\n') do
    --print(line)
    local last_wall_left = nil
    --local last_item_left = nil
    local col = 1
    local line_has_data = false
    for cell_data in line:gmatch('[#ISE%.]+') do
      line_has_data = true
      local cell = Cell:new {row=row, col=col}
      for object_char in cell_data:gmatch('.') do
        local object_type = ObjectType.from_char(object_char)
        cell:add_object(object_type)
      end

      if not maze[row] then
        maze[row] = {}
      end
      maze[row][col] = cell

      cell:add_neighbour_wall(last_wall_left, Direction.WEST)
      cell:add_neighbour_wall(last_wall_up[col], Direction.NORTH)

      if cell:is_item() then
        item_rows[row]:add_item(col)
        item_cols[col]:add_item(row)
      end

      if cell:is_start() then
        maze.start_cell = cell
      end
      if cell:is_end() then
        maze.end_cell = cell
      end

      if cell:is_wall() then
        for i=col-1,1,-1 do
          maze[row][i]:add_neighbour_wall(cell, Direction.EAST)
          if maze[row][i]:is_wall() then break end
        end
        for i=row-1,1,-1 do
          maze[i][col]:add_neighbour_wall(cell, Direction.SOUTH)
          if maze[i][col]:is_wall() then break end
        end
        last_wall_left = cell
        last_wall_up[col] = cell
      end
      col = col + 1
    end
    if line_has_data then
      row = row + 1
    end
  end
  assert(maze.start_cell, "no start cell found in the maze")
  assert(maze.end_cell, "no end cell found in the maze")
  return maze
end

local function move(row, col, dir)
  local d_row, d_col = Direction.dir_delta(dir)
  return row + d_row, col + d_col
end

function Maze:collect(row, col)
  local was_last_item = self[row][col]:count_items() == 1
  if was_last_item then
    self.item_rows[row]:remove_item(col)
    self.item_cols[col]:remove_item(row)
  end
  return self[row][col]:remove_item()
end

function Maze:drop(row, col)
  local was_first_item = self[row][col]:count_items() == 0
  if was_first_item then
    self.item_rows[row]:add_item(col)
    self.item_cols[col]:add_item(row)
  end
  self[row][col]:add_item()
end

local function one_block_before(row, col, dir)
  return move(row, col, Direction.opposite_direction(dir))
end

local function normalize_delta(d_row,d_col)
  return d_row ~= 0 and d_row // math.abs(d_row) or 0,
         d_col ~= 0 and d_col // math.abs(d_col) or 0
end

local function reachable_from_pos(src_row, src_col, dst_row, dst_col, dir)
  local diff_row, diff_col = normalize_delta(dst_row - src_row, dst_col - src_col)
  local dir_row, dir_col = Direction.dir_delta(dir)
  return (src_row == dst_row and src_col == dst_col) or (dir_row == diff_row and dir_col == diff_col)
end



local function is_closer(src_row, src_col, a_row, a_col, b_row, b_col, dir)
  -- returns true if (a_row,a_col) is closer or at the same distance from (src_row,src_col) than (b_row,b_col)
  assert(reachable_from_pos(src_row, src_col, a_row, a_col, dir), string.format("%s %s is not reachable from %s %s in direction %s", a_row, a_col, src_row, src_col, dir))
  assert(reachable_from_pos(src_row, src_col, b_row, b_col, dir), string.format("%s %s is not reachable from %s %s in direction %s", b_row, b_col, src_row, src_col, dir))
  local d_arow, d_acol = a_row-src_row,a_col-src_col
  local d_brow, d_bcol = b_row-src_row,b_col-src_col
  return math.abs(d_arow) <= math.abs(d_brow) and math.abs(d_acol) <= math.abs(d_bcol)
end

function Maze:move_to_item(row, col, dir)
  local wall_row, wall_col = one_block_before(self[row][col].neighbour_walls[dir].row,
                                              self[row][col].neighbour_walls[dir].col, dir)
  local item_row, item_col = next_item_in_dir(self, row, col, dir)
  --print('wall', wall_row, wall_col, 'item', item_row, item_col)
  if wall_row < 1 or wall_row > self.height or wall_col < 1 or wall_col > self.width then
    error("maze is missing borders", 2)
  end
  if is_closer(row,col,item_row,item_col,wall_row,wall_col,dir) then
    --print("item is closer :)")
    return item_row,item_col,true
  else
    return wall_row,wall_col,false
  end
end


function Maze:move_to_wall(row, col, dir)
  local wall = self[row][col].neighbour_walls[dir]
  if not wall then
    return nil,nil,nil
  end
  local ret_row, ret_col = one_block_before(wall.row, wall.col, dir)
  return ret_row,ret_col,true
end


function Maze:move_to_pos(src_row, src_col, dst_row, dst_col, dir)
  local wall_row, wall_col, success = self:move_to_wall(src_row, src_col, dir)
  if reachable_from_pos(src_row, src_col, dst_row, dst_col, dir)
    and (not success or is_closer(src_row, src_col, dst_row, dst_col, wall_row, wall_col, dir)) then
    return dst_row, dst_col, true
  end
  return wall_row, wall_col, false
end

function Maze:move_to_start(row, col, dir)
  return self:move_to_pos(row, col, self.start_cell.row, self.start_cell.col, dir)
end

function Maze:move_to_end(row, col, dir)
  return self:move_to_pos(row, col, self.end_cell.row, self.end_cell.col, dir)
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
