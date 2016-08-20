local BEGIN = 1
local MOVE = 2
local REQUEST_LOCATION = 3
local AWAIT_LOCATION = 4
local ENQUEUE_RESIDENCE = 5
local AWAIT_RESIDENCE = 6
return {
  plan = function(char, state)
    state.state = BEGIN
  end,
  perform = function(char, state)
    if state.state == BEGIN then
      -- find the closest municipality
      local loc = Location.get_closest(char:get_position(), function(x)
        return x.type == Location.TYPE_MUNICIPALITY
      end)

      if not loc then
        -- there's no where to go, better start our own
        char:push_task('establish_municipality')
        state.state = BEGIN
        return
      end

      char.municipality = loc.id
      char:push_task('move', { dest = loc:get_position(), distance = 5 })
      state.state = MOVE

    elseif state.state == MOVE then
      state.state = REQUEST_LOCATION

    elseif state.state == REQUEST_LOCATION then
      -- help build the municipality if it is not complete yet
      local municipality = Location.get(char.municipality)
      if not municipality:is_complete() then
        local order = municipality:get_next_order()
        if order then char:push_task('build_lazily', { order = order.id }) end
        return
      end

      -- when complete, ask for a place to build a home
      local residence = municipality:request_location(7,5,7)
      if not residence then return false end
      residence.type = Location.TYPE_RESIDENCE
      char.residence = residence.id
      char:push_task('move', { dest = residence:get_position() })
      state.state = ENQUEUE_RESIDENCE

    elseif state.state == ENQUEUE_RESIDENCE then
      local residence = Location.get(char.residence)
      local order = BuildOrder.create(residence.min, residence.max, function(x,y,z)
        if x == residence.min.x or x == residence.max.x or
           y == residence.max.y or
           z == residence.min.z or z == residence.max.z
        then
          return "air"
        elseif
           x == residence.min.x+1 or x == residence.max.x-1 or
           y == residence.max.y-1 or
           z == residence.min.z+1 or z == residence.max.z-1
        then
          if x == residence.pos.x and z > residence.pos.z and y <= residence.min.y + 1 then
            return "air"
          end
          return "default:stone"
        end
        return "air"
      end)

      BuildOrder.register(order)
      char:push_task("build_lazily", { order = order.id })
      state.state = AWAIT_RESIDENCE

    elseif state.state == AWAIT_RESIDENCE then
      return char.last_task_result
    end
  end
}