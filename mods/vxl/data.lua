--- Manages the loading/saving of data for the simulation
local function loaddata()
  local data_file = minetest.get_worldpath() .. "/data"
  local file = io.open(data_file, "r")
  if not file then return {} end
  local result = serializable.inflate(file:read("*a"))
  io.close(file)
  return result
end

local function savedata()
  local data_file = minetest.get_worldpath() .. "/data"
  local file = io.open(data_file, "w")
  if file then
    file:write(serializable.deflate())
    io.close(file)
  end
end

if minetest then
  minetest.register_on_shutdown(savedata)
  minetest.after(0, loaddata)
end

-- time in in-game seconds since the simulation started
vxl = { }
vxl.data = vxl.data or { }
vxl.data.time = vxl.data.time or 0

-- The baseline scaling between real time and game time. The tricky part is to
-- keep things like movement speed and attack frequency looking correct on the
-- real timescale while keeping things like building a city roughly correct on
-- the game timescale.
vxl.TIME_SCALE = 30.0