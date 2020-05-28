--
-- @file    localize/lang.lua
-- @anthor  xingweizhen (weizhen.xing@funplus.com)
-- @date    2018-03-31 14:52:45
-- @desc    描述
--

local LangMT = { }
function LangMT.__index(t, k)
	if string.byte(k) > string.byte('Z') then
		t[k] = k
		return k
	else 
		local N = setmetatable({}, LangMT)
		t[k] = N

		k = tonumber(k) and "[" .. k .. "]" or "." .. k
		rawset(N, "__name", (rawget(t, "__name") or "") .. k)	
		return N
	end
end

function LangMT.__tostring(self)
	return self.__name
end

function LangMT:csfmt(...)
	local Fmt = {...}
	return __name .. "{" .. table.concat({...}, ",") .. "}"
end

local function init_loc(Loc)
	for _,v in pairs(Loc) do
		if type(v) == "table" then 
			init_loc(v)
			setmetatable(v, LangMT) 
		end 
	end
	setmetatable(Loc, LangMT)
end

return function (Loc)
	init_loc(Loc)
	return Loc
end
