--
-- @file    ui/shop/lc_wndnormalshop.lua
-- @author  shenbingkang
-- @date    2018-06-26 18:43:57
-- @desc    WNDNormalShop
--

local self = ui.new()
local _ENV = self

self.StatusBar = {
	AssetBar = true,
	HealthyBar = true,
}

local curShopID
local ShopCfg = config("shoplib")
local itemlib = config("itemlib")

local shopInfo
local goodsList = {}

-- 检查商品是否受限
local function check_islimit(payLimitType, payLimitParams)
	if payLimitType == 1 then
		-- 玩家等级
		local Player = DY_DATA:get_player()
		local playerLevel = Player.level
		if payLimitParams > playerLevel then
			local limitReason = TEXT.ShopLimit_UserLevel:csfmt(payLimitParams)
			return true, limitReason
		end

	elseif payLimitType == 2 then
		-- vip等级
		return false

	elseif payLimitType ==3 then
		-- 公会商店等级
		if self.GuildShopBuildLv == nil then
			return false
		end
		if payLimitParams > self.GuildShopBuildLv then
			local limitReason = TEXT.ShopLimit_GuildShopLevel:csfmt(payLimitParams)
			return true, limitReason
		end
	end

	return false
end

local function on_refresh_shop_fin(tm)
	return true
end

local function on_refresh_shop_timer(tm)
	local SubRefresh = Ref.SubMain.SubRefresh
	if tm.count == 0 then
		libunity.SetActive(SubRefresh.spRefresh, false)
		libunity.SetActive(GO(SubRefresh.btnRefresh, "SubCost"), false)
		libunity.SetActive(GO(SubRefresh.btnRefresh, "lbFree"), true)
		return
	end
	libunity.SetActive(SubRefresh.spRefresh, true)
	SubRefresh.lbRefreshTime.text = tm:to_time_string()
end

local function rfsh_shop_info()
	local SubRefresh = Ref.SubMain.SubRefresh
	shopInfo = DY_DATA.ShopInfo[curShopID]
	if shopInfo.manualRefreshAssetType ~= 0 then
		libunity.SetActive(SubRefresh.go, true)
	
		local leftTime = shopInfo.validityTime - os.date2secs()

		if shopInfo.nRefreshCnt >= shopInfo.nRefreshLimitCnt then
			DY_TIMER.stop_timer("ShopRefreshTimer")
			libunity.SetActive(GO(SubRefresh.btnRefresh, "SubCost"), false)
			libunity.SetActive(GO(SubRefresh.btnRefresh, "lbFree"), false)
			libunity.SetActive(GO(SubRefresh.btnRefresh, "lbRefreshLimit"), true)
			libunity.SetActive(SubRefresh.spRefresh, false)
			libugui.SetInteractable(SubRefresh.btnRefresh, false)
		else

			if leftTime < 0 then leftTime = 0 end
			local tm = DY_TIMER.replace_timer("ShopRefreshTimer",
				leftTime, leftTime, on_refresh_shop_fin)
			tm:subscribe_counting(Ref.go, on_refresh_shop_timer)
			on_refresh_shop_timer(tm)

			local itemData = itemlib.get_dat(shopInfo.manualRefreshAssetType)

			libugui.SetInteractable(SubRefresh.btnRefresh, true)
			libunity.SetActive(GO(SubRefresh.btnRefresh, "SubCost"), leftTime > 0)
			libunity.SetActive(GO(SubRefresh.btnRefresh, "lbFree"), leftTime <= 0)
			libunity.SetActive(GO(SubRefresh.btnRefresh, "lbRefreshLimit"), false)
			libugui.SetSprite(GO(SubRefresh.btnRefresh, "SubCost/spIcon"), itemData.icon)
			libugui.SetText(GO(SubRefresh.btnRefresh, "SubCost/lbCost"), shopInfo.manualRefreshPrice)
		end
	
	else
		DY_TIMER.stop_timer("ShopRefreshTimer")
		libunity.SetActive(SubRefresh.go, false)
	end
end

local function rfsh_goods_list_view()
	goodsList = DY_DATA.ShopGoodsInfo[curShopID]
	libugui.SetLoopCap(Ref.SubMain.SubGoodsView.SubScroll.GrpContent.go, #goodsList, true)
end

local function rfsh_player_assets()
	local SubAsset = Ref.SubMain.SubAsset

	if self.AssetType == CVar.ASSET_TYPE["Gold"] then
		libunity.SetActive(SubAsset.go, false)
	else
		libunity.SetActive(SubAsset.go, true)

		local amount = 0
		if self.AssetType < 100 then
			amount = DY_DATA:nget_asset(self.AssetType)
		else
			amount = DY_DATA:nget_item(self.AssetType)
		end
		SubAsset.lbMoney.text = amount

		local AssetData = itemlib.get_dat(self.AssetType)
		SubAsset.lbAssetInfo.text = TEXT.fmtShopAsset:csfmt(AssetData.name)
		ui.seticon(SubAsset.spAssetIcon, AssetData.icon)
	end
end

--!* [开始] 自动生成函数 *--

function on_grpgoodslist_ent(go, i)
	local GrpContent = Ref.SubMain.SubGoodsView.SubScroll.GrpContent

	local n = i + 1
	GrpContent:setindex(go, n)

	local goodsInfo = goodsList[n]
	local Ent = ui.ref(go)

	-- local itemData = itemlib.get_dat(goodsInfo.itemID)
	-- ui.seticon(Ent.spIcon, itemData.icon)
	--Ent.lbName.text = itemData.name
	UTIL.flex_itement(Ent, "SubItem", 0)
	local Item = _G.DEF.Item.new(goodsInfo.itemID, goodsInfo.nStack)
	show_item_view(Item, Ent.SubItem)
	libugui.SetVisible(Ent.SubItem.lbAmount, false)

	local costData = itemlib.get_dat(goodsInfo.assetType)
	ui.seticon(Ent.spCostIcon, costData.icon)
	Ent.lbPrice.text = goodsInfo.curPrice

	local canBuy = true
	local isLimitLock, limitLockReason = check_islimit(goodsInfo.payLimitType, goodsInfo.payLimitParams)

	if isLimitLock then
		--不能购买，有限制条件
		libunity.SetActive(Ent.spLockBack, true)
		libunity.SetActive(Ent.SubBuy.SubPrice.go, false)
		libunity.SetActive(Ent.SubBuy.spLock, true)
		Ent.SubBuy.lbLock.text = string.format("<color=red>%s</color>", limitLockReason)

		canBuy = false
	else
		local lastCnt = goodsInfo.nStack
		Ent.lbCount.text = lastCnt
		if lastCnt == 0 then
			-- 不能购买，已售罄
			libunity.SetActive(Ent.spLockBack, true)
			libunity.SetActive(Ent.SubBuy.SubPrice.go, false)
			libunity.SetActive(Ent.SubBuy.spLock, false)
			Ent.SubBuy.lbLock.text = TEXT.SoldOut
			
			canBuy = false
		else
			-- 可以购买
			libunity.SetActive(Ent.spLockBack, false)
			libunity.SetActive(Ent.SubBuy.SubPrice.go, true)
			libunity.SetActive(Ent.SubBuy.spLock, false)
			Ent.SubBuy.lbLock.text = nil
		end
	end

	libugui.SetInteractable(Ent.SubBuy.btn, canBuy)
end

function on_submain_subgoodsview_subscroll_grpcontent_entgoodsunit_subitem_click(evt, data)
	local index = ui.index(evt)
	local goodsInfo = goodsList[index]
	local Item = _G.DEF.Item.new(goodsInfo.itemID, goodsInfo.nStack)
	Item:show_tip(evt)
end

function on_submain_subgoodsview_subscroll_grpcontent_entgoodsunit_subitem_deselect(evt, data)
	ItemDEF.hide_tip()
end

function on_submain_subgoodsview_subscroll_grpcontent_entgoodsunit_subbuy_click(btn)
	local GrpContent = Ref.SubMain.SubGoodsView.SubScroll.GrpContent
	local index = GrpContent:getindex(btn.transform.parent)
	local goodsInfo = goodsList[index]
	if goodsInfo then
		ui.show("UI/MBNormalShopSelect", 0, {
			curShopID = curShopID,
			ShopItemInfo = goodsInfo, 
		})
	end
end

function on_submain_subrefresh_btnrefresh_click(btn)
	NW.SHOP.RequestRefreshShop(curShopID)
end

function on_submain_subasset_spasseticon_click(evt, data)
	local Item = _G.DEF.Item.new(self.AssetType, 1)
	Item:show_tip(evt)
end

function on_submain_subasset_spasseticon_deselect(evt, data)
	ItemDEF.hide_tip()
end
--!* [结束] 自动生成函数  *--

function init_view()
	ui.group(Ref.SubMain.SubGoodsView.SubScroll.GrpContent)
	--!* [结束] 自动生成代码 *--
	self.UTIL = _G.PKG["ui/util"]
	self.show_item_view = UTIL.show_item_view
	self.ItemDEF = _G.DEF.Item
end

function init_logic()
	local obj = Context.obj
	local Obj = CTRL.get_obj(Context.obj)
	Ref.lbShopTitle.text = Obj:get_name()

	self.StatusBar.Menu = {
		icon = "CommonIcon/ico_main_057",
		name = "WNDNormalShop",
		title = Obj:get_name(),
		Context = Context,
	}

	curShopID = tonumber(Context.ext) -- CVar.SHOP_TYPE["GUILD_SHOP"]

	Ref.SubMain.SubGoodsView.SubScroll.GrpContent:hide()

	local shopBaseData = ShopCfg.get_shop_dat(curShopID)
	self.AssetType = tonumber(shopBaseData.assetCostType)

	rfsh_player_assets()
	NW.SHOP.RequestGetShopInfo(curShopID)

	if curShopID == CVar.SHOP_TYPE["GUILD_SHOP"] then
		NW.GUILD.RequestBuildingInfo(4)
	end
end

function show_view()
	
end

function on_recycle()
	libgame.UnitBreak(0)
end

Handlers = {
	["SHOP.SC.GET"] = function (shopArr)
		if table.ifind(shopArr, curShopID) then
			rfsh_shop_info()
			rfsh_goods_list_view()
		end
	end,
	["SHOP.SC.SHOP_CHANGE"] = function (shopID)
		if shopID == curShopID then
			rfsh_shop_info()
		end
	end,
	["SHOP.SC.GOODS_CHANGE"] = function (shopID)
		if shopID == curShopID then
			rfsh_goods_list_view()
		end
	end,
	["PACKAGE.SC.SYNC_ITEM"] = rfsh_player_assets,
	["PLAYER.SC.ROLE_ASSET_GET"] = rfsh_player_assets,
	["GUILD.SC.GUILD_BUILD_INFO"] = function (buildingInfo)
		if buildingInfo then
			if buildingInfo.buildingId == 4 then
				self.GuildShopBuildLv = buildingInfo.buildingLv
				rfsh_goods_list_view()
			end
		end
	end,
}

return self

