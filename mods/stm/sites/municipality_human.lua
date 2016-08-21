local function find_suitable_location(self, hint)
  local size = Parameters.municipality_half_size
  local max_variance = size / 2
  local pos = MapData.get_surface_pos(MapData.random_point_near(hint, 10))
  local min = vector.new(pos.x - size, pos.y, pos.z - size)
  local max = vector.new(pos.x + size, pos.y, pos.z + size)
  local variance, y_min, y_max = MapData.get_surface_variance(min, max)

  if variance > max_variance then return nil end

  self.pos = vector.new(pos.x, y_min, pos.z)
  self.min = vector.new(pos.x - size, y_min, pos.z - size)
  self.max = vector.new(pos.x + size, y_max, pos.z + size)
  return true
end

local function create_initial_build_orders(self)
  local order = BuildOrder.from_generator(self.min, self.max, 'flatland')
  BuildOrder.register(order)
  self:add_order(order)
end

return {
  is_municipality = true,
  find_suitable_location = find_suitable_location,
  create_initial_build_orders = create_initial_build_orders
}