local _ENV = _GameEnv
local hitNoteCounter = 0
local missedNoteCounter = 0
local totalNumberOfNotes = 0
local TapNotes = {}
local HoldNotes = {}

-- The list of all tap note scores and types available during play
-- taken from the OutFox source code.
-- Only the uncommented values are actually going to be considered as triggers in this game.
local acceptedTapScores = {
  Misses = {
    --TapNoteScore_None = true,
    --TapNoteScore_HitMine = true,
    --TapNoteScore_AvoidMine = true,
    --TapNoteScore_CheckpointMiss = true,
    TapNoteScore_Miss = true,
  },
  Hits = {
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
  },
}
local acceptedHoldScores = {
  Misses = {
    --HoldNoteScore_None = true,
    HoldNoteScore_LetGo = true,
    HoldNoteScore_MissedHold = true,
  },
  Hits = {
    HoldNoteScore_Held = true,
  },
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

local acceptedTapSubtypes = {
  TapNoteSubType_Hold = true,
  TapNoteSubType_Roll = true,
}


local function is_non_hold_judgment(judgment)
  -- see Player::SetJudgment
  return judgment.Holds ~= nil
end

local function is_hold_judgment(judgment)
  -- see Player::SetHoldJudgment and also SetMineJudgment
  return judgment.HoldNoteScore ~= nil
end

local function is_hit_hold_score(score)
  return acceptedHoldScores.Hits[score] ~= nil
end

local function is_miss_hold_score(score)
  return acceptedHoldScores.Misses[score] ~= nil
end

local function is_hit_tap_score(score)
  return acceptedTapScores.Hits[score] ~= nil
end

local function is_miss_tap_score(score)
  return acceptedTapScores.Misses[score] ~= nil
end


local function is_accepted_hold_score(score)
  return is_hit_hold_score(score) or is_miss_hold_score(score)
end

local function is_accepted_tap_score(score)
  return is_hit_tap_score(score) or is_miss_tap_score(score)
end

local function is_accepted_note_type(note_type)
  return acceptedTapTypes[note_type] ~= nil
end

local function is_accepted_note_subtype(note_subtype)
  return acceptedTapSubtypes[note_subtype] ~= nil
end

local function get_hold_notes_from_judgment(judgment)
  -- see Player::SetHoldJudgment
  local notes = {}
  local v = judgment.TapNote
  if is_hold_judgment(judgment)
    and is_accepted_hold_score(judgment.HoldNoteScore)
    and is_accepted_note_type(v:GetTapNoteType())
      then notes[#notes + 1] = {Note = v, IsHit = is_hit_hold_score(judgment.HoldNoteScore)} end
  return notes
end

local function get_tap_notes_from_judgment(judgment)
  -- see Player::SetJudgment
  local notes = {}
  if is_non_hold_judgment(judgment) then
    for _,v in pairs(judgment.Notes) do
      if v
        and is_accepted_tap_score(judgment.TapNoteScore)
        and is_accepted_note_type(v:GetTapNoteType())
          then notes[#notes + 1] = {Note = v, IsHit = is_hit_tap_score(judgment.TapNoteScore)} end
    end
  end
  return notes
end

local function count_notes(note_data)
  -- see OutFox docs for Player::GetNoteData
  -- parameter note_data is an array of NoteDataEntries
  -- the NoteDataEntry follows the structure
  -- { beat, column, notetype, quantization, length = fBeatLen }
  -- we're only after the 3rd argument here
  local count = 0
  for _,note_data_entry in ipairs(note_data) do
    local note_type = note_data_entry[3]
    -- tap notes count as one
    if is_accepted_note_type(note_type) then
      count = count + 1
    -- hold notes count as two (head + tail)
    elseif is_accepted_note_subtype(note_type) then
      count = count + 2
    end
  end
  return count
end

return Def.Actor{
  Name="JudgmentStalker",
  OnCommand=function(self)
    local p1 = SCREENMAN:GetTopScreen():GetChild('PlayerP1')
    totalNumberOfNotes = count_notes(p1:GetNoteData())
    Debug.screenMsg(totalNumberOfNotes)
  end,
  HandleNewHitNoteCommand=function(self)
    hitNoteCounter = hitNoteCounter + 1
    Debug.screenMsg("hit:", hitNoteCounter, "missed:", missedNoteCounter, "total:", totalNumberOfNotes)
  end,
  HandleNewMissedNoteCommand=function(self)
    missedNoteCounter = missedNoteCounter + 1
    Debug.screenMsg("hit:", hitNoteCounter, "missed:", missedNoteCounter, "total:", totalNumberOfNotes)
  end,
  JudgmentMessageCommand=function(self,judgment)
    Debug.logTable(judgment)
    for _,note_data in pairs(get_tap_notes_from_judgment(judgment)) do
      tap_note = note_data.Note
      is_hit = note_data.IsHit
      if TapNotes[tap_note] == nil then
        TapNotes[tap_note] = true
        if is_hit then
          self:queuecommand("HandleNewHitNote")
        else
          self:queuecommand("HandleNewMissedNote")
        end
        Debug.logMsg(hitNoteCounter, missedNoteCounter, judgment.TapNoteScore, tap_note, tap_note:GetTapNoteType(), tap_note:GetTapNoteSubType())
      end
    end

    for _,note_data in pairs(get_hold_notes_from_judgment(judgment)) do
      hold_note = note_data.Note
      is_hit = note_data.IsHit
      if HoldNotes[hold_note] == nil then
        HoldNotes[hold_note] = true
        if is_hit then
          self:queuecommand("HandleNewHitNote")
        else
          self:queuecommand("HandleNewMissedNote")
        end
        Debug.logMsg(hitNoteCounter, missedNoteCounter, judgment.HoldNoteScore, hold_note, hold_note:GetTapNoteType(), hold_note:GetTapNoteSubType())
      end
    end
  end
}
