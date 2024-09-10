function ListTeamConfigurations()
  local Constants = require("engine.constants")
  local input_path = Constants.input_path
  local output_path = Constants.output_path
  local team_name_key = Constants.team_name_key
  local team_config_key = Constants.team_config_key

  local function fetch_valid_configurations()
    local team_name = GAMESTATE:Env()[team_name_key] or ""
    local inputs = FILEMAN:GetDirListing(input_path .. "/" .. team_name .. "_*.in")
    local outputs = FILEMAN:GetDirListing(output_path .. "/" .. team_name .. "_*.out")

    -- fallback, hopefully shouldn't be needed
    if #inputs == 0 or #outputs == 0 then
      inputs = FILEMAN:GetDirListing(input_path .. "/*.in")
      outputs = FILEMAN:GetDirListing(output_path .. "/*.out")
      local input_set = {}
      for _,v in ipairs(inputs) do
        input_set[ string.gsub(v, "%.in$", "") ] = true
      end
      local output_list = {}
      for _,v in ipairs(outputs) do
        local stripped = string.gsub(v, "%.out$", "")
        if input_set[stripped] then
          output_list[#output_list + 1] = stripped
        end
      end
      return output_list
    end

    local input_set = {}
    for _,v in ipairs(inputs) do
      input_set[ string.gsub(string.gsub(v, "%.in$", ""), "^" .. team_name .. "_", "") ] = true
    end
    local output_list = {}
    for _,v in ipairs(outputs) do
      local stripped = string.gsub(string.gsub(v, "%.out$", ""), "^" .. team_name .. "_", "")
      if input_set[stripped] then
        output_list[#output_list + 1] = stripped
      end
    end
    return output_list
  end
  return {
    Name="TeamConfig",
    GoToFirstOnStart=true,
    OneChoiceForAllPlayers=true,
    ExportOnChange=true,
    LayoutType="ShowAllInRow",
    SelectType="SelectOne",
    LoadSelections= function(self, list, pn)
      -- good ol' wildcards (had to read the SM source code to figure this out)
      -- see src/RageFileManager.cpp and src/RageUtil_FileDB.cpp for more information
      local curr_config = GAMESTATE:Env()[team_config_key] or ""
      local key = FindValue(self.Choices, curr_config)
      if key then
        list[key] = true
      else
        list[1] = true
      end
    end,
    SaveSelections= function(self, list, pn)
      for i, choice in ipairs(self.Choices) do
        if list[i] then
          GAMESTATE:Env()[team_config_key] = choice
        end
      end
    end,
    Choices=fetch_valid_configurations(),
    Reload=function(self)
      GAMESTATE:Env()[team_config_key] = nil
      self.Choices = fetch_valid_configurations()
      return "ReloadChanged_All"
    end,
    ReloadRowMessages={"ReloadTeamConfig"}
  }
end
