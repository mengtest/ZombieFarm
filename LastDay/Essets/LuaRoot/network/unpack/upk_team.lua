--
-- @file    upk_team.lua
-- @anthor  xingweizhen (weizhen.xing@funplus.com)
-- @date    2018-05-28 16:28:28
-- @desc    描述
--

local NW, P = _G.NW, {}

local TeamStatus = {
	"Waiting", "Matching", "Fighting", "Deleting",
}

local LocationStatus = {
	[0] = "NotLocate", [1] = "Arrived", [2] = "Moving",
}

local InvitationDEF = {}
InvitationDEF.__index = InvitationDEF
function InvitationDEF:waiting_time()
	return self.time + self.waiting - os.date2secs()
end

-- 离开队伍后的数据逻辑
local function leave_team()
	require("libvoice.cs").QuitRoom()
	local World = rawget(DY_DATA, "World")
	if World then World.Matching = nil end
	DY_DATA.Team = nil
end

local function get_team_member(roleId, Members, addIfMissing)
	if Members == nil then Members = DY_DATA.Team.Members end

	for i,v in ipairs(Members) do
		if v.id == roleId then return i, v end
	end

	if addIfMissing then
		local Role = _G.DEF.Human.new(roleId, "none")
		table.insert(Members, Role)
		return #Members, Role
	end
end

-- TeamMemberStataus
local function sc_member_status(nm, Member)
	if Member == nil then
		local pid = nm:readU64()
		_, Member = get_team_member(pid)
		if Member == nil then
			libunity.LogW("TeamMemberStatus: 队友#{0}不存在", pid)
		end
	end
	local ready = nm:readU32() == 1
	local location = LocationStatus[nm:readU32()]
	local online = nm:readU32() == 1
	local leftTime = nm:readU32()
	local arriveTime = math.ceil(os.date2secs() + leftTime / 1000)

	if Member then
		Member.ready, Member.location, Member.online, Member.arriveTime =
			ready, location, online, arriveTime
	end
end

-- RoleBaseData
function P.sc_player_base(nm, Role)
	if Role == nil then
		Role = _G.DEF.Human.new(nm:readU64(), "none")
	end
	NW.read_RoleBaseData(nm, Role)
	return Role
end

-- RoleData
local function sc_player_data(nm, Role)
	Role = P.sc_player_base(nm, Role)
	Role:read_equips(nm)
	Role:read_view(nm)
	Role:read_pet(nm)

	-- 本地缓存遇到的新玩家
	if Role.id ~= DY_DATA:get_player().id then
		local Pref_RecentlyMets = rawget(DY_DATA, "RecentlyMets")
		if Pref_RecentlyMets then
			local RecentlyMets = Pref_RecentlyMets:load()
			local Data = table.match(RecentlyMets, { id = Role.id, })
			if Data == nil then
				Data = { id = Role.id }
				table.insert(RecentlyMets, Data)
			end
			Data.name, Data.gender, Data.level, Data.power, Data.date =
			Role.name, Role.gender, Role.level, Role.power, os.date2secs()
			table.sort(RecentlyMets, function (a, b) return a.date > b.date end)
			DY_DATA.RecentlyMets.dirty = true
		end
	end

	return Role
end

-- TeamBaseData
local function sc_team_base(nm, Team)
	DY_DATA.World.Matching = nil

	if Team == nil then
		Team = rawget(DY_DATA, "Team")
		local teamId = nm:readU32()
		if Team == nil then
			require("libvoice.cs").JoinRoom(teamId, 1)
			Team = {}
			DY_DATA.Team = Team
		end
		Team.id = teamId
		Team.enableMic = false
		Team.enableVoice = true
	else
		Team.joined = true
	end
	Team.entId = nm:readU32()
	Team.mapId = nm:readU64()
	Team.mapType = nm:readU32()
	Team.teamType = nm:readU32()
	Team.camp = nm:readU32()
	local preStatus = Team.status
	Team.status = TeamStatus[nm:readU32()]
	Team.leaderId = nm:readU64()
	Team.statusDirty = preStatus ~= Team.status

	Team.name = nm:readString()
	if #Team.name == 0 then Team.name = tostring(Team.id) end

	return Team
end

-- TeamData
local function sc_team_data(nm, Team)
	local Team = sc_team_base(nm, Team)
	Team.Members = nm:readArray({}, sc_player_data)
	nm:readArray(nil, sc_member_status)
	if Team.status == "Fighting" then
		DY_DATA.Room = NW.MULTI.sc_room_info(nm)
	else
		DY_DATA.Room = nil
	end
	return Team
end

local function remove_invitation(sn)
	for i,v in ipairs(DY_DATA.TeamInvitations) do
		if v.sn == sn then
			table.remove(DY_DATA.TeamInvitations, i)
		break end
	end
end

NW.regist("TEAM.SC.TEAM_CREATE", NW.common_op_ret)

NW.regist("TEAM.SC.TEAM_INVITE", function (nm)
	local playerId = nm:readU64()
	local ret, err = NW.chk_op_ret(nm:readU32())
	return { ret = ret, err = err, playerId = playerId }
end)

NW.regist("TEAM.SC.DROP_MEMBER", NW.common_op_ret)
NW.regist("TEAM.SC.MOVE_LEADER", NW.common_op_ret)
NW.regist("TEAM.SC.SET_STATUS", NW.common_op_ret)
NW.regist("TEAM.SC.EXIT_TEAM", NW.common_op_ret)
NW.regist("TEAM.SC.JOIN_PUBLIC", function (nm)
	local teamId = nm:readU32()
	local ret, err = NW.chk_op_ret(nm:readU32())
	return { ret = ret, err = err, teamId = teamId, }
end)

NW.regist("TEAM.SC.SET_READY", NW.common_op_ret)

NW.regist("TEAM.SC.INVITE_ACT", function (nm)
	local sn = nm:readU32()
	local accept = nm:readU32() == 1 -- 1接收 2拒绝
	local ret, err = NW.chk_op_ret(nm:readU32())
	local waiting = 0
	if err == nil then
		waiting = nm:readU32()
	end
	return { ret = ret, err = err, sn = sn, accept = accept, waiting = waiting }
end)

NW.regist("TEAM.SC.TEAM_CLOSE_BATTLE_POLL", NW.common_op_ret)
NW.regist("TEAM.SC.TEAM_CLOSE_BATTLE_ACT", function (nm)
	local sn = nm:readU64()
	local ret, err = NW.chk_op_ret(nm:readU32())
	return { ret = ret, err = err }
end)

NW.regist("TEAM.SC.PUBLIC_LIST", function (nm)
	local entId, mapId, mapType = nm:readU32(), nm:readU64(), nm:readU32()
	local fullList = nm:readU32() == 1
	local RemoveIDs = nm:readArray({}, nm.readU64)

	local TeamList
	if fullList then
		TeamList = {}
	else
		TeamList = table.tomap(DY_DATA.TeamList, "id")
		for _,v in ipairs(RemoveIDs) do
			TeamList[v] = nil
		end
	end

	local n = nm:readU32()
	for i=1,n do
		local teamId = nm:readU64()
		local Team = table.need(TeamList, teamId)
		Team.id = teamId
		sc_team_data(nm, Team)
	end

	DY_DATA.TeamList = table.toarray(TeamList)
	table.sort(DY_DATA.TeamList, function (a, b)
		return a.id > b.id
	end)

	return DY_DATA.TeamList
end)

NW.regist("TEAM.SC.SYNC_TEAM_INFO", function (nm)
	local ret = nm:readU32()
	if ret == 1 then
		return sc_team_data(nm)
	else
		leave_team()
	end
end)

NW.regist("TEAM.SC.SYNC_TEAM_BASE", function (nm)
	local ret = nm:readU32()
	if ret == 1 then
		return sc_team_base(nm)
	else
		local Team = rawget(DY_DATA, "Team")
		if Team == nil then return end

		local Members = Team.Members
		for i,v in ipairs(Members) do
			if v.id == DY_DATA:get_player().id then
				local currTime = os.date2secs()
				local arrived = v.location == "Arrived"

				if v.arriveTime <= currTime and not arrived then
					UI.MBox.make("MBNormal")
						:set_param("title", TEXT.HintInformation)
						:set_param("content", TEXT.LimiteTimeKickOut)
						:show()
				end
			end
		end
		leave_team()

	end
end)

NW.regist("TEAM.SC.SYNC_MEMBER_JOIN", sc_team_base)
NW.regist("TEAM.SC.SYNC_MEMBER_OUT", function (nm)
	return nm:readU64()
end)

NW.regist("TEAM.SC.SYNC_INVITE", function (nm)
	local sn = nm:readU32()
	local Inviter = P.sc_player_base(nm)

	local Team = sc_team_base(nm, {id = nm:readU32(), })

	local waiting = nm:readU32() / 1000
	local delayWait = nm:readU32() / 1000
	local Invitation = setmetatable({
		Team = Team, Inviter = Inviter, sn = sn,
		time = os.date2secs(), waiting = waiting, delayWait = delayWait,
	}, InvitationDEF)

	local selfGuildId = DY_DATA:get_player().guildID
	local Inviter = Invitation.Inviter
	local isFriend = DY_DATA:get_friend_info(Inviter.id, "FRIEND")
	local isMember = Inviter.guildID == selfGuildId
	-- 排序（好友>避难所成员>陌生人)
	local index = nil
	if isFriend then
		for i,v in ipairs(DY_DATA.TeamInvitations) do
			if not DY_DATA:get_friend_info(v.Inviter.id, "FRIEND") then
				index = i
			break end
		end
	elseif isMember then
		for i,v in ipairs(DY_DATA.TeamInvitations) do
			if not DY_DATA:get_friend_info(v.Inviter.id, "FRIEND") and v.Inviter.guildID ~= selfGuildId then
				index = i
			break end
		end
	end

	if index then
		table.insert(DY_DATA.TeamInvitations, index, Invitation)
	else
		table.insert(DY_DATA.TeamInvitations, Invitation)
	end

	if DY_DATA.TeamInvitations.Current == nil or #DY_DATA.TeamInvitations == 1 then
		P.show_invitation(Invitation)
	end
	return Invitation
end)

NW.regist("TEAM.SC.SYNC_REFUSE_INVITE", function (nm)
	local oper = nm:readU32()
	local Player = P.sc_player_base(nm)
	local PlayerStatus = table.need(DY_DATA.Team, "PlayerStatus")
	PlayerStatus[Player.id] = "refused"
	if oper == 2 then
		-- 拒绝
		UI.Toast.norm(TEXT["team.fmt_refuse"]:csfmt(Player.name))
	elseif oper == 3 then
		-- 稍候
		UI.Toast.norm(TEXT["team.fmt_holdon"]:csfmt(Player.name, CVar.TEAM.InvitationExtraWaitingTime / 60))
	end

	return { Player = Player, oper = oper }
end)

NW.regist("TEAM.SC.SYNC_ROLE_JOIN", function (nm)
	local roleId = nm:readU64()
	local index, Role = get_team_member(roleId, nil, true)
	sc_player_data(nm, Role)
	nm:readU64() -- 取出玩家id
	sc_member_status(nm, Role)
	return { index = index, Role = Role }
end)

NW.regist("TEAM.SC.SYNC_ROLE_EXIT", function (nm)
	local playerId = nm:readU64()
	local Team = rawget(DY_DATA, "Team")
	if Team == nil then return end

	local Members = Team.Members
	local index, Role
	for i,v in ipairs(Members) do
		if v.id == playerId then
			if Team.leaderId == DY_DATA:get_player().id then
				local currTime = os.date2secs()
				local arrived = v.location == "Arrived"
				if v.arriveTime <= currTime and not arrived then
					local content = TEXT.TeamMemberKickOut:csfmt(v.name)
					UI.MBox.make("MBNormal")
						:set_param("title", TEXT.HintInformation)
						:set_param("content", content)
						:show()
				end
			end
			index = i
			Role = table.remove(Members, i)
		break end
	end

	return { index = index, Role = Role }
end)

NW.regist("TEAM.SC.SYNC_READY_GO", function (nm)
	local countdown = nm:readU32()
	return countdown
end)

NW.regist("TEAM.SC.SYNC_READY_GO_FAIL", function (nm)
	local Team = rawget(DY_DATA, "Team")
	if Team then
		return table.arrvalue(nm:readArray({}, nm.readU64))
	end
	libunity.LogW("没有队伍，但收到了准备计时失败消息")
end)

NW.regist("TEAM.SC.SYNC_MEMBERS_STATUS", function (nm)
	local Team = rawget(DY_DATA, "Team")
	if Team then
		nm:readArray(nil, sc_member_status)
		return Team
	end
	libunity.LogW("没有队伍，但收到了准备就绪列表")
end)

NW.regist("TEAM.SC.SYNC_CLOSE_BATTLE_POLL", function (nm)
	local sn = nm:readU64()
	local pid = nm:readU64()
	local Member = get_team_member(pid)

	local _, Entrance = DY_DATA.World:find_entrance(DY_DATA.Team.entId)
	local Cost = _G.DEF.Item.gen(Entrance.NewTeamCosts.Items[1])
	local costName = Cost:get_base_data().name
	local content = TEXT.fmtRefreshStage:csfmt(Cost.amount, costName, _G.CVar.TEAM.RefreshMapKickOutTime)
	UI.MBox.operate("VoteRefreshStage", nil, { content = content, }, true):set_event(
		function () P.vote_refresh(sn, true) end,
		function () P.vote_refresh(sn, false) end):show()
	return { sn = sn, Member = Member }
end)

NW.regist("TEAM.SC.SYNC_CLOSE_BATTLE_POLL_INFO", function (nm)
	local sn = nm:readU64()
	local AgreeMembers = table.arrvalue(nm:readArray({}, nm.readU64))
	return { sn = sn, AgreeMembers = AgreeMembers, }
end)

NW.regist("TEAM.SC.SYNC_CLOSE_BATTLE_POLL_RESULT", function (nm)
	local sn = nm:readU64()
	local AgreeMembers = table.arrvalue(nm:readArray({}, nm.readU64))
	ui.show("UI/WNDRefreshStage", nil, AgreeMembers)
	return { sn = sn, AgreeMembers = AgreeMembers, }
end)

function P.create(Entrance, Stage)
	NW.MainCli:send(NW.msg("TEAM.CS.TEAM_CREATE"):writeU32(Entrance.id))
end

function P.invite(pid)
	NW.MainCli:send(NW.msg("TEAM.CS.TEAM_INVITE"):writeU64(pid))
end

function P.kick(pid)
	NW.MainCli:send(NW.msg("TEAM.CS.DROP_MEMBER"):writeU64(pid))
end

function P.promote(pid)
	NW.MainCli:send(NW.msg("TEAM.CS.MOVE_LEADER"):writeU64(pid))
end

function P.set_status(status)
	NW.MainCli:send(NW.msg("TEAM.CS.SET_STATUS"):writeU32(status))
end

function P.set_ready(ready)
	NW.MainCli:send(NW.msg("TEAM.CS.SET_READY"):writeU32(ready and 2 or 1))
end

function P.exit()
	NW.MainCli:send(NW.msg("TEAM.CS.EXIT_TEAM"))
end

function P.join(Team)
	local nm = NW.msg("TEAM.CS.JOIN_PUBLIC")
	nm:writeU32(Team.entId):writeU64(Team.mapId):writeU32(Team.mapType)
	  :writeU32(Team.id):writeU64(Team.leaderId)

	NW.MainCli:send(nm)
end

function P.accept(Invitation, act)
	NW.MainCli:send(NW.msg("TEAM.CS.INVITE_ACT"):writeU32(Invitation.sn):writeU32(act))

	if act == 1 then
		-- 接受
		DY_DATA.TeamInvitations = nil
		DY_TIMER.stop_timer("TeamInvitationWaiting")
	elseif act == 2 then
		-- 拒绝
		DY_DATA.TeamInvitations.Current = nil
		remove_invitation(Invitation.sn)
		DY_TIMER.stop_timer("TeamInvitationWaiting")
		P.show_invitation()
	elseif act == 3 then
		Invitation.waiting = Invitation.waiting + Invitation.delayWait
		local waiting = Invitation:waiting_time()
		DY_TIMER.replace_timer("TeamInvitationWaiting", waiting, waiting, true)
	end
	NW.broadcast("TEAM.SC.SYNC_INVITE")
end

function P.pool_vote_refresh()
	NW.MainCli:send(NW.msg("TEAM.CS.TEAM_CLOSE_BATTLE_POLL"))
end

function P.vote_refresh(sn, agree)
	NW.MainCli:send(NW.msg("TEAM.CS.TEAM_CLOSE_BATTLE_ACT"):writeU64(sn):writeU32(agree and 1 or 0))
end

function P.add_listener(Entrance, Stage)
	local nm = NW.msg("TEAM.CS.PUBLIC_LIST_ADD_LISTEN")
	nm:writeU32(Stage.id):writeU64(Stage.mapId):writeU32(Stage.mType)
	NW.MainCli:send(nm)
end

function P.remove_listener(Entrance, Stage)
	local nm = NW.msg("TEAM.CS.PUBLIC_LIST_REMOVE_LISTEN")
	nm:writeU32(Stage.id):writeU64(Stage.mapId):writeU32(Stage.mType)
	NW.MainCli:send(nm)

	DY_DATA.TeamList = nil
end

function P.show_invitation(Invitation)
	local waiting
	if Invitation == nil then
		while true do
			Invitation = DY_DATA.TeamInvitations[1]
			if Invitation == nil then break end

			waiting = Invitation:waiting_time()
			if waiting > 0 then break end

			table.remove(DY_DATA.TeamInvitations, 1)
		end
		if Invitation == nil then return end
	else
		waiting = Invitation:waiting_time()
	end

	DY_DATA.TeamInvitations.Current = Invitation

	local EntData = config("maplib").get_ent(Invitation.Team.entId)
	local content
	if EntData.Cost then
		local Cost = _G.DEF.Item.gen(EntData.Cost)
		content = TEXT["team.fmt_invitation"]:csfmt(
			Invitation.Inviter.name, EntData.name, Cost:get_base_data().name)
	else
		content = TEXT["InviteToLocation"]:csfmt(
			Invitation.Inviter.name, EntData.name)
	end
	UI.MBox.make()
		:set_param("time", waiting)
		:set_param("title", TEXT["team.invitation"])
		:set_param("content", content)
		:set_param("txtCancel", TEXT["team.refuse"])
		:set_param("txtConfirm", TEXT["team.please_wait"])
		:set_param("txtOption", TEXT["team.accept"])
		:set_param("limitBack", true)
		:set_action("cancel", function () P.accept(Invitation, 2) end)
		:set_action("confirm", function () P.accept(Invitation, 3) end)
		:set_action("option", function () P.accept(Invitation, 1) end)
		:show()
end

NW.TEAM = P
