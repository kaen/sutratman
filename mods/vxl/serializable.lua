-- Automatic class methods for serializable data types
_G.serializable = { }
local klasses = { }
local instances = { }

local function serialize(data)
  return minetest.serialize(data)
end

local function unserialize(data)
  return minetest.unserialize(data)
end

local function get_uuid()
  return vxl.get_uuid()
end

--- Define a serializable class
-- @param name String a unique name for this class
-- @param initializer Function a function returning default properties for new objects
function serializable.define(name, initializer)
  assert(type(name) == "string")
  assert(type(initializer) == "function")

  local klass = { }
  klasses[name] = klass

  -- Standard constructor, optionally takes a table with properties to set on
  -- the new object
  klass.__index = klass
  klass.new = function(o)
    o = o or { }
    if not o.id then o.id = vxl.get_uuid() end
    for k,v in pairs(initializer()) do
      if o[k] == nil then o[k] = v end
    end
    setmetatable(o, klass)
    return o
  end

  -- Registers an instance of the class in a registry for later serialization
  klass.register = function(o)
    instances[klass] = instances[klass] or { }
    instances[klass][o.id] = o
  end

  -- Gets a registered instance of a klass by ID
  klass.get = function(id)
    if not instances[klass] then return end
    return instances[klass][id]
  end

  klass.all = function()
    return instances[klass] or { }
  end

  return klass
end

-- creates a string (meant to be written to a file) containing all of the
-- primitive data for all instances of serializable classes
function serializable.deflate()
  return serialize(instances)
end

-- inflates a string created by deflate into a registry full of objects
-- created from the appropriate klass
function serializable.inflate(str)
  local data = unserialize(str)
  for klass,objects in pairs(data) do
    instances[klass] = instances[klass] or { }
    for _,object in pairs(objects) do
      instances[klass][object.id] = klasses[klass].new(object)
    end
  end
end
