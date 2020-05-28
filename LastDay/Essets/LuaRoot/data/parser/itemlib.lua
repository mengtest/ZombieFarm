--
-- @file    data/parser/itemlib.lua
-- @authors xing weizhen (xingweizhen@firedoggame.com)
-- @date    2017-10-27 23:24:47
-- @desc    描述
--

local text_obj = config("textlib").text_obj
local log = _G.newlog()
local TIME_SCALE = _G.CVar.TIME_SCALE
local LENGTH_SCALE = _G.CVar.LENGTH_SCALE
local DB = {}
local CooldownGroupDB = {}

local Attrs = config("attrlib")
local AttrDEF = _G.DEF.Attr
local ItemMType = _G.CVar.ItemMType
local ItemSType = _G.CVar.ItemSType

local ITEM_COOLDOWN = dofile("config/item_cooldown")
for _,v in ipairs(ITEM_COOLDOWN) do
	CooldownGroupDB[v.GroupID] = v.cooldown / 1000
end

local ITEM_MAIN = dofile("config/item_item")
for _,v in ipairs(ITEM_MAIN) do
	DB[v.ID] = {
		id = v.ID,
		mType = ItemMType[v.type],
		sType = ItemSType[v.type][v.subType],
		-- 交易类型
		category = v.tradeType, subCategory = v.tradeSubType,

		typeValue = v.type,
		nStack = v.stackSize, destroyable = v.ableToDestory == 1,
		shortcut = v.quickBar == 1,

		icon = v.icon,
		name = text_obj("item_item", "itemName", v),
		desc = text_obj("item_item", "itemDescription", v),
		dragSfx = v.itemMoveVoice, dropSfx = v.itemDropVoice,
		score = v.score,
		isRefined = v.refinedIcon == 1,
		rarity = v.rarity,
	}
end

local ItemLossType = _G.CVar.ItemLossType
local ITEM_EQUIP = dofile("config/item_equip")
for _,v in ipairs(ITEM_EQUIP) do
	local Base = DB[v.ID]
	if Base then
		Base.lossless = v.ableToConsume == 2
		Base.lossType = ItemLossType[v.consumeType]
		Base.dura = v.maxDurability
		Base.Attr = Attrs.get_dat(v.combatID)
		Base.model = v.model
		Base.affixIdx = v.holdingPosition
		Base.lossSfx = v.brokenSFX
		Base.equipSfx = v.wearSFX

		if v.visionType == 1 then
			Base.ExAttr = AttrDEF.new { visionAdd = v.visionAmend * LENGTH_SCALE }
		elseif v.visionType == 2 then
			Base.ExAttr = AttrDEF.new { visionReplace = v.visionAmend * LENGTH_SCALE }
		end

		if Base.Attr == nil and v.combatID ~= 0 then
			log("装备#%d的属性配置#%d不存在", v.ID, v.combatID)
		end
	else
	end
end

local ITEM_WEAPON = dofile("config/item_weapon")
for _,v in ipairs(ITEM_WEAPON) do
	local Base = DB[v.ID]
	if Base then
		Base.wType = v.type
		Base.Oper = table.arrvalue(v.interactiveID:splitn("|"))
		Base.prepare = v.equipTime * TIME_SCALE
		Base.ammo = v.magazine
		Base.sneak = v.sneak == 1
		Base.Attr.fast = v.attackSpeed / 1000

		Base.Skills = v.skill:splitn("|")
		Base.reload = v.reloadSkill
		Base.Passive = v.passive:splitn("|")
		Base.fxBundle = v.packageFX
		Base.sfxBank = v.packageSFX
		if Base.affixIdx == 0 then
			log("武器#%d持握位置不正确(=%d)", v.ID, Base.affixIdx)
			Base.affixIdx = 1
		end
	else
	end
end

local ITEM_THROW = dofile("config/item_throw")
for _,v in ipairs(ITEM_THROW) do
	local Base = DB[v.ID]
	if Base then
		Base.Skills = { v.skill }
		Base.Passive = v.passive:splitn("|")
		Base.fxBundle = v.packageFX
		Base.sfxBank = v.packageSFX
	else
	end
end

local ITEM_USE = dofile("config/item_use")
for _,v in ipairs(ITEM_USE) do
	local Base = DB[v.ID]
	if Base then
		Base.useSfx = v.SFX
		Base.cooldownGroupID = v.cooldownGroup

		-- 单位为秒
		Base.cooldown = v.selfCooldown / 1000
		Base.cooldownGroup = CooldownGroupDB[v.cooldownGroup]
	else
	end
end

local Categories = {}
for i,v in ipairs(dofile("config/item_type")) do
	table.insert(Categories, { id = v.ID, name = text_obj("item_type", "typeName", v), })
end

local SubCategoriesMap = setmetatable({}, _G.MT.AutoGen)
for i,v in ipairs(dofile("config/item_subtype")) do
	table.insert(SubCategoriesMap[v.ID], { id = v.subID, name = text_obj("item_subtype", "subTypeName", v),})
end
setmetatable(SubCategoriesMap, nil)

log()

local P = {
	BLUEPRINT = 100,
	Categories = Categories, SubCategoriesMap = SubCategoriesMap,
}

DB[P.BLUEPRINT] = {
	id = P.BLUEPRINT,
	model = "S_Blueprint",
	affixIdx = 1,
	prepare = 0,
	Attr = { pose = 0, },
}
function P.get_dat(dat)
	local data = DB[dat]
	if data == nil then
		print(debug.traceback())
		libunity.LogE("[itemlib]item data is nil.ID:{0}", dat)
	end
	return data
end

return P
