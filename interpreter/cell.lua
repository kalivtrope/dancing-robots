local enums = require("enums")
local utils = require("utils")
local assert_bounds = utils.assert_bounds
local ObjectType,ObjectCharInv = enums.ObjectType, enums.ObjectCharInv

local Cell = {
  x = -1,
  y = -1,
  object_counts = nil,
  neighbour_walls = nil,
}

Cell.__index = Cell
Cell.__tostring = function(self)
  local res = ""
  for k in pairs(self.object_counts) do
    res = res .. ObjectCharInv[k]
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
  assert_bounds(o.x, "cell.x", 1)
  assert_bounds(o.y, "cell.y", 1)
  return o
end

function Cell:add_object(o)
  if o == ObjectType.EMPTY then
    return
  elseif o == ObjectType.START or o == ObjectType.END then
    assert(not self:is_wall(), string.format("cannot place start/end at wall at pos (%d,%d)", self.x, self.y))
    self.object_counts[o] = 1
  elseif o == ObjectType.WALL then
    assert(not self:is_non_wall(), string.format("cannot place wall at pos (%d,%d)", self.x, self.y))
    self.object_counts[o] = 1
  elseif o == ObjectType.ITEM then
    assert(not self:is_wall(), string.format("cannot place item at wall (%d,%d)", self.x, self.y))
    self.object_counts[o] = (self.object_counts[o] or 0) + 1
  end
end

function Cell:add_neighbour_wall(neighbour, dir)
  self.neighbour_walls[dir] = neighbour
end

function Cell:get_count(oc_type)
  return self.object_counts[ObjectType[oc_type]]
end

function Cell:is_empty()
  return not (self:get_count("START") or self:get_count("END") or self:get_count("WALL") or self:get_count("ITEM"))
end

function Cell:is_wall()
  return (self:get_count("WALL") or 0) > 0
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
