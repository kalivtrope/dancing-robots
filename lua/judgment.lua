local _ENV = _GameEnv
local noteCounter = 0
local TapNotes = {}
local HoldNotes = {}

-- The list of tap note scores available during play.
-- Only the uncommented values are actually going to be considered as triggers in this game.
local acceptedTapScores = {
  --TapNoteScore_None = true,
  --TapNoteScore_HitMine = true,
  --TapNoteScore_AvoidMine = true,
  --TapNoteScore_CheckpointMiss = true,
  --TapNoteScore_Miss = true,
  TapNoteScore_W5 = true,
  TapNoteScore_W4 = true,
  TapNoteScore_W3 = true,
  TapNoteScore_W2 = true,
  TapNoteScore_W1 = true,
  TapNoteScore_ProW5 = true,
  TapNoteScore_ProW4 = true,
  TapNoteScore_ProW3 = true,
  TapNoteScore_ProW2 = true,
  TapNoteScore_ProW1 = true,
  --TapNoteScore_MaxScore = true,
  --TapNoteScore_CheckpointHit = true,
}
local acceptedHoldScores = {
  --HoldNoteScore_None = true,
  --HoldNoteScore_LetGo = true,
  HoldNoteScore_Held = true,
  --HoldNoteScore_MissedHold = true,
}

local acceptedTapTypes = {
  --TapNoteType_Empty = true,
  TapNoteType_Tap = true,
  TapNoteType_HoldHead = true,
  --TapNoteType_HoldTail = true,
  --TapNoteType_Mine = true,
  --TapNoteType_Lift = true,
  --TapNoteType_Attack = true,
  --TapNoteType_AutoKeysound = true,
  --TapNoteType_Fake = true,
}


local function is_non_hold_judgment(judgment)
  -- see Player::SetJudgment
  return judgment.Holds ~= nil
end

local function is_hold_judgment(judgment)
  -- see Player::SetHoldJudgment and also SetMineJudgment
  return judgment.HoldNoteScore ~= nil
end

local function get_hold_notes_from_judgment(judgment)
  -- see Player::SetHoldJudgment
  local notes = {}
  local v = judgment.TapNote
  if is_hold_judgment(judgment)
    and acceptedHoldScores[judgment.HoldNoteScore]
    and acceptedTapTypes[v:GetTapNoteType()] then
      notes[#notes + 1] = v
  end
  return notes
end

local function get_tap_notes_from_judgment(judgment)
  -- see Player::SetJudgment
  local notes = {}
  if is_non_hold_judgment(judgment) then
    for _,v in pairs(judgment.Notes) do
      if v
        and acceptedTapScores[judgment.TapNoteScore]
        and acceptedTapTypes[v:GetTapNoteType()] then
          notes[#notes + 1] = v
      end
    end
  end
  return notes
end

return Def.Actor{
  Name="JudgmentStalker",
  HandleNewNoteCommand=function(self)
    noteCounter = noteCounter + 1
    Debug.screenMsg(noteCounter)
  end,
  JudgmentMessageCommand=function(self,judgment)
    Debug.logTable(judgment)
    for _,tap_note in pairs(get_tap_notes_from_judgment(judgment)) do
      if TapNotes[tap_note] == nil then
        TapNotes[tap_note] = true
        self:queuecommand("HandleNewNote")
        Debug.logMsg(noteCounter, judgment.TapNoteScore, tap_note, tap_note:GetTapNoteType(), tap_note:GetTapNoteSubType())
      end
    end

    for _,hold_note in pairs(get_hold_notes_from_judgment(judgment)) do
      if HoldNotes[hold_note] == nil then
        HoldNotes[hold_note] = true
        self:queuecommand("HandleNewNote")
        Debug.logMsg(noteCounter, judgment.HoldNoteScore, hold_note, hold_note:GetTapNoteType(), hold_note:GetTapNoteSubType())
      end
    end
  end
}
