--- Models persistent player data
Soul = serializable.define('Soul', function()
  return {
    name = "",
    previous_characters = { },
    current_character = nil
  }
end)

--- Attach a soul to given player (called when players join)
-- Calls find_or_create and moves the player to the appropriate position
function Soul.attach(player)
  local soul = Soul.find_or_create(player)

  -- don't materialize unless we at least have an astral plane
  local astral_plane = Site.get(stm.data.astral_plane)
  if not astral_plane then return soul end

  if soul:get_char() then
    soul:move_to_character()
  else
    soul:confine_to_astral_plane()
  end
  return soul
end

function Soul.on_die_or_respawn(player)
  local soul = Soul.find_or_create(player)
  soul:excarnate()
end

--- Find or a create a Soul instance for this player
-- Always returns the same Soul instance for a given player name
function Soul.find_or_create(player)
  stm.data.souls = stm.data.souls or { }
  local name = player:get_player_name()
  if stm.data.souls[name] then return Soul.get(stm.data.souls[name]) end

  local soul = Soul.new({ name = name })
  Soul.register(soul)
  stm.data.souls[name] = soul.id
  return soul
end

--- Create a new character and spawn the player into the simulation
function Soul:incarnate()
  local race = stm.pick_from_hash(Race.all())
  local site = stm.find_one(Site.all(), function(x) return x.is_municipality end)
  local pos = nil
  if site then pos = site:get_position() end
  local result = Character.new({ soul = self.id, race = race.id, materialized = true, pos = pos })
  self.current_character = result.id
  Character.register(result)
  self:move_to_character()
  -- TODO: set player model to match the new character
  return result
end

--- Kill any existing character for this soul and remove player from simulation
function Soul:excarnate()
  local char = self:get_char()
  if char then
    char:die()
    char.materialized = false
  end
  self:confine_to_astral_plane()
  self.current_character = nil
  -- TODO set player model to an amorphous soul-like thing
  -- TODO move player to astral plane
end

--- Move excarnated souls back to the astral plane if they leave it
function Soul:confine_to_astral_plane()
  local astral_plane = Site.get(stm.data.astral_plane)
  if not astral_plane:contains(self:get_player():getpos()) then
    self:get_player():setpos(astral_plane:get_position())
  end
end

function Soul:move_to_character()
  self:get_player():setpos(self:get_char():get_position())
end

function Soul:simulate(dt)
  if not self.current_character then
    self:confine_to_astral_plane()
  end
end

function Soul:get_char()
  return Character.get(self.current_character)
end

function Soul:get_player()
  return minetest.get_player_by_name(self.name)
end

if minetest and minetest.register_on_joinplayer then
  minetest.register_on_joinplayer(Soul.attach)
  minetest.register_on_dieplayer(Soul.on_die_or_respawn)
  minetest.register_on_respawnplayer(Soul.on_die_or_respawn)
  minetest.register_chatcommand('incarnate', { func = function(name)
    local soul = Soul.attach(minetest.get_player_by_name(name))
    if not soul:get_char() then soul:incarnate() end
  end})
end