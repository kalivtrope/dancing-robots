local Constants = require("engine.constants")
--local Debug = require("engine.debug")
local Queue = require("data_structures.queue")
local RecognizedTypes = require("engine.recognized-types")
local min_notes_per_batch, max_pn = Constants.min_notes_per_batch, Constants.max_pn  -- pn = player_number
local should_distinguish_player_score = RecognizedTypes.should_distinguish_player_score
local count_notes_from_note_data = RecognizedTypes.count_notes_from_note_data
-- the local variables need to be (re)set on Init in these scripts
local note_counter
local distinguish_player_score
local total_numbers_of_notes
local total_number_of_instructions
local total_number_of_batches
local instruction_per_batch
local notes_per_batch
local extra_notes
local extra_instruction
local batch_queues
local processed_number_of_batches
local current_numbers_of_hits
local current_numbers_of_misses
local players_present
local game_over

local default_pn = 1

local function enqueue_judgments_for_player(pn)
  if not distinguish_player_score then pn = default_pn end

  local needs_extra_note = processed_number_of_batches < extra_notes[pn] and 1 or 0
  while current_numbers_of_hits[pn] + current_numbers_of_misses[pn]
        >= notes_per_batch[pn] + needs_extra_note do
    local outcome = current_numbers_of_hits[pn] > 0
    local rem_notes = notes_per_batch[pn] + needs_extra_note
    rem_notes, current_numbers_of_hits[pn] = math.max(0, rem_notes-current_numbers_of_hits[pn]),
                                             math.max(0, current_numbers_of_hits[pn]-rem_notes)
    rem_notes, current_numbers_of_misses[pn] = math.max(0, rem_notes-current_numbers_of_misses[pn]),
                                               math.max(0, current_numbers_of_misses[pn]-rem_notes)
    assert(rem_notes == 0, string.format("rem_notes not properly spent (%d remains)", rem_notes))
    batch_queues[pn]:enqueue(outcome)
    needs_extra_note = processed_number_of_batches < extra_notes[pn] and 1 or 0
  end
end

local function enqueue_judgments()
  for pn=1,max_pn do
    if players_present[pn] then
      enqueue_judgments_for_player(pn)
      if not distinguish_player_score then break end
    end
  end
end

local function dispatch_batch(batch_successful)
  local needs_extra_instruction = processed_number_of_batches < extra_instruction and 1 or 0
  MESSAGEMAN:Broadcast("ExecuteNext", {randomize = not batch_successful, n=instruction_per_batch+needs_extra_instruction})
  --Debug.stderr_msg(batch_successful, processed_number_of_batches, total_number_of_batches)
end

local function dispatch_processed_batches_together()
  while batch_queues[default_pn]:size() > 0 do
    dispatch_batch(batch_queues[default_pn]:dequeue())
    processed_number_of_batches = processed_number_of_batches + 1
    --Debug.stderr_msg("batch no", processed_number_of_batches, "out of", total_number_of_batches)
  end
end

local function dispatch_processed_batches_distinguish()
  local batch_size = math.huge
  for pn=1,max_pn do
    if players_present[pn] then batch_size = math.min(batch_size, batch_queues[pn]:size()) end
  end
  assert(batch_size ~= math.huge, "no players present")
  for _=1,batch_size do
    local batch_successful = false
    for pn=1,max_pn do
      if players_present[pn] then
        local pn_batch_successful = batch_queues[pn]:dequeue()
        batch_successful = batch_successful or pn_batch_successful
      end
    end
    dispatch_batch(batch_successful)
    processed_number_of_batches = processed_number_of_batches + 1
  end
end

local function dispatch_processed_batches()
  if distinguish_player_score then
    dispatch_processed_batches_distinguish()
  else
    dispatch_processed_batches_together()
  end
end

local function check_if_all_notes_processed()
  if processed_number_of_batches >= total_number_of_batches then
    game_over = true
  end
end

local function flush_batches()
  if game_over then return end
  enqueue_judgments()
  dispatch_processed_batches()
  check_if_all_notes_processed()
  note_counter = note_counter + 1
  --Debug.stderr_msg("# of notes", note_counter, "out of", total_numbers_of_notes[default_pn])
end

local function inc_hits(pn)
  if not distinguish_player_score then pn = default_pn end
  current_numbers_of_hits[pn] = current_numbers_of_hits[pn] + 1
end

local function inc_misses(pn)
  if not distinguish_player_score then pn = default_pn end
  current_numbers_of_misses[pn] = current_numbers_of_misses[pn] + 1
end

local function prepare_variables()
  --[[
  Let's describe the variables used in this module in more detail.

  The instruction dispatcher uses a concept of so-called 'batches'.
  A batch is a unit of evaluation. There's a certain number of instructions and notes assigned with a batch.
  Once enough notes have been judged, the batch gets evaluated.
  If the evaluation was successful, the assigned number of instructions will be interpreted as-is,
  otherwise the same amount of random instructions will be interpreted instead.

  The number of batches and associated variables gets determined as follows:
  N .. total_numbers_of_batches
  L .. instruction_per_batch
  R .. notes_per_batch
  K .. min_notes_per_batch

  If the distinguish_player_score flag is true, then the only thing that's different for each player
  is notes_per_batch.
  The values of N and L are the same for each player even if their scores are evaluated separately.

  if distinguish_player_score = true:
    let k\in\mathbb{N} and P_1, P_2, ..., P_k be the active players (the game can handle up to 8 players)
    N := min{ #notes_{P_1} // K, ..., #notes_{P_k}, #instructions }
    R_{P_i} := #notes_{P_i} // N (forall 1 <= i <= k)
    L := #instructions // N
  otherwise:
    the logic is similar except we're only storing all the data to the default_pn player.
  --]]
  distinguish_player_score = should_distinguish_player_score(GAMESTATE:GetCurrentStyle():GetStyleType())
  total_numbers_of_notes = {}
  players_present = {}
  notes_per_batch = {}
  batch_queues = {}
  extra_notes = {}
  current_numbers_of_hits = {}
  current_numbers_of_misses = {}
  total_number_of_batches = total_number_of_instructions
  -- first phase: detect players, count notes for each present player and calculate the number
  --   of batches in case of distinguished scores
  for pn=1,max_pn do
    local player = SCREENMAN:GetTopScreen():GetChild('PlayerP' .. pn)
    if player then
      players_present[pn] = true
      if distinguish_player_score then
        total_numbers_of_notes[pn] = count_notes_from_note_data(player:GetNoteData())
        if total_numbers_of_notes[pn] == 0 then
          error("notefield for player " .. pn .. " is empty")
        end
        total_number_of_batches = math.max(1, math.min(total_number_of_batches,
                                           total_numbers_of_notes[pn] // min_notes_per_batch))
        --Debug.stderr_msg("total number of notes, p", pn, total_numbers_of_notes[pn])
      else
        total_numbers_of_notes[default_pn] =
          (total_numbers_of_notes[default_pn] or 0) + count_notes_from_note_data(player:GetNoteData())
        --Debug.stderr_msg("total number of notes, p", default_pn, total_numbers_of_notes[pn])
      end
    end
  end
  -- second phase: finish calculating the number of batches, create batch queues,
  --  determine note count per batch along with the number of batches with an extra note
  if not distinguish_player_score then
    total_number_of_batches = math.max(1, math.min(total_number_of_batches,
                                       total_numbers_of_notes[default_pn] // min_notes_per_batch))
    batch_queues[default_pn] = Queue:new()
    notes_per_batch[default_pn] = total_numbers_of_notes[default_pn] // total_number_of_batches
    extra_notes[default_pn] = total_numbers_of_notes[default_pn] % total_number_of_batches
    --Debug.stderr_msg("notes per batch", notes_per_batch[default_pn])
    --Debug.stderr_msg("extra notes", extra_notes[default_pn])
    current_numbers_of_hits[default_pn] = 0
    current_numbers_of_misses[default_pn] = 0
  else
    for pn=1,max_pn do
      if players_present[pn] then
        batch_queues[pn] = Queue:new()
        notes_per_batch[pn] = total_numbers_of_notes[pn] // total_number_of_batches
        extra_notes[pn] = total_numbers_of_notes[pn] % total_number_of_batches
        current_numbers_of_hits[pn] = 0
        current_numbers_of_misses[pn] = 0
      end
    end
  end
  -- last phase: assign variables that don't directly depend on the distinguish_player_score variable
  instruction_per_batch = total_number_of_instructions // total_number_of_batches
  --Debug.stderr_msg("instruction_per_batch", instruction_per_batch)
  extra_instruction = total_number_of_instructions % total_number_of_batches
  --Debug.stderr_msg("extra instruction", extra_instruction)
  processed_number_of_batches = 0

  game_over = false
  --Debug.stderr_msg("# of batches:", total_number_of_batches)
  --Debug.stderr_msg("# of instructions:", total_number_of_instructions)
  note_counter = 0
end


local InstructionDispatcher = Def.Actor{
  Name="InstructionDispatcher",
  InitCommand=function(self)
    self:visible(false)
  end,
  InstructionCountMessageCommand=function(_, params)
    total_number_of_instructions = params.number_of_instructions
    prepare_variables()
  end,
}
for pn=1,max_pn do
  InstructionDispatcher["HandleNewHitNoteP"..pn.."Command"] = function()
    inc_hits(pn)
    flush_batches()
  end
  InstructionDispatcher["HandleNewMissedNoteP"..pn.."Command"] = function()
    inc_misses(pn)
    flush_batches()
  end
end

return InstructionDispatcher
