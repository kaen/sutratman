return function(min,max)
  local build_fn = function(x,y,z)
    if y >= min.y then return 'air' end
    return 'default:dirt'
  end

  return stm.walk_aabb(min, max, build_fn)
end