--
-- @file    data/parser/openinanilib.lua
-- @anthor  xingweizhen (ye.xin@funplus.com)
-- @date    2018-01-29 11:48:21
-- @desc    描述
--

local text_id = config("textlib").text_id
local DB = {}
local TEXT = dofile("config/openinani_openinani")
for _,v in ipairs(TEXT) do
	DB[v.index] = {
		id = v.index,
		starttime = v.starttime,
		showtime = v.showtime,
		pos = v.pos,
		startspeed = v.startspeed,
		endspeed = v.endspeed,
		path = v.resource,
		scale = v.resourcerate
	}
end

local P = {}
function P.get_dat(id) return id and DB[id] or DB end


return P