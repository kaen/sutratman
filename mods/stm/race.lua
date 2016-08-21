--- Definition-based objects for modeling race-specific behavior
Race = serializable.define('Race', function()
  return {
    name = "unknown",
    creator = nil
  }
end)

--- Create Race instances from the race definitions
function Race.populate()
  for k, def in pairs(Race.defs) do
    local race = Race.new({name = k})
    Race.register(race)
  end
end

function Race:get_def()
  return Race.defs[self.name]
end

Race.defs = stm.load_directory('races')