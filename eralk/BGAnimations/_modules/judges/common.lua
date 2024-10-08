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

function Judge:test_if_robot_is_at_end()
  local robot_row, robot_col = self.robot_state.row, self.robot_state.col
  local end_row, end_col = self.maze.end_cell.row, self.maze.end_cell.col
  local ans = robot_row == end_row and robot_col == end_col
  if not ans then
    self:add_verdict(string.format("robot ended at pos (%d,%d), should have been (%d,%d)",
                                    robot_row, robot_col, end_row, end_col))
  end
  return ans
end


function Judge:test_if_everything_collected()
  local maze = self.maze
  local ans = true
  for row=2,maze.height-1 do
    for col=2,maze.width-1 do
      if maze[row][col]:is_item() then
        if row ~= maze.end_cell.row or col ~= maze.end_cell.col then
          self:add_verdict(string.format("extra item at pos (%d,%d)", row, col))
          ans = false
        end
      end
    end
  end
  return ans
end

function Judge:test_if_inventory_emptied()
  local ans = true
  if self.robot_state.items_collected > 0 then
    self:add_verdict(string.format("extra item%s left in inventory%s",
                                    self.robot_state.items_collected == 1 and "" or "s",
                                    self.robot_state.items_collected == 1 and "" or
                                         " (" .. self.robot_state.items_collected .. ")"
                                    ))
    ans = false
  end
  return ans
end


function Judge:attach_to_interpreter(interpreter)
  local o = {}
  o.interpreter = interpreter
  o.game = o.interpreter.game
  o.maze = o.game.maze
  o.robot_state = o.game.robot_state
  self.__index = self
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
  self.judgment_verdict = ""
end

function Judge:judge_next_command(randomize)
  -- the judge can simply let the next command execute and only start caring after exhausting all instructions
    -- or they can intervene anytime during the user code interpretation
    -- they may also collect relevant statistics here
  self.interpreter:execute_next_command(randomize)
  if self.interpreter.out_of_instructions or self.interpreter.error_encountered then
    self:make_judgment()
    return false
  end
end

return Judge
