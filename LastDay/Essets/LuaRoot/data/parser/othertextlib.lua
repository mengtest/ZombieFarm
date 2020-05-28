--
-- @file    data/parser/othertextlib.lua
-- @anthor  xingweizhen (ye.xin@funplus.com)
-- @date    2018-01-29 11:48:21
-- @desc    描述
--

local text_obj = config("textlib").text_obj
local DB = {}
local TEXT = dofile("config/othertext_newsticker")
for _,v in ipairs(TEXT) do
	DB[v.ID] = {
		id = v.ID,
		subtype = v.type,
		content = text_obj("othertext_newsticker", "text", v),
	}
end

local P = {}
function P.get_dat(id)
	local dat = DB[id]
	return dat and dat.content or ""
end


return P