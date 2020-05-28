--
-- @file    debug/d_stage.lua
-- @anthor  xingweizhen (weizhen.xing@funplus.com)
-- @date    2017-10-31 16:13:30
-- @desc    描述
--

local UnitDEF = _G.DEF.Unit
local ItemDEF = _G.DEF.Item

math.randomseed(0)

local PosIndices = {}
local siz = 20
local total = siz * siz
for i=1,total do table.insert(PosIndices, i) end

local id = 10000
local UnitDEF = _G.DEF.Unit
local Stage = _G.DEF.Stage.new(0, 50, 50)
Stage.weather = 1
Stage:set_dat(1101)
Stage.home = true
function Stage:new_unit(dat, camp, Data)
	local nPos = #PosIndices
	if nPos > 0 then
		id = id + 1
		local index = math.random(nPos)
		local value = PosIndices[index]
		table.remove(PosIndices, index)

		local x = math.floor(value / siz)
		local y = value % siz
		local Obj = UnitDEF.new(id, dat, camp)
		Obj:set_location(UE.Vector3(x * 3, 0, y * 3), math.random(360))
		self:add_unit(Obj)
		self:cache_unit(Obj)
		if Data then for k,v in pairs(Data) do Obj[k] = v end end
		return Obj
	end
end

-- 自己
local CVar = _G.CVar
local Player = DY_DATA:get_player()
local Self = _G.DEF.Human.new(1, "Player", 3, Player.name)
Self.player = true
Self.surviveTime = os.date2secs() - 1790
Self.pid = Player.id
Self:set_view(1, 1, 1, 1, 3)
Self.level = Player.level
Self.Hunger = ItemDEF.new(8, 0)
Self.Thirsty = ItemDEF.new(9, 19)
Self.Smell = ItemDEF.new(10, 30)
Self.Urination = ItemDEF.new(11, 50)
Self.Attr = { hp = 100, }
Self.hp = 81

DY_DATA.Self = Self
Self:set_pet(801)
Self:set_weapon(DY_DATA:iget_item(CVar.EQUIP_MAJOR_POS), DY_DATA:iget_item(CVar.EQUIP_MINOR_POS))
Self:set_dress(1, DY_DATA:iget_item(CVar.EQUIP_HEAD_POS))
Self:set_dress(2, DY_DATA:iget_item(CVar.EQUIP_BODY_POS))
Self:set_dress(3, DY_DATA:iget_item(CVar.EQUIP_LEG_POS))
Self:set_dress(4, DY_DATA:iget_item(CVar.EQUIP_FOOT_POS))
Self:set_dress(5, DY_DATA:iget_item(CVar.EQUIP_BAG_POS))
Self:set_location(UE.Vector3(20, 0, 20), -45)

Stage.Self = Self
Stage:add_unit(Self)
Stage:add_unit(Self.Pet)

local genAll
--genAll = true
if genAll then
	for k,v in pairs(config("unitlib").DB) do
		if k ~= 1 then Stage:new_unit(k, 1) end
	end
return end

function Stage:gen_unit(dat, camp, pos, angle, Data)
	id = id + 1
	local Unit = UnitDEF.new(id, dat, camp)
	Unit:set_location(pos, angle)
	if Data then for k,v in pairs(Data) do Unit[k] = v end end
	self:add_unit(Unit)
end

for i=1,5 do Stage:new_unit(1001, 1) end
for i=1,5 do Stage:new_unit(1201, 1) end
for i=1,5 do Stage:new_unit(1203, 1) end
Stage:new_unit(101, 2, { hp = 0, interact = 3, disappear = 300000, })
Stage:new_unit(101, 2, { hp = 0, disappear = 300000, })
for i=1,3 do Stage:new_unit(101, 2) end
for i=1,3 do Stage:new_unit(102, 2) end
for i=1,3 do Stage:new_unit(104, 2) end
for i=1,3 do Stage:new_unit(105, 2) end
for i=1,3 do Stage:new_unit(106, 2) end
--Stage:new_unit(107, 2)
for i=1,3 do Stage:new_unit(108, 2) end
--Stage:new_unit(109, 2)
for i=1,3 do Stage:new_unit(114, 2) end
for i=1,3 do Stage:new_unit(115, 2) end
for i=1,3 do Stage:new_unit(117, 2) end
for i=1,3 do Stage:new_unit(183, 2) end
for i=1,5 do Stage:new_unit(10001, 1) end
for i=1,5 do Stage:new_unit(10002, 1) end
for i=1,5 do Stage:new_unit(10003, 1) end
Stage:new_unit(21400, 1)
Stage:new_unit(21400, 1, { status = 0, })
Stage:new_unit(21000, 1)
Stage:new_unit(51007, 1)

function Stage:build_obj(dat, x, y, angle)
	id = id + 1
	local Obj = UnitDEF.new(id, dat, 3)
	Obj:set_location(UE.Vector3(x, 0, y), angle)
	self:add_unit(Obj)
	self:cache_unit(Obj)
	return Obj
end

-- 建筑
-- 1级地板x4
Stage:build_obj(50001, 20.5, 20.5, 0)
Stage:build_obj(50001, 22.5, 20.5, 0)
Stage:build_obj(50001, 22.5, 22.5, 0)
Stage:build_obj(50001, 20.5, 22.5, 0)

-- 2级地板x4
Stage:build_obj(50002, 16.5, 20.5, 0)
Stage:build_obj(50002, 18.5, 20.5, 0)
Stage:build_obj(50002, 18.5, 22.5, 0)
Stage:build_obj(50002, 16.5, 22.5, 0)

-- 3级地板x4
Stage:build_obj(50003, 20.5, 16.5, 0)
Stage:build_obj(50003, 22.5, 16.5, 0)
Stage:build_obj(50003, 22.5, 18.5, 0)
Stage:build_obj(50003, 20.5, 18.5, 0)

Stage:build_obj(50101, 22.5, 20.5, -90)
--Stage:build_obj(50101, 20.5, 20.5, 0)
-- 工作台
local Work = Stage:build_obj(51002, 20.5, 22.5, 0)
Work.interact = 6
Work.hp = 1

-- 皮卡
local Pickup = Stage:build_obj(53031, 40.5, 40.5, 0)

function Stage:add_reed(group)
	id = id + 1
	local Obj = UnitDEF.new(id, 0, 1)
	Obj:set_location(UE.Vector3.zero, 0)
	Obj.class = "Reedbed"
	Obj.status = 1
	Obj.group = group
	self:add_unit(Obj)
end
Stage:add_reed(1)
Stage:add_reed(2)

-- 另一个人
local Passby = _G.DEF.Human.new(2, "Human", 31, "Player 2")
Passby.pid = 2
Passby.Smell = ItemDEF.new(10, 30)
Passby.Urination = ItemDEF.new(11, 0)
local Weapon = _G.DEF.Item.create(Passby:gen_item_pos(_G.CVar.EQUIP_MAJOR_POS), 1001, 1)
DY_DATA:iset_item(Weapon.pos, Weapon)
Passby:set_view(2, 1, 1, 1, 1)
Passby:set_location(UE.Vector3(10, 0, 15), 180)
Passby:set_weapon(Weapon)
Stage:add_unit(Passby)

-- 一个尸体
local Corpse = _G.DEF.Human.new(3, "Human", 21, "Player Corpse")
Corpse.hp = 0
Corpse.interact = 3
Corpse.disappear = 999999
Corpse.Urination = ItemDEF.new(11, 0)
Corpse:set_view(2, 1, 1, 3, 1)
Corpse:set_location(UE.Vector3(20.5, 0, 20.5), -45)
Stage:add_unit(Corpse)

-- 交易所员工
Stage:gen_unit(403, 1, UE.Vector3(20, 0, 15), 0, { interact = 4, dlg = 1, name = "Trade post staff" })

-- 公会采集中心NPC
Stage:gen_unit(404, 1, UE.Vector3(22, 0, 15), 0, { interact = 4, dlg = 13 })

-- 遇难者
Stage:gen_unit(403, 1, UE.Vector3(18, 0, 15), 90, { interact = 4, dlg = 40 })

-- 交易商人
Stage:gen_unit(404, 1, UE.Vector3(18, 0, 13), -90, { interact = 4, dlg = 31 })

DY_DATA.CliData = {
	Guide = { ["0"] = 0, ["4"] = 0, ["5"] = 0, },
	NewCraft = {  },
	NewBuild = {  },
}

--_G.PKG["game/ctrl"].add_reg("game/event/prelude")
