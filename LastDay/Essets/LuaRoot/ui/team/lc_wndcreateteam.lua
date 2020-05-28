--
-- @file    ui/team/lc_wndcreateteam.lua
-- @author  xingweizhen
-- @date    2018-05-28 12:38:34
-- @desc    WNDCreateTeam
--

local self = ui.new()
local _ENV = self

self.StatusBar = {
	AssetBar = true,
	HealthyBar = true,
}
self.ChatPos = { ax = 1, ay = 0, ox = -30, oy = 110, channel = CVar.ChatChannel.TEAM, }

local MenuItem_Kick = {
	name = "team.kick",
	action = function (pid, pname)
		local fmtContent = TEXT["team.fmt_kick_member"]
		UI.MBox.operate("TeamKickMember", function ()
			NW.TEAM.kick(pid)
		end, { content = fmtContent:csfmt(pname) })
	end,
}

local MenuItem_Promote = {
	name = "team.promote",
	action = function (pid, pname)
		local fmtContent = TEXT["team.fmt_new_cap"]
		UI.MBox.operate("TeamPromoteCaptain", function ()
			NW.TEAM.promote(pid)
		end, { content = fmtContent:csfmt(pname) })
	end,
}

local function on_member_model_load(view)
	if not libunity.IsEnable(Ref.go, "Canvas") then
		libgame.SetViewVisible(view, false)
	end
end

local function create_role_view(i, Ent, Role)
	local RoleForm = Role:get_form_data()
	local genderTag = CVar.GenderTag[Role.gender]
	local model = libgame.CreateView("/UIROOT/ROLE", "PlayerOverUI" .. genderTag,
		RoleForm.Data.Attr.weapon, RoleForm.View, on_member_model_load)

	local Weapon = Role.MajorWeapon
	if Weapon then
		local WeaponBase = Weapon:get_base_data()
		local pose = WeaponBase.wType
		local Affixes = { Weapon:get_dress_data(), }
		libgame.UpdateUnitView(model, pose, { Affixes = Affixes })
	end

	libugui.Follow(model, Ent.SubSomeone.ElmModel, 6.5)
	libunity.FaceCamera(model)

	local Model = self.Models[i]
	if Model then libgame.Recycle(Model.go) end

	self.Models[i] = { go = model, id = Role.id }
end

local function tick_member_waiting()
	local currTime = os.date2secs()
	local hasWait = false
	for i,v in ipairs(DY_DATA.Team.Members) do
		if v.location ~= "Arrived" then
			hasWait = true
			local Ent = Ref.GrpMembers:get(i)
			local waitTime = v.arriveTime - currTime
			if waitTime >= 0 then
				Ent.SubSomeone.lbWaitTime.text = os.secs2time(nil, waitTime)
			else
				libunity.SetActive(Ent.SubSomeone.spWait, false)
			end
		end
	end
	if not hasWait then
		self.tickWaiting = nil
		return true
	end
end

local function rfsh_ready_button()
	local Team = DY_DATA.Team
	local visible = Team.teamType ~= 2
	libunity.SetActive(Ref.SubOper.SubReady.go, visible)

	if not visible then return end

	local btnText, interactable = nil, true
	if Team.status == "Matching" then
		interactable = false
		btnText = TEXT["team.ready"]
	elseif Team.status == "Fighting" then
		btnText = TEXT.Enter
	else
		local Player = DY_DATA:get_player()
		local selfLeader = Player.id == Team.leaderId
		if selfLeader then
			btnText = TEXT["team.start"]
		else
			for i,v in ipairs(Team.Members) do
				if v.id == Player.id then
					btnText = TEXT[v.ready and "team.unready" or "team.ready"]
				break end
			end
		end
	end

	Ref.SubOper.SubReady.lbTitle.text = btnText
	libugui.SetInteractable(Ref.SubOper.SubReady.go, interactable)
end

local function rfsh_team_leader()
	local Team = DY_DATA.Team
	local Members = Team.Members
	local waiting = Team.status == "Waiting"
	Ref.GrpMembers:dup(4, function (i, Ent, isNew)
		local Member = Members[i]
		if Member then
			local isLeader = Member.id == Team.leaderId
			local SubSomeone = Ent.SubSomeone
			SubSomeone.spLeader:SetSprite(isLeader and "Squad/ico_sq_05" or "Common/ico_com_025")
			SubSomeone.spLeader:SetNativeSize()
			libugui.SetVisible(SubSomeone.spLeader, isLeader or Member.ready)
		else
			local isClosed = maxPlayerCount < i or not waiting
			libunity.SetActive(Ent.SubEmpty.SubClosed.go, isClosed)
			libunity.SetActive(Ent.SubEmpty.SubOpened.go, not isClosed)
		end
	end)

	local Player = DY_DATA:get_player()
	local selfLeader = Player.id == Team.leaderId
	libunity.SetActive(Ref.tglAutoMatch, allowMatch and selfLeader)

	rfsh_ready_button()
end

local function rfsh_team_info()
	local Team = DY_DATA.Team

	local SubReady = Ref.SubOper.SubReady
	local spWait = SubReady.spWait
	local matching = Team.status == "Matching"
	local waiting = Team.status == "Waiting"
	if matching then
		if not libunity.IsActive(spWait) then
			libunity.SetActive(spWait)
			local time = 0
			libunity.InvokeRepeating(Ref.go, 0, 1, function ()
				SubReady.lbWaitTime.text = os.secs2time(nil, time)
				time = time + 1
				if not libunity.IsActive(spWait) then return true end
			end)
		end
	end
	libunity.SetActive(spWait, matching)
	libugui.SetInteractable(Ref.tglAutoMatch, allowMatch and waiting)
	libugui.SetInteractable(Ref.SubOper.SubRefresh.go, Team.status == "Fighting")

	rfsh_ready_button()
end

local function rfsh_team_members(alldata)
	local Team = DY_DATA.Team
	local Members = Team.Members
	if Members == nil then return end

	local wndVisible = libunity.IsEnable(Ref.go, "Canvas")
	local waiting = Team.status == "Waiting"
	local hasWait = false
	Ref.GrpMembers:dup(4, function (i, Ent, isNew)
		local Member = Members[i]
		local Model = self.Models[i]
		local SubSomeone, SubEmpty = Ent.SubSomeone, Ent.SubEmpty
		libunity.SetActive(SubSomeone.go, Member)
		libunity.SetActive(SubEmpty.go, not Member)
		if Member then
			local isLeader = Member.id == Team.leaderId
			if alldata then
				SubSomeone.spLeader:SetSprite(isLeader and "Squad/ico_sq_05" or "Common/ico_com_025")
				SubSomeone.spLeader:SetNativeSize()
				SubSomeone.lbLevel.text = TEXT.fmtLevel:csfmt(Member.level)
				SubSomeone.lbName.text = Member.name
			end
			libugui.SetVisible(SubSomeone.spLeader, isLeader or Member.ready)

			local arrived = Member.location == "Arrived"
			if not hasWait and not arrived then hasWait = true end
			libunity.SetActive(Ent.spWait, not arrived)
			libunity.SetActive(Ent.spNotArrived, not arrived)

			if (Model == nil or Model.id ~= Member.id) and wndVisible and arrived then
				create_role_view(i, Ent, Member)
			end
		else
			local isClosed = maxPlayerCount < i or not waiting
			libunity.SetActive(SubEmpty.SubClosed.go, isClosed)
			libunity.SetActive(SubEmpty.SubOpened.go, not isClosed)
			libgame.Recycle(Model and Model.go)
			self.Models[i] = nil
		end
	end)

	if hasWait and not self.tickWaiting then
		self.tickWaiting = true
		libunity.InvokeRepeating(Ref.go, 0, 1, tick_member_waiting)
	end

	rfsh_ready_button()
end

local function set_model_view(visible)
	for i,v in ipairs(DY_DATA.Team.Members) do
		local Model = self.Models[i]
		if Model then
			libgame.SetViewVisible(Model.go, visible)
		elseif visible then
			local arrived = v.location == "Arrived"
			if arrived then
				create_role_view(i, Ref.GrpMembers:get(i), v)
			end
		end
	end
end

local function on_invite_close()
	ChatPos.hide = nil
	set_visible(true)
end

function set_visible(visible)
	libugui.SetVisible(Ref.go, visible)
	set_model_view(visible)
end

--!* [开始] 自动生成函数 *--

function on_grpmembers_entmember_subempty_subopened_btninvite_click(btn)
	ChatPos.hide = true
	set_visible(false)

	local Wnd = ui.show("UI/WNDInvitePlayer", 2)
	Wnd:set_close(on_invite_close)
end

function on_grpmembers_entmember_subsomeone_click(btn, eventData)
	local playerId = DY_DATA:get_player().id
	local Team = DY_DATA.Team
	local Member = Team.Members[ui.index(btn)]
	if Member == nil then return end

	if playerId ~= Member.id then
		local rightmenu = _G.PKG["ui/rightmenu"]
	    local  MenuArr = {
             {
              name = "RightMenu.ViewProfile",
              action = function()
                  local UserCard = {playerId = Member.id, name = Member.name, uniqueId = Member.uniqueId,
                  hair = Member.hair, gender = Member.gender, face = Member.face, haircolor =Member.haircolor,
                  guildName = Member.guildName,guildChanel = Member.guildChanel}
                  ui.show("UI/MBPlayerInfoCard",0 , UserCard)
              end,
             }
            }

		local isFriend = NW.FRIEND.check_isfriend(Member.id)
		if isFriend then
			table.insert(MenuArr,rightmenu.DelFriend)
		else
			table.insert(MenuArr,rightmenu.AddFriend)
		end
		table.insert(MenuArr,rightmenu.AddBlack)

		if Team.status == "Waiting" and playerId == Team.leaderId then
			table.insert(MenuArr, MenuItem_Kick)
			table.insert(MenuArr, MenuItem_Promote)
		end

		ui.show("UI/WNDPlayerRightMenu", nil, {
			pos = eventData.position,
			MenuArr = MenuArr,
			Args = { Member.id, Member.name,CVar.ChatSource.Team },
		})
	end
end

function on_btnleave_click(btn)
	UI.MBox.operate("LeaveSquad", NW.TEAM.exit)
end

function on_suboper_subready_click(btn)
	local Team = DY_DATA.Team
	if DY_DATA.World.Travel.dst > 0 or Team.entId ~= DY_DATA.World.Travel.src then
		UI.Toast.norm(TEXT["team.arrive_before_getready"])
	return end

	if Team.status == "Fighting" then
		NW.MULTI.get_room_token(DY_DATA.Room.id)
	else
		-- 没有门票不许准备
		if DY_DATA.World:check_passcard_enough() then
			local Player = DY_DATA:get_player()
			if Player.id == Team.leaderId then
				NW.team_apply_map(DY_DATA.Team.entId, Ref.tglAutoMatch.value)
			else
				local selfReady
				for i,v in ipairs(Team.Members) do
					if v.id == Player.id then
						selfReady = v.ready
					break end
				end
				if selfReady ~= nil then NW.TEAM.set_ready(not selfReady) end
			end
		end
	end
end

function on_suboper_subrefresh_click(btn)
	NW.TEAM.pool_vote_refresh()
end

function on_subwait_click(btn)
	UI.Toast.norm(TEXT.tipAutoEnterStageTeam)
end

--!* [结束] 自动生成函数  *--

function init_view()
	ui.group(Ref.GrpMembers)
	--!* [结束] 自动生成代码 *--

	self.StatusBar.Menu = {
		icon = "CommonIcon/ico_main_059",
		name = "WNDCreateTeam",
		Context = Context,
	}
	self.Models = {}
	Ref.GrpMembers:dup(4)

	local _, Entrance = DY_DATA.World:find_entrance(DY_DATA.Team.entId)
	self.Entrance = Entrance
	self.maxPlayerCount = Entrance.Stages[1].maxPlayerCount
	self.allowMatch = Entrance.maxMatchTeam ~= 0
end

function init_logic()
	ui.moveout(Ref.spBack, 1)
	ui.moveout(Ref.go, 1)

	libunity.SetActive(Ref.SubOper.go, allowMatch)
	libunity.SetActive(Ref.SubWait.go, not allowMatch)
	libunity.SetActive(Ref.SubOper.SubReady.spWait, false)

	if not allowMatch then
		local Tm = _G.DY_TIMER.get_timer("StageClose#"..Entrance.id)
		if Tm and not Tm.paused then
			Ref.SubWait.lbWaitTime.text = os.secs2time(nil, Tm.count)
			Tm:subscribe_counting(Ref.go, function (tm)
				Ref.SubWait.lbWaitTime.text = os.secs2time(nil, tm.count)
			end)
		else
			Ref.SubWait.lbWaitTime.text = os.secs2time(nil, 0)
		end
	end

	-- 显示刷新消耗，即进本消耗
	local EntData = config("maplib").get_ent(DY_DATA.Team.entId)
	local SubReady = Ref.SubOper.SubReady
	if EntData.Cost then
		local Cost = _G.DEF.Item.gen(EntData.Cost)
		local costIcon = Cost:get_base_data().icon
		ui.seticon(SubReady.spIcon, costIcon)
		SubReady.lbAmount.text = Cost.amount > 1 and Cost.amount or ""
	else
		SubReady.spIcon:SetSprite("")
		SubReady.lbAmount.text = nil
	end

	rfsh_team_info()
	rfsh_team_leader()
	libugui.SetAlpha(Ref.GrpMembers.go, 0)
end

function show_view()
	libugui.SetAlpha(Ref.GrpMembers.go, 1)
	rfsh_team_members(true)
end

function on_recycle()
	ui.putback(Ref.spBack, Ref.go)
	for _,v in pairs(Models) do
		libgame.Recycle(v and v.go)
	end

	local RecentlyMets = rawget(DY_DATA, "RecentlyMets")
	if RecentlyMets and RecentlyMets.dirty then
		RecentlyMets.dirty = nil
		RecentlyMets:save()
	end

	local InviteWnd = ui.find("WNDInvitePlayer")
	if InviteWnd then InviteWnd:close(true) end
end

Handlers = {
	["CLIENT.SC.TOPBAR_SWITCH"] = function (Wnd)
		local modelVisible = Wnd == self
		local InviteWnd = ui.find("WNDInvitePlayer")
		if InviteWnd then
			libugui.SetVisible(Ref.go, false)
			libugui.SetVisible(InviteWnd.Ref.go, modelVisible)
		else
			set_model_view(modelVisible)
		end
	end,

	["TEAM.SC.SYNC_TEAM_BASE"] = function (Team)
		if Team then
			rfsh_team_info()
			rfsh_team_leader()
		else
			self:close()
		end
	end,

	["TEAM.SC.SYNC_TEAM_INFO"] = function (Team)
		if Team and Team.status ~= "Deleting" then
			rfsh_team_info()
			rfsh_team_leader()
			rfsh_team_members(true)
		else
			self:close()
		end
	end,

	["TEAM.SC.SYNC_ROLE_JOIN"] = function (Ret)
		rfsh_team_members(true)
	end,

	["TEAM.SC.SYNC_ROLE_EXIT"] = function (Ret)
		if Ret.index then
			rfsh_team_members(true)
		end
	end,

	["TEAM.SC.SYNC_MEMBERS_STATUS"] = rfsh_team_members,

	["MULTI_MAP.SC.APPLY_ROOM"] = function (Ret)
		if Ret.err == nil then
			NW.apply_global_map(Ret.Room)
		end
	end,

	["MULTI_MAP.SC.SYNC_BEGIN_MATCH"] = function (Ret)

	end,
}

return self

