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

  local human_town = nil
  local goblin_town = nil
  local plane = nil
  for k,v in pairs(Site.all()) do
    if v.type == 'municipality_human' then human_town = v end
    if v.type == 'municipality_goblin' then goblin_town = v end
    if v.type == 'astral_plane' then plane = v end
  end

  assert(goblin_town)
  assert(plane)
  local human_town_pos = human_town:get_position()

  -- there should be at least 5 characters in the world, and all should be
  -- residents of this human_town
  assert(stm.count_pairs(Character.all()) > 5)
  for k,v in pairs(Character.all()) do
    assertEquals(Race.get(v.race).name, 'human')
    assertEquals(v.municipality, human_town.id)
    if human_town.ruler ~= v.id then assert(v.residence) end
  end

  -- the human_town should have a ruler
  assert(Character.get(human_town.ruler))

  -- the human_town should have lots of sub residences
  assert(#human_town.children > 5)
  local min = vector.new(human_town_pos.x - 5, human_town_pos.y, human_town_pos.z - 5)
  local max = vector.new(human_town_pos.x + 5, human_town_pos.y, human_town_pos.z + 5)

  -- All build orders should be complete
  for k,v in pairs(BuildOrder.all()) do
    assert(v:is_complete())
  end

  -- check that the expected amount of time has passed (within 1 game second)
  assert(math.abs(stm.data.time - sim_time) < 1)
end
