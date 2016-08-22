--- Manages the loading/saving of data for the simulation

local function loaddata()
  local objects_file = minetest.get_worldpath() .. "/objects"
  local data_file = minetest.get_worldpath() .. "/data"
  local file = io.open(objects_file, "r")
  if not file then return {} end
  serializable.inflate(file:read("*a"))
  io.close(file)

  local file = io.open(data_file, "r")
  if not file then return {} end
  stm.data = minetest.deserialize(file:read("*a"))
  io.close(file)
end

local function savedata()
  local objects_file = minetest.get_worldpath() .. "/objects"
  local data_file = minetest.get_worldpath() .. "/data"
  local file = io.open(objects_file, "w")
  if file then
    file:write(serializable.deflate())
    io.close(file)
  end

  file = io.open(data_file, "w")
  if file then
    file:write(minetest.serialize(stm.data))
    io.close(file)
  end
end

if minetest then
  -- minetest.register_on_shutdown(savedata)
  -- minetest.after(0, loaddata)
end

-- time in in-game seconds since the simulation started
stm = { }
stm.data = stm.data or { }
stm.data.time = stm.data.time or 0

-- The baseline scaling between real time and game time. The tricky part is to
-- keep things like movement speed and attack frequency looking correct on the
-- real timescale while keeping things like building a city roughly correct on
-- the game timescale.
stm.TIME_SCALE = 30.0