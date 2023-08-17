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
local cells_per_row
local cells_per_column
local Judge, maze, robot_state
local maze_data
local curr_frame = {}

-- contains the last drawn bounding box
local old_frame = {}
-- contains the bounding box we want to transition into
local new_frame = {}

-- Actor that keeps a timer for maintaining animations
local timer

local needs_refresh
local animation_in_progress


local function cell_data_to_drawable_array(data)
  if data.is_wall then
    return {[Drawable.wall] = true}
  end
  local out = {}
  out[data.is_even and Drawable.empty_even or Drawable.empty_odd] = true
  if data.is_start then
    out[Drawable.start] = true
  end
  if data.is_end then
    out[Drawable["end"]] = true
  end
  if data.is_item then
    out[ItemCountToDrawable[data.no_items]] = true
  end
  if data.is_robot then
    out[RobotDirectionToDrawable[data.robot_dir]] = true
  end
  return out
end

local function add_shadow_to_cell(out, dir)
  out[ShadowDirectionToDrawable[dir]] = true
end

local function cells_in_all_dirs(row, col)
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

local function has_wall(row, col)
  return maze[row] and maze[row][col] and maze[row][col]:is_wall()
end

local function should_be_shadowed(row, col, dir)
  -- assuming there's a wall in the given cell's direction already
  if not Direction.is_diagonal(dir) then return true end
  local dir1, dir2 = Direction.decompose(dir)
  local row1, col1 = Direction.step(row, col, dir1)
  local row2, col2 = Direction.step(row, col, dir2)
  return (not has_wall(row1, col1)) and (not has_wall(row2, col2))
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

local function prepare_maze_data()
  maze_data = {}
  for row=1,maze.height do
    maze_data[row] = maze_data[row] or {}
    for col=1,maze.width do
      local cell = maze[row][col]
      local is_wall = cell:is_wall()
      local is_start = cell:is_start()
      local is_end = cell:is_end()
      local is_item = cell:is_item()
      local no_items = cell:count_items()
      local is_robot = robot_state.row == row and robot_state.col == col
      local is_even = (row+col) % 2 == 0
      local robot_dir = robot_state.orientation
      local out_cell = cell_data_to_drawable_array({is_wall = is_wall,
      is_start = is_start,
      is_end = is_end,
      is_item = is_item,
      no_items = no_items,
      is_robot = is_robot,
      is_even = is_even,
      robot_dir = robot_dir})
      maze_data[row][col] = out_cell
      if not is_wall then
        for nb_cell,dir in cells_in_all_dirs(row, col) do
          if nb_cell:is_wall() and should_be_shadowed(row, col, dir) then
            add_shadow_to_cell(out_cell, dir)
          end
        end
      end
    end
  end
  maze_data.version = 0
end

local function begin_animate()
  if timer then
    timer:aux(0)
    animation_in_progress = true
    timer:decelerate(animation_duration):aux(1)
  end
end

local function refresh_frame_data()
  local animate = false
  if not old_frame.min_row
     or out_of_frame(robot_state.row, old_frame.min_row, old_frame.max_row) then
     if old_frame.min_row then
       animate = true
     end
     new_frame.min_row, new_frame.max_row = center_robot_pos(robot_state.row, max_cells_per_column, maze.height)
  end
  if not old_frame.min_col
     or out_of_frame(robot_state.col, old_frame.min_col, old_frame.max_col) then
    if old_frame.min_col then
      animate = true
    end
    new_frame.min_col, new_frame.max_col = center_robot_pos(robot_state.col, max_cells_per_row, maze.width)
  end
  if animate then
    begin_animate()
    return
  end
  for k,v in pairs(new_frame) do
    old_frame[k] = v
    curr_frame[k] = v
  end
end

local function transition(percentage)
  -- transition from old_frame to new_frame using simple linear interpolation
  for k,v in pairs(old_frame) do
    curr_frame[k] = lerp(percentage, v, new_frame[k])
  end
end

local function write_current_frame()
  --print("write called")
  if animation_in_progress then
    local aux = timer:getaux() -- and 1 -- uncomment this to turn off animations
    transition(aux)
    maze_data.version = maze_data.version + 1
    --print("newa:", maze_data.version)
    if aux == 1 then
      animation_in_progress = false
      for k,v in pairs(new_frame) do
        old_frame[k] = v
      end
    end
  else
    if needs_refresh then
      refresh_frame_data()
      maze_data.version = maze_data.version + 1
      --print("new:", maze_data.version)
      needs_refresh = false
    end
  end
end

return function(judge)
  return Def.ActorFrame{
  Name="JudgeWrapperClockwork",
  InitCommand=function(self)
    prepare_maze_data()
    animation_in_progress = false
    needs_refresh = true
    self:visible(false)
  end,
  OnCommand=function(self)
    cells_per_column=math.min(max_cells_per_column, judge.maze.height)
    cells_per_row=math.min(max_cells_per_row, judge.maze.width)
    MESSAGEMAN:Broadcast("DataBind", {curr_frame=curr_frame, cells_per_column=cells_per_column,
                                      cells_per_row=cells_per_row, maze_data=maze_data })
  end,
  Def.Quad{
    Name="Timer",
    InitCommand=function(self)
      self:visible(false)
      timer = self
      self:aux(0)
    end,
  },
  Def.Actor{
    Name="JudgeWrapper",
    InitCommand=function(self)
      Judge = judge
      maze = Judge.maze
      robot_state = Judge.robot_state
      self:visible(false):sleep(animation_duration):queuecommand("Tick")
    end,
    TickCommand=function(self)
      -- TODO: implement command queueing
      if Judge.judgment_received then return end
      local prev_row, prev_col, prev_dir = Judge.robot_state.row, Judge.robot_state.col, Judge.robot_state.orientation
      local prev_item_cnt = Judge.maze[prev_row][prev_col]:count_items()
      -- remove robot sprite
      maze_data[prev_row][prev_col][RobotDirectionToDrawable[prev_dir]] = nil
      -- remove item sprite
      if ItemCountToDrawable[prev_item_cnt] then
        maze_data[prev_row][prev_col][ItemCountToDrawable[prev_item_cnt]] = nil
      end

      Judge:judge_next_command()

      local curr_row, curr_col, curr_dir = Judge.robot_state.row, Judge.robot_state.col, Judge.robot_state.orientation
      local curr_item_cnt = Judge.maze[curr_row][curr_col]:count_items()
      if curr_row ~= prev_row or curr_col ~= prev_col then
        local item_cnt = Judge.maze[prev_row][prev_col]:count_items()
        if ItemCountToDrawable[item_cnt] then
          maze_data[prev_row][prev_col][ItemCountToDrawable[item_cnt]] = true
        end
      end
      maze_data[curr_row][curr_col][RobotDirectionToDrawable[curr_dir]] = true
      if ItemCountToDrawable[curr_item_cnt] then
        maze_data[curr_row][curr_col][ItemCountToDrawable[curr_item_cnt]] = true
      end
      needs_refresh = true
      self:sleep(animation_duration):queuecommand("Tick")
    end,

    CurrentFrameCommand=function()
      write_current_frame()
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
