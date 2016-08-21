TestSoul = {}
function TestSoul:testReincarnation()
  local subject = Soul.new()
  Soul.register(subject)

  History.populate()

  -- create a home for the characters
  local site = Site.new({type = 'municipality_human'})
  Site.register(site)
  site.pos = vector.new(0,0,0)
  site.min = vector.new(-10,0,-10)
  site.max = vector.new(10,0,10)

  -- assert that we create a character when incarnated
  local char = subject:incarnate()
  assert(char:get_soul() == subject)
  assert(char:get_race().name == 'human')
  assert(site:contains(char:get_position()))
end
