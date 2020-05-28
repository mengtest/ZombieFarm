--
-- @file    data/parser/skilllib.lua
-- @anthor  xingweizhen (weizhen.xing@funplus.com)
-- @date    2017-10-19 12:13:46
-- @desc    描述
--

local text_id = config("textlib").text_id
local text_obj = config("textlib").text_obj
local DB = {}

local TIME_SCALE = _G.CVar.TIME_SCALE
local LENGTH_SCALE = _G.CVar.LENGTH_SCALE
local TarID2Set = {
	[1] = 4, -- 敌人100
	[2] = 3, -- 友方=队友+自己 10 + 1
	[3] = 7, -- 所有=敌人+队友+自己 100+10+1
	[4] = 1, -- 自己=1
	[5] = 6, -- 非自己？=敌人+队友 100+10
}

local LocMap = table.tomap(dofile("config/skill_text"), "ID")
local DefLoc = { name = TEXT.Undefined, }

local EffLIB = {}
local SKILL_EFF = dofile("config/skill_effect")
for _,v in ipairs(SKILL_EFF) do
	EffLIB[v.ID] = {
		id = v.ID, func = v.type,
		Params = { v.parameter1, v.parameter2, v.parameter3, v.parameter4, v.parameter5, v.parameter6 },
	}
end

local BuffLIB = {}
local SKILL_BUFF = dofile("config/skill_buff")
for _,v in pairs(SKILL_BUFF) do
	local EffIds = v.effect:splitn("|")
	local EffFuncs = {}
	for _,v in ipairs(EffIds) do
		local Eff = EffLIB[v]
		if Eff then table.insert(EffFuncs, Eff.func) end
	end
	BuffLIB[v.ID] = {
		id = v.ID, fx = v.SE, Funcs = EffFuncs,
		icon = v.icon,
		name = text_obj("skill_buff", "buffName", v),
		desc = text_obj("skill_buff", "buffTips", v),
		hidden = v.display == 0,
	}
end

local MissileLIB = {}
local SKILL_MISSILE = dofile("config/skill_missile")
for _,v in ipairs(SKILL_MISSILE) do
	local Siz = v.size:splitn(":")
	MissileLIB[v.ID] = {
		id = v.ID,
		sizeA = (Siz[1] or 0) * LENGTH_SCALE, sizeB = (Siz[2] or 0) * LENGTH_SCALE,
		speed = v.velocity * LENGTH_SCALE, mode = v.mode, Params = v.param:splitn("|"),
		tarLimit = v.targetLimit,
		fx = v.resource,
	}
end


local SubLIB = {}
local SubResMap = table.tomap(dofile("config/skill_subresource"), "ID")
local SubDefRes = { self = "", target = "", hit = "", }
local SKILL_SUB = dofile("config/skill_sub")
for _,v in ipairs(SKILL_SUB) do
	local Res = SubResMap[v.ID] or SubDefRes
	local Fx = Res.hit:split("|")

	local Effs = {}
	for _,v in ipairs(v.effect:splitn("|")) do
		table.insert(Effs, EffLIB[v])
	end
	SubLIB[v.ID] = {
		id = v.ID, cost = v.cost, delay = v.delay * TIME_SCALE, live = v.life == 1,
		interval = v.effectInterval * TIME_SCALE, freq = v.effectNum,
		tarType = v.targetMode,
		Target = {
			tarSet = TarID2Set[v.targetCamp],
			rangeType = v.rangeType, Params = v.rangeParam:splitn(":"),
			tarLimit = v.targetMax,
		},
		Effs = Effs,
		Missile = MissileLIB[v.missileID],

		fxH = Fx[1], sfxH = Fx[2],
	}
end

-- 蓄力类技能的额外配置
local ChargeMap = setmetatable({}, _G.MT.AutoGen)
local SKILL_CHARGE = dofile("config/skill_charge")
for _,v in ipairs(SKILL_CHARGE) do
	table.insert(ChargeMap[v.ID], {
			cond = v.parameter1,
			value = v.parameter2,
			skill = v.activeSkill,
		})
end
setmetatable(ChargeMap, nil)
-- local function sort_charge_skill(a, b)
-- 	return a.charge < b.charge
-- end

-- 特殊功能技能额外配置
local SpecialMap = setmetatable({}, _G.MT.AutoGen)
local SKILL_SPECIAL = dofile("config/skill_trigger")
for i,v in ipairs(SKILL_SPECIAL) do
	table.insert(SpecialMap[v.ID], {
			func = v.Effect,
			Args = v.parameter1:splitn("|"),
		})
end
setmetatable(SpecialMap, nil)

local MainResMap = table.tomap(dofile("config/skill_resource"), "ID")
local MainDefRes = {
	icon = "", action = "", selfCasting = "", targetCasting = "", selfCasted = "", targetCasted = ""
}

local SKILL_MAIN = dofile("config/skill_skill")
for _,v in ipairs(SKILL_MAIN) do
	local Loc = LocMap[v.ID] or DefLoc
	local Res = MainResMap[v.ID] or MainDefRes
	local FxC = Res.selfCasting:split("|")
	local FxCed = Res.selfCasted:split("|")
	local ChargeIDs = ChargeMap[v.ID]
	local Specials = SpecialMap[v.ID]
	--if ChargeIDs then table.sort(ChargeIDs, sort_charge_skill) end
	local ItorArgs = v.indicator:splitn(":")
	local itorType = ItorArgs[1]
	if itorType then table.remove(ItorArgs, 1) end

	DB[v.ID] = {
		id = v.ID, combo = v.comboID,
		oper = v.operationType, mode = v.move, cost = v.cost,
		allowNullTar = v.nonTarget == 1,
		blockLevel = v.penetration,
		cooldown = v.cooldown * TIME_SCALE,
		ready = v.prepareTime * TIME_SCALE,
		cast = v.castingTime * TIME_SCALE,
		post = (v.castingTime + v.duration) * TIME_SCALE,
		delay = v.displayDelay * TIME_SCALE,
		minRange = v.minDistance * LENGTH_SCALE,
		maxRange = v.maxDistance * LENGTH_SCALE,
		alertRange = v.lockDistance * LENGTH_SCALE,
		tarSet = TarID2Set[v.referenceCamp],
		tarType = v.targetMode,
		Target = {
			tarFilter = v.targetSelect, tarSet = TarID2Set[v.targetCamp],
			rangeType = v.rangeType, Params = v.rangeParam:splitn(":"),
			tarLimit = 1,
		},
		Indicator = itorType and { type = itorType, Params = ItorArgs } or nil,

		SubIDs = v.subIndexes:splitn("|"),
		ChargeIDs = ChargeIDs,
		Specials = Specials,

		name = Loc.name,
		acts = Res.action:split("|"),
		hurt = v.hurtDisplay,

		fxC = FxC[1], fxCT = Res.targetCasting, sfxC = FxC[2],
		fxCed = FxCed[1], fxCTed = Res.targetCasted, sfxCed = FxCed[2],
	}
end

local SKILL_INTERACT = dofile("config/interactive_interactive")
for _,v in ipairs(SKILL_INTERACT) do
	DB[v.ID] = {
		id = v.ID, type = "SKILL", mode = "Fin2Move", oper = "Loop",
		damage = v.damage,
		ready = 0, cast = v.castingTime * TIME_SCALE, post = v.duration * TIME_SCALE,
		minRange = v.minDistance * LENGTH_SCALE,
		maxRange = v.maxDistance * LENGTH_SCALE,
		chkInventory = v.inventoryFull == 1,
		action = v.action, fxH = v.SE, sfxC = v.SFX,
		reqTip = text_id("interactive_interactive", "toolText", v),
		spIcon = v.icon,
	}
end

local HURT_VIEW = dofile("config/skill_hurtdisplay")
local HurtDB = {}
for _,v in ipairs(HURT_VIEW) do
	HurtDB[v.ID] = {
		sfx = v.SFX,
		Fx = { v.SE_1, v.SE_2, v.SE_3, v.SE_4, v.SE_5, },
		force = v.force,
	}
end

local P = { }

local function new_action(name, id, Data)
	P[name] = id
	Data.id = id
	DB[id] = Data
end

local MAX_POST = 99999999

-- 拾取地面物体
new_action("PICK_ID", 1, {
	type = "PICK", mode = "Fin2Move",
	damage = 0, ready = 0, delay = 20, cast = 0, post = 25, action = "Pick",
	minRange = 0, maxRange = 0.3, chkInventory = true,

	name = "Pick",
	spIcon = "ico_main_024",
})

-- 打开一个地图箱子（包括掉落）
new_action("OPEN_ID", 2, {
	type = "OPEN",
	ready = 0, delay = 0, cast = 0, post = MAX_POST, action = "Open",
	minRange = 0, maxRange = 0.5,

	name = "Open",
	spIcon = "ico_main_024",
})

-- 打开一个工作台
new_action("WORK_ID", 3, {
	type = "OPEN",
	damage = 0, ready = 0, delay = 0, cast = 0, post = MAX_POST, action = "",
	minRange = 0, maxRange = 0.5,

	name = "Work",
	--spIcon = "ico_main_024",
})

-- 触发一个机关
new_action("TRIG_ID", 4, {
	type = "TRIG",
	damage = 0, ready = 0, delay = 0, cast = 0, post = 0, action = "",
	minRange = 0, maxRange = 0.75,

	name = "Trigger",
	--spIcon = "ico_main_024",
})

-- 展开设计图纸
new_action("FOLD_ID", 5, {
	type = "SYNC", mode = "Fin2Move",
	damage = 0, ready = 0, delay = 0, cast = 0, post = MAX_POST, action = "blueprintunfold",
	minRange = 0, maxRange = 1,

	name = "Fold",
	--spIcon = "ico_main_024",
})

-- 打开一个传送设备
new_action("PORT_ID", 6, {
	type = "OPEN",
	damage = 0, ready = 0, delay = 0, cast = 0, post = 0, action = "",
	minRange = 0, maxRange = 0.5,

	name = "Port",
	--spIcon = "ico_main_024",
})

-- 排泄动作
new_action("URINATE_ID", 7, {
	type = "FUNC", mode = "Fin2Move",
	damage = 0, ready = 0, delay = 0, cast = 90, post = 90, action = "Urinate",
	minRange = 0, maxRange = 1,

	name = "Urinate",
	spIcon = "ico_main_032",

	fxC = "common/urinate",
})

-- 对话动作
new_action("TALK_ID", 8, {
	type = "FUNC", mode = "Fin2Move",
	damage = 0, ready = 0, delay = 0, cast = 0, post = MAX_POST, action = "",
	minRange = 0, maxRange = 1,

	name = "Talk",
	spIcon = "ico_main_049",
})

-- 宠物预警
new_action("PET_ALERT_ID", 81, {
	type = "SYNC",
	damage = 0, ready = 0, delay = 0,
	cast = 30, post = 30, action = "alert",
	minRange = 0, maxRange = 999999,

	name = "PetAlert",
	--spIcon = "ico_main_024",
})

-- 工作台友好交互
new_action("FRIENDLY_WORK_ID", 9, {
	type = "OPEN",
	ready = 0, delay = 0, cast = 0, post = 20, action = "Open",
	minRange = 0, maxRange = 0.5,
	interactTime = 20,

	name = "FriendlyWork",
	spIcon = "ico_main_054",
})

-- 交互动作(跟随)
new_action("EMOTE_FOLLOW_ID", 90, {
	type = "SYNC",
	ready = 0, delay = 0, cast = 0, post = 30, action = "emote_follow",
	minRange = 0, maxRange = 0.5,

	name = "EmoteFollow",
	--spIcon = "ico_main_024",
})

-- 交互动作(打招呼)
new_action("EMOTE_HI_ID", 91, {
	type = "SYNC",
	ready = 0, delay = 0, cast = 0, post = 30, action = "emote_hi",
	minRange = 0, maxRange = 0.5,

	name = "EmoteHi",
	--spIcon = "ico_main_024",
})

-- 交互动作(投降)
new_action("EMOTE_SURRENDER_ID", 92, {
	type = "SYNC",
	ready = 0, delay = 0, cast = 0, post = 30, action = "emote_surrender",
	minRange = 0, maxRange = 0.5,

	name = "EmoteSurrender",
	--spIcon = "ico_main_024",
})

-- 交互动作(嘲讽)
new_action("EMOTE_TAUNT_ID", 93, {
	type = "SYNC",
	ready = 0, delay = 0, cast = 0, post = 30, action = "emote_taunt",
	minRange = 0, maxRange = 0.5,

	name = "EmoteTaunt",
	--spIcon = "ico_main_024",
})

-- 交互类型和动作对应关系
local INTERACT_TO_ACTION = {
	-- 拾取
	[1] = P.PICK_ID,
	-- TODO 采集
	[2] = P.PICK_ID,
	-- 打开箱子
	[3] = P.OPEN_ID,
	-- 进行对话
	[4] = P.TALK_ID,
	-- 触发机关
	[5] = P.TRIG_ID,
	-- 打开工作台
	[6] = P.WORK_ID,
	-- 交互好友工作台
	[7] = P.FRIENDLY_WORK_ID,
}

function P.get_oper(interactId)
	return INTERACT_TO_ACTION[interactId]
end

function P.get_eff(id)
	return EffLIB[id]
end
function P.get_buff(id)
	return BuffLIB[id]
end
function P.get_missile(id)
	return MissileLIB[id]
end
function P.get_sub(id)
	return SubLIB[id]
end
function P.get_dat(dat)
	local Dat = DB[dat]
	if Dat == nil then
		libunity.LogW("获取技能#{0}失败：数据不存在", dat)
	end
	return Dat
end
function P.get_hurt(id)
	return HurtDB[id]
end

return P
