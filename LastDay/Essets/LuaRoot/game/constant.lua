--
-- @file    game/constant.lua
-- @anthor  xingweizhen (weizhen.xing@funplus.com)
-- @date    2017-11-09 11:08:00
-- @desc    描述
--

local CVar = _G.CVar
CVar.TIME_SCALE = 0.03
CVar.LENGTH_MUL = 1000
CVar.LENGTH_SCALE = 1 / CVar.LENGTH_MUL
CVar.HEART_BEAT_INTERVAL = 10

CVar.UNIT_ID_FOR_PET = 1000000

--资源类型
CVar.ASSET_TYPE =
{
	Vitality = 1,--体力
	Gold = 3,--金币
	Exp = 4,--经验
	Spirit = 5,--精神值
	HP = 6,--生命值
	--Exploit = 7,--功勋值(公会)
	FoodSatis = 8,--饱食度
	WaterSatura = 9,--饱水度
	Cleanliness = 10,--清洁度
	Excretion = 11,--排泄度
	Talent = 12,--天赋点
	Exploit = 13,--功勋值(公会)
	GuildEnergy = 14,--公会电力
}

-- 营地地图ID
CVar.HOME_ID = 1

-- 自定义动作区间 [0-80)基础动作 [80-90)宠物动作  [90-100)人物动作表情
CVar.NORMAL_OPER = 80
CVar.PET_OPER = 90
CVar.EMOTE_OPER = 100
CVar.MAX_OPER = 100

-- 生存时长BuffID
CVar.SURVIVE_BUFF_ID = 5

CVar.UnitType = {
	[1] = "Player", [2] = "Monster", [3] = "Mine", [4] = "Npc",  --[5] = "Pet",
	[6] = "Reedbed",[7] = "Building", [8] = "Corpse",
}

-- 道具主类型
CVar.ItemMType = {
	"ASSET", "PROP", "EQUIP", "MAT",
}
-- 道具子类型
CVar.ItemSType = {
	[1] = { },
	[2] = { "USE", "THROW", },
	[3] = { "WEAPON", "", "BAG", "HEAD", "BODY", "LEG", "FOOT", },
	[4] = { },
	[5] = { },
	[6] = { },
}

-- 道具损耗类型
CVar.ItemLossType = {
	"Destroy", "Invalid",
}

-- 建筑主类型
CVar.BuildMType = {
	"BUILDING", "FURNITURE",
}
-- 道具子类型
CVar.BuildSType = {
	[1] = { "FLOOR", "WALL", "DOOR", "WINDOW" },
	[2] = {
		[11] = "PACKAGE", [12] = "MACHINE", [13] = "DEFENCE",
	},
}

-- 角色头发颜色
CVar.RoleHairColorsArray = {
	{ id = 4, color = "#1D2327", [3] = "#171C24", },
	{ id = 2, color = "#A3782A", [3] = "#8B631C", },
	{ id = 3, color = "#602222", [3] = "#541B1B", },
	{ id = 1, color = "#9F9F9F", hide = true, },
}
-- 性别图标
CVar.RoleGenderIcon = {
	"Common/ico_cc_015", "Common/ico_cc_014",
}
-- 默认服装资源
local GenderTag = { "M", "F", }
local ColorTag = { "W", "Y", "B", }
CVar.GenderTag = GenderTag
CVar.ColorTag = ColorTag

function CVar.get_defface(gender, color, face)
	return string.format("CHead_%s_%s_%d", GenderTag[gender], ColorTag[color], face)
end
function CVar.get_defdress(part, gender, color, face)
	local dressName
	if part == "Head" then
		dressName = CVar.get_defface(gender, color, face)
	else
		dressName = string.format("C%s_%s", part, GenderTag[gender])
	end
	return string.format("%s/%s/%s", part, dressName, dressName)
end

function CVar.get_defdresses(gender, color, face)
	return {
		CVar.get_defdress("Head", gender, color, face),
		CVar.get_defdress("Body", gender),
		CVar.get_defdress("Legs", gender),
		CVar.get_defdress("Feet", gender),
	}
end
function CVar.get_dress(part, name, gender)
	local dressName = string.format("%s_%s", name, GenderTag[gender])
	return string.format("%s/%s/%s", part, dressName, dressName)
end

function CVar.get_hair(gender, no)
	return string.format("CHair_%s_%d", GenderTag[gender], no)
end
function CVar.get_skin(gender, color)
	return GenderTag[gender]..ColorTag[color]
end

-- 装备类型对应资源组名
CVar.SType2Dress = {
	WEAPON = "Weapon", HEAD = "Head", BODY = "Body", LEG = "Legs", FOOT = "Feet", BAG = "Bag",
}

local ITEM_LIMIT, CAP_LIMIT = 1000, 100
-- 每个单位拥有的道具上限
CVar.OBJ_ITEM_LIMIT = ITEM_LIMIT
-- 每个背包的容量上限
CVar.PACKAGE_CAP_LIMIT = CAP_LIMIT

--生成item的index
--obj摸的物件id  bag：{0：背包；1：装备栏位} i：在该背包中的pos
function CVar.gen_item_pos(obj, bag, i)
	return obj * ITEM_LIMIT + bag * CAP_LIMIT + i
end

function CVar.split_item_pos(index)
	return math.floor(index / ITEM_LIMIT), index % ITEM_LIMIT
end

function CVar.split_item_idx(index)
	local obj, pos = CVar.split_item_pos(index)
	local bag, idx = math.floor(pos / CAP_LIMIT), pos % CAP_LIMIT
	return obj, bag, idx
end

-- 装备的位置编号定义
CVar.EQUIP_POS_ZERO = 100
CVar.EQUIP_MAJOR_POS = 102
CVar.EQUIP_MINOR_POS = 101
CVar.EQUIP_HEAD_POS = 103
CVar.EQUIP_BODY_POS = 104
CVar.EQUIP_LEG_POS = 105
CVar.EQUIP_FOOT_POS = 106
CVar.EQUIP_BAG_POS = 107
CVar.EQUIP_LPOCKET_POS = 108
CVar.EQUIP_RPOCKET_POS = 109

-- 服装数量（Avatar）
CVar.DRESS_NUM = 4
-- 装备槽位序号对应位置编号
CVar.EQUIP_SLOT2POS = {
	CVar.EQUIP_HEAD_POS,
	CVar.EQUIP_BODY_POS,
	CVar.EQUIP_LEG_POS,
	CVar.EQUIP_FOOT_POS,
	CVar.EQUIP_BAG_POS,
}
-- 装备类型对应槽位序号
CVar.EQUIP_TYPE2SLOT = {
	HEAD = 1, BODY = 2, LEG = 3, FOOT = 4, BAG = 5,
}
CVar.EQUIP_TYPE2POS = {
	WEAPON = CVar.EQUIP_MAJOR_POS,
	HEAD = CVar.EQUIP_HEAD_POS,
	BODY = CVar.EQUIP_BODY_POS,
	LEG = CVar.EQUIP_LEG_POS,
	FOOT = CVar.EQUIP_FOOT_POS,
}

-- 装备位置编号对应道具的类型
CVar.EQUIP_POS2TYPE = {
	[CVar.EQUIP_MAJOR_POS] = "WEAPON", [CVar.EQUIP_MINOR_POS] = "WEAPON",
	[CVar.EQUIP_HEAD_POS] = "HEAD",
	[CVar.EQUIP_BODY_POS] = "BODY",
	[CVar.EQUIP_LEG_POS] = "LEG",
	[CVar.EQUIP_FOOT_POS] = "FOOT",
	[CVar.EQUIP_BAG_POS] = "BAG",
	[CVar.EQUIP_LPOCKET_POS] = "THROW",
	[CVar.EQUIP_RPOCKET_POS] = "THROW",
}

-- 装备位置编号对应道具表现分类
CVar.EQUIP_POS2NAME = {
	[CVar.EQUIP_MAJOR_POS] = "major",
	[CVar.EQUIP_MINOR_POS] = "minor",
	[CVar.EQUIP_HEAD_POS] = "dress",
	[CVar.EQUIP_BODY_POS] = "dress",
	[CVar.EQUIP_LEG_POS] = "dress",
	[CVar.EQUIP_FOOT_POS] = "dress",
	[CVar.EQUIP_LPOCKET_POS] = "pocket",
	[CVar.EQUIP_RPOCKET_POS] = "pocket",
	[CVar.EQUIP_BAG_POS] = "bag",
}

--机器人部件数量
CVar.ROBOT_MECHPARTS_NUM = 6
CVar.ROBOT_MECHPARTS_TYPE = {
	[1] = "RArms",
	[2] = "RTrack",
	[3] = "RBackpack",
	[4] = "RBody"
}

-- 建造方法枚举
CVar.BuildMethod = {
	[0] = "Transform", [1] = "Build", [2] = "Upgrade",
}

-- 世界地图
-- 世界地图 - 常量
CVar.TravelTool = {
	walk = 1,
	back = 31, rush = 32,
}
-- 世界地图 - 移动方式图标
local DefTravelIcon = { icon = "MOW/ico_mow_005", color = "#0AAEE4", costIco = "Common/ico_mow_07" }
CVar.TravelICON = {
	Walk = { icon = "MOW/ico_mow_012", color = "#546C52", costIco = "Common/ico_mow_028" },
	Rush = { icon = "MOW/ico_mow_023", color = "#0AAEE4", costIco = "Common/ico_mow_028" },
	Drive = setmetatable({
		[2] = DefTravelIcon,
	}, { __index = function (t, k) return DefTravelIcon end }),
}

function CVar.get_travel_icon(tool)
	local TravelTool = CVar.TravelTool
	local TravelIcon
	if tool == TravelTool.back or tool == TravelTool.rush then
		return CVar.TravelICON.Rush
	elseif tool == TravelTool.walk then
		return CVar.TravelICON.Walk
	else
		return CVar.TravelICON.Drive[tool]
	end
end

-- 阵营颜色
CVar.UnitColors = {
	harm = "#D64309", neutral = "#FF9C00", help = "#00C54A", team = "#09D6D2",
}

-- ============================================================================
-- 配置表常量
-- ============================================================================
local CFGConst = setmetatable({}, _G.MT.AutoGen)

local CONST_GAME = dofile("config/constant_game")
for i,v in ipairs(CONST_GAME) do
	local klass, key = v.name:match("(%a+)%.(%a+)")
	if klass and key then
		CFGConst[klass:upper()][key] = tonumber(v.value) or v.value
	else
		CFGConst[v.name] = tonumber(v.value) or v.value
	end
end

local CONST_BATTLE = dofile("config/constant_battle")
for i,v in ipairs(CONST_BATTLE) do
	local klass, key = v.name:match("(%a+)%.(%a+)")
	if klass and key then
		CFGConst[klass:upper()][key] = tonumber(v.value) or v.value
	else
		CFGConst[v.name] = tonumber(v.value) or v.value
	end
end

for k,v in pairs(CFGConst) do
	CVar[k] = v
end

-- ============================================================================

-- 行囊格子数量
CVar.POCKET_NUM = tonumber(CVar.GAME.PlayerInitialBagCapacity)
CVar.BACKPACK_MIN = 15
-- 背包最大格子数量
CVar.BACKPACK_NUM = 90

-- 聊天频道定义（1、私聊 2、世界 3、 公会 4、队伍 5、附近 7、黑名单（不属于聊天频道））
CVar.ChatChannel = {
	GUILD = 3,	-- guild,
	TEAM = 4,  -- team,
	NEARBY = 5,	-- nearby,
	STRANGER = 6,  -- stranger,陌生人属于私聊频道friend
	FRIEND = 1,	-- whisper,好友通讯录也属于私聊频道
	BLACK = 7,	-- black,
	WORLD = 2,	-- world
}
CVar.RedDotName = {
	Root = "Root",			--根节点
	FriendApply = "FriendApply",--好友申请按钮
	ChatNew = "ChatNew",		--主界面聊天信息
	FriendNew = "FriendNew",	--聊天主界面好友页签
	StrangerNew = "StrangerNew",	--聊天主界面陌生人页签
	CraftNew = "CraftNew",        --工艺
	BuildNew = "BuildNew",        --建筑
	BuildHouse = "BuildHouse",		--房屋（建筑）
	BuildDevice = "BuildDevice",		--设备（建筑）
	BuildFurniture = "BuildFurniture",	--家具（建筑）
	BuildSpecial = "BuildSpecial",	--特殊（建筑）
	MailNew = "MailNew",			--邮件
	TaskRecode = "TaskRecode",			--任务奖励
}

CVar.TextAnchor = {
        --Text is anchored in upper left corner.
        UpperLeft = 0,
        --Text is anchored in upper side, centered horizontally.
        UpperCenter = 1,
        --Text is anchored in upper right corner.
        UpperRight = 2,
        --Text is anchored in left side, centered vertically.
        MiddleLeft = 3,
        --Text is centered both horizontally and vertically.
        MiddleCenter = 4,
        --Text is anchored in right side, centered vertically.
        MiddleRight = 5,
        --Text is anchored in lower left corner.
        LowerLeft = 6,
        --Text is anchored in lower side, centered horizontally.
        LowerCenter = 7,
        --Text is anchored in lower right corner.
        LowerRight = 8,
}
CVar.ChatSource = {
	None = 0,
	Nearby = 1,
	Guild = 2,
	Team = 3,
	Search = 4,
}
-- 资产恢复周期
local RecoveryCycles = {
	[1] = tonumber(CVar.GAME.PlayerRecoverEnergy)
}
function CVar.get_recovery_cycle(id)
	return RecoveryCycles[id] or 0
end

local PickupRepairCost
function CVar.get_pickup_repair_cost()
	if  PickupRepairCost == nil then
		local Data = CVar.PICKUP.RepairCost:totable(":", "id", "amount")
		PickupRepairCost = _G.DEF.Item.gen(Data)
	end
	return PickupRepairCost
end

-- 气味转为清洁度等级
function CVar.smell_value2level(value)
	return math.floor(value / CVar.BATTLE.PlayerCleanlinessLevelRate) + 1
end

CVar.SHOP_TYPE = {
	VIRTUAL_SHOP = 0,--虚拟商店
	GUILD_SHOP = 1,--公会商店
}

--虚拟商店商品id
CVar.VIRTUAL_GOODS = {
	ENERGY = 1,--体力
	KEY_BUNKER = 107,
	MBPass= 601,--地堡通行证
}

CVar.FRIEND_TYPE = {
	FRIEND = 1,
	BLACKLIST = 2,
	APPLYLIST = 3,
}

-- 成就定义
 CVar.Achieves = {
 	GUILD = 1, CHAT = 2, TRADE = 3, RADIO = 4, PICKUP = 5,
 }

return CVar
