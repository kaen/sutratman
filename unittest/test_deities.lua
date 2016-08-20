TestDeities = {}
function TestDeities:testPopulate()
  Deity:populate()
  for _, deity in pairs(Deity.all()) do
    assertEquals(type(deity.name), 'string')
    assertEquals(type(deity.origin_story), 'string')
    assertEquals(type(deity.domain), 'string')
  end
end
