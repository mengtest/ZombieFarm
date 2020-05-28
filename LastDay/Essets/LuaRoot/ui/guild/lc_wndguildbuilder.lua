--
-- @file    ui/guild/lc_wndguildbuilder.lua
-- @author  shenbingkang
-- @date    2018-09-12 20:38:58
-- @desc    WNDGuildBuilder
--

local self = ui.new()
local _ENV = self
local guildlib = config("guildlib")
local itemlib = config("itemlib")

self.StatusBar = {
	AssetBar = true,
	HealthyBar = true,
}

local function forceUpdateSelected(go)
	libunity.SetParent(self.spSelected, go, false, -1)
	libunity.SetActive(self.spSelected, true)
end

local function rfsh_edit_cnt_view()
	local SubSelectedCnt = Ref.SubMain.SubSelectedCnt

	local donateItem = self.departmentInfo.donate[self.selectedIndex]

	local finishCnt = donateItem and self.buildingInfo.donateProgress[donateItem.id] or 0
	local needCnt = donateItem and (donateItem.amount - finishCnt) or 0
	local ownCnt = donateItem and DY_DATA:nget_item(donateItem.id) or 0

	local donateMaxValue = math.min(needCnt, ownCnt)
	SubSelectedCnt.SubProc.bar.maxValue = donateMaxValue
	SubSelectedCnt.SubProc.bar.value = donateMaxValue
	SubSelectedCnt.lbMax.text = donateMaxValue
end

local function rfsh_builder_view()
	self.resInfo, self.departmentInfo = guildlib.get_building_info(
		self.buildingInfo.buildingId, self.buildingInfo.buildingLv)

	local SubMain = Ref.SubMain
	ui.seticon(SubMain.spBuildingIcon, self.departmentInfo.unitBase.icon)
	SubMain.lbBuildingLv.text = string.format(TEXT.fmtLv, self.buildingInfo.buildingLv)
	SubMain.lbBuildingDesc.text = departmentInfo.unitBase.desc

	Ref.SubTips.SubNextLvTips.lbInfomation.text = departmentInfo.upgradeDescription

	rfsh_edit_cnt_view()

	local cnt = #departmentInfo.donate
	local isAllFull = true

	self.DonateItemList = {}
	SubMain.GrpDonate:dup(cnt, function (i, Ent, isNew)
		local donateItem = departmentInfo.donate[i]
		local finishCnt = self.buildingInfo.donateProgress[donateItem.id] or 0

		local Item = ItemDEF.new(donateItem.id, 1)
		self.DonateItemList[i] = Item
		local itemData = Item:get_base_data()

		Item:show_icon(Ent.spIcon)
		Item:show_rarityIcon(Ent.spRarity)

		Ent.lbName.text = itemData.name

		if finishCnt < donateItem.amount then
			isAllFull = false
		end
		Ent.spProc.fillAmount = finishCnt / donateItem.amount
		Ent.lbProc.text = string.format(TEXT.fmtCnt_Adequate, finishCnt, donateItem.amount)

		if self.selectedIndex == i then
			forceUpdateSelected(Ent.go)
		else
			libunity.SetActive(Ent.spSelected, true)
		end
	end)

	if cnt == 0 then
		libunity.SetActive(Ref.SubMain.lbMaxLevel, true)
		Ref.SubMain.lbMaxLevel.text = TEXT.GuildBuildMaxLevel
		libunity.SetActive(Ref.SubMain.SubSelectedCnt.go, false)
		libugui.SetInteractable(Ref.SubMain.btnDonate, false)
	elseif isAllFull then
		libunity.SetActive(Ref.SubMain.lbMaxLevel, true)
		Ref.SubMain.lbMaxLevel.text = TEXT.GuildBuildLvUpLimit:csfmt(self.departmentInfo.needGuildLv)
		SubMain.GrpDonate:hide()
		libunity.SetActive(Ref.SubMain.SubSelectedCnt.go, false)
		libugui.SetInteractable(Ref.SubMain.btnDonate, false)
	else
		libunity.SetActive(Ref.SubMain.lbMaxLevel, false)
		Ref.SubMain.lbMaxLevel.text = nil
		libunity.SetActive(Ref.SubMain.SubSelectedCnt.go, true)
		libugui.SetInteractable(Ref.SubMain.btnDonate, true)
	end
end

local function set_default_selected_index()
	if self.selectedIndex ~= 0 then
		return
	end

	self.resInfo, self.departmentInfo = guildlib.get_building_info(
		self.buildingInfo.buildingId, self.buildingInfo.buildingLv)
	local donateItemList = self.departmentInfo.donate
	for i,donateItem in pairs(donateItemList) do
		local finishCnt = donateItem and self.buildingInfo.donateProgress[donateItem.id] or 0
		local needCnt = donateItem and (donateItem.amount - finishCnt) or 0
		local ownCnt = donateItem and DY_DATA:nget_item(donateItem.id) or 0
		if needCnt > 0 and ownCnt > 0 then
			self.selectedIndex = i
			return
		end
	end
	self.selectedIndex = 0
end

--!* [开始] 自动生成函数 *--

function on_next_building_info_pressed(evt, data)
	local SubNextLvTips = Ref.SubTips.SubNextLvTips
	if data then
		libunity.SetActive(SubNextLvTips.go, true)
	else
		libunity.SetActive(SubNextLvTips.go, false)
	end
end

function on_entitem_click(btn)
	local index = ui.index(btn)
	self.selectedIndex = index

	local Ent = Ref.SubMain.GrpDonate:get(index)
	forceUpdateSelected(Ent.go)
	rfsh_edit_cnt_view()
end

function on_submain_grpdonate_entitem_spicon_pressed(evt, data)
	if data then
		local index = ui.index(evt)
		self.DonateItemList[index]:show_tip(evt)
	else
		_G.DEF.Item.hide_tip()
	end
end

function on_edit_count_changed(bar)
	local SubProc = Ref.SubMain.SubSelectedCnt.SubProc
	SubProc.lbSelectedCnt.text = string.format("%d", bar.value)
end

function on_submain_subselectedcnt_btnmuti_click(btn)
	local SubProc = Ref.SubMain.SubSelectedCnt.SubProc
	SubProc.bar.value = SubProc.bar.value - 1
end

function on_submain_subselectedcnt_btnadd_click(btn)
	local SubProc = Ref.SubMain.SubSelectedCnt.SubProc
	SubProc.bar.value = SubProc.bar.value + 1
end

function on_submain_subselectedcnt_btnmax_click(btn)
	local SubProc = Ref.SubMain.SubSelectedCnt.SubProc
	SubProc.bar.value = SubProc.bar.maxValue
end

function on_submain_btndonate_click(btn)
	local donateCnt = Ref.SubMain.SubSelectedCnt.SubProc.bar.value
	local donateItem = departmentInfo.donate[self.selectedIndex]

	if donateItem and donateCnt > 0 then
		NW.GUILD.RequestDonate(self.buildingId, donateItem.id, donateCnt)
	end
end
--!* [结束] 自动生成函数  *--

function init_view()
	ui.group(Ref.SubMain.GrpDonate)
	--!* [结束] 自动生成代码 *--

	self.ItemDEF = _G.DEF.Item
end

function init_logic()
	self.StatusBar.Menu = {
		icon = "CommonIcon/ico_main_057",
		name = "WNDGuildBuilder",
		Context = Context,
	}

	self.selectedIndex = 0
	self.spSelected = Ref.SubMain.spSelected
	libunity.SetActive(self.spSelected, false)
	
	libunity.SetActive(Ref.SubTips.SubNextLvTips.go, false)

	self.buildingId = tonumber(Context.ext)
	NW.GUILD.RequestBuildingInfo(self.buildingId)

	if self.buildingId == 1 then -- 避难所大楼
		
	elseif self.buildingId == 2 then -- 发电站
		
	elseif self.buildingId == 3 then -- 建造车床
		
	elseif self.buildingId == 4 then -- 自动贩卖机
		
	elseif self.buildingId == 5 then -- 蓝图机
		
	end
	
end

function show_view()
	
end

function on_recycle()
	libgame.UnitBreak(0)
	libunity.SetParent(self.spSelected, Ref.SubMain.go, true, -1)
	libunity.SetActive(self.spSelected, true)
end

Handlers = {
	["GUILD.SC.GUILD_BUILD_INFO"] = function(buildingInfo)
		if buildingInfo then
			if self.buildingId == buildingInfo.buildingId then
				self.buildingInfo = buildingInfo
				set_default_selected_index()
				rfsh_builder_view()
			end
		end
	end,
	["GUILD.SC.GUILD_DONATE"] = function(err)
		if err == nil then
			NW.GUILD.RequestBuildingInfo(self.buildingId)
		end
	end,
}

return self

