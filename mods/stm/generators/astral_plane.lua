return function(min,max)
  local build_fn = function(x,y,z)
    if y > min.y then return 'air' end
    return 'homedecor:glowlight_quarter_white'
  end

  return stm.walk_aabb(min, max, build_fn)
end