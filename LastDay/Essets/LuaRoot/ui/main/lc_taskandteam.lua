--
-- @file    ui/main/lc_taskandteam.lua
-- @author  xingweizhen
-- @date    2018-09-21 12:01:39
-- @desc    TaskAndTeam
--

local self = ui.new()
local _ENV = self

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

local function tick_member_waiting()
	local currTime = os.date2secs()

	local SubWait = Ref.SubMain.SubTeam.SubWait

	if self.selfTeamMember and self.selfTeamMember.location ~= "Arrived" then
		if self.selfTeamMember.arriveTime > currTime then
			SubWait.lbWaitTime.text = os.secs2time(nil, self.selfTeamMember.arriveTime - currTime)
		else
			libunity.SetActive(SubWait.go, false)
		end
	else
		libunity.SetActive(SubWait.go, false)
	end
end

local function rfsh_team_waittime(Member)
	self.selfTeamMember = Member
	local SubWait = Ref.SubMain.SubTeam.SubWait

	if Member then
		local arrived = Member.location == "Arrived"
		if not arrived then
			libunity.CancelInvoke(SubWait.go)
			libunity.InvokeRepeating(SubWait.go, 0, 1, tick_member_waiting)
		end

		libunity.SetActive(SubWait.go, not arrived)
	else
		libunity.SetActive(SubWait.go, false)
	end
end

local function rfsh_member_view(Member, Ent)
	Ent.lbName.text = string.format("LV%d %s", Member.level, Member.name)
	if Context and Member.online then
		local Obj = Context.get_human(Member.id)
		libunity.SetActive(Ent.barHp, Obj ~= nil)
		if Obj then
			local value, limit = libgame.GetUnitHealth(Obj.id)
			if value and limit then
				Ent.barHp.value = value / limit
			else
				Ent.barHp.value = 0
			end
		end
	else
		libunity.SetActive(Ent.barHp, false)
	end

	Member:show_view(Ent.SubHead)
	Ent.SubHead.spFace.grayscale = not Member.online
	Ent.SubHead.spHair.grayscale = not Member.online

	libugui.SetAlpha(GO(Ent.go, "Icon="), Member.location == "Arrived" and 1 or 0.5)

	if Member.id  == DY_DATA:get_player().id then
		rfsh_team_waittime(Member)
	end
end
local function show_team_waittime()
	local Team = rawget(DY_DATA, "Team")
	if Team == nil then return end
	rfsh_team_waittime(self.selfTeamMember)
end
-- 战斗中队员信息更新
local function rfsh_obj_view(i, obj)
	local Ent = Ref.SubMain.SubTeam.GrpMembers:gen(i)
	local value, limit = libgame.GetUnitHealth(obj)
	if value and limit then
		Ent.barHp.value = value / limit
	end
end
-- 战斗中创建队员
local function on_obj_create(obj)
	local Team = rawget(DY_DATA, "Team")
	if Team == nil then return end

	local Obj = Context.get_obj(obj)
	local pid = Obj and Obj.pid
	if pid then
		for i,v in ipairs(Team.Members) do
			if v.id == pid then
				local Ent = Ref.SubMain.SubTeam.GrpMembers:get(i)
				if Ent then libunity.SetActive(Ent.barHp, true) end
			break end
		end
	end
end

-- 战斗中队员离开
local function on_obj_leave(Obj)
	local Team = rawget(DY_DATA, "Team")
	if Team == nil then return end

	local pid = Obj and Obj.pid
	if pid then
		for i,v in ipairs(Team.Members) do
			if v.id == pid then
				local Ent = Ref.SubMain.SubTeam.GrpMembers:get(i)
				if Ent then libunity.SetActive(Ent.barHp, false) end
			break end
		end
	end
end

local function rfsh_team_members()
	local Team = rawget(DY_DATA, "Team")
	if Team == nil then return end

	local Members = Team.Members
	if Members then
		Ref.SubMain.SubTeam.GrpMembers:dup(#Members, function (i, Ent, isNew)
			rfsh_member_view(Members[i], Ent)
		end)
	else
		Ref.SubMain.SubTeam.GrpMembers:hide()
		rfsh_team_waittime()
	end
end

local function get_task_content(taskData)
	local tasklib = config("tasklib")
	local taskInfo = tasklib.get_dat(taskData.id)

	local taskName = taskInfo.name
	taskName = taskName .. string.format("(%s)", taskData.progress)

	return taskName
end

local function rfsh_timelimit_task_view()
	local GrpTasks = Ref.SubMain.SubTask.SubScroll.SubView.GrpTasks

	if DY_DATA.TASK.ForcusTimeLimitTaskID == nil then
		local Task, TaskBase = DY_DATA:get_endfirst_task("TimeLimitTask")
		DY_DATA.TASK.ForcusTimeLimitTaskID = Task and Task.id
	end

	local forcusTaskCnt = DY_DATA.TASK.ForcusTimeLimitTaskID and 1 or 0

	local SubNoTask = Ref.SubMain.SubTask.SubNoTask
	libunity.SetActive(SubNoTask.go, forcusTaskCnt == 0)

	GrpTasks:dup(forcusTaskCnt, function (i, Ent, isNew)
		libunity.SetActive(Ent.spTimecount, true)

		local taskData = DY_DATA.Tasks[DY_DATA.TASK.ForcusTimeLimitTaskID]
		Ent.lbContent.text = get_task_content(taskData)

		function on_timelimit_timer(tm)
			Ent.lbWaitTime.text = tm:to_time_string_hour()
			if tm.count == 0 then
				DY_DATA.TASK.ForcusTimeLimitTaskID = nil
				rfsh_timelimit_task_view()
				return
			end
		end
		local leftTime = taskData.endTime - os.date2secs()
		local tm = DY_TIMER.replace_timer("TaskAndTeam_TL_"..i,
			leftTime, leftTime, function(_)	return true	end)
		tm:subscribe_counting(Ent.spTimecount, on_timelimit_timer)
		on_timelimit_timer(tm)
	end)
end

local function rfsh_main_task_view()
	local GrpTasks = Ref.SubMain.SubTask.SubScroll.SubView.GrpTasks

	if DY_DATA.TASK.ForcusMainTaskID == nil then
		local Task, TaskBase = DY_DATA:get_top_task("MainTask")
		DY_DATA.TASK.ForcusMainTaskID = Task and Task.id
	end

	local forcusTaskCnt = DY_DATA.TASK.ForcusMainTaskID and 1 or 0

	local taskId = DY_DATA.TASK.ForcusMainTaskID

	local SubNoTask = Ref.SubMain.SubTask.SubNoTask
	libunity.SetActive(SubNoTask.go, forcusTaskCnt == 0)

	GrpTasks:dup(forcusTaskCnt, function (i, Ent, isNew)
		-- DY_TIMER.stop_timer("TaskAndTeam_TL_"..i)
		libunity.SetActive(Ent.spTimecount, false)
		local taskData = DY_DATA.Tasks[DY_DATA.TASK.ForcusMainTaskID]
		Ent.lbContent.text = get_task_content(taskData)
	end)
end

local function rfsh_task_views()
	if self.CurSelectedTaskType == nil then
		self.CurSelectedTaskType = "MainTask"
	end

	if self.CurSelectedTaskType == "MainTask" then
		local tglMainline = Ref.SubMain.SubTask.SubTgls.tglMainline
		tglMainline.value = true
		rfsh_main_task_view()
	elseif self.CurSelectedTaskType == "TimeLimitTask" then
		local tglTimelimit = Ref.SubMain.SubTask.SubTgls.tglTimelimit
		tglTimelimit.value = true
		rfsh_timelimit_task_view()
	end
end

local function init_voice_toggle_state(tgl, value)
	libugui.SetColor(GO(tgl, "spIcon"), value and "#FFFFFF" or "#808080")
end

local function SetToggleState(btn, isOn)
	libunity.SetActive(GO(btn, "spChk"), isOn)
end

local function SelectToggle(type)
	local SubTgls = Ref.SubMain.SubTgls

	SetToggleState(SubTgls.btnTask, type == "Task")
	SetToggleState(SubTgls.btnTeam, type == "Team")
	libunity.SetActive(Ref.SubMain.SubTask.go,  type == "Task")
	libunity.SetActive(Ref.SubMain.SubTeam.go, type == "Team")

	if type == "Task" then
		rfsh_task_views()
	elseif type == "Team" then
		rfsh_team_members()
		local SubTeam = Ref.SubMain.SubTeam
		local Team = DY_DATA.Team
		SubTeam.tglMic.value = Team.enableMic
		SubTeam.tglVoice.value = Team.enableVoice
		init_voice_toggle_state(SubTeam.tglMic, Team.enableMic)
		init_voice_toggle_state(SubTeam.tglVoice, Team.enableVoice)
	end
	self.CurSelectedToggleType = type
	Ref.SubMain.tglSwitch.value = true
end

local function rfsh_tglteam_interactable()
	local Team = rawget(DY_DATA, "Team")
	local hasTeam = Team and Team.status ~= "Deleting"
	local TeamInvitations = rawget(DY_DATA, "TeamInvitations")
	local nInvitation = TeamInvitations and #TeamInvitations or 0
	libugui.SetInteractable(Ref.SubMain.SubTgls.btnTeam, hasTeam or nInvitation > 0)
	libunity.SetActive(GO(Ref.SubMain.SubTgls.go, "Invite="), nInvitation > 0)
	return hasTeam, nInvitation
end

local function on_sc_team_change(Team)
	local hasTeam = rfsh_tglteam_interactable()
	if not hasTeam then
		SelectToggle("Task")
		rfsh_team_waittime()
	else
		if not Team.joined then
			SelectToggle("Team")
		end
		libunity.SetActive(Ref.SubMain.SubTgls.SubWait.go, false)
	end
end

local function on_invitation_waiting(Tm)
	local SubWait = Ref.SubMain.SubTgls.SubWait
	if Tm and not Tm.paused then
		SubWait.lbWaitTime.text = os.secs2time(nil, Tm.count)
	else
		libunity.SetActive(SubWait.go, false)
		rfsh_tglteam_interactable()
	end

end

local function rfsh_team_invitation_waiting()
	local Tm = DY_TIMER.get_timer("TeamInvitationWaiting")
	if Tm and not Tm.paused then
		local SubWait = Ref.SubMain.SubTgls.SubWait
		libunity.SetActive(SubWait.go, true)
		libugui.SetInteractable(Ref.SubMain.SubTgls.btnTeam, true)
		Tm:subscribe_counting(SubWait.go, on_invitation_waiting)
	end
	on_invitation_waiting(Tm)
end

local on_invitation_counting

local function rfsh_team_invitation_count()
	local _, nInvitation = rfsh_tglteam_interactable()
	if nInvitation > 0 then
		libunity.SetActive(GO(Ref.SubMain.SubTgls.go, "Invite="), true)
		Ref.SubMain.SubTgls.lbInviteCount.text = nInvitation

		DY_TIMER.replace_timer("TeamInvitationCounting", 1, 1, on_invitation_counting)
	else
		DY_TIMER.stop_timer("TeamInvitationCounting")
	end
end

on_invitation_counting = function (Tm)
local dirty = false
	local TeamInvitations = rawget(DY_DATA, "TeamInvitations")
	if TeamInvitations and #TeamInvitations > 0 then
		for i=#TeamInvitations,1,-1 do
			local v = TeamInvitations[i]
			if v:waiting_time() <= 0 then
				dirty = true
				table.remove(TeamInvitations, i)
			end
		end
	else dirty = true end

	if dirty then rfsh_team_invitation_count() end
end

--!* [开始] 自动生成函数 *--

function on_submain_subtgls_btntask_click(btn)
	if self.CurSelectedToggleType == "Task" then
		ui.show("UI/WNDTaskNote")
	return end

	SelectToggle("Task")
end

function on_submain_subtgls_btnteam_click(btn)
	if self.CurSelectedToggleType == "Team" then
		ui.open("UI/WNDCreateTeam")
	return end

	if rawget(DY_DATA, "Team") then
		SelectToggle("Team")
	else
		local TeamInvitations = rawget(DY_DATA, "TeamInvitations")
		if TeamInvitations then
			local Invitation = TeamInvitations.Current
			if Invitation then
				local Tm = DY_TIMER.get_timer("TeamInvitationWaiting")
				if Tm and not Tm.paused then
					local content
					local EntData = config("maplib").get_ent(Invitation.Team.entId)
					if EntData.Cost then
						local Cost = _G.DEF.Item.gen(EntData.Cost)
						content = TEXT["team.fmt_invitation"]:csfmt(
							Invitation.Inviter.name, EntData.name, Cost:get_base_data().name)
					else
						content = TEXT["InviteToLocation"]:csfmt(Invitation.Inviter.name, EntData.name)
					end
					UI.MBox.make()
						:set_param("time", Tm)
						:set_param("title", TEXT["team.invitation"])
						:set_param("content", content)
						:set_param("txtConfirm", TEXT["team.accept"])
						:set_param("txtCancel", TEXT["team.refuse"])
						:set_param("show_close_button", true)
						:set_event(
							function () NW.TEAM.accept(Invitation, 1) end,
							function () NW.TEAM.accept(Invitation, 2) end)
						:show()
				return end
			end

			NW.TEAM.show_invitation()
		end
	end
end

function on_submain_subtask_subtgls_tglmainline_click(tgl)
	libugui.SetColor(GO(tgl, "lbText_"), tgl.value and "#000000" or "#FFFFFF")
	self.CurSelectedTaskType = "MainTask"
	rfsh_main_task_view()
end

function on_submain_subtask_subtgls_tgltimelimit_click(tgl)
	libugui.SetColor(GO(tgl, "lbText_"), tgl.value and "#000000" or "#FFFFFF")
	self.CurSelectedTaskType = "TimeLimitTask"
	rfsh_timelimit_task_view()
end

function on_submain_subtask_subscroll_subview_grptasks_enttask_click(btn)
	local jumpToTaskId = nil
	if self.CurSelectedTaskType == "MainTask" then
		jumpToTaskId =DY_DATA.TASK.ForcusMainTaskID
	elseif self.CurSelectedTaskType == "TimeLimitTask" then
		jumpToTaskId = DY_DATA.TASK.ForcusTimeLimitTaskID
	end
	ui.show("UI/WNDTaskNote", 0, { jumpToTaskId = jumpToTaskId,})
end

function on_submain_subteam_tglmic_click(tgl)
	local Team = DY_DATA.Team
	Team.enableMic = tgl.value
	require("libvoice.cs").EnableSend(Team.enableMic)

	init_voice_toggle_state(tgl, Team.enableMic)
end

function on_submain_subteam_tglvoice_click(tgl)
	local Team = DY_DATA.Team
	Team.enableVoice = tgl.value
	require("libvoice.cs").EnableRecv(Team.enableVoice)

	init_voice_toggle_state(tgl, Team.enableVoice)
end

function on_submain_subteam_grpmembers_entmember_click(btn, eventData)
	local index = ui.index(btn)
	local playerId = DY_DATA:get_player().id
	local Member = DY_DATA.Team.Members[index]
	if Member and playerId ~= Member.id then
		local rightmenu = _G.PKG["ui/rightmenu"]
	    local  MenuArr = { rightmenu.Whisper ,
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

		if DY_DATA.Team.status == "Waiting" and playerId == DY_DATA.Team.leaderId then
			table.insert(MenuArr, MenuItem_Kick)
			table.insert(MenuArr, MenuItem_Promote)
		end

		ui.show("UI/WNDPlayerRightMenu", nil, {
			pos = eventData.position,
			MenuArr = MenuArr,
			Args = { Member.id, Member.name, self.depth, CVar.ChatSource.Team },
		})
	end
end

function on_submain_subteam_grpmembers_entmember_subhead_click(btn)

end

function on_submain_tglswitch_click(tgl)
	local value = tgl.value
	local type = self.CurSelectedToggleType
	libunity.SetActive(Ref.SubMain.SubTask.go, value and type == "Task")
	libunity.SetActive(Ref.SubMain.SubTeam.go, value and type == "Team")
	if value and type == "Team" then
		show_team_waittime()
	end
	libunity.SetScale(tgl, value and 1 or -1, 1, 1)
end
--!* [结束] 自动生成函数  *--

function init_view()
	ui.group(Ref.SubMain.SubTask.SubScroll.SubView.GrpTasks)
	ui.group(Ref.SubMain.SubTeam.GrpMembers)
	--!* [结束] 自动生成代码 *--
end

function init_logic()
	on_submain_tglswitch_click(Ref.SubMain.tglSwitch)

	local isGlobalStage = false
	if DY_DATA:get_stage() then
		local stageInfo = DY_DATA.World:get_curr_stage()
		if stageInfo then
			isGlobalStage = stageInfo.global
		end
	end

	if isGlobalStage then
		libugui.SetInteractable(Ref.SubMain.SubTgls.btnTask, false)
		SelectToggle("Team")
	else
		SelectToggle("Task")
		libugui.SetInteractable(Ref.SubMain.SubTgls.btnTask, true)
	end
	Ref.SubMain.SubTask.SubTgls.tglMainline.value = true
	rfsh_task_views()

	if Context then
		Context.subscribe("OBJ_CREATE", on_obj_create)
		Context.subscribe("OBJ_LEAVE", on_obj_leave)
		Context.subscribe("TEAM_MEMBER_UPDATE", rfsh_obj_view)
	end

	local Team = rawget(DY_DATA, "Team")
	if Team then
		require("libvoice.cs").EnableSend(Team.enableMic)
		require("libvoice.cs").EnableRecv(Team.enableVoice)
	end
	libugui.SetInteractable(Ref.SubMain.SubTgls.btnTeam, Team)

	rfsh_team_invitation_waiting()
	rfsh_team_invitation_count()

	DY_DATA.RedSystem:BuildRedDotUI(CVar.RedDotName.TaskRecode,Ref.SubMain.SubTgls.btnTask)
end

function show_view()

end

function on_recycle()
	if Context then
		Context.unsubscribe("OBJ_CREATE", on_obj_create)
		Context.unsubscribe("OBJ_LEAVE", on_obj_leave)
		Context.unsubscribe("TEAM_MEMBER_UPDATE", rfsh_obj_view)
	end
	self.CurSelectedToggleType = nil

	DY_TIMER.stop_timer("TeamInvitationCounting")
	DY_DATA.RedSystem:UnbuildRedDotUI(CVar.RedDotName.TaskRecode)
end

Handlers = {
	["TEAM.SC.SYNC_ROLE_JOIN"] = function (Ret)
		rfsh_team_members()
	end,

	["TEAM.SC.SYNC_ROLE_EXIT"] = function (Ret)
		if Ret.index then
			rfsh_team_members()
		end
	end,

	["CLIENT.SC.TASK_FORCUS"] = function (Task)
		if Task.type == self.CurSelectedTaskType then
			rfsh_task_views()
		end
	end,

	["TEAM.SC.SYNC_TEAM_BASE"] = on_sc_team_change,
	["TEAM.SC.SYNC_TEAM_INFO"] = function (Team)
		on_sc_team_change(Team)
		rfsh_team_members()
	end,

	["TEAM.SC.SYNC_REFUSE_INVITE"] = function (Ret)
		if Ret.oper == 3 then
			rfsh_team_invitation_waiting()
		end
	end,

	["TEAM.SC.SYNC_INVITE"] = function (Ret)
		rfsh_team_invitation_count()
		rfsh_team_invitation_waiting()
	end,

	--["TEAM.SC.SYNC_MEMBERS_STATUS"] = rfsh_team_waittime(),
}

return self

