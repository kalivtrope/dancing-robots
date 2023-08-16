local scx = SCREEN_CENTER_X
local scy = SCREEN_CENTER_Y
local sw = SCREEN_WIDTH
local sh = SCREEN_HEIGHT
local Constants = require("engine.constants")
local max_cells_per_column, real_size, max_cells_per_row, texture_size, total_texture_width =
      Constants.max_cells_per_column, Constants.real_size, Constants.max_cells_per_row, Constants.texture_size, Constants.total_texture_width

local display_ratio = real_size / texture_size
local real_texture_width = total_texture_width * display_ratio
local num_verts_per_tile = 4
local curr_frame = nil
local maze_data = nil
local cells_per_column = nil
local cells_per_row = nil

local Enums = require("engine.enums")
local Drawable = Enums.Drawable
local Dancefloor
local DrawableToSprite = {}

local function CreateSprite(name, idx)
  return Def.Sprite {
    Name=name,
    Texture="../../_images/" .. name .. ".png",
    InitCommand=function(self)
      self:visible(true)
      DrawableToSprite[idx] = self
      -- obliviously assuming all textures are squares of the same size (they *better* be! >:( )
      self:basezoomx(display_ratio)
      self:basezoomy(display_ratio)
      self:xy(real_size/2 + (idx-1)*real_size,real_size/2)
    end,
  }
end

local function draw_sprite_at_pos(sprite, x, y)
  -- Here the method sprite:xy() sets the position of a sprite's CENTER relative to the CENTER of screen coordinates.
  -- Screen coordinates go from (0,0) at the top-left corner to
  --   (SCREEN_WIDTH,SCREEN_HEIGHT) at the bottom-right corner of the screen.
  --   So the center sits precisely at (SCREEN_WIDTH/2,SCREEN_HEIGHT/2).
  -- You may choose to resize the game window, however in that case the coordinate system stays the same
  --   and the engine instead takes full care of resizing and scaling content accordingly.

  -- First part (real_size/2): the sprite's actual calculated onscreen size is stored in real_size
  --   (we assume for all sprites to be squares of dimensions real_size x real_size).
  --   Since we're setting the position for the sprite's center, in order for the topleft corner sprite
  --   to be at (0,0) we must offset the coordinates by real_size/2 in both x and y directions.
  -- Second part ((x-1)*real_size): this marks the offset from the left/top edge of the leftmost/topmost placed sprite.
  -- Third part (-cells_per_row*real_size/2): first off, the origin (at the top-left corner of the sprite) gets moved
  --   to the screen center by adding scx (this is implicit since we're placing this sprite relative to this parent,
  -- which is at the center, as mentioned previously).
  --   Then, by assuming we're drawing cells_per_row number of sprites,
  --   we shift the origin back by cells_per_row/2 and cells_per_column/2 sprites
  --   in order for the sprites in middle column/row to be placed exactly at the screen center x/y
  --   Subnote: it should always hold that 0 < cells_per_row <= max_cells_per_row
  sprite:xy(real_size/2 + (x-1)*real_size - cells_per_row*real_size/2,
            real_size/2 + (y-1)*real_size - cells_per_column*real_size/2)
  -- In the beginning, we also needed to scale the sprite's texture to have real_size on screen,
  -- which was done by the value of basezoom=real_size/texture_size (that was determined in the runtime defined above)
  sprite:Draw()
end

local function place_drawable_at_pos(drawable_idx, x, y)
  local scp_x = real_size/2 + (x-1)*real_size - cells_per_row*real_size/2 + scx
  local scp_y = real_size/2 + (y-1)*real_size - cells_per_column*real_size/2 + scy
  local tcp_x = (drawable_idx - 0.5) * real_size
  local tcp_y = 0.5 * real_size
  local A = { {scp_x-real_size/2,scp_y-real_size/2,0},Color.White,{(tcp_x-real_size/2+0.5)/real_texture_width,(tcp_y-real_size/2+0.5)/real_size} }
  local B = { {scp_x-real_size/2,scp_y+real_size/2,0},Color.White,{(tcp_x-real_size/2+0.5)/real_texture_width,(tcp_y+real_size/2-0.5)/real_size} }
  local C = { {scp_x+real_size/2,scp_y+real_size/2,0},Color.White,{(tcp_x+real_size/2-0.5)/real_texture_width,(tcp_y+real_size/2-0.5)/real_size} }
  local D = { {scp_x+real_size/2,scp_y-real_size/2,0},Color.White,{(tcp_x+real_size/2-0.5)/real_texture_width,(tcp_y-real_size/2+0.5)/real_size} }
  --[[
    A D
    B C
  --]]
  return {
    A, B, C, D
  }
end

local function draw_function()
  local min_row, min_col, max_row, max_col
    = curr_frame.min_row, curr_frame.min_col, curr_frame.max_row, curr_frame.max_col
  local min_rowf, min_colf, max_rowc, max_colc
    = math.floor(min_row), math.floor(min_col), math.ceil(max_row), math.ceil(max_col)
  for row=min_rowf,max_rowc do
    if maze_data[row] then
      for col=min_colf,max_colc do
        local cell = maze_data[row][col]
        if cell then
          for i=1,Drawable._len do
            if cell[i] then
              draw_sprite_at_pos(DrawableToSprite[i], col-min_col+1, row-min_row+1)
            end
          end
        end
      end
    end
  end
end

local polygons = {}



local DancefloorSprites=Def.ActorFrameTexture{
  InitCommand=function(self)
    self:SetWidth(real_texture_width):SetHeight(real_size):SetTextureName("DancefloorSprites"):EnableAlphaBuffer(true)
    self:Create()
    self:Draw()
    self:hibernate(math.huge)
  end,
}

 for name, idx in pairs(Drawable) do
   if name ~= "_len" then
     DancefloorSprites[#DancefloorSprites+1] = CreateSprite(name, idx)
   end
 end

local function dancefloor_update()
    local min_row, min_col, max_row, max_col
      = curr_frame.min_row, curr_frame.min_col, curr_frame.max_row, curr_frame.max_col
    local min_rowf, min_colf, max_rowc, max_colc
      = math.floor(min_row), math.floor(min_col), math.ceil(max_row), math.ceil(max_col)
    Dancefloor:SetNumVertices(num_verts_per_tile * (max_rowc - min_rowf + 1) * (max_colc - min_colf + 1))
    local vert_index = 1
    for row=min_rowf,max_rowc do
      if maze_data[row] then
        for col=min_colf,max_colc do
          local cell = maze_data[row][col]
          if cell then
            for i=1,Drawable._len do
              if cell[i] then
                Dancefloor:SetVertices(vert_index, place_drawable_at_pos(i, col-min_col+1, row-min_row+1))
                vert_index = vert_index + num_verts_per_tile
              end
            end
          end
        end
      end
    end
end

local DancefloorActor = Def.ActorMultiVertex{
  Name="Dancefloor",
  Texture="DancefloorSprites",
  DataBindMessageCommand=function(_,params)
    --print("received data bind")
    maze_data = params.maze_data
    curr_frame = params.curr_frame
    cells_per_row = params.cells_per_row
    cells_per_column = params.cells_per_column
    assert(type(cells_per_column) == "number" and cells_per_column > 0 and cells_per_column <= max_cells_per_column,
      string.format("invalid number of cells per column (got '%s')", cells_per_column))
    assert(type(cells_per_row) == "number" and cells_per_row > 0 and cells_per_row <= max_cells_per_row,
      string.format("invalid number of cells per column (got '%s')", cells_per_row))
  end,
  InitCommand=function(self)
    --print("init")
    self:zwrite(false):ztest(false):SetDrawState{Mode='DrawMode_Quads', First=1, Num=-1}:SetTextureFiltering(true)
    Dancefloor = self
  end,
  OnCommand=function(self)
    --self:queuecommand("Refresh")
  end,
  RefreshCommand=function(self)
    --print("Update")
    self:SetNumVertices(num_verts_per_tile)
    local min_row, min_col, max_row, max_col
      = curr_frame.min_row, curr_frame.min_col, curr_frame.max_row, curr_frame.max_col
    local min_rowf, min_colf, max_rowc, max_colc
      = math.floor(min_row), math.floor(min_col), math.ceil(max_row), math.ceil(max_col)
    self:SetNumVertices(num_verts_per_tile * (max_rowc - min_rowf + 1) * (max_colc - min_colf + 1))
    --print("num verts", self:GetNumVertices())
    local vert_index = 1 -- ig?
    for row=min_rowf,max_rowc do
      if maze_data[row] then
        for col=min_colf,max_colc do
          local cell = maze_data[row][col]
          if cell then
            for i=1,Drawable._len do
              if cell[i] then
                self:SetVertices(vert_index, place_drawable_at_pos(i, col-min_col+1, row-min_row+1))
                vert_index = vert_index + num_verts_per_tile
              end
            end
          end
        end
      end
    end
    self:sleep(1/4):queuecommand("Refresh")
  end,
}
--[[
local Dancefloor = Def.ActorFrame{
  Name="Dancefloor",
  DataBindMessageCommand=function(_,params)
    maze_data = params.maze_data
    curr_frame = params.curr_frame
    cells_per_row = params.cells_per_row
    cells_per_column = params.cells_per_column
    assert(type(cells_per_column) == "number" and cells_per_column > 0 and cells_per_column <= max_cells_per_column,
      string.format("invalid number of cells per column (got '%s')", cells_per_column))
    assert(type(cells_per_row) == "number" and cells_per_row > 0 and cells_per_row <= max_cells_per_row,
      string.format("invalid number of cells per column (got '%s')", cells_per_row))
  end,
  InitCommand=function(self)
    self:xy(scx, scy)
    self:SetDrawFunction(draw_function)
  end,
}
--]]

--[[
 for name, idx in pairs(Drawable) do
   if name ~= "_len" then
     Dancefloor[#Dancefloor+1] = CreateSprite(name, idx)
   end
 end
--]]

return Def.ActorFrame{
  OnCommand=function(self)
    self:SetUpdateFunction(dancefloor_update):SetUpdateFPS(60)
  end,
  DancefloorSprites,
  DancefloorActor,
}
--[[
return Def.ActorFrame{
  Name="dancefloorAF",
  Dancefloor,
  Def.Sprite{
    Texture="dancefloorAFT",
    InitCommand=function(self) self:Center() end,
  },
}--]]
