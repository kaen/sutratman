function stm.pick_one(t)
  return t[math.random(#t)]
end

function stm.pick_from_hash(t)
  local keys = { }
  for k,v in pairs(t) do
    table.insert(keys, k)
  end
  local key = keys[math.random(#keys)]
  return t[key]
end

function stm.pick_random_2d_point()
end

function stm.get_uuid()
  stm.data.last_uuid = (stm.data.last_uuid or 0) + 1
  return stm.data.last_uuid
end

function stm.assert(x)
  assert(x)
end

function stm.equals(a,b)
  if type(a) == 'table' and type(b) == 'table' then
    for k,v in pairs(a) do
      if not stm.equals(a[k],b[k]) then return false end
    end
    return true
  end
  return a == b
end

function stm.close_to(a,b,dist)
  return (math.abs(a.x - b.x) <= dist) and (math.abs(a.y - b.y) <= dist) and (math.abs(a.z - b.z) <= dist)
end

function stm.clone(x)
  local result = { }
  for k,v in pairs(x) do
    if type(v) == 'table' then
      result[k] = stm.clone(v)
    else
      result[k] = v
    end
  end
  return result
end

function stm.dump(x, depth)
  local result = { }
  local depth = depth or 0
  local i, padding
  for k,v in pairs(x) do
    padding = ""
    for i=1,depth do
      padding = padding .. "  "
    end
    if type(v) == 'table' then
      print(padding .. k)
      stm.dump(v, depth + 1)
    else
      print(padding .. k, v)
    end
  end
end

--- Returns the vector in haystack with the shortest distance to needle
function stm.closest_to(needle, haystack)
  local best_dist = math.huge
  local best = nil
  for k,v in pairs(haystack) do
    local dist = vector.distance_squared(needle, v)
    if dist < best_dist then
      best_dist = dist
      best = v
    end
  end
  return best
end

-- obviously assumes AABB pairs, ignores y coordinates
function stm.rectangles_overlap(min1,max1,min2,max2)
  if min1.x > max2.x or min2.x > max1.x then return false end
  if min1.z > max2.z or min2.z > max1.z then return false end
  return true
end

function stm.float_to_node(p)
  local x, y, z
  if p.x > 0 then
    x = math.floor(p.x+0.5)
  else
    x = math.ceil(p.x-0.5)
  end
  if p.y > 0 then
    y = math.floor(p.y+0.5)
  else
    y = math.ceil(p.y-0.5)
  end
  if p.z > 0 then
    z = math.floor(p.z+0.5)
  else
    z = math.ceil(p.z-0.5)
  end
  return vector.new(x,y,z)
end

function stm.is_solid(node)
  if not node then return true end
  if node.name == 'air' then return false end
  if node.name == 'ignore' then return true end
  if minetest.registered_nodes[node.name].walkable == nil then return true end
  return minetest.registered_nodes[node.name].walkable
end

function stm.line_of_sight(a, b)
  if minetest and minetest.line_of_sight then
    return minetest.line_of_sight(a,b)
  else
    local step = 1.0
    local dist = vector.distance(a,b)
    local dir = vector.direction(a,b)
    for t = 0,dist,step do
      local cursor = vector.add(a, vector.multiply(dir, t))
      local node = MapData.get_node(cursor)
      if cursor and cursor.name ~= 'air' then return false end
    end
    return true
  end
end

function stm.count_pairs(t)
  local result = 0
  for k,v in pairs(t) do
    result = result + 1
  end
  return result
end

--- Iterates over all integer positions between `a` and `b`, applying `fn`
-- @param a min extents of the aabb
-- @param b max extents of the aabb
-- @param fn callback function taking arguments `(x,y,z)` and returning a string
-- @return an array of tables where each element has the form `{ pos = <vector>, name = <result for that position> }`
function stm.walk_aabb(a,b,fn)
  local result = { }
  for x = math.min(a.x,b.x),math.max(a.x,b.x),1 do
    for y = math.min(a.y,b.y),math.max(a.y,b.y),1 do
      for z = math.min(a.z,b.z),math.max(a.z,b.z),1 do
        local name = fn(x,y,z)
        if name then
          local pos = vector.new(x,y,z)
          result[stm.pos_to_int(pos)] = { name = name }
        end
      end
    end
  end
  return result
end

function stm.load_directory(dir)
  local path = 'mods/stm/'
  if _G.minetest then
    path = minetest.get_modpath("stm") .. "/"
  end
  path = path .. dir .. '/'
  local list = io.popen('ls -1 ' .. path)
  local basename
  local result = { }
  for name in function() return list:read() end do
    basename = string.gsub(name, '.lua', '')
    result[basename] = dofile(path .. name)
  end
  return result
end

function stm.get_blueprint_data(a, b, name)
  local min = vector.new(math.min(a.x, b.x), math.min(a.y,b.y), math.min(a.z,b.z))
  local max = vector.new(math.max(a.x, b.x), math.max(a.y,b.y), math.max(a.z,b.z))
  local base = vector.new(
    math.floor(min.x + (max.x - min.x) / 2),
    math.floor(min.y + (max.y - min.y) / 2),
    math.floor(min.z + (max.z - min.z) / 2)
  )
  local data = {
    base = base,
    size = vector.subtract(max, min),
    nodes = { }
  }
  for x=min.x,max.x do
    for y=min.y,max.y do
      for z=min.z,max.z do
        local pos = vector.new(x,y,z)
        local node = minetest.get_node(pos)
        table.insert(data.nodes, { pos = vector.subtract(pos, base), node = node })
      end
    end
  end
  return data
end

function stm.schematic_size(name)
  local s = dofile(stm.base_path .. "/schematics/" .. name .. ".lua")
  return s.size
end

local min_value = -math.floor(0xFFFF/2)
local bit_spacing = 0x10000
function stm.pos_to_int(pos)
  return (pos.z - min_value) * bit_spacing * bit_spacing +
    (pos.y - min_value) * bit_spacing +
    (pos.x - min_value)
end

function stm.int_to_pos(i)
  local pos = vector.new(0,0,0)
  local raw = nil
  raw = math.floor(i / (bit_spacing * bit_spacing))
  i = i - raw * bit_spacing * bit_spacing
  pos.z = raw + min_value

  raw = math.floor(i / bit_spacing)
  i = i - raw * bit_spacing
  pos.y = raw + min_value

  pos.x = i + min_value
  return pos;
end

--- Return the first element (v) of `t` for which `f(v, k)` returns true
function stm.find_one(t, f)
  for k,v in pairs(t) do
    if f(v, k) then return v end
  end
end

if minetest then
  stm.base_path = minetest.get_modpath('stm')
else
  stm.base_path = './mods/stm/'
end
