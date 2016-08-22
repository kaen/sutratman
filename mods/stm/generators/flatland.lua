return function(min,max)
  local build_fn = function(x,y,z)
    if y >= min.y then
      if MapData.get_node(vector.new(x,y,z)).name ~= 'air' then
        return 'air'
      else
        return nil
      end
    end
    return 'default:dirt'
  end

  return stm.walk_aabb(min, max, build_fn)
end