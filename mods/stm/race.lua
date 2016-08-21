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

-- defer to the race definition
local old_index = Race.__index
Race.__index = function(t,k)
  if old_index[k] then return old_index[k] end
  return t:get_def()[k]
end

Race.defs = stm.load_directory('races')