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

math.randomseed(os.time())