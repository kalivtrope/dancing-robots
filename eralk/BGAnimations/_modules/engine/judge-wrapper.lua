local Enums = require("engine.enums")
local Drawable = Enums.Drawable
local ItemCountToDrawable = Enums.ItemCountToDrawable
local RobotDirectionToDrawable = Enums.RobotDirectionToDrawable
local ShadowDirectionToDrawable = Enums.ShadowDirectionToDrawable

local Constants = require("engine.constants")
local Direction = require("engine.enums").Direction
local max_cells_per_column, max_cells_per_row = Constants.max_cells_per_column, Constants.max_cells_per_row

local function cell_data_to_drawable_array(data)
  if data.is_wall then
    return {Drawable.wall}
  end
  local out = {}
  out[1] = data.is_robot and Drawable.empty_robot or (data.is_even and Drawable.empty_even or Drawable.empty_odd)
  if data.is_start then
    out[#out+1] = Drawable.start
  end
  if data.is_end then
    out[#out+1] = Drawable["end"]
  end
  if data.is_item then
    out[#out+1] = ItemCountToDrawable[data.no_items]
  end
  if data.is_robot then
    out[#out+1] = RobotDirectionToDrawable[data.robot_dir]
  end
  return out
end

local function add_shadow_to_cell(out, row, col, dir)
  out[row] = out[row] or {}
  out[row][col] = out[row][col] or {}
  out[row][col][#out[row][col]+1] = ShadowDirectionToDrawable[dir]
end

local function cells_in_all_dirs(maze, row, col)
  local dir_idx = 0
  return function()
    dir_idx = dir_idx+1
    local dir = Direction[Direction[dir_idx]]
    local cell = nil
    while true do
      if not dir then break end
      local _row,_col = Direction.step(row, col, dir)

      local nb_cell = (maze[_row] or {})[_col]
      if nb_cell then cell = nb_cell break end

      dir_idx = dir_idx+1
      dir = Direction[Direction[dir_idx]]
    end
    return cell, dir
  end
end

local function has_wall(maze, row, col)
  return maze[row] and maze[row][col] and maze[row][col]:is_wall()
end

local function should_be_shadowed(maze, row, col, dir)
  -- assuming there's a wall in the given cell's direction already
  if not Direction.is_diagonal(dir) then return true end
  local dir1, dir2 = Direction.decompose(dir)
  local row1, col1 = Direction.step(row, col, dir1)
  local row2, col2 = Direction.step(row, col, dir2)
  return (not has_wall(maze, row1, col1)) and (not has_wall(maze, row2, col2))
end

local function in_bounds(val, min, max)
  return val >= min and val <= max
end

local function draw(judge)
  local out = {}
  local maze = judge.maze
  local robot_state = judge.robot_state
  -- we make sure to always return a (max_cells_per_column)x(max_cells_per_row) matrix,
  -- unless the original grid itself is smaller than that.
  local min_row = ((robot_state.row-1) // max_cells_per_column) * max_cells_per_column + 1
  local max_row = math.min(maze.height, min_row - 1 + max_cells_per_column)
  if max_row - min_row + 1 < max_cells_per_column and maze.height >= max_cells_per_column then
    min_row = max_row - max_cells_per_column + 1
  end
  local min_col = ((robot_state.col-1) // max_cells_per_row) * max_cells_per_row + 1
  local max_col = math.min(maze.width, min_col - 1 + max_cells_per_row)
  if max_col - min_col + 1 < max_cells_per_row and maze.width >=  max_cells_per_row then
    min_col = max_col - max_cells_per_row + 1
  end
  for row=1,max_row-min_row+1 do
    out[row] = out[row] or {}
    for col=1,max_col-min_col+1 do
      local real_row = row+min_row-1
      local real_col = col+min_col-1
      local cell = maze[real_row][real_col]
      local is_wall = cell:is_wall()
      local is_start = cell:is_start()
      local is_end = cell:is_end()
      local is_item = cell:is_item()
      local no_items = cell:count_items()
      local is_robot = robot_state.row == real_row and robot_state.col == real_col
      local is_even = (real_row+real_col) % 2 == 0
      local robot_dir = robot_state.orientation
      out[row][col] = cell_data_to_drawable_array({is_wall = is_wall,
                                                   is_start = is_start,
                                                   is_end = is_end,
                                                   is_item = is_item,
                                                   no_items = no_items,
                                                   is_robot = is_robot,
                                                   is_even = is_even,
                                                   robot_dir = robot_dir})
      if not is_wall then
        for nb_cell,dir in cells_in_all_dirs(maze, real_row, real_col) do
          if nb_cell:is_wall() then
            if should_be_shadowed(maze, real_row, real_col, dir)
              and in_bounds(nb_cell.row, min_row, max_row)
              and in_bounds(nb_cell.col, min_col, max_col) then
                add_shadow_to_cell(out, row, col, dir)
            end
          end
        end
      end
    end
  end
  MESSAGEMAN:Broadcast("CellUpdate", { cell_data = out })
end

return function(judge)
  return Def.Actor{
    Name="Judge",
    OnCommand=function(self)
      self:visible(false)
      draw(judge)
    end,
    ExecuteInQueueCommand=function(self)
      --for i=1,200000000 do

      --end
      --[[
      instructionPointer = instructionPointer + 1
      Debug.logMsg(GetTimeSinceStart(), instructionPointer)
      Debug.screenMsg("NEXT", instructionPointer)
      --]]
    end,
    ExecuteNextMessageCommand=function(self, params)
      -- TODO: prolly just roll a die here and enqueue a command
      --[[
      Debug.logMsg(GetTimeSinceStart(), "registered broadcast")
      self:queuecommand("ExecuteInQueue")
      Debug.logMsg(GetTimeSinceStart(), "finished broadcast")
      --]]
      --local certainty = params.certainty
      --local id = params.id
      --Debug.screenMsg("NEXT", certainty, id)
    end,
  }
end
