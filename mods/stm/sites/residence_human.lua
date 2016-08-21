local function create_initial_build_orders(self)
  local order = BuildOrder.create(self.min, self.max, 'house_human.lua')
  BuildOrder.register(order)
  self:add_order(order)
end

return {
  is_residence = true,
  create_initial_build_orders = create_initial_build_orders
}