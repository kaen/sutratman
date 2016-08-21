.PHONY: doc check

all: doc check test

test:
	lua ./unittest/run.lua

doc:
	ldoc -f markdown -a mods/stm/

check:
	luacheck mods/stm/
