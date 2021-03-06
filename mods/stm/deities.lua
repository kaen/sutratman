local DOMAINS = {
  "Picks",
  "Clouds",
  "Fire",
  "Ice",
  "Life",
  "Death",
  "Misfortune",
  "Luck"
}

 -- "<name> came to this world when he/she <origin story>"
local ORIGIN_STORIES = {
  "was born of the world's collective grief",
  "coalesced from radiated cosmic energies of the heavens",
  "was regurgitated from the depths of hell",
  "has existed since the epoch of all things",
  "was manifested from the spirit of joy",
  "tore asunder the barriers between this plane and that of the gods"
}

Deity = serializable.define('Deity', function()
  return {
    name = "Deity",
    domain = "",
    origin_story = ""
  }
end)


function Deity:describe()
  return self.name .. ", the god of " .. self.domain .. " " .. self.origin_story
end

-- Deities can seed the world with mortals created to manifest their will in
-- the physical realm
function Deity:create_mortals()
  local count = Parameters.minimum_eden_mortals + math.random(Parameters.extra_eden_mortals)
  local eden = self:pick_eden()
  local race = self:pick_race()
  if not race then return end
  race.creator = self.id

  for i=1,count do
    local char = Character.new({ race = race.id })
    char.pos = MapData.get_surface_pos(MapData.random_point_near(eden, 10))
    char:push_task('wander')
    char:push_task('find_residence')
    Character.register(char)
  end
end

--- Find a compatible Race that does not yet have a creator
-- @return a Race instance or nil
function Deity:pick_race()
  for k,v in pairs(Race.all()) do
    if v.creator == nil then return v end
  end
end

function Deity:pick_eden()
  -- TODO: Pick a spot that the deity in question would actually like
  -- return MapData.get_surface_pos({x=0,y=0,z=0})
  local min, max = MapData.get_extents()
  min.x = min.x + Parameters.minimum_municipality_distance
  max.x = max.x - Parameters.minimum_municipality_distance
  min.z = min.z + Parameters.minimum_municipality_distance
  max.z = max.z - Parameters.minimum_municipality_distance
  return { x = math.random(min.x, max.x), y = 0, z = math.random(min.z, max.z) }
end

function Deity.populate()
  local count = Parameters.deity_count
  for i=1,count do
    local deity = Deity.new()
    Deity.register(deity)
  end
end
