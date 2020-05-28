--
-- @file    ui/trade/lc_wndtradehouse.lua
-- @author  xingweizhen
-- @date    2018-06-13 01:28:32
-- @desc    WNDTradeHouse
--

local self = ui.new()
local _ENV = self

self.StatusBar = {
	AssetBar = true,
}

local function gen_goods_list(AllGoodsList, subCategory)
	local GoodsList = {}
	self.CategoryGoodsList[subCategory] = GoodsList
	for i,v in ipairs(AllGoodsList) do
		local GoodsBase = v:get_base_data()
		if GoodsBase.subCategory == subCategory then
			table.insert(GoodsList, v)
		end
	end
	return GoodsList
end

local function rfsh_goods_list(GoodsList)
	self.GoodsList = GoodsList
	libugui.SetLoopCap(Ref.SubGoods.SubScroll.SubView.GrpGoods.go, #GoodsList, true)
end

local function rfsh_self_items()
	libugui.SetLoopCap(Ref.SubOnShelf.SubScroll.SubView.GrpItems.go, DY_DATA.bagCap, true)
end

local function rfsh_sell_prices()
	local SubShelf = Ref.SubOnShelf.SubShelf
	if SellItem then
		SubShelf.SubUnitPrice.SubPrice.lbPrice.text = self.unitPrice
		local totalPrice = self.unitPrice * SellItem.amount
		SubShelf.SubTotalPrice.lbPrice.text = totalPrice
		SubShelf.SubFee.lbPrice.text = math.floor(totalPrice * CVar.AH.SalesTaxRate / 1000)
	else
		SubShelf.SubUnitPrice.SubPrice.lbPrice.text = nil
		SubShelf.SubTotalPrice.lbPrice.text = nil
		SubShelf.SubFee.lbPrice.text = nil
	end
end

--!* [开始] 自动生成函数 *--

function on_subfilter_grpmtypes_entmtype_click(tgl)
	if tgl.value then
		local ItemLIB = config("itemlib")
		categoryIdx = ui.index(tgl)
		local Category = Categories[categoryIdx]
		local SubCategories = SubCategoriesMap[Category.id]
		local GrpSTypes = Ref.SubFilter.GrpSTypes
		libugui.AllTogglesOff(GrpSTypes.go)

		GrpSTypes:dup(#SubCategories, function (i, Ent, isNew)
			local SubCategory = SubCategories[i]
			Ent.lbSType.text = SubCategory.name
			Ent.tgl.value = self.subCategoryId == SubCategory.id
		end)
		libunity.SetParent(GrpSTypes.go, Ref.SubFilter.GrpMTypes.go, false, categoryIdx + 1)

		NW.VENDUE.pull(Category.id)
	end
end

function on_subfilter_grpstypes_entstype_click(tgl)
	if tgl.value then
		local index = ui.index(tgl)
		local Category = Categories[categoryIdx]
		local subCategoryId = SubCategoriesMap[Category.id][index].id

		if self.subCategoryId ~= subCategoryId then
			self.subCategoryId = subCategoryId
			local GoodsList = gen_goods_list(DY_DATA.TradeGoods[Category.id], subCategoryId)
			rfsh_goods_list(GoodsList)

			self.selectedGoods = nil
			libugui.SetVisible(self.spGoodsSel, false)
		end
	end
end

function on_subgoods_subfields_subname_click(btn)

end

function on_subgoods_subfields_subscore_click(btn)

end

function on_subgoods_subfields_subprice_click(btn)

end

function on_subgoods_subfields_subamount_click(btn)

end

function on_grpgoods_ent(go, i)
	local index = i + 1
	ui.index(go, index)

	local Ent = ui.ref(go)
	local Goods = GoodsList[index]
	Goods:show_view(Ent)

	local GoodsBase = Goods:get_base_data()
	Ent.lbName.text = GoodsBase.name
	Ent.lbScore.text = GoodsBase.score
	Ent.lbPrice.text = Goods.price
	Ent.lbAmount.text = nil
	Ent.lbTAmount.text = Goods.amount

	if selectedGoods == index then
		libunity.SetParent(self.spGoodsSel, go, false, 0)
		libugui.SetVisible(self.spGoodsSel, true)
	else
		libugui.SetVisible(Ent.spGoodsSel, false)
	end
end

function on_subgoods_subscroll_subview_grpgoods_entgoods_click(btn)
	local index = ui.index(btn)
	if self.selectedGoods ~= index then
		self.selectedGoods = index
		libunity.SetParent(self.spGoodsSel, btn, false, 0)
		libugui.SetVisible(self.spGoodsSel, true)
	end
end

function on_subgoods_subsearch_btnbuy_click(btn)
	NW.VENDUE.get_price(GoodsList[selectedGoods])
end

function on_subgoods_subsearch_btnsearch_click(btn)

end

function on_input_content_changed(inp, text)

end

function on_item_drop(evt, data)
	libugui.SetVisible(Ref.SubDrag.go, false)

	if SellItem then
		local Ent = Ref.SubOnShelf.SubScroll.SubView.GrpItems:find(SellItem.pos)
		if Ent then show_item_view(SellItem, Ent) end
	end
	self.SellItem = DY_DATA:iget_item(dragIdx)

	local SubShelf = Ref.SubOnShelf.SubShelf
	SellItem:show_view(SubShelf.SubItem, nil, true)

	self.unitPrice = 1
	rfsh_sell_prices()
end

function on_subonshelf_subshelf_btnonshelf_click(btn)
	NW.VENDUE.sell(SellItem, unitPrice)
end

function on_subonshelf_subshelf_subunitprice_subprice_btndec_click(btn)
	if SellItem and unitPrice > 0 then
		unitPrice = unitPrice - 1
		rfsh_sell_prices()
	end
end

function on_subonshelf_subshelf_subunitprice_subprice_btnadd_click(btn)
	if SellItem and unitPrice < 999 then
		unitPrice = unitPrice + 1
		rfsh_sell_prices()
	end
end

function on_grpitems_ent(go, i)
	local index = i + 1
	ui.index(go, index)

	local Ent = ui.ref(go)
	local Item = DY_DATA:iget_item(index)
	show_item_view(Item, Ent)

	if selectedIdx == index then
		libunity.SetParent(self.spSelected, go, false)
		libugui.SetVisible(self.spSelected, true)
	else
		libugui.SetVisible(Ent.spSelected, false)
	end
end

function on_item_selected(evt, data)
	self.selectedIdx = ui.index(evt)
	self:focus_slot(evt)
end

function on_begindrag_item(evt, data)
	self:begin_drag(evt, data)
end

function on_drag_item(evt, data)
	self:doing_drag(evt, data)
end

function on_enddrag_item(evt, data)
	self:end_drag(evt, data)
end

function on_item_pressed(evt, data)
	if data then
		local Item = self:try_select_item(evt)
		if Item then
			Item:show_tip(evt)
			self:focus_slot(evt)
		end
	else
		_G.DEF.Item.hide_tip()
	end
end

function on_item_dualclick(evt, data)
	show_item_view(nil, ui.ref(evt))
	self.dragIdx = ui.index(evt)
	on_item_drop()
end

function on_grptabs_enttab_click(tgl)
	if tgl.value then
		local index = ui.index(tgl)
		libunity.SetActive(Ref.SubFilter.go, index == 1)
		libunity.SetActive(Ref.SubSelling.go, index == 3)
		libunity.SetActive(Ref.SubGoods.go, index == 1 or index == 3)
		libunity.SetActive(Ref.SubOnShelf.go, index == 2)

		if index == 3 then
			if rawget(DY_DATA, "GoodsOrders") then
				rfsh_goods_list(DY_DATA.GoodsOrders)
			else
				NW.VENDUE.pull_own()
			end
		end
	end
end
--!* [结束] 自动生成函数  *--

function init_view()
	ui.group(Ref.SubFilter.GrpMTypes)
	ui.group(Ref.SubFilter.GrpSTypes)
	ui.group(Ref.SubGoods.SubScroll.SubView.GrpGoods)
	ui.group(Ref.SubOnShelf.SubScroll.SubView.GrpItems)
	ui.group(Ref.GrpTabs)
	--!* [结束] 自动生成代码 *--

	local UTIL = _G.PKG["ui/util"]
	local flex_itemgrp = UTIL.flex_itemgrp
	flex_itemgrp(Ref.SubGoods.SubScroll.SubView.GrpGoods, 0, 2, 0, 80, -4, 20)
	flex_itemgrp(Ref.SubOnShelf.SubScroll.SubView.GrpItems)
	local SubItem = UTIL.flex_itement(Ref.SubOnShelf.SubShelf, "SubItem", 0)
	libugui.SetVisible(SubItem.lbAmount, false)
	SubItem.lbAmount = SubItem.lbNAmount

	local Inv = _G.PKG["ui/item/inventory"]
	setmetatable(Inv, getmetatable(self))
	setmetatable(self, Inv)

	self.show_item_view = _G.PKG["ui/util"].show_item_view

	-- 页签
	local TabNames = {
		TEXT.purchase, TEXT.selling, string.format(TEXT.fmtMySales, 0, 10)
	}
	Ref.GrpTabs:dup(#TabNames, function (i, Ent, isNew)
		local tabName = TabNames[i]
		Ent.lbTab.text = tabName
		Ent.lbChkTab.text = tabName
	end)

	local ItemLIB = config("itemlib")
	self.Categories = ItemLIB.Categories
	self.SubCategoriesMap = ItemLIB.SubCategoriesMap
	Ref.SubFilter.GrpMTypes:dup(#Categories, function (i, Ent, isNew)
		Ent.lbMType.text = Categories[i].name
	end)

	self.spGoodsSel = Ref.SubGoods.SubScroll.spSelected
	self.spSelected = Ref.SubOnShelf.SubScroll.spSelected
	self.GrpPockets = Ref.SubOnShelf.SubScroll.SubView.GrpItems
	self.GrpBackpack = self.GrpPockets

	self.CategoryGoodsList = {}

	-- 初始化
	SubItem.lbAmount.text = nil
	rfsh_sell_prices()
	Ref.SubGoods.SubScroll.lbTips.text = nil

end

function init_logic()
	Ref.SubDrag = ui.ref(ui.create("UI/SubItemDrag"))
	libugui.SetVisible(Ref.SubDrag.go, false)
	libugui.SetVisible(self.spGoodsSel, false)
	libugui.SetVisible(self.spSelected, false)

	Ref.SubFilter.GrpSTypes:hide()

	-- 初始化道具列表
	rfsh_self_items()

	Ref.GrpTabs:get(1).tgl.value = true
end

function show_view()

end

function on_recycle()
	ui.close(Ref.SubDrag.go, true)
	libugui.AllTogglesOff(Ref.GrpTabs.go)
	libugui.AllTogglesOff(Ref.SubFilter.GrpMTypes.go)
	libugui.AllTogglesOff(Ref.SubFilter.GrpSTypes.go)

	libunity.SetParent(Ref.SubFilter.GrpSTypes.go, Ref.SubFilter.go, false)
	libunity.SetParent(self.spSelected, Ref.SubOnShelf.SubScroll.go)
	libunity.SetParent(self.spGoodsSel, Ref.SubGoods.SubScroll.go)
end

Handlers = {
	["VENDUE.SC.VENDUE_LIST"] = function (Ret)
		if Ret.dirty then
			if subCategoryId then
				local Category = Categories[categoryIdx]
				local SubCategories = SubCategoriesMap[Category.id]
				for _,v in ipairs(SubCategories) do
					if v.id == subCategoryId then
						local GoodsList = gen_goods_list(Ret.GoodsList, v.id)
						rfsh_goods_list(GoodsList)
					return end
				end
			end
		end
	end,

	["VENDUE.SC.VENDUE_SELL"] = function (Goods)
		if Goods then
			self.SellItem = nil
			rfsh_sell_prices()
			show_item_view(nil, Ref.SubOnShelf.SubShelf.SubItem)
		end
	end,

	["VENDUE.SC.ITEM_SELL_INFO"] = function (Ret)
		ui.show("UI/WNDBuyGoods", nil, Ret)
	end,

	["VENDUE.SC.VENDUE_OWNER"] = function (GoodsOrders)
		if GoodsOrders then rfsh_goods_list(GoodsOrders) end
	end
}

return self

