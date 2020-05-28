--
-- @file    network/unpack/upk_multi.lua
-- @anthor  xingweizhen (weizhen.xing@funplus.com)
-- @date    2018-05-14 11:24:26
-- @desc    描述
--

local NW, P = _G.NW, {}

-- RoomLoginInfo
local function sc_room_info(nm, Room)
	if Room == nil then
		Room = { id = nm:readU64(), }
	end

	Room.serverId = nm:readU32()
	Room.host = nm:readString()
	Room.port = nm:readU32()
	Room.token = nm:readU64()
	Room.mapId = nm:readU64()

	return Room
end
P.sc_room_info = sc_room_info

local RoomStatus = {
	"Matching", "InBattle", "BattleOver", "Closed",
}
-- RoomInfo
local function sc_room_base(nm, Room)
	if Room == nil then
		Room = { id = nm:readU64(), }
	end

	Room.entId = nm:readU32()
	Room.mapId = nm:readU64()
	Room.status = RoomStatus[nm:readU32()]
	Room.corpse = nm:readU32() == 1

	-- 房间类型
	-- 1：个人房间: 2队伍房间; 3别人的基地; 4自己的基地
	Room.roomType = nm:readU32()
	if Room.roomType == 3 then
		Room.HomeBattle = {
			-- 参与阵营: 1攻击方; 2防守方
			camp = nm:readU32(),
			Atker = NW.TEAM.sc_player_base(nm),
			Defer = NW.TEAM.sc_player_base(nm),
		}
	elseif Room.roomType == 4 then
		Room.HomeBattle = {
			Atker = NW.TEAM.sc_player_base(nm),
		}
	end

	return Room
end

NW.regist("MULTI_MAP.SC.APPLY_ROOM", function (nm)
	local act = nm:readU32()
	local ret, err = NW.chk_op_ret(nm:readU32())
	local Room
	if err == nil then
		Room = sc_room_info(nm)
	end
	return { ret = ret, err = err, Room = Room, }
end)

NW.regist("MULTI_MAP.SC.ALONE_APPLY", NW.common_op_ret)
NW.regist("MULTI_MAP.SC.TEAM_APPLY", NW.common_op_ret)

NW.regist("MULTI_MAP.SC.GET_ROOM_TOKEN", function (nm)
	local roomId = nm:readU64()
	local ret, err = NW.chk_op_ret(nm:readU32())
	local Room
	if err == nil then
		Room = sc_room_info(nm)
		NW.apply_global_map(Room)
	end

	return { ret = ret, err = err, Room = Room, }
end)

NW.regist("MULTI_MAP.SC.ATTACK_ROLE_HOME", function (nm)
	local pid = nm:readU64()
	local ret, err = NW.chk_op_ret(nm:readU32())
	return { ret = ret, err = err, pid = pid, }
end)

NW.regist("MULTI_MAP.SC.BS_APPLY_JOIN", NW.MAP.sc_apply_join)

NW.regist("MULTI_MAP.SC.SYNC_CROSS_BATTLE_INFO", function (nm)
	-- CrossBattleInfo
	DY_DATA.CrossBattle = {
		lockLocal = nm:readU32() == 1,
		lockTimeout = nm:readU32(),
		-- 最近进入的跨服房间
		roomId = nm:readU64(),
		-- 最近一次丢尸体的房间,
		corpseRoomId = nm:readU64(),
	}

	return DY_DATA.CrossBattle
end)

NW.regist("MULTI_MAP.SC.SYNC_ROOM_INFO", function (nm)
	local fullList = nm:readU32() == 1
	if fullList then
		DY_DATA.RoomList = nm:readArray({}, sc_room_base)
	else
		local RoomList = table.tomap(DY_DATA.RoomList, "id")
		local n = nm:readU32()
		for i=1,n do
			local Room = { id = nm:readU64(), }
			sc_room_base(nm, Room)
			RoomList[Room.id] = Room
		end

		DY_DATA.RoomList = table.toarray(RoomList)
	end
	return DY_DATA.RoomList
end)

NW.regist("MULTI_MAP.SC.SYNC_BEGIN_MATCH", function (nm)
	local matchType = nm:readU32()
	local maxWait = nm:readU32() / 1000
	local minWait = nm:readU32() /1000
	DY_DATA.World.Matching = { matchType = matchType, maxWait = maxWait, minWait = minWait }
	return DY_DATA.World.Matching
end)

function P.get_room_token(roomId)
	NW.send(NW.msg("MULTI_MAP.CS.GET_ROOM_TOKEN"):writeU64(roomId))
end

function P.cancel_alone_apply(entId)
	DY_DATA.World.Matching = nil
	NW.send(NW.msg("MULTI_MAP.CS.CANCEL_ALONE_APPLY"):writeU32(entId))
end

function P.attack_player_home(entId, pid, type)
	NW.send(NW.msg("MULTI_MAP.CS.ATTACK_ROLE_HOME"):writeU32(entId):writeU64(pid):writeU32(type))
end

NW.MULTI = P
