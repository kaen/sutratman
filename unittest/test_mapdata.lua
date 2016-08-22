TestMapData = {}

function TestMapData:testMapGenerationWatchdog()
  -- reset the state to thwart the global mapdata and on_generated mocking
  stm = nil
  minetest = nil
  dofile("mods/stm/init.lua")

  local generated_blocks = fixture('generated_blocks')
  local done = false

  -- register a callback and assert that it has fired
  table.insert(MapData.generation_callbacks, function() done = true end)

  for _, args in ipairs(generated_blocks) do
    MapData.on_generated(args.minp, args.maxp, args.blockseed)
  end
  assert(done)
end

function TestMapData:testMapGenerationWatchdogIncomplete()
  local generated_blocks = fixture('generated_blocks')
  local done = false

  -- register a callback and assert that it has fired
  table.insert(MapData.generation_callbacks, function() done = true end)

  for i, args in ipairs(generated_blocks) do
    -- bail early so the callback is never fired
    if i > (#generated_blocks / 2) then break end
    MapData.on_generated(args.minp, args.maxp, args.blockseed)
  end
  assert(not done)
end

function TestMapData:testXZHash()
  local min, max = MapData.get_extents()
  local index = 1
  for x=min.x,max.x do
    for z=min.z,max.z do
      local result = MapData.xz_hash(x,z)
      assert(index == result)
      index = index + 1
    end
  end
end