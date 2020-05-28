--
-- @file    ui/guild/lc_wndguild.lua
-- @author  shenbingkang
-- @date    2018-06-06 18:24:50
-- @desc    WNDGuild
--

local self = ui.new()
local _ENV = self
self.StatusBar = {
	AssetBar = true,
	HealthyBar = false,
}
self.ChatPos = { ax = 1, ay = 0, ox = -20, oy = 100, }

--我的公会成员面板数据
local selectedMemberListIndex = 1

--公会管理界面数据
local manageMemberList = {}
local bApplySwich = false

--公会日志界面数据
local guildLogList = {}

--公会列表面板数据
local guildList = {}
local myApply = {}
local selectedClanListIndex = 1

-- 测试数据开始
-- local function Debug_get_guild_date(createCnt)
-- 	local testData = {GuildList = {}, MyApply = {}}
-- 	for i=1,createCnt do
-- 		local modO,_ = math.modf(i % 3)
-- 		testData.GuildList[i] = {
-- 			guildID = i,
-- 			guildName = "TestGuildName"..i,
-- 			--guildIcon = "", --"底图ID#图标ID#背景色Id#底图颜色ID#图标色ID"
-- 			guildNotice = "This is Guild:"..i.."'s Notice.",
-- 			leaderName = "TestLeader"..i,
-- 			guildLevel = i,
-- 			guildMemCnt = i,
-- 			guildMemLimitCnt = 100,
-- 			guildActivity = i * 10,
-- 			isOpenApply = modO == 0,
-- 			isLocked = modO == 2,
-- 		}
-- 	end
-- 	testData.MyApply = { 1,3,5,7,9,11,13,15,17,19,}
-- 	return testData
-- end
-- 测试数据结束

--==============我的公会面板==================================
local function forceUpdateMemberListSelected(go)
	libunity.SetParent(self.spMemberSelected, go, false, 0)
	libunity.SetActive(self.spMemberSelected, true)
end

local function rfsh_myclen_weekact_stall(SubStall, exploit, maxExploit, myWeekContribution, reState)
	local welfAnchor = exploit / maxExploit
	libugui.SetAnchor(SubStall.go, welfAnchor, 0.5, welfAnchor, 0.5)
	libugui.SetAnchoredPos(SubStall.go, 0, 0, 0)
	libugui.SetText(GO(SubStall.btnStall, "lbStall"), exploit)

	if myWeekContribution >= exploit and reState == 0 then
		libugui.SetInteractable(SubStall.btnStall, true)
	else
		libugui.SetInteractable(SubStall.btnStall, false)
	end
end

local function rfsh_myclen_weekact_view()
	local SubMyWeekActivity = Ref.SubContents.SubMyClanContent.SubMyWeekActivity
	local myGuildInfo = DY_DATA.MyGuildInfo
	local myWeekContribution = myGuildInfo.myWeekContribution
	SubMyWeekActivity.lbCurWeekActivity.text = myWeekContribution

	local SubActStall1 = SubMyWeekActivity.SubProgress.SubStall1
	local SubActStall2 = SubMyWeekActivity.SubProgress.SubStall2
	local SubActStall3 = SubMyWeekActivity.SubProgress.SubStall3

	local guildlib = config("guildlib")
	local welf1 = guildlib.get_welfare_dat(1)
	local welf2 = guildlib.get_welfare_dat(2)
	local welf3 = guildlib.get_welfare_dat(3)

	local maxWelfValue = welf3.exploit
	SubMyWeekActivity.SubProgress.barAct.value = myWeekContribution / maxWelfValue

	rfsh_myclen_weekact_stall(SubActStall1, welf1.exploit, maxWelfValue, myWeekContribution, myGuildInfo.rewardState[1])
	rfsh_myclen_weekact_stall(SubActStall2, welf2.exploit, maxWelfValue, myWeekContribution, myGuildInfo.rewardState[2])
	rfsh_myclen_weekact_stall(SubActStall3, welf3.exploit, maxWelfValue, myWeekContribution, myGuildInfo.rewardState[3])
end

local function rfsh_myclen_memberlist_view()
	local memCnt = #DY_DATA.MyGuildMemberList
	if selectedMemberListIndex > memCnt then
		selectedMemberListIndex = memCnt
	end
	libugui.SetLoopCap(Ref.SubContents.SubMyClanContent.SubMemberList.SubMemberListView.GrpMemberList.go, memCnt, true)
end

local function rfsh_myclen_claninfo_view()
	local SubGuildInfo = Ref.SubContents.SubMyClanContent.SubGuildInfo
	local SubNotice = Ref.SubContents.SubMyClanContent.SubNotice
	local guildlib = config("guildlib")

	local myGuildInfo = DY_DATA.MyGuildInfo
	local levelDat = guildlib.get_level_dat(myGuildInfo.guildLevel)

	local guildBadge = _G.DEF.GuildBadge.gen(myGuildInfo.guildIcon)
	guildBadge:show_bgcolor(SubGuildInfo.spGuildBadge)
	guildBadge:show_sdicon(SubGuildInfo.spGuildBadgeSd)
	guildBadge:show_sdcolor(SubGuildInfo.spGuildBadgeSd)
	guildBadge:show_pticon(SubGuildInfo.spGuildBadgePt)
	guildBadge:show_ptcolor(SubGuildInfo.spGuildBadgePt)

	SubGuildInfo.lbGuildName.text = myGuildInfo.guildName
	SubGuildInfo.SubDetails.lbIdLv.text = string.format(TEXT.fmtClanInfo.IdLv, myGuildInfo.guildID, myGuildInfo.guildLevel)
	SubGuildInfo.SubDetails.lbMemCnt.text = string.format(TEXT.fmtClanInfo.Members, myGuildInfo.guildMemCnt, levelDat.maxMember)
	SubGuildInfo.SubDetails.lbActivity.text = string.format(TEXT.fmtClanInfo.Activity, myGuildInfo.guildActivity)
	SubGuildInfo.SubDetails.lbCost.text = string.format(TEXT.fmtClanInfo.MantenanceCost, levelDat.maintenanceFee)
	SubGuildInfo.SubDetails.lbCptial.text = string.format(TEXT.fmtClanInfo.ClanCptial, myGuildInfo.guildFund)
	SubNotice.lbNotice.text = myGuildInfo.guildNotice

	local Player = DY_DATA:get_player()
	local myInfo = DY_DATA:get_guild_member_info(Player.id)
	libunity.SetActive(SubNotice.btnEditNotice, myInfo.position ~= 0)
end

local function rfsh_myclen_view()
	rfsh_myclen_weekact_view()
	rfsh_myclen_memberlist_view()
	rfsh_myclen_claninfo_view()
end
--------------------------------------------------------------

--==============公会管理面板==================================
local function anim_toggle_changed(tgl)
	local tarPos = tgl.value and UE.Vector3(30, 0, 0) or UE.Vector3(-30, 0, 0)
	if freezingData then
		libugui.SetAnchoredPos(GO(tgl, "spThumb_"), tarPos)
	else
		libugui.DOTween("Position", GO(tgl, "spThumb_"), nil, tarPos, {
				duration = 0.2, ease = "InCubic",
			})
	end
end

local function rfsh_manage_accept_switch_state(isOpen)
	bApplySwich = isOpen
	Ref.SubContents.SubManageContent.tglSwitch.value = isOpen
end

local function rfsh_manage_list_view(applyList)
	if applyList then
		manageMemberList = applyList
	end
	libugui.SetLoopCap(Ref.SubContents.SubManageContent.SubManageListView.GrpManageList.go, #manageMemberList, true)
end
--------------------------------------------------------------

--==============公会日志面板==================================
local function rfsh_guild_log_view()
	libugui.SetLoopCap(Ref.SubContents.SubClanLogContent.SubScroll.GrpContent.go, #guildLogList, true)
end
--------------------------------------------------------------

--==============公会列表面板==================================
local function forceUpdateClanListSelected(go)
	libunity.SetParent(self.spClanListSelected, go, false, -1)
	libunity.SetActive(self.spClanListSelected, true)
end

local function rfsh_clanlist_notice_view()
	local guildInfo = guildList[selectedClanListIndex]
	if guildInfo then
		Ref.SubContents.SubClanListContent.SubNotice.lbNotice.text = guildInfo.guildNotice
	else
		Ref.SubContents.SubClanListContent.SubNotice.lbNotice.text = nil
	end
end

--刷新公会列表页签
local function rfsh_clan_list_view(data)
	if data then
		if data.GuildList then
			guildList = data.GuildList
		end
	end
	local guildCnt = #guildList
	if selectedClanListIndex > guildCnt then
		selectedClanListIndex = guildCnt
	end
	libugui.SetLoopCap(Ref.SubContents.SubClanListContent.SubClanListView.GrpGuildList.go, guildCnt, true)
	rfsh_clanlist_notice_view()
end
--------------------------------------------------------------

--刷新资源
local function rfsh_player_assets()
	local SubAsset = Ref.SubAsset
	local amount = DY_DATA:nget_asset("Exploit")
	SubAsset.lbAmount.text = amount
end

--初始化公会界面
local function init_guild_togs()
	local SubTogs = Ref.SubTogs
	local SubClanListContent = Ref.SubContents.SubClanListContent

	local Player = DY_DATA:get_player()

	if Player.guildID == nil or Player.guildID == 0 then
		libunity.SetActive(SubTogs.tglMyClan, false)
		libunity.SetActive(SubTogs.tglLog, false)
		libunity.SetActive(SubTogs.tglManage, false)

		--显示创建、加入公会按钮
		libunity.SetActive(SubClanListContent.btnCreate, true)
		libunity.SetActive(SubClanListContent.btnJoin, true)

		--策划需求，未加入公会不显示个人贡献
		libunity.SetActive(Ref.SubAsset.go, false)

		return SubTogs.tglClanList
	else
		libunity.SetActive(SubTogs.tglMyClan, true)
		libunity.SetActive(SubTogs.tglLog, true)
		libunity.SetActive(SubTogs.tglManage, true)

		--隐藏创建、加入公会按钮
		libunity.SetActive(SubClanListContent.btnCreate, false)
		libunity.SetActive(SubClanListContent.btnJoin, false)

		--策划需求，加入公会才显示个人贡献
		libunity.SetActive(Ref.SubAsset.go, true)

		return SubTogs.tglMyClan
	end
end

local function do_Guild_AdjNormal()
	--0-普通成员 1-管理员 2-会长
	NW.GUILD.RequestModifyPosition(Context.operUserID, 0)
end
local function do_Guild_AdjAdmin()
	NW.GUILD.RequestModifyPosition(Context.operUserID, 1)
end
local function do_Guild_TnfPresident()
	NW.GUILD.RequestModifyPosition(Context.operUserID, 2)
end
local function do_Guild_KickOut()
	NW.GUILD.RequestKickOut(Context.operUserID)
end

--!* [开始] 自动生成函数 *--

function on_subcontents_submyclancontent_submyweekactivity_subprogress_substall1_btnstall_click(btn)
	NW.GUILD.RequestReceiveWelfare(1)
end

function on_subcontents_submyclancontent_submyweekactivity_subprogress_substall2_btnstall_click(btn)
	NW.GUILD.RequestReceiveWelfare(2)
end

function on_subcontents_submyclancontent_submyweekactivity_subprogress_substall3_btnstall_click(btn)
	NW.GUILD.RequestReceiveWelfare(3)
end

function on_subcontents_submyclancontent_submyweekactivity_btngotoclan_click(btn)
	--todo:跳转到公会营地
end

function on_grpmemberlist_ent(go, i)
	local GrpMemberList = Ref.SubContents.SubMyClanContent.SubMemberList.SubMemberListView.GrpMemberList

	local n = i + 1
	GrpMemberList:setindex(go, n)

	local memberInfo = DY_DATA.MyGuildMemberList[n]
	local Ent = ui.ref(go)

	local guildlib = config("guildlib")

	Ent.lbMemName.text = memberInfo.name
	Ent.lbMemPosition.text = guildlib.get_position_name(memberInfo.position)
	Ent.lbMemLevel.text = memberInfo.level
	Ent.lbMemContribution.text = memberInfo.contribution

	local lastTime = memberInfo.lastLogoutTime

	if lastTime == 0 then
		Ent.lbMemState.text = TEXT.online
	else
		local offlineTime = os.date2secs() - lastTime
		Ent.lbMemState.text = string.format(TEXT.fmtOffline, os.last2string(offlineTime, 1))
	end

	if selectedMemberListIndex == n then
		forceUpdateMemberListSelected(go)
	else
		libunity.SetActive(Ent.spSelected, false)
	end
end

function on_subcontents_submyclancontent_submemberlist_submemberlistview_grpmemberlist_entmemberinfo_click(btn, event)
	local GrpMemberList = Ref.SubContents.SubMyClanContent.SubMemberList.SubMemberListView.GrpMemberList
	local index = GrpMemberList:getindex(btn)
	selectedMemberListIndex = index
	forceUpdateMemberListSelected(btn)

	--右键菜单
	local Player = DY_DATA:get_player()
	local myInfo = DY_DATA:get_guild_member_info(Player.id)
	local operPlayerInfo = DY_DATA.MyGuildMemberList[index]
	--点击自己的名片，不弹右键菜单
	if operPlayerInfo.id == Player.id then
		return
	end

	local rightmenu = _G.PKG["ui/rightmenu"]
	local MenuArr = {rightmenu.AddFriend ,rightmenu.AddBlack }
	if myInfo.position == 2 then
		if operPlayerInfo.position == 0 then
			local adjAdmin = {name = "RightMenu.Guild_AdjAdmin",action = do_Guild_AdjAdmin}
			table.insert(MenuArr, adjAdmin)
		else
			local adjNormal = { name ="RightMenu.Guild_AdjNormal",action = do_Guild_AdjNormal}
			table.insert(MenuArr, adjNormal)
		end
		local tnfPresident = { name ="RightMenu.Guild_TnfPresident",action = do_Guild_TnfPresident}
		local kickOut = { name ="RightMenu.Guild_KickOut",action = do_Guild_KickOut}
			
		table.insert(MenuArr, tnfPresident)
		table.insert(MenuArr, kickOut)
	elseif myInfo.position == 1 then
		if operPlayerInfo.position == 0 then
			local kickOut = { name ="RightMenu.Guild_KickOut",action = do_Guild_KickOut}
			
			table.insert(MenuArr, kickOut)
		end
	end

	ui.show("UI/WNDPlayerRightMenu", 0,
		{ pos = event.position, MenuArr = MenuArr,
		 Args = { operPlayerInfo.id, operPlayerInfo.name,self.depth, CVar.ChatSource.Guild},
		})
end

function on_subcontents_submyclancontent_subguildinfo_btnguildquit_click(btn)
	local Player = DY_DATA:get_player()
	local myInfo = DY_DATA:get_guild_member_info(Player.id)

	if myInfo.position == 2 then
		--会长退出流程
		local disTime = DY_DATA.MyGuildInfo.guildDisTime
		if disTime == 0 then
			local memCnt = #DY_DATA.MyGuildMemberList
			if memCnt == 1 then
				_G.UI.MBox.operate("PresidentQuitGuildCountdown", function ()
					NW.GUILD.RequestDissolveGuild()
				end)
			else
				_G.UI.Toast.norm(TEXT.DissolveSomeoneElse)
				return
			end
		else
			local lastTime = disTime - os.date2secs()
			if lastTime <= 0 then
				_G.UI.MBox.operate("PresidentQuitGuild", nil, nil, true):set_event(
					function ()
						NW.GUILD.RequestConfirmDissolveGuild()
					end,
					function ()
						_G.UI.MBox.operate("PresidentCancelQuitGuild", function ()
							NW.GUILD.RequestCancelDissolveGuild()
						end)
					end
				):show()
			else
				_G.UI.MBox.operate("PresidentCancelQuitGuildCountdown", function ()
					NW.GUILD.RequestCancelDissolveGuild()
				end,{
					content = string.format(tostring(TEXT.AskOperation.PresidentCancelQuitGuildCountdown.content), os.last2string(lastTime, 4)),
				})
			end
		end
	else
		--一般会员退出流程
		_G.UI.MBox.operate("NormalQuitGuild", function ()
				NW.GUILD.RequestQuitGuild()
		end)
	end
end

function on_subcontents_submyclancontent_subnotice_btneditnotice_click(btn)
	ui.show("UI/MBModifyGuildInfo", 0,
		{ title = TEXT.title_ModifyGuildNotice, modifyType = 2, showType = 2, })
end

function on_grpmanagelist_ent(go, i)
	local GrpManageList = Ref.SubContents.SubManageContent.SubManageListView.GrpManageList

	local n = i + 1
	GrpManageList:setindex(go, n)

	local memberInfo = manageMemberList[n]
	local Ent = ui.ref(go)

	Ent.lbMemName.text = memberInfo.name
	Ent.lbMemLevel.text = memberInfo.level
end

function on_subcontents_submanagecontent_submanagelistview_grpmanagelist_entmemberinfo_btnrefuse_click(btn)
	local GrpManageList = Ref.SubContents.SubManageContent.SubManageListView.GrpManageList
	local index = GrpManageList:getindex(btn.transform.parent)
	local memberInfo = manageMemberList[index]
	table.remove(manageMemberList, index)
	rfsh_manage_list_view()
	NW.GUILD.RequestDealApply(memberInfo.id, false)
end

function on_subcontents_submanagecontent_submanagelistview_grpmanagelist_entmemberinfo_btnagree_click(btn)
	local GrpManageList = Ref.SubContents.SubManageContent.SubManageListView.GrpManageList
	local index = GrpManageList:getindex(btn.transform.parent)
	local memberInfo = manageMemberList[index]
	table.remove(manageMemberList, index)
	rfsh_manage_list_view()
	NW.GUILD.RequestDealApply(memberInfo.id, true)
end

function on_subcontents_submanagecontent_tglswitch_click(tgl)
	anim_toggle_changed(tgl)
	NW.GUILD.RequestChangeSetting(tgl.value)
end

function on_grpguildloglist_ent(go, i)
	--libugui.SetLoopCap(Ref.SubContents.SubClanLogContent.SubScroll.GrpContent.go, #guildLogList, true)
	local GrpContent = Ref.SubContents.SubClanLogContent.SubScroll.GrpContent
	local n = i + 1
	GrpContent:setindex(go, n)

	local guildLogInfo = guildLogList[n]
	local Ent = ui.ref(go)

	libugui.SetText(Ent.go, guildLogInfo.logStr)
	local logTime = os.date2secs() - guildLogInfo.time
	Ent.lbLogDate.text = string.format(TEXT.fmtOffline, os.last2string(logTime, 1))
	--Ent.lbLogDate.text =
end

function on_grpguildlist_ent(go, i)
	local GrpGuildList = Ref.SubContents.SubClanListContent.SubClanListView.GrpGuildList

	local n = i + 1
	GrpGuildList:setindex(go, n)

	local guildInfo = guildList[n]
	local Ent = ui.ref(go)

	Ent.lbRankNo.text = n

	local guildBadge = _G.DEF.GuildBadge.gen(guildInfo.guildIcon)
	guildBadge:show_bgcolor(Ent.spGuildBadge)
	guildBadge:show_sdicon(Ent.spGuildBadgeSd)
	guildBadge:show_sdcolor(Ent.spGuildBadgeSd)
	guildBadge:show_pticon(Ent.spGuildBadgePt)
	guildBadge:show_ptcolor(Ent.spGuildBadgePt)

	Ent.lbGuildName.text = guildInfo.guildName
	Ent.lbGuildLeader.text = guildInfo.leaderName
	Ent.lbGuildLevel.text = guildInfo.guildLevel
	Ent.lbGuildMemberCnt.text = string.format("%d/%d", guildInfo.guildMemCnt, guildInfo.guildMemLimitCnt)
	Ent.lbGuildActivity.text = guildInfo.guildActivity

	if myApply[guildInfo.guildID] then
		libunity.SetActive(Ent.spApplied, true)
		libunity.SetActive(Ent.spLocked, false)
	else
		libunity.SetActive(Ent.spApplied, false)
		libunity.SetActive(Ent.spLocked, guildInfo.isLocked)
	end

	if selectedClanListIndex == n then
		forceUpdateClanListSelected(go)
	else
		libunity.SetActive(Ent.spSelected, false)
	end
end

function on_subcontents_subclanlistcontent_subclanlistview_grpguildlist_entguildinfo_click(btn)
	local GrpGuildList = Ref.SubContents.SubClanListContent.SubClanListView.GrpGuildList
	local index = GrpGuildList:getindex(btn)
	selectedClanListIndex = index
	forceUpdateClanListSelected(btn)
	rfsh_clanlist_notice_view()
end

function on_subcontents_subclanlistcontent_btnjoin_click(btn)
	local guildInfo = guildList[selectedClanListIndex]
	if guildInfo then
		NW.GUILD.RequestApplyGuild(guildInfo.guildID)
	end
end

function on_subcontents_subclanlistcontent_btncreate_click(btn)
	ui.show("UI/MBModifyGuildInfo", 0,
		{ title = TEXT.title_CreateGuild, modifyType = 1, showType = 7,
		 cost = config("paylib").get_dat("CreateGuild").amount,})
end

function on_subcontents_subclanlistcontent_inpsearch_submit(inp, text)

end

function on_subcontents_subclanlistcontent_btnsearch_click(btn)
	local SubClanListContent = Ref.SubContents.SubClanListContent
	local searchKey = SubClanListContent.inpSearch.text
	if #searchKey == 0 then
		if NW.connected() then
			NW.GUILD.RequestGetGuildList()
		else
			-- 测试开始
			-- rfsh_clan_list_view(Debug_get_guild_date(100))
			-- 测试结束
		end
	else
		if NW.connected() then
			NW.GUILD.RequestSearchGuild(searchKey)
		else
			-- 测试开始
			-- rfsh_clan_list_view(Debug_get_guild_date(1))
			-- 测试结束
		end
	end
end

function on_subtogs_tglmyclan_click(tgl)
	local SubMyClanContent = Ref.SubContents.SubMyClanContent
	libugui.SetVisible(GO(tgl, "lbTogName"), not tgl.value)
	if tgl.value then
		libugui.SetVisible(SubMyClanContent.go, true)
		NW.GUILD.RequestGetMyGuildInfo()
	else
		libugui.SetVisible(SubMyClanContent.go, false)
	end
end

function on_subtogs_tgllog_click(tgl)
	local SubClanLogContent = Ref.SubContents.SubClanLogContent
	libugui.SetVisible(GO(tgl, "lbTogName"), not tgl.value)
	if tgl.value then
		libugui.SetVisible(SubClanLogContent.go, true)
		NW.GUILD.RequestGetGuildLog()
	else
		libugui.SetVisible(SubClanLogContent.go, false)
	end
end

function on_subtogs_tglmanage_click(tgl)
	local SubManageContent = Ref.SubContents.SubManageContent
	libugui.SetVisible(GO(tgl, "lbTogName"), not tgl.value)
	if tgl.value then
		libugui.SetVisible(SubManageContent.go, true)
		NW.GUILD.RequestGetApplyList()
	else
		libugui.SetVisible(SubManageContent.go, false)
	end
end

function on_subtogs_tglclanlist_click(tgl)
	local SubClanListContent = Ref.SubContents.SubClanListContent
	libugui.SetVisible(GO(tgl, "lbTogName"), not tgl.value)
	if tgl.value then
		libugui.SetVisible(SubClanListContent.go, true)
		if NW.connected() then
			NW.GUILD.RequestGetGuildList()
		else
			-- 测试开始
			-- rfsh_clan_list_view(Debug_get_guild_date(100))
			-- 测试结束
		end
	else
		libugui.SetVisible(SubClanListContent.go, false)
	end
end
function on_subtogs_tglempty_click(tgl)

end
--!* [结束] 自动生成函数  *--

function init_view()
	ui.group(Ref.SubContents.SubMyClanContent.SubMemberList.SubMemberListView.GrpMemberList)
	ui.group(Ref.SubContents.SubManageContent.SubManageListView.GrpManageList)
	ui.group(Ref.SubContents.SubClanLogContent.SubScroll.GrpContent)
	ui.group(Ref.SubContents.SubClanListContent.SubClanListView.GrpGuildList)
	--!* [结束] 自动生成代码 *--
end

function init_logic()
	Ref.SubTogs.tglEmpty.value = true

	--我的公会Content
	local SubMyClanContent = Ref.SubContents.SubMyClanContent
	self.spMemberSelected = SubMyClanContent.SubMemberList.SubMemberListView.spSelected
	libunity.SetActive(self.spMemberSelected, false)

	--公会列表Content
	local SubClanListContent = Ref.SubContents.SubClanListContent
	self.spClanListSelected = SubClanListContent.SubClanListView.spSelected
	libunity.SetActive(self.spClanListSelected, false)

	rfsh_player_assets()
	local tog = init_guild_togs()
	tog.value = true
end

function show_view()

end

function on_recycle()
	--我的公会Content
	local SubMyClanContent = Ref.SubContents.SubMyClanContent
	libunity.SetParent(self.spMemberSelected, SubMyClanContent.SubMemberList.SubMemberListView.go, true, -1)
	libunity.SetActive(self.spMemberSelected, true)

	--公会列表Content
	local SubClanListContent = Ref.SubContents.SubClanListContent
	libunity.SetParent(self.spClanListSelected, SubClanListContent.SubClanListView.go, true, -1)
	libunity.SetActive(self.spClanListSelected, true)

	Ref.SubTogs.tglEmpty.value = true
end

local jumpTog = false
Handlers = {
	["GUILD.SC.GET_GUILD_LIST"] = rfsh_clan_list_view,
	["GUILD.SC.GET_MY_APPLY_LIST"] = function (data)
		if data.MyApply then
			myApply = {}
			for _,v in pairs(data.MyApply) do
				myApply[v] = 1
			end
		end
	end,
	["GUILD.SC.SEARCH_GUILD"] = rfsh_clan_list_view,
	["GUILD.SC.APPLY_JOIN_GUILD"] = function(applyGuildID)
		if applyGuildID == -1 then
			return
		end
		myApply[applyGuildID] = 1
		rfsh_clan_list_view()
	end,
	["GUILD.SC.CREATE_GUILD"] = function (err)
		if err == nil then
			NW.GUILD.RequestGetGuildList()
			NW.GUILD.RequestGetMyGuildInfo()
			jumpTog = true
		end
	end,
	["GUILD.SC.GUILD_MY_INFO"] = function ()
		local tog = init_guild_togs()
		if jumpTog == true then
			jumpTog = false
			tog.value = true
		end
		rfsh_myclen_view()
	end,
	["GUILD.SC.GAIN_WELFARE_REWARD"] = function (wlfId)
		if wlfId then
			rfsh_myclen_weekact_view()
		end
	end,
	["GUILD.SC.GUILD_CHANGE_DESC"] = function (ret)
		if ret then
			rfsh_myclen_claninfo_view()
		end
	end,
	["GUILD.SC.GET_GUILD_APPLY_LIST"] = function (data)
		rfsh_manage_list_view(data.ApplyList)
		rfsh_manage_accept_switch_state(data.IsOpen)
	end,
	["GUILD.SC.GUILD_OPERATE"] = function (ret)
		if ret then
			rfsh_myclen_view()
		end
	end,
	["GUILD.SC.GUILD_CHANGE_SETTING"] = function (isOpen)
		if isOpen ~= nil then
			rfsh_manage_accept_switch_state(isOpen)
		end
	end,
	["GUILD.SC.GUILD_CHANGE_JOB"] = function (ret)
		if ret then
			rfsh_myclen_view()
		end
	end,
	["GUILD.SC.GUILD_KICK_OUT"] = function (ret)
		if ret then
			rfsh_myclen_view()
		end
	end,
	["GUILD.SC.GET_GUILD_LOG_LIST"] = function (logList)
		if logList then
			guildLogList = logList
			rfsh_guild_log_view()
		end
	end,
	["PLAYER.SC.ROLE_ASSET_GET"] = rfsh_player_assets,
	["GUILD.SC.GUILD_QUIT"] = function (err)
		if err == nil then
			local tog = init_guild_togs()
			tog.value = true
		end
	end,
	["GUILD.SC.CONFIRM_DISSOLUTION_GUILD"] = function (err)
		if err == nil then
			local tog = init_guild_togs()
			tog.value = true
		end
	end,
	["GUILD.SC.GUILD_ID_CHANGE_NOTICE"] = function (modifyType)
		if modifyType == 1 then
			NW.GUILD.RequestGetMyGuildInfo()
		else
			local SubContents = Ref.SubContents
			libugui.SetVisible(SubContents.SubMyClanContent.go, false)
			libugui.SetVisible(SubContents.SubManageContent.go, false)
			libugui.SetVisible(SubContents.SubClanLogContent.go, false)
			local tog = init_guild_togs()
			tog.value = true
		end
	end,
}

return self

