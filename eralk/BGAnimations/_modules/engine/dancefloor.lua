local scx = SCREEN_CENTER_X
local scy = SCREEN_CENTER_Y
local sw = SCREEN_WIDTH
local sh = SCREEN_HEIGHT
local Constants = require("engine.constants")
local max_cells_per_column, real_size, max_cells_per_row =
      Constants.max_cells_per_column, Constants.real_size, Constants.max_cells_per_row
local basezoom

local Enums = require("engine.enums")
local Drawable = Enums.Drawable

local function CreateSprite(name)
  return Def.Sprite {
    Name=name,
    Texture="../../_images/" .. name .. ".png",
    InitCommand=function(self) self:visible(false) end
  }
end

local function draw_sprite_at_pos(sprite, x, y, cells_per_row, cells_per_column)
  sprite:visible(true)
  -- Here the method sprite:xy() sets the position of a sprite's CENTER relative to the screen coordinates.
  -- Screen coordinates go from (0,0) at the top-left corner to
  --   (SCREEN_WIDTH,SCREEN_HEIGHT) at the bottom-right corner of the screen.
  -- You may choose to resize the game window, however in that case the coordinate system stays the same
  --   and the engine instead takes full care of resizing and scaling content accordingly.

  -- First part (real_size/2): the sprite's actual calculated onscreen size is stored in real_size
  --   (we assume for all sprites to be squares of dimensions real_size x real_size).
  --   Since we're setting the position for the sprite's center, in order for the topleft corner sprite
  --   to be at (0,0) we must offset the coordinates by real_size/2 in both x and y directions.
  -- Second part ((x-1)*real_size): this marks the offset from the left/top edge of the leftmost/topmost placed sprite.
  -- Third part (-cells_per_row*real_size/2 + scx): first off, the origin (at the top-left corner sprite) gets moved
  --   to the screen center by adding scx.
  --   Then, by assuming we're drawing cells_per_row number of sprites,
  --   we shift the origin back by cells_per_row/2 and cells_per_column/2 sprites
  --   in order for the sprites in middle column/row to be placed exactly at the screen center x/y
  --   Subnote: it should always hold that 0 < cells_per_row <= max_cells_per_row
  sprite:xy(real_size/2 + (x-1)*real_size - cells_per_row*real_size/2 + scx,
            real_size/2 + (y-1)*real_size - cells_per_column*real_size/2 + scy)
  -- In the end, we need to scale the sprite's texture to have real_size on screen, which is done by the value
  --   of basezoom=real_size/texture_size (that is determined in the runtime below)
  sprite:basezoomx(basezoom)
  sprite:basezoomy(basezoom)
  sprite:Draw()
  sprite:visible(false)
end

local cell_data = nil
local cells_per_column = nil
local cells_per_row = nil

local function draw_function(self)
  if not cell_data then return end
  local curr_data = cell_data
  --local cells_per_column = #cell_data
  --local cells_per_row = #cell_data[1]
  assert(cells_per_column > 0 and cells_per_column <= max_cells_per_column,
    string.format("invalid number of cells per column (got '%d')", cells_per_column))
  assert(cells_per_row > 0 and cells_per_row <= max_cells_per_row,
    string.format("invalid number of cells per column (got '%d')", cells_per_row))
  for y,row in pairs(curr_data) do
    for x,cell_type_arr in pairs(row) do
      for _,cell_type in ipairs(cell_type_arr) do
        draw_sprite_at_pos(self:GetChild(cell_type), x, y, cells_per_row, cells_per_column)
      end
    end
  end
end

local Dancefloor = Def.ActorFrameTexture{
  CellUpdateMessageCommand = function(self,params)
    cell_data = params.cell_data
    cells_per_column = params.cells_per_column
    cells_per_row = params.cells_per_row
    self:visible(true)
    self:Draw()
    self:visible(false)
  end,
  InitCommand=function(self)
    self:SetWidth(sw):SetHeight(sh):SetTextureName("dancefloorAFT")
    self:xy(scx, scy)
    local start = self:GetChild(Drawable.start)
    -- obliviously assuming all textures are squares of the same size (they *better* be! >:( )
    local texture_size = start:GetTexture():GetTextureWidth()
    basezoom = real_size / texture_size
    -- cell_data = { {"start", "end"}, {"end", "start" }}
    self:SetDrawFunction(draw_function)
    self:Create()
    self:visible(false)
  end,
}

for k in pairs(Drawable) do
  Dancefloor[#Dancefloor+1] = CreateSprite(k)
end

--return Dancefloor


return Def.ActorFrame{
  Dancefloor,
  Def.Sprite{
    Texture="dancefloorAFT",
    InitCommand=function(self) self:Center() end,
  },
}
