minetest.register_privilege("schematic_save", "Can use Schematic commands")

schematic_save = {}
schematic_save.set_pos = {}

schematic_save.pos1 = {}
schematic_save.pos2 = {}


schematic_save.path = minetest.get_modpath(minetest.get_current_modname())
dofile(schematic_save.path .. "/mark.lua")
dofile(schematic_save.path .. "/serialize.lua")

--determines whether `nodename` is a valid node name, returning a boolean
schematic_save.node_is_valid = function(nodename)
	return minetest.registered_nodes[nodename] ~= nil
	or minetest.registered_nodes["default:" .. nodename] ~= nil
end

--determines the axis in which a player is facing, returning an axis ("x", "y", or "z") and the sign (1 or -1)
schematic_save.player_axis = function(name)
	local dir = minetest.env:get_player_by_name(name):get_look_dir()
	local x, y, z = math.abs(dir.x), math.abs(dir.y), math.abs(dir.z)
	if x > y then
		if x > z then
			return "x", dir.x > 0 and 1 or -1
		end
	elseif y > z then
		return "y", dir.y > 0 and 1 or -1
	end
	return "z", dir.z > 0 and 1 or -1
end

minetest.register_chatcommand("/mark", {
	params = "",
	description = "Show markers at the region positions",
	--privs = {schematic_save=true},
	func = function(name, param)
		schematic_save.mark_pos1(name)
		schematic_save.mark_pos2(name)
		minetest.chat_send_player(name, "Schematic region marked", false)
	end,
})

minetest.register_chatcommand("/pos1", {
	params = "",
	description = "Set Schematic region position 1 to the player's location",
	--privs = {schematic_save=true},
	func = function(name, param)
		local pos = minetest.env:get_player_by_name(name):getpos()
		pos.x, pos.y, pos.z = math.floor(pos.x + 0.5), math.floor(pos.y + 0.5), math.floor(pos.z + 0.5)
		schematic_save.pos1[name] = pos
		schematic_save.mark_pos1(name)
		minetest.chat_send_player(name, "Schematic position 1 set to " .. minetest.pos_to_string(pos), false)
	end,
})

minetest.register_chatcommand("/pos2", {
	params = "",
	description = "Set Schematic region position 2 to the player's location",
	--privs = {schematic_save=true},
	func = function(name, param)
		local pos = minetest.env:get_player_by_name(name):getpos()
		pos.x, pos.y, pos.z = math.floor(pos.x + 0.5), math.floor(pos.y + 0.5), math.floor(pos.z + 0.5)
		schematic_save.pos2[name] = pos
		schematic_save.mark_pos2(name)
		minetest.chat_send_player(name, "Schematic position 2 set to " .. minetest.pos_to_string(pos), false)
	end,
})

minetest.register_chatcommand("/p", {
	params = "set/set1/set2/get",
	description = "Set Schematic region, Schematic position 1, or Schematic position 2 by punching nodes, or display the current Schematic region",
	--privs = {schematic_save=true},
	func = function(name, param)
		if param == "set" then --set both Schematic positions
			schematic_save.set_pos[name] = "pos1"
			minetest.chat_send_player(name, "Select positions by punching two nodes", false)
		elseif param == "set1" then --set Schematic position 1
			schematic_save.set_pos[name] = "pos1only"
			minetest.chat_send_player(name, "Select position 1 by punching a node", false)
		elseif param == "set2" then --set Schematic position 2
			schematic_save.set_pos[name] = "pos2"
			minetest.chat_send_player(name, "Select position 2 by punching a node", false)
		elseif param == "get" then --display current Schematic positions
			if schematic_save.pos1[name] ~= nil then
				minetest.chat_send_player(name, "Schematic position 1: " .. minetest.pos_to_string(schematic_save.pos1[name]), false)
			else
				minetest.chat_send_player(name, "Schematic position 1 not set", false)
			end
			if schematic_save.pos2[name] ~= nil then
				minetest.chat_send_player(name, "Schematic position 2: " .. minetest.pos_to_string(schematic_save.pos2[name]), false)
			else
				minetest.chat_send_player(name, "Schematic position 2 not set", false)
			end
		else
			minetest.chat_send_player(name, "Unknown subcommand: " .. param, false)
		end
	end,
})

minetest.register_on_punchnode(function(pos, node, puncher)
	local name = puncher:get_player_name()
	if name ~= "" and schematic_save.set_pos[name] ~= nil then --currently setting position
		if schematic_save.set_pos[name] == "pos1" then --setting position 1
			schematic_save.pos1[name] = pos
			schematic_save.mark_pos1(name)
			schematic_save.set_pos[name] = "pos2" --set position 2 on the next invocation
			minetest.chat_send_player(name, "Schematic position 1 set to " .. minetest.pos_to_string(pos), false)
		elseif schematic_save.set_pos[name] == "pos1only" then --setting position 1 only
			schematic_save.pos1[name] = pos
			schematic_save.mark_pos1(name)
			schematic_save.set_pos[name] = nil --finished setting positions
			minetest.chat_send_player(name, "Schematic position 1 set to " .. minetest.pos_to_string(pos), false)
		elseif schematic_save.set_pos[name] == "pos2" then --setting position 2
			schematic_save.pos2[name] = pos
			schematic_save.mark_pos2(name)
			schematic_save.set_pos[name] = nil --finished setting positions
			minetest.chat_send_player(name, "Schematic position 2 set to " .. minetest.pos_to_string(pos), false)
		end
	end
end)

minetest.register_chatcommand("/save", {
	params = "<file>",
	description = "Save the current Schematic region to \"(world folder)/schems/<file>.we\"",
	--privs = {schematic_save=true},
	func = function(name, param)
		local pos1, pos2 = schematic_save.pos1[name], schematic_save.pos2[name]
		if pos1 == nil or pos2 == nil then
			minetest.chat_send_player(name, "No Schematic region selected", false)
			return
		end

		if param == "" then
			minetest.chat_send_player(name, "Invalid usage: " .. param, false)
			return
		end

		local result, count = schematic_save.serialize(pos1, pos2)

		--local path = minetest.get_worldpath() .. "/schems"
		local path = minetest.get_worldpath()
		local filename = path .. "/" .. param .. ".lua"
		--os.execute("mkdir \"" .. path .. "\"") --create directory if it does not already exist
		local file, err = io.open(filename, "w")
		if err ~= nil then
			minetest.chat_send_player(name, "Could not save file to \"" .. filename .. "\"", false)
			return
		end
		file:write(result)
		file:flush()
		file:close()

		minetest.chat_send_player(name, count .. " nodes saved", false)
	end,
})
