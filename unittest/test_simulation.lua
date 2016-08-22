TestSimulation = {}
function TestSimulation:testPopulate()
  Simulation:populate()
  assert(stm.count_pairs(Character.all()) > 5)
end

function TestSimulation:testSimulate()
  local sim_time = 0.1 *24*60*60
  -- TODO: uncomment this line when physics stop being screwy
  -- MapData.get_node = MapData.get_node_mock_wavy

  Simulation.populate()
  Simulation.simulate(sim_time)

  local town = nil
  local plane = nil
  for k,v in pairs(Site.all()) do
    if v.type == 'municipality_human' then town = v end
    if v.type == 'astral_plane' then plane = v end
  end

  assert(plane)
  local town_pos = town:get_position()

  -- there should be at least 5 characters in the world, and all should be
  -- residents of this town
  assert(stm.count_pairs(Character.all()) > 5)
  for k,v in pairs(Character.all()) do
    assertEquals(Race.get(v.race).name, 'human')
    assertEquals(v.municipality, town.id)
    if town.ruler ~= v.id then assert(v.residence) end
  end

  -- the town should have a ruler
  assert(Character.get(town.ruler))

  -- the town should have lots of sub residences
  assert(#town.children > 5)
  local min = vector.new(town_pos.x - 5, town_pos.y, town_pos.z - 5)
  local max = vector.new(town_pos.x + 5, town_pos.y, town_pos.z + 5)

  -- All build orders should be complete
  for k,v in pairs(BuildOrder.all()) do
    assert(v:is_complete())
  end

  -- check that the expected amount of time has passed (within 1 game second)
  assert(math.abs(stm.data.time - sim_time) < 1)
end