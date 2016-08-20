.PHONY: doc check

all: doc check test

test:
	lua ./unittest/run.lua

doc:
	ldoc -f markdown mods/vxl/

check:
	luacheck mods/vxl/
