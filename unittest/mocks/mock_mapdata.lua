function MapData.walk_voxels_mock(min, max, fn)
  local x, y, z, data
  for x=min.x,max.x do
    for y=min.y,max.y do
      for z=min.z,max.z do
        data = MapData.get_node(vector.new(x,y,z))
        fn({x = x, y = y, z = z}, data.name, data.cid)
      end
    end
  end
end

local mock_node_defs = nil
MapData.mock_node_group_cache = { }
function MapData.get_node_group_mock(name, group)
  if MapData.mock_node_group_cache[name] and MapData.mock_node_group_cache[name][group] then
    return MapData.mock_node_group_cache[name][group]
  end

  if not mock_node_defs then
    mock_node_defs = fixture('node_defs')
  end

  local result = mock_node_defs[name].groups[group] or 0
  MapData.mock_node_group_cache[name] = MapData.mock_node_group_cache[name] or {}
  MapData.mock_node_group_cache[name][group] = result
  return result
end

MapData.mock_data = { }
function MapData.set_node_mock(pos, node)
  MapData.mock_data[pos_to_int(pos)] = node
end

function MapData.get_node_mock(pos)
  local cached = MapData.mock_data[pos_to_int(pos)]
  if cached then return cached end

  local height = pos.y -- math.floor(pos.y + math.floor(math.sin(pos.x/2) + math.cos(pos.z/2)))
  if height > 0 then return { name = "air" } end
  if height == 0 then return { name = "default:dirt" } end
  return { name = "default:stone" }
end

function MapData.get_node_mock_wavy(pos)
  local cached = MapData.mock_data[pos_to_int(pos)]
  if cached then return cached end

  local height = math.floor(pos.y + math.floor(math.sin(pos.x/2) + math.cos(pos.z/2)))
  if height > 0 then return { name = "air" } end
  if height == 0 then return { name = "default:dirt" } end
  return { name = "default:stone" }
end

function MapData.emerge_area(min,max)
  -- do nothing
end

minetest = minetest or { }
minetest.registered_nodes = fixture('registered_nodes')

-- inject fake map data
local generated_blocks = fixture('generated_blocks')
for _, args in ipairs(generated_blocks) do
  MapData.on_generated(args.minp, args.maxp, args.blockseed)
end

MapData.walk_voxels = MapData.walk_voxels_mock
MapData.get_node_group = MapData.get_node_group_mock
MapData.get_node = MapData.get_node_mock
MapData.set_node = MapData.set_node_mock