--
-- @file    ui/team/lc_wndinviteplayer.lua
-- @author  xingweizhen
-- @date    2018-05-29 11:22:13
-- @desc    WNDInvitePlayer
--

local self = ui.new()
local _ENV = self

self.ChatPos = false

local function check_have_enter_team(member)
	for i,v in ipairs( DY_DATA.Team.Members) do
		if v.id == member.id then
			return true
		end
	end
	return false
end

local RoleListGetter = {
	[1] = function ()
		local online_friend  = {}
		for i,v in ipairs(DY_DATA.friendList) do
			if v.isOnline and not check_have_enter_team(v) then
				table.insert(online_friend,v)
			end
		end
		return online_friend
	end,

	-- 最近遇到的玩家
	[2] = function ()
		local recentlyMets = {}
		for i,v in ipairs(DY_DATA.RecentlyMets:load()) do
			if not check_have_enter_team(v) then
				table.insert(recentlyMets,v)
			end
		end

		return recentlyMets
	end,
}

local function focus_selected(go)
	if go then
		libugui.SetVisible(spSelected, true)
		libunity.SetParent(spSelected, go)
	else
		libugui.SetVisible(spSelected, false)
	end
	libugui.SetInteractable(Ref.SubOp.btnInvite, go ~= nil)
	libugui.SetInteractable(Ref.SubOp.btnWhisper, go ~= nil)
end

local function get_role_list(tab)
	local List = self.RoleLists[tab]
	if List == nil then
		List = RoleListGetter[tab]()
		RoleLists[tab] = List
	end
	return List
end

local function rfsh_player_list(tab)
	if tab == nil then
		local tgl = libugui.GetTogglesOn(Ref.GrpTabs.go)[1]
		if tgl then tab = ui.index(tgl) end
	end
	if tab then
		self.List = get_role_list(tab)
		libugui.SetLoopCap(Ref.SubPlayers.SubView.GrpPlayers.go, #List, true)
	end
end

local function show_player_status(Player, status, Ent)
	if status == nil then
		local PlayerStatus = DY_DATA.Team.PlayerStatus
		status = PlayerStatus and PlayerStatus[Player.id] or "idle"
	end

	Ent.lbStatus.text = TEXT["team.player_" .. status]
end
local function on_refresh_friend_list()
	self.RoleLists[1] = RoleListGetter[1]()
	rfsh_player_list()
end
--!* [开始] 自动生成函数 *--

function on_grptabs_enttab_click(tgl)
	if tgl.value then
		libugui.SetAlpha(GO(tgl, "spTabBg"), 1)
		focus_selected()
		selectedIdx = nil
		rfsh_player_list(Ref.GrpTabs:getindex(tgl))
	else
		libugui.SetAlpha(GO(tgl, "spTabBg"), 0.5)
	end
end

function on_player_ent(go, i)
	local index = i + 1
	ui.index(go, index)

	local Role = List[index]
	local Ent = ui.ref(go)
	libugui.SetColor(go, i % 2 == 0 and "#464646" or "#626262")
	Ent.lbName.text = Role.name
	Ent.lbLevel.text = Role.level
	Ent.lbGuildName.text = Role.guildName
	--Ent.lbPower.text = Role.power
	--Ent.spGender:SetSprite(CVar.RoleGenderIcon[Role.gender])
	show_player_status(Role, nil, Ent)

	if selectedIdx == index then
		focus_selected(go)
	else
		libugui.SetVisible(Ent.spSelected, false)
	end
end

function on_subplayers_subview_grpplayers_entplayer_click(btn)
	self.selectedIdx = ui.index(btn)
	focus_selected(btn)
end

function on_subop_btnwhisper_click(btn)
	local Role = List[selectedIdx]
	if Role then
		NW.FRIEND.OnPrivateChat(Role.id,Role.name,self.depth,CVar.ChatSource.Team)
	end
end

function on_subop_btninvite_click(btn)
	local Role = List[selectedIdx]
	if Role then
		NW.TEAM.invite(Role.id)
		local status = "invited"
		table.need(DY_DATA.Team, "PlayerStatus")[Role.id] = status
		local Ent = Ref.SubPlayers.SubView.GrpPlayers:find(selectedIdx)
		show_player_status(Role, status, Ent)
		UI.Toast.norm(TEXT["HadSendInvited"])
	end
end
--!* [结束] 自动生成函数  *--

function init_view()
	ui.group(Ref.GrpTabs)
	ui.group(Ref.SubPlayers.SubView.GrpPlayers)
	--!* [结束] 自动生成代码 *--

	self.spSelected = Ref.SubPlayers.spSelected
	self.RoleLists = {}
	Ref.GrpTabs:dup(#TEXT.InviteTabs, function (i, Ent, isNew)
		local tabName = TEXT.InviteTabs[i]
		Ent.lbTab.text = tabName
		Ent.lbChkTab.text = tabName
		libugui.SetAlpha(Ent.spTabBg, 0.5)
	end)
	NW.FRIEND.RequestGetFriendList()
end

function init_logic()
	Ref.GrpTabs:get(1).tgl.value = true
end

function show_view()

end

function on_recycle()
	libugui.AllTogglesOff(Ref.GrpTabs.go)
end

Handlers = {
	["TEAM.SC.SYNC_REFUSE_INVITE"] = function ()
		rfsh_player_list()
	end,
	["TEAM.SC.TEAM_INVITE"] = function (result)
		if result.ret == 0 then
			--UI.Toast.norm(TEXT["HadSendInvited"])
		elseif result.ret == 1304 then
			for i,v in ipairs(DY_DATA.friendList) do
				if v.id == result.playerId then
					v.isOnline = false
					on_refresh_friend_list()
					break
				end
			end
		end
	end,
	["FRIEND.SC.FRIEND_LIST"] = function()
		on_refresh_friend_list()
	end,
	["FRIEND.SC.FRIEND_ONLINE_STATE"] = function ()
		on_refresh_friend_list()
	end,
	["TEAM.SC.SYNC_ROLE_JOIN"] = function()
		on_refresh_friend_list()
	end,
	["TEAM.SC.SYNC_ROLE_EXIT"] = function()
		on_refresh_friend_list()
	end,
}

return self

