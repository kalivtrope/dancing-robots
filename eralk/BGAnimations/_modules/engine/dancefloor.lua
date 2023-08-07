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

local function draw_sprite_at_pos(sprite, x, y)
  sprite:visible(true)
  sprite:xy(real_size/2 + (x-1)*real_size - max_cells_per_row*real_size/2 + scx,
            real_size/2 + (y-1)*real_size - max_cells_per_column*real_size/2 + scy)
  sprite:basezoomx(basezoom)
  sprite:basezoomy(basezoom)
  sprite:Draw()
  sprite:visible(false)
end

local cell_data = nil

local function draw_function(self)
  if not cell_data then return end
  local curr_data = cell_data
  for y,row in ipairs(curr_data) do
    for x,cell_type_arr in ipairs(row) do
      for _,cell_type in ipairs(cell_type_arr) do
        draw_sprite_at_pos(self:GetChild(cell_type), x, y)
      end
    end
  end
end


local Dancefloor = Def.ActorFrameTexture{ -- TODO: check if this poor guy doesn't get mercilessly murdered??
  CellUpdateMessageCommand = function(self,params)
    cell_data = params.cell_data
    self:visible(true)
    self:Draw()
    self:visible(false)
  end,
  InitCommand=function(self)
    self:SetWidth(sw):SetHeight(sh):SetTextureName("dancefloorAFT")
    self:xy(scx, scy)
    local start = self:GetChild(Drawable.start)
    --local End = self:GetChild(Drawable["end"])
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

return Def.ActorFrame{
  Dancefloor,
  Def.Sprite{
    Texture="dancefloorAFT",
    InitCommand=function(self) self:Center() end,
  },
}
