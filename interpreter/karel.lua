local CellType = {
  EMPTY = 1,
  START = 2,
  END = 3,
  WALL = 4,
  ITEM = 5,
}

local CellChar = {
  ['.'] = CellType.EMPTY,
  ['S'] = CellType.START,
  ['E'] = CellType.END,
  ['#'] = CellType.WALL,
  ['I'] = CellType.ITEM,
}

local Direction = {
  NORTH = 1,
  EAST = 2,
  SOUTH = 3,
  WEST = 4,
}

local Cell = {
  x = -1,
  y = -1,
  type_counts = {},
  neighbours = {
    [Direction.NORTH] = nil,
    [Direction.EAST] = nil,
    [Direction.SOUTH] = nil,
    [Direction.WEST] = nil,
  },
}

local Maze = {
  width = -1,
  height = -1,
}

local GameType = {
  MATRIX = 1,
  MAZE = 2,
  SORT = 3,
}

local GameResult = {
  NONE = 1,
  WIN = 2,
  LOSE = 3,
}

local Game = {
  maze = nil,
  over = false,
  result = {type = GameResult.NONE, message = ""},
  type = GameType.NONE,
  items_collected = 0,
  x = -1,
  y = -1,
}

local function cell_type_from_char(c)
  if not CellChar[c] then
    error(string.format("unknown cell type '%s'", c))
  end
  return CellChar[c]
end

function Cell:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  assert(o.x > 0 and o.y > 0, "attempt to create an unitialized cell") -- prevent creating invalid cells
  return o
end

local function parse_maze(maze_str)
  local maze = {}
  local y = 0
  for line in (maze_str .. '\n'):gmatch('(.-)\r?\n') do
    local x = 0
    local line_has_data = false
    for cell_data in line:gmatch('[#ISE%.]+') do
      line_has_data = true
      local cell = Cell:new({x=x, y=y})
      local cell_is_empty = true
      for cell_char in cell_data:gmatch('.') do
        local cell_type = cell_type_from_char(cell_char)
        cell.type_counts[cell_type] = (cell.type_counts[cell_type] or 0) + 1
        if cell_type ~= CellType.EMPTY then
          cell_is_empty = false
        end
      end
      if not cell_is_empty then
        if not maze[x] then
          maze[x] = {}
        end
        maze[x][y] = cell
      end
      --io.stdout:write(string.format("x: %d, y: %d, data: %s\n", x,y,cell_data))
      x = x + 1
    end
    if line_has_data then
      y = y + 1
    end
  end
  return maze
end

function Maze:new(params)
  -- params: table with entries:
    -- `maze_str` describes the textual representation of the maze
    -- `width` -> maze width
    -- `height` -> maze height
  local o =  parse_maze(params.maze_str)
  setmetatable(o, self)
  self.__index = self
  o.height, o.width = params.height, params.width
  return o
end

function Game:new(params)
  -- params: table with entries:
    -- 'type_str' describes the according GameType
    -- 'maze_str'
    -- `width`
    -- `height`  parameters to Maze:new()
  local game_type_key = string.upper(params.type_str)
  assert(GameType[game_type_key], string.format("unknown game type '%s'", params.type_str))
  local o = { type = GameType[game_type_key]}
  setmetatable(o, self)
  self.__index = self
  o.maze = Maze:new(params)

  return o
end


function Cell:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end


local filename = ... or arg[1]
file = filename and assert(io.open(filename, "r")) or io.stdin

game_type_str = file:read("*line")
game_height, game_width = file:read("*n", "*n")
game_maze_str = file:read("*all")
local curr_game = Game:new({height = game_height, width = game_width, type_str = game_type_str, maze_str = game_maze_str})
