TestCharacter = {}

function TestCharacter:testTaskProcessing()
  local c = Character.new()
  local plan_done = 0
  local perform_done = 0

  local function plan_cb()
    plan_done = plan_done + 1
  end

  local function perform_cb()
    perform_done = perform_done + 1
  end

  local tasks = {
    { name = 'callback', state = { plan_cb = plan_cb, perform_cb = perform_cb } },
    { name = 'callback', state = { plan_cb = plan_cb, perform_cb = perform_cb } }
  }

  -- requires three calls: one to unpack the sequence of tasks, plus one more
  -- per sub task
  c:push_task('sequence', tasks)
  for i=1,20 do
    c:perform_tasks()
  end

  assertEquals(plan_done, 2)
  assertEquals(perform_done, 2)
  assertEquals(#c.tasks, 0)
end

function TestCharacter:testCollision()
  local c = Character.new()
  local i, j
  c.pos = vector.new(0,1,0)
  local wall_pos = vector.new(0,1,5)
  local dest_pos = vector.new(0,1,10)
  local step = Simulation.real_to_game(1/60) 

  -- make an impassable wall between us and the destination
  for i=-1,1 do
    for j=-1,1 do
      MapData.set_node(vector.new(wall_pos.x + i, wall_pos.y + j, wall_pos.z), { name = "default:stone" })
    end
  end

  for t=0,10000,step do
    c:move_to(dest_pos)
    c:simulate(step)
  end

  assert(stm.close_to(c.pos, wall_pos, 1))
end

function TestCharacter:testPathing()
  local step = Simulation.real_to_game(1/60) 
  local c = Character.new()
  local i, j
  c.pos = vector.new(0,1,0)
  local dest_pos = vector.new(0,1,3)

  for t=0,10000,step do
    c:move_to(dest_pos)
    c:simulate(step)
  end

  assert(stm.close_to(c.pos, dest_pos, 1))
end


function TestCharacter:testJumping()
  local c = Character.new()
  local i, j
  c.pos = vector.new(0,1,0)
  local wall_pos = vector.new(0,1,5)
  local dest_pos = vector.new(0,1,10)
  local step = Simulation.real_to_game(1/60) 

  -- make a low wall between us and the destination
  for i=-1,1 do
    MapData.set_node(vector.new(wall_pos.x + i, wall_pos.y, wall_pos.z), { name = "default:stone" })
  end

  for t=0,10000,step do

    c:move_to(dest_pos)
    c:simulate(step)
  end

  assert(stm.close_to(c.pos, dest_pos, 1))
end

function TestCharacter:testGravity()
  local c = Character.new()
  local i, j
  c.pos = vector.new(0,10,0)
  local step = Simulation.real_to_game(1/60) 

  for t=0,10000,step do
    c:simulate(step)
  end

  assert(math.abs(c.pos.y - 0.5) < 0.015)
end