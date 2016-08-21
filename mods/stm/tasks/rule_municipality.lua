local AWAIT_BUILD = 2
local PLAN_ZONES = 3

return {
  plan = function(char, state)
    state.state = AWAIT_BUILD
  end,
  perform = function(char, state)
    local site = Site.get(state.site)
    if state.state == AWAIT_BUILD then
      if site:is_complete() then 
        state.state = PLAN_ZONES
      end
    elseif state.state == PLAN_ZONES then

    end
  end
}