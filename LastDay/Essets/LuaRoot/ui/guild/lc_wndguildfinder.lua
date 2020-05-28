--
-- @file    ui/guild/lc_wndguildfinder.lua
-- @author  shenbingkang
-- @date    2018-09-04 15:03:14
-- @desc    WNDGuildFinder
--

local self = ui.new()
local _ENV = self

local guildlib = config("guildlib")
local itemlib = config("itemlib")

-- 建筑列表中不显示以下建筑
local HIDE_BUILDING_ID = {
	[1] = true,
	[5] = true
}

self.StatusBar = {
	AssetBar = true,
	HealthyBar = true,
}

local searchKey

local function rfsh_search_view()
	local SubSearch = Ref.SubMain.SubSearch
	SubSearch.lbChanel.text = #searchKey > 0 and searchKey or TEXT.GuildSearchKeyEmpty
end

local function input_searchkey(inputChar)

	local containsDot = searchKey:find("[.]")

	if #searchKey > 6 and containsDot ~= nil then
		return
	elseif #searchKey > 5 and containsDot == nil then
		return
	end

	if inputChar == "." and containsDot ~= nil then
		return
	end
	searchKey = searchKey .. inputChar

	rfsh_search_view()

end

local function clean_searchkey()
	searchKey = ""
	rfsh_search_view()
end

local selectedMemberListIndex

local function forceUpdateMemberListSelected(go)
	libunity.SetParent(self.spMemberSelected, go, false, -1)
	libunity.SetActive(self.spMemberSelected, true)
end

local function rfsh_guild_member_list_view()
	local SubMemberListView = Ref.SubMain.SubViews.SubMemberView.SubMemberListView
	local GrpMemberList = SubMemberListView.GrpMemberList

	local pageMaxCnt = math.ceil(libugui.GetRectSize(SubMemberListView.go).y / 80)
	local memCnt = #DY_DATA.MyGuildMemberList

	local scroll = SubMemberListView.go:GetComponent("ScrollRect")
	if pageMaxCnt > memCnt then
		scroll:StopMovement()
		scroll.verticalNormalizedPosition = 1
		libunity.SetEnable(scroll, false)
	else
		libunity.SetEnable(scroll, true)
	end

	if selectedMemberListIndex > memCnt then
		selectedMemberListIndex = memCnt
	end
	libugui.SetLoopCap(GrpMemberList.go, math.max(memCnt, pageMaxCnt), true)
end

local function on_mantenance_fin(tm)
	NW.GUILD.RequestForceManager()
	return true
end

local function on_mantenance_timer(tm)
	local SubOverview = Ref.SubMain.SubViews.SubOverview
	if tm.count == 0 then
		local MyGuildInfo = DY_DATA.MyGuildInfo
		libunity.SetActive(SubOverview.spMatenanceStop, MyGuildInfo.guildCaptial < MyGuildInfo.guildManten)
		SubOverview.lbMatenanceTime.text = nil
		SubOverview.lbMantenance.color = "#FF0000"
		return
	end
	SubOverview.lbMatenanceTime.text = tm:to_time_string()
	SubOverview.lbMantenance.color = "#DCDCDC"
	libunity.SetActive(SubOverview.spMatenanceStop, false)
end

local function rfsh_guild_log_view(logList)
	local GrpLogView = Ref.SubMain.SubViews.SubOverview.SubLogView.GrpLogView

	GrpLogView:dup(#logList, function (i, Ent, isNew)
		local guildLogInfo = logList[i]

		libugui.SetText(Ent.go, guildLogInfo.logStr)
		local logTime = os.date2secs() - guildLogInfo.time
		Ent.lbLogDate.text = string.format(TEXT.fmtOffline, os.last2string(logTime, 1))
	end)
end

local function rfsh_guild_overview()
	local SubOverview = Ref.SubMain.SubViews.SubOverview
	SubOverview.lbExploit.text = DY_DATA:nget_asset("Exploit")
	local MyGuildInfo = DY_DATA.MyGuildInfo
	SubOverview.lbCptial.text = MyGuildInfo.guildCaptial
	SubOverview.lbMantenance.text = MyGuildInfo.guildManten

	local leftTime = MyGuildInfo.guildNextMantenTime and (MyGuildInfo.guildNextMantenTime - os.date2secs()) or 0

	if leftTime > 0 then
		local tm = DY_TIMER.replace_timer("GuildMantenance",
			leftTime, leftTime, on_mantenance_fin)
		tm:subscribe_counting(Ref.go, on_mantenance_timer)
		on_mantenance_timer(tm)
	else
		DY_TIMER.stop_timer("GuildMantenance")
		SubOverview.lbMatenanceTime.text = nil
		SubOverview.lbMantenance.color = "#FF0000"
		libunity.SetActive(SubOverview.spMatenanceStop, true)
	end
end

local function on_claim_fin(tm)
	return true
end

local function on_claim_timer(tm)
	local SubExchangeView = Ref.SubMain.SubViews.SubExchangeView
	SubExchangeView.lbRefreshTime.text = tm:to_time_string()
	if tm.count == 0 then
		libugui.SetInteractable(SubExchangeView.btnRequestExchange, true)
		libunity.SetActive(SubExchangeView.spRefresh, false)
		return
	end
end

local function rfsh_exchange_friendly_view()
	local SubExchangeView = Ref.SubMain.SubViews.SubExchangeView

	local friendlyLvInfo = guildlib.get_exchange_friendly_level(self.myFriendlyValue)
	SubExchangeView.lbFriendlyLevel.text = friendlyLvInfo.level

	local curLevelExp = self.myFriendlyValue - friendlyLvInfo.preExp
	local curNeedExp = friendlyLvInfo.exp - friendlyLvInfo.preExp
	local proValue = curLevelExp / curNeedExp

	SubExchangeView.barFriendly.value = proValue
	SubExchangeView.lbFriendlyExp.text = string.format(TEXT.fmtCnt_Adequate, curLevelExp, curNeedExp)

	local leftClaimTime = DY_DATA.GuildClaimTime - os.date2secs()
	if leftClaimTime > 0 then
		libugui.SetInteractable(SubExchangeView.btnRequestExchange, false)
		libunity.SetActive(SubExchangeView.spRefresh, true)
		local tm = DY_TIMER.replace_timer("GuildClaimTimer",
		leftClaimTime, leftClaimTime, on_claim_fin)
		tm:subscribe_counting(Ref.go, on_claim_timer)
		on_claim_timer(tm)
	else
		DY_TIMER.stop_timer("GuildClaimTimer")
		libugui.SetInteractable(SubExchangeView.btnRequestExchange, true)
		libunity.SetActive(SubExchangeView.spRefresh, false)
	end

end

local function rfsh_guild_exchange_view()
	if self.claimList == nil then self.claimList = {} end
	if self.myFriendlyValue == nil then self.myFriendlyValue = 0 end
	if self.myExchangeList == nil then self.myExchangeList = {} end

	rfsh_exchange_friendly_view()

	local SubView = Ref.SubMain.SubViews.SubExchangeView.SubView
	local GrpExchangeList = SubView.GrpExchangeList

	local pageMaxCnt = math.ceil(libugui.GetRectSize(SubView.go).y / 80)
	local excCnt = #self.claimList

	local scroll = SubView.go:GetComponent("ScrollRect")
	if pageMaxCnt > excCnt then
		scroll:StopMovement()
		scroll.verticalNormalizedPosition = 1
		libunity.SetEnable(scroll, false)
	else
		libunity.SetEnable(scroll, true)
	end

	libugui.SetLoopCap(GrpExchangeList.go, math.max(excCnt, pageMaxCnt), true)
end

local function rfsh_guild_badge(badgeStr)
	local SubGuildDetail = Ref.SubMain.SubGuildInfo.SubGuildDetail

	local guildBadge = _G.DEF.GuildBadge.gen(badgeStr)
	guildBadge:show_bgcolor(SubGuildDetail.spGuildBadge)
	guildBadge:show_sdicon(SubGuildDetail.spGuildBadgeSd)
	guildBadge:show_sdcolor(SubGuildDetail.spGuildBadgeSd)
	guildBadge:show_pticon(SubGuildDetail.spGuildBadgePt)
	guildBadge:show_ptcolor(SubGuildDetail.spGuildBadgePt)
end

local function on_refresh_guildlist_fin()
	return true
end

local function on_refresh_guildlist_timer(tm)
	local SubGuildDetail = Ref.SubMain.SubGuildInfo.SubGuildDetail
	if tm.count == 0 then
		libunity.SetActive(SubGuildDetail.spRefresh, false)
		libunity.SetActive(GO(SubGuildDetail.btnRefresh, "SubCost"), false)
		libunity.SetActive(GO(SubGuildDetail.btnRefresh, "lbFree"), true)
		return
	end
	libunity.SetActive(SubGuildDetail.spRefresh, true)
	SubGuildDetail.lbRefreshTime.text = tm:to_time_string()
end


local function rfsh_empty_guildinfo_view()
	local SubGuildDetail = Ref.SubMain.SubGuildInfo.SubGuildDetail

	SubGuildDetail.lbChanel.text = TEXT.guildChanelID:csfmt(TEXT.ChanelEmpty)
	SubGuildDetail.lbGuildName.text = nil
	SubGuildDetail.lbGuildLevel.text = TEXT.GuildLevel:csfmt(0)

	rfsh_guild_badge(nil)

	SubGuildDetail.lbDesc.text = TEXT.GuildEmptyNotice
	SubGuildDetail.lbActivity.text =  0
	local memCnt = 0
	local memCntLimit = 0
	SubGuildDetail.lbMember.text = string.format("%d/%d", memCnt, memCntLimit)

	SubGuildDetail.SubInfo.GrpBuilding:dup(0, function (i, Ent, isNew)	end)

	libunity.SetActive(SubGuildDetail.SubInfo.SubEditDesc.go, false)
	libunity.SetActive(SubGuildDetail.SubFlip.go, false)

	libunity.SetActive(SubGuildDetail.btnApplyJoin, false)
	libunity.SetActive(SubGuildDetail.btnRefresh, false)
	DY_TIMER.stop_timer("RefreshGuildList")
	libunity.SetActive(SubGuildDetail.spRefresh, false)

	libunity.SetActive(SubGuildDetail.btnQuit, false)
end

local function rfsh_guildinfo_view(guildInfo)
	local SubGuildDetail = Ref.SubMain.SubGuildInfo.SubGuildDetail

	libunity.SetActive(SubGuildDetail.SubFlip.go, false)
	if type(guildInfo) == "number" then
		SubGuildDetail.SubFlip.lbPageNum.text = guildInfo
		guildInfo = self.ShowGuildList[guildInfo]
		libunity.SetActive(SubGuildDetail.SubFlip.go, true)
	end

	if guildInfo == nil or guildInfo.guildID == nil then
		self.CurShowGuildId = nil
		rfsh_empty_guildinfo_view()
		return
	end

	self.CurShowGuildId = guildInfo.guildID

	SubGuildDetail.lbChanel.text = TEXT.guildChanelID:csfmt(guildInfo.guildChanelStr)
	SubGuildDetail.lbGuildName.text = guildInfo.guildName
	SubGuildDetail.lbGuildLevel.text = TEXT.GuildLevel:csfmt(guildInfo.guildLevel)

	rfsh_guild_badge(guildInfo.guildIcon)

	SubGuildDetail.lbDesc.text = #guildInfo.guildDesc == 0 and TEXT.GuildDefaultNotice or guildInfo.guildDesc

	SubGuildDetail.lbActivity.text = guildInfo.guildActivity

	local memCnt = guildInfo.guildMemCnt
	local memCntLimit = guildInfo.guildMemLimitCnt
	SubGuildDetail.lbMember.text = string.format("%d/%d", memCnt, memCntLimit)

	local buildingList = {}
	for _,v in pairs(guildInfo.guildBuildings) do
		if HIDE_BUILDING_ID[v.buildingId] == nil then
			table.insert(buildingList, v)
		end
	end

	SubGuildDetail.SubInfo.GrpBuilding:dup(#buildingList, function (i, Ent, isNew)
		local buildingInfo = buildingList[i]

		local resInfo, departmentInfo = guildlib.get_building_info(
			buildingInfo.buildingId, buildingInfo.buildingLv)
			
		ui.seticon(Ent.spIcon, departmentInfo.unitBase.icon)
		Ent.lbLevel.text = string.format(TEXT.fmtLv, buildingInfo.buildingLv)
	
	end)

	local Player = DY_DATA:get_player()

	if Player.guildID == 0 then
		libunity.SetActive(SubGuildDetail.SubInfo.SubEditDesc.go, false)
		libugui.SetInteractable(SubGuildDetail.spGuildBadge, false)

		libunity.SetActive(SubGuildDetail.btnApplyJoin, true)
		libunity.SetActive(SubGuildDetail.btnRefresh, true)
		libunity.SetActive(SubGuildDetail.btnQuit, false)

		local leftTime = DY_DATA.GuildListRefreshTime - os.date2secs()
		if leftTime > 0 then
			local tm = DY_TIMER.replace_timer("RefreshGuildList",
				leftTime, leftTime, on_refresh_guildlist_fin)
				tm:subscribe_counting(Ref.go, on_refresh_guildlist_timer)
			on_refresh_guildlist_timer(tm)

			local Cost = config("paylib").get_dat("RefreshGuildList", DY_DATA.GuildRefreshTime + 1, true)
			libunity.SetActive(GO(SubGuildDetail.btnRefresh, "SubCost"), true)
			libunity.SetActive(GO(SubGuildDetail.btnRefresh, "lbFree"), false)
			libugui.SetText(GO(SubGuildDetail.btnRefresh, "SubCost/lbCost"), Cost.amount)

		else
			libunity.SetActive(SubGuildDetail.spRefresh, false)
			libunity.SetActive(GO(SubGuildDetail.btnRefresh, "SubCost"), false)
			libunity.SetActive(GO(SubGuildDetail.btnRefresh, "lbFree"), true)
		end
	else

		local myGuildMemberInfo = DY_DATA:get_guild_member_info(Player.id)

		local bCanEditDesc = false
		bCanEditDesc = myGuildMemberInfo and myGuildMemberInfo.position >= 3 or false

		libunity.SetActive(SubGuildDetail.SubInfo.SubEditDesc.go, bCanEditDesc)
		libugui.SetInteractable(SubGuildDetail.spGuildBadge, bCanEditDesc)

		libunity.SetActive(SubGuildDetail.btnApplyJoin, false)
		libunity.SetActive(SubGuildDetail.btnRefresh, false)
		DY_TIMER.stop_timer("RefreshGuildList")
		libunity.SetActive(SubGuildDetail.spRefresh, false)
		libunity.SetActive(SubGuildDetail.btnQuit, true)
	end
end

local function rfsh_guild_view(myGuildID)
	if myGuildID == nil then
		local Player = DY_DATA:get_player()
		myGuildID = Player.guildID
	end

	if myGuildID == 0 then
		Ref.lbTitle.text = TEXT.Title_Guild_Finder
		Ref.SubMain.SubViews.SubTabs.tglEmpty.value = true

		libunity.SetActive(Ref.SubMain.SubGuildInfo.go, true)
		libunity.SetActive(Ref.SubMain.SubSearch.go, true)
		libunity.SetActive(Ref.SubMain.SubViews.go, false)

		rfsh_guildinfo_view(self.ShowGuildList[self.CurShowIndex])
	else
		Ref.lbTitle.text = TEXT.Title_Guild

		libunity.SetActive(Ref.SubMain.SubSearch.go, false)
		libunity.SetActive(Ref.SubMain.SubViews.go, true)

		rfsh_guildinfo_view(DY_DATA.MyGuildInfo)
		Ref.SubMain.SubViews.SubTabs.tglOverview.value = true
	end
end

local function set_tips_infomation()
	Ref.SubTips.SubPositionInfomation.lbInfomation.text = TEXT.GuildPositionInfomation:csfmt(
		CVar.GUILD.ProbationFeatsLimit, CVar.GUILD.ProbationFeatsLimit, CVar.GUILD.MemberFeatsLimit)
end

--!* [开始] 自动生成函数 *--

function on_btnseven_click(btn)
	input_searchkey(7)
end

function on_btneight_click(btn)
	input_searchkey(8)
end

function on_btnnine_click(btn)
	input_searchkey(9)
end

function on_btnback_click(btn)
	searchKey = searchKey:sub(1, -2)
	rfsh_search_view()
end

function on_btnfour_click(btn)
	input_searchkey(4)
end

function on_btnfive_click(btn)
	input_searchkey(5)
end

function on_btnsix_click(btn)
	input_searchkey(6)
end

function on_btnenter_click(btn)
	local inputChanelNum = tonumber(searchKey)
	if inputChanelNum then
		inputChanelNum = math.floor(inputChanelNum * 1000)
		NW.GUILD.RequestSearchGuild(inputChanelNum)
	else
		rfsh_guildinfo_view(self.CurShowIndex)
	end
end

function on_btnone_click(btn)
	input_searchkey(1)
end

function on_btntwo_click(btn)
	input_searchkey(2)
end

function on_btnthree_click(btn)
	input_searchkey(3)
end

function on_btnac_click(btn)
	clean_searchkey()
	rfsh_guildinfo_view(self.CurShowIndex)
end

function on_btnzero_click(btn)
	input_searchkey(0)
end

function on_btndot_click(btn)
	input_searchkey(".")
end

function on_submain_subviews_suboverview_btndonate_click(btn)
	ui.show("UI/MBGuildDonateSelect", 0)
end

function on_submain_subviews_submemberview_subheader__subpos_ptrdown(evt, data)
	local SubPositionInfomation = Ref.SubTips.SubPositionInfomation
	libunity.SetActive(SubPositionInfomation.go, true)
end

function on_grpmemberlist_ent(go, i)
	local GrpMemberList = Ref.SubMain.SubViews.SubMemberView.SubMemberListView.GrpMemberList

	local n = i + 1
	GrpMemberList:setindex(go, n)

	local memberInfo = DY_DATA.MyGuildMemberList[n] or {}
	local Ent = ui.ref(go)
	libugui.SetInteractable(Ent.go, memberInfo.id ~= nil)

	local bgColor
	if (n & 1) == 1 then
		bgColor = "#626262"
	else
		bgColor = "#474646"
	end
	libugui.SetColor(Ent.spBg, bgColor)

	Ent.lbMemName.text = memberInfo.name
	Ent.lbMemPosition.text = memberInfo.position and guildlib.get_position_name(memberInfo.position)
	Ent.lbMemLevel.text = memberInfo.level
	Ent.lbMemContribution.text = memberInfo.contribution

	local lastTime = memberInfo.lastLogoutTime

	if lastTime == nil then
		Ent.lbMemState.text = nil
	elseif lastTime == 0 then
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

function on_submain_subviews_submemberview_submemberlistview_grpmemberlist_entmemberinfo_click(btn, event)
	local GrpMemberList = Ref.SubMain.SubViews.SubMemberView.SubMemberListView.GrpMemberList
	local index = GrpMemberList:getindex(btn)

	local operPlayerInfo = DY_DATA.MyGuildMemberList[index]
	if operPlayerInfo then
		selectedMemberListIndex = index
		forceUpdateMemberListSelected(btn)

		local Player = DY_DATA:get_player()
		local operPlayerInfo = DY_DATA.MyGuildMemberList[index]

		if operPlayerInfo.id == 1 then
			_G.UI.Toast.norm(TEXT.CantClickGuildBossAlert)
		elseif operPlayerInfo.id ~= Player.id then
			--点击自己的名片，不弹右键菜单
			local isfriend = NW.FRIEND.check_isfriend(operPlayerInfo.id)

			local rightmenu = _G.PKG["ui/rightmenu"]
			local MenuArr = { }
			if isfriend then
				table.insert(MenuArr,rightmenu.DelFriend)
			else
				table.insert(MenuArr,rightmenu.AddFriend)
			end
			table.insert(MenuArr,rightmenu.Whisper)
			ui.show("UI/WNDPlayerRightMenu", 0,
				{ pos = event.position, MenuArr = MenuArr,
		 		 Args = { operPlayerInfo.id, operPlayerInfo.name,self.depth, CVar.ChatSource.Guild},
				})
		end
	end
end

function on_grpexchangelist_ent(go, i)
	local GrpExchangeList = Ref.SubMain.SubViews.SubExchangeView.SubView.GrpExchangeList

	local n = i + 1
	GrpExchangeList:setindex(go, n)

	local claimInfo = self.claimList[n]
	local Ent = ui.ref(go)
	local SubClaimInfo = Ent.SubClaimInfo

	local bgColor
	if (n & 1) == 1 then
		bgColor = "#626262"
	else
		bgColor = "#474646"
	end
	libugui.SetColor(Ent.spBg, bgColor)

	if claimInfo then
		libunity.SetActive(SubClaimInfo.go, true)
		local userInfo = DY_DATA:get_guild_member_info(claimInfo.requestUserId)
		SubClaimInfo.lbMemName.text = userInfo.name

		local Item = ItemDEF.new(claimInfo.requestItemId, 1)
		local itemData = Item:get_base_data()
		Item:show_icon(Ent.spItemIcon)
		Item:show_rarityIcon(Ent.spRarity)

		SubClaimInfo.SubRequest.lbItemName.text = itemData.name

		local proValue = claimInfo.receiveItemCnt / claimInfo.requestItemCnt
		SubClaimInfo.SubRequest.barExc.value = proValue
		SubClaimInfo.SubRequest.lbExc.text = string.format(TEXT.fmtCnt_Adequate, claimInfo.receiveItemCnt, claimInfo.requestItemCnt)

		local ownCnt = DY_DATA:nget_item(claimInfo.requestItemId)
		SubClaimInfo.lbOwnCnt.text = ownCnt == 0 and string.format("<color=red>%d</color>", ownCnt) or ownCnt

		libunity.SetActive(SubClaimInfo.btnExchange, true)
		local Player = DY_DATA:get_player()
		if claimInfo.requestUserId == Player.id then
			libunity.SetActive(SubClaimInfo.btnExchange, false)
		elseif claimInfo.receiveItemCnt == claimInfo.requestItemCnt then
			libugui.SetInteractable(SubClaimInfo.btnExchange, false)
			libugui.SetText(GO(SubClaimInfo.btnExchange, "&lbText"), TEXT.GuildExchangeOver)
		elseif self.myExchangeList[claimInfo.requestId] then
			libugui.SetInteractable(SubClaimInfo.btnExchange, false)
			libugui.SetText(GO(SubClaimInfo.btnExchange, "&lbText"), TEXT.GuildExchanged)
		elseif ownCnt < 1 then
			libugui.SetInteractable(SubClaimInfo.btnExchange, false)
			libugui.SetText(GO(SubClaimInfo.btnExchange, "&lbText"), TEXT.GuildExchangeLack)
		else
			libugui.SetInteractable(SubClaimInfo.btnExchange, true)
			libugui.SetText(GO(SubClaimInfo.btnExchange, "&lbText"), TEXT.GuildExchange)
		end
	else
		libunity.SetActive(SubClaimInfo.go, false)
	end
end

function on_entexchange_click(btn)
	local GrpExchangeList = Ref.SubMain.SubViews.SubExchangeView.SubView.GrpExchangeList
	local index = ui.index(btn)
	local claimInfo = self.claimList[index]
	if claimInfo then
		NW.GUILD.RequestClaimComplete(claimInfo.requestId)
	end
end

function on_submain_subviews_subexchangeview_btnrequestexchange_click(btn)
	ui.show("UI/MBGuildRequestClaim", 0, { myFriendlyValue = self.myFriendlyValue, })
end

function on_submain_subviews_subtabs_tgloverview_click(tgl)
	local SubGuildInfo = Ref.SubMain.SubGuildInfo
	local SubOverview = Ref.SubMain.SubViews.SubOverview
	libugui.SetAlpha(GO(tgl, "spTabBg"), tgl.value and 1 or 0.5)

	if tgl.value then
		libugui.SetVisible(SubGuildInfo.go, true)
		libugui.SetVisible(SubOverview.go, true)
	else
		libugui.SetVisible(SubOverview.go, false)
	end
end

function on_submain_subviews_subtabs_tglmember_click(tgl)
	local SubGuildInfo = Ref.SubMain.SubGuildInfo
	local SubMemberView = Ref.SubMain.SubViews.SubMemberView
	libugui.SetAlpha(GO(tgl, "spTabBg"), tgl.value and 1 or 0.5)

	if tgl.value then
		libugui.SetVisible(SubGuildInfo.go, false)
		libugui.SetVisible(SubMemberView.go, true)
	else
		libugui.SetVisible(SubMemberView.go, false)
	end
end

function on_submain_subviews_subtabs_tglexchange_click(tgl)
	local SubGuildInfo = Ref.SubMain.SubGuildInfo
	local SubExchangeView = Ref.SubMain.SubViews.SubExchangeView
	libugui.SetAlpha(GO(tgl, "spTabBg"), tgl.value and 1 or 0.5)
	
	if tgl.value then
		NW.GUILD.RequestGuildClaimList()
		libugui.SetVisible(SubGuildInfo.go, false)
		libugui.SetVisible(SubExchangeView.go, true)
	else
		libugui.SetVisible(SubExchangeView.go, false)
	end
end

function on_submain_subviews_subtabs_tglempty_click(tgl)

end

function on_guildbadge_click(btn)
	ui.show("UI/MBModifyGuildBadge", 0,
		{ badge = DY_DATA.MyGuildInfo.guildIcon,})
end

function on_submain_subguildinfo_subguilddetail_subinfo_subeditdesc_btnedit_click(btn)
	ui.show("UI/MBModifyGuildDesc", 0)
end

function on_submain_subguildinfo_subguilddetail_subflip_btnpreguild_click(btn)
	self.CurShowIndex = self.CurShowIndex - 1
	if self.CurShowIndex < 1 then
		self.CurShowIndex = #self.ShowGuildList
	end
	rfsh_guildinfo_view(self.CurShowIndex)
end

function on_submain_subguildinfo_subguilddetail_subflip_btnnextguild_click(btn)
	self.CurShowIndex = self.CurShowIndex + 1
	local cnt = #self.ShowGuildList
	if self.CurShowIndex > cnt then
		self.CurShowIndex = cnt == 0 and 0 or 1
	end
	rfsh_guildinfo_view(self.CurShowIndex)
end

function on_submain_subguildinfo_subguilddetail_btnapplyjoin_click(btn)
	if self.CurShowGuildId then
		_G.UI.MBox.operate("JoinGuildAlert", function ()
			NW.GUILD.RequestApplyJoinGuild(self.CurShowGuildId)
		end)
	end
end

function on_submain_subguildinfo_subguilddetail_btnrefresh_click(btn)
	local leftTime = DY_DATA.GuildListRefreshTime - os.date2secs()
	if leftTime > 0 then
		local Cost = _G.DEF.Item.gen(config("paylib").get_dat("RefreshGuildList", DY_DATA.GuildRefreshTime + 1, true))
		local Params = { hint = true }
		UI.MBox.consume(Cost, "RefreshGuildList", function ()
			NW.GUILD.RequestGetGuildList(true)
		end, Params)
	else
		NW.GUILD.RequestGetGuildList(true)
	end

end

function on_submain_subguildinfo_subguilddetail_btnquit_click(btn)
	_G.UI.MBox.operate("QuitGuildAlert", function ()
		NW.GUILD.RequestQuitGuild()
	end)
end

function on_subtips_subpositioninfomation_ptrdown(evt, data)
	local SubPositionInfomation = Ref.SubTips.SubPositionInfomation
	libunity.SetActive(SubPositionInfomation.go, false)
end
--!* [结束] 自动生成函数  *--

function init_view()
	ui.group(Ref.SubMain.SubViews.SubOverview.SubLogView.GrpLogView)
	ui.group(Ref.SubMain.SubViews.SubMemberView.SubMemberListView.GrpMemberList)
	ui.group(Ref.SubMain.SubViews.SubExchangeView.SubView.GrpExchangeList)
	ui.group(Ref.SubMain.SubGuildInfo.SubGuildDetail.SubInfo.GrpBuilding)
	--!* [结束] 自动生成代码 *--
	
	self.ItemDEF = _G.DEF.Item
end

function init_logic()
	self.StatusBar.Menu = {
		icon = "CommonIcon/ico_main_057",
		name = "WNDGuildFinder",
		Context = Context,
	}

	selectedMemberListIndex = 0
	self.spMemberSelected = Ref.SubMain.SubViews.SubMemberView.SubMemberListView.spSelected
	libunity.SetActive(self.spMemberSelected, false)

	local SubTabs = Ref.SubMain.SubViews.SubTabs
	SubTabs.tglEmpty.value = true
	on_submain_subviews_subtabs_tgloverview_click(SubTabs.tglOverview)
	on_submain_subviews_subtabs_tglmember_click(SubTabs.tglMember)
	on_submain_subviews_subtabs_tglexchange_click(SubTabs.tglExchange)

	self.ShowGuildList = {}

	clean_searchkey()
	rfsh_empty_guildinfo_view()
	local Player = DY_DATA:get_player()
	rfsh_guild_view(Player.guildID)

	if Player.guildID == 0 then
		NW.GUILD.RequestGetGuildList()
	else
		Ref.SubMain.SubViews.SubTabs.tglOverview.value = true
		NW.GUILD.RequestMyGuildInfo()
		NW.GUILD.RequestGetGuildLog()
	end

	set_tips_infomation()
end

function show_view()

end

function on_recycle()
	libgame.UnitBreak(0)
	Ref.SubMain.SubViews.SubTabs.tglEmpty.value = true
	libunity.SetParent(self.spMemberSelected, Ref.SubMain.SubViews.SubMemberView.SubMemberListView.go, true, -1)
	libunity.SetActive(self.spMemberSelected, true)
end

Handlers = {
	["GUILD.SC.GET_GUILD_LIST"] = function()
		self.ShowGuildList = DY_DATA.GuildList
		self.CurShowIndex = 1
		rfsh_guildinfo_view(self.CurShowIndex)
	end,
	["GUILD.SC.SEARCH_GUILD"] = function (lst)
		rfsh_guildinfo_view(lst[1])
	end,
	["GUILD.SC.GUILD_MY_INFO"] = function ()
		self.ShowGuildList = {}
		rfsh_guild_view()

		rfsh_guild_overview()
		rfsh_guild_member_list_view()
	end,
	["GUILD.SC.APPLY_JOIN_GUILD"] = function (err)
		if err == 1360 then
			_G.UI.MBox.make("MBNormal")
				:set_param("title", TEXT.titleGuildMemberMax)
				:set_param("content", TEXT.contentGuildMemberMax)
				:set_param("single", true)
				:show()
		elseif err == nil then
			NW.GUILD.RequestMyGuildInfo()
			NW.GUILD.RequestGetGuildLog()
		end
	end,
	["GUILD.SC.GUILD_QUIT"] = function ()
		if err == nil then
			rfsh_guild_view(0)
			NW.GUILD.RequestGetGuildList()
		end
	end,
	["GUILD.SC.GUILD_CLAIM_LIST"] = function (claimInfo)
		if claimInfo then
			self.claimList = claimInfo.claimList
			self.myFriendlyValue = claimInfo.myFriendlyValue
			self.myExchangeList = claimInfo.myExchangeList
			rfsh_guild_exchange_view()
		end
	end,
	["GUILD.SC.GUILD_CLAIM_COMPLETE"] = function(claimInfo)
		if claimInfo then
			self.myExchangeList[claimInfo.claimId] = 1
			self.myFriendlyValue = claimInfo.myFriendlyValue
			rfsh_exchange_friendly_view()
		else
			NW.GUILD.RequestGuildClaimList()
		end
	end,
	["GUILD.SC.SYN_CLAIM_INFO"] = function (claimInfo)
		function replace_claiminfo(claimInfo)
			for i,v in ipairs(self.claimList) do
				if v.requestId == claimInfo.requestId then
					self.claimList[i] = claimInfo
					return i
				elseif v.requestUserId == claimInfo.requestUserId then
					table.remove(self.claimList, i)
					return
				end
			end
		end

		if self.claimList == nil then self.claimList = {} end
		local replaceIndex = replace_claiminfo(claimInfo)
		if replaceIndex == nil then
			table.insert(self.claimList, 1, claimInfo)
		end
		rfsh_guild_exchange_view()
	end,
	["PLAYER.SC.ROLE_ASSET_GET"] = function ()
		local SubOverview = Ref.SubMain.SubViews.SubOverview
		SubOverview.lbExploit.text = DY_DATA:nget_asset("Exploit")
	end,
	["GUILD.SC.GET_GUILD_LOG_LIST"] = function (logList)
		rfsh_guild_log_view(logList)
	end,
	["GUILD.SC.GUILD_CHANGE_ICON"] = function(err)
		if err == nil then
			rfsh_guild_badge(DY_DATA.MyGuildInfo.guildIcon)
		end
	end,
	["GUILD.SC.GUILD_DONATE"] = function(err)
		if err == nil then
			rfsh_guild_overview()
			local SubGuildDetail = Ref.SubMain.SubGuildInfo.SubGuildDetail
			SubGuildDetail.lbActivity.text = DY_DATA.MyGuildInfo.guildActivity
			NW.GUILD.RequestGetGuildLog()
		end
	end,
	["GUILD.SC.MEMBER_INFO"] = function()
		rfsh_guild_overview()
		rfsh_guild_member_list_view()
		NW.GUILD.RequestGetGuildLog()
	end,
	["GUILD.SC.SYN_GUILD_INFO"] = function()
		self.ShowGuildList = DY_DATA.GuildList
		rfsh_guildinfo_view(self.CurShowIndex)
	end,
	["GUILD.SC.SYN_MY_GUILD_INFO"] = function()
		rfsh_guild_overview()
	end,
	["GUILD.SC.GUILD_CHANGE_DESC"] = function(err)
		if err == nil then
			local SubGuildDetail = Ref.SubMain.SubGuildInfo.SubGuildDetail
			local desc = DY_DATA.MyGuildInfo.guildDesc
			SubGuildDetail.lbDesc.text = #desc == 0 and TEXT.GuildDefaultNotice or desc
		end
	end,
	["GUILD.SC.GUILD_CHANGE_ICON"] = function(err)
		if err == nil then
			rfsh_guild_badge(DY_DATA.MyGuildInfo.guildIcon)
		end
	end,
}

return self

