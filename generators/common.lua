local Cell = require("interpreter.cell")

local Generator = {
  grid = nil,
}
Generator.__index = Generator
Generator.__tostring = function(self)
  local res = self.game_type .. "\n"
    .. self.height .. " " .. self.width .. "\n"
  for row=1,self.height do
    local row_str = ""
    for col=1,self.width do
      if col > 1 then row_str = row_str .. " " end
      row_str = row_str .. tostring(self.grid[row][col])
    end
    res = res .. row_str .. "\n"
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
    if i <= self.height then
      self.grid[i][1]:add_wall()
      self.grid[i][self.width]:add_wall()
    end
    if i <= self.width then
      if i ~= 1 then
        self.grid[1][i]:add_wall()
      end
      self.grid[self.height][i]:add_wall()
    end
  end
end

function Generator:init(game_type, height, width)
  self.game_type = game_type
  self.height = height
  self.width = width
  self.grid = {}
  for row=1,height do
    self.grid[row] = self.grid[row] or {}
    for col=1,width do
      self.grid[row][col] = Cell:new({row=row, col=col})
    end
  end
end

return Generator
