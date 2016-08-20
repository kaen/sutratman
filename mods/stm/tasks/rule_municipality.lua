local AWAIT_BUILD = 2
local PLAN_ZONES = 3

return {
  plan = function(char, state)
    state.state = AWAIT_BUILD
  end,
  perform = function(char, state)
    local loc = Location.get(state.location)
    if state.state == AWAIT_BUILD then
      if loc:is_complete() then 
        state.state = PLAN_ZONES
      end
    elseif state.state == PLAN_ZONES then

    end
  end
}