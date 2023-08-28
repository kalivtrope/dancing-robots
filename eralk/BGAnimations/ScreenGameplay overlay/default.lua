local function get_player(pn)
  return SCREENMAN:GetTopScreen():GetChild('PlayerP' .. pn)
end

local Debug = require("engine.debug")
local RecognizedTypes = require("engine.recognized-types")
local is_recognized_style_type = RecognizedTypes.is_recognized_style_type
local should_distinguish_player_score = RecognizedTypes.should_distinguish_player_score

local curr_style_type = GAMESTATE:GetCurrentStyle():GetStyleType()
if not is_recognized_style_type(curr_style_type) then
  Debug.screen_msg("Unrecognized style type:", curr_style_type)
  return Def.Actor{}
end

local Constants = require("engine.constants")
local max_pn = Constants.max_pn
local config_key = Constants.config_key
local input_dir = Constants.input_path
local output_dir = Constants.output_path
local curr_config = GAMESTATE:Env()[config_key]

local Interpreter = require("interpreter.interpreter")

-- TODO I'll keep this this until the engine and interpreter are properly connected
-- then I'll try to create a new screen for choosing a game
local input_path = input_dir .. "/" .. curr_config ..  ".in"
local output_path = output_dir .. "/" .. curr_config .. ".out"
local input_str = assert(lua.ReadFile(input_path))
local output_str = assert(lua.ReadFile(output_path))
local int = Interpreter:new(input_str, output_str)

local judge = require("judges."..int.game.type..".main"):attach_to_interpreter(int)

local JudgeWrapper = require("engine.judge-wrapper")( judge )
local Dancefloor = require("engine.dancefloor")
local InstructionDispatcher = require("engine.instruction-dispatcher")
local JudgmentEmitter = require("engine.judgment-emitter")

local sh = SCREEN_HEIGHT
local sw = SCREEN_WIDTH
local height = sh / 480
local width = sw / 640
local scx = SCREEN_CENTER_X
local scy = SCREEN_CENTER_Y

local P = {}

local judge_wrapper, dancefloor, proxies, blank

local function setupPlayerProxy(proxy, target)
  proxy:SetTarget(target)
  target:visible(false)
  -- center if there's only one notefield
  if GAMESTATE:GetNumSidesJoined() == 1 then
    target:x(scx)
  end
end

local function setupJudgeProxy(proxy, target, pn)
  proxy:SetTarget(target):zoom(height):xy(scx * (pn-.5), scy)
  target:visible(false)
end

local function prepareVariables()
  for pn = 1, max_pn do
    local player = get_player(pn)
    P[pn] = player
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
  blank:Draw()
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
      blank = self:GetChild("Blank")
      for pn = 1, max_pn do
        if P[pn] then
          setupPlayerProxy(proxies:GetChild("P" .. pn), P[pn])
          setupJudgeProxy(proxies:GetChild("P" .. pn .. "Combo"), P[pn]:GetChild("Combo"), pn)
          setupJudgeProxy(proxies:GetChild("P" .. pn .. "Judgment"), P[pn]:GetChild("Judgment"), pn)
        end
      end
    self:SetDrawFunction(draw_function) end,
    ---[[
    Def.Quad{
      Name="Blank",
      OnCommand=function(self) self:FullScreen():diffuse(0,0,0,1) end -- blank background
    },--]]
    Def.Actor{ OnCommand=function(self) self:sleep(9e9) end},
    JudgeWrapper,
    InstructionDispatcher,
    JudgmentEmitter,
    Dancefloor,
    Proxies,
  }
