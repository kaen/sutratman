--- Represents a thing to be built.
BuildOrder = serializable.define('BuildOrder', function()
  return {
    pos = nil,
    total = 0,
    remaining = 0,
    min = nil,
    max = nil,
    spec = {}
  }
end)

-- wait N standard realtime seconds before a task can be reclaimed
local TASK_TIMEOUT = 3 * stm.TIME_SCALE

--- Creates a build order from a schematic function.
-- @param min vector for the bounding rectangle's min point
-- @param max vector for the bounding rectangle's max point
-- @param fn callback function taking arguments `(x,y,z)` and returning a
--   string such as "default:dirt" or "air"
-- @return the newly created BuildOrder
function BuildOrder.create(min, max, fn)
  local result = BuildOrder.new()
  result.min = min
  result.max = max
  for x = min.x,max.x do
    for y = min.y,max.y do
      for z = min.z,max.z do
        local name = fn(x,y,z)
        if name then
          result:push(vector.new(x,y,z), name)
        end
      end
    end
  end
  return result
end

--- Add a block with the given `name` at `pos`
function BuildOrder:push(pos, name)
  self.total = self.total + 1
  self.remaining = self.remaining + 1
  local id = stm.get_uuid()
  self.spec[id] = { pos = pos, name = name, id = id }
end

--- Takes the unclaimed task closest to pos
function BuildOrder:take_task(pos)
  local free_tasks = { }
  local best_dist = math.huge
  local best_task = nil
  for k,task in pairs(self.spec) do
    if not task.taken or stm.data.time - task.taken > TASK_TIMEOUT then
      local dist = vector.subtract(pos, task.pos)
      local dist_squared = dist.x * dist.x + dist.z * dist.z
      if dist_squared < best_dist then
        best_dist = dist_squared
        best_task = task
      end
    end
  end

  if not best_task then return end
  best_task.taken = stm.data.time
  return best_task
end

--- Mark a given task as complete
function BuildOrder:complete_task(id)
  self.remaining = self.remaining - 1
  self.spec[id] = nil
end

--- Returns true if the entire build order is complete
function BuildOrder:is_complete()
  return self.remaining == 0
end

--- Find all positions adjacent to this build order.
-- The returned positions can be passed to map_data.get_all_surface_pos for
-- pathing to the build site. Only the x/z components are valid in the
-- results, and only one position is returned per peripheral x/z pair.
-- @return a table of adjacent positions
function BuildOrder:find_adjacent_positions()
  local results = { }
  for x=self.min.x-1,self.max.x+1 do
    table.insert(results, vector.new(x, 0, self.min.z))
    table.insert(results, vector.new(x, 0, self.max.z))
  end

  for z=self.min.z,self.max.z do
    table.insert(results, vector.new(self.min.x, 0, z))
    table.insert(results, vector.new(self.max.x, 0, z))
  end
  return results
end
