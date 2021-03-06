Site = serializable.define('Site', function()
  return {
    name = "Site",
    pos = { x = 0, y = 0, z = 0 },
    children = { },
    ruler = nil,
    orders = { },
    type = nil
  }
end)

Site.TYPE_MUNICIPALITY = 1
Site.TYPE_RESIDENCE = 2

function Site.get_closest(pos, filter)
  for k,v in pairs(Site.all()) do
    -- TODO actual distance check
    if filter(v) then return v end
  end
  return nil
end

function Site:describe()
  return string.format("%s, a simple %s", self.name, self.race)
end

function Site:get_position()
  return {
    x = self.pos.x,
    y = self.pos.y,
    z = self.pos.z
  }
end

function Site:get_workers()
  local result = { }
  for k,char in pairs(Character.all()) do
    -- all residents except the ruler are workers for now
    -- TODO: hang these IDs on self.workers?
    if char.municipality == self.id and char.id ~= self.ruler then
      table.insert(result, char)
    end
  end
  return result
end

--- Returns true when built and ready for request_space
-- A site is complete when it has no incomplete build orders left
function Site:is_complete()
  return self:get_next_order() == nil
end

--- Add an order to this Site's queue
function Site:add_order(order)
  table.insert(self.orders, order.id)
end

--- Get the next incomplete order to be worked on
-- @return nil or a BuildOrder instance
function Site:get_next_order()
  for _,id in pairs(self.orders) do
    local order = BuildOrder.get(id)
    if order and not order:is_complete() then return order end
  end

  -- nothing found, check our children
  for k,id in pairs(self.children) do
    local child = Site.get(id)
    if child then
      local order = child:get_next_order()
      if order then return order end
    end
  end
end

--- Request space in this site for the given child site
-- If space is found, then the appropriate values for the new location are set
-- for `pos`, `min`, and `max` in `child`. If the function does not return
-- true, `child` is unmodified
-- @param child the child Site instance
-- @param size a vector specifying the space needed
-- @return true when space was found
function Site:request_space(child, size)
  for x = self.min.x,(self.max.x-size.x) do
    for z = self.min.z,(self.max.z-size.z) do
      if self:allocate_space(child, size, x, z) then return true end
    end
  end
end

--- Like `request_space`, but positions are chosen randomly rather than scanned.
function Site:request_space_randomly(child, size)
  local attempts = 0
  while attempts < Parameters.site_request_space_randomly_max_attempts do
    local x = math.random(self.min.x,(self.max.x-size.x))
    local z = math.random(self.min.z,(self.max.z-size.z))
    if self:allocate_space(child, size, x, z) then return true end
    attempts = attempts + 1
  end
end

function Site:allocate_space(child, size, x, z)
  local ok, other
  local min = vector.new(0,self.pos.y,0)
  local max = vector.new(0,self.pos.y + size.y - 1,0)
  min.x = x
  min.z = z
  max.x = x + size.x
  max.z = z + size.z

  ok = true
  for k, id in pairs(self.children) do
    other = Site.get(id)
    if stm.rectangles_overlap(min,max,other.min,other.max) then
      ok = false
      break
    end
  end

  if ok then
    child.pos = vector.new(
      math.floor(min.x + (max.x - min.x)/2),
      self:lowest_nearest_surface_height(min, max),
      math.floor(min.z + (max.z - min.z)/2)
    )
    child.min = min
    child.max = max
    table.insert(self.children, child.id)
    return true
  end
end

function Site:lowest_nearest_surface_height(min, max)
  local lowest = math.huge
  for x=min.x,max.x do
    for z=min.z,max.z do
      lowest = math.min(lowest, self:nearest_surface_height(x,z))
    end
  end
  return lowest
end

function Site:nearest_surface_height(x,z)
  local candidates = MapData.get_all_surface_pos(vector.new(x,self.pos.y,z))
  return stm.closest_to(self.pos, candidates).y
end

function Site:get_def()
  return Site.defs[self.type]
end

-- defer to the site definition
local old_index = Site.__index
Site.__index = function(t,k)
  if old_index[k] then return old_index[k] end
  return t:get_def()[k]
end

function Site:contains(pos)
  return self.min.x <= pos.x and self.max.x >= pos.x and
         self.min.y <= pos.y and self.max.y >= pos.y and
         self.min.z <= pos.z and self.max.z >= pos.z 
end

Site.defs = stm.load_directory('sites')