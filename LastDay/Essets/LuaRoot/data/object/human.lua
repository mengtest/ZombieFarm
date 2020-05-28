--
-- @file    data/object/human.lua
-- @authors xing weizhen (xingweizhen@firedoggame.com)
-- @date    2017-10-27 23:05:36
-- @desc    描述
--

local OBJDEF = setmetatable({}, _G.DEF.Unit)
OBJDEF.__index = OBJDEF
OBJDEF.__tostring = function (self)
	return string.format("[<玩家>#%s(%s) CAMP:%s]",
		tostring(self.id), self.name or "NONAME", tostring(self.camp))
end
OBJDEF.EMPTY_RHAND = { index = 1, path = "", }
OBJDEF.EMPTY_LHAND = { index = 2, path = "", }
OBJDEF.EMPTY_AFFIXES = {
	[5] = { index = 3, path = "" },
}

local HealthyAssets = {
	Hunger = 8, -- 饱食度
	Thirsty = 9, -- 饱水度
	Smell = 10, -- 臭味浓度
	Urination = 11, -- 排泄值
}

local ViewDEF = {}
ViewDEF.__index = ViewDEF
ViewDEF.__eq = function (a, b)
	local equal = a.skin == b.skin and a.face == b.face and a.haircolor == b.haircolor
	if not equal then return false end
	for i=1,CVar.DRESS_NUM do if a.Dresses[i] ~= b.Dresses[i] then return false end end
	return true
end

function OBJDEF.new(id, class, camp, name)
	local self = {
		id = id, dat = 1, camp = camp,
		name = name, class = class,
	}
	return setmetatable(self, OBJDEF)
end

function OBJDEF:offensive() return true end

function OBJDEF:set_view(gender, color, face, hair, haircolor)
	if gender then self.gender = gender end
	if color then self.color = color end
	if face then self.face = face end
	if hair then self.hair = hair end
	if haircolor then self.haircolor = haircolor end
end

function OBJDEF:set_pet(petDat)
	if petDat > 0 then
		local petId = CVar.UNIT_ID_FOR_PET + self.id
		local Pet = self.Pet
		if Pet == nil then
			Pet = _G.DEF.Unit.new(petId)
			Pet.Skills = {
				config("skilllib").PET_ALERT_ID,
			}
			Pet.camp = 0
			Pet.class = "Pet"
			Pet.name = self.name .. "'s Pet"
			Pet.obstacle = false
			self.Pet = Pet
		end
		Pet.parent = self.id
		if Pet.dat ~= petDat then
			Pet.dat = petDat
			Pet.Form = nil
		end
	else
		self.Pet = nil
	end
end

function OBJDEF:set_location(coord, angle)
	self.coord = coord
	self.angle = angle
	if self.Pet then
		-- 宠物在玩家右手边
		coord = coord + UE.Quaternion.Euler(0, angle + 90, 0) * UE.Vector3.forward
		self.Pet:set_location(coord, angle)
	end
	return self
end

function OBJDEF:get_weapon_data()
	local Major, Minor = self:get_weapon()
	if Major and Major:damaged() then
		Major = nil
	end
	local DEF_WEAPON_POS = _G.CVar.EQUIP_POS_ZERO
	return {
		majorId = Major and Major.pos or DEF_WEAPON_POS,
		minorId = Minor and Minor.pos or DEF_WEAPON_POS,
	}
end

function OBJDEF:calc_attr()
	local Base = self:get_base_data()
	local Attr = _G.DEF.Attr.Empty + Base.Attr
	Attr.sneak = _G.CVar.BATTLE.SneakMovementSpeed * _G.CVar.LENGTH_SCALE

	for i=1,CVar.DRESS_NUM do
		local Dress = self:get_dress(i)
		if Dress then
			local DressAttr = Dress:get_base_data().Attr
			if DressAttr then Attr = Attr + DressAttr end
		end
	end

	local Weapon, _ = self:get_weapon()
	if Weapon then
		local WeaponAttr = Weapon:calc_attr()
		if WeaponAttr then Attr = Attr + WeaponAttr end
	end

	if self.Attr then
		for k,v in pairs(self.Attr) do Attr[k] = v end
	end

	return Attr
end

function OBJDEF:get_view_dresses()
	local Dresses, dress = {}, 0
	local CVar = _G.CVar
	local DEFAULT_DRESSES = CVar.get_defdresses(self.gender, self.color, self.face)
	local SType2Dress = _G.CVar.SType2Dress
	local World = rawget(DY_DATA, "World")
	local hasInitBundle = World == nil or World:has_bundle(CVar.HOME_ID)

	for i=1,CVar.DRESS_NUM do
		local Dress = self:get_dress(i)
		local dressPath
		if hasInitBundle and Dress then
			local DressBase = Dress:get_base_data()
			local dressType = SType2Dress[DressBase.sType]
			dressPath = CVar.get_dress(dressType, DressBase.model, self.gender)
		end

		if dressPath == nil or #dressPath == 0 then
			Dresses[i] = DEFAULT_DRESSES[i]
		else
			Dresses[i] = dressPath
			dress = dress + 2 ^ (i-1)
		end
	end
	if Dresses[1] ~= DEFAULT_DRESSES[1] then
		-- 戴了头盔的情况，要把头部也放进去
		table.insert(Dresses, DEFAULT_DRESSES[1])
	else
		-- 不戴头盔，要加入发型
		local hairName = CVar.get_hair(self.gender, self.hair)
		table.insert(Dresses, string.format("Hair/%s/%s", hairName, hairName))
	end

	local hcId, haircolor = self.haircolor
	for i,v in ipairs(CVar.RoleHairColorsArray) do
		if v.id == hcId then
			haircolor = v[self.color] or v.color
		break end
	end

	return setmetatable({
		skin = CVar.get_skin(self.gender, self.color),
		face = CVar.get_defface(self.gender, self.color, self.face),
		haircolor = haircolor,
		dress = dress,
		Dresses = Dresses,
	}, ViewDEF)
end

function OBJDEF:get_view_affixes()
	local World = rawget(DY_DATA, "World")
	local hasInitBundle = World == nil or World:has_bundle(CVar.HOME_ID)

	local Affixes = {}
	for i = CVar.DRESS_NUM + 1, #CVar.EQUIP_SLOT2POS do
		local Equip = self:get_dress(i)
		if hasInitBundle and Equip then
			local EquipData = Equip:get_dress_data()
			table.insert(Affixes, EquipData)
		end
	end
	return Affixes
end

function OBJDEF:update_view_affix(slot)
	local Affix = self:get_dress(slot)
	return Affix and Affix:get_dress_data() or OBJDEF.EMPTY_AFFIXES[slot]
end

function OBJDEF:update_view_affixes(Affixes)
	local Dresses = self.Dresses
	for i = CVar.DRESS_NUM + 1, #CVar.EQUIP_SLOT2POS do
		if type(Dresses[i]) == "number" then
			table.insert(Affixes, self:update_view_affix(i))
		end
	end
end

function OBJDEF:get_form_data()
	local Base = self:get_base_data()
	local Tmpl = self:get_tmpl_data()
	local Major, Minor = self:get_weapon()
	local FinalAttr = self:calc_attr()
	local InitAttr = table.dup(FinalAttr)
	if self.hp then InitAttr.hp = self.hp end

	-- 添加气味值
	if self.Smell then
		FinalAttr.smell = _G.CVar.smell_value2level(self.Smell.amount)
	end

	local prefab, class, mapIco
	-- 玩家不会落地成盒
	prefab = self.class ~= "Player" and "Player3rd" or "Player"
	prefab = prefab .. CVar.GenderTag[self.gender]
	class = self.class
	local Corpse = self.hp and self.hp == 0 and Tmpl.Corpse or nil
	if Corpse then
		mapIco = Corpse.ico
	else
		mapIco = class == "Player" and "Battle/map_player_d" or Tmpl.mapIco
	end

	self.Form = {
		class = class,
		View = {
			name = self.name,
			prefab = prefab,
			model = self:get_view_dresses(),
			Fxes = {
				footstep = "SFX/Character/Footsteps",
				hurtSfx = Tmpl.hurtSfx,
				deadFx = Tmpl.deadFx,
				deadSfx = Tmpl.deadSfx,
				mapIco = mapIco,
			},
			bodyMat = 1,
			gender = self.gender,
			Affixes = self:get_view_affixes(),
		},
		Data = {
			Init = {
				size = Tmpl.size,
				coord = self.coord,
				status = 0,
				stealth = self.stealth == true,
				angle = self.angle,
				camp = self.camp,
				id = self.id, dat = self.dat,

				layer = Corpse and Corpse.layer or (self.player and Tmpl.mapLayer - 1 or Tmpl.mapLayer),

				Attr = InitAttr,
				operLimit = self.operLimit,
				operId = self:get_oper() or -1,
				obstacle = Tmpl.obstacle,
				disappear = self.disappear,

				state = self.state,
				tarCoord = self.tarCoord or self.coord,
				tarAngle = self.tarAngle or self.angle,
				offensive = self:offensive(),
			},
			Attr = FinalAttr,
			Skills = self:get_skills(),
			Weapons = self:get_weapon_data(),
		},
	}

	return self.Form
end

function OBJDEF:urinate_warning()
	if self.Urination then
		return self.Urination.amount >= tonumber(_G.CVar.BATTLE.PlayerOrangeUrinate)
	end
end

function OBJDEF:urinate_error()
	if self.Urination then
		return self.Urination.amount >= tonumber(_G.CVar.BATTLE.PlayerRedUrinate)
	end
end

function OBJDEF:urinate(tar)
	local SkillLIB = config("skilllib")
	local UrinateAct = SkillLIB.get_dat(SkillLIB.URINATE_ID)
	libgame.PlayerInteract(_G.CVar.EQUIP_MAJOR_POS, UrinateAct.id, tar or 0, UrinateAct.post)
end

function OBJDEF:update_healthy(name, value, Changed)
	local dat = HealthyAssets[name]
	if dat then
		local Healthy = self[name]
		if Healthy == nil then
			Healthy = _G.DEF.Item.new(dat, value)
			self[name] = Healthy
		else
			local old = Healthy.amount
			Healthy.amount = value
			if value ~= old then
				Changed[name] = value - old
			return true end
		end
	else
		libunity.LogW("{0}:未定义的健康属性={1}", self, name)
	end
end

function OBJDEF:calc_survive_time()
	if self.isSurviveTiming then
		return self.surviveTime and (os.date2secs() - self.surviveTime) or 0
	end
	return self.surviveTime or 0
end

function OBJDEF:calc_survive_exp(totalSurviveTime)
	if totalSurviveTime == nil then
		totalSurviveTime = self:calc_survive_time()
	end
	if totalSurviveTime > 0 then
		local Eff = config("skilllib").get_eff(CVar.SURVIVE_BUFF_ID)
		local SURVIVE = CVar.SURVIVE
		local x = tonumber(SURVIVE.SurviveTimeReward)
		local y = tonumber(SURVIVE.SurviveMaxTimeReward)
		local z = tonumber(SURVIVE.SurviveTimeZ)
		local a = tonumber(Eff.Params[3] / 1000)
		if totalSurviveTime > x then
			if totalSurviveTime > y then totalSurviveTime = y end
			return a * math.ceil((totalSurviveTime - x) / z)
		end
	end
	return 0
end

function OBJDEF:read_role(nm)
	self.tmpl = nm:readU32()

	local Changed = {}
	self:update_healthy("Hunger", nm:readU32(), Changed)
	self:update_healthy("Thirsty", nm:readU32(), Changed)
	if self:update_healthy("Smell", nm:readU32(), Changed) then
		local smellLevel = _G.CVar.smell_value2level(self.Smell.amount)
		libgame.UpdateUnitData(self.id, { Attr = { smell = smellLevel, } })
	end

	local Attr = table.need(self, "Attr")
	Attr.hp = nm:readU32()
	self.hp = nm:readU32()
	Attr.move = nm:readU32() * _G.CVar.LENGTH_SCALE

	self:update_healthy("Urination", nm:readU32(), Changed)

	if self.player and next(Changed) then
		NW.broadcast("CLIENT.SC.SELF_HEALTHY", Changed)
	end
end

function OBJDEF:read_view(nm)
	local gender, face, hair, haircolor =
		nm:readU32(), nm:readU32(), nm:readU32(), nm:readU32()

	local FacesLIB = config("avatarlib").Faces
	local Faces = FacesLIB[gender]
	if Faces == nil then
		libunity.LogW("{0}:错误的性别类型={1}，使用默认性别[男]", self, gender)
		gender = 1
		Faces = FacesLIB[gender]
	end

	local Face = table.match(Faces, { id = face })
	self:set_view(gender, Face.color, face, hair, haircolor)
end

function OBJDEF:read_pet(nm)
	local petDat = nm:readU32()
	self:set_pet(petDat)
end

-- RoleSurviveInfo
function OBJDEF:read_healthy(nm)
	local smell, urinate = nm:readU32(), nm:readU32()
	local Attr = table.need(self, "Attr")
	self.hp = nm:readU32()
	self.Attr.hp = nm:readU32()

	if self.update_healthy then
		local Changed = {}
		if self:update_healthy("Smell", smell, Changed) then
			local smellLevel = _G.CVar.smell_value2level(self.Smell.amount)
			libgame.UpdateUnitData(self.id, { Attr = { smell = smellLevel, } })
		end

		self:update_healthy("Urination", urinate, Changed)

		if self.player and next(Changed) then
			NW.broadcast("CLIENT.SC.SELF_HEALTHY", Changed)
		end
	end
end

function OBJDEF:read_id_healthy(nm)
	nm:readU32()
	return self:read_healthy(nm)
end

function OBJDEF:show_view(Sub)
	local AvatarLIB = config("avatarlib")
	local face, hair = AvatarLIB.get_player_head(self.gender, self.face, self.hair, self.haircolor)
	ui.seticon(Sub.spFace, "PlayerIcon/"..face)
	ui.seticon(Sub.spHair, "PlayerIcon/"..hair)
end

return OBJDEF
