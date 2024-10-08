function WriteResult(result)
  local gamedata_path = THEME:GetPathB("", "_gamedata")
  local path = gamedata_path .. "/results.txt"
  local old_contents = File.Read(path)
  Trace("contents:")
  Trace(old_contents)
  File.Write(path, old_contents .. "\n" 
                   .. result.timestamp .. ","
                   .. "\"" .. result.team_name .. "\","
                   .. result.level_cleared .. ","
                   .. result.total_num_of_steps .. ","
                   .. result.played_num_of_steps .. ","
                   .. result.num_of_instructions .. ","
                   .. result.num_of_randomized_instructions)
end

function ConstructStats(pn)
  local Constants = require("engine.constants")
  local team_name_key = Constants.team_name_key
  local verdict_key = Constants.verdict_key
  local total_num_of_steps = Constants.total_num_of_steps
  local played_num_of_steps = Constants.played_num_of_steps
  local num_of_instructions = Constants.num_of_instructions
  local num_of_randomized_instructions = Constants.num_of_randomized_instructions
  return {
    timestamp = Date.Today() .. "_" .. Time.Now(),
    team_name = GAMESTATE:Env()[team_name_key],
    level_cleared = ((GAMESTATE:Env()[verdict_key] or {})[1] and 1 or 0),
    total_num_of_steps = (GAMESTATE:Env()[total_num_of_steps][pn] or 0),
    played_num_of_steps = (GAMESTATE:Env()[played_num_of_steps][pn] or -1),
    num_of_instructions = GAMESTATE:Env()[num_of_instructions],
    num_of_randomized_instructions = GAMESTATE:Env()[num_of_randomized_instructions]
  }
end
