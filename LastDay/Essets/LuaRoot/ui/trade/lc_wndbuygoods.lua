--
-- @file    ui/trade/lc_wndbuygoods.lua
-- @author  xingweizhen
-- @date    2018-06-13 17:27:19
-- @desc    WNDBuyGoods
--

local self = ui.new()
local _ENV = self

local function rfsh_buy_prices()
	local SubAmount = Ref.SubMain.SubAmount
	SubAmount.lbAmount.text = self.buyAmount

	local totalAmount = self.buyAmount
	self.totalPrice = 0
	for i,v in ipairs(Context.Prices) do
		if totalAmount < v.amount then
			totalPrice = totalPrice + totalAmount * v.price
		break end
		totalAmount = totalAmount - v.amount
		totalPrice = totalPrice + v.amount * v.price
	end
	SubAmount.lbPrice.text = totalPrice
end

--!* [开始] 自动生成函数 *--

function on_submain_subamount_btndec_click(btn)
	if self.buyAmount > 0 then
		buyAmount = buyAmount - 1
		rfsh_buy_prices()
	end
end

function on_submain_subamount_btnadd_click(btn)
	if self.buyAmount < 999 then
		buyAmount = buyAmount + 1
		rfsh_buy_prices()
	end
end

function on_submain_btnbuy_click(btn)
	NW.VENDUE.buy(Context.goods, buyAmount, totalPrice)
end
--!* [结束] 自动生成函数  *--

function init_view()
	ui.group(Ref.SubMain.GrpPrices)
	--!* [结束] 自动生成代码 *--

	_G.PKG["ui/util"].flex_itement(Ref.SubMain, "SubItem")
	Ref.SubMain.lbTips.text = nil
end

function init_logic()
	local SubMain = Ref.SubMain

	local Goods = _G.DEF.Goods.new(Context.goods)
	Goods:show_view(SubMain.SubItem)

	local Prices = Context.Prices
	SubMain.GrpPrices:dup(#Prices, function (i, Ent, isNew)
		local Price = Prices[i]
		Ent.lbIdx.text = i
		Ent.lbPrice.text = Price.price
		Ent.lbAmount.text = Price.amount
	end)
	SubMain.lbRemain.text = nil
	self.buyAmount = 1
	self.unitPrice = Prices[1].price

	rfsh_buy_prices()
end

function show_view()

end

function on_recycle()

end

Handlers = {
	["VENDUE.SC.VENDUE_BUY"] = function (Ret)
		if Ret.err == nil then self:close() end
	end
}

return self

