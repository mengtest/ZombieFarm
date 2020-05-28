--
-- @file    data/parser/guildlib.lua
-- @anthor  shenbingkang
-- @date    2018-01-04 17:52:00
-- @desc    描述
--

local P = {}

local text_obj = config("textlib").text_obj
local AttrDEF = _G.DEF.Attr
local ITEMLib = config("itemlib")
local UNITLIB = config("unitlib")
--local ATTRLib = config("attrlib")
local log = _G.newlog()

local EBadgeType = {
	Background = 0,
	Shading = 1,
	Pattern = 2,
}

local ColorMap = {
	[0] = {
		"#ffffff",
		"#ffff00",
		"#ff6e00",
		"#c33131",
		"#60c400",
		"#00f780",
		"#45cbbc",
		"#3e4eda",
		"#8104ff",
		"#ff9af6",
	},
	[1] = {
		"#7c4500",
		"#c34400",
		"#c33131",
		"#84bf4c",
		"#049476",
		"#30ae9f",
		"#3e4eda",
		"#5c2891",
		"#e133c4",
		"#0d0d0d",
	},
	[2] = {
		"#fff056",
		"#f66b00",
		"#842121",
		"#84bf4c",
		"#049476",
		"#30ae9f",
		"#3e4795",
		"#5c2891",
		"#a14e92",
		"#3b3454",
	},
}

local WELFARE_DB = {}
local WELFARE = dofile("config/guild_welfare")
for _,v in ipairs(WELFARE) do
	WELFARE_DB[v.lv] = {
		welf_id = v.lv,
		exploit = v.exploit,
		reward = v.reward:splitgn(),
	}
end

local POSITION_DB = {}
local POSITION = dofile("config/guild_positiontext")
for _,v in ipairs(POSITION) do
	POSITION_DB[v.ID] = {
		pos_id = v.ID,
		text = text_obj("guild_positiontext", "nameTextID", v),
	}
end

local LEVEL_DB = {}
local LEVEL = dofile("config/guild_level")
for _,v in ipairs(LEVEL) do
	LEVEL_DB[v.level] = {
		lv_id = v.level,
		maintenanceFee = v.maintenanceFee,
		maxMember = v.maxMember,
	}
end

local BADGE_DB = {}
local BADGE_TYPE_DB = {}
local BADGE = dofile("config/guild_badge")
for _,v in ipairs(BADGE) do
	BADGE_DB[v.ID] = {
		badgeID = v.ID,
		badgeType = v.type,
		icon = "GuildIcon/"..v.icon,
	}
	if BADGE_TYPE_DB[v.type] == nil then
		BADGE_TYPE_DB[v.type] = {}
	end
	table.insert(BADGE_TYPE_DB[v.type], BADGE_DB[v.ID])
end

local GUILDLOG_DB = {}
local GUILDLOG = dofile("config/guild_guildlog")
for _,v in pairs(GUILDLOG) do
	GUILDLOG_DB[v.ID] = {
		logID = v.ID,
		fmtContent = text_obj("guild_guildlog", "logText", v),
	}
end

local GUILDLOG_TYPE_DB = {}
local GUILDLOG_TYPE = dofile("config/guild_guildlogtype")
for _,v in pairs(GUILDLOG_TYPE) do
	GUILDLOG_TYPE_DB[v.ID] = {
		ID = v.ID,
		Type = v.Type,
	}
end

local DEPARTMENT_RESOURCE_DB = {}
local DEPARTMENT_RESOURCE = dofile("config/guild_departmentresource")
for _,v in pairs(DEPARTMENT_RESOURCE) do
	DEPARTMENT_RESOURCE_DB[v.ID] = {
		buildingID = v.ID,
		picture = v.picture,
		name = text_obj("guild_departmentresource", "departmentName", v),
		--desc = text_obj("guild_departmentresource", "describtionTextID", v),
	}
end

local DEPARTMENT_DB = {}
local DEPARTMENT = dofile("config/guild_department")
for _,v in pairs(DEPARTMENT) do
	if DEPARTMENT_DB[v.ID] == nil then
		DEPARTMENT_DB[v.ID] = {}
	end

	DEPARTMENT_DB[v.ID][v.lv] = {
		buildingID = v.ID,
		buildingLv = v.lv,
		needGuildLv = v.guildLv,
		donate = v.donate:splitgn(":"),
		unitBase = UNITLIB.get_dat(tonumber(v.objectID)),
		maintenanceFee = v.MaintenanceFee,
		upgradeDescription = text_obj("guild_department", "upgradeDescription", v),
	}
end

local GUILDBUFF_BUFFID_DB = {}
local GUILDBUFF_RQCLASS_DB = {}
local GUILDBUFF = dofile("config/guild_guildbuff")
for _,v in pairs(GUILDBUFF) do
	if GUILDBUFF_BUFFID_DB[v.ID] == nil then
		GUILDBUFF_BUFFID_DB[v.ID] = {}
	end
	if GUILDBUFF_RQCLASS_DB[v.requiredClass] == nil then
		GUILDBUFF_RQCLASS_DB[v.requiredClass] = {}
	end

	local data = {
		buffID = v.ID,
		buffLV = v.lv,
		requiredClass = v.requiredClass,
		effect = v.effect,
		cost = v.cost,
		icon = v.icon,
		--name = text_obj("guild_guildbuff", "nameTextID", v),
		--desc = text_obj("guild_guildbuff", "nameTextID", v),
	}

	GUILDBUFF_BUFFID_DB[v.ID][v.lv] = data
	table.insert(GUILDBUFF_RQCLASS_DB[v.requiredClass], data)
end

-- local DONATE_TYPE_DB = {}
-- local DONATE_TYPE = dofile("config/guild_donatetype")
-- for _,v in pairs(DONATE_TYPE) do
-- 	DONATE_TYPE_DB[v.ID] = text_obj("guild_donatetype", "nameTextID", v)
-- end

local ROBOT_MECHPARTS_DB = {}
local ROBOT_MECHPARTS_TYPE_DB = {}
local ROBOT_MECHPARTS = dofile("config/guild_mechparts")
for _,v in pairs(ROBOT_MECHPARTS) do
	local mechparts = {id = v.ID,}

	mechparts.class = v.type
	mechparts.requiredClass = v.requiredClass
	mechparts.cost = v.cost
	mechparts.icon = v.icon
	mechparts.model = ""
	--mechparts.name = text_obj("guild_mechparts", "nameTextID", v)

	local mechpartsAttr = AttrDEF.new({
			efficiency = v.efficiency,
			endurance = v.endurance,
		})

	local Attr
	if v.canEquipped == 1 then
		local itemData = ITEMLib.get_dat(v.ID)
		Attr = itemData.Attr
		mechparts.model = itemData.model
	end

	if Attr then
		mechpartsAttr = mechpartsAttr + Attr
	end
	mechparts.Attr = mechpartsAttr

	ROBOT_MECHPARTS_DB[v.ID] = mechparts
	if ROBOT_MECHPARTS_TYPE_DB[mechparts.class] == nil then
		ROBOT_MECHPARTS_TYPE_DB[mechparts.class] = {}
	end
	table.insert(ROBOT_MECHPARTS_TYPE_DB[mechparts.class], mechparts)
end
for _,list in pairs(ROBOT_MECHPARTS_TYPE_DB) do
	table.sort(list, function (a, b)
		return a.requiredClass < b.requiredClass
	end)
end

local EMPLOYEE_DB = {}
local EMPLOYEE = dofile("config/guild_employee")
for _,v in pairs(EMPLOYEE) do
	EMPLOYEE_DB[v.requiredClass] = {
		id = v.requiredClass,
		npcID = v.npcID,
	}
end

local EXPLOIT_MAP_DB = {}
local EXPLOIT_MAP = dofile("config/guild_exploitation")
for _,v in pairs(EXPLOIT_MAP) do
	local data = {}
	data.mapID = v.mapID
	data.itemID = v.itemID
	data.receiveTime = v.receiveTime
	data.extraItemID = v.extraItemID
	data.icon = v.picture
	--data.name = text_obj("guild_exploitation", "nameTextID", v)

	table.insert(EXPLOIT_MAP_DB, data)
end
table.sort(EXPLOIT_MAP_DB, function (a, b)
	return a.mapID < b.mapID
end)

local EXPLOIT_TIME_DB = {}
local EXPLOIT_TIME = dofile("config/guild_exploittime")
for _,v in pairs(EXPLOIT_TIME) do
	local data = {id = v.ID,}
	data.time = v.time
	local endurance = v.enduranceInterval:splitn(":")
	data.enduranceMin = endurance[1]
	data.enduranceMax = endurance[2]
	table.insert(EXPLOIT_TIME_DB, data)
end

local FRIENDLY_LV_DB = {}
local FRIENDLY_LV = dofile("config/guild_friendlylevel")
for _,v in pairs(FRIENDLY_LV) do
	local data = {}
	data.level = v.level
	data.exp = v.exp
	FRIENDLY_LV_DB[data.level] = data
end
for _,v in pairs(FRIENDLY_LV_DB) do
	local preLevel = v.level - 1
	local preData = FRIENDLY_LV_DB[preLevel]
	v.preExp = preData and preData.exp or 0
end

local REQUEST_ITEM_DB = {}
local REQUEST_ITEM = dofile("config/guild_requestitem")
for _,v in pairs(REQUEST_ITEM) do
	local data = {}
	data.id = v.ID
	data.itemId = v.ItemID
	data.requestLvLimit = v.FriendlyLevelLimit
	data.requestCnt = v.FriendlyLevelNum
	data.sortIndex = v.Sort
	table.insert(REQUEST_ITEM_DB, data)
end
table.sort(REQUEST_ITEM_DB, function (a, b)
	if a.requestLvLimit == b.requestLvLimit then
		return a.sortIndex < b.sortIndex
	end
	return a.requestLvLimit < b.requestLvLimit
end)

local DONATE_ITEM_DB = {}
local DONATE_ITEM = dofile("config/guild_donateitem")
for _,v in pairs(DONATE_ITEM) do
	DONATE_ITEM_DB[v.ID] = v.Contribution
end

function P.get_welfare_dat(id)
	return WELFARE_DB[id]
end

function P.get_position_name(position)
	local Position = POSITION_DB[position]
	return Position and tostring(Position.text)
end

function P.get_level_dat(id)
	return LEVEL_DB[id]
end

function P.get_badge_dat(id)
	return BADGE_DB[id]
end

function P.get_badge_type_list(badgeType)
	local typeId = tonumber(badgeType)
	if typeId == nil then
		typeId = EBadgeType[badgeType]
	end
	return BADGE_TYPE_DB[typeId]
end

function P.find_badge_icon_index(badgeType, badgeID)
	local list = P.get_badge_type_list(badgeType)
	for i,v in pairs(list) do
		if v.badgeID == badgeID then
			return i
		end
	end
	return -1
end

function P.get_color_map(badgeType)
	local typeId = tonumber(badgeType)
	if typeId == nil then
		typeId = EBadgeType[badgeType]
	end
	return ColorMap[typeId]
end

local function process_log_value(logKey, logValue)
	local rst = logValue
	if logKey == "<GUILD_JOB>" then
		rst = P.get_position_name(tonumber(logValue))
	elseif logKey == "<GUILD_BUILD>" then
		local department = DEPARTMENT_RESOURCE_DB[tonumber(logValue)]
		if department == nil then
			libunity.LogE("[DepartmentResource]表中未包含ID={0}的数据。", tonumber(logValue))
		end
		rst = department and department.name or ""
	-- elseif logKey == "<GUILD_OPERATION>" then
	-- 	rst = DONATE_TYPE_DB[tonumber(logValue)]
	elseif logKey == "<GUILD_DONATEITEM_NAME>" then
		local itemData = ITEMLib.get_dat(tonumber(logValue))
		rst = itemData.name
	end
	return tostring(rst)
end

local function process_log_type(logType)
	local typeStr = ""
	local typeInfo = GUILDLOG_TYPE_DB[tonumber(logType)]
	if typeInfo == nil then
		libunity.LogE("[GuildLogType]表中未包含ID={0}的数据。", dat)
	else
		typeStr = typeInfo.Type
	end
	return typeStr
end

local function log_split(log)
	local Ret = {}
	local datas = log:split('|')
	for _,v in pairs(datas) do
		local pairInfo = v:split(':')
		table.insert(Ret, { key = pairInfo[1], value = pairInfo[2] } )
	end

    return Ret
end

function P.get_guildlog(logID, paramStr)
	local fmtContent = tostring(GUILDLOG_DB[logID].fmtContent)
	local params = log_split(paramStr)

	for _,v in pairs(params) do
		local typeStr = process_log_type(v.key)
		local realValue = process_log_value(typeStr, v.value)
		fmtContent = string.gsub(fmtContent, typeStr, realValue)
	end
	return fmtContent
end

function P.get_building_info(buildingID, buildingLv)
	local resInfo = DEPARTMENT_RESOURCE_DB[buildingID]
	local departmentInfo = DEPARTMENT_DB[buildingID][buildingLv]
	return resInfo, departmentInfo
end

function P.get_guild_buff_info(buffID, buffLV)
	return GUILDBUFF_BUFFID_DB[buffID][buffLV]
end

function P.get_guild_buff_menu_list()
	return GUILDBUFF_RQCLASS_DB
end

function P.get_mechparts_info(mechpartsID)
	return ROBOT_MECHPARTS_DB[mechpartsID]
end

function P.get_mechparts_list(mechpartsType)
	return ROBOT_MECHPARTS_TYPE_DB[mechpartsType]
end

function P.get_employee_info(buildingLevel)
	return EMPLOYEE_DB[buildingLevel]
end

function P.get_exploit_map_list()
	return EXPLOIT_MAP_DB
end

function P.get_exploit_time(endurance)
	local exploitTime = 0
	for _,v in pairs(EXPLOIT_TIME_DB) do
		if endurance < v.enduranceMin then
			return exploitTime
		end
		exploitTime = v.time
	end
	return exploitTime
end

function P.get_exchange_friendly_level(curExp)
	local lastData
	for _,v in pairs(FRIENDLY_LV_DB) do
		lastData = v
		if curExp < v.exp then
			return v
		end
	end
	return lastData
end

function P.get_request_claim_list()
	return REQUEST_ITEM_DB
end

function P.get_donate_contribution(itemId)
	local value = DONATE_ITEM_DB[itemId]
	return value or 0
end

return P