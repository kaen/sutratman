Task = serializable.define('Task', function()
  return {
    character = nil,
    name = nil,
    state = { } 
  }
end)

Task.defs = { }

function Task.loadDefs()
  local path = 'mods/vxl/tasks/'
  if _G.minetest then
    path = minetest.get_modpath("vxl") .. "/tasks/"
  end
  local list = io.popen('ls -1 ' .. path)
  local basename
  for name in function() return list:read() end do
    basename = string.gsub(name, '.lua', '')
    Task.defs[basename] = dofile(path .. name)
  end
end

Task.loadDefs()