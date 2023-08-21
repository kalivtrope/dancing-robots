local animation_duration = 0.5
local max_cells_per_column = 10
local real_size = SCREEN_HEIGHT / max_cells_per_column
local max_cells_per_row = SCREEN_WIDTH // real_size + 2
local max_items_per_cell = #(require("engine.enums").ItemCountToDrawable)
local texture_size = 64
local num_sprites = require("engine.enums").Drawable._len
local total_texture_width = texture_size * num_sprites
local min_notes_per_batch = 3
local max_pn = 2

return {
  animation_duration = animation_duration,
  max_cells_per_column = max_cells_per_column,
  real_size =  real_size,
  max_cells_per_row = max_cells_per_row,
  max_items_per_cell = max_items_per_cell,
  texture_size = texture_size,
  total_texture_width = total_texture_width,
  min_notes_per_batch = min_notes_per_batch,
  max_pn = max_pn,
}
