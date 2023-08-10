local Enums = require("engine.enums")
local Drawable = Enums.Drawable
local ItemCountToDrawable = Enums.ItemCountToDrawable
local RobotDirectionToDrawable = Enums.RobotDirectionToDrawable
local ShadowDirectionToDrawable = Enums.ShadowDirectionToDrawable

local Constants = require("engine.constants")
local Direction = require("engine.enums").Direction
local max_cells_per_column = Constants.max_cells_per_column
local max_cells_per_row = Constants.max_cells_per_row
local animation_duration = Constants.animation_duration
local Judge

-- contains the last drawn bounding box
local old_frame = {}
-- contains the bounding box we want to transition into
local new_frame = {}

-- Actor that keeps a timer for maintaining animations
local timer

local needs_redraw = false


local function cell_data_to_drawable_array(data)
  if data.is_wall then
    return {Drawable.wall}
  end
  local out = {}
  out[1] = --[[data.is_robot and Drawable.empty_robot or--]](data.is_even and Drawable.empty_even or Drawable.empty_odd)
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

local function out_of_frame(curr_pos, min, max)
  return curr_pos < min+(max-min)/3 or curr_pos > min+(max-min)*2/3
end

local function center_robot_pos(curr_pos, dimen_size, maze_size)
  -- returns the minimum and maximum position
  -- of the frame's bounding box in the specified direction
  -- (the direction being either horizontal or vertical, but that's not important for this function's logic)
  -- such that the robot is placed in the center of the frame
  -- the frame is `dimen_size` cells tall/wide, the maze is `maze_size` cells tall/wide
  if maze_size <= dimen_size then
    -- if the maze is too small, make the frame focus on the whole thing
    return 1, maze_size
  end
  return curr_pos - dimen_size // 2,
         curr_pos + dimen_size // 2 - (dimen_size % 2 == 0 and 1 or 0)
end

local function draw_frame(frame)
  -- draws the maze at the frame defined by the bounding box frame.{min,max}_{row,col}
  local out = {}
  local maze = Judge.maze
  local robot_state = Judge.robot_state
  for row=math.floor(frame.min_row),math.ceil(frame.max_row) do
    if maze[row] then
      local row_pos = row - frame.min_row + 1
      out[row_pos] = out[row_pos] or {}
      for col=math.floor(frame.min_col),math.ceil(frame.max_col) do
        local col_pos = col - frame.min_col + 1
        if maze[row][col] then
          local cell = maze[row][col]
          local is_wall = cell:is_wall()
          local is_start = cell:is_start()
          local is_end = cell:is_end()
          local is_item = cell:is_item()
          local no_items = cell:count_items()
          local is_robot = robot_state.row == row and robot_state.col == col
          local is_even = (row+col) % 2 == 0
          local robot_dir = robot_state.orientation
          out[row_pos][col_pos] = cell_data_to_drawable_array({is_wall = is_wall,
          is_start = is_start,
          is_end = is_end,
          is_item = is_item,
          no_items = no_items,
          is_robot = is_robot,
          is_even = is_even,
          robot_dir = robot_dir})
          if not is_wall then
            for nb_cell,dir in cells_in_all_dirs(maze, row, col) do
              if nb_cell:is_wall() then
                if should_be_shadowed(maze, row, col, dir)
                  and in_bounds(nb_cell.row, math.floor(frame.min_row), math.ceil(frame.max_row))
                  and in_bounds(nb_cell.col, math.floor(frame.min_col), math.ceil(frame.max_col)) then
                  add_shadow_to_cell(out, row_pos, col_pos, dir)
                end
              end
            end
          end
        end
      end
    end
  end
  return out
end


local function draw()
  local maze = Judge.maze
  local robot_state = Judge.robot_state
  local animate = false
  if not old_frame.min_row or out_of_frame(robot_state.row, old_frame.min_row, old_frame.max_row) then
    if old_frame.min_row then animate = true end
    new_frame.min_row, new_frame.max_row = center_robot_pos(robot_state.row, max_cells_per_column, maze.height)
  end
  if not old_frame.min_col or out_of_frame(robot_state.col, old_frame.min_col, old_frame.max_col) then
    if old_frame.min_col then animate = true end
    new_frame.min_col, new_frame.max_col = center_robot_pos(robot_state.col, max_cells_per_row, maze.width)
  end
  if animate then
    timer:queuecommand("BeginAnimate")
    --[[
    print("dold_frame", old_frame.min_row, old_frame.max_row, old_frame.min_col, old_frame.max_col)
    print("dnew_frame", new_frame.min_row, new_frame.max_row, new_frame.min_col, new_frame.max_col)
    --]]
    return
  end
  for k,v in pairs(new_frame) do old_frame[k] = v end
  local out = draw_frame(old_frame)
  MESSAGEMAN:Broadcast("CellUpdate", { cell_data = out, cells_per_row=math.min(max_cells_per_row, maze.width),
                                       cells_per_column=math.min(max_cells_per_column, maze.height) })
end

local function transition(percentage)
  -- transition from old_frame to new_frame using simple linear interpolation
  local frame = {}
  --[[
  print(percentage)
  print("old_frame", old_frame.min_row, old_frame.max_row, old_frame.min_col, old_frame.max_col)
  print("new_frame", new_frame.min_row, new_frame.max_row, new_frame.min_col, new_frame.max_col)
  --]]
  for k,v in pairs(old_frame) do
    frame[k] = lerp(percentage, v, new_frame[k])
  end
  local out = draw_frame(frame)
  local maze = Judge.maze
  MESSAGEMAN:Broadcast("CellUpdate", { cell_data = out, cells_per_row=math.min(max_cells_per_row, maze.width),
                                       cells_per_column=math.min(max_cells_per_column, maze.height) })
end

local animation_in_progress = false

local function draw_function(_)
  if animation_in_progress then
    local aux = timer:getaux()
    transition(aux)
    if aux == 1 then
      animation_in_progress = false
      for k,v in pairs(new_frame) do old_frame[k] = v end
    end
  else
    if needs_redraw then
      draw()
      needs_redraw = false
    end
  end
end

return function(judge)
  return Def.ActorFrame{
  InitCommand=function(self)
    self:visible(true)
    self:SetDrawFunction(draw_function)
  end,
  Def.Quad{
    Name="Timer",
    InitCommand=function(self)
      self:visible(false)
      timer = self
      self:aux(0)
    end,
    BeginAnimateCommand=function(self)
      self:aux(0)
      animation_in_progress = true
      self:linear(animation_duration):aux(1)
    end,
  },
  Def.Actor{
    Name="JudgeWrapper",
    InitCommand=function(self) Judge = judge end,
    OnCommand=function(self)
      self:visible(false)
      draw()
      self:sleep(0.25):queuecommand("Tick")
    end,
    TickCommand=function(self)
      if Judge.judgment_received then return end -- TODO: implement command queueing
        Judge:judge_next_command()
        needs_redraw = true
        self:sleep(0.25):queuecommand("Tick")
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
}
end
