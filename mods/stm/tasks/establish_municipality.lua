local ESTABLISH = 1
local PREPARE_TERRAIN = 2
local BUILD = 3

return {
  plan = function(char, state)
    state.state = ESTABLISH
  end,
  perform = function(char, state)
    if state.state == ESTABLISH then
      if char:find_compatible_municipality() then return false end
      local site = Site.get_closest(char:get_position(), function(x)
        return x.is_municipality
      end)

      -- we're too close to another town
      if closest and vector.distance(closest:get_position(), char:get_position()) < Parameters.minimum_municipality_distance then
        return false
      end

      local site = Site.new({ type = Race.get(char.race).municipality_type })
      if not site:find_suitable_location(char:get_position()) then
        -- Couldn't find a good spot, return without registering the site
        -- wander a bit in case we need to try again
        char:push_task('wander', { stop = stm.data.time + Parameters.establish_municipality_wander_time })
        return
      end

      -- set up the new site and assign the founder as the ruler
      site.ruler = char.id
      char.municipality = site.id
      site:prepare_terrain()
      Site.register(site)
      char:push_task('construct_site', { site = site.id })
      state.state = PREPARE_TERRAIN
    elseif state.state == PREPARE_TERRAIN then
      local site = Site.get(char.municipality)
      if site:is_complete() then
        site:create_initial_build_orders()
        char:push_task('construct_site', { site = site.id })
        state.state = BUILD
      end
    elseif state.state == BUILD then
      local site = Site.get(char.municipality)
      if site:is_complete() then
        char:push_task("rule_municipality", { site = site.id })
        return true
      end
    end
  end
}