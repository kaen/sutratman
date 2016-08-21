--- Models persistent player data
Soul = serializable.define('Soul', function()
  return {
    name = "",
    previous_characters = { },
    current_character = nil
  }
end)

function Soul:incarnate()
  local race = stm.pick_from_hash(Race.all())
  local result = Character.new({ soul = self.id, race = race.id })
  Character.register(result)
  return result
end
