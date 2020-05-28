--
-- @file    data/parser/attrlib.lua
-- @anthor  xingweizhen (weizhen.xing@funplus.com)
-- @date    2017-11-14 10:10:47
-- @desc    描述
--

local P = {}

local DB = {}
local ATTR = dofile("config/combatstats_stats")
local AttrDEF = _G.DEF.Attr
for i,v in ipairs(ATTR) do
	DB[v.ID] = AttrDEF.create(v)
end

function P.get_dat(dat)
	return DB[dat]
end

return P