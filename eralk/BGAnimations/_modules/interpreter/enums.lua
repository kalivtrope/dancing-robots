local ObjectChar

local ObjectType = {
  END = 1,
  START = 2,
  ITEM = 3,
  WALL = 4,
  EMPTY = 5,
  _NUM_OBJS = 5,
  from_char = function(c)
    if not ObjectChar[c] then
      error(string.format("unknown object type '%s'", c), 2)
    end
    return ObjectChar[c]
  end
}

ObjectChar = {
  ['.'] = ObjectType.EMPTY,
  ['S'] = ObjectType.START,
  ['E'] = ObjectType.END,
  ['#'] = ObjectType.WALL,
  ['I'] = ObjectType.ITEM,
}

local ObjectCharInv = {}
for k,v in pairs(ObjectChar) do
  ObjectCharInv[v] = k
end

local Direction

Direction = {
  NORTH = 1,
  EAST = 2,
  SOUTH = 3,
  WEST = 4,
  _NUM_DIRS = function() return 4 end,
  opposite_direction = function(dir)
    return (dir + 1) % 4 + 1
  end,
  dir_delta = function(dir)
    local row, col = -1,0 -- north delta
    for _=2,dir do
      row,col = col,-row
    end
    return row,col
  end,
  step = function(row, col, dir)
    local d_row, d_col = Direction.dir_delta(dir)
    return row + d_row, col + d_col
  end,
}

local DirectionInv = {}

for k,v in pairs(Direction) do
  DirectionInv[v] = k
end
for k,v in pairs(DirectionInv) do
  Direction[k] = v
end

local Tokens = {
  TURNLEFT = "TURN_LEFT",
  TURNRIGHT = "TURN_RIGHT",
  COLLECT = "COLLECT",
  DROP = "DROP",
  MOVETOITEM = "MOVE_TO_ITEM",
  MOVETOWALL = "MOVE_TO_WALL",
  MOVETOSTART = "MOVE_TO_START",
  MOVETOEND = "MOVE_TO_END",
  NOP = "NOP",
}

local curr_idx = 1
for _,v in pairs(Tokens) do
  Tokens[curr_idx] = v
  curr_idx = curr_idx + 1
end
Tokens._len = curr_idx - 1

return {
  ObjectType = ObjectType,
  ObjectChar = ObjectChar,
  ObjectCharInv = ObjectCharInv,
  Direction = Direction,
  GameType = {
    MATRIX = 'matrix',
    --MAZE = 'maze',
    --SORT = 'sort',
    SORTP = 'sortp',
    SPIRAL = 'spiral',
    COMB = 'comb',
  },
  GameResult = {
    NONE = 1,
    WIN = 2,
    LOSE = 3,
  },
  Tokens = Tokens,
}
