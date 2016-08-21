schematic_save.marker1 = {}
schematic_save.marker2 = {}

--marks schematic_save region position 1
schematic_save.mark_pos1 = function(name)
	local pos = schematic_save.pos1[name]
	if schematic_save.marker1[name] ~= nil then --marker already exists
		schematic_save.marker1[name]:remove() --remove marker
		schematic_save.marker1[name] = nil
	end
	if pos ~= nil then --add marker
		schematic_save.marker1[name] = minetest.env:add_entity(pos, "schematic_save:pos1")
		schematic_save.marker1[name]:get_luaentity().active = true
	end
end

--marks schematic_save region position 2
schematic_save.mark_pos2 = function(name)
	local pos = schematic_save.pos2[name]
	if schematic_save.marker2[name] ~= nil then --marker already exists
		schematic_save.marker2[name]:remove() --remove marker
		schematic_save.marker2[name] = nil
	end
	if pos ~= nil then --add marker
		schematic_save.marker2[name] = minetest.env:add_entity(pos, "schematic_save:pos2")
		schematic_save.marker2[name]:get_luaentity().active = true
	end
end

minetest.register_entity(":schematic_save:pos1", {
	initial_properties = {
		visual = "cube",
		visual_size = {x=1.1, y=1.1},
		textures = {"worldedit_pos1.png", "worldedit_pos1.png",
			"worldedit_pos1.png", "worldedit_pos1.png",
			"worldedit_pos1.png", "worldedit_pos1.png"},
		collisionbox = {-0.55, -0.55, -0.55, 0.55, 0.55, 0.55},
	},
	on_step = function(self, dtime)
		if self.active == nil then
			self.object:remove()
		end
	end,
	on_punch = function(self, hitter)
		self.object:remove()
		local name = hitter:get_player_name()
		schematic_save.marker1[name] = nil
	end,
})

minetest.register_entity(":schematic_save:pos2", {
	initial_properties = {
		visual = "cube",
		visual_size = {x=1.1, y=1.1},
		textures = {"worldedit_pos2.png", "worldedit_pos2.png",
			"worldedit_pos2.png", "worldedit_pos2.png",
			"worldedit_pos2.png", "worldedit_pos2.png"},
		collisionbox = {-0.55, -0.55, -0.55, 0.55, 0.55, 0.55},
	},
	on_step = function(self, dtime)
		if self.active == nil then
			self.object:remove()
		end
	end,
	on_punch = function(self, hitter)
		self.object:remove()
		local name = hitter:get_player_name()
		schematic_save.marker2[name] = nil
	end,
})
