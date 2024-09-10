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

local gamedata_path = THEME:GetPathB("", "_gamedata")
local input_path = gamedata_path .. "/Inputs"
local output_path = gamedata_path .. "/Outputs"
local team_name_key = "ERALK_TEAM_NAME"
local team_config_key = "ERALK_TEAM_CONFIG"
local verdict_key = "ERALK_VERDICT"
local max_verdict_messages_displayed = 3

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
  input_path = input_path,
  output_path = output_path,
  team_name_key = team_name_key,
  team_config_key = team_config_key,
  verdict_key = verdict_key,
  max_verdict_messages_displayed = max_verdict_messages_displayed,
}
