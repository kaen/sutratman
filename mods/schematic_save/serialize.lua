

-- Create and initialize a table for a schematic.
function schematic_save.schematic_array(width, height, depth)
	-- Dimensions of data array.
	local schem = {size={x=width, y=height, z=depth}}
	schem.data = {}

	for z = 0,depth-1 do
		for y = 0,height-1 do
			for x = 0,width-1 do
				local i = z*width*height + y*width + x + 1
				schem.data[i] = {}
				schem.data[i].name = "air"
				schem.data[i].prob = 0
			end
		end
	end

	schem.yslice_prob = {}

	return schem
end

function schematic_save.serialize(a, b)
  local min = vector.new(math.min(a.x, b.x), math.min(a.y,b.y), math.min(a.z,b.z))
  local max = vector.new(math.max(a.x, b.x), math.max(a.y,b.y), math.max(a.z,b.z))
  local base = vector.new(
    math.floor(min.x + (max.x - min.x) / 2),
    min.y,
    math.floor(min.z + (max.z - min.z) / 2)
  )
  local data = {
    size = vector.subtract(max, min),
    nodes = { }
  }
  local count = 0
  for x=min.x,max.x do
    for y=min.y,max.y do
      for z=min.z,max.z do
      	count = count + 1
      	local absolute = vector.new(x,y,z)
        local pos = vector.subtract(absolute, base) 
        local node = minetest.get_node(absolute)
        data.nodes[stm.pos_to_int(pos)] = node
      end
    end
  end
  return minetest.serialize(data), count
end
