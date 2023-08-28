local log_msg = require("engine.debug").log_msg

local function create_set(t)
  local res = {}
  for _,v in ipairs(t) do
    res[v] = true
  end
  return res
end

-- The exhaustive list of all style and tap note {(sub)types,scores} available during play
-- taken straight from the OutFox documentation.
-- See Stepmania source code at src/GameConstantsAndTypes.h and src/NoteTypes.h
--  for more detailed explanation on all these enums.
local RecognizedStyleTypes = {
  DistinguishPlayerScore = create_set {
    'StyleType_TwoPlayersTwoSides', -- each player has their own notefield
  },
  Other = create_set {
    'StyleType_OnePlayerOneSide', -- occurs only during singleplayer
    -- there are two fields which are practically under control of a single player
    --   but require input from two input controllers
    'StyleType_OnePlayerTwoSides',

    -- I couldn't find a chart of this type to test this code onto, so I'm currently leaving this commented out.
    -- (it's apparently supposed to be a type for Couples charts but
    --   the only Couples pack that I found got its style reported as OnePlayerTwoSides)
    --'StyleType_TwoPlayersSharedSides',
  }
}

local RecognizedTapScores = {
  -- arbitrary partitioning into what I would consider to be the hit and miss sets respectively
  Misses = create_set {
    --'TapNoteScore_HitMine',
    --'TapNoteScore_AvoidMine',
    --'TapNoteScore_CheckpointMiss',
    'TapNoteScore_Miss',
  },
  Hits = create_set {
    'TapNoteScore_W5',
    'TapNoteScore_W4',
    'TapNoteScore_W3',
    'TapNoteScore_W2',
    'TapNoteScore_W1',
    -- below are the new judgment scores added in OutFox
    'TapNoteScore_ProW5',
    'TapNoteScore_ProW4',
    'TapNoteScore_ProW3',
    'TapNoteScore_ProW2',
    'TapNoteScore_ProW1',
    -- end of new judgment scores added in OutFox
    --'TapNoteScore_CheckpointHit',
  },
}

local RecognizedHoldScores = {
  Misses = create_set {
    'HoldNoteScore_LetGo',
    'HoldNoteScore_MissedHold',
  },
  Hits = create_set {
    'HoldNoteScore_Held',
  },
}

local RecognizedTapTypes = create_set {
  --TapNoteType_Empty,
  'TapNoteType_Tap',
  'TapNoteType_HoldHead',
  'TapNoteType_LongNoteHead', -- newly added in OutFox Alpha V, *should* supersede HoldHead
  -- (got renamed to make more sense in gamemodes other than dance that don't make you physically hold notes (I guess))
  --'TapNoteType_HoldTail',
  --'TapNoteType_LongNoteTail', -- supersedes HoldTail
  --'TapNoteType_Mine',
  --'TapNoteType_Lift',
  --'TapNoteType_Attack',
  --'TapNoteType_AutoKeysound',
  --'TapNoteType_Fake',
}

local RecognizedTapSubtypes = create_set {
  'TapNoteSubType_Hold',
  'TapNoteSubType_Roll',
}

-- The following indicators were mainly hacked from runtime observation and eyeballing the stepmania source code
--  (by which I want to say: I realize the conditions that I test for
--    may be a bit confusing, but that's just how the judgment objects are apparently constructed).
-- there are currently three judgment function calls that we might choose to identify:
  -- ("Tapnote") judgment - primarily for taps,
  --                        but there may also appear e.g. hold tails if they're being judged at the same time
  -- Holdnote judgment - used for holds not judged along with any taps
  --                     (only the HoldHead notes appear here, I think)
  -- Mine judgment (we choose to ignore them in this code)
  -- See methods Player::SetJudgment, Player::SetHoldJudgment and Player::SetMineJudgment at SM src/Player.cpp
  --  for more information.

local function is_tap_judgment(judgment)
  -- see Player::SetJudgment
  return judgment.Holds ~= nil
end

local function is_hold_judgment(judgment)
  -- see Player::SetHoldJudgment and also SetMineJudgment
  return judgment.HoldNoteScore ~= nil
end

local function is_hit_hold_score(score)
  return RecognizedHoldScores.Hits[score] ~= nil
end

local function is_miss_hold_score(score)
  return RecognizedHoldScores.Misses[score] ~= nil
end

local function is_hit_tap_score(score)
  return RecognizedTapScores.Hits[score] ~= nil
end

local function is_miss_tap_score(score)
  return RecognizedTapScores.Misses[score] ~= nil
end


local function is_recognized_hold_score(score)
  return is_hit_hold_score(score) or is_miss_hold_score(score)
end

local function is_recognized_tap_score(score)
  return is_hit_tap_score(score) or is_miss_tap_score(score)
end

local function is_recognized_note_type(note_type)
  return RecognizedTapTypes[note_type] ~= nil
end

local function is_recognized_note_subtype(note_subtype)
  return RecognizedTapSubtypes[note_subtype] ~= nil
end

local function get_hold_notes_from_judgment(judgment)
  -- see Player::SetHoldJudgment
  local notes = {}
  local v = judgment.TapNote
  if is_hold_judgment(judgment)
    and is_recognized_hold_score(judgment.HoldNoteScore)
    and is_recognized_note_type(v:GetTapNoteType())
      then notes[#notes + 1] = {Note = v, IsHit = is_hit_hold_score(judgment.HoldNoteScore),
                                Player = pname(judgment.Player)} end
  return notes
end

local function get_tap_notes_from_judgment(judgment)
  -- see Player::SetJudgment
  local notes = {}
  if is_tap_judgment(judgment) then
    for _,v in pairs(judgment.Notes) do
      --log_msg(v:GetTapNoteType())
      if v
        and is_recognized_tap_score(judgment.TapNoteScore)
        and is_recognized_note_type(v:GetTapNoteType())
          then notes[#notes + 1] = {Note = v, IsHit = is_hit_tap_score(judgment.TapNoteScore),
                                    Player = pname(judgment.Player)} end
    end
  end
  return notes
end

local function count_notes_from_note_data(note_data)
  -- See OutFox docs for Player::GetNoteData
  -- The note_data parameter is an _array_ of NoteDataEntries.
  -- The NoteDataEntry follows the array structure
  --   { beat, column, notetype, quantization, length = fBeatLen }
  -- We're only after the 3rd argument (notetype) here.
  local count = 0
  for _,note_data_entry in ipairs(note_data) do
    local note_type = note_data_entry[3]
    -- tap notes count as one
    if is_recognized_note_type(note_type) then
      count = count + 1
    -- hold/long notes count as two (head + tail)
    elseif is_recognized_note_subtype(note_type) then
      count = count + 2
    end
  end
  return count
end

local function is_recognized_style_type(style_type)
  return RecognizedStyleTypes.DistinguishPlayerScore[style_type] or RecognizedStyleTypes.Other[style_type]
end

local function should_distinguish_player_score(style_type)
  return RecognizedStyleTypes.DistinguishPlayerScore[style_type] ~= nil
end


return {
  -- export helper functions for accessing and utilizing all of the enums defined above
  count_notes_from_note_data = count_notes_from_note_data,
  get_tap_notes_from_judgment = get_tap_notes_from_judgment,
  get_hold_notes_from_judgment = get_hold_notes_from_judgment,
  should_distinguish_player_score = should_distinguish_player_score,
  is_recognized_style_type = is_recognized_style_type,
}
