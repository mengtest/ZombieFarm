--
-- @file    ui/shop/lc_mbnormalshopselect.lua
-- @author  shenbingkang
-- @date    2018-09-12 17:45:01
-- @desc    MBNormalShopSelect
--

local self = ui.new()
local _ENV = self

local itemlib = config("itemlib")
local ItemDEF = _G.DEF.Item

local function rfsh_total_price_value(value)
	local btnConfirm = Ref.SubMain.btnConfirm
	libugui.SetText(GO(btnConfirm, "lbPrice"), string.format("%d", self.ShopItemInfo.curPrice * value))
end

--!* [开始] 自动生成函数 *--

function on_submain_subitem_spicon_click(evt, data)
	self.ShopItem:show_tip(evt)
end

function on_submain_subitem_spicon_deselect(evt, data)
	_G.DEF.Item.hide_tip()
end

function on_edit_count_changed(bar)
	local SubProc = Ref.SubMain.SubSelectedCnt.SubProc
	SubProc.lbSelectedCnt.text = string.format("%d", bar.value)
	rfsh_total_price_value(bar.value)
end

function on_submain_subselectedcnt_btnmuti_click(btn)
	local SubSelectedCnt = Ref.SubMain.SubSelectedCnt
	local curValue = SubSelectedCnt.SubProc.bar.value
	SubSelectedCnt.SubProc.bar.value = curValue - 1
end

function on_submain_subselectedcnt_btnadd_click(btn)
	local SubSelectedCnt = Ref.SubMain.SubSelectedCnt
	local curValue = SubSelectedCnt.SubProc.bar.value
	SubSelectedCnt.SubProc.bar.value = curValue + 1
end

function on_submain_subselectedcnt_btnmax_click(btn)
	local SubSelectedCnt = Ref.SubMain.SubSelectedCnt
	SubSelectedCnt.SubProc.bar.value = self.ShopItemInfo.nStack
end

function on_submain_btnconfirm_click(btn)
	local cnt = Ref.SubMain.SubSelectedCnt.SubProc.bar.value
	if cnt > 0 then
		NW.SHOP.RequestBuyGoods(Context.curShopID, self.ShopItemInfo.goodsID, cnt)
	end
end
--!* [结束] 自动生成函数  *--

function init_view()
	--!* [结束] 自动生成代码 *--
end

function init_logic()
	self.ShopItemInfo = Context.ShopItemInfo
	local nStack = self.ShopItemInfo.nStack

	local SubSelectedCnt = Ref.SubMain.SubSelectedCnt
	SubSelectedCnt.SubProc.bar.value = 1
	SubSelectedCnt.SubProc.bar.maxValue = nStack
	on_edit_count_changed(SubSelectedCnt.SubProc.bar)
	SubSelectedCnt.lbMax.text = nStack

	local SubMain = Ref.SubMain
	
	self.ShopItem = ItemDEF.new(self.ShopItemInfo.itemID)
	local itemData = self.ShopItem:get_base_data()
	self.ShopItem:show_icon(SubMain.SubItem.spIcon)
	self.ShopItem:show_rarityIcon(SubMain.SubItem.spRarity)
	SubMain.SubItem.lbName.text = itemData.name
	SubMain.SubItem.lbCount.text = nStack
	SubMain.lbItemDesc.text = itemData.desc

	local assetData = itemlib.get_dat(self.ShopItemInfo.assetType)
	libugui.SetSprite(GO(SubMain.btnConfirm, "spIcon"), assetData.icon)
	libugui.SetSprite(SubMain.SubItem.spMoneyIcon, assetData.icon)
	SubMain.SubItem.lbPrice.text = self.ShopItemInfo.curPrice
end

function show_view()
	
end

function on_recycle()
	
end

Handlers = {
	["SHOP.SC.BUY_GOODS"] = function(reward)
		if reward then
			self:close()
		end
	end,
}

return self

