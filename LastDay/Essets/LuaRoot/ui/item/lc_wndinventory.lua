--
-- @file    ui/item/lc_wndinventory.lua
-- @author  xingweizhen
-- @date    2017-11-01 22:13:13
-- @desc    WNDInventory
--

local self = ui.new()
setfenv(1, self)

self.StatusBar = {
	AssetBar = true,
	HealthyBar = true,
}

local function rfsh_inventory_view()
	self:rfsh_view()
end

local function on_item_changed(Items)
	self:item_changed(Items)
end

local function show_item_info(Item)
	local SubInfo = Ref.SubInfo
	libugui.SetVisible(SubInfo.lbTips, Item == nil)
	libugui.SetVisible(SubInfo.SubItem.spEmpty, Item == nil)
	libunity.SetActive(SubInfo.SubDesc.go, Item ~= nil)

	show_item_view(Item, SubInfo.SubItem)
	if Item then
		local ItemBase = Item:get_base_data()
		SubInfo.SubDesc.lbName.text = cfgname(ItemBase)

		local Content = { ItemBase.desc }
		local AttrTips = Item:gen_attr_tip()
		if AttrTips then for _,v in ipairs(AttrTips) do table.insert(Content, v) end end

		local DuraTips = Item:gen_dura_tip()
		if DuraTips then for _,v in ipairs(DuraTips) do table.insert(Content, v) end end

		SubInfo.SubDesc.lbDesc.text = table.concat(Content, "\n")
	else
		SubInfo.SubDesc.lbName.text = nil
		SubInfo.SubDesc.lbDesc.text = nil
	end
end

function show_grpent_view(go, index)
	self.GrpBackpack:setindex(go, index)
	self:show_loop_view(go, index, "entItem")
end

--!* [开始] 自动生成函数 *--

function on_item_selected(evt, data)
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

function on_drop_item(evt, data)
	self:drop_drag(evt, data)
end

function on_item_pressed(evt, data)
	-- if data then
	-- 	self:show_tip()
	-- else
	-- 	_G.DEF.Item.hide_tip()
	-- end
end

function on_item_dualclick(evt, data)
	-- 2018.5.9日反馈：双击物品栏装备物品的操作结果不再可见，不再有双击物品栏这一操作
	-- self:op_equip(self:ent2index(evt))
end

function on_btncharacter_click(btn)
	self:close(true)
	ui.open("UI/WNDCharacter")
end

function on_grpbackpack_ent(go, i)
	show_grpent_view(go, CVar.POCKET_NUM + i + 1)
end

function on_subop_btnequip_click(btn)
	self:op_equip()
end

function on_subop_btnuse_click(btn)
	self:op_use()
end

function on_subop_btnsplit_click(btn)
	self:op_split()
end

function on_subop_btndelete_click(btn)
	self:op_delete()
end
--!* [结束] 自动生成函数  *--

function init_view()
	ui.group(Ref.SubItems.GrpPockets)
	ui.group(Ref.SubItems.SubScroll.SubView.GrpBackpack)
	--!* [结束] 自动生成代码 *--

	Ref.SubInfo.lbTips.text = TEXT.tipInventoryUnsel
	self.GrpPockets = Ref.SubItems.GrpPockets
	self.GrpBackpack = Ref.SubItems.SubScroll.SubView.GrpBackpack
	self.SubItemOp = Ref.SubOp
	self.spSelected = Ref.SubItems.spSelected

	local UTIL = _G.PKG["ui/util"]
	local flex_itemgrp = UTIL.flex_itemgrp
	flex_itemgrp(self.GrpPockets)
	flex_itemgrp(self.GrpBackpack)
	UTIL.flex_itement(Ref.SubInfo, "SubItem", 0)
	libugui.SetVisible(Ref.SubInfo.SubItem.lbAmount, false)

	local Inv = _G.PKG["ui/item/inventory"]
	setmetatable(Inv, getmetatable(self))
	setmetatable(self, Inv)

	self.show_item_view = _G.PKG["ui/util"].show_item_view

	-- 不允许选中空的格子，重写选中格子操作
	local base_focus_slot = Inv.focus_slot
	self.focus_slot = function (self, go, allowEmpty)
		local index = self:ent2index(go)
		local Item = DY_DATA:iget_item(index)
		if allowEmpty or Item then
			self.selectedIdx = index
			base_focus_slot(self, go)
			show_item_info(Item)
			self:update_itemop(Item)
		end
	end
end

function init_logic()
	libgame.UnitStay(0, false)

	ui.moveout(Ref.spBack, 1)

	libugui.SetVisible(Ref.SubItems.spSelected, false)
	show_item_info()

	Ref.SubDrag = ui.ref(ui.create("UI/SubItemDrag"))
	libugui.SetVisible(Ref.SubDrag.go, false)
end

function show_view()
	rfsh_inventory_view()
	local scroll = Ref.SubItems.SubScroll.go:GetComponent("ScrollRect")
	scroll.verticalNormalizedPosition = 1

	self.selectedIdx = nil
	self:focus_slot()
	self:update_itemop()
	self:rfsh_itemscd()
end

function on_recycle()
	ui.close(Ref.SubDrag.go, true)

	ui.putback(Ref.spBack, Ref.go)
	libunity.SetParent(Ref.SubItems.spSelected, Ref.SubItems.go)
end

Handlers = {
	["PACKAGE.SC.ITEM_MOVE"] = function (Items)
		if Items then
			if self.dropIdx then
				local Item = DY_DATA:iget_item(dropIdx)
				Item:play_drop(dropIdx)

				local Ent = self:iget_entitem(dropIdx)
				self:focus_slot(Ent and Ent.go, true)
				self.dropIdx = nil
			end
			on_item_changed(Items)
			self:rfsh_itemscd()
			self.dragIdx = nil
		else
			if dragIdx then
				-- 处理拖动失败的情况
				show_item_view(DY_DATA:iget_item(dragIdx), self:iget_entitem(dragIdx))
				self.dragIdx = nil
			end
		end
	end,
	["PACKAGE.SC.ITEM_DEL"] = on_item_changed,
	["PACKAGE.SC.ITEM_USE"] = function (Items)
		on_item_changed(Items)
		self:rfsh_itemscd()
	end,
	["PACKAGE.SC.SYNC_ITEM"] = on_item_changed,
	["PACKAGE.SC.PACKAGE_INTO"] = on_item_changed,

	["PACKAGE.SC.PACKAGE_PICKUP"] = rfsh_inventory_view,
	["PACKAGE.SC.SYNC_PACKAGE"] = rfsh_inventory_view,
}

return self

