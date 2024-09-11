local Constants = require("engine.constants")
local verdict_key = Constants.verdict_key
local max_verdict_messages_displayed = Constants.max_verdict_messages_displayed
local controller

local font_size_px = 20
local main_verdict_zoom = 3

local function exit_screen(self)
  SCREENMAN:GetTopScreen():RemoveInputCallback(controller)
  -- send a special type of message (a screen message) to start transitioning
  SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToNextScreen")
end

return Def.ActorFrame{
  OnCommand=function(self)
    controller = LoadModule("Lua.InputSystem.lua")(self)
    WriteResult(ConstructStats())
    SCREENMAN:GetTopScreen():AddInputCallback(controller)
  end,
  OffCommand=function(self)
    SCREENMAN:GetTopScreen():RemoveInputCallback(controller)
  end,
  BackCommand=function(self)
    exit_screen(self)
  end,
  StartCommand=function(self)
    exit_screen(self)
  end,
  Def.ActorFrame{
    InitCommmand=function(self)

    end,
    OnCommand=function(self) self:Center() end,
    Def.BitmapText{
      Font="Common Normal",
      OnCommand=function(self)
        self:zoom(main_verdict_zoom)
        local verdict = (GAMESTATE:Env()[verdict_key] or {})[1]
        if verdict then
          self:settext("LEVEL CLEARED")
        else
          self:settext("LEVEL FAILED")
        end
      end
    },
    Def.BitmapText{
      Font="Common Normal",
      OnCommand=function(self)
        self:y(font_size_px*main_verdict_zoom + font_size_px*max_verdict_messages_displayed/2)
        local verdict_comments = (GAMESTATE:Env()[verdict_key] or {})[2] or ""
        local pattern = "(.-)\r?\n"
        local match_result = ""
        local num_matches = 0
        for match in string.gmatch(verdict_comments, pattern) do
          match_result = match_result .. (num_matches > 0 and "\n" or "") .. match
          num_matches = num_matches + 1
          if num_matches >= max_verdict_messages_displayed then break end
        end
        if match_result then
          self:settext(match_result)
        else
          self:settext(verdict_comments)
        end
      end,
    },
      Def.BitmapText{
      Font="Common Normal",
      OnCommand=function(self)
        self:y(font_size_px*main_verdict_zoom + font_size_px*max_verdict_messages_displayed)
        self:settext("\n\nHit " .. (GAMESTATE:Env()[Constants.played_num_of_steps] or -1)  .. "/" .. (GAMESTATE:Env()[Constants.total_num_of_steps] or 0) .. " notes")
      end,
    }
  },
}
