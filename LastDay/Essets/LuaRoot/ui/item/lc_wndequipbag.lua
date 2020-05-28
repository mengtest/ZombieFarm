--
-- @file    ui/item/lc_wndequipbag.lua
-- @author  xingweizhen
-- @date    2018-01-03 16:41:16
-- @desc    WNDEquipBag
--

local self = ui.new()
setfenv(1, self)

local Name2Index = {
	SubMajor = _G.CVar.EQUIP_MAJOR_POS,
	SubMinor = _G.CVar.EQUIP_MINOR_POS,
	SubHead = _G.CVar.EQUIP_HEAD_POS,
	SubBody = _G.CVar.EQUIP_BODY_POS,
	SubLeg = _G.CVar.EQUIP_LEG_POS,
	SubFoot = _G.CVar.EQUIP_FOOT_POS,
	SubLPocket = _G.CVar.EQUIP_LPOCKET_POS,
	SubRPocket = _G.CVar.EQUIP_RPOCKET_POS,
	SubBag = _G.CVar.EQUIP_BAG_POS,
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
local show_attr_view = UTIL.show_attr_view

local PlayerChange

function iget_entitem(index)
	return Ref.SubRole[Index2Name[index]]
end

local function rfsh_equips_view()
	for k,v in pairs(Index2Name) do
		local Item, Ent = DY_DATA:iget_item(k), Ref.SubRole[v]
		Primary.show_item_view(Item, Ent)
		Primary:show_cooldown(Item, Ent)
	end
end

local function rfsh_role_view()
	local Player = DY_DATA:get_player()
	local SubProfile = Ref.SubRole.SubProfile

	SubProfile.lbLevel.text = TEXT.fmtLevel:csfmt(Player.level)
	SubProfile.SubName.lbName.text = Player.name

	local SubLevel = SubProfile.SubLevel

	local Level = Player:get_level_data()
	if Level.maxExp > 0 then
		SubLevel.bar.value = Player.exp / Level.maxExp
		SubLevel.lbExp.text = string.format("%d/%d", Player.exp, Level.maxExp)
	else
		SubLevel.bar.value = 0
		SubLevel.lbExp.text = nil
	end
end

local function rfsh_role_attrs()
	local Obj = DY_DATA.Self
	local Attr = Obj:calc_attr()
	local Keys = { "Damage", "def", "move", "fast" }
	show_attr_view(Ref.SubRole.GrpAttrs, Attr, Keys)
end

local function rfsh_equip_dura(obj, Inf)
	if obj == DY_DATA.Self.id then
		local pos = Inf.pos
		local Item = DY_DATA:iget_item(pos)
		local entName = Index2Name[pos]
		Primary.show_item_view(Item, Ref.SubRole[entName])
	end
end

local function rfsh_weapon_cool(obj, Inf)
	if obj == CTRL.selfId then
		local function tween_cooldown(Sub, cooldown, cycle)
			if cooldown and cooldown > 0 then
				UTIL.tween_cooldown(Sub.spCd, cooldown, cycle)
			else
				libunity.SetActive(Sub.spCd, false)
			end
		end

		tween_cooldown(Ref.SubRole.SubMajor, Inf.majorCD, Inf.majorCycle)
		tween_cooldown(Ref.SubRole.SubMinor, Inf.minorCD, Inf.minorCycle)
	end
end

local function update_player_view(pose, Model, Affixes)
	if libunity.IsActive(player) then
		libgame.UpdateUnitView(player, pose, { model = Model, Affixes = Affixes })
	end
end

local function create_player_view()
	local Self = DY_DATA:get_self()
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

	libugui.Follow(player, Ref.SubRole.evtPlayer, 5)

	libunity.FaceCamera(player)
end

local function on_player_data_changed()
	if PlayerChange == nil then return end

	local Player = DY_DATA.Self
	local pose, Model
	local Affixes = {}
	if PlayerChange.major then
		local Weapon = Player:get_weapon()
		if Weapon then
			local WeaponBase = Weapon:get_base_data()
			pose = WeaponBase.wType
			table.insert(Affixes, Weapon:get_dress_data())
			table.insert(Affixes, { index = 3 - WeaponBase.affixIdx, path = "", })
		else
			pose = 0
			table.insert(Affixes, Player.EMPTY_RHAND)
			table.insert(Affixes, Player.EMPTY_LHAND)
		end
		next_action(Ref.go, rfsh_role_attrs)
	end

	if PlayerChange.bag then
		table.insert(Affixes, Player:update_view_affix(_G.CVar.EQUIP_TYPE2SLOT.BAG))
	end

	if PlayerChange.dress then
		Model = Player:get_view_dresses()
		next_action(Ref.go, rfsh_role_attrs)
	end

	if #Affixes == 0 then Affixes = nil end
	if PlayerChange.major or PlayerChange.bag or PlayerChange.dress then
		update_player_view(pose, Model, Affixes)
	end

	PlayerChange = nil
end

function item_dual_click(index)
	Primary:op_equip(index)
end

function equip_changed(SlotNames)
	if SlotNames.bag then
		if PlayerChange == nil then PlayerChange = {} end
		PlayerChange.bag = SlotNames.bag
		next_action(Ref.go, on_player_data_changed)
	end
end

local function highlight_slots(poslist)
	if poslist then
		self.HighlightSlots = poslist
		for i,v in ipairs(poslist) do
			local Ent = iget_entitem(v)
			if Ent then
				local spHigh = Ent.spHigh
				if spHigh == nil then
					libunity.NewChild(Ent.go, Ref.SubRole.spHigh)
				else
					libunity.SetActive(spHigh, true)
				end
			end
		end
	elseif self.HighlightSlots then
		for _,v in ipairs(self.HighlightSlots) do
			local Ent = iget_entitem(v)
			if Ent then libunity.SetActive(Ent.spHigh, false) end
		end
		self.HighlightSlots = nil
	end
end

function begindrag_item(evt)
	local index = Primary:ent2index(evt)
	local Item = DY_DATA:iget_item(index)
	local ItemBase = Item and Item:get_base_data()
	if not ItemBase then return end

	local slotIds = {}
	if ItemBase.mType == "EQUIP" then
		local sType = ItemBase.sType
		if sType == "WEAPON" then
			table.insert(slotIds,CVar.EQUIP_MAJOR_POS)
			table.insert(slotIds,CVar.EQUIP_MINOR_POS)
		else
			for k,v in pairs(CVar.EQUIP_POS2TYPE) do
				if v == sType then table.insert(slotIds, k) break end
			end
		end
	elseif ItemBase.mType == "PROP" then
		local sType = ItemBase.sType
		if sType == "USE" or sType == "THROW" then
			table.insert(slotIds,CVar.EQUIP_LPOCKET_POS)
			table.insert(slotIds,CVar.EQUIP_RPOCKET_POS)
		end
	end

	highlight_slots(slotIds)
end

function enddrag_item(evt)
	highlight_slots()
end

local function show_download_progress(progress)
	local SubDL = Ref.SubRole.SubDL
	SubDL.spFill.fillAmount = progress
	SubDL.lbOper.text = TEXT.downloading
	SubDL.lbProgress.text = string.format("%d%%", math.floor(progress * 100))
end

local function show_unpack_progress(progress)
	local SubDL = Ref.SubRole.SubDL
	SubDL.spFill.fillAmount = progress
	if progress < 1 then
		SubDL.lbOper.text = TEXT.unpacking
		SubDL.lbProgress.text = string.format("%d%%", math.floor(progress * 100))
	else
		libunity.SetActive(SubDL.go, false)
		PlayerChange = { major = true, dress = true, bag = true, }
		on_player_data_changed()
	end
end

local function on_unit_attr_changed(Unit)
	if Unit and Unit.id == DY_DATA.Self.id then
		next_action(Ref.go, rfsh_role_attrs)
	end
end

--!* [开始] 自动生成函数 *--

function on_subrole_evtplayer_drag(evt, data)
	local delta = data.delta
	local trans = player.transform
	local euler = trans.localEulerAngles
	euler.y = euler.y - delta.x
	trans.localEulerAngles = euler
end

function on_subrole_evtplayer_drop(evt, data)
	local Item = DY_DATA:iget_item(Primary.dragIdx)
	local dropIdx = Primary:item2equipidx(Item)
	if dropIdx then
		Primary:drop_slot(dropIdx)
	end
end

function on_item_selected(evt, data)
	Primary.on_item_selected(evt, data)
end

function on_begindrag_item(evt, data)
	Primary.on_begindrag_item(evt, data)
end

function on_drag_item(evt, data)
	Primary.on_drag_item(evt, data)
end

function on_enddrag_item(evt, data)
	Primary.on_enddrag_item(evt, data)
end

function on_drop_item(evt, data)
	Primary.on_drop_item(evt, data)
end

function on_item_pressed(evt, data)
	Primary.on_item_pressed(evt, data)
end

function on_item_dualclick(evt, data)
	-- 卸载装备
	local emptyIdx = DY_DATA:get_empty_itempos(0, 0)
	if emptyIdx then
		local index = Primary:ent2index(evt)
		NW.move_item(index, emptyIdx)
	end
end
--!* [结束] 自动生成函数  *--

function init_view()
	ui.group(Ref.SubRole.GrpAttrs)
	--!* [结束] 自动生成代码 *--

	self.Primary = Context.Primary
	self.Primary.Secondary = self


	local flex_itement = _G.PKG["ui/util"].flex_itement
	for k,v in pairs(Index2Name) do
		local Sub = flex_itement(Ref.SubRole, v)
		ui.index(Sub.go, k)
	end

	local show_item_view = Primary.show_item_view
	Primary.show_item_view = function (Item, Ent, defSprite, clip, forceShowAmount)
		if Ent and defSprite == nil then defSprite = DefIcons[ui.index(Ent.go)] end
		show_item_view(Item, Ent, defSprite, clip, forceShowAmount)
	end
	Ref.SubRole.lbUniqueId.text = DY_DATA:get_player().uniqueId

end

function init_logic()
	ui.moveout(Ref.spBack, 1)
	libgame.UnitStay(0, false)
	rfsh_role_view()
	rfsh_equips_view()
	rfsh_role_attrs()
	create_player_view()

	CTRL.subscribe("HEALTH_CHANGED", rfsh_role_hp)
	CTRL.subscribe("DURA_CHANGED", rfsh_equip_dura)
	CTRL.subscribe("SWAP_WEAPON", rfsh_weapon_cool)
	rfsh_weapon_cool(CTRL.selfId, libgame.GetHumanWeaponCooldown(0))

	libunity.SetActive(Ref.SubRole.spHigh, false)

	local World = DY_DATA.World
	libunity.SetActive(Ref.SubRole.SubDL.go, not World:has_bundle(CVar.HOME_ID))

	local dl, upk = SCENE.get_progress()
	if dl then
		show_download_progress(dl)
	elseif upk then
		show_unpack_progress(upk)
	end
end

function show_view()

end

function on_recycle()
	ui.putback(Ref.spBack, Ref.go)
	CTRL.unsubscribe("HEALTH_CHANGED", rfsh_role_hp)
	CTRL.unsubscribe("DURA_CHANGED", rfsh_equip_dura)
	CTRL.unsubscribe("SWAP_WEAPON", rfsh_weapon_cool)

	libgame.Recycle(player and player.gameObject)
end

Handlers = {
	["CLIENT.SC.EQUIP_CHANGED"] = function (pos)
		if PlayerChange == nil then PlayerChange = {} end

		local Item = DY_DATA:iget_item(pos)
		local name = CVar.EQUIP_POS2NAME[pos]
		PlayerChange[name] = Item and Item.amount or 0

		next_action(Ref.go, on_player_data_changed)
	end,

	["PACKAGE.SC.SYNC_PACKAGE"] = function (Package)
		if Package.obj == 0 and Package.bag == 1 then
			rfsh_equips_view()
		end
	end,
	["PACKAGE.SC.ITEM_USE"] = function (Items)
		Primary:show_cooldown(DY_DATA:iget_item(CVar.EQUIP_LPOCKET_POS), Ref.SubRole.SubLPocket)
		Primary:show_cooldown(DY_DATA:iget_item(CVar.EQUIP_RPOCKET_POS), Ref.SubRole.SubRPocket)
	end,
	["MAP.SC.SYNC_OBJ_SPEED"] = on_unit_attr_changed,
	["MAP.SC.SYNC_OBJ_ATT"] = on_unit_attr_changed,
	["ROLE.SC.GET_ROLE_INFO"] = function ()
		rfsh_role_attrs()
	end,
	["PLAYER.SC.GET_ROLE_INFO"] = rfsh_role_view,

	["CLIENT.SC.DOWNLOADING_ASSET"] = show_download_progress,
	["CLIENT.SC.UNPACKING_ASSET"] = show_unpack_progress,
}

return self

