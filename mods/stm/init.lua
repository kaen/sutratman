local SOURCES = {
  'profi.lua',
  'serializable.lua',
  'vector.lua',
  'data.lua',
  'util.lua',
  'parameters.lua',
  'mapdata.lua',
  'race.lua',
  'character.lua',
  'soul.lua',
  'build_order.lua',
  'task.lua',
  'site.lua',
  'deities.lua',
  'simulation.lua',
  'misc_helpers.lua'
}

for _, name in ipairs(SOURCES) do
  if minetest then
    dofile(minetest.get_modpath('stm') .. "/" .. name)
  else
    dofile('./mods/stm/' .. name)
  end
end
