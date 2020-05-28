--
-- @file    data/object/unit.lua
-- @anthor  xingweizhen (weizhen.xing@funplus.com)
-- @date    2017-10-25 20:51:04
-- @desc    描述
--

local Vector3 = UE.Vector3
local OBJDEF = {}
OBJDEF.__index = OBJDEF
OBJDEF.__tostring = function (self)
	return string.format("[<%s>#%s(%s) CAMP:%s]",
		tostring(self.class), tostring(self.id), tostring(self.dat), tostring(self.camp))
end
OBJDEF.LIB = "unitlib"
OBJDEF.get_base_data = table.get_base_data

local AlwaysViewModels = {
	["mi_bigairdrop"] = true,
}

local UnitType = _G.CVar.UnitType

local UnitClass2Prefab = setmetatable({
	Role = "Role",
	Pet = "Pet",
	Reedbed = "",
}, { __index = function (t, n) return "Entity" end })

function OBJDEF.new(id, dat, camp)
	return setmetatable({ id = id, dat = dat, camp = camp, }, OBJDEF)
end

function OBJDEF.create(id, dat, camp, coord, angle)
	local self = OBJDEF.new(id, dat, camp)
	return self:set_location(coord, angle)
end

function OBJDEF:reset()
	self.coord = nil
	self.Form = nil
end

function OBJDEF:offensive()
	if self.Skills then return #self.Skills > 0 end

	local Base = self:get_base_data()
	return Base.Skills and #Base.Skills > 0
end

function OBJDEF:get_name()
	if self.name and #self.name > 0 then return self.name end

	local name = self:get_base_data().name
	if self.nid and self.nid > 0 then
		return string.format("%s %s", name, config("textlib").get_dat(self.nid))
	end
	return name
end

function OBJDEF:gen_item_pos(pos)
	return self.player and pos or self.id * 1000 + pos
end

function OBJDEF:set_location(coord, angle)
	self.coord = coord
	self.angle = angle
	return self
end

function OBJDEF:get_oper(objId)
	local Base = self:get_base_data()
	local interact = self.interact or Base.interact

	-- 特殊的交互标志，本身不支持交互，表示死亡的单位保留尸体
	if interact < 0 then return 0 end

	if self.operLimit and not table.void(self.operLimit) then
		local uid, pid, camp = objId
		if objId then
			local Obj = _G.PKG["game/ctrl"].get_obj(objId)
			pid = Obj.pid
			camp = Obj.camp
		else
			local selfInfo = DY_DATA:get_self()
			uid = selfInfo.id
			pid = selfInfo.pid
			camp = selfInfo.camp
		end

		local operLimit = self.operLimit
		local selfOwn = self.master == pid or self.srcObj == uid
		interact = (selfOwn and operLimit[-1]) or operLimit[camp] or operLimit[-2] or 0
	end

	if interact == nil or interact == 0 then
		-- 物件配置交互
		return Base.oper
	else
		-- 自定义交互
		local SKillLIB = config("skilllib")
		-- 传送点
		if self.ExInfo and self.ExInfo.Port then return SKillLIB.PORT_ID end

		-- 其他交互动作
		return SKillLIB.get_oper(interact)
	end
end

function OBJDEF:get_class()
	local Base = self:get_base_data()
	local class = self.class or Base.class
	return class or "Entity"
end

function OBJDEF:set_dress(pos, Dress)
	local Dresses = table.need(self, "Dresses")
	Dresses[pos] = Dress
end

function OBJDEF:get_dress(pos)
	local Dresses = self.Dresses
	local Dress = Dresses and Dresses[pos]
	if type(Dress) == "number" then
		Dress = DY_DATA:iget_item(Dress)
		Dresses[pos] = Dress
	end

	return Dress
end

function OBJDEF:set_weapon(Major, Minor)
	self.MajorWeapon = Major
	self.MinorWeapon = Minor
end

function OBJDEF:get_weapon()
	local Major, Minor = self.MajorWeapon, self.MinorWeapon
	if type(Major) == "number" then
		Major = DY_DATA:iget_item(Major)
		self.MajorWeapon = Major
	end
	if type(Minor) == "number" then
		Minor = DY_DATA:iget_item(Minor)
		self.MinorWeapon = Minor
	end
	return Major, Minor
end

function OBJDEF:get_equipped(Item)
	local Diff
	local majorPos = self:gen_item_pos(_G.CVar.EQUIP_MAJOR_POS)
	local itemLimit = self:gen_item_pos(_G.CVar.OBJ_ITEM_LIMIT)
	if Item.pos == nil or Item.pos < majorPos or Item.pos > itemLimit then
		local ItemBase = Item:get_base_data()
		if ItemBase.mType == "EQUIP" then
			local pos = _G.CVar.EQUIP_TYPE2POS[ItemBase.sType]
			if pos == nil then return end

			Diff = DY_DATA:iget_item(self:gen_item_pos(pos))
			if Diff == nil and ItemBase.sType == "WEAPON" then
				Diff = _G.DEF.Item.new(1000)
			end
		end
		if Diff == nil then Diff = true end
	end
	return Diff
end

function OBJDEF:set_status(newStatus)
	local oldStatus = self.status
	if oldStatus ~= newStatus then
		self.status = newStatus

		-- 检查是不是一个机关
		local mech = self:get_base_data().mech
		if mech then
			self.tmplIdx = newStatus
			if oldStatus then
				-- 机关模板发生变化
				self.Base = nil
				self.Tmpl = nil
				self.datDirty = true
			end
		else
			self.statusDirty = true
			if self.type == "Player" then
				if oldStatus then
					self.stealth = newStatus == 2
				end
			elseif self.type == "Monster" then
				self.idleStatus = newStatus == 0 and nil or newStatus
			end
		end
	end
end

function OBJDEF:get_skills()
	return self.Skills
end

function OBJDEF:calc_attr()
	local Base = self:get_base_data()
	return Base.Attr
end

function OBJDEF:get_action()
	return self.NWObjAction
end

function OBJDEF:get_tmpl_data()
	local Tmpl = self.Tmpl
	if Tmpl == nil then
		local tmpl = self:get_base_data().tmpl
		Tmpl = config("unitlib").get_tmpl(tmpl, self.tmplIdx or 0)
		self.Tmpl = Tmpl
	end

	if self.Tmpl == nil then
		libunity.LogE("没有模板信息。id:"..tostring(self.id)..",dat:"..tostring(self.dat))
		return
	end

	return Tmpl
end

function OBJDEF:get_form_data()
	if self.class == "Reedbed" then
		local FormData = {
			class = self.class,
			View = { prefab = "", },
			Data = {
				Init = {
					id = self.id,
					camp = self.camp,
					coord = self.coord,
					status = self.status,
				},
				group = self.group,
			}
		}
		self.Form = FormData
		return FormData
	end

	local Base = self:get_base_data()
	local Tmpl = self:get_tmpl_data()
	local BaseAttr = self:calc_attr()
	local InitAttr, Attr
	if BaseAttr then
		InitAttr = _G.DEF.Attr.Empty + BaseAttr
		Attr = _G.DEF.Attr.Empty + BaseAttr
	end

	if self.hp and InitAttr then InitAttr.hp = self.hp end

	if self.Attr and Attr then
		for k,v in pairs(self.Attr) do
			Attr[k] = v
		end
	end

	if Attr then
		Attr.sneak = Attr.move
	end

	if Base and Tmpl then
		local isdead = self.hp and self.hp == 0
		local Corpse = isdead and Tmpl.Corpse or nil
		local class = Corpse and "LivingEntity" or self:get_class()

		local modelName = self.randomModelIndex and Tmpl.modelGroup[self.randomModelIndex] or Tmpl.model

		local View = {
			name = Base.name,
			prefab = self.prefab or UnitClass2Prefab[class],

			model = modelName,
			Fxes = {
				footstep = Tmpl.footstepSfx,
				hurtSfx = Tmpl.hurtSfx,
				deadFx = Tmpl.deadFx,
				deadSfx = Tmpl.deadSfx,
				mapIco = Corpse and Corpse.ico or Tmpl.mapIco,
				modelScale = Base.scale,
			},
			bodyMat = Base.bodyMat or 0,
			fxBundle = Tmpl.fxBundle,
			sfxBank = Tmpl.sfxBank,
			subMode = Base.subBuilding,
			alwaysView = AlwaysViewModels[modelName],
		}

		local obstacle = self.obstacle
		if isdead then
			obstacle = false
		elseif obstacle == nil then
			obstacle = Tmpl.obstacle
		end

		local Init = {
			size = Tmpl.size,
			coord = self.coord,
			status = self.status,
			stealth = self.stealth == true,
			angle = self.angle,
			camp = self.camp,
			master = self.master,
			id = self.id, dat = self.dat,

			layer = Corpse and Corpse.layer or Tmpl.mapLayer,

			Attr = InitAttr,
			operLimit = self.operLimit,
			operId = self:get_oper() or -1,
			obstacle = obstacle,
			blockLevel = Tmpl.blockLevel,
			disappear = self.disappear,

			state = self.state,
			tarCoord = self.tarCoord or self.coord,
			tarAngle = self.tarAngle or self.angle,

			offensive = self:offensive(),
			Death = self.Death,
		}

		local FormData = {
			class = class,
			View = View,
			Data = {
				Init = Init,
				Attr = Attr,
				Skills = self:get_skills(),
			},
		}

		self.Form = FormData
		return FormData
	end
end

-- @
-- Network Data

function OBJDEF.read_vector(nm)
	local x, y = nm:readU32() / 1000, nm:readU32() / 1000
	local angle = nm:readU32()
	return Vector3(x, 0, y), angle
end

function OBJDEF:read_equips(nm)
	local Equips = nm:readArray({}, nm.readU32)

	-- 玩家自己的装备从自己的装备槽位获得，忽略此处的映射
	if self.class == "Player" then return end

	local NewWeapon = 0
	local NewDresses = { 0, 0, 0, 0, 0 }
	local OldDresses = table.need(self, "Dresses")

	local ItemLIB = config("itemlib")
	local ItemDEF = _G.DEF.Item
	local EQUIP_SLOT2POS = _G.CVar.EQUIP_SLOT2POS
	local EQUIP_TYPE2SLOT = _G.CVar.EQUIP_TYPE2SLOT

	for _,v in ipairs(Equips) do
		if v > 0 then
			local ItemBase = ItemLIB.get_dat(v)
			if ItemBase.wType then
				NewWeapon = self.MajorWeapon
				if NewWeapon == 0 or type(NewWeapon) ~= "table" or NewWeapon.dat ~= v then
					-- class等于none时，表示这不是一个战斗单位实体
					if self.class ~= "none" then
						local majorPos = self:gen_item_pos(_G.CVar.EQUIP_MAJOR_POS)
						DY_DATA:iset_item(majorPos, ItemDEF.create(majorPos, v, 1))
						NewWeapon = majorPos
					else
						NewWeapon = ItemDEF.new(v, 1)
					end
				end
			else
				local slot = EQUIP_TYPE2SLOT[ItemBase.sType]
				if slot then
					local Dress = OldDresses[slot]
					NewDresses[slot] = Dress
					if Dress == 0 or type(Dress) ~= "table" or Dress.dat ~= v then
						if self.class ~= "none" then
							local dressPos = self:gen_item_pos(EQUIP_SLOT2POS[slot])
							DY_DATA:iset_item(dressPos, ItemDEF.create(dressPos, v, 1))
							NewDresses[slot] = dressPos
						else
							NewDresses[slot] = ItemDEF.new(v, 1)
						end
					end
				end
			end
		end
	end

	self.MajorWeapon = NewWeapon
	self.Dresses = NewDresses
end

function OBJDEF:read_skills(nm)
	self.Skills = nm:readArray({}, nm.readU32)
end

function OBJDEF:read_buffs(nm)
	local Buffs = {}
	local n = nm:readU32()
	for i=1,n do
		local id, disappear = nm:readU32(), nm:readU64()
		table.insert(Buffs, { id = id, disappear = disappear, })
	end
	self.Buffs = Buffs
end

function OBJDEF:read_action(nm)
	local Action = { id = self.id, }
	Action.state = nm:readU32()
	local coord, angle = OBJDEF.read_vector(nm)
	self:set_location(coord, angle)

	Action.Self = { coord = coord, angle = angle }
	Action.addData = nm:readU32()
	if Action.state >= 10 and Action.state < 20 then
		Action.skill = nm:readU32()
	end
	if Action.addData > 0 then
		coord, angle = OBJDEF.read_vector(nm)
		Action.Next = { coord = coord, angle = angle }
		Action.param = nm:readU32()
		self.tarCoord = coord
		self.tarAngle = angle
	end
	self.NWObjAction = Action
	self.state = Action.state
	self.actionDirty = true
end

function OBJDEF:read_id_action(nm)
	nm:readU32()
	self:read_action(nm)
end

-- <MapObjTemplate>
function OBJDEF:read_sample(nm)
	local dat = self.dat
	self.dat = nm:readU32()
	if dat and self.dat ~= dat then
		-- 模板发生变化
		self.Base = nil
		self.Tmpl = nil
		self.datDirty = true
	end
	self:read_equips(nm)
	self:read_skills(nm)

	self.tmplDirty = true
end
function OBJDEF:read_id_sample(nm)
	nm:readU32()
	self:read_sample(nm)
end

-- <MapObjBaseInfo>
function OBJDEF:read_base(nm)
	self.camp = nm:readU32()
	local newStatus = nm:readU32()
	self.disappear = nm:readU64()
	self.interact = nm:readU32()
	self.baseDirty = true

	self:set_status(newStatus)
end

function OBJDEF:read_id_base(nm)
	nm:readU32()
	self:read_base(nm)
end

-- 单位扩展数据
function OBJDEF:read_ext(nm)
	self.operLimit = {}
	local n = nm:readU32()
	for i=1,n do
		local extType, extValue = nm:readU32(), nm:readU32()
		self.operLimit[extType] = extValue
		-- if extType == 1 then
		-- 	self.operLimit = extValue
		-- else
		-- 	libunity.LogE("{0}未知的单位扩展类型:{1}={2}", self, extType, extValue)
		-- end
	end
end

--刷新建筑工作时间
function OBJDEF:update_workingtime(lastTime, workedTime)
	self.startWorkTime = os.date2secs() - workedTime
	if lastTime > 0 then
		_G.PKG["game/timers"].launch_unitworking_timer(self.id, lastTime)
	else
		DY_TIMER.stop_timer("UnitWorking#"..self.id)
	end
end

-- <MapObjInfo>
function OBJDEF:read_info(nm)
	self.level = nm:readU32()
	self.name = nm:readString()

	local Attr = table.need(self, "Attr")
	Attr.hp = nm:readU32()
	self.hp = nm:readU32()
	self.camp = nm:readU32()
	local newStatus = nm:readU32()

	local oldType = self.type
	local unitType = UnitType[nm:readU32()]
	self.type = unitType
	self.class = nil

	self.disappear = nm:readU64()
	self.interact = nm:readU32()

	setmetatable(self, OBJDEF)
	if unitType == "Npc" then
		-- NPC
		self.class = "Entity"
	elseif unitType == "Mine" then
		-- 矿产
		self.output = nm:readU32()
	elseif unitType == "Monster" then
		-- 怪物
		self.nid = nm:readU32()
	elseif unitType == "Player" then
		-- 玩家
		self.dat = 1
		if self.class == nil then
			self.class = self.player and "Player" or "Human"
		end
		setmetatable(self, _G.DEF.Human)
		self:read_view(nm)
		self:read_pet(nm)
		self:read_id_healthy(nm)
		self.pid = nm:readU64()
	elseif unitType == "Reedbed" then
		self.dat = 0
		self.class = "Reedbed"
		self.group = nm:readU32()
	elseif unitType == "Building" then
		self.sbObjIds = nm:readArray({}, nm.readU32)
		self.master = nm:readU64()
		self.formulaID = nm:readU32()
		local lastTime = nm:readU32()
		local workedTime = nm:readU32()
		self.formulaTotalTime = lastTime + workedTime
		--debug.printG("lastTime:"..lastTime..",workedTime"..workedTime)
		self:update_workingtime(lastTime, workedTime)
		self.helpUserList = nm:readArray({}, nm.readU64)

		self.randomModelIndex = nm:readU32()
		self.remainingCap = nm:readU32()
		self.totalCap = nm:readU32()

		local Tmpl = self:get_tmpl_data()
		--保护机制
		if self.randomModelIndex < 1 then
			self.randomModelIndex = 1
		elseif self.randomModelIndex > #Tmpl.modelGroup then
			self.randomModelIndex = #Tmpl.modelGroup
		end

	elseif unitType == "Corpse" then
		-- 玩家
		self.dat = 1
		self.class = "Human"
		setmetatable(self, _G.DEF.Human)
		self:read_view(nm)
		self.srcObj = nm:readU32()
	end

	self:read_id_action(nm)
	self:read_buffs(nm)

	self:read_ext(nm)
	self.Death = { type = nm:readU32(), value = nm:readU32(), }

	if oldType ~= unitType then
		self.Form = nil
	end

	self.infoDirty = true

	self:set_status(newStatus)
end

function OBJDEF:read_id_info(nm)
	nm:readU32()
	self:read_info(nm)
end

function OBJDEF:read_full(nm)
	self:read_sample(nm)
	self:read_id_info(nm)
	self:read_id_action(nm)
end

-- @

return OBJDEF
