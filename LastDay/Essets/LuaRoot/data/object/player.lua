--
-- @file    data/object/player.lua
-- @anthor  xingweizhen (weizhen.xing@funplus.com)
-- @date    2017-11-08 15:06:47
-- @desc    描述
--


local OBJDEF = {}
OBJDEF.__index = OBJDEF
OBJDEF.__tostring = function (self)
	return string.format("[玩家#%s]", self.id)
end

local CRAFT = _G.PKG["game/craftapi"]
local BUILD = _G.PKG["game/buildapi"]

function OBJDEF.new(id)
	local self = { id = id }
	return setmetatable(self, OBJDEF)
end

function OBJDEF:get_level_data()
	return config("levellib").get_dat(self.level)
end

function OBJDEF:read_info(nm)
	self.nChangeName = nm:readU32()
	self.uniqueId = nm:readString()
	self.name = nm:readString()
	self.icon = nm:readU32()
	self.frame = nm:readU32()
	self.verified = nm:readU32() == 1
	local changeNameCool = nm:readU32()
	_G.PKG["game/timers"].launch_chname_timer(changeNameCool)

	self.guildID = nm:readU32()
	self.guildChannel = nm:readU32()
	local oldName = nm:readString()
	if self.guildID == 0 then
		self.guildName = ""
	else
		local hex = string.format("%02X", self.guildID)
		self.guildName = string.format(TEXT.GuildNameFormat, hex)
	end
end
function OBJDEF:read_friendInfo(nm)
	-- self.serverId = nm:readU32()--服务器ID
	-- self.name = nm:readString()--名称
	-- self.level = nm:readU32()--等级
	-- self.power = nm:readU32()--战力
	NW.read_RoleBaseData(nm, self)

	-- self.guildID = nm:readU32()
	-- self.guildName = nm:readString()
	self.guildIcon = nm:readString()
	self.lastTime = nm:readU64()
	self.serverStr = nm:readString()
	self.isOnline = nm:readU32() == 1
end
function OBJDEF:read_asset(nm)
	local lastlevel = self.level

	self.level = nm:readU32()
	if lastlevel and lastlevel  ~= self.level then
		self:check_have_newbuild(self.level,lastlevel)
		self:check_have_newcraft(self.level,lastlevel)
	end
	-- 如果有Vip系统，此处应使用Vip类
	self.vip = nm:readU32()
	self.totalRechange = nm:readU32()
	self.exp = nm:readU32()

	local ItemDEF = _G.DEF.Item
	local Assets = table.need(self, "Assets")
	local n = nm:readU32()
	for i=1,n do
		local dat, amount = nm:readU32(), nm:readU32()
		Assets[dat] = ItemDEF.new(dat, amount)
	end

	local DY_TIMER = _G.DY_TIMER
	n = nm:readU32()
	for i=1,n do
		local dat = nm:readU32()
		local limit, recovery = nm:readU32(), nm:readU32()
		local Asset = Assets[dat]

		if Asset then
			Asset.limit = limit
			local cycle = _G.CVar.get_recovery_cycle(Asset.dat)
			if cycle > 0 and Asset.amount < Asset.limit then
				_G.PKG["game/timers"].launch_asset_timer(Asset, recovery, cycle)
			end
		else

		end
	end
end

function OBJDEF:read_locate(nm)
	local mapType, mapId, objId = nm:readU32(), nm:readU64(), nm:readU32()
	self.map = mapType > 0 and mapId or nil
	self.obj = objId > 0 and objId or nil
end


function OBJDEF:show_view(Sub)
	local AvatarLIB = config("avatarlib")
	local face, hair = AvatarLIB.get_player_head(self.gender, self.face, self.hair, self.haircolor)
	ui.seticon(Sub.spFace, "PlayerIcon/"..face)
	ui.seticon(Sub.spHair, "PlayerIcon/"..hair)
end

function OBJDEF:check_have_newcraft(playerlevel,lastlevel)
	local crafts =
	config("formulalib").get_formula_list_levelrang(playerlevel,lastlevel)

	CRAFT.save_list(crafts)

	self:check_newcraft_state()
end
function OBJDEF:check_newcraft_state()
	local count = 0
	for k,v in pairs(CRAFT.launch()) do
		count = count + 1
	end

    DY_DATA.RedSystem:SetRedDotState(CVar.RedDotName.CraftNew,count > 0)
end
function OBJDEF:check_have_newbuild(playerlevel,lastlevel)
    local curBuildings, curFurnitures =
    config("unitlib").get_building_list_levelrang(playerlevel,lastlevel)

    BUILD.save_list(curBuildings)
    BUILD.save_list(curFurnitures)

    self:check_newbuild_state()
end
function OBJDEF:check_newbuild_state()
	local houseNum = 0
	local deviceNum = 0
	local furnitureNum = 0
	local specialNum = 0
	for k,v in pairs(BUILD.launch()) do
		local dat = config("unitlib").get_dat(tonumber(k))
		if dat then
			if dat.showType == 1 then
				houseNum = houseNum + 1
			elseif dat.showType == 2 then
				deviceNum = deviceNum + 1
			elseif dat.showType== 3 then
				furnitureNum = furnitureNum + 1
			elseif dat.showType == 4 then
				specialNum = specialNum + 1
			end
		end


	end

    DY_DATA.RedSystem:SetRedDotState(CVar.RedDotName.BuildHouse,houseNum > 0)

    DY_DATA.RedSystem:SetRedDotState(CVar.RedDotName.BuildDevice,deviceNum > 0)

    DY_DATA.RedSystem:SetRedDotState(CVar.RedDotName.BuildFurniture,furnitureNum > 0)

    DY_DATA.RedSystem:SetRedDotState(CVar.RedDotName.BuildSpecial,specialNum > 0)

end
return OBJDEF
