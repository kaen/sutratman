TestSoul = {}
function TestSoul:testReincarnation()
  local subject = Soul.new()
  subject:get_player():setpos(vector.new(0,0,0))
  Soul.register(subject)

  Simulation.populate()

  -- create a home for the characters
  local site = Site.new({type = 'municipality_human'})
  Site.register(site)
  site.pos = vector.new(0,0,0)
  site.min = vector.new(-10,0,-10)
  site.max = vector.new(10,0,10)

  local astral_plane = Site.get(stm.data.astral_plane)
  -- assert that we create a character when incarnated
  local char = subject:incarnate()
  assert(subject:get_char() == char)
  assert(char:get_soul() == subject)
  assert(char:get_race().name == 'human')
  assert(char:is_materialized())
  assert(site:contains(char:get_position()))

  -- expected conditions when soul is excarnated
  subject:excarnate()
  assert(char:is_dead())
  assert(not char:is_materialized())
  assert(not subject:get_char())
  assert(astral_plane:contains(subject:get_player():getpos()))

  -- excarnated souls can not leave the astral plane
  subject:get_player():setpos(vector.new(0,0,0))
  assert(not astral_plane:contains(subject:get_player():getpos()))
  subject:confine_to_astral_plane()
  assert(astral_plane:contains(subject:get_player():getpos()))

  -- but you can move around the plane freely
  local ok_pos = astral_plane:get_position()
  ok_pos.y = ok_pos.y + 1
  ok_pos.z = ok_pos.z - 1
  ok_pos.x = ok_pos.x - 1
  subject:get_player():setpos(ok_pos)
  subject:confine_to_astral_plane()
  assert(vector.distance(subject:get_player():getpos(), ok_pos) < 0.01)
end

function TestSoul:testFindOrCreate()
  -- This function is mocked, so we're just retrieving our mock ahead of time
  local player = Soul.get_player()

  -- expect it to create a new Soul
  local subject = Soul.find_or_create(player)

  -- call it again and expect to get the same one
  local subject2 = Soul.find_or_create(player)
  assert(subject2 == subject)
  assert(subject.name == 'testplayer')
end

function TestSoul:testAttach()
  Simulation.populate()

  -- This function is mocked, so we're just retrieving our mock ahead of time
  local player = Soul.get_player()

  local astral_plane = Site.get(stm.data.astral_plane)
  local subject = Soul.attach(player)
  local subject2 = Soul.attach(player)
  local char = subject:incarnate()
  assert(subject2 == subject)
  assert(subject.name == 'testplayer')

  -- move the player away, then attach and assert player is at character position
  player:setpos(vector.new(10,10,10))
  assert(vector.distance(player:getpos(), char:get_position()) > 0.01)
  Soul.attach(player)
  assert(vector.distance(player:getpos(), char:get_position()) < 0.01)
  assert(not astral_plane:contains(subject:get_player():getpos()))

  -- die, become excarnated and go to the astral plane
  char:die()
  assert(subject:get_char() == nil)
  assert(astral_plane:contains(subject:get_player():getpos()))
  player:setpos(vector.new(10,10,10))
  assert(vector.distance(player:getpos(), astral_plane:get_position()) > 0.01)
  Soul.attach(player)
  assert(vector.distance(player:getpos(), astral_plane:get_position()) < 0.01)
end


function TestSoul:testAttachNoAstralPlane()
  -- This function is mocked, so we're just retrieving our mock ahead of time
  local player = Soul.get_player()
  local subject = Soul.attach(player)
  assert(subject.name == 'testplayer')

  Simulation.populate()

  local char = subject:incarnate()
  assert(subject:get_char() == char)
  assert(char:get_soul() == subject)
  assert(char:get_race().name == 'human')
  assert(char:is_materialized())
end