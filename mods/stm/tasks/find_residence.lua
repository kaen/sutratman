local BEGIN = 1
local FINISH_CONSTRUCTION = 2
local REQUEST_LOCATION = 3
local AWAIT_RESIDENCE = 6
return {
  plan = function(char, state)
    state.state = BEGIN
  end,
  perform = function(char, state)
    if state.state == BEGIN then
      -- find the closest municipality
      local site = Site.get_closest(char:get_position(), function(x)
        return x.is_municipality
      end)

      if not site then
        -- there's no where to go, better start our own
        char:push_task('establish_municipality')
        state.state = BEGIN
        return
      end

      -- help build the municipality if it is not complete yet
      char.municipality = site.id
      char:push_task('construct_site', { site = site.id })
      state.state = FINISH_CONSTRUCTION

    elseif state.state == FINISH_CONSTRUCTION then
      if char.last_task_result ~= true then return false end
      state.state = REQUEST_LOCATION

    elseif state.state == REQUEST_LOCATION then
      -- when complete, ask for a place to build a home
      local residence = Site.new()
      residence.type = Race.get(char.race).residence_type
      local size = residence:pick_style()
      local found_space = Site.get(char.municipality):request_space(residence, size)
      if not found_space then return false end

      residence:create_initial_build_orders()
      Site.register(residence)
      char.residence = residence.id
      char:push_task('construct_site', { site = residence.id })
      state.state = AWAIT_RESIDENCE

    elseif state.state == AWAIT_RESIDENCE then
      return char.last_task_result
    end
  end
}