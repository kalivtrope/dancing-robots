function ListTeamNames()
  local Constants = require("engine.constants")
  local input_path = Constants.input_path
  local output_path = Constants.output_path
  local team_name_key = Constants.team_name_key

  local function fetch_team_names()
    local inputs = FILEMAN:GetDirListing(input_path .. "/*.in")
    local outputs = FILEMAN:GetDirListing(output_path .. "/*.out")
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
    local team_names = {}
    for _,v in ipairs(output_list) do
      local stripped = string.gsub(v, "_.*$", "")
      team_names[stripped] = true
    end
    local res = {}
    for k in pairs(team_names) do
      res[#res + 1] = k
    end
    table.sort(res)
    return res
  end
  return {
    Name="TeamNames",
    GoToFirstOnStart=true,
    OneChoiceForAllPlayers=true,
    ExportOnChange=true,
    LayoutType="ShowAllInRow",
    SelectType="SelectOne",
    LoadSelections= function(self, list, pn)
      local curr_config = GAMESTATE:Env()[team_name_key] or ""
      local key = FindValue(self.Choices, curr_config)
      if key then
        list[key] = true
      else
        list[1] = true
        GAMESTATE:Env()[team_name_key] = self.Choices[1]
        MESSAGEMAN:Broadcast("ReloadTeamConfig")
      end
    end,
    SaveSelections=function(self, list, pn)
      for i, choice in ipairs(self.Choices) do
        if list[i] then
          GAMESTATE:Env()[team_name_key] = choice
          MESSAGEMAN:Broadcast("ReloadTeamConfig")
        end
      end
    end,
    Choices=fetch_team_names(),
  }
end
