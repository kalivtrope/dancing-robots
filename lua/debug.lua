local _ENV = _GameEnv
Debug = {}

local debugOn = true


local function msgFromSeq(...)
  local msg = ""
  local useSpaces = false
  for _, v in ipairs({...}) do
    if useSpaces then
      msg = msg .. "  " .. tostring(v)
    else
      msg =  msg .. tostring(v)
      useSpaces = true
    end
  end
  return msg
end


function Debug.screenMsg(...)
  if debugOn then
    SCREENMAN:SystemMessage(msgFromSeq(...))
  end
end

function Debug.logMsg(...)
  if debugOn then
    _G.Trace(msgFromSeq(...))
  end
end


function Debug.logTable(table)
  if debugOn then
    _G.rec_print_table(table)
  end
end
