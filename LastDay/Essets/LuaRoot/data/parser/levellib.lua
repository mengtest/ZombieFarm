--
-- @file    data/parser/levellib.lua
-- @anthor  xingweizhen (weizhen.xing@funplus.com)
-- @date    2018-03-30 10:29:32
-- @desc    描述
--


local DB = {}

local LEVEL = dofile("config/level_level")
for _,v in ipairs(LEVEL) do
	DB[v.level] = {
		maxExp = v.exp, nTalent = v.talent,
	}
end

return {
	get_dat = function (level) return DB[level] end,
	get_maxn = function () return #DB end,
}