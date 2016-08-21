--- Represents a thing to be built.
BuildOrder = serializable.define('BuildOrder', function()
  return {
    pos = nil,
    total = 0,
    remaining = 0,
    min = nil,
    max = nil,
    jobs = {}
  }
end)

-- wait N standard realtime seconds before a job can be reclaimed
local TASK_TIMEOUT = 3 * stm.TIME_SCALE

function BuildOrder.from_schematic(base, name)
  local spec = dofile(stm.base_path .. "/schematics/" .. name .. ".lua")
  local translated_nodes = { }
  for i,n in pairs(spec.nodes) do
    local pos = stm.int_to_pos(i)
    pos = vector.add(pos, base)
    translated_nodes[stm.pos_to_int(pos)] = n
  end
  return BuildOrder.create(translated_nodes)
end

function BuildOrder.from_generator(min, max, name)
  local spec = dofile(stm.base_path .. "/generators/" .. name .. ".lua")
  return BuildOrder.create(spec(min,max))
end

--- Creates a build order from a schematic function.
-- @param spec mapping of integers to node objects (used with set_node).
-- The keys are passed to stm.int_to_pos, and the result is expected to be the absolute position to pass to set_node
-- The values are passed as-is to set_node
function BuildOrder.create(spec)
  local result = BuildOrder.new()

  if type(spec) == 'function' then
    spec = spec(min,max)
  end

  result.min = vector.new(math.huge, math.huge, math.huge)
  result.max = vector.new(-math.huge, -math.huge, -math.huge)
  -- TODO: truncate spec to given min/max extents?
  for k,v in pairs(spec) do
    local pos = stm.int_to_pos(k)
    result.min.x = math.min(result.min.x, pos.x)
    result.min.y = math.min(result.min.y, pos.y)
    result.min.z = math.min(result.min.z, pos.z)
    result.max.x = math.max(result.max.x, pos.x)
    result.max.y = math.max(result.max.y, pos.y)
    result.max.z = math.max(result.max.z, pos.z)
    result:push_job(pos, v)
  end
  return result
end

--- Add job to build `node` at `pos`
function BuildOrder:push_job(pos, node)
  self.total = self.total + 1
  self.remaining = self.remaining + 1
  local id = stm.get_uuid()
  self.jobs[id] = { pos = pos, node = node, id = id }
end

--- Takes the unclaimed job closest to pos
function BuildOrder:take_job(pos)
  local free_jobs = { }
  local best_dist = math.huge
  local best_job = nil
  for k,job in pairs(self.jobs) do
    if not job.taken or stm.data.time - job.taken > TASK_TIMEOUT then
      local delta = vector.subtract(pos, job.pos)
      local dist_squared = delta.x * delta.x + delta.z * delta.z
      if dist_squared < best_dist then
        best_dist = dist_squared
        best_job = job
      end
    end
  end

  if not best_job then return end
  best_job.taken = stm.data.time
  return best_job
end

--- Mark a given job as complete
function BuildOrder:complete_job(id)
  self.remaining = self.remaining - 1
  self.jobs[id] = nil
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
