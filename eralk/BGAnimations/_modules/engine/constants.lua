local max_maze_width = 1  -- a float in range (0,1] denoting the max percentage of width taken up by the maze
local max_cells_per_column = 10
local real_size = SCREEN_HEIGHT / max_cells_per_column
local max_cells_per_row = SCREEN_WIDTH * max_maze_width // real_size
local max_items_per_cell = #(require("engine.enums").ItemCountToDrawable)

return {
  --max_maze_width = max_maze_width,
  max_cells_per_column = max_cells_per_column,
  real_size =  real_size,
  max_cells_per_row = max_cells_per_row,
  max_items_per_cell = max_items_per_cell,
}
