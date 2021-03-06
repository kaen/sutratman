return function(min,max)
  local build_fn = function(x,y,z)
    local name = MapData.get_node(vector.new(x,y,z)).name
    if MapData.get_node_group('leaves', name) > 0 or MapData.get_node_group('tree', name) > 0 then
      return 'air'
    end
  end

  return stm.walk_aabb(min, max, build_fn)
end