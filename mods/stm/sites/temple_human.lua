local function create_initial_build_orders(self)
  local order = BuildOrder.from_schematic(self.pos, 'temple_human')
  BuildOrder.register(order)
  self:add_order(order)
end

return {
  create_initial_build_orders = create_initial_build_orders
}