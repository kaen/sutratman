TestHistory = {}
function TestHistory:testPopulate()
  History:populate()
  assert(stm.count_pairs(Character.all()) > 5)
end

function TestHistory:testSimulate()
  local sim_time = 0.05 *24*60*60
  -- TODO: uncomment this line when physics stop being screwy
  -- MapData.get_node = MapData.get_node_mock_wavy

  History.populate()
  History.simulate(sim_time)

  local town = nil
  for k,v in pairs(Location.all()) do
    if v.type == Location.TYPE_MUNICIPALITY then
      town = v
      break
    end
  end

  local town_pos = town:get_position()

  -- there should be at least 5 characters in the world, and all should be
  -- residents of this town
  assert(stm.count_pairs(Character.all()) > 5)
  for k,v in pairs(Character.all()) do
    assertEquals(v.municipality, town.id)
    if town.ruler ~= v.id then assert(v.residence) end
  end

  -- the town should have a ruler
  assert(Character.get(town.ruler))

  -- the town should have lots of sub residences
  assert(#town.children > 5)
  local min = vector.new(town_pos.x - 5, town_pos.y, town_pos.z - 5)
  local max = vector.new(town_pos.x + 5, town_pos.y, town_pos.z + 5)
  local variance, y_min, y_max = MapData.get_surface_variance(min, max)

  -- All build orders should be complete
  for k,v in pairs(BuildOrder.all()) do
    assert(v:is_complete())
  end

  -- check that the expected amount of time has passed (within 1 game second)
  assert(math.abs(stm.data.time - sim_time) < 1)
end
