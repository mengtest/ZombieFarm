--
-- @file    data/parser/errorlib.lua
-- @anthor  xingweizhen (weizhen.xing@funplus.com)
-- @date    2018-01-08 10:07:43
-- @desc    描述
--


local text_obj = config("textlib").text_obj
local DB = setmetatable({}, _G.MT.AutoGen)
local ERROR_CODE = dofile("config/errorcode_text")
for _,v in ipairs(ERROR_CODE) do
	DB[v.OP or "Default"][v.ID] = text_obj("errorcode_text", "Info", v)
end
setmetatable(DB, nil)

local P = {}
function P.get_dat(op, code)
	local Error = DB[op]
	return Error and Error[code] or nil
end

return P