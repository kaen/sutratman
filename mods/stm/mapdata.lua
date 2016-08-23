stm.MAP_BLOCK_SIZE = 80
stm.XSIZE = stm.MAP_BLOCK_SIZE * 2
stm.YSIZE = stm.MAP_BLOCK_SIZE * 1
stm.ZSIZE = stm.MAP_BLOCK_SIZE * 2

stm.data.mapdata_block_offset = nil
stm.data.mapdata_expected_blocks = stm.XSIZE * stm.YSIZE * stm.ZSIZE * 8 / math.pow(stm.MAP_BLOCK_SIZE, 3)
stm.data.mapdata_generated_blocks = 0
stm.data.mapdata_generation_callbacks_fired = false
stm.data.mapdata_heightmap = { }

MapData = { }
MapData.generation_callbacks = { }
function MapData.get_surface_pos(p)
  local pos = stm.float_to_node(p)
  local i = MapData.xz_hash(pos.x,pos.z)
  local y = stm.data.mapdata_heightmap[i] + 1
  local min, max = MapData.get_extents()
  y = math.max(min.y, math.min(max.y, y))
  return vector.new(pos.x,y,pos.z)
  -- local nearby_air_pos, crumbly_rating = nil
  -- local min_extent, max_extent = MapData.get_extents()
  -- local min = vector.new(p.x,min_extent.y,p.z)
  -- local max = vector.new(p.x,max_extent.y,p.z)
  -- local best_pos = {
  --   x = -30000,
  --   y = -30000,
  --   z = -30000
  -- }

  -- local fn = function(pos, name, cid)
  --   if pos.y > best_pos.y then
  --     if stm.is_solid({ name = name, cid = cid }) then
  --       local node_above = MapData.get_node(vector.new(pos.x, pos.y+1, pos.z))
  --       if not stm.is_solid(node_above) then
  --         best_pos = pos
  --       end
  --     end
  --   end
  -- end

  -- MapData.walk_voxels(min, max, fn)
  -- best_pos.y = best_pos.y + 1

  -- return best_pos
end

function MapData.get_all_surface_pos(p)
  return { MapData.get_surface_pos(p) }
  -- local min_extent, max_extent = MapData.get_extents()
  -- local min = vector.new(p.x,min_extent.y,p.z)
  -- local max = vector.new(p.x,max_extent.y,p.z)
  -- local results = { }

  -- local fn = function(pos, name, cid)
  --   if stm.is_solid({ name = name, cid = cid }) then
  --     local node_above = MapData.get_node(vector.new(pos.x, pos.y+1, pos.z))
  --     if not stm.is_solid(node_above) then
  --       table.insert(results, vector.new(pos.x, pos.y + 1, pos.z))
  --     end
  --   end
  -- end

  -- MapData.walk_voxels(min, max, fn)
  -- return results
end


-- fn is a callback taking arguments (pos, name, cid)
function MapData.walk_voxels(min, max, fn)
  local node, pos, cid = nil
  local vm = minetest.get_voxel_manip(min, max)
  local emin, emax = vm:read_from_map(min, max)
  -- print('emin/max')
  -- print(minetest.pos_to_string(emin), minetest.pos_to_string(emax))
  local va = VoxelArea:new({MinEdge = emin, MaxEdge = emax})
  local data = vm:get_data()
  local name
  local best_pos = {
    x = -math.huge,
    y = -math.huge,
    z = -math.huge
  }

  for index in va:iterp(min, max) do
    cid = data[index]
    pos = va:position(index)
    -- print(index, minetest.pos_to_string(pos), cid)

    if cid and index > 0 then
      name = minetest.get_name_from_content_id(cid)
      -- print(name)
      fn(pos, name, cid)
    end
  end

  return best_pos
end


function MapData.find_node_near(pos, r, spec)
  local min = { x = pos.x - r, y = pos.y - r, z = pos.z - r }
  local max = { x = pos.x + r, y = pos.y + r, z = pos.z + r }
  local match = nil
  local group = nil
  local fn = function(pos, name, cid)
    for _, s in ipairs(spec) do
      if string.find(s, 'group:') == 1 then
        group = string.sub(s,7,#s)
        if MapData.get_node_group(name, group) > 0 then
          match = pos
          break
        end
      elseif name == s then
        match = pos
        break
      end
    end
  end
  MapData.walk_voxels(min, max, fn)
  return match
end

function MapData.get_node_group(name, group)
  return minetest.get_node_group(name, group)
end

function MapData.get_node(pos)
  local node = minetest.get_node(pos)
  if node.name == "ignore" then
    minetest.get_voxel_manip():read_from_map(pos, pos)
    node = minetest.get_node(pos)
  end
  return node
end

function MapData.set_node(pos, node)
  MapData.set_node_raw(pos, node)
end

function MapData.set_node_raw(pos, node)
  minetest.set_node(pos, node)
end

function pos_to_int(pos)
  return math.floor(pos.z-0.5) * 0x1000000 + math.floor(pos.y-0.5) * 0x1000 + math.floor(pos.x-0.5)
end


function MapData.random_point_near(pos, r)
  return vector.new(pos.x + math.random(-r,r), pos.y + math.random(-r,r), pos.z + math.random(-r,r))
end

function MapData.get_surface_variance(min, max)
  local y_min = math.huge
  local y_max = -math.huge
  local cursor, pos, x, z

  -- find the min/max height of surface nodes for this area
  local cursor = vector.new(0,0,0)
  for x=min.x,max.x do
    for z=min.z,max.z do
      cursor.x = x
      cursor.z = z
      pos = MapData.get_surface_pos(cursor)

      if pos then
        y_min = math.min(y_min, pos.y)
        y_max = math.max(y_max, pos.y)
      end
    end
  end

  return math.abs(y_max - y_min), y_min, y_max
end

function MapData.get_extents()
  local offset = stm.data.mapdata_block_offset
  local min = {
    x = -stm.XSIZE + offset.x,
    y = -stm.YSIZE + offset.y,
    z = -stm.ZSIZE + offset.z
  }

  local max = {
    x = stm.XSIZE + offset.x,
    y = stm.YSIZE + offset.y,
    z = stm.ZSIZE + offset.z
  }

  return min, max
end

function MapData.emerge_area(min, max)
  minetest.emerge_area(min, max)
end

--- Maps x,z to an integer value between 1 and xsize*zsize
-- Used for indexing 2D map data tables, using this consecutive integer hash
-- method causes lua to store the underlying table as a contiguous array in
-- memory (rather than a sparse hash table), making access much faster.
function MapData.xz_hash(x,z)
  local min, max = MapData.get_extents()
  local zsize = max.z - min.z + 1
  assert(x >= min.x)
  assert(x <= max.x)
  assert(z >= min.z)
  assert(z <= max.z)
  x = x - min.x
  z = z - min.z
  return x * zsize + z + 1
end

local collected_block_data = { }
function MapData.on_generated(minp, maxp, blockseed)
  if type(stm.data.mapdata_block_offset) ~= 'table' then
    stm.data.mapdata_block_offset = {
      x = minp.x % 80,
      y = minp.y % 80,
      z = minp.z % 80
    }
  end

  local min_extent, max_extent = MapData.get_extents()
  MapData.emerge_area(min_extent, max_extent)
  if minp.x >= min_extent.x and
     maxp.x <= max_extent.x and
     minp.y >= min_extent.y and
     maxp.y <= max_extent.y and
     minp.z >= min_extent.z and
     maxp.z <= max_extent.z
  then
    local heightmap = minetest.get_mapgen_object("heightmap")
    local index = stm.pos_to_int(stm.float_to_node(vector.midpoint(minp, maxp)))
    local heightmap_index = 1
    if heightmap then
      for z=minp.z,maxp.z do
        for x=minp.x,maxp.x do
          -- hashes collide from map blocks at different y levels, but we always
          -- take the highest surface
          local i = MapData.xz_hash(x,z)
          local old_value = stm.data.mapdata_heightmap[i] or -math.huge
          stm.data.mapdata_heightmap[i] = math.max(old_value, heightmap[heightmap_index])
          heightmap_index = heightmap_index + 1
        end
      end
    end
    if Parameters.extract_mock_data then
      table.insert(collected_block_data, { minp = minp, maxp = maxp, blockseed = blockseed, heightmap = heightmap })
    end
    stm.data.mapdata_generated_blocks = 1 + stm.data.mapdata_generated_blocks
    -- print("blocks generated:", stm.data.mapdata_generated_blocks, stm.data.mapdata_expected_blocks)
  end

  if stm.data.mapdata_generated_blocks == stm.data.mapdata_expected_blocks and not stm.data.mapdata_generation_callbacks_fired then
    stm.data.mapdata_generation_callbacks_fired = true
    minetest.after(1,function()
      for _, callback in ipairs(MapData.generation_callbacks) do
        callback()
      end
    end)
    if Parameters.extract_mock_data then
      table.insert(collected_block_data, { minp = minp, maxp = maxp, blockseed = blockseed, heightmap = heightmap })
      stm.write_file('generated_blocks.lua', minetest.serialize(collected_block_data))
    end
  end
end

function MapData.dump_registered_nodes()
  file = io.open('registered_nodes.lua', "w")
  if file then
    file:write(minetest.serialize(minetest.registered_nodes))
    io.close(file)
  end
end

function MapData.pos_to_block(pos)
  local min, max = MapData.get_extents()
  local x = math.floor((pos.x - min.x)/ 16)
  local y = math.floor((pos.y - min.y)/ 16)
  local z = math.floor((pos.z - min.z)/ 16)
  return vector.new(x,y,z)
end

if minetest then
  minetest.register_on_generated(MapData.on_generated)
  minetest.after(0, MapData.dump_registered_nodes)
end
