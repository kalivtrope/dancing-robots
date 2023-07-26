local Judge = {
  judgment_received = false,
  judgment_success = true,
  judgment_verdict = nil,
  interpreter = nil,
  game = nil,
  maze = nil,
  robot_state = nil,
}
Judge.__index = Judge

function Judge:new(o)
  o = o or {}
  setmetatable(o, self)
  return o
end

function Judge:add_verdict(msg)
  self.judgment_verdict = (self.judgment_verdict or "") .. msg .. "\n"
end

function Judge:add_judgment(flag)
  self.judgment_success = self.judgment_success and flag
end

function Judge:test_if_robot_survived()
  if self.interpreter.error_encountered then
    self:add_verdict("robot crashed into a wall")
    return false
  end
  return true
end

function Judge:test_if_robot_is_at_end()
  local robot_x, robot_y = self.robot_state.x, self.robot_state.y
  local end_x, end_y = self.maze.end_cell.x, self.maze.end_cell.y
  local ans = robot_x == end_x and robot_y == end_y
  if not ans then
    self:add_verdict(string.format("robot ended at pos (%d,%d), should have been (%d,%d)",
                                    robot_x, robot_y, end_x, end_y))
  end
  return ans
end

function Judge:attach_to_interpreter(interpreter)
  local o = {}
  o.interpreter = interpreter
  o.game = o.interpreter.game
  o.maze = o.game.maze
  o.robot_state = o.game.robot_state
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
