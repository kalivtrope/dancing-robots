local Debug = {}

local debug_on = false


local function msg_from_seq(...)
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


function Debug.screen_msg(...)
  if debug_on then
    SCREENMAN:SystemMessage(msg_from_seq(...))
  end
end

function Debug.stderr_msg(...)
  if debug_on then
    print(msg_from_seq(...))
  end
end

function Debug.log_msg(...)
  if debug_on then
    _G.Trace(msg_from_seq(...))
  end
end

function Debug.log_table(table)
  if debug_on then
    _G.rec_print_table(table)
  end
end

return Debug
