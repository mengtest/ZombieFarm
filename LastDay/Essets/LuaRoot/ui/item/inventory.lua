--
-- @file    ui/item/inventory.lua
-- @anthor  xingweizhen (weizhen.xing@funplus.com)
-- @date    2018-04-11 11:01:35
-- @desc    描述
--

local P = {}
P.__index = P
P.__tostring = function (self)
	if self then
		return string.format("[Window:%s@%d<%s>]", self.path, self.depth or 0, tostring(self:is_opened()))
	else
		return "[WindowDEF]"
	end
end

local UTIL = _G.PKG["ui/util"]

local POCKET_NUM, BACKPACK_MIN, BACKPACK_NUM =
	_G.CVar.POCKET_NUM, _G.CVar.BACKPACK_MIN, _G.CVar.BACKPACK_NUM
local OBJ_ITEM_LIMIT = _G.CVar.OBJ_ITEM_LIMIT

function P:rfsh_itemscd()
	local Ref, Items = self.Ref, DY_DATA:get_obj_items(0)
	for i=1,POCKET_NUM,1 do
		local v = Items[i]
		local ent = self:iget_entitem(i)
		self:show_cooldown(v, ent)
	end

	local GrpBackpack = self.GrpBackpack
	local nBackpack = math.max(DY_DATA.bagCap - POCKET_NUM, BACKPACK_MIN)
	for i=1,nBackpack,1 do
		local index = CVar.POCKET_NUM + i
		local ent = self:iget_entitem(index)

		local unlock = index <= DY_DATA.bagCap or index > OBJ_ITEM_LIMIT
		if ent and unlock then
			local Item = DY_DATA:iget_item(index)
			self:show_cooldown(Item, ent)
		end
	end

	local secondaryCnt = self.Context.cap and self.Context.cap or 0
	for i=1,secondaryCnt,1 do
		local index = CVar.gen_item_pos(self.Context.obj, 0, i)
		local ent = self:iget_entitem(index)
		local unlock = index <= DY_DATA.bagCap or index > OBJ_ITEM_LIMIT
		if ent and unlock then
			local Item = DY_DATA:iget_item(index)
			self:show_cooldown(Item, ent)
		end
	end
end

function P:rfsh_view()
	local show_item_view = self.show_item_view
	local Ref, Items = self.Ref, DY_DATA:get_obj_items(0)
	self.GrpPockets:dup(POCKET_NUM, function (i, Ent, isNew)
		show_item_view(Items[i], Ent)
		
	end)

	local GrpBackpack = self.GrpBackpack
	local nBackpack = math.max(DY_DATA.bagCap - POCKET_NUM, BACKPACK_MIN)
	libugui.SetLoopCap(GrpBackpack.go, nBackpack, true)
	Ref.SubItems.SubScroll.go:GetComponent("ScrollRect").movementType =
		nBackpack > BACKPACK_MIN and "Elastic" or "Clamped"
end

function P:show_loop_view(go, index, entName, isLocked)
	local unlock = index <= DY_DATA.bagCap or index > OBJ_ITEM_LIMIT
	local Ent = ui.ref(go)
	Ent.evt.interactable = unlock

	if unlock then
		local Item = DY_DATA:iget_item(index)
		self.show_item_view(Item, Ent)

		if Ent.spLock then
			if Item == nil and isLocked then
				libunity.SetActive(Ent.spLock, true)
			else
				libunity.SetActive(Ent.spLock, false)
			end
		end

		if self.selectedIdx == index then
			if  Item == nil then
				self.selectedIdx = nil
				libugui.SetVisible(Ent.spSelected, false)
			end 
				self:focus_slot(go)
				self:update_itemop(Item)
		else
			libugui.SetVisible(Ent.spSelected, false)
		end
	else
		self.show_item_view(nil, Ent)
		libugui.KillTween(Ent.spCooldown)
		libunity.SetActive(Ent.spCooldown, false)
		Ent.spIcon:SetSprite("Common/frm_inventory_004")
	end
end

function P:check_slots(srcPos, tarPos)
	local CVar = _G.CVar
	if tarPos > CVar.EQUIP_POS_ZERO and tarPos < OBJ_ITEM_LIMIT then
		local Item = DY_DATA:iget_item(srcPos)
		if Item then
			local sType = CVar.EQUIP_POS2TYPE[tarPos]
			local ItemBase = Item:get_base_data()
			if ItemBase.mType == "EQUIP" then
				return sType == ItemBase.sType
			elseif ItemBase.shortcut then
				return tarPos == CVar.EQUIP_LPOCKET_POS
					or tarPos == CVar.EQUIP_RPOCKET_POS
			else return false end
		end
	end

	return true
end

function P:check_can_putin(pos)
	if pos >= CVar.OBJ_ITEM_LIMIT then
		return self.Context.canPutIn
	end
	return true
end

function P:show_cooldown(Item, Ent)
	if Ent and Ent.spCooldown then
		if Item and Item.dat and Item.dat ~= 0 then
			local cooldown, cycle = DY_DATA:get_item_cool(Item)
			if cooldown and cooldown > 0 then
				UTIL.tween_cooldown(Ent.spCooldown, cooldown, cycle)
			else
				libunity.SetActive(Ent.spCooldown, false)
			end
		else
			libugui.KillTween(Ent.spCooldown)
			libunity.SetActive(Ent.spCooldown, false)
		end
	end
end

function P:ent2index(go)
	local index = ui.index(go)
	if index then return index end

	if self.Secondary then
		return self.Secondary.ent2index(go)
	end
end

function P:iget_entitem(index)
	local CVar = _G.CVar
	if index > CVar.EQUIP_POS_ZERO then
		if self.Secondary then
			return self.Secondary.iget_entitem(index)
		end
	elseif index > POCKET_NUM then
		return self.GrpBackpack:find(index)
	else
		return self.GrpPockets:find(index)
	end
end

function P:try_select_item(go)
	local index = self:ent2index(go)
	local Item = DY_DATA:iget_item(index)
	if Item then
		self.selectedIdx = index
	end
	return Item
end

function P:focus_slot(go)
	local spSelected = self.spSelected
	if go then
		libunity.SetParent(spSelected, go, false, -1)
	end
	libugui.SetVisible(spSelected, go ~= nil)
end

function P:update_itemop(Item)
	local SubOp = self.SubItemOp
	if Item and Item.amount and Item.amount > 0 then
		local Self = DY_DATA.Self
		local ItemBase = Item:get_base_data()
		local inBag = Item.pos % 1000 < 100
		local urinateError = Self:urinate_error()
		local isInPocket = Item.pos == CVar.EQUIP_LPOCKET_POS or Item.pos == CVar.EQUIP_RPOCKET_POS

		SubOp.btnUse.interactable = ItemBase.sType == "USE" and not urinateError
		SubOp.btnEquip.interactable = inBag
			and (ItemBase.mType == "EQUIP" or ItemBase.shortcut)
			and not urinateError
		SubOp.btnDelete.interactable = ItemBase.destroyable
		SubOp.btnSplit.interactable = Item.amount > 1 and ItemBase.nStack > 1 and not isInPocket
	else
		SubOp.btnUse.interactable = false
		SubOp.btnEquip.interactable = false
		SubOp.btnSplit.interactable = false
		SubOp.btnDelete.interactable = false
	end
end

function P:show_tip(go)
	local Item = self:try_select_item(go)
	if Item then
		local Diff = DY_DATA:get_self():get_equipped(Item)
		Item:show_tip(go, Diff)
		self:focus_slot(go)
		self:update_itemop(Item)
	end
end

function P:begin_drag(evt, data)
	local Ref = self.Ref
	local dragIdx = self:ent2index(evt)
	local Item = DY_DATA:iget_item(dragIdx)
	if Item then
		Item:play_drag()

		libugui.SetVisible(Ref.SubDrag.go, true)
		self.dragIdx = dragIdx
		self.show_item_view(nil, self:iget_entitem(dragIdx))
		self.show_item_view(Item, Ref.SubDrag)
	else
		self.dragIdx = nil
	end
end

function P:doing_drag(evt, data)
	if self.dragIdx then
		local Ref = self.Ref
		local localPos = libugui.ScreenPoint2Local(data.position, Ref.go)
		libugui.SetAnchoredPos(Ref.SubDrag.go, localPos)
	end
end

function P:end_drag(evt, data)
	local dragIdx = self.dragIdx
	if dragIdx then
		local Ref = self.Ref
		if libugui.SetVisible(Ref.SubDrag.go, false) then
			self.show_item_view(DY_DATA:iget_item(dragIdx), self:iget_entitem(dragIdx))
		end
		if not NW.connected() then self.dragIdx = nil end
	end
end

function P:drop_slot(slotIdx)
	self.dropIdx = slotIdx
	local dragIdx, dropIdx = self.dragIdx, self.dropIdx

	if not self:check_can_putin(dropIdx) then
		return
	end

	if dragIdx ~= dropIdx then
		local DragItem = DY_DATA:iget_item(dragIdx)
		if self:check_slots(dropIdx, dragIdx) and
			self:check_slots(dragIdx, dropIdx) and
			NW.move_item(dragIdx, dropIdx) then
			-- 拖拽成功
			libugui.SetVisible(self.Ref.SubDrag.go, false)
			
			if not NW.connected() then
				self.dropIdx = nil
			end
		end
	end
end

function P:drop_drag(evt, data)
	if self.dragIdx then
		self:drop_slot(self:ent2index(evt))
	end
end

function P:item_changed(Items)
	if Items == nil then return end

	local EQUIP_POS2NAME = _G.CVar.EQUIP_POS2NAME
	local SlotNames = {}
	if self.selectedIdx == nil then self:focus_slot(nil, true) end

	for _,v in ipairs(Items) do
		local ent = self:iget_entitem(v.pos)
		self.show_item_view(v, ent)
		if self.selectedIdx == v.pos then
			if v.dat == nil or v.dat == 0 then
				self:focus_slot(nil, true)
			else
				self:update_itemop(v)
			end
		end

		local name = EQUIP_POS2NAME[v.pos]
		if name then SlotNames[name] = true end
	end

	local Secondary = self.Secondary
	if Secondary and Secondary.equip_changed then
		Secondary.equip_changed(SlotNames)
	end
end

function P:item2equipidx(Item)
	if Item == nil then return end

	local _, bag, idx = CVar.split_item_idx(Item.pos)
	local slotId = nil
	if bag == 0 then
		local ItemBase = Item:get_base_data()
		if ItemBase.shortcut then
			-- 快捷口袋栏，检查可堆叠位置
			if ItemBase.nStack > 1 then
				local function stack_checking(slot)
					local Pocket = DY_DATA:iget_item(slot)
					if Pocket and Pocket.dat == Item.dat then
						if Pocket.amount < ItemBase.nStack then
							return slot
						end
					end
				end
				slotId = stack_checking(CVar.EQUIP_LPOCKET_POS)
					or stack_checking(CVar.EQUIP_RPOCKET_POS)
			end

			-- 检查空位置
			if slotId == nil then
				local function empty_checking(slot)
					if DY_DATA:iget_item(slot) == nil then return slot end
				end
				slotId = empty_checking(CVar.EQUIP_LPOCKET_POS)
					or empty_checking(CVar.EQUIP_RPOCKET_POS)
			end

			-- 使用左口袋
			if slotId == nil then
				slotId = CVar.EQUIP_LPOCKET_POS
			end
		elseif ItemBase.mType == "EQUIP" then
			local sType = ItemBase.sType
			if sType == "WEAPON" then
				-- 优先空栏位，再优先主手
				local Minor = DY_DATA:iget_item(CVar.EQUIP_MINOR_POS)
				if Minor then
					slotId = CVar.EQUIP_MAJOR_POS
				else
					slotId = DY_DATA:iget_item(CVar.EQUIP_MAJOR_POS) and
						CVar.EQUIP_MINOR_POS or CVar.EQUIP_MAJOR_POS
				end
			else
				for k,v in pairs(CVar.EQUIP_POS2TYPE) do
					if v == sType then slotId = k; break end
				end
			end
		end
	elseif bag == 1 then
		if idx == 1 then
			-- 双击副手武器=切换到主手
			slotId = CVar.EQUIP_MAJOR_POS
		end
	end

	return slotId
end

function P:op_equip(index)
	local CVar = _G.CVar
	local itemIndex = index or self.selectedIdx
	local Item = DY_DATA:iget_item(itemIndex)
	local slotId = P:item2equipidx(Item)
	
	if slotId then
		self.dropIdx = slotId
		self.selectedIdx = nil
		self:focus_slot()
		self:update_itemop()
		NW.move_item(itemIndex, slotId)
		return Item, true
	end
	return Item
end

function P:op_use()
	NW.use_item(DY_DATA:iget_item(self.selectedIdx))
end

function P:op_split()
	local Item = DY_DATA:iget_item(self.selectedIdx)
	if Item and Item.amount > 1 then
		local obj, bagCap
		if Item.pos > OBJ_ITEM_LIMIT then
			obj, bagCap = self.Context.obj, self.Context.cap
		else
			obj, bagCap = 0, DY_DATA.bagCap or (POCKET_NUM + BACKPACK_NUM)
		end
		local emptyIdx = DY_DATA:get_empty_itempos(obj, 0, bagCap)
		if emptyIdx then
			local amount = math.floor(Item.amount / 2)
			NW.move_item(Item.pos, emptyIdx, amount)
		else
			-- 没有空位拆分
		end
	end
end

function P:op_delete()
	local Item = DY_DATA:iget_item(self.selectedIdx)
	if Item then
		UI.MBox.operate("DeleteItem", function () NW.del_item(Item) end, {
				txtConfirm = TEXT.delete,
				confirmStyle = "Red",
			})
	end
end

return P
