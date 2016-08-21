--- Automatic class methods for serializable data types.
_G.serializable = { }
local klasses = { }
local instances = { }

local function serialize(data)
  return minetest.serialize(data)
end

local function deserialize(data)
  return minetest.deserialize(data)
end

local function get_uuid()
  return stm.get_uuid()
end

--- Define a serializable class.
-- The methods described below are added as class-level methods to the defined
-- class.
--
-- Objects defined using this interface can be saved to the disk by
-- serialization safely and reliably, even when the code changes. This
-- requires that only primitive types are saved into the instance attributes
-- of a `serializable` class. I.E. only simple tables, numbers, strings,
-- booleans, or nil.
-- @param name String a unique name for this class
-- @param initializer Function a function returning default properties for new objects
-- @return a table which will be set as the metatable `__index` property for all instances of the new class
function serializable.define(name, initializer)
  assert(type(name) == "string")
  assert(type(initializer) == "function")

  local klass = { }
  klasses[name] = klass
  klass.__index = klass

  --- Standard object constructor.
  -- Optionally takes a table with properties to set on
  -- the new object
  -- @param o Table instance attributes for the new object
  klass.new = function(o)
    o = o or { }
    if not o.id then o.id = stm.get_uuid() end
    for k,v in pairs(initializer()) do
      if o[k] == nil then o[k] = v end
    end
    setmetatable(o, klass)
    return o
  end

  --- Registers an instance of the class in a registry for later serialization.
  -- @param o instance of this klass to register
  klass.register = function(o)
    instances[name] = instances[name] or { }
    instances[name][o.id] = o
  end

  --- Gets a registered instance of a klass by ID
  -- @param id Number the id number of the object to retrieve
  klass.get = function(id)
    if not instances[name] then return end
    return instances[name][id]
  end

  --- Gets a reference to the table of instances of this class.
  -- @return Table a hash of `id` numbers to the actual object instance
  klass.all = function()
    return instances[name] or { }
  end

  return klass
end

--- Deflate all instances of registered classes into a string.
-- Creates a string (meant to be written to a file) containing all of the
-- primitive data for all instances of serializable classes
function serializable.deflate()
  return serialize(instances)
end

--- Inflate instances of registered classes from a string.
-- Inflates a string created by `deflate` into a registry full of objects
-- created from the appropriate klass (and retrievable with `klass.get`)
function serializable.inflate(str)
  local data = deserialize(str)
  for name,objects in pairs(data) do
    instances[name] = instances[name] or { }
    for k,object in pairs(objects) do
      print(k,object)
      instances[name][object.id] = klasses[name].new(object)
    end
  end
end
