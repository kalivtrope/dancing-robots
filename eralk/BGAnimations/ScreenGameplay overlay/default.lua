if IsGame("dance") and GAMESTATE:GetCurrentStyle():GetName() == "single" or GAMESTATE:GetCurrentStyle():GetName() == "versus" then


-- modify package path to make the require command work
package.path = "./_modules/?.lua;" .. package.path
-- add a custom searcher utilizing FILEMAN because we don't have direct access to the filesystem here
local function load(modname)
  local errmsg = ""
  local modulepath = string.gsub(modname, "%.", "/")
  for path in string.gmatch(package.path, "([^;]+)") do
    local filename = THEME:GetPathB("", string.gsub(path, "%?", modulepath))
    if not FILEMAN:DoesFileExist(filename) then
      errmsg = errmsg .. "\n\tno file '" .. filename .. "' (custom loader)"
    else
      local loader, err = loadfile(filename)
      if err then
        error(err, 3)
      elseif loader then
        return loader
      end
    end
  end
  return errmsg
end
table.insert(package.searchers, 2, load)

local Debug = require("engine.debug")
local Interpreter = require("interpreter.interpreter")

-- TODO I'll keep this this until the engine and interpreter are properly connected
-- then I'll try to create a new screen for choosing a game
local input_name = "example_n50.in"
local output_name = "example_n50.out"
local input_path = THEME:GetPathB("", "_gamedata/Inputs/"..input_name)
local output_path = THEME:GetPathB("", "_gamedata/Outputs/"..output_name)
local input_str = assert(lua.ReadFile(input_path))
local output_str = assert(lua.ReadFile(output_path))
local int = Interpreter:new(input_str, output_str)

local judge = require("judges."..int.game.type.."-judge"):attach_to_interpreter(int)

local JudgeWrapper = require("engine.judge-wrapper")( judge )
local Dancefloor = require("engine.dancefloor")

local sh = SCREEN_HEIGHT
local sw = SCREEN_WIDTH
local height = sh / 480
local width = sw / 640
local scx = SCREEN_CENTER_X
local scy = SCREEN_CENTER_Y
--local max_cells_per_column = 10
--local max_maze_width = 1 -- a float in range (0,1] denoting the max percentage of width taken up by the maze
local max_pn = 2
local main_player = 1
local P = {}

local judge_wrapper, dancefloor, proxies

local function setupPlayerProxy(proxy, target)
  proxy:SetTarget(target)
  target:visible(false):x(scx)
end

local function setupJudgeProxy(proxy, target, pn)
  proxy:SetTarget(target):zoom(height):xy(scx * (pn-.5), scy)
  target:visible(false)
end

local function prepareVariables()
  for pn = 1, max_pn do
    local player = SCREENMAN:GetTopScreen():GetChild('PlayerP' .. pn)
    P[pn] = player
    if player then main_player = pn end
  end
end

local Proxies = Def.ActorFrame {
  Name="Proxies",
  Def.ActorProxy{ Name="P1Combo" },
  Def.ActorProxy{ Name="P2Combo" },
  Def.ActorProxy{ Name="P1Judgment" },
  Def.ActorProxy{ Name="P2Judgment" },
  Def.ActorProxy{ Name="P1" },
  Def.ActorProxy{ Name="P2" },
}

local function draw_function()
  judge_wrapper:playcommand("CurrentFrame")
  dancefloor:playcommand("Refresh")
  proxies:Draw()
end

return Def.ActorFrame {
    OnCommand=function(self)
      prepareVariables()
      judge_wrapper = self:GetChild("JudgeWrapperClockwork"):GetChild("JudgeWrapper")
      dancefloor = self:GetChild("DancefloorAF"):GetChild("Dancefloor")
      proxies = self:GetChild("Proxies")
      for pn = 1, max_pn do
        if P[pn] then
          setupPlayerProxy(proxies:GetChild("P" .. pn), P[pn])
          setupJudgeProxy(proxies:GetChild("P" .. pn .. "Combo"), P[pn]:GetChild("Combo"), pn)
          setupJudgeProxy(proxies:GetChild("P" .. pn .. "Judgment"), P[pn]:GetChild("Judgment"), pn)
        end
      end
    self:SetDrawFunction(draw_function) end,
    --[[
    Def.Quad{
      Name="Blank background baby",
      OnCommand=function(self) self:FullScreen():diffuse(0,0,0,1) end -- blank background baby
    },--]]
    Def.Actor{ OnCommand=function(self) self:sleep(9e9) end},
    JudgeWrapper,
    Dancefloor,
    Proxies,
  }

else return Def.Actor{} end
