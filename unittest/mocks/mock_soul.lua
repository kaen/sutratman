-- TODO this mock is pretty stateful although it's lightweight enough that it
-- probably doesn't matter yet
local mock_player = {
  position = vector.new(0,0,0),
  setpos =  function(self, pos) self.position = pos end,
  getpos = function(self) return self.position end,
  get_player_name = function() return 'testplayer' end
}
function Soul:get_player()
  return mock_player
end