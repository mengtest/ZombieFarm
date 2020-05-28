--
-- @file    ui/item/lc_wndworkbag.lua
-- @author  xingweizhen
-- @date    2018-01-03 18:51:09
-- @desc    WNDWorkBag
--

local self = ui.new()
setfenv(1, self)

local function get_slot_index()
	-- 第一个格子是燃料，最后一个格子是成品
	return CVar.gen_item_pos(Context.obj, 0, 1),
		CVar.gen_item_pos(Context.obj, 0, Context.cap)
end

local function get_select_formula(index)
	return config("workinglib").get_dat(Context.Data.Formulas[index])
end

function iget_entitem(index)
	local fuelIndex, produceIndex = get_slot_index()

	if index == fuelIndex then
		return Ref.SubWork.SubFuel
	elseif index == produceIndex then
		return Ref.SubWork.SubProcuct
	else
		return Ref.SubWork.GrpMats:find(index)
	end
end

local function clear_item_ent(i, Ent, isNew)
	Ent.spIcon:SetSprite("")
	Ent.lbAmount.text = nil
end

local function on_working_timer(tm)
	if  tm.param > 0 and tm.count <= tm.param then
		-- 燃料用完了
		tm.paused = true
	end

	local SubProcuct = Ref.SubWork.SubProcuct
	SubProcuct.barProc.value = tm.count / tm.cycle
	SubProcuct.lbTime.text = os.secs2time(nil, tm.count - 1)

	local SubHasten = Ref.SubWork.SubHasten
	local Produce = Context.Data.Produce
	local Formula = config("workinglib").get_dat(Produce.id)
	SubHasten.lbCost.text = math.ceil(tm.count * Formula.hastenCost / 60)
end

local function on_working_fin(tm)
	NW.op_produce(Context.obj, 0)
	return true
end

local function on_burning_timer(tm)
	local SubFuel = Ref.SubWork.SubFuel
	SubFuel.barProc.value = tm.count / tm.cycle
	SubFuel.lbTime.text = os.secs2time(nil, tm.count - 1)
end

local function on_burntime_fin(tm)
	local SubFuel = Ref.SubWork.SubFuel
	SubFuel.lbTime.text = nil

	NW.op_produce(Context.obj, 2)
	return true
end

local function active_formula_view(active)
	local SubFormulas = Ref.SubWork.SubFormulas
	libunity.SetActive(SubFormulas.GrpMats.go, active)
	libunity.SetActive(SubFormulas.SubTime.go, active)
	libugui.SetVisible(GO(SubFormulas.go, "lbTip_"), not active)
end

local function rfsh_formula_list()
	local ItemDEF = _G.DEF.Item
	local WorkingLIB = config("workinglib")
	local Formulas = Context.Data.Formulas
	Ref.SubWork.SubFormulas.SubScroll.SubView.GrpFormulas:dup(#Formulas, function (i, Ent, isNew)
		local Formula = WorkingLIB.get_dat(Formulas[i])
		local Product = Formula.Product
		local Item = ItemDEF.new(Product.id, Product.amount)
		Item:show_view(Ent)
	end)
end

local function rfsh_material_list(index)
	active_formula_view(true)

	local ItemDEF = _G.DEF.Item
	local Formula = get_select_formula(index)

	local SubFormulas = Ref.SubWork.SubFormulas
	local Mats = Formula.Mats
	SubFormulas.GrpMats:dup(#Mats, function (i, Ent, isNew)
		local Mat = Mats[i]
		ItemDEF.new(Mat.id, Mat.amount):show_view(Ent)
	end)

	SubFormulas.SubTime.lbTime.text = os.secs2time(nil, Formula.duration)
end

local function rfsh_package_view()
	local SubWork = Ref.SubWork
	local GrpMats = SubWork.GrpMats

	local fuelIndex, _ = get_slot_index()
	local maxMat = Context.cap - 2
	GrpMats:dup(4, function (i, Ent, isNew)
		libugui.SetInteractable(Ent.go, i <= maxMat)
		if i <= maxMat then
			local itemPos = fuelIndex + i
			GrpMats:setindex(Ent.go, itemPos)

			local Item = DY_DATA:iget_item(itemPos)
			Primary.show_item_view(Item, Ent)
		else
			Ent.spIcon:SetSprite("Common/ico_com_026")
			Ent.lbAmount.text = nil
			GrpMats:setindex(Ent.go, 0)
		end
	end)

	local hasFuel = #Context.Data.Fuels > 0
	libunity.SetActive(SubWork.SubFuel.go, hasFuel)
	if hasFuel then
		Primary.show_item_view(DY_DATA:iget_item(fuelIndex), SubWork.SubFuel)
	end
end

local function rfsh_working_view()
	local SubWork = Ref.SubWork
	local SubProcuct = SubWork.SubProcuct

	local _, produceIndex = get_slot_index()
	local ProductItem = DY_DATA:iget_item(produceIndex)

	local Produce = Context.Data.Produce
    local hasFuel = #Context.Data.Fuels > 0
	local working = Produce.working and Produce.id > 0
	libunity.SetActive(SubWork.SubHasten.go, working)
	if not working then
		SubProcuct.barProc.value = 0
		SubProcuct.lbTime.text = nil
		Primary.show_item_view(ProductItem, SubProcuct)

		DY_TIMER.stop_timer("WORKING")
	else
		local Formula = config("workinglib").get_dat(Produce.id)
		local timeLeft = Formula.duration - Produce.timeUsed + 1
		local timeFin = hasFuel and math.max(timeLeft - Produce.burnTimeLeft, 0) or 0

		local Item = ProductItem or _G.DEF.Item.create(produceIndex, Formula.Product.id, 0)
		Primary.show_item_view(Item, SubProcuct)

		local ownAmount = Item.amount or 0
		SubProcuct.lbAmount.text = string.format("%d(+%d)", ownAmount, Formula.Product.amount)

		local tm = DY_TIMER.replace_timer("WORKING", timeLeft, Formula.duration, on_working_fin)
		tm.param = timeFin
		tm:subscribe_counting(Ref.go, on_working_timer)
		on_working_timer(tm)
	end

	if Produce.burnTimeLeft > 0 then
		local tm = DY_TIMER.replace_timer("BURNING",
			Produce.burnTimeLeft + 1, Produce.maxBurnTime, on_burntime_fin)
		tm:subscribe_counting(Ref.go, on_burning_timer)
		on_burning_timer(tm)
	else
		SubWork.SubFuel.barProc.value = 0
		SubWork.SubFuel.lbTime.text = nil
		DY_TIMER.stop_timer("BURNING")
	end
end

function item_dual_click(index)

end

--!* [开始] 自动生成函数 *--

function on_subwork_subformulas_subscroll_subview_grpformulas_entformula_click(tgl)
	if tgl.value then
		rfsh_material_list(ui.index(tgl))
	end
end

function on_formula_pressed(evt, data)
	if data then
		local Formula = get_select_formula(ui.index(evt))
		local Product = Formula.Product
		local Item = _G.DEF.Item.new(Product.id, Product.amount)
		Item:show_tip(evt)
	else
		_G.DEF.Item.hide_tip()
	end
end

function on_mat_pressed(evt, data)
	if data then
		local tgl = libugui.GetTogglesOn(Ref.SubWork.SubFormulas.SubScroll.SubView.GrpFormulas.go)[1]
		if tgl then
			local Formula = get_select_formula(ui.index(tgl))
			local Mat = Formula.Mats[ui.index(evt)]
			local Item = _G.DEF.Item.new(Mat.id, Mat.amount)
			Item:show_tip(evt)
		end
	else
		_G.DEF.Item.hide_tip()
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

function on_subwork_subfuel_btninfo_click(btn)
	ui.show("UI/WNDFuelList", nil, Context.Data.Fuels)
end

function on_subwork_subhasten_click(btn)
	UI.MBox.consume(_G.DEF.Item.new(3, 100), "HastenWork", function ()
		NW.op_produce(Context.obj, 1)
	end)

end
--!* [结束] 自动生成函数  *--

function init_view()
	ui.group(Ref.SubWork.SubFormulas.SubScroll.SubView.GrpFormulas)
	ui.group(Ref.SubWork.SubFormulas.GrpMats)
	ui.group(Ref.SubWork.GrpMats)
	--!* [结束] 自动生成代码 *--

	local flex_itemgrp = _G.PKG["ui/util"].flex_itemgrp
	flex_itemgrp(Ref.SubWork.SubFormulas.SubScroll.SubView.GrpFormulas)
	flex_itemgrp(Ref.SubWork.SubFormulas.GrpMats)
	flex_itemgrp(Ref.SubWork.GrpMats)

	local flex_itement = _G.PKG["ui/util"].flex_itement
	flex_itement(Ref.SubWork, "SubProcuct")
end

function init_logic()
	self.Primary = Context.Primary
	self.Primary.Secondary = self

	active_formula_view(false)
	local Obj = CTRL.get_obj(Context.obj)
	local ObjBase = Obj:get_base_data()
	Ref.SubWork.lbTitle.text = ObjBase.name

	local fuelIndex, produceIndex = get_slot_index()
	ui.index(Ref.SubWork.SubFuel.go, fuelIndex)
	ui.index(Ref.SubWork.SubProcuct.go, produceIndex)

	rfsh_formula_list()
	rfsh_package_view()
	rfsh_working_view()
end

function show_view()

end

function on_recycle()
	libugui.AllTogglesOff(Ref.SubWork.SubFormulas.SubScroll.SubView.GrpFormulas.go)

	-- libgame.UnitBreak(0)
	-- NW.send(NW.gamemsg("PACKAGE.CS.PACKAGE_CLOSE"):writeU32(Context.obj))

	DY_TIMER.stop_timer("WORKING")
	DY_TIMER.stop_timer("BURNING")
end

Handlers = {
	["PRODUCE.SC.PRODUCEINFO"] = function (Ret)
		if Ret.Produce then
			Context.Data.Produce = Ret.Produce
			rfsh_working_view()
			if Ret.Produce.working then
				local Obj = CTRL.get_obj(Context.obj)
				local BuildTmpl = Obj:get_tmpl_data()
				local fmodRes = BuildTmpl.footstepSfx
				if #fmodRes ~= 0 then
					libunity.PlayAudio(BuildTmpl.footstepSfx)
				end
			end
		end
	end,

	["PACKAGE.SC.SYNC_PACKAGE"] = function (Package)
		if Package.obj == Context.obj then
			rfsh_package_view()
		end
	end,
}
return self

