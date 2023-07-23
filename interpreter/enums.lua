local ObjectChar

local ObjectType = {
  EMPTY = 1,
  START = 2,
  END = 3,
  WALL = 4,
  ITEM = 5,
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

return {
  ObjectType = ObjectType,
  ObjectChar = ObjectChar,
  ObjectCharInv = ObjectCharInv,
  Direction = {
    NORTH = 1,
    EAST = 2,
    SOUTH = 3,
    WEST = 4,
  },
  GameType = {
    MATRIX = 1,
    MAZE = 2,
    SORT = 3,
  },
  GameResult = {
    NONE = 1,
    WIN = 2,
    LOSE = 3,
  },
  Tokens = {
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
}
