local MINIMUM_SPACING = 100

local function find_suitable_location(char, state, size)
  local max_variance = size / 2
  local start = MapData.get_surface_pos(MapData.random_point_near(char:get_position(), 10))
  local min = vector.new(start.x - size, start.y, start.z - size)
  local max = vector.new(start.x + size, start.y, start.z + size)
  local variance, y_min, y_max = MapData.get_surface_variance(min, max)

  if variance > max_variance then return nil end

  return start, y_min, y_max
end

return {
  plan = function(char, state)
    -- do nothing, planning is retried in perform
  end,
  perform = function(char, state)
    local size = 15
    local closest = Location.get_closest(char:get_position(), function(x)
        return x.type == Location.TYPE_MUNICIPALITY
    end)

    -- we're too close to another town, so we'll always fail to find a good spot
    if closest and vector.distance(closest:get_position(), char:get_position()) < MINIMUM_SPACING then
      return false
    end

    local pos, y_min, y_max = find_suitable_location(char,state,size)
    if not pos then return end

    -- found a good spot
    local loc = Location.new({ type = Location.TYPE_MUNICIPALITY })
    loc.pos = vector.new(pos.x, y_min, pos.z)
    loc.min = vector.new(pos.x - size, y_min, pos.z - size)
    loc.max = vector.new(pos.x + size, y_max, pos.z + size)
    Location.register(loc)

    -- create initial build orders for this location
    local order = BuildOrder.create(loc.min, loc.max, 'flatland.lua')
    BuildOrder.register(order)
    loc:add_order(order)

    -- assign the founder as the ruler
    loc.ruler = char.id
    char.municipality = loc.id
    char:push_task("rule_municipality", { location = loc.id })
    return true
  end
}