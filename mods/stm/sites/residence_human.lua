local function pick_style(self)
  local schematics = {'house1', 'house2', 'house3'}
  self.style = stm.pick_one(schematics)
  return stm.schematic_size(self.style)
end

local function create_initial_build_orders(self)
  local order = BuildOrder.from_schematic(self.pos, self.style)
  BuildOrder.register(order)
  self:add_order(order)
end

return {
  is_residence = true,
  pick_style = pick_style,
  create_initial_build_orders = create_initial_build_orders
}