-- Simulates a simulation of the world after mapgen
Simulation = { }
function Simulation:populate()
  if not stm.data.simulation then
    Race.populate()
    Deity:populate()

    for k,deity in pairs(Deity.all()) do
      deity:create_mortals()
    end

    stm.data.simulation = { }
  end
end

function Simulation.materialize()
  for _, c in pairs(Character.all()) do
    c:materialize()
  end
end

--- simulates n game seconds of simulation from the current state
-- simulation is done in fixed size chunks equal to `stm.TIME_SCALE / 60`
-- which equates to 1/60 of a real time second at standard scaling.
function Simulation.simulate(n)
  local step = stm.TIME_SCALE / 60
  while n > 0 do
    Simulation.step(step)
    n = n - step
  end
end

function Simulation.game_to_real(t)
  return t / stm.TIME_SCALE
end

function Simulation.real_to_game(t)
  return t * stm.TIME_SCALE
end

--- Perform a single step of length `dt`
-- @param dt number of game seconds to simulate
function Simulation.step(dt)
  stm.data.set_node_queue = { }
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
    Simulation:populate()
    for k,v in pairs(Character.all()) do
      v:materialize()
    end
    print("materialized")
    minetest.register_globalstep(function(dt) Simulation.simulate(Simulation.real_to_game(dt)) end)
  end)
  minetest.after(1, function()
    if stm.data.mapdata_generation_callbacks_fired then
      print('resuming')
      minetest.register_globalstep(function(dt) Simulation.simulate(Simulation.real_to_game(dt)) end)
    end
  end)
end