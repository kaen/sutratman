local function create_initial_build_orders(self)
  local schematics = {'house1', 'house2', 'house3'}
  local order = BuildOrder.from_schematic(self.pos, stm.pick_one(schematics))
  BuildOrder.register(order)
  self:add_order(order)
end

return {
  is_residence = true,
  create_initial_build_orders = create_initial_build_orders
}