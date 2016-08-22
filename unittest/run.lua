#!/usr/bin/env lua

EXPORT_ASSERT_TO_GLOBALS = true
require('luaunit')
local path = require('path')
local fs = require('path.fs')
local loaded = { }
function load_module(name)
    if loaded[name] then return end
    f = io.open("mods" .. "/" .. name .. "/depends.txt")
    if f then
        for dep in f:lines() do
            if dep then load_module(dep) end
        end
    end
    dofile("mods/" .. name .. "/init.lua")
    loaded[name] = true
end

for name in fs.dir("unittest") do
    start, stop = name:find('test')
    if start == 1 then
        dofile("unittest/" .. name)
    end
end

-- fixture loader helper
function fixture(name)
    return dofile("unittest/fixtures/" .. name .. ".lua")
end

-- hack to ensure that a global teardown/setup is run between all cases
for k,v in pairs(_G) do
    if type(v) == 'table' and string.find(k, 'Test') == 1 then
        -- guess we need an IFFE here to thwart the closure
        (function()
            local oldFunction = v.setUp
            v.setUp = function(self)
                -- blow away anything that might retain state between cases
                stm = nil
                minetest = nil
                dofile("mods/stm/init.lua")

                for name in fs.dir("unittest/mocks") do
                    start, stop = name:find('mock')
                    if start == 1 then
                        dofile("unittest/mocks/" .. name)
                    end
                end
                math.randomseed(1337)
                Parameters.fast = true
                Parameters.skip = false
                if oldFunction then oldFunction() end
            end
        end)()
    end
end

local lu = LuaUnit.new()
os.exit( lu:runSuite() )