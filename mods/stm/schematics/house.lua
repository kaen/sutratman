return function(min,max)
  local build_fn = function(x,y,z)
    if x == min.x or x == max.x or
       y == max.y or
       z == min.z or z == max.z
    then
      return "air"
    elseif
       x == min.x+1 or x == max.x-1 or
       y == max.y-1 or
       z == min.z+1 or z == max.z-1
    then
      local midx = math.floor(min.x + (max.x - min.x)*.5)
      local midz = math.floor(min.z + (max.z - min.z)*.5)
      if x == midx and z > midz and y <= min.y + 1 then
        return "air"
      end
      return "default:stone"
    end
    return "air"
  end
  return stm.walk_aabb(min, max, build_fn)
end
