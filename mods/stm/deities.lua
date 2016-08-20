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
  local count = 5 + math.random(5)
  local eden = self:pick_eden()
  local char
  for i=1,count do
    char = Character.new()
    char.pos = MapData.get_surface_pos(MapData.random_point_near(eden, 10))
    char:push_task('wander')
    char:push_task('find_residence')
    Character.register(char)
  end
end

function Deity:pick_eden()
  -- TODO: Pick a spot that the deity in question would actually like
  -- return MapData.get_surface_pos({x=0,y=0,z=0})
  return { x = 0, y = 0, z = 0 }
end

function Deity.populate()
  local count = 1 -- math.random(10)
  for i=1,count do
    local deity = Deity.new()
    Deity.register(deity)
  end
end
