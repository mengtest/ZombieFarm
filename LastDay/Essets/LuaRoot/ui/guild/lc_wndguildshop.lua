--
-- @file    ui/guild/lc_wndguildshop.lua
-- @author  shenbingkang
-- @date    2018-06-15 15:07:23
-- @desc    WNDGuildShop
--

local self = ui.new()
local _ENV = self

local curShopID
local contributionValue
local maxCellNum = -1
local ShopCfg = config("shoplib")

local shopInfo
local goodsList = {}

local function rfsh_shop_info()
	local SubRefresh = Ref.SubMain.SubNPCInfo.SubRefresh
	shopInfo = DY_DATA.ShopInfo[curShopID]
	if shopInfo.manualRefreshAssetType then
		libunity.SetActive(SubRefresh.go, true)
		SubRefresh.lbAmount.text = shopInfo.manualRefreshPrice
		SubRefresh.lbResidues.text = string.format(TEXT.fmtResiduesCnt, 
			(shopInfo.nRefreshLimitCnt - shopInfo.nRefreshCnt), shopInfo.nRefreshLimitCnt)
	else
		libunity.SetActive(SubRefresh.go, false)
	end
end
local function rfsh_goods_list_view()
	goodsList = DY_DATA.ShopGoodsInfo[curShopID]
	libugui.SetLoopCap(Ref.SubMain.SubGoodsView.SubScroll.GrpContent.go, #goodsList, true)
end

local function rfsh_player_assets()
	local SubAsset = Ref.SubMain.SubAsset
	local amount = DY_DATA:nget_asset(self.AssetType)
	SubAsset.lbAmount.text = amount
end

local function rfsh_guild_exhibit_shop(buildingLevel)
	local guildShopData = ShopCfg.get_guild_shop_data(buildingLevel)
	local exhibitShopList = {}
	if guildShopData then
		exhibitShopList = guildShopData.exhibitShop
		maxCellNum = maxCellNum
	end
	local GrpShowGoods = Ref.SubMain.SubNPCInfo.GrpShowGoods
	GrpShowGoods:dup(#exhibitShopList, function (idx, Ent, isNewIcon)
		UTIL.flex_itement(Ent, "SubItem", 0)
		libugui.SetVisible(Ent.SubItem.lbAmount, false)

		local itemID = exhibitShopList[idx]
		local Item = _G.DEF.Item.new(itemID, 1)
		show_item_view(Item, Ent.SubItem)
	end)
end

local function rfsh_npc_info()
	local Obj = CTRL.get_obj(Context.obj)
	local npcBaseInfo = Obj:get_base_data()
	local SubNPCInfo = Ref.SubMain.SubNPCInfo
	SubNPCInfo.lbNpcName.text = npcBaseInfo.name
	SubNPCInfo.lbNpcInfo.text = npcBaseInfo.desc
	--todo:npc头像
end

--!* [开始] 自动生成函数 *--

function on_submain_subnpcinfo_subrefresh_btnrefresh_click(btn)
	NW.SHOP.RequestRefreshShop(curShopID)
end

function on_grpgoodslist_ent(go, i)
	local GrpContent = Ref.SubMain.SubGoodsView.SubScroll.GrpContent

	local n = i + 1
	GrpContent:setindex(go, n)

	local goodsInfo = goodsList[n]
	local Ent = ui.ref(go)

	UTIL.flex_itement(Ent, "SubItem", 0)
	local Item = _G.DEF.Item.new(goodsInfo.itemID, goodsInfo.nStack)
	local baseItemInfo = Item:get_base_data()
	show_item_view(Item, Ent.SubItem)

	Ent.lbItemName.text = baseItemInfo.name

	if goodsInfo.nPayLimitCnt == 0 or goodsInfo.nPayLimitCnt > goodsInfo.nPayCnt then
		libunity.SetActive(Ent.SubSold.go, false)
		libunity.SetActive(Ent.SubBuy.go, true)
		Ent.SubBuy.SubBuy.lbAmount.text = goodsInfo.curPrice
	else
		libunity.SetActive(Ent.SubSold.go, true)
		libunity.SetActive(Ent.SubBuy.go, false)
	end

end

function on_submain_subgoodsview_subscroll_grpcontent_entgoodsunit_subbuy_subbuy_click(btn)
	local GrpContent = Ref.SubMain.SubGoodsView.SubScroll.GrpContent
	local index = GrpContent:getindex(btn.transform.parent.parent)
	local goodsInfo = goodsList[index]
	NW.SHOP.RequestBuyGoods(curShopID, goodsInfo.goodsID)
end
--!* [结束] 自动生成函数  *--

function init_view()
	ui.group(Ref.SubMain.SubNPCInfo.GrpShowGoods)
	ui.group(Ref.SubMain.SubGoodsView.SubScroll.GrpContent)
	--!* [结束] 自动生成代码 *--
	self.UTIL = _G.PKG["ui/util"]
	self.show_item_view = UTIL.show_item_view
end

function init_logic()
	curShopID = tonumber(Context.ext) -- CVar.SHOP_TYPE["GUILD_SHOP"]

	self.AssetType = ShopCfg.assetCostType
	Ref.lbShopTitle.text = ShopCfg.get_shop_dat(curShopID).name
	maxCellNum = -1

	--! 此处特殊处理不同种类的商店
	if curShopID == CVar.SHOP_TYPE["GUILD_SHOP"] then
		NW.GUILD.RequestGetBuildingInfo()
	end

	rfsh_player_assets()
	NW.SHOP.RequestGetShopInfo(curShopID)

	rfsh_npc_info()
end

function show_view()
	
end

function on_recycle()
	
end

Handlers = {
	["GUILD.SC.GET_BUILDING_INFO"] = function (buildingInfoList)
		if curShopID ~= CVar.SHOP_TYPE["GUILD_SHOP"] then
			return
		end
		if buildingInfoList then
			for _,v in pairs(buildingInfoList) do
				if v.buildingID == 3 then
					rfsh_guild_exhibit_shop(v.buildingLevel)
					return
				end
			end
		end
	end,
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
	["PLAYER.SC.ROLE_ASSET_GET"] = rfsh_player_assets,
}

return self

