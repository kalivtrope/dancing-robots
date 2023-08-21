local InstructionDispatcher
local RecognizedTypes = require("engine.recognized-types")
local Debug = require("engine.debug")

local get_tap_notes_from_judgment = RecognizedTypes.get_tap_notes_from_judgment
local get_hold_notes_from_judgment = RecognizedTypes.get_hold_notes_from_judgment


local TapNotes, HoldNotes

return Def.Actor{
  name="JudgmentEmitter",
  OnCommand=function(self)
    InstructionDispatcher = self:GetParent():GetChild("InstructionDispatcher")
    self:visible(false)
    TapNotes = {}
    HoldNotes = {}
  end,
  JudgmentMessageCommand=function(self,judgment)
    --Debug.logTable(judgment)
    --Debug.logMsg(get_hold_notes_from_judgment(judgment))
    --Debug.logTable(get_tap_notes_from_judgment(judgment))

    for _,note_data in pairs(get_tap_notes_from_judgment(judgment)) do
      local tap_note = note_data.Note
      local is_hit = note_data.IsHit
      if TapNotes[tap_note] == nil then
        TapNotes[tap_note] = true
        if is_hit then
          InstructionDispatcher:queuecommand("HandleNewHitNote" .. note_data.Player )
        else
          InstructionDispatcher:queuecommand("HandleNewMissedNote" .. note_data.Player )
        end
      end
    end

    for _,note_data in pairs(get_hold_notes_from_judgment(judgment)) do
      local hold_note = note_data.Note
      local is_hit = note_data.IsHit
      if HoldNotes[hold_note] == nil then
        HoldNotes[hold_note] = true
        if is_hit then
          InstructionDispatcher:queuecommand("HandleNewHitNote" .. note_data.Player )
        else
          InstructionDispatcher:queuecommand("HandleNewMissedNote" .. note_data.Player )
        end
      end
    end
  end
}
