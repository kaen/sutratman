-- Simulates a history of the world after mapgen
History = { }
function History:populate()
  if not stm.data.history then
    Deity:populate()

    for k,deity in pairs(Deity.all()) do
      deity:create_mortals()
    end

    stm.data.history = { }
  end
end

function History.materialize()
  for _, c in pairs(Character.all()) do
    c:materialize()
  end
end

-- simulates n days of history from the current state
function History.simulate(n)
  local secondsLeft = History.game_to_real(n*24*60*60)

  -- in general we want to simulate 1/60 of a second in real time
  local step = 1/60

  while secondsLeft > 0 do
    History.step(step)
    secondsLeft = secondsLeft - step
  end
end

function History.game_to_real(t)
  return t / stm.TIME_SCALE
end

function History.real_to_game(t)
  return t * stm.TIME_SCALE
end

function History.step(dt)
  stm.data.set_node_queue = { }
  -- convert dt from standard real time to game time
  dt = dt * stm.TIME_SCALE
  stm.data.time = stm.data.time + dt

  for k,char in pairs(Character.all()) do
    char:simulate(dt)
  end

  for k,v in pairs(stm.data.set_node_queue) do
    MapData.set_node(v.pos, v.node)
  end
end

if minetest then
  table.insert(MapData.generation_callbacks, function()
    History:populate()
    for k,v in pairs(Character.all()) do
      v:materialize()
    end
    print("materialized")
    minetest.register_globalstep(History.step)
  end)
end