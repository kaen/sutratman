--- Represents any character in the world (including players).
Character = serializable.define('Character', function()
  return {
    pos = vector.new(0,0,0),
    yaw = 0,
    name = "",
    race = nil,
    velocity = vector.new(0,0,0),
    acceleration = vector.new(0,0,0),
    municipality = nil,
    residence = nil,
    on_ground = false,
    tasks = { }
  }
end)

--- Get a copy of this character's position.
-- @return vector
function Character:get_position()
  return {
    x = self.pos.x,
    y = self.pos.y,
    z = self.pos.z
  }
end

--- Get a string describing this character
function Character:describe()
  return string.format("%s, a simple %s", self.name, self.race)
end

--- Perform all simulation for this character.
-- @param dt time in game seconds to simulate
function Character:simulate(dt)
  self:perform_tasks(dt)
  self:update_physics(dt)
end

local PHYSICS_FUZZ = 0.01
--- Perform physics simulation for this character.
-- @param dt time in game seconds to simulate
function Character:update_physics(dt)
  -- local node = MapData.get_node(self.pos)
  local node = MapData.get_node(self.pos)

  -- -- TODO: better unsticking logic
  self.on = node
  if stm.is_solid(node) then
    self.pos.y = (MapData.get_surface_pos(self.pos) or vector.new(0,0,0)).y - 0.50 + PHYSICS_FUZZ
    self.on_ground = false
    self.acceleration.y = 0
    self.velocity.y = 0
    return
  end

  local node_below = MapData.get_node(vector.new(self.pos.x, self.pos.y - 1, self.pos.z))
  self.below = node_below
  local old = vector.new(self.pos.x, self.pos.y, self.pos.z)
  local old_node_pos = stm.float_to_node(old)

  self.on_ground = true
  if old_node_pos.y - old.y < 0.50 - PHYSICS_FUZZ or not stm.is_solid(node_below) then
    self.acceleration.y = -10 / stm.TIME_SCALE
    self.on_ground = false
  else
    self.acceleration.y = math.max(0, self.acceleration.y)
    self.velocity.y = math.max(0, self.velocity.y)
    self.pos.y = old_node_pos.y - 0.50 + PHYSICS_FUZZ
  end

  self.velocity = vector.add(self.velocity, vector.multiply(self.acceleration, dt))
  self.pos = vector.add(self.pos, vector.multiply(self.velocity, dt))
  local new = vector.new(self.pos.x, self.pos.y, self.pos.z)

  -- check for collisions when moving to new voxel
  local new_node_pos = stm.float_to_node(new)
  local xmove = old_node_pos.x ~= new_node_pos.x
  local ymove = old_node_pos.y ~= new_node_pos.y
  local zmove = old_node_pos.z ~= new_node_pos.z
  if xmove or ymove or zmove then
    local new_node = MapData.get_node(new)
    self.new = new_node
    if stm.is_solid(new_node) then
      -- TODO: better jumping
      if self.on_ground and (xmove or zmove) then
        local new_node_above = MapData.get_node(vector.new(new.x, new.y + 1, new.z))
        self.new_above = new_node_above
        if not stm.is_solid(new_node_above) then
          self.acceleration.y = 0
          self.velocity.y = 10 * stm.TIME_SCALE
          self.pos.y = self.pos.y + 1
          self.on_ground = false
          return
        end
      end

      -- check y first since we can jump over nodes
      if ymove then
        self.velocity.y = 0
        self.pos.y = old.y
        new.y = old.y
      end

      if xmove then
        self.velocity.x = 0
        self.pos.x = old.x
      end

      if zmove then
        self.velocity.z = 0
        self.pos.z = old.z
      end
    end
  end
end

--- Perform the current task for this character.
function Character:perform_tasks()
  local task, task_def = self:get_current_task()
  if not task then return nil end

  if not task.state.planned then
    task_def.plan(self, task.state)
    task.state.planned = true
  end

  local result = task_def.perform(self, task.state)
  if result == true or result == false then
    self.last_task_result = result
    self:pop_task(task)
  end
end

--- Get the current task for this character.
function Character:get_current_task()
  local task = Task.get(self.tasks[#self.tasks])
  if not task then return nil end
  return task, Task.defs[task.name]
end

--- Get a path from this charcter's position to `pos`.
-- This function (like minetest.find_path underneath it) may return nil for
-- any number of reasons including frequent set_node calls around the
-- find_path call. It also very expensive in the case of pathing failure, and
-- should be throttled by any client code.
-- @return the result of `minetest.find_path`
function Character:get_path_to(pos)
  if not self.on_ground then return end
  if not (minetest and minetest.find_path) then return { pos } end
  pos.x = pos.x
  pos.y = pos.y
  pos.z = pos.z
  return minetest.find_path(stm.float_to_node(self.pos), pos, 10, 1, 3, 'A*')
end

--- Add a task definition to the end of the task queue
-- @param name String the name of the task such as 'establish_municipality'
-- @param state Table the initial state of the task (used to pass task inputs)
-- @usage char:push_task('move', { dest = a_far_away_place, distance = 3 })
function Character:push_task(name, state)
  state = state or { }
  local task = Task.new({name = name, state = state})
  Task.register(task)
  table.insert(self.tasks, task.id)
end

function Character:pop_task(task)
  for i,id in ipairs(self.tasks) do
    if id == task.id then
      table.remove(self.tasks, i)
      break
    end
  end
end

--- Get the character's current walk speed.
-- @return Number the (directionless) walking speed of this character in
--   meters per gamesecond
function Character:get_walk_speed()
  -- roughly three meters per (standard realtime) second
  return 3 / stm.TIME_SCALE
end

--- Create the minetest entity that represents this character.
function Character:materialize()
  local entity = minetest.add_entity(self.pos, 'stm:character')
  entity:get_luaentity().char_id = self.id
end

--- Move to position.
-- Sets the yaw and velocity of the character to face `p`
-- @param p a vector specifying where to move to
function Character:move_to(p)
  local vec = {x = p.x -self.pos.x, y = p.y -self.pos.y, z = p.z -self.pos.z}
  local dist = vector.distance(self.pos, p)
  self.yaw = math.atan(vec.z/vec.x)
  if p.x < self.pos.x then
    self.yaw = self.yaw+math.pi
  end

  if dist > 1 then
    local walk_vector = vector.rotateY(vector.new(self:get_walk_speed(),0,0), self.yaw)
    self.velocity.x = walk_vector.x
    self.velocity.z = walk_vector.z
  else
    self:stop()
  end
end

--- Set the character's velocity to 0.
function Character:stop()
  self.velocity = vector.new(0,0,0)
end

if _G.minetest then
  minetest.register_entity('stm:character', {
    hp_max = 1,
    physical = false,
    weight = 5,
    textures = {"character.png"},
    visual = "mesh",
    mesh = "character.x",
    collisionbox = {-0.4, -0.01, -0.4, 0.4, 1, 0.4},
    makes_footstep_sound = true,
    walk_velocity = 1,
    armor = 100,
    drawtype = "front",
    water_damage = 1,
    lava_damage = 8,
    animation = {
      speed_normal = 17,
      stand_start = 0,
      stand_end = 79,
      walk_start = 168,
      walk_end = 187,
      current = 'stand'
    },
    view_range = 8,
    get_staticdata = function(self)
      return tostring(self.char_id)
    end,
    on_activate = function(self, data)
      self.char_id = tonumber(data)
    end,
    on_rightclick = function(self, clicker)
      stm.dump(self:get_char())
      for k,v in pairs(self:get_char().tasks) do
        print(v)
        stm.dump(Task.get(v))
      end
    end,
    get_char = function(self)
      if not self.char_id then return nil end
      if not self.char then
        for k,v in pairs(Character.all()) do
          if v.id == self.char_id then
            self.char = v
            break
          end
        end
      end
      return self.char
    end,
    on_step = function(self, dt)
      local char = self:get_char()
      if char then
        self.object:moveto(char:get_position())
        self.object:setvelocity(char.velocity)
        if char.velocity.x == 0 and char.velocity.y == 0 and char.velocity.z == 0 then
          if self.animation.current ~= 'stand' then
            self.object:set_animation(
              {x = self.animation.stand_start,y = self.animation.stand_end},
              self.animation.speed_normal, 0
            )
            self.animation.current = "stand"
          end
        else
          if self.animation.current ~= 'walk' then
            self.object:set_animation(
              {x = self.animation.walk_start,y = self.animation.walk_end},
              self.animation.speed_normal, 0
            )
            self.animation.current = "walk"
          end
        end
        self.object:setacceleration(char.acceleration)
        self.object:setyaw(char.yaw-math.pi/2)
      end
    end
})
end
