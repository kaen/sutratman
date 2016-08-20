WANDER_DISTANCE = 10
MAX_TRIES = 10
return {
  plan = function(char, state)
  end,
  perform = function(char, state)
    local pos = char:get_position()
    local dest = {
      x = pos.x + math.random(-WANDER_DISTANCE, WANDER_DISTANCE),
      y = pos.y + math.random(-WANDER_DISTANCE, WANDER_DISTANCE),
      z = pos.z + math.random(-WANDER_DISTANCE, WANDER_DISTANCE)
    }
    char:push_task('move', { dest = dest })
  end
}