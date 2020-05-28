--
-- @file    ui/team/lc_wndteamlist.lua
-- @author  xingweizhen
-- @date    2018-05-28 15:47:08
-- @desc    WNDTeamList
--

local self = ui.new()
local _ENV = self

-- 每页最多显示队伍数量
local NTEAM_PER_PAGE = 8

local function rfsh_team_list(TeamList)
	local n = math.min(#TeamList, NTEAM_PER_PAGE)
	Ref.GrpTeams:dup(n, function (i, Ent, isNew)
		local Team = TeamList[i]
		local nMember = #Team.Members
		local SubSimple = Ent.SubSimple
		SubSimple.lbName.text = Team.name
		SubSimple.lbAmount.text = string.format("%d/%d", nMember, 4)

		local power = 0
		for i,v in ipairs(Team.Members) do power = power + v.power end
		SubSimple.lbPower.text = power

		ui.group(Ent.GrpDetail)
		Ent.GrpDetail:dup(4, function (i, Ent, isNew)
			local Member = Team.Members[i]
			libunity.SetActive(Ent.SubEmpty.go, Member == nil)
			libunity.SetActive(Ent.SubSomeone.go, Member)
			if Member then
				libugui.SetVisible(Ent.SubSomeone.spLeader, Member.id == Team.leaderId)
				Ent.SubSomeone.lbName.text = Member.name
				Ent.SubSomeone.lbLevel.text = Member.level
				Ent.SubSomeone.lbPower.text = Member.power
			end
		end)

		libunity.SetActive(Ent.GrpDetail.go, Ent.tgl.value)
	end)
end

local function listener_public_list()
	NW.TEAM.add_listener(Context.Entrance, Context.Stage)
end

--!* [开始] 自动生成函数 *--

function on_btnchange_click(btn)

end

function on_btnjoin_click(btn)
	local tgl = libugui.GetTogglesOn(Ref.GrpTeams.go)[1]
	if tgl then
		NW.TEAM.join(DY_DATA.TeamList[ui.index(tgl)])
	end
end

function on_grpteams_entteam_click(tgl)
	libunity.SetActive(GO(tgl, "GrpDetail"), tgl.value)
end
--!* [结束] 自动生成函数  *--

function init_view()
	ui.group(Ref.GrpTeams)
	--!* [结束] 自动生成代码 *--
end

function init_logic()
	libunity.InvokeRepeating(Ref.go, 0, 10, listener_public_list)
end

function show_view()

end

function on_recycle()
	libugui.AllTogglesOff(Ref.GrpTeams.go)
	NW.TEAM.remove_listener(Context.Entrance, Context.Stage)
end

Handlers = {
	["TEAM.SC.PUBLIC_LIST"] = rfsh_team_list,

	["TEAM.SC.SYNC_TEAM_INFO"] = function (Team)
		if Team then
			self:close(true)
			ui.open("UI/WNDCreateTeam")
		end
	end,
}

return self

