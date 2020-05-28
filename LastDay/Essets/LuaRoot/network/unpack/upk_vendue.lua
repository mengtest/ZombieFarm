--
-- @file    network/unpack/upk_vendue.lua
-- @anthor  xingweizhen (weizhen.xing@funplus.com)
-- @date    2018-06-13 09:27:05
-- @desc    描述
--


local NW, P = _G.NW, {}

local GoodsDEF = DEF.Goods

local function read_sell_info(nm)
	return { price = nm:readU32(), amount = nm:readU32(), }
end

NW.regist("VENDUE.SC.VENDUE_LIST", function (nm)
	local ret, err = NW.chk_op_ret(nm:readU32())
	if err then return end

	local TradeGoods = DY_DATA.TradeGoods
	local remoteVer = nm:readU32()
	local category = nm:readU32()
	local GoodsList = TradeGoods[category]
	local localVer = GoodsList and GoodsList.ver

	if remoteVer ~= localVer then
		GoodsList = { ver = remoteVer, }
		nm:readArray(GoodsList, GoodsDEF.read)
		TradeGoods[category] = GoodsList
	end

	return { dirty = remoteVer ~= localVer, category = category, GoodsList = GoodsList, }
end)

NW.regist("VENDUE.SC.VENDUE_OWNER", function (nm)
	local ret, err = NW.chk_op_ret(nm:readU32())
	if err == nil then
		DY_DATA.GoodsOrders = nm:readArray({}, GoodsDEF.order)
		return DY_DATA.GoodsOrders
	end
end)

NW.regist("VENDUE.SC.VENDUE_SELL", function (nm)
	local ret, err = NW.chk_op_ret(nm:readU32())
	if err == nil then
		return GoodsDEF.order(nm)
	end
end)

NW.regist("VENDUE.SC.VENDUE_OPE", function (nm)
	local ret, err = NW.chk_op_ret(nm:readU32())
	if err == nil then
		local order, op = nm:readU32(), nm:readU32()
		return { order = order, op = op, }
	end
end)

NW.regist("VENDUE.SC.ITEM_SELL_INFO", function (nm)
	local goods = nm:readU32()
	local Prices = nm:readArray({}, read_sell_info)
	return {
		goods = goods, Prices = Prices
	}
end)

NW.regist("VENDUE.SC.VENDUE_BUY", NW.common_op_ret)

function P.pull(category)
	local GoodsList = DY_DATA.TradeGoods[category]
	local localVer = GoodsList and GoodsList.ver
	NW.send(NW.msg("VENDUE.CS.VENDUE_LIST"):writeU32(localVer or 0):writeU32(category))
end

function P.pull_own()
	NW.send(NW.msg("VENDUE.CS.VENDUE_OWNER"))
end

function P.get_price(Goods)
	NW.send(NW.msg("VENDUE.CS.ITEM_SELL_INFO"):writeU32(Goods.dat))
end

function P.buy(goods, amount, price)
	NW.send(NW.msg("VENDUE.CS.VENDUE_BUY"):writeU32(goods):writeU32(amount):writeU32(price))
end

function P.sell(Item, unitPrice)
	local nm = NW.msg("VENDUE.CS.VENDUE_SELL")
	nm:writeU32(Item.pos - 1):writeU32(unitPrice):writeU32(Item.amount)
	NW.send(nm)
end

NW.VENDUE = P
