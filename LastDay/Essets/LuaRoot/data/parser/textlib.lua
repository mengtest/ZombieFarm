--
-- @file    data/parser/textlib.lua
-- @anthor  xingweizhen (weizhen.xing@funplus.com)
-- @date    2018-01-29 11:48:21
-- @desc    描述
--

local DB 

local function reset()
	DB = {}
	local TEXT = dofile("config/text_".._G.lang)
	for _,v in ipairs(TEXT) do
		DB[v.ID] = v.Text
	end
end

local function get_dat(id) return DB[id] or "Text#" .. id end
local function get_loc(Loc) return get_dat(Loc.id) end

local OBJDEF = {}
OBJDEF.__index = OBJDEF
OBJDEF.__tostring = get_loc
OBJDEF.__call = get_loc
OBJDEF.__concat = function (a, b)
	return tostring(a)..tostring(b)
end
OBJDEF.__len = function (self)
	local text = tostring(self)
	return text and #text or 0
end
OBJDEF.csfmt = function (self, ...)
	return get_loc(self):csfmt(...)
end

function OBJDEF.new(id)
	return setmetatable({ id = id }, OBJDEF)
end

local TEXT_SECTION = dofile("config/text_textsection")
local SectionDB = setmetatable({}, _G.MT.AutoGen)
for i,v in ipairs(TEXT_SECTION) do
	SectionDB[v.sheetName][v.textField] = { key = v.idField, section = v.idSection }
end
setmetatable(SectionDB, nil)

--local P = {}
--function P.get_dat(id) return DB[id] or "Text#" .. id end
local function text_id(sheet, field, Dat)
	if Dat then
		local Sheet = SectionDB[sheet]
		if Sheet then
			local Field = Sheet[field]
			if Field then
				local index = Dat[Field.key]
				if index then return Field.section + index end
			end
		end
	end

	libunity.LogW("Text Undefine [{0}.{1}]", sheet, field)

	return 0
end

local function text_obj(sheet, field, Dat)
	return OBJDEF.new(text_id(sheet, field, Dat))
end

local function new_text(id)
	return OBJDEF.new(id)
end

reset()

return {
	reset = reset,
	get_dat = get_dat,
	text_id = text_id,
	text_obj = text_obj,
	new_text = new_text,
}
