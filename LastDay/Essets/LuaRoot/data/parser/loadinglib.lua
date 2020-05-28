--
-- @file    data/parser/loadinglib.lua
-- @anthor  xingweizhen (weizhen.xing@funplus.com)
-- @date    2018-06-11 14:30:59
-- @desc    描述
--

local DB = {}

local text_obj = config("textlib").text_obj
local LOADING = dofile("config/loading_tips")
for i,v in ipairs(LOADING) do
	table.insert(DB, {
		icon = v.tipsIcon,
		title = text_obj("loading_tips", "loadingTitle", v),
		content = text_obj("loading_tips", "loadingContent", v),
	})
end

return {
	ran_get = function ()
		return DB[math.random(1, #DB)]
	end,
}
