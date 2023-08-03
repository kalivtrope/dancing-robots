local utils = require("interpreter.utils")
local assert_bounds = utils.assert_bounds

local FenwickTree = {}
FenwickTree.__index = FenwickTree

function FenwickTree:new(n, vals)
  -- construct a fenwick tree representing a fixed-sized integer sequence
  local ft = { bit = {}, len = n+1 }
  setmetatable(ft, self)
  if vals then
    for i=1,ft.len do
      ft.bit[i] = (ft.bit[i] or 0) + (vals[i] or 0)
      local r = i | (i+1)
      if r <= ft.len then
        ft.bit[r] = (ft.bit[r] or 0) + ft.bit[i]
      end
    end
  end
  return ft
end

function FenwickTree:sum(last_pos)
  assert_bounds(last_pos, "last_pos", 1, self.len)
  -- return sum of elements at positions from 1 to last_pos in the underlying array
  local res = 0
  while last_pos > 0 do
    res = res + (self.bit[last_pos] or 0)
    last_pos = (last_pos & (last_pos+1)) - 1
  end
  return res
end

function FenwickTree:add(pos, delta)
  assert_bounds(pos, "pos", 1, self.len)
  while pos <= self.len do
    self.bit[pos] = (self.bit[pos] or 0) + delta
    pos = pos | (pos + 1)
  end
end


return FenwickTree
