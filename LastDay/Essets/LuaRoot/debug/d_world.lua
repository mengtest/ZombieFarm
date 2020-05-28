--
-- @file    debug/d_world.lua
-- @anthor  xingweizhen (weizhen.xing@funplus.com)
-- @date    2018-04-08 15:31:32
-- @desc    描述
--

local World = setmetatable(DY_DATA.World, _G.DEF.World)

local Entrances = {
	{ id = 1, mType = 0, reqLevel = 1, Coord = { x = 0, y = 0, }, name = "Camp", entranceState = 1 },
}
for k,v in pairs(config("maplib").Entrances) do
	if k ~= 1 then
		table.insert(Entrances, v)
	end
end

World.Entrances = Entrances

World.Travel = {
	src = 1, dst = 0,
	tool = 2,
	leftTime = 10, totalTime = 30,
	Points = {
		{ x = 0, y = 0, },
		{ x = 1, y = 1, },
		{ x = 5, y = 5, },
		{ x = 5, y = 10, },
	},
}

World.Vehicle = {
	id = 2, curFuel = 33, maxFuel = 100, curDura = 75, maxDura = 100,
}
