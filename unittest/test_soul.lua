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
  assert(subject:get_char() == char)
  assert(char:get_soul() == subject)
  assert(char:get_race().name == 'human')
  assert(char:is_materialized())
  assert(site:contains(char:get_position()))

  subject:excarnate()
  assert(char:is_dead())
  assert(not char:is_materialized())
  assert(not subject:get_char())
end

function TestSoul:testFindOrCreate()
  local player = { get_player_name = function() return 'testplayer' end }

  -- expect it to create a new Soul
  local subject = Soul.find_or_create(player)

  -- call it again and expect to get the same one
  local subject2 = Soul.find_or_create(player)
  assert(subject2 == subject)
  assert(subject.name == 'testplayer')
end