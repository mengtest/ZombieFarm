--
-- @file    ui/guild/lc_mbguilddonaterank.lua
-- @author  shenbingkang
-- @date    2018-06-14 11:38:04
-- @desc    MBGuildDonateRank
--

local self = ui.new()
local _ENV = self

local function rfsh_donate_rank_view(donateRankList)
	self.donateRankList = donateRankList
	libugui.SetLoopCap(Ref.SubMain.SubRankView.GrpMemberList.go, #donateRankList, true)
end

--!* [开始] 自动生成函数 *--

function on_grpmemberlist_ent(go, i)
	local GrpMemberList = Ref.SubMain.SubRankView.GrpMemberList

	local n = i + 1
	GrpMemberList:setindex(go, n)

	local memberInfo = self.donateRankList[n]
	local Ent = ui.ref(go)

	Ent.lbRankNo.text = n
	Ent.lbUserName.text = memberInfo.name
	Ent.lbRankPosition.text = memberInfo.positionName
	Ent.lbRankContribution.text = memberInfo.contribution
end
--!* [结束] 自动生成函数  *--

function init_view()
	ui.group(Ref.SubMain.SubRankView.GrpMemberList)
	--!* [结束] 自动生成代码 *--
end

function init_logic()
	NW.GUILD.RequestGetDonateRankList()
end

function show_view()
	
end

function on_recycle()
	
end

Handlers = {
	["GUILD.SC.GET_BUILDING_DONATE_RANK"] = rfsh_donate_rank_view,
}

return self

