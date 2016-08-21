--- Simple table for setting/getting parameters.
-- This table has metamethods that throw errors when non-existant parameters
-- are accessed.
Parameters = { }

--- Half size of the astral plane
Parameters.astral_plane_half_size = 10
--- Number of deities to create
Parameters.deity_count = 1
--- Half size of new municipalities (in number of nodes)
Parameters.municipality_half_size = 15
--- Minimum spacing when establishing new municipalities
Parameters.minimum_municipality_distance = 100
--- Minimum number of mortals spawned by a creator deity
Parameters.minimum_eden_mortals = 5
--- Extra number of mortals that may be spawned by a creator deity
Parameters.extra_eden_mortals = 5

Parameters.__index = function(t,k)
  print("No such parameter: " .. k)
  assert(false)
end

Parameters.__newindex = function(t,k,v)
  print("No such parameter: " .. k)
  assert(false)
end

setmetatable(Parameters, Parameters)