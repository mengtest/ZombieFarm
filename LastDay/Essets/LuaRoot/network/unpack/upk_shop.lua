--
-- @file    network/unpack/upk_shop.lua
-- @author  shenbingkang
-- @date    2018-06-15 10:30:00
-- @desc    描述
--

local NW, P = _G.NW, {}

local function read_GoodsInfo(nm)
	local goodsInfo = {}
	goodsInfo.goodsID = nm:readU32()
	goodsInfo.itemID = nm:readU32()
	goodsInfo.nStack = nm:readU32()
	goodsInfo.nPayCnt = nm:readU32() --(废弃)
	goodsInfo.nPayLimitCnt = nm:readU32() --0无限制(废弃)
	goodsInfo.assetType = nm:readU32() -- 资产类型
	goodsInfo.curPrice = nm:readU32()
	goodsInfo.orgPrice = nm:readU32()
	goodsInfo.payLimitType = nm:readU32() --购买权限类型
	goodsInfo.payLimitParams = nm:readU32() --购买权限参数
	goodsInfo.validityTime = nm:readU64()
	goodsInfo.sortIndex = nm:readU32() --升序（从小到大）排列
	goodsInfo.strExtra = nm:readString()
	return goodsInfo
end

local function read_ShopInfo(nm)
	local shopInfo = {}
	shopInfo.shopID = nm:readU32()
	shopInfo.shopType = nm:readU32()
	shopInfo.bIsInBusiness = (nm:readU32() == 1) --0：关闭 1：开启
	shopInfo.nRefreshCnt = nm:readU32()
	shopInfo.nRefreshLimitCnt = nm:readU32()
	shopInfo.nFreeRefreshLimitCnt = nm:readU32()
	shopInfo.manualRefreshAssetType = nm:readU32() --0：不可手动刷新 1：可手动刷新
	shopInfo.manualRefreshPrice = nm:readU32()
	shopInfo.validityTime = math.floor(nm:readU64() / 1000)
	shopInfo.strRefreshTime = nm:readString()
	return shopInfo
end

local function sort_goodslist(a, b)
	return a.sortIndex < b.sortIndex
end

--========================================SC协议========================================

NW.regist("SHOP.SC.GET", function (nm)
	local cnt = nm:readU32()
	local shopIdArr = {}
	for i=1,cnt do
		local shopInfo = read_ShopInfo(nm)
		local goodsInfoList = nm:readArray({}, read_GoodsInfo)
		table.sort(goodsInfoList, sort_goodslist)

		DY_DATA.ShopInfo[shopInfo.shopID] = shopInfo
		DY_DATA.ShopGoodsInfo[shopInfo.shopID] = goodsInfoList

		table.insert(shopIdArr, shopInfo.shopID)
	end

	return shopIdArr
end)

NW.regist("SHOP.SC.SHOP_CHANGE", function (nm)
	local shopInfo = read_ShopInfo(nm)
	DY_DATA.ShopInfo[shopInfo.shopID] = shopInfo
	return shopInfo.shopID
end)

NW.regist("SHOP.SC.GOODS_CHANGE", function (nm)
	local shopID = nm:readU32()
	local goodsInfoList = nm:readArray({}, read_GoodsInfo)
	table.sort(goodsInfoList, sort_goodslist)

	DY_DATA.ShopGoodsInfo[shopID] = goodsInfoList
	return shopID
end)

NW.regist("SHOP.SC.REFLASH", function (nm)
	local ret, err = NW.chk_op_ret(nm:readU32())
	return err
end)

NW.regist("SHOP.SC.BUY_GOODS", function (nm)
	local shopID = nm:readU32()
	local goodsID = nm:readU32()
	local ret, err = NW.chk_op_ret(nm:readU32())
	if err == nil then
		local reward = {}
		reward.magnif = nm:readU32() --暴击倍数 >1 产生了暴击
		reward.goodsList = nm:readArray({}, NW.read_item) --获得物品 key=物品Id value=数量
		return reward
	end
	return nil
end)

--========================================CS协议========================================

function P.RequestGetShopInfo(shopType)
	local shopID = tonumber(shopType)
	if shopID == nil then
		shopID = CVar.SHOP_TYPE[shopType]
	end

	local nm = NW.msg("SHOP.CS.GET")
	nm:writeU32(shopID)
	NW.send(nm)
end

function P.RequestRefreshShop(shopType)
	local shopID = tonumber(shopType)
	if shopID == nil then
		shopID = CVar.SHOP_TYPE[shopType]
	end

	local nm = NW.msg("SHOP.CS.REFLASH")
	nm:writeU32(shopID)
	NW.send(nm)
end

function P.RequestBuyGoods(shopType, goodsID, cnt)
	local shopID = tonumber(shopType)
	if shopID == nil then
		shopID = CVar.SHOP_TYPE[shopType]
	end

	if cnt == nil or cnt < 1 then
		cnt = 1
	end

	local nm = NW.msg("SHOP.CS.BUY_GOODS")
	nm:writeU32(shopID)
	nm:writeU32(goodsID)
	nm:writeU32(cnt)
	NW.send(nm)
end

NW.SHOP = P
