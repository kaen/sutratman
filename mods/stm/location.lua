Location = serializable.define('Location', function()
  return {
    name = "Location",
    pos = { x = 0, y = 0, z = 0 },
    children = { },
    ruler = nil,
    type = nil
  }
end)

Location.TYPE_MUNICIPALITY = 1
Location.TYPE_RESIDENCE = 2

function Location.get_closest(pos, filter)
  for k,v in pairs(Location.all()) do
    -- TODO actual distance check
    if filter(v) then return v end
  end
  return nil
end

function Location:describe()
  return string.format("%s, a simple %s", self.name, self.race)
end

function Location:get_position()
  return {
    x = self.pos.x,
    y = self.pos.y,
    z = self.pos.z
  }
end

function Location:get_workers()
  local result = { }
  for k,char in pairs(Character.all()) do
    -- all residents except the ruler are workers for now
    -- TODO: hang these IDs on self.workers?
    if char.municipality == self.id and char.id ~= self.ruler then
      table.insert(result, char)
    end
  end
  return result
end

function Location:request_location(xsize, ysize, zsize)
  local min = vector.new(0,self.pos.y,0)
  local max = vector.new(0,self.pos.y + ysize - 1,0)
  local ok, other
  for x = self.min.x,(self.max.x-xsize+1) do
    for z = self.min.z,(self.max.z-zsize+1) do
      min.x = x
      min.z = z
      max.x = x + xsize - 1
      max.z = z + zsize - 1

      ok = true
      for k, id in pairs(self.children) do
        other = Location.get(id)
        if stm.rectangles_overlap(min,max,other.min,other.max) then
          ok = false
          break
        end
      end

      if ok then
        local result = Location.new()
        Location.register(result)
        result.pos = vector.new(
          math.floor(min.x + (max.x - min.x)/2),
          math.floor(min.y),
          math.floor(min.z + (max.z - min.z)/2)
        )
        result.min = min
        result.max = max
        table.insert(self.children, result.id)
        return result
      end
    end
  end
end
