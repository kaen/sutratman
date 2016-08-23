--- Simple table for setting/getting parameters.
-- This table has metamethods that throw errors when non-existant parameters
-- are accessed.
Parameters = { }

--- When true, characters teleport to destinations immediately
Parameters.fast = true
--- When true, bails out of simulation to keep up with target frame rate
Parameters.skip = true
--- Extract mock data for unit tests when true
Parameters.extract_mock_data = false
--- Half size of the astral plane
Parameters.astral_plane_half_size = 10
--- Number of deities to create
Parameters.deity_count = 3
--- Game seconds to wander when failed to establish municipality
Parameters.establish_municipality_wander_time = 10 * stm.TIME_SCALE
--- Half size of new municipalities (in number of nodes)
Parameters.municipality_half_size = 20
--- Minimum spacing when establishing new municipalities
Parameters.minimum_municipality_distance = 50
--- Minimum number of mortals spawned by a creator deity
Parameters.minimum_eden_mortals = 10
--- Max attempts allowed when randomly choosing a spot for a child site
Parameters.site_request_space_randomly_max_attempts = 20
--- Extra number of mortals that may be spawned by a creator deity
Parameters.extra_eden_mortals = 10

Parameters.__index = function(t,k)
  print("No such parameter: " .. k)
  assert(false)
end

Parameters.__newindex = function(t,k,v)
  print("No such parameter: " .. k)
  assert(false)
end

setmetatable(Parameters, Parameters)