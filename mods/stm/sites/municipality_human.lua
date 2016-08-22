local function find_suitable_location(self, hint)
  local size = Parameters.municipality_half_size
  local max_variance = size / 2
  local pos = MapData.get_surface_pos(MapData.random_point_near(hint, 10))
  local min = vector.new(pos.x - size, pos.y, pos.z - size)
  local max = vector.new(pos.x + size, pos.y, pos.z + size)
  -- local variance, y_min, y_max = MapData.get_surface_variance(min, max)

  -- if variance > max_variance then return nil end

  self.pos = vector.new(pos.x, pos.y, pos.z)
  self.min = vector.new(pos.x - size, pos.y - size, pos.z - size)
  self.max = vector.new(pos.x + size, pos.y + size, pos.z + size)
  return true
end

local function prepare_terrain(self)
  local order = BuildOrder.from_generator(self.min, self.max, 'clearcut')
  BuildOrder.register(order)
  self:add_order(order)
end

local function create_initial_build_orders(self)
  local fountain = Site.new()
  fountain.type = 'fountain'
  local found_space = self:request_space_randomly(fountain, stm.schematic_size('fountain'))
  if found_space then
    fountain:create_initial_build_orders()
    Site.register(fountain)
  end

  local temple = Site.new()
  temple.type = 'temple_human'
  local found_space = self:request_space_randomly(temple, stm.schematic_size('temple_human'))
  if found_space then
    temple:create_initial_build_orders()
    Site.register(temple)
  end
end

return {
  is_municipality = true,
  find_suitable_location = find_suitable_location,
  prepare_terrain = prepare_terrain,
  create_initial_build_orders = create_initial_build_orders
}