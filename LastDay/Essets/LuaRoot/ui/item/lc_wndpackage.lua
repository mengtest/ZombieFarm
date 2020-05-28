--
-- @file    ui/item/lc_wndpackage.lua
-- @author  xingweizhen
-- @date    2018-04-11 09:53:11
-- @desc    WNDPackage
--

local self = ui.new()
setfenv(1, self)

self.StatusBar = {
	AssetBar = true, HealthyBar = true,
}

local function rfsh_inventory_view()
	self:rfsh_view()
end

local function on_item_changed(Items)
	self:item_changed(Items)
end

function show_grpent_view(go, index, isLocked)
	self:show_loop_view(go, index, "entItem", isLocked)
end

--!* [开始] 自动生成函数 *--

function on_item_selected(evt, data)
	self:focus_slot(evt)
end

function on_begindrag_item(evt, data)
	self:begin_drag(evt, data)
	if Secondary.begindrag_item then
		Secondary.begindrag_item(evt)
	end
end

function on_drag_item(evt, data)
	self:doing_drag(evt, data)
end

function on_enddrag_item(evt, data)
	self:end_drag(evt, data)
	if Secondary.enddrag_item then
		Secondary.enddrag_item(evt)
	end
end

function on_drop_item(evt, data)
	self:drop_drag(evt, data)
end

function on_item_pressed(evt, data)
	if data then
		self:show_tip(evt)
	else
		_G.DEF.Item.hide_tip()
	end
end

function on_item_dualclick(evt, data)
	if Secondary.item_dual_click then
		Secondary.item_dual_click(self:ent2index(evt))
	end
end

function on_grpbackpack_ent(go, i)
	local index = CVar.POCKET_NUM + i + 1
	self.GrpBackpack:setindex(go, index)
	show_grpent_view(go, index)
end

function on_subitems_subop_btnequip_click(btn)
	self:op_equip()
end

function on_subitems_subop_btnuse_click(btn)
	self:op_use()
end

function on_subitems_subop_btnsplit_click(btn)
	self:op_split()
end

function on_subitems_subop_btndelete_click(btn)
	self:op_delete()
end
--!* [结束] 自动生成函数  *--

function init_view()
	ui.group(Ref.SubItems.GrpPockets)
	ui.group(Ref.SubItems.SubScroll.SubView.GrpBackpack)
	--!* [结束] 自动生成代码 *--

	self.GrpPockets = Ref.SubItems.GrpPockets
	self.GrpBackpack = Ref.SubItems.SubScroll.SubView.GrpBackpack
	self.SubItemOp = Ref.SubItems.SubOp
	self.spSelected = Ref.SubItems.spSelected

	local flex_itemgrp = _G.PKG["ui/util"].flex_itemgrp
	flex_itemgrp(self.GrpPockets)
	flex_itemgrp(self.GrpBackpack)

	local Inv = _G.PKG["ui/item/inventory"]
	setmetatable(Inv, getmetatable(self))
	setmetatable(self, Inv)

	local show_item_view = _G.PKG["ui/util"].show_item_view
	self.show_item_view = function (Item, Ent, defSprite, clip, forceShowAmount)
		show_item_view(Item, Ent, defSprite, clip, forceShowAmount)
		self:show_cooldown(Item, Ent)
	end

	-- 不允许选中空的格子，重写选中格子操作
	local base_focus_slot = Inv.focus_slot
	self.focus_slot = function (self, go, allowEmpty)
		local index = go and self:ent2index(go)
		local Item = DY_DATA:iget_item(index)
		if allowEmpty or Item then
			self.selectedIdx = index
			base_focus_slot(self, go)
			self:update_itemop(Item)
		end
	end

	self.GrpPockets:dup(CVar.POCKET_NUM)
	libugui.RebuildLayout(Ref.SubItems.go)
end

function init_logic()
	if Context == nil then
		Context = { wndName = "WNDEquipBag" }
		self.StatusBar.Menu = 1
	else
		local pageIcon = Context.pageIcon --"Common/ico_main_001"
		local pageTitle = Context.title

		self.packageObj = Context.obj
		self.StatusBar.Menu = {
			icon = pageIcon,
			name = "WNDPackage", title = pageTitle,
			Context = Context,
		}
	end

	Context.Primary = self

	ui.show("UI/" .. Context.wndName, ui.DEPTH_WND + 1, Context)

	libugui.SetVisible(self.spSelected, false)

	Ref.SubDrag = ui.ref(ui.create("UI/SubItemDrag"))
	libugui.SetVisible(Ref.SubDrag.go, false)

	rfsh_inventory_view()
	local scroll = Ref.SubItems.SubScroll.go:GetComponent("ScrollRect")
	scroll.verticalNormalizedPosition = 1

	self.selectedIdx = nil
	self:focus_slot()
	self:update_itemop()
	self:rfsh_itemscd()
end

function show_view()

end

function on_recycle()
	ui.close(Context.wndName, true)
	ui.close(Ref.SubDrag.go, true)

	libunity.SetParent(self.spSelected, Ref.SubItems.go)

	if packageObj then
		libgame.UnitBreak(0)
		NW.send(NW.gamemsg("PACKAGE.CS.PACKAGE_CLOSE"):writeU32(packageObj))
		-- 清空缓存
		DY_DATA:del_obj_items(packageObj)
	end
end

Handlers = {
	["PACKAGE.SC.ITEM_MOVE"] = function (Items)
		if Items then
			if self.dropIdx then
				local Item = DY_DATA:iget_item(dropIdx)
				if Item then
					Item:play_drop(dropIdx)
					local Ent = self:iget_entitem(dropIdx)
					if Ent then self:focus_slot(Ent.go) end
				else
					self:focus_slot()
				end

				self.dropIdx = nil
			end
			self:item_changed(Items)
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
	["PACKAGE.SC.SYNC_PACKAGE"] = function (Package)
		if Package.obj == 0 and Package.bag == 0 then
			rfsh_inventory_view()
		end
	end,
	["PACKAGE.SC.ITEM_COMPOSE"] = on_item_changed,
}

return self

