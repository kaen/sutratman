--- Models persistent player data
Soul = serializable.define('Soul', function()
  return {
    name = "",
    previous_characters = { },
    current_character = nil
  }
end)

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
  local result = Character.new({ soul = self.id, race = race.id, materialized = true })
  self.current_character = result.id
  Character.register(result)
  -- TODO: set player model to match the new character
  return result
end

--- Kill any existing character for this soul and remove player from simulation
function Soul:excarnate()
  local char = self:get_char()
  self.current_character = nil
  char:die()
  char.materialized = false
  -- TODO set player model to an amorphous soul-like thing
  -- TODO move player to astral plane
end

function Soul:get_char()
  return Character.get(self.current_character)
end

if minetest and minetest.register_on_joinplayer then
  minetest.register_on_joinplayer(Soul.find_or_create)
end