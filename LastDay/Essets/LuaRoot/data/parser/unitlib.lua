--
-- @file    data/parser/unitlib.lua
-- @anthor  xingweizhen (weizhen.xing@funplus.com)
-- @date    2017-10-19 12:24:32
-- @desc    描述
--

local DB = {}
local BUILDING_LIST

local ATTRLib = config("attrlib")
local text_obj = config("textlib").text_obj
local AttrDEF = _G.DEF.Attr
local EmptyAttr = AttrDEF.new({ hp = 1 })
local TIME_SCALE = _G.CVar.TIME_SCALE
local LENGTH_SCALE = _G.CVar.LENGTH_SCALE

local log = _G.newlog()

local LootMap = table.tomap(dofile("config/object_outputdisplay"), "ID")

local OBJ_TMPL = dofile("config/object_template")
local TmplDB = {}
for _,v in ipairs(OBJ_TMPL) do

	local modelGroup = v.model:split('|')

	local Tmpl = {
		id = v.ID,
		size = { x = v.Width * LENGTH_SCALE, y = 0, z = v.length * LENGTH_SCALE, },
		obstacle = v.blocking == 1,
		blockLevel = v.attackBlocking,

		model = modelGroup[1],
		modelGroup = modelGroup,
		mapIco = v.thumbnail, mapLayer = v.layer,
		hurtSfx = v.hurtSFX,
		--策划需求，即是脚步声又是生产音效
		footstepSfx = v.moveSFX,
		bornFx = v.bornResource, deadFx = v.deadResource,
		deadSfx = v.deadResourceSFX,
		fxBundle = v.packageFX, sfxBank = v.packageSFX,
	}
	local Loot = LootMap[v.ID]
	if Loot then
		Tmpl.Corpse = {
			ico = Loot.thumbnail,
			layer = Loot.layer,
			model = Loot.model,
		}
	end

	Tmpl.__index = Tmpl
	TmplDB[v.ID] = Tmpl
end

local OBJ_MAIN = dofile("config/object_object")
for _,v in ipairs(OBJ_MAIN) do
	local Tmpl = TmplDB[v.tempID]
	if Tmpl == nil then
		log("[object#%d]引用了不存在的模板#%d", v.ID, v.tempID)
	end
	DB[v.ID] = {
		id = v.ID, tmpl = v.tempID, type = v.type,
		scale = v.scale / 1000,
		building = v.building == 1,
		interact = v.interactive,
		interactTime = v.openTime * TIME_SCALE,
		interactType = v.openType,
		interactIcon = v.interactIcon,
		name = text_obj("object_object", "objectName", v),
		desc = text_obj("object_object", "objectDescription", v),
	}
end

local OBJ_NPC = dofile("config/object_npc")
for _,v in ipairs(OBJ_NPC) do
	local Data = DB[v.ID]
	if Data then
		local NpcAttr = AttrDEF.new({
				turn = math.rad(v.rotationSpeed),
				dayAlert = v.dayAlertRadius * LENGTH_SCALE,
				nightAlert = v.nightAlertRadius * LENGTH_SCALE,
				daySightRad = v.dayVisionRadius * LENGTH_SCALE,
				daySightAngle = v.dayVisionAngle,
				nightSightRad = v.nightVisionRadius * LENGTH_SCALE,
				nightSightAngle = v.nightVisionAngle,
			})
		local Attr = ATTRLib.get_dat(v.combatID)
		if Attr then
			NpcAttr = NpcAttr + Attr
		else
			log("[NPC#%d]没有属性配置(%d)", v.ID, v.combatID)
		end

		Data.bodyMat = v.bodyMaterial
		Data.Attr = NpcAttr
		Data.smellWarnAlert = v.smellingAcuityLevel2 * LENGTH_SCALE
		Data.smellErrorAlert = v.smellingAcuityLevel1 * LENGTH_SCALE
		local Skills = v.skill:splitn("|")
		if #Skills > 0 then Data.Skills = Skills end

		if Data.building then
			Data.class = "LivingEntity"
		else
			if Data.type == 1 then
				Data.class = "Human"
			elseif Data.type == 2 then
				Data.class = "Role"
			end
		end
	else
		log("[NPC#%d]缺少基础配置", v.ID)
	end
end

local OBJ_MINE = dofile("config/object_mine")
for _,v in ipairs(OBJ_MINE) do
	local Data = DB[v.ID]
	if Data then
		Data.class = "LivingEntity"
		Data.oper = v.interactiveID
		Data.Attr = ATTRLib.get_dat(v.combatID)
		if Data.Attr == nil then
			log("[Mine#%d]没有属性配置(%d)", v.ID, v.combatID)
		end

		local Drops = v.checkDrop:splitn("|")
		Data.Drops = #Drops > 0 and Drops or nil
	else
		log("[Mine#%d]缺少基础配置", v.ID)
	end
end

local OBJ_ITEM = dofile("config/object_mapitem")
for _,v in ipairs(OBJ_ITEM) do
	local Data = DB[v.ID]
	if Data then
		local Drops = v.checkDrop:splitn("|")
		Data.Drops = #Drops > 0 and Drops or nil
	else
		log("[MapItem#%d]缺少基础配置", v.ID)
	end
end

local BuildMethod = _G.CVar.BuildMethod
local BuildMType = _G.CVar.BuildMType
local BuildSType = _G.CVar.BuildSType
local Floors = {}
local Machines = {}

local OBJ_REPAIR = dofile("config/building_repair")
local RepairDB = {}
for i,v in ipairs(OBJ_REPAIR) do
	RepairDB[v.ID] = v.repairlMaterial:totablearray("|", ":", "id", "amount")
end

local OBJ_BUILD = dofile("config/building_building")
for _,v in ipairs(OBJ_BUILD) do
	local Data = DB[v.objectID]
	local STypeNames = BuildSType[v.buildType]
	if Data then
		Data.icon = v.icon
		Data.sort = v.sort
		Data.group = v.groupID
		Data.upgradeId = v.upgradeTarget
		Data.level = v.level
		Data.method = BuildMethod[v.buildMode]

		--只是用作显示分组使用
		Data.showType = v.buildType
		--mType非1就是2
		Data.mType = v.buildType == 1 and BuildMType[1] or BuildMType[2]
		Data.buildingType = v.buildingType
		Data.sType = STypeNames and STypeNames[v.buildingType]
		Data.base = v.groundType
		Data.reqPlayerLevel = v.levelRequired
		Data.rotType = v.directionChange
		Data.moveType = v.positionChange
		Data.worth = v.delete ~= 0 and v.deleteConfirm or -1
		Data.Repair = v.repair > 0 and RepairDB[v.repair] or nil
		Data.Formula = v.machining:splitn("|")
		Data.Mats = v.buildMaterial:splitgn(":")
		if #v.subBuilding ~= 0 then
			Data.subBuilding = v.subBuilding:totablearray("|", ":", "id", "pos")
		end
		if Data.sType == "FLOOR" then
			Floors[Data.level] = Data
		elseif Data.sType == "MACHINE" then
			table.insert(Machines, Data)
		end
	else
		log("[Buiding#%d]缺少基础配置", v.objectID)
	end
end

-- 机关模板关系
local OBJ_MECH = dofile("config/object_mech")
local MechMap = setmetatable({}, _G.MT.AutoGen)
for _,v in ipairs(OBJ_MECH) do
	local Data = DB[v.ID]
	if Data then Data.mech = true end

	MechMap[v.ID][v.status] = v.tempID
	MechMap[v.tempID][0] = v.ID
end
setmetatable(MechMap, nil)

-- 建造组关系
local BuildGrp = {}
local BUILD_GROUP = dofile("config/building_group")
for i,v in ipairs(BUILD_GROUP) do
	BuildGrp[v.groupID] = {
		id = v.groupID, nBuild = v.initialBuildNum,
		Step = { level = v.levelStep, amount = v.additionBuildNum, },

		name = text_obj("building_group", "groupName", v),
	}
end

local BuildTypeList = {}
local BUILDING_BUILDTYPE = dofile("config/building_buildtype")
for _,v in pairs(BUILDING_BUILDTYPE) do
	BuildTypeList[v.ID] = {
		id = v.ID,
		sortIndex = v.sort,
		name = text_obj("building_buildtype", "typeName", v),
		mType = v.ID == 1 and BuildMType[1] or BuildMType[2]
	}
end
table.sort(BuildTypeList, function (a, b)
	return a.sortIndex < b.sortIndex
end)

DB[0] = {
	id = 0,
}

local P = { DB = DB, }

function P.get_dat(dat)
	return DB[dat]
end

function P.get_tmpl(tmpl, status)
	local Tmpls = MechMap[tmpl]
	local tmp = Tmpls and Tmpls[status]
	return TmplDB[tmp or tmpl]
end

local function sort_building(a, b)
	if a.reqPlayerLevel ~= b.reqPlayerLevel then
		return a.reqPlayerLevel < b.reqPlayerLevel
	end
	if a.sort == b.sort then
		return a.id < b.id
	end
	return a.sort < b.sort
end

function P.gen_building_list(playerLevel)
	if BUILDING_LIST == nil then
		BUILDING_LIST = {}
		for _,v in pairs(DB) do
			if v.building and v.method == "Build" then
				table.insert(BUILDING_LIST, v)
			end
		end
		table.sort(BUILDING_LIST, sort_building)
	end

	local Buildings, Furnitures = {}, {}
	for _,v in pairs(BUILDING_LIST) do
		if v.reqPlayerLevel and v.reqPlayerLevel <= playerLevel then
			if v.mType == "BUILDING" then
				table.insert(Buildings, v)
			else
				table.insert(Furnitures, v)
			end
		end
	end
	return Buildings, Furnitures
end

function P.get_building_list_levelrang(maxlevel,minlevel)
	if BUILDING_LIST == nil then
		BUILDING_LIST = {}
		for _,v in pairs(DB) do
			if v.building and v.method == "Build" then
				table.insert(BUILDING_LIST, v)
			end
		end
		table.sort(BUILDING_LIST, sort_building)
	end

	local Buildings, Furnitures = {}, {}
	for _,v in pairs(BUILDING_LIST) do
		if v.reqPlayerLevel and v.reqPlayerLevel <= maxlevel and v.reqPlayerLevel > minlevel then
			if v.mType == "BUILDING" then
				table.insert(Buildings, v)
			else
				table.insert(Furnitures, v)
			end
		end
	end
	return Buildings, Furnitures
end

function P.get_floor_data(level)
	return Floors[level]
end

function P.get_build_group(grp)
	return BuildGrp[grp] or libunity.LogW("建筑组#{0}不存在", grp)
end

function P.get_buildtype_list()
	return BuildTypeList
end

function P.get_buildtype(typeIndex)
	return BuildTypeList[typeIndex] or libunity.LogW("建筑类型#{0}不存在", grp)
end

local MachiningsForItem = {}
function P.get_machinings_for_item(dat)
	local Machinings = MachiningsForItem[dat]
	if Machinings == nil then
		local WorkingLIB = config("workinglib")
		Machinings = {}
		for _,v in ipairs(Machines) do
			for _,formula in ipairs(v.Formula) do
				local Formula = WorkingLIB.get_dat(formula)
				if Formula and Formula.Product.id == dat then
					table.insert(Machinings, { Machine = v, Formula = Formula, })
				end
			end
		end
	end
	return Machinings
end

log()

return P