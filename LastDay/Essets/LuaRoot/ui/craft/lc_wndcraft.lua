--
-- @file    ui/craft/lc_wndcraft.lua
-- @author  xingweizhen
-- @date    2018-01-20 11:32:57
-- @desc    WNDCraft
--

local self = ui.new()
setfenv(1, self)

self.StatusBar = {
	AssetBar = { "Gold", },
	HealthyBar = true,
	Menu = 2,
}

local CRAFT = _G.PKG["game/craftapi"]

-- 获取当前拥有的材料可制造道具的数量
local function get_item_count(id, Mats)
	local ItemCounts = table.need(self, "ItemCounts")
	local count = ItemCounts[id]
	if count == nil then
		count = math.maxinteger
		for _,v in ipairs(Mats) do
			local own = get_item_amount(v.id)

			count = math.min(count, math.floor(own / v.amount))
		end
		ItemCounts[id] = count
	end

	return count
end

local function get_selected_formula()
	return FormulaList[selectedIdx]
end

local function rfsh_frame()
	self.ItemCounts = nil
	libugui.SetLoopCap(Ref.SubScroll.SubView.GrpFormulas.go, #FormulaList, true)
end

local function rfsh_product_view(Formula)
	if Formula == nil then return end

	local SubProduct = Ref.SubProduct
	local Item = ItemDEF.gen(Formula.Item)
	Item:show_icon(SubProduct.SubNorm.spIcon)
	local ItemBase = Item:get_base_data()
	SubProduct.lbItem.text = cfgname(ItemBase)
	SubProduct.lbDesc.text = ItemBase.desc

	local SubCraft = SubProduct.SubCraft
	local formulaActivated = Formula.reqPlayerLevel <= DY_DATA:get_player().level

	local nMat = #Formula.Mats
	SubCraft.GrpMats:dup(6, function (i, Ent, isNew)
		if i > nMat then
			ui.seticon(Ent.spIcon, "Common/_null")
			libugui.SetColor(Ent.spIcon, "#000000")
			libugui.SetAlpha(Ent.spIcon,0.5)
			ui.seticon(Ent.spRarity, nil)
			Ent.lbAmount.text=""
		else
			local MatData = Formula.Mats[i]
			local Mat = ItemDEF.new(MatData.id, MatData.amount)
			Mat:show_view(Ent)
            Ent.lbAmount.text = string.own_needs(get_item_amount(Mat.dat), Mat.amount)

		end
	end)

	if formulaActivated then
		SubCraft.SubBtn.btn.interactable = get_item_count(Item.dat, Formula.Mats) > 0
		SubCraft.SubBtn.lbText.text = TEXT["v.craft"]
	else
		SubCraft.SubBtn.btn.interactable = false
		SubCraft.SubBtn.lbText.text = TEXT.fmtLevelReq:csfmt(Formula.reqPlayerLevel)
	end
end

local function rfsh_all_frame()
	rfsh_frame()
	rfsh_product_view(get_selected_formula())
end

local function late_rfsh_list()
	next_action(Ref.go, rfsh_frame)
end

local function late_rfsh_all()
	next_action(Ref.go, rfsh_all_frame)
end

local function focus_selected(go)
	local spSelected = Ref.SubScroll.spSelected
	libugui.SetVisible(spSelected, true)
	libunity.SetParent(spSelected, go, false, -1)
end

local function update_selected(index)
	self.selectedIdx = index
	rfsh_product_view(get_selected_formula())
end

local function rfsh_formulas_list(group)
	if group == 0 then group = nil end
	self.FormulaList = FormulaLIB.get_formula_list(group)

	local GrpFormulas = Ref.SubScroll.SubView.GrpFormulas
	libugui.SetLoopCap(GrpFormulas.go, #FormulaList, true)

	local scroll = Ref.SubScroll.go:GetComponent("ScrollRect")
	scroll.verticalNormalizedPosition = 1

	-- 延迟一帧更新
	libunity.Invoke(Ref.SubScroll.go, 0, function ()
		focus_selected(GrpFormulas:find(1).go)
		update_selected(1)
	end)
end


local function init_frame()
	local GrpTabs = Ref.GrpTabs
	local AllEnt = GrpTabs:gen(1)
	GrpTabs:setindex(AllEnt.go, 0)
	AllEnt.lbTab.text = TEXT.alltabs
	AllEnt.lbChkTab.text = TEXT.alltabs

	for i,v in FormulaLIB.groups() do
		local Ent, isNew = GrpTabs:gen(i+1)
		GrpTabs:setindex(Ent.go, i)
		Ent.lbTab.text = v.name
		Ent.lbChkTab.text = v.name
		libugui.SetAlpha(Ent.spTabBg, 0.5)
	end
	AllEnt.tgl.value = true
end

--!* [开始] 自动生成函数 *--

function on_subproduct_subcraft_grpmats_entmat_click(evt, data)
	local Formula = get_selected_formula()
	local matIdx = ui.index(evt)
	local Mat = Formula.Mats[matIdx]
	if Mat then ItemDEF.new(Mat.id):show_tip(evt) end
end

function on_subproduct_subcraft_grpmats_entmat_deselect(evt, data)
	_G.DEF.Item.hide_tip()
end

function on_subproduct_subcraft_subbtn_click(btn)
	local Formula = get_selected_formula()
	libugui.SetInteractable(Ref.go, false)
	local StatusWnd = ui.find("WNDTopBar")
	if StatusWnd then libugui.SetInteractable(StatusWnd.go, false) end

	libugui.DOTween(nil, Ref.SubProduct.SubCraft.SubBtn.bar, 0, 1, {
		duration = Formula.time,
		complete = function ()
			libugui.SetInteractable(Ref.go, true)
			if StatusWnd then libugui.SetInteractable(StatusWnd.go, true) end
			Ref.SubProduct.SubCraft.SubBtn.bar.value = 0
			NW.send(NW.gamemsg("PACKAGE.CS.ITEM_COMPOSE"):writeU32(Formula.id))
		end,
	})
end

function on_grpformula_ent(go, i)
	local n = i + 1
	ui.index(go, n)

	local Formula = FormulaList[n]
	local formulaActivated = Formula.reqPlayerLevel <= DY_DATA:get_player().level

	local Ent = ui.ref(go)

	local Item = ItemDEF.gen(Formula.Item)
	Item:show_icon(Ent.spIcon)
	Item:show_rarityIcon(Ent.spRarity)
	--Item:show_view(Ent)
	--if Item.amount == 1 then Ent.lbAmount.text = nil end

	local ItemBase = Item:get_base_data()
	Ent.lbName.text = ItemBase.name
	local count = get_item_count(Item.dat, Formula.Mats)
	libunity.SetActive(Ent.spCount, formulaActivated and count > 0)

	libunity.SetActive(Ent.spSuperior, ItemBase.isRefined)

	if selectedIdx == n then
		focus_selected(go)
	else
		libugui.SetVisible(Ent.spSelected, false)
	end

	libunity.SetActive(Ent.spLock, not formulaActivated)
	local craft_state = CRAFT.load(Formula.id)

	if formulaActivated then
		libunity.SetActive(Ent.spRedPoint, craft_state ~= nil)
	else
		if craft_state then
			CRAFT.save(Formula.id,nil)

			DY_DATA:get_player():check_newcraft_state()
		end
		libunity.SetActive(Ent.spRedPoint, false)
	end
end

function on_subscroll_subview_grpformulas_entformula_click(btn)
	focus_selected(btn)
	local index = ui.index(btn)
	if selectedIdx ~= index then
		update_selected(index)

		local Formula = get_selected_formula()
		local craft_state = CRAFT.load(Formula.id)
		if craft_state then
			CRAFT.save(Formula.id,nil)
		end

		DY_DATA:get_player():check_newcraft_state()
		libunity.SetActive(GO(btn, "spRedPoint"), false)
	end
end

function on_subscroll_subview_grpformulas_entformula_pressed(evt, data)
	if data then
		local Formula = FormulaList[ui.index(evt)]
		local Item = ItemDEF.gen(Formula.Item)
		Item:show_tip(evt, DY_DATA:get_self():get_equipped(Item))
	else
		ItemDEF.hide_tip()
	end
end

function on_grptabs_enttab_click(tgl)
	local value = tgl.value

	if value then
		libugui.SetAlpha(GO(tgl, "spTabBg"), 1)
		local index = Ref.GrpTabs:getindex(tgl)
		rfsh_formulas_list(index)
	else
		libugui.SetAlpha(GO(tgl, "spTabBg"), 0.5)
	end
end
--!* [结束] 自动生成函数  *--

function init_view()
	ui.group(Ref.SubProduct.SubCraft.GrpMats)
	ui.group(Ref.SubScroll.SubView.GrpFormulas)
	ui.group(Ref.GrpTabs)
	--!* [结束] 自动生成代码 *--

	local flex_itemgrp = _G.PKG["ui/util"].flex_itemgrp
	--flex_itemgrp(Ref.SubScroll.SubView.GrpFormulas, 0, "None", 0.5, 120, 120)
	flex_itemgrp(Ref.SubProduct.SubCraft.GrpMats)

	self.ItemDEF = _G.DEF.Item
	self.FormulaLIB = config("formulalib")

	self.get_item_amount = DY_DATA.item_counter()
end

function init_logic()
	libgame.UnitStay(0, false)

	libugui.SetVisible(Ref.SubScroll.spSelected, false)
	Ref.SubProduct.SubCraft.SubBtn.bar.value = 0

	init_frame()
end

function show_view()

end

function on_recycle()
	libunity.SetParent(Ref.SubScroll.spSelected, Ref.SubScroll.go)
	libugui.AllTogglesOff(Ref.GrpTabs.go)
end

Handlers = {
	["CLIENT.SC.TOPBAR_SWITCH"] = function (Wnd)
		if Wnd == self then
			late_rfsh_all()
		end
	end,
	["PACKAGE.SC.ITEM_COMPOSE"] = function (Items)
		if Items then
			late_rfsh_all()

			local Formula = get_selected_formula()
			local Item = Formula.Item
			local ItemBase = config("itemlib").get_dat(Item.id)
			UI.Toast.norm(TEXT.fmtObtainItem:csfmt(Item.amount, ItemBase.name))
		end
	end,
	["PACKAGE.SC.ITEM_DEL"] = late_rfsh_list,
	["PACKAGE.SC.ITEM_USE"] = late_rfsh_list,
	["PACKAGE.SC.SYNC_ITEM"] = late_rfsh_all,
	["PACKAGE.SC.PACKAGE_INTO"] = late_rfsh_list,
	["PACKAGE.SC.PACKAGE_PICKUP"] = late_rfsh_list,
	["PACKAGE.SC.SYNC_PACKAGE"] = late_rfsh_list,
	["PACKAGE.SC.SYNC_ITEM_STAT"] = late_rfsh_all,
}

return self

