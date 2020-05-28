--
-- @file    data/object/attr.lua
-- @anthor  xingweizhen (weizhen.xing@funplus.com)
-- @date    2017-11-14 10:21:36
-- @desc    描述
--


local AttrIDMap = {
	"Damage", "atk", "def", "hp", "mp", "move", "sneak", "turn", "fast", "alert",
	"dayAlert", "daySightRad", "daySightAngle",
	"nightAlert", "nightSightRad", "nightSightAngle",
	"visionAdd", "visionReplace",
}

local AttrNameMap = table.swapkv(AttrIDMap)

local AttrIconMap = {
	Damage = "Common/ico_com_019",
	--atk = "Common/ico_com_019",
	def = "Common/ico_com_017",
	move = "Common/ico_com_020",
	fast = "Common/ico_com_018",
	hp = "Common/ico_com_069",
}

local SortedAttrName
local function get_attr_names()
	if SortedAttrName == nil then
		local SortedKeys = {
			"hp",
			"Damage",
			--"atk",
			"def",
			"move",
			"fast",
			"sneak",
			"turn",
		}
		SortedAttrName = {}
		local AttrNames = _G.TEXT.CFG_FIELD_NAME
		for _,v in ipairs(SortedKeys) do
			table.insert(SortedAttrName, { key = v, name = AttrNames[v] })
		end

		-- 放入其他的属性
		local SortedKeysMap = table.swapkv(SortedKeys)
		for i,v in ipairs(AttrIDMap) do
			if SortedKeysMap[v] == nil then
				table.insert(SortedAttrName, { key = v, name = AttrNames[v], })
			end
		end
	end
	return SortedAttrName
end

local function to_normal_percent(value)
	value = math.floor(value * 1000 + 0.5) / 10
	return value .. "%"
end

local function to_additive_percent(value)
	value = math.floor(value * 1000 + 0.5) / 10
	return value >= 0 and ("+" .. value .. "%") or (value .. "%")
end

-- 属性格式化函数
-- 向上取一位小数
local function value_to_self(value)
	return tostring(value)
end

-- 向上取整
local function value_to_int(value)
	return tostring(math.ceil(value))
end

-- 转为百分比
local function value_to_percent(value)
	value = math.floor(value * 1000 + 0.5) / 10
	return value .. "%"
end

-- 转为“降低”百分比
local function value_to_anti_percent(value)
	value = 1 - value
	return (math.floor(value * 1000 + 0.5) / 10) .. "%"
end

-- 转为“改变”百分比
local function value_to_rate_percent(value)
	return to_additive_percent(value - 1)
end

-- 攻击速度
local function add_atk_speed(value)
	local value = (value + 100) / 100 - 1
	return to_additive_percent(value)
end

-- 伤害范围
local function value_to_damage(Damage)
	return string.format("%d~%d", Damage.lowL, Damage.highU)
end

local AttrConv = setmetatable({
	hp = value_to_self,
	mp = value_to_self,
	atk = value_to_self,
	def = value_to_self,
	move = value_to_self,
	turn = value_to_self,
	fast = value_to_self,
	alert = value_to_self,
	Damage = value_to_damage,
}, { __index = function() return tostring end })

local function attr_add(srcVal, addVal)
	return srcVal + addVal
end
local function attr_add_milli(srcVal, addVal)
	return srcVal + addVal / 1000
end
local AttrTrans = setmetatable({

}, { __index = function () return attr_add end })

local DMGDEF = { }

function DMGDEF.new() return setmetatable({}, DMGDEF) end
function DMGDEF.__index(t, n) return 0 end
function DMGDEF.__newindex(t, n, v) end

function DMGDEF.__add(A, B)
	return setmetatable({
			lowL = A.lowL + B.lowL,
			lowU = A.lowU + B.lowU,
			midU = A.midU + B.midU,
			highU = A.highU + B.highU,
		}, DMGDEF)
end

function DMGDEF.__sub(A, B)
	return setmetatable({
			lowL = A.lowL - B.lowL,
			lowU = A.lowU - B.lowU,
			midU = A.midU - B.midU,
			highU = A.highU - B.highU,
		}, DMGDEF)
end

local OBJDEF = {
	AttrConv = AttrConv,
	AttrTrans = AttrTrans,
}

local defaultFast

function OBJDEF.__index(t, n)
	return n == "Damage" and DMGDEF.new() or 0
end

function OBJDEF.__newindex(t, n, v)
	if type(n) == "number" then
		n = AttrIDMap[n]
	end
	if n ~= "Damage" then
		rawset(t, n, v)
	end
end

function OBJDEF.__tostring(self)
	return cjson.encode(self)
end

function OBJDEF.__add(A, B)
	local C = {}
	for _,v in ipairs(AttrIDMap) do
		if v == "visionReplace" then
			C[v] = math.max(A[v], B[v])
		else
			C[v] = A[v] + B[v]
		end
	end
	for k,v in pairs(C) do
		if v == 0 then C[k] = nil end
	end
	return setmetatable(C, OBJDEF)
end

function OBJDEF.__sub(A, B)
	local C = {}
	for _,v in ipairs(AttrIDMap) do
		if v == "visionReplace" then
			C[v] = math.max(A[v], B[v])
		else
			C[v] = A[v] - B[v]
		end
	end
	for k,v in pairs(C) do
		if v == 0 then C[k] = nil end
	end
	return setmetatable(C, OBJDEF)
end

function OBJDEF.new(self)
	return setmetatable(self or {}, OBJDEF)
end

function OBJDEF.dmg(self)
	return setmetatable(self or {}, DMGDEF)
end

function OBJDEF.create(Cfg)
	return setmetatable({
		hp = Cfg.HP,
		def = Cfg.armor,
		move = Cfg.movementSpeed / 1000,
		atk = math.floor((Cfg.lowDamageLL + Cfg.lowDamageUL + Cfg.midDamageUL + Cfg.highDamageUL) / 4 + 0.5),
		Damage = setmetatable({
			lowL = Cfg.lowDamageLL, lowU = Cfg.lowDamageUL,
			midU = Cfg.midDamageUL, highU = Cfg.highDamageUL,
		}, DMGDEF),
	}, OBJDEF)
end

function OBJDEF.default(key)
	if key == "fast" then
		if defaultFast == nil then
			defaultFast = config("itemlib").get_dat(1000).Attr.fast
		end
		return defaultFast
	else
		return 0
	end
end

function OBJDEF.add_value(self, key, value)
	if type(key) == "number" then key = AttrIDMap[key] end
	self[key] = AttrTrans[key](self[key], value)
end

local function to_short_number(value)
	value = math.floor(value * 100 + 0.5) / 100
	return math.tointeger(value) or value
end

function OBJDEF.conv_value(key, value, sign)
	local preffix = ""
	if key == "Damage" then
		value = table.dup(value, true)
		if sign == false then
			value.lowL = math.abs(value.lowL)
			value.highU = math.abs(value.highU)
		elseif sign and value.lowL > 0 then
			 preffix = "+"
		end
		value.lowL = to_short_number(value.lowL)
		value.highU = to_short_number(value.highU)
	else
		if sign == false then
			value = math.abs(value)
		elseif sign and value > 0 then
			preffix = "+"
		end
		value = to_short_number(value)
	end

	return preffix .. AttrConv[key](value)
end

function OBJDEF.sign_value(key, value)
	if key == "Damage" then
		value = value.lowL or 0
	end

	return value == 0 and 0 or math.abs(value) / value
end

function OBJDEF.pairs(...)
	local SortedAttrName = get_attr_names()
	local i = 0
	local max = #SortedAttrName
	local Attrs = {...}
	local hasAttr = #Attrs > 0
	local sign_value = OBJDEF.sign_value
	local conv_value = OBJDEF.conv_value
	return function ()
		while i < max do
			i = i + 1
			local v = SortedAttrName[i]
			local key, name = v.key, v.name
			local Values, valid = { key, name }
			if hasAttr then
				for n,Attr in ipairs(Attrs) do
					local value = Attr[key]
					if value == nil or sign_value(key, value) == 0 then
						value = nil
					else
						value = conv_value(key, value); valid = true
					end
					Values[n + 2] = value or false
				end
			else valid = true end
			if valid then return unpack(Values) end
		end
	end
end

function OBJDEF.get_text(self)
	local TextMap = {}
	for _,text,value in OBJDEF.pairs(self) do
		local sign = (value:find("^%d")) and "+" or ""
		table.insert(TextMap, { name = text, value = sign..value })
	end
	return TextMap
end

-- @self        属性实例
-- @sep         多属性间间隔符
-- @fmt         属性显示格式：%s %s
function OBJDEF.make_text(self, sep, fmt)
	local TextMap = {}
	if fmt == nil then fmt = "<color=#FDDCA3>%s</color> %s" end
	for _,text,value in OBJDEF.pairs(self) do
		value = value:gsub("^(%d)", "+%1")
		table.insert(TextMap, string.format(fmt, text, value))
	end
	return table.concat(TextMap, sep)
end

function OBJDEF.seticon(attr, sp)
	ui.seticon(sp, AttrIconMap[attr])
end

OBJDEF.Empty = OBJDEF.new()

return OBJDEF
