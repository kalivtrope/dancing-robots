local enums = require("interpreter.enums")
local utils = require("interpreter.utils")
local assert_bounds = utils.assert_bounds
local ObjectType,ObjectCharInv = enums.ObjectType, enums.ObjectCharInv

local Cell = {
  row = -1,
  col = -1,
  object_counts = nil,
  neighbour_walls = nil,
}

Cell.__index = Cell

Cell.stringify = function(self,uniform_print)
  if not uniform_print then
    return self:__tostring()
  end
  local min_val = ObjectType._NUM_OBJS
  for k,v in pairs(self.object_counts) do
    if v > 0 and k < min_val then
      min_val = k
    end
  end
  return ObjectCharInv[min_val]
end
Cell.__tostring = function(self)
  local res = ""
  for k,v in pairs(self.object_counts) do
    if v > 0 then
      res = res .. string.rep(ObjectCharInv[k], v)
    end
  end
  if self:is_empty() then
    res = "."
  end
  return res
end

function Cell:new(o)
  o = o or {}
  setmetatable(o, self)
  o.object_counts = o.object_counts or {}
  o.neighbour_walls = o.neighbour_walls or {}
  assert_bounds(o.row, "cell.row", 1)
  assert_bounds(o.col, "cell.col", 1)
  return o
end

function Cell:add_item()
    assert(not self:is_wall(), string.format("cannot place item into wall (%d,%d)", self.row, self.col))
    self.object_counts[ObjectType.ITEM] = (self.object_counts[ObjectType.ITEM] or 0) + 1
end

function Cell:add_start()
    assert(not self:is_wall(), string.format("cannot place start/end into wall at pos (%d,%d)", self.row, self.col))
    self.object_counts[ObjectType.START] = 1
end

function Cell:add_end()
    assert(not self:is_wall(), string.format("cannot place end into wall at pos (%d,%d)", self.row, self.col))
    self.object_counts[ObjectType.END] = 1
end

function Cell:add_wall()
    assert(not self:is_non_wall(), string.format("cannot place wall at pos (%d,%d)", self.row, self.col))
    self.object_counts[ObjectType.WALL] = 1
end

function Cell:add_object(o)
  if o == ObjectType.EMPTY then
    return
  elseif o == ObjectType.START then
    self:add_start()
  elseif o == ObjectType.END then
    self:add_end()
  elseif o == ObjectType.WALL then
    self:add_wall()
  elseif o == ObjectType.ITEM then
    self:add_item()
  end
end

function Cell:remove_wall()
  if not self:is_wall() then
    return false
  end
  self.object_counts[ObjectType.WALL] = nil
  return true
end

function Cell:remove_item()
  if not self:is_item() then
    return false
  end
  self.object_counts[ObjectType.ITEM] = self.object_counts[ObjectType.ITEM] - 1
  return true
end

function Cell:add_neighbour_wall(neighbour, dir)
  self.neighbour_walls[dir] = neighbour
end

function Cell:get_count(oc_type)
  return self.object_counts[ObjectType[oc_type]]
end

function Cell:is_empty()
  return not (self:is_start() or self:is_end() or self:is_wall() or self:is_item())
end

function Cell:is_wall()
  return (self:get_count("WALL") or 0) > 0
end

function Cell:count_items()
  return self:get_count("ITEM") or 0
end

function Cell:is_item()
  return (self:get_count("ITEM") or 0) > 0
end

function Cell:is_non_wall()
  return self:get_count("START") or self:get_count("END") or self:get_count("ITEM")
end

function Cell:is_start()
  return (self:get_count("START") or 0) > 0
end

function Cell:is_end()
  return (self:get_count("END") or 0) > 0
end

return Cell
