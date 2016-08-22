WANDER_DISTANCE = 10
MAX_TRIES = 10
return {
  plan = function(char, state)
  end,
  perform = function(char, state)
    if state.stop and stm.data.time > state.stop then
      return true
    end

    local pos = char:get_position()
    local dest = {
      x = pos.x + math.random(-WANDER_DISTANCE, WANDER_DISTANCE),
      y = pos.y,
      z = pos.z + math.random(-WANDER_DISTANCE, WANDER_DISTANCE)
    }
    char:push_task('move', { dest = MapData.get_surface_pos(dest) })
  end
}