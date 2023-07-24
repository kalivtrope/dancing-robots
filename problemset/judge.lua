local Judge = {
  judgment_received = false,
  judgment_success = false,
  judgment_verdict = nil,
}
Judge.__index = Judge

function Judge:new(o)
  o = o or {}
  setmetatable(o, self)
  return o
end

function Judge:attach_to_interpreter(interpreter)
  local o = {}
  o.interpreter = interpreter
  setmetatable(o, self)
  return o
end

-- you usually need to override only this class method
function Judge:make_judgment()
  if self.judgment_received then
    return
  end
  self.judgment_received = true
  self.judgment_success = true
  self.judgment_verdict = "judgment verdict"
end

function Judge:judge_next_command()
  -- the judge can simply let the next command execute and only start caring after exhausting all instructions
    -- or they can intervene anytime during the user code interpretation
    -- they may also collect relevant statistics here
  self.interpreter:execute_next_command()
  if self.interpreter.out_of_instructions or self.interpreter.error_encountered then
    self:make_judgment()
    return false
  end
end

return Judge
