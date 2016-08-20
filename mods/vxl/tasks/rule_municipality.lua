local QUEUE_BUILD = 1
local AWAIT_BUILD = 2
local PLAN_ZONES = 3

return {
  plan = function(char, state)
    state.state = QUEUE_BUILD
  end,
  perform = function(char, state)
    local loc = Location.get(state.location)
    if state.state == QUEUE_BUILD then
      local build_fn = function(x,y,z)
        if y >= loc.pos.y then return 'air' end
        return 'default:dirt'
      end

      local order = BuildOrder.create(loc.min, loc.max, build_fn)
      BuildOrder.register(order)
      state.order = order.id

      for k,worker in pairs(loc:get_workers()) do
        worker:push_task("build", { order = order.id })
      end

      state.state = AWAIT_BUILD
    elseif state.state == AWAIT_BUILD then
      if BuildOrder.get(state.order):is_complete() then 
        state.state = PLAN_ZONES
      end
    elseif state.state == PLAN_ZONES then

    end
  end
}