--
-- @file    ui/team/lc_wndrefreshstage.lua
-- @author  xingweizhen
-- @date    2018-09-20 15:04:30
-- @desc    WNDRefreshStage
--

local self = ui.new()
local _ENV = self


--!* [开始] 自动生成函数 *--

function on_submain_subagree_click(btn)
	NW.TEAM.vote_refresh(true)
end

function on_submain_btnrefuse_click(btn)
	NW.TEAM.vote_refresh(false)
end
--!* [结束] 自动生成函数  *--

function init_view()
	ui.group(Ref.SubMain.GrpVotes)
	--!* [结束] 自动生成代码 *--
end

function init_logic()
	local AgreeMembers = Context
	Ref.SubMain.GrpVotes:dup(#DY_DATA.Team.Members, function (i, Ent, isNew)
		local Member = DY_DATA.Team.Members[i]
		Ent.lbName.text = Member.name
		Ent.spChk:SetSprite(AgreeMembers[Member.id] and "Common/ico_com_025" or "Common/btn_com_001")
	end)
end

function show_view()

end

function on_recycle()

end

return self

