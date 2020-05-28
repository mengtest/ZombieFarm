--
-- @file    data/object/robot.lua
-- @authors shenbingkang
-- @date    2018-06-21 14:31:00
-- @desc    描述
--

local OBJDEF = setmetatable({}, _G.DEF.Unit)
OBJDEF.__index = OBJDEF
OBJDEF.__tostring = function (self)
	return string.format("[<机器人>#%s(%s) CAMP:%s]",
		tostring(self.id), self.name or "NONAME", tostring(self.camp))
end

local CVar = _G.CVar

function OBJDEF.new(id, class, camp, name)
	local self = {
		id = id, dat = 1, camp = camp,
		name = name, class = class,
	}
	return setmetatable(self, OBJDEF)
end

function OBJDEF:set_view(mechpartsArr)
	self.mechpartsArr = table.dup(mechpartsArr)
end

function OBJDEF:set_location(coord, angle)
	self.coord = coord
	self.angle = angle
	return self
end

function OBJDEF:set_dress(mechpartsType, mechpartsID)
	self.mechpartsArr[mechpartsType] = mechpartsID
end

function OBJDEF:get_dress(mechpartsPos)
	local cfg = config("guildlib")
	local mechpartsArr = self.mechpartsArr
	local mechpartsID = mechpartsArr and mechpartsArr[mechpartsPos]
	return cfg.get_mechparts_info(mechpartsID)
end

function OBJDEF:calc_attr()
	local Base = self:get_base_data()
	local Attr = _G.DEF.Attr.Empty + Base.Attr
	Attr.sneak = CVar.BATTLE.SneakMovementSpeed * CVar.LENGTH_SCALE

	for i=1,CVar.ROBOT_MECHPARTS_NUM do
		local mechpartsInfo = self:get_dress(i)
		if mechpartsInfo then
			local DressAttr = mechpartsInfo.Attr
			if DressAttr then Attr = Attr + DressAttr end
		end
	end

	return Attr
end

--额外属性：动力值（采集效率） + 耐久值（油量） + 租聘费用
function OBJDEF:calc_extra_attr()
	local totalEfficiency = 0
	local totalEndurance = 0
	local totalCost = 0

	for i=1,CVar.ROBOT_MECHPARTS_NUM do
		local mechpartsInfo = self:get_dress(i)
		if mechpartsInfo then
			local DressAttr = mechpartsInfo.Attr
			totalEfficiency = totalEfficiency + DressAttr.efficiency
			totalEndurance = totalEndurance + DressAttr.endurance
			totalCost = totalCost + mechpartsInfo.cost
		end
	end
	return totalEfficiency, totalEndurance, totalCost
end

function OBJDEF:get_view_dresses()
	local Dresses = {}
	local ROBOT_MECHPARTS_TYPE = CVar.ROBOT_MECHPARTS_TYPE
	for i = 1, CVar.ROBOT_MECHPARTS_NUM do
		local mechpartsInfo = self:get_dress(i)
		local dressPath = ROBOT_MECHPARTS_TYPE[i]
		if mechpartsInfo and dressPath then
			if #mechpartsInfo.model > 0 then
				dressPath = string.format("%s/%s/%s", dressPath, mechpartsInfo.model, mechpartsInfo.model)
				Dresses[i] = dressPath
			end
		end
	end
	return {
		-- skin = CVar.get_skin(self.gender, self.color),
		-- face = CVar.get_defface(self.gender, self.color, self.face),
		-- haircolor = CVar.RoleHairColors[self.haircolor],
		-- shoesWear = Dresses[4] ~= DEFAULT_DRESSES[4],
		Dresses = Dresses,
	}
end

function OBJDEF:get_form_data()
	local Base = self:get_base_data()
	local Tmpl = self:get_tmpl_data()
	local FinalAttr = self:calc_attr()
	local InitAttr = table.dup(FinalAttr)
	if self.hp then InitAttr.hp = self.hp end

	local prefab = "Robot"
	self.Form = {
		class = self.class,
		View = {
			name = self.name,
			prefab = prefab,
			model = self:get_view_dresses(),
			Fxes = {
				footstep = "SFX/Character/Footsteps",
				hurtSfx = Tmpl.hurtSfx,
				deadFx = Tmpl.deadFx,
				deadSfx = Tmpl.deadSfx,
				mapIco = Tmpl.mapIco,
			},
			bodyMat = 1,
		},
		Data = {
			Init = {
				size = Tmpl.size,
				coord = self.coord,
				status = 0,
				stealth = self.stealth == true,
				angle = self.angle,
				camp = self.camp,
				id = self.id,


				layer = Tmpl.mapLayer + 1,

				Attr = InitAttr,
				operId = -1,
				obstacle = Tmpl.obstacle,

				state = self.state,
				tarCoord = self.tarCoord or self.coord,
				tarAngle = self.tarAngle or self.angle,
			},
			Attr = FinalAttr,
			Skills = self:get_skills(),
		},
	}

	return self.Form
end

function OBJDEF:read_view(nm)
	local mechpartsArr = {}
	for i=1,CVar.ROBOT_MECHPARTS_NUM do
		table.insert(mechpartsArr, nm:readU32())
	end
	self:set_view(mechpartsArr)
end

return OBJDEF
