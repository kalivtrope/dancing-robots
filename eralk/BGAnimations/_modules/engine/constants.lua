local animation_duration = 0.25
local max_cells_per_column = 10
local real_size = SCREEN_HEIGHT / max_cells_per_column
local max_cells_per_row = SCREEN_WIDTH // real_size + 2
local max_items_per_cell = #(require("engine.enums").ItemCountToDrawable)

return {
  --max_maze_width = max_maze_width,
  animation_duration = animation_duration,
  max_cells_per_column = max_cells_per_column,
  real_size =  real_size,
  max_cells_per_row = max_cells_per_row,
  max_items_per_cell = max_items_per_cell,
}
