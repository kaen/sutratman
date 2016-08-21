TestUtil = {}

function TestUtil:testIntToPos()
  local edge = math.floor(0xFFFF / 2)
  local subjects = {
    vector.new(edge, edge, edge),
    vector.new(-edge, -edge, -edge),
    vector.new(0, 0, 0),
    vector.new(1, 1, 1),
    vector.new(-1, -1, -1)
  }

  for _, pos in pairs(subjects) do
    local int = stm.pos_to_int(pos)
    local result = stm.int_to_pos(int)
    assert(vector.distance(pos, result) == 0)
  end
end