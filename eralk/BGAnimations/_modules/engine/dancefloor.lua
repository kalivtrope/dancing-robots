local scx = SCREEN_CENTER_X
local scy = SCREEN_CENTER_Y
local sw = SCREEN_WIDTH
local sh = SCREEN_HEIGHT
local Constants = require("engine.constants")
local max_cells_per_column, real_size, max_cells_per_row =
      Constants.max_cells_per_column, Constants.real_size, Constants.max_cells_per_row
local cell_data = nil
local cell_len = 0
local cells_per_column = nil
local cells_per_row = nil

local Enums = require("engine.enums")
local Drawable = Enums.Drawable
local DrawableToSprite = {}

local function CreateSprite(name, idx)
  return Def.Sprite {
    Name=name,
    Texture="../../_images/" .. name .. ".png",
    InitCommand=function(self)
      self:visible(false)
      DrawableToSprite[idx] = self
      local texture_size = self:GetTexture():GetTextureWidth()
      -- obliviously assuming all textures are squares of the same size (they *better* be! >:( )
      local basezoom = real_size / texture_size
      self:basezoomx(basezoom)
      self:basezoomy(basezoom)
    end,
  }
end

local function draw_sprite_at_pos(sprite, x, y)
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
  -- In the beginning, we also needed to scale the sprite's texture to have real_size on screen,
  -- which was done by the value of basezoom=real_size/texture_size (that was determined in the runtime defined above)
  sprite:Draw()
  sprite:visible(false)
end

local function draw_function()
  for i=1,cell_len do
    local cell = cell_data[i]
    local row, col = cell.row, cell.col
    for _,cell_type in ipairs(cell) do
      draw_sprite_at_pos(DrawableToSprite[cell_type], col, row)
    end
  end
end



local Dancefloor = Def.ActorFrameTexture{
  Name="Dancefloor",
  CellsPerDimenMessageCommand=function(_,params)
    cells_per_row = params.cells_per_row
    cells_per_column = params.cells_per_column
    assert(type(cells_per_column) == "number" and cells_per_column > 0 and cells_per_column <= max_cells_per_column,
      string.format("invalid number of cells per column (got '%s')", cells_per_column))
    assert(type(cells_per_row) == "number" and cells_per_row > 0 and cells_per_row <= max_cells_per_row,
      string.format("invalid number of cells per column (got '%s')", cells_per_row))
  end,
  FlushDrawMessageCommand=function(self)
    self:visible(true)
    self:Draw()
    self:visible(false)
    cell_len = 0
  end,
  CellUpdateMessageCommand = function(_,cell)
    cell_len = cell_len + 1
    cell_data[cell_len] = cell
  end,
  InitCommand=function(self)
    self:SetWidth(sw):SetHeight(sh):SetTextureName("dancefloorAFT")
    self:xy(scx, scy)
    self:SetDrawFunction(draw_function)
    self:Create()
    self:visible(false)
    cell_data = {}
    cell_len = 0
  end,
}

for name, idx in pairs(Drawable) do
  Dancefloor[#Dancefloor+1] = CreateSprite(name, idx)
end

--return Dancefloor

return Def.ActorFrame{
  Dancefloor,
  Def.Sprite{
    Texture="dancefloorAFT",
    InitCommand=function(self) self:Center() end,
  },
}
