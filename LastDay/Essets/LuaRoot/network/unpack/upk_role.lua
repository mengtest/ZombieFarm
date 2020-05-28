--
-- @file    network/unpack/upk_role.lua
-- @anthor  xingweizhen (weizhen.xing@funplus.com)
-- @date    2017-11-08 15:03:44
-- @desc    描述
--

local NW, P = _G.NW, {}

function P.OnPlayerInfo(userId)
	local UserCard = { playerId = userId }
	ui.show("UI/MBPlayerInfoCard",0 , UserCard)
end

-- 获取自己的RoleInfo
NW.regist("PLAYER.SC.GET_ROLE_INFO", function (nm)
	local Player = DY_DATA:get_player()
	Player.id = nm:readU64()
	Player:read_info(nm)
	local Self = DY_DATA:get_self()
	Self:read_view(nm)
	return Player
end)

-- 获取别人的RoleInfo
NW.regist("PLAYER.SC.GET_OTHER_ROLE_INFO", function (nm)
	local ret, err = NW.chk_op_ret(nm:readU32())
	if err == nil then
		local roleInfo = {}
		roleInfo.id = nm:readU64()
		NW.read_RoleBaseData(nm, roleInfo)

		roleInfo.gender = nm:readU32()
		roleInfo.face = nm:readU32()
		roleInfo.hair = nm:readU32()
		roleInfo.haircolor = nm:readU32()

		return roleInfo
	end
end)

NW.regist("PLAYER.SC.ROLE_ASSET_GET", function (nm)
	local Player = DY_DATA:get_player()
	Player:read_asset(nm)
	return Player
end)

NW.regist("PLAYER.SC.NAME_CHANGE", NW.common_op_ret)
NW.regist("PLAYER.SC.ROLE_HEAD_CHANGE", NW.common_op_ret)
NW.regist("PLAYER.SC.ROLE_RANDOM_NAME", function (nm)
	local sex = nm:readU32()
	local RanNames = nm:readArray({}, nm.readString)
	return {sex = sex, RanNames = RanNames}
end)

NW.regist("ROLE.SC.GET_ROLE_INFO", function (nm)
	local Self = DY_DATA:get_self()
	Self:read_role(nm)

	-- 映射一下装备位
	if Self.Dresses == nil then
		local CVar = _G.CVar
		Self:set_weapon(CVar.EQUIP_MAJOR_POS, CVar.EQUIP_MINOR_POS)
		local EQUIP_SLOT2POS = CVar.EQUIP_SLOT2POS
		for i,v in ipairs(EQUIP_SLOT2POS) do
			Self:set_dress(i, v)
		end
	end

	return Self
end)

NW.regist("ROLE.SC.GET_ROLE_LOCAL", function (nm)
	local Player = DY_DATA:get_player()
	Player:read_locate(nm)
	return Player
end)

NW.regist("ROLE.SC.ROLE_REVIVAL", function (nm)
	local ret, err = NW.chk_op_ret(nm:readU32())
	if err == nil then
		NW.MAP.exit_map()
	end
	return { ret = ret, err = err, }
end)

NW.regist("TALENT.SC.LIST", function (nm)
	local Talents = nm:readArray({}, nm.readU32)
	DY_DATA.Talents = table.arrvalue(Talents)
	DY_DATA.Talents.points = nm:readU32()
end)

NW.regist("TALENT.SC.LOCK", function (nm)
	local ret, err = NW.chk_op_ret(nm:readU32())
	local talentId, points
	if err == nil then
		talentId = nm:readU32()
		points = nm:readU32()

		local Talents = DY_DATA.Talents
		Talents[talentId] = true
		Talents.points = points
	end

	return { ret = ret, err = err, talentId = talentId, points = points }
end)

NW.regist("TALENT.SC.RESET", NW.common_op_ret)

NW.ROLE = P
