local _Direction = require("interpreter.enums").Direction

local Direction

Direction = {
  NORTHEAST = _Direction._NUM_DIRS() + 1,
  NORTHWEST = _Direction._NUM_DIRS() + 2,
  SOUTHWEST = _Direction._NUM_DIRS() + 3,
  SOUTHEAST = _Direction._NUM_DIRS() + 4,
  _NUM_DIRS_EXT = function() return _Direction._NUM_DIRS() + 4 end,
  combine = function(dir1, dir2)
    local d1_row, d1_col = Direction.dir_delta(dir1)
    local d2_row, d2_col = Direction.dir_delta(dir2)
    return d1_row + d2_row, d1_col + d2_col
  end,
  decompose = function(dir)
    local dir1, dir2
    if dir == Direction.NORTHEAST or dir == Direction.NORTHWEST then
      dir1 = _Direction.NORTH
    else
      dir1 = _Direction.SOUTH
    end
    if dir == Direction.NORTHWEST or dir == Direction.SOUTHWEST then
      dir2 = _Direction.WEST
    else
      dir2 = _Direction.EAST
    end
    return dir1, dir2
  end,
  is_diagonal = function(dir)
    return dir > _Direction._NUM_DIRS()
  end,
  dir_delta = function(dir)
    if dir <= _Direction._NUM_DIRS() then
      return _Direction.dir_delta(dir)
    end
    return Direction.combine(Direction.decompose(dir))
  end,
  step = function(row, col, dir)
    local d_row, d_col = Direction.dir_delta(dir)
    return row + d_row, col + d_col
  end
}
local D_mt = {
  __index = function(_, key) return _Direction[key] end,
}
setmetatable(Direction, D_mt)

local DirectionInv = {}

for k,v in pairs(Direction) do
  DirectionInv[v] = k
end
for k,v in pairs(DirectionInv) do
  Direction[k] = v
end

local function create_enum(t)
  local res = {}
  for k,v in ipairs(t) do
    res[v] = k
  end
  return res
end

local Drawable = create_enum{
  "empty_even",
  "empty_odd",
  "empty_robot",
  "start",
  "end",
  "item",
  "item2",
  "item3",
  "item4",
  "wall",
  "shadow_north",
  "shadow_east",
  "shadow_south",
  "shadow_west",
  "shadow_southwest",
  "shadow_northwest",
  "shadow_southeast",
  "shadow_northeast",
  "robot_north",
  "robot_east",
  "robot_south",
  "robot_west",
}


local ItemCountToDrawable = {
  Drawable.item,
  Drawable.item2,
  Drawable.item3,
  Drawable.item4,
}

local IC_mt = { __index = function(self, _) return self[#self] end}
setmetatable(ItemCountToDrawable, IC_mt)

local ShadowDirectionToDrawable = {
  [Direction.NORTH] = Drawable.shadow_north,
  [Direction.EAST] = Drawable.shadow_east,
  [Direction.SOUTH] = Drawable.shadow_south,
  [Direction.WEST] = Drawable.shadow_west,
  [Direction.NORTHEAST] = Drawable.shadow_northeast,
  [Direction.NORTHWEST] = Drawable.shadow_northwest,
  [Direction.SOUTHWEST] = Drawable.shadow_southwest,
  [Direction.SOUTHEAST] = Drawable.shadow_southeast,
}

local RobotDirectionToDrawable = {
  [Direction.NORTH] = Drawable.robot_north,
  [Direction.EAST] = Drawable.robot_east,
  [Direction.SOUTH] = Drawable.robot_south,
  [Direction.WEST] = Drawable.robot_west,
}


return {
  Drawable = Drawable,
  RobotDirectionToDrawable = RobotDirectionToDrawable,
  ShadowDirectionToDrawable = ShadowDirectionToDrawable,
  ItemCountToDrawable = ItemCountToDrawable,
  Direction = Direction,
}
