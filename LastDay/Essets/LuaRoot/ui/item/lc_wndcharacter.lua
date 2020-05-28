--
-- @file    ui/item/lc_wndcharacter.lua
-- @author  xingweizhen
-- @date    2018-04-03 11:18:00
-- @desc    WNDCharacter
--

local self = ui.new()
setfenv(1, self)

self.StatusBar =
{
	AssetBar = true,
	HealthyBar = true,
}

self.Item4AllPos = {}

local Name2Index = {
	SubMajor = CVar.EQUIP_MAJOR_POS,
	SubMinor = CVar.EQUIP_MINOR_POS,
	SubHead = CVar.EQUIP_HEAD_POS,
	SubBody = CVar.EQUIP_BODY_POS,
	SubLeg = CVar.EQUIP_LEG_POS,
	SubFoot = CVar.EQUIP_FOOT_POS,
	SubLPocket = CVar.EQUIP_LPOCKET_POS,
	SubRPocket = CVar.EQUIP_RPOCKET_POS,
	SubBag = CVar.EQUIP_BAG_POS,
}
local Index2Name = table.swapkv(Name2Index)
local DefIcons = {
	[CVar.EQUIP_MAJOR_POS] = "Common/ico_com_027",
	[CVar.EQUIP_MINOR_POS] = "Common/ico_com_033",
	[CVar.EQUIP_HEAD_POS] = "Common/ico_com_008",
	[CVar.EQUIP_BODY_POS] = "Common/ico_com_014",
	[CVar.EQUIP_LEG_POS] = "Common/ico_com_007",
	[CVar.EQUIP_FOOT_POS] = "Common/ico_com_013",
	[CVar.EQUIP_LPOCKET_POS] = "Common/ico_com_022",
	[CVar.EQUIP_RPOCKET_POS] = "Common/ico_com_022",
	[CVar.EQUIP_BAG_POS] = "Common/ico_com_006",
}

local UTIL = _G.PKG["ui/util"]
local show_item_view = UTIL.show_item_view
local show_attr_view = UTIL.show_attr_view

local function get_item4pos(pos)
	local Item4Pos = self.Item4AllPos[pos]
	if Item4Pos == nil then
		Item4Pos = {}
		if pos > CVar.EQUIP_BAG_POS then
			-- 口袋栏，对应的是支持快捷使用的道具
			for i=1,DY_DATA.bagCap do
				local Item = DY_DATA:iget_item(i)
				if Item then
					local ItemBase = Item:get_base_data()
					if ItemBase.shortcut then
						table.insert(Item4Pos, Item)
					end
				end
			end
			self.Item4AllPos[CVar.EQUIP_LPOCKET_POS] = Item4Pos
			self.Item4AllPos[CVar.EQUIP_RPOCKET_POS] = Item4Pos
		else
			local sType = CVar.EQUIP_POS2TYPE[pos]
			for i=1,DY_DATA.bagCap do
				local Item = DY_DATA:iget_item(i)
				if Item then
					local ItemBase = Item:get_base_data()
					if ItemBase.sType == sType then
						table.insert(Item4Pos, Item)
					end
				end
			end
			if sType == "WEAPON" then
				self.Item4AllPos[CVar.EQUIP_MAJOR_POS] = Item4Pos
				self.Item4AllPos[CVar.EQUIP_MINOR_POS] = Item4Pos
			else
				self.Item4AllPos[pos] = Item4Pos
			end
		end
	end

	return Item4Pos
end

local function clear_item4pos(pos)
	if pos > CVar.EQUIP_BAG_POS then
		self.Item4AllPos[CVar.EQUIP_LPOCKET_POS] = nil
		self.Item4AllPos[CVar.EQUIP_RPOCKET_POS] = nil
	elseif pos == CVar.EQUIP_MAJOR_POS or pos == CVar.EQUIP_MAJOR_POS then
		self.Item4AllPos[CVar.EQUIP_MAJOR_POS] = nil
		self.Item4AllPos[CVar.EQUIP_MINOR_POS] = nil
	else
		self.Item4AllPos[pos] = nil
	end
end

local function item_pos2ent(pos)
	local entName = Index2Name[pos]
	if entName then
		if pos < Name2Index.SubHead then
			return Ref.SubRIGHT.SubContent.SubWeapons[entName]
		elseif pos <= Name2Index.SubBag then
			return Ref.SubLEFT.SubContent.SubEquips[entName]
		else
			return Ref.SubRIGHT.SubContent.SubPocket[entName]
		end
	end
end

local show_item_view = UTIL.show_item_view
local function show_equip_view(Item, Ent, pos)
	show_item_view(Item, Ent, DefIcons[pos])
	libugui.SetVisible(Ent.spTip, Item == nil and #get_item4pos(pos) > 0)
end

local function rfsh_equips_view()
	for k,v in pairs(Index2Name) do
		local Item = DY_DATA:iget_item(k)
		local Ent = item_pos2ent(k)
		if Ent then show_equip_view(Item, Ent, k) end

		if k == CVar.EQUIP_LPOCKET_POS or k == CVar.EQUIP_RPOCKET_POS then
			local cooldown, cycle
			if Item then
				cooldown, cycle = DY_DATA:get_item_cool(Item)
			end
			if cooldown and cooldown > 0 then
				UTIL.tween_cooldown(Ent.spCooldown, cooldown, cycle)
			else
				libunity.SetActive(Ent.spCooldown, false)
			end
		end
	end
end

local function rfsh_role_view()
	local Player = DY_DATA:get_player()
	local SubName = Ref.SubLEFT.SubContent.SubName

	SubName.lbName.text = string.format("LV.%d %s", Player.level, Player.name)
end

local function rfsh_role_attrs()
	local Obj = DY_DATA.Self
	local Attr = Obj:calc_attr()
	local Keys = { "Damage", "def", "move", "fast" }
	show_attr_view(Ref.SubLEFT.SubContent.GrpAttrs, Attr, Keys)
end

local function rfsh_equip_dura(obj, Inf)
	if obj == DY_DATA.Self.id then
		local CVar = CVar
		local pos = Inf.pos
		if pos > CVar.EQUIP_POS_ZERO then
			local Item = DY_DATA:iget_item(pos)
			local Ent = item_pos2ent(pos)
			if Ent then show_equip_view(Item, Ent, pos) end
		end
	end
end

local function update_player_view(pose, Model, Affixes)
	if libunity.IsActive(player) then
		libgame.UpdateUnitView(player, pose, { model = Model, Affixes = Affixes })
	end
end

local function create_player_view()
	local Self = DY_DATA.Self
	local PlayerForm = Self:get_form_data()
	local genderTag = CVar.GenderTag[Self.gender]
	self.player = libgame.CreateView("/UIROOT/ROLE", "PlayerOverUI" .. genderTag,
		PlayerForm.Data.Attr.weapon, PlayerForm.View)

	local urinateError = Self:urinate_error()
	local anim = player:GetComponentInChildren(typeof(UE.Animator))
	anim:SetBool("urinate", Self:urinate_error())

	local Weapon = DY_DATA:iget_item(CVar.EQUIP_MAJOR_POS)
	if not urinateError and Weapon then
		local WeaponBase = Weapon:get_base_data()
		local pose = WeaponBase.wType
		local Affixes = { Weapon:get_dress_data(), }
		update_player_view(pose, nil, Affixes)
	end

	Ref.SubEquipList.SubOp.btnEquip.interactable = not urinateError
	Ref.SubEquipList.SubOp.btnRemove.interactable = not urinateError

	libugui.Follow(player, Ref.evtModel, 4)

	libunity.FaceCamera(player)
end

local function focus_equip(Sub, go)
	local spSelected = Sub.spSelected
	libunity.SetParent(spSelected, go or Sub.go, false, -1)
	libugui.SetVisible(spSelected, go ~= nil)
end

local function focus_equip_pos(go)
	focus_equip(Ref, go)
end

local function focus_equip_index(go)
	focus_equip(Ref.SubEquipList, go)
end

local function rfsh_list_opbtn()
	local SubOp = Ref.SubEquipList.SubOp
	local isEquipPos = self.selectPos ~= CVar.EQUIP_LPOCKET_POS
		and self.selectPos ~= CVar.EQUIP_RPOCKET_POS
	local PosItem = DY_DATA:iget_item(self.selectPos)
	libunity.SetActive(SubOp.btnEquip, self.selectIdx ~= nil)
	libunity.SetActive(SubOp.btnUse, PosItem ~= nil and not isEquipPos)
	libunity.SetActive(SubOp.btnRemove, PosItem ~= nil)
end

local function rfsh_equip_list()
	self.EquipList = get_item4pos(self.selectPos)

	--装备列表排序
	if self.EquipList then
		table.sort(self.EquipList, function (element1, element2)
			local itemBase1 = element1:get_base_data()
			local itemBase2 = element2:get_base_data()

			if itemBase1.score ~= itemBase2.score then
				return itemBase1.score > itemBase2.score
			end

			if itemBase1.id ~= itemBase2.id then
				return itemBase1.id > itemBase2.id
			end

			local itemDura1 = element1:get_durability()
			local itemDura2 = element2:get_durability()

			if itemDura1 ~= itemDura2 then
				return itemDura1 > itemDura2
			end

			if element1.amount ~= element2.amount then
				return element1.amount > element2.amount
			end

			return element1.pos < element2.pos
		end )
	end

	local scroll = Ref.SubEquipList.go:GetComponent("ScrollRect")
	--scroll.verticalNormalizedPosition = 1
	libugui.SetLoopCap(Ref.SubEquipList.SubView.GrpEquips.go, #EquipList, true)

	self.selectIdx = nil
	focus_equip_index(nil)
	rfsh_list_opbtn()
end


local function equip_changed(SlotNames)
	local Self = DY_DATA.Self
	local pose, Model
	local Affixes = {}
	if SlotNames.major then
		local Weapon = Self:get_weapon()
		if Weapon then
			local WeaponBase = Weapon:get_base_data()
			pose = WeaponBase.wType
			table.insert(Affixes, Weapon:get_dress_data())
			table.insert(Affixes, { index = 3 - WeaponBase.affixIdx, path = "", })
		else
			pose = 0
			table.insert(Affixes, Self.EMPTY_RHAND)
			table.insert(Affixes, Self.EMPTY_LHAND)
		end
		next_action(Ref.go, rfsh_role_attrs)
	end

	if SlotNames.bag then
		table.insert(Affixes, Self:update_view_affix(CVar.EQUIP_TYPE2SLOT.BAG))
	end

	if SlotNames.dress then
		Model = Self:get_view_dresses()
		next_action(Ref.go, rfsh_role_attrs)
	end

	if #Affixes == 0 then Affixes = nil end
	if SlotNames.major or SlotNames.bag or SlotNames.dress then
		update_player_view(pose, Model, Affixes)
	end

end

local function on_item_changed(Items)
	if Items == nil then return end

	local EQUIP_POS2NAME = CVar.EQUIP_POS2NAME
	local SlotNames = {}
	for _,v in ipairs(Items) do
		if v.pos == selectPos then
			if v.dat > 0 then v:play_drop() end
			local Ent = item_pos2ent(selectPos)
			if Ent then
				show_equip_view(v, Ent, selectPos)
			end

			if v.pos == CVar.EQUIP_LPOCKET_POS or v.pos == CVar.EQUIP_RPOCKET_POS then
				local cooldown, cycle = DY_DATA:get_item_cool(v)
				if cooldown and cooldown > 0 then
					UTIL.tween_cooldown(Ent.spCooldown, cooldown, cycle)
				else
					libunity.SetActive(Ent.spCooldown, false)
				end
			end

		end

		local name = EQUIP_POS2NAME[v.pos]
		if name then SlotNames[name] = true end
	end

	-- 全部重置（可优化为针对位置重置）
	self.Item4AllPos = {}

	equip_changed(SlotNames)

	-- 重新刷新列表
	next_action(Ref.go, rfsh_equip_list)
end

local function pos2side(pos)
	if pos then
		return (pos < Name2Index.SubHead or pos > Name2Index.SubBag) and "RIGHT" or "LEFT"
	end
end

--!* [开始] 自动生成函数 *--

function on_evtmodel_drag(evt, data)
	local delta = data.delta
	local trans = player.transform
	local euler = trans.localEulerAngles
	euler.y = euler.y - delta.x
	trans.localEulerAngles = euler
end

function on_btnhidelist_click(btn)
	local tweenDura = 0.2
	local EquipList_go = Ref.SubEquipList.go
	local size = libugui.GetRectSize(EquipList_go)
	libugui.KillTween(EquipList_go)

	local LEFTContent_go = Ref.SubLEFT.SubContent.go
	local RIGHTContent_go = Ref.SubRIGHT.SubContent.go

	local listPos = libugui.GetAnchoredPos(EquipList_go)
	local side = pos2side(self.selectPos)
	if side == "LEFT" then
		libugui.KillTween(LEFTContent_go)
		local pos = libugui.GetAnchoredPos(LEFTContent_go)
		pos.x = 0
		libugui.DOTween("Position", LEFTContent_go, nil, pos, { duration = tweenDura })

		listPos.x = listPos.x - size.x
		libugui.DOTween("Position", EquipList_go, nil, listPos, { duration = tweenDura })
	elseif side == "RIGHT" then
		libugui.KillTween(RIGHTContent_go)
		local pos = libugui.GetAnchoredPos(RIGHTContent_go)
		pos.x = 0
		libugui.DOTween("Position", RIGHTContent_go, nil, pos, { duration = tweenDura })

		listPos.x = listPos.x + size.x
		libugui.DOTween("Position", EquipList_go, nil, listPos, { duration = tweenDura })
	end

	local sizeL = libugui.GetRectSize(LEFTContent_go)
	local sizeR = libugui.GetRectSize(RIGHTContent_go)
	local mpos = libugui.GetAnchoredPos(Ref.evtModel)
	libugui.DOTween("Position", Ref.evtModel, nil, UE.Vector3((sizeL.x - sizeR.x) / 2, mpos.y, 0),
		{ duration = tweenDura })

	self.selectPos = nil
	focus_equip_pos()
	self.selectIdx = nil
	focus_equip_index()

	libunity.SetActive(Ref.btnHideList, false)
end

function on_btninventory_click(btn)
	self:close(true)
	ui.open("UI/WNDInventory")
end

function on_equip_click(btn)
	focus_equip_pos(btn)

	local tweenDura = 0.2
	local EquipList_go = Ref.SubEquipList.go
	local size = libugui.GetRectSize(EquipList_go)


	local prevPos = self.selectPos
	self.selectPos = Name2Index[btn.name]
	if prevPos == self.selectPos then return end

	libugui.KillTween(EquipList_go)

	local prevSide = pos2side(prevPos)
	local side = pos2side(self.selectPos)
	if prevSide ~= side then
		local LEFTContent_go = Ref.SubLEFT.SubContent.go
		local RIGHTContent_go = Ref.SubRIGHT.SubContent.go

		local Vector2, Vector3 = UE.Vector2, UE.Vector3
		local sizeL = libugui.GetRectSize(LEFTContent_go)
		local sizeR = libugui.GetRectSize(RIGHTContent_go)
		local offsetX = sizeL.x - sizeR.x
		local mpos = libugui.GetAnchoredPos(Ref.evtModel)

		if side == "LEFT" then
			libugui.KillTween(LEFTContent_go)
			libugui.SetAnchoredPos(RIGHTContent_go, 0)

			local pos = libugui.GetAnchoredPos(LEFTContent_go)
			local tarPos = Vector3(size.x, pos.y, pos.z)
			libugui.DOTween("Position", LEFTContent_go, pos, tarPos, { duration = tweenDura })

			libunity.SetParent(EquipList_go, Ref.SubLEFT.go, false, -1)
			libugui.AnchorPresets(EquipList_go, 0, 1, -size.x)
			libugui.DOTween("Position", EquipList_go, nil, Vector3.zero, { duration = tweenDura })

			libugui.DOTween("Position", Ref.evtModel, nil, Vector3((offsetX + size.x) / 2, mpos.y, 0),
				{ duration = tweenDura })
		else
			libugui.KillTween(RIGHTContent_go)
			libugui.SetAnchoredPos(LEFTContent_go, 0)

			local pos = libugui.GetAnchoredPos(RIGHTContent_go)
			local tarPos = Vector3(-size.x, pos.y, pos.z)
			libugui.DOTween("Position", RIGHTContent_go, pos, tarPos, { duration = tweenDura })

			libunity.SetParent(EquipList_go, Ref.SubRIGHT.go, false, -1)
			libugui.AnchorPresets(EquipList_go, 1, 1, size.x)
			libugui.DOTween("Position", EquipList_go, nil, Vector3.zero, { duration = tweenDura })

			libugui.DOTween("Position", Ref.evtModel, nil, Vector3((offsetX - size.x) / 2, mpos.y, 0),
				{ duration = tweenDura })
		end
	end

	libunity.SetEnable(GO(Ref.SubEquipList.go, nil, "Canvas"), true)
	libunity.SetActive(Ref.btnHideList, true)
	libugui.DOTween("Alpha", Ref.SubEquipList.go, 0, 1, { duration = 0.25 })
	rfsh_equip_list()
end

--填充展开列表
function on_equip_ent(go, i)
	i = i + 1
	ui.index(go, i)

	local Item = EquipList[i]
	local Ent = ui.ref(go)
	Item:show_view(Ent)

	local ItemBase = Item:get_base_data()
	local SubInfo = Ent.SubInfo
	SubInfo.lbName.text = cfgname(ItemBase)

	--只有装备显示评分
	if ItemBase.typeValue == 3 then
		libunity.SetActive(Ent.SubEquipScore.go, true)
		Ent.SubEquipScore.lbScore.text = ItemBase.score
	else
		libunity.SetActive(Ent.SubEquipScore.go, false)
	end

	ui.group(SubInfo.GrpAttrs)
	local Attr = Item:calc_attr()
	if Attr then
		local Keys = { "Damage", "def", "move", "fast" }
		show_attr_view(SubInfo.GrpAttrs, Attr, Keys, {
				sign = true,
				callback = function (i, Ent, attr, value)
					if value > 0 then
						libunity.SetActive(Ent.go, true)
						Ent.lbValue.color = "#91E619"
					elseif value < 0 then
						libunity.SetActive(Ent.go, true)
						Ent.lbValue.color = "#F05A50"
					else
						--隐藏属性为0的Item
						libunity.SetActive(Ent.go, false)
						Ent.lbValue.color = "#C5C5C5"
					end
				end,
			})
	else
		SubInfo.GrpAttrs:hide()
	end

	if selectIdx == i then
		focus_equip_index(go)
	else
		libugui.SetVisible(Ent.spSelected, false)
	end
end

function on_subequiplist_subview_grpequips_entequip_click(tgl)
	self.selectIdx = ui.index(tgl)
	focus_equip_index(tgl)
	rfsh_list_opbtn()

	local Item = EquipList[selectIdx]
	Item:play_drag()
end

function on_subequiplist_subop_btnuse_click(btn)
	NW.use_item(DY_DATA:iget_item(self.selectPos))
end

function on_subequiplist_subop_btnequip_click(btn)
	local Item = EquipList[selectIdx]
	NW.move_item(Item.pos, self.selectPos)
end

function on_subequiplist_subop_btnremove_click(btn)
	local pos = DY_DATA:get_empty_itempos(0, 0)
	if pos then
		NW.move_item(selectPos, pos)
	else
		UI.Toast.norm(TEXT.tipInventoryFull)
	end
end
--!* [结束] 自动生成函数  *--

function init_view()
	ui.group(Ref.SubLEFT.SubContent.GrpAttrs)
	--!* [结束] 自动生成代码 *--

	-- 补全装备栏
	local flex_itement = UTIL.flex_itement
	for _,v in pairs(Index2Name) do
		flex_itement(Ref.SubLEFT.SubContent.SubEquips, v)
		flex_itement(Ref.SubRIGHT.SubContent.SubWeapons, v)
		flex_itement(Ref.SubRIGHT.SubContent.SubPocket, v)
	end

	-- 补全装备列表栏
	local flex_itemgrp = UTIL.flex_itemgrp
	flex_itemgrp(Ref.SubEquipList.SubView.GrpEquips, 1, "Vertical", 0, 100, -50, 5)
end

function init_logic()
	CTRL.subscribe("DURA_CHANGED", rfsh_equip_dura)

	libgame.UnitStay(0, false)
	ui.moveout(Ref.spBack, 1)

	-- 窗口打开时，隐藏装备选择列表
	libunity.SetEnable(GO(Ref.SubEquipList.go, nil, "Canvas"), false)
	libunity.SetActive(Ref.btnHideList, false)
	libugui.SetVisible(Ref.SubEquipList.spSelected, false)
	libugui.SetVisible(Ref.spSelected, false)

	-- 初始化面板位置
	local LEFTContent_go = Ref.SubLEFT.SubContent.go
	local RIGHTContent_go = Ref.SubRIGHT.SubContent.go
	libugui.SetAnchoredPos(LEFTContent_go, 0)
	libugui.SetAnchoredPos(RIGHTContent_go, 0)
	local sizeL = libugui.GetRectSize(LEFTContent_go)
	local sizeR = libugui.GetRectSize(RIGHTContent_go)
	libugui.SetAnchoredPos(Ref.evtModel, (sizeL.x - sizeR.x) / 2)

	rfsh_role_view()
	rfsh_equips_view()
	rfsh_role_attrs()
	create_player_view()
end

function show_view()

end

function on_recycle()
	ui.putback(Ref.spBack, Ref.go)
	CTRL.unsubscribe("DURA_CHANGED", rfsh_equip_dura)

	ui.putback(Ref.spBack, Ref.go)
	libunity.SetParent(Ref.spSelected, Ref.go)
	libunity.SetParent(Ref.SubEquipList.spSelected, Ref.SubEquipList.go)
	libunity.SetParent(Ref.SubEquipList.go, Ref.go)

	if self.action == "pop" then
		self.selectPos = nil
	end

	libgame.Recycle(player and player.gameObject)
end


Handlers = {
	["PACKAGE.SC.ITEM_MOVE"] = on_item_changed,
	["PACKAGE.SC.ITEM_DEL"] = on_item_changed,
	["PACKAGE.SC.ITEM_USE"] = on_item_changed,
	["ROLE.SC.GET_ROLE_INFO"] = function ()
		rfsh_role_attrs()
	end,
	["PLAYER.SC.GET_ROLE_INFO"] = rfsh_role_view,
	["MAP.SC.SYNC_OBJ_SPEED"] = function (Unit)
		if Unit and Unit.id == DY_DATA.Self.id then
			next_action(Ref.go, rfsh_role_attrs)
		end
	end,
}

return self

