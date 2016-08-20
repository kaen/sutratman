local SOURCES = {
  'serializable.lua',
  'vector.lua',
  'data.lua',
  'util.lua',
  'mapdata.lua',
  'character.lua',
  'build_order.lua',
  'task.lua',
  'location.lua',
  'deities.lua',
  'history.lua',
  'misc_helpers.lua'
}

for _, name in ipairs(SOURCES) do
  if minetest then
    dofile(minetest.get_modpath('vxl') .. "/" .. name)
  else
    dofile('./mods/vxl/' .. name)
  end
end
