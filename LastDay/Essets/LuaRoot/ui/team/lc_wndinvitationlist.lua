--
-- @file    ui/team/lc_wndinvitationlist.lua
-- @author  xingweizhen
-- @date    2018-05-30 10:01:29
-- @desc    WNDInvitationList
--

local self = ui.new()
local _ENV = self

local function rfsh_invitation_list()
	libugui.SetLoopCap(Ref.SubInvitations.SubView.GrpInvitations.go, #List, true)
end

--!* [开始] 自动生成函数 *--

function on_btnjoin_click(btn)
	local Invitation = List[self.selectedIdx]
	NW.TEAM.accept(Invitation, true)
end

function on_invitation_ent(go, i)
	local index = i + 1
	ui.index(go, index)

	local Invitation = List[index]
	local Ent = ui.ref(go)
	Ent.lbName.text = Invitation.Team.name
	Ent.lbTime.text = os.last2string(os.date2secs() - Invitation.time, 3)

	local Entrance = config("maplib").get_ent(Invitation.Team.entId)
	Ent.lbWhere.text = Entrance.name

	if self.selectedIdx == index then
		libunity.SetParent(self.spSelected, btn, false, 0)
		libugui.SetVisible(self.spSelected, true)
	else
		libugui.SetVisible(Ent.spSelected, false)
	end
end

function on_subinvitations_subview_grpinvitations_entinvitation_click(btn)
	self.selectedIdx = ui.index(btn)
	libunity.SetParent(self.spSelected, btn, false, 0)
	libugui.SetVisible(self.spSelected, true)
end
--!* [结束] 自动生成函数  *--

function init_view()
	ui.group(Ref.SubInvitations.SubView.GrpInvitations)
	--!* [结束] 自动生成代码 *--

	self.spSelected = Ref.SubInvitations.spSelected
	self.List = DY_DATA.TeamInvitations
end

function init_logic()
	libugui.SetVisible(self.spSelected, false)
	rfsh_invitation_list()
end

function show_view()

end

function on_recycle()
	libunity.SetParent(self.spSelected, Ref.SubInvitations.go)
end

Handlers = {
	["TEAM.SC.SYNC_TEAM_INFO"] = function (Team)
		if Team then
			self:close(true)
			ui.open("UI/WNDCreateTeam")
		end
	end,
}
return self

