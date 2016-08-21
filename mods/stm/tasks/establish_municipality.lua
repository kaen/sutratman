
return {
  plan = function(char, state)
    -- do nothing, planning is retried in perform
  end,
  perform = function(char, state)
    local closest = Site.get_closest(char:get_position(), function(x)
        return x.is_municipality == true
    end)

    -- we're too close to another town
    if closest and vector.distance(closest:get_position(), char:get_position()) < Parameters.minimum_municipality_distance then
      return false
    end

    local site = Site.new({ type = Race.get(char.race).municipality_type })
    if not site:find_suitable_location(char:get_position()) then
      -- Couldn't find a good spot, return without registering the site
      return
    end

    -- set up the new site and assign the founder as the ruler
    site:create_initial_build_orders()
    site.ruler = char.id
    char.municipality = site.id
    char:push_task("rule_municipality", { site = site.id })
    Site.register(site)
    return true
  end
}