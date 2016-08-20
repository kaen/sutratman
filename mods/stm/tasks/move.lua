local PATH = 1
local TRAVEL = 2
local MAX_BLOCKED_FRAMES = 30
local PATH_WAIT_TIME = 3 * stm.TIME_SCALE
return {
  plan = function(char, state)
    state.distance = state.distance or 1
    state.state = PATH
    char.path_wait = 0
  end,
  perform = function(char, state)
    if state.state == PATH then
      -- couldn't path due to timeout, try again later
      if stm.data.time < char.path_wait then return end

      char.path_wait = stm.data.time + PATH_WAIT_TIME
      if stm.line_of_sight(char.pos, state.dest, stepsize) then
        state.path = { state.dest }
      else
        state.path = char:get_path_to(state.dest)
      end
      state.index = 1
      state.last = char:get_position()
      state.state = TRAVEL
      state.blocked_frames = 0
    elseif state.state == TRAVEL then
      local pos = stm.float_to_node(char:get_position())
      if stm.close_to(state.dest, pos, state.distance) then
        char:stop()
        return true
      end

      -- task fails if we can't get to the destination
      if not state.path then
        -- print()
        -- print('can not path')
        -- stm.dump(char.pos)
        -- stm.dump(state.dest)
        char:stop()
        return false
      end

      -- if the current index is nil then we've got to the end of the path without reaching the destination
      local waypoint = state.path[state.index]
      if not waypoint then return false end

      -- if we've gotten to the current point, move to the next one
      if stm.close_to(waypoint, pos, 1.0) then
        state.index = state.index + 1
      else
        -- move to next point
        char:move_to(waypoint)
      end

      if stm.close_to(state.last, char.pos, 0.1) then
        state.blocked_frames = state.blocked_frames + 1
        if state.blocked_frames > MAX_BLOCKED_FRAMES then
          state.state = PATH
          print('blocked movement detected')
        end
      end

      state.last = stm.float_to_node(char.pos)
    end
  end
}