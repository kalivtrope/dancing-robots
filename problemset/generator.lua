local Cell = require("interpreter.cell")

local Generator = {
  grid = nil,
}
Generator.__index = Generator
Generator.__tostring = function(self)
  local res = self.game_type .. "\n"
    .. self.height .. " " .. self.width .. "\n"
  for y=1,self.height do
    local row = ""
    for x=1,self.width do
      if x > 1 then row = row .. " " end
      row = row .. tostring(self.grid[x][y])
    end
    res = res .. row .. "\n"
  end
  return res
end

function Generator:new()
  local o = {}
  self.__index = self
  self.__tostring = self.__tostring
  setmetatable(o, self)
  return o
end

function Generator:add_borders()
  for i=1,math.max(self.height, self.width) do
    self.grid[1][i]:add_wall()
    if i ~= 1 then
      self.grid[i][1]:add_wall()
    end
    if i <= self.height then
      self.grid[self.width][i]:add_wall()
    end
    if i <= self.width then
      self.grid[i][self.height]:add_wall()
    end
  end
end

function Generator:init(game_type, width, height)
  self.game_type = game_type
  self.width = width
  self.height = height
  self.grid = {}
  for x=1,width do
    self.grid[x] = self.grid[x] or {}
    for y=1,height do
      self.grid[x][y] = Cell:new({x=x, y=y})
    end
  end
end

return Generator
