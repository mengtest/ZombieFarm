--
-- @file    ui/item/lc_wndworkbag_new.lua
-- @author  shenbingkang
-- @date    2018-07-25 14:30:53
-- @desc    WNDWorkBag
--

local self = ui.new()
local _ENV = self

local WorkingLIB = config("workinglib")
local ItemLIB = config("itemlib")

local EWorkingBagType = {
	["1"] = "Normal",	-- 家里的加工台
	["2"] = "Guild", -- 公会加工台
}

self.StatusBar = {
	AssetBar = true,
	HealthyBar = true,
}

local function get_slot_index()
	-- 倒数第二个格子是燃料，最后一个格子是成品
	return CVar.gen_item_pos(Context.obj, 0, Context.cap - 1),
		CVar.gen_item_pos(Context.obj, 0, Context.cap)
end

--获取格子内的材料数量
local function get_material_cnt_incell(itemId)
	for i=1,Context.cap,1 do
		local pos = CVar.gen_item_pos(Context.obj, 0, i)
		local _item = DY_DATA:iget_item(pos)
		if _item and _item.dat == itemId then
			return _item.amount
		end
	end
	return 0
end

-- 获取填充数量 ( 需要数量/拥有数量 )
local function generate_item_cnt_str(needCnt, maxCnt)
	return string.own_needs(maxCnt, needCnt)
end

local function get_select_formula(index)
	return WorkingLIB.get_dat(self.Formulas[index])
end

local function forceUpdateFormulaSelected(go)
	libunity.SetParent(self.spFormulaSelected, go, false, -1)
	libunity.SetActive(self.spFormulaSelected, true)
end

local function forceUpdateFuelSelected(go)
	libunity.SetParent(self.spFuelSelected, go, false, -1)
	libunity.SetActive(self.spFuelSelected, true)
end

local function on_working_timer(tm)
	if tm.param > 0 and tm.count <= tm.param then
		-- 燃料用完了
		tm.paused = true
	end

	if self.FormulaUnitDict == nil then
		return
	end

	local SubProduct = Ref.SubWork.SubFormulaInfo.SubProduct
	SubProduct.SubProductItem.spProc.fillAmount = 1 - (tm.count / tm.cycle)
	--SubProduct.SubProductItem.lbProc.text = os.secs2time(nil, tm.count)

	local SubWorking = Ref.SubWork.SubWorking
	local SubHasten = Ref.SubWork.SubOprs.SubHasten

	local Produce = Context.Data.Produce
	local lastTime = Produce.lastTime - 1
	Produce.lastTime = lastTime >= 0 and lastTime or 0
	Produce.workedTime = Produce.workedTime + 1

	local Formula = WorkingLIB.get_dat(Produce.id)
	self.HastenCost = math.ceil(Produce.lastTime * Formula.hastenCost / 60)
	SubHasten.lbCost.text = self.HastenCost
	libunity.SetActive(Ref.SubWork.spTimecount, true)
	Ref.SubWork.lbWaitTime.text = os.secs2time(nil, Produce.lastTime)

	local FormulaEnt = self.FormulaUnitDict[Produce.id]
	if FormulaEnt then
		local proc = Produce.workedTime / (Produce.workedTime + Produce.lastTime)
		FormulaEnt.spProc.fillAmount = proc
	end
end

local function on_working_fin(tm)
	NW.op_produce(Context.obj, 0)
	return true
end

local function on_burning_timer(tm)
	local SubFuel = Ref.SubWork.SubFormulaInfo.SubFuel
	SubFuel.SubFuelItem.barProc.value = tm.count / tm.cycle

	local Produce = Context.Data.Produce
	Produce.burnTimeLeft = Produce.burnTimeLeft - 1

	--SubFuel.lbTime.text = os.secs2time(nil, tm.count - 1)--不需要显示燃料时间
end

local function on_burntime_fin(tm)
	local SubFuel = Ref.SubWork.SubFormulaInfo.SubFuel
	SubFuel.SubFuelItem.barProc.value = 0

	NW.op_produce(Context.obj, 2)
	return true
end

local function on_guild_working_timer(tm)
	local SubProduct = Ref.SubWork.SubFormulaInfo.SubProduct
	SubProduct.SubProductItem.spProc.fillAmount = 1 - (tm.count / tm.cycle)
	--SubProduct.SubProductItem.lbProc.text = os.secs2time(nil, tm.count)

	local SubWorking = Ref.SubWork.SubWorking
	local SubHasten = Ref.SubWork.SubOprs.SubHasten

	local ownAmount = self.ProduceCache[1] and self.ProduceCache[1].amount or 0
	local usedTime = ownAmount * editInfo.formula.duration + tm.cycle - tm.count
	local totalTime = (self.GuildWorkingCnt + ownAmount) * editInfo.formula.duration

	local FormulaEnt = self.FormulaUnitDict[self.GuildWorkingFormulaId]

	if FormulaEnt then
		local proc = usedTime / totalTime
		FormulaEnt.spProc.fillAmount = proc
	end

	libunity.SetActive(Ref.SubWork.spTimecount, true)
	Ref.SubWork.lbWaitTime.text = os.secs2time(nil, (totalTime - usedTime))
end

local function on_guild_working_fin(tm)
	if self.GuildWorkingCnt > 0 then
		NW.GUILD.RequestGuildProduce(Context.obj, 2, self.GuildWorkingFormulaId)
	end
	return true
end


--方法替换为get_item_amount
local function get_item_cnt(itemId)
	-- if Context.totalCntDict then
	-- 	return Context.totalCntDict[itemId] or 0
	-- else
	-- 	return DY_DATA:nget_item(itemId)
	-- end
	return get_item_amount(itemId)
end

--计算最多还能生产多少产品
local function calc_max_make_cnt(Formula, FuelInfo)

	if Formula == nil then
		return 0
	end

	local OwnProductCnt = 0
	if self.workingBagType == "Normal" then
		local fuelIndex, produceIndex = get_slot_index()
		local OwnProductItem = DY_DATA:iget_item(produceIndex)
		OwnProductCnt = OwnProductItem and OwnProductItem.amount or 0
	end

	local Mats = Formula.Mats

	local fuelId
	local perfCnt = 0
	local fCnt = -1
	if FuelInfo then
		fuelId = FuelInfo.id
		perfCnt = Formula.duration / FuelInfo.burnTime
	end

	local Product = Formula.Product
	local ProductItem = ItemDEF.new(Product.id, Product.amount)
	local cnt = ProductItem:get_base_data().nStack - OwnProductCnt
	if cnt == 0 then
		return 0
	end

	for _,v in pairs(Mats) do
		local matOwnCnt = get_item_cnt(v.id)
		if fuelId == v.id then
			fCnt = (matOwnCnt / (v.amount + perfCnt)) * perfCnt
			fCnt = math.floor(fCnt)
		end

		local MatItem = ItemDEF.new(v.id, 1)
		-- 生产设备允许原材料超过堆叠上限
		--matOwnCnt = math.min(MatItem:get_base_data().nStack, matOwnCnt)
		local canCreate = math.floor(matOwnCnt / v.amount)
		cnt = math.min(cnt, canCreate)
		if cnt == 0 then
			return 0
		end
	end

	return cnt, fCnt
end

--计算最大燃料装填数、最多能制作的数量
local function calc_max_fuel_cnt(fuelInfo, formula, matMaxCnt, fCnt)
	local FuelItem = ItemDEF.new(fuelInfo.id, 1)
	-- 生产设备允许燃料超过堆叠上限
	--local fuelCnt = math.min(FuelItem:get_base_data().nStack, get_item_cnt(fuelInfo.id))
	local fuelCnt = get_item_cnt(fuelInfo.id)
	if fCnt >= 0 then
		fuelCnt = math.min(fCnt, fuelCnt)
	end
	local fireTime = fuelCnt * fuelInfo.burnTime
	local fuelCanMakeCnt = math.floor(fireTime / formula.duration)

	return fuelCnt, fuelCanMakeCnt
end

-- 计算生产n个产品需要多少燃料、拥有的燃料数量
local function calc_need_fuel_cnt(fuelInfo, formula, productCnt)
	local needFuelCnt = 0
	local fuelCnt = get_item_cnt(fuelInfo.id)

	local needTotalTime = formula.duration * productCnt
	needFuelCnt = math.ceil(needTotalTime / fuelInfo.burnTime)

	return needFuelCnt, fuelCnt
end

local function rfsh_exhibit_product_icon()
	local ProductItem = nil
	local working = false

	if self.workingBagType == "Normal" then
		local fuelIndex, produceIndex = get_slot_index()
		ProductItem = DY_DATA:iget_item(produceIndex)
		local Produce = Context.Data.Produce
		working = Produce.working and Produce.id > 0
	elseif self.workingBagType == "Guild" then
		working = self.GuildWorkingCnt > 0
		ProductItem = self.ProduceCache[1] or nil
	end

	if not working and ProductItem == nil then
		local SelectedFormula = get_select_formula(self.SelectedFormulaIndex)
		if SelectedFormula then
			local Product = SelectedFormula.Product
			local ProductItem = ItemDEF.new(Product.id, Product.amount)
			local productBase = ProductItem:get_base_data()

			local SubProductItem = Ref.SubWork.SubFormulaInfo.SubProduct.SubProductItem
			--ui.seticon(SubProductItem.spIcon, productBase.icon)

			ProductItem:show_icon(SubProductItem.spIcon)
			ProductItem:show_rarityIcon(SubProductItem.spRarity)

			libugui.SetAlpha(SubProductItem.spIcon, 0.5)
			self.ProductItemInfo = ProductItem
		end
	end
end

-- 刷新普通工作台成品面板
local function rfsh_normal_product_view()
	local SubProduct = Ref.SubWork.SubFormulaInfo.SubProduct
	local SubProductItem = SubProduct.SubProductItem
	local SubWorking = Ref.SubWork.SubWorking

	local fuelIndex, produceIndex = get_slot_index()
	local ProductItem = DY_DATA:iget_item(produceIndex)
	self.ProductItemInfo = ProductItem
	local Produce = Context.Data.Produce
	local Formula = WorkingLIB.get_dat(Produce.id)

	local productBase
	if ProductItem then
		productBase = ProductItem:get_base_data()
		ui.seticon(SubProductItem.spIcon, productBase.icon)
	else
		ui.seticon(SubProductItem.spIcon, nil)
	end
	local ownAmount = ProductItem and ProductItem.amount or 0
	--SubProduct.lbDoneCnt.text = string.format(TEXT.DoneCount, ownAmount)
	libunity.SetActive(Ref.SubWork.SubOprs.btnTakeAll, ownAmount > 0)

	local working = Produce.working and Produce.id > 0

	local SubOprs = Ref.SubWork.SubOprs
	libunity.SetActive(SubOprs.SubHasten.go, working)

	if not working then
		libunity.SetActive(SubOprs.btnCancelWork, false)
		if ProductItem then
			libunity.SetActive(Ref.SubWork.spWorkNotice, true)
			libunity.SetActive(Ref.SubWork.spTimecount, false)
			Ref.SubWork.lbWorkNotice.text = TEXT.Processing_WorkComplete
			libunity.SetActive(SubWorking.go, false)
			libunity.SetActive(SubOprs.btnEditCnt, false)
		else
			libunity.SetActive(Ref.SubWork.spWorkNotice, false)
			libunity.SetActive(Ref.SubWork.spTimecount, false)
			Ref.SubWork.lbWorkNotice.text = nil
			libunity.SetActive(SubWorking.go, true)
			libunity.SetActive(SubOprs.btnEditCnt, true)
		end
		SubProductItem.spProc.fillAmount = 0
		--SubProductItem.lbProc.text = nil
		SubProductItem.lbProc.text = ownAmount > 0 and ownAmount or nil
		--SubProduct.lbLastCnt.text = nil

		rfsh_exhibit_product_icon()

		DY_TIMER.stop_timer("WORKING")
		DY_TIMER.stop_timer("BURNING")
	else
		if ProductItem == nil then
			local Product = Formula.Product
			ProductItem = ItemDEF.new(Product.id, 0)
			productBase = ProductItem:get_base_data()
			ui.seticon(SubProductItem.spIcon, productBase.icon)
			self.ProductItemInfo = ProductItem
		end

		libunity.SetActive(SubOprs.btnCancelWork, true)
		libunity.SetActive(SubOprs.btnEditCnt, false)
		libunity.SetActive(Ref.SubWork.spWorkNotice, true)
		libunity.SetActive(Ref.SubWork.spTimecount, true)
		Ref.SubWork.lbWorkNotice.text = TEXT.Processing_Working:csfmt(productBase.name)
		libunity.SetActive(SubWorking.go, false)

		local timeLeft = Formula.duration - Produce.timeUsed
		local timeFin = hasFuel and math.max(timeLeft - Produce.burnTimeLeft, 0) or 0

		local lastAmount = math.ceil(Produce.lastTime / Formula.duration)
		SubProductItem.lbProc.text = string.format("%d/%d", ownAmount, (ownAmount + lastAmount))
		--SubProduct.lbLastCnt.text = string.format(TEXT.LastCount, lastAmount)

		local tm = DY_TIMER.replace_timer("WORKING", timeLeft, Formula.duration, on_working_fin)
		tm.param = timeFin
		tm:subscribe_counting(Ref.go, on_working_timer)
		on_working_timer(tm)
	end
end

-- 刷新公会加工成品面板
local function rfsh_guild_produce_view()
	local SubOprs = Ref.SubWork.SubOprs
	libunity.SetActive(SubOprs.SubHasten.go, false)
	libunity.SetActive(SubOprs.btnTakeAll, false)

	local SubProduct = Ref.SubWork.SubFormulaInfo.SubProduct
	local SubProductItem = SubProduct.SubProductItem
	local SubWorking = Ref.SubWork.SubWorking

	local Formula = WorkingLIB.get_dat(self.GuildWorkingFormulaId)
	local Produce = Formula and Formula.Product or nil
	self.ProductItemInfo = nil

	if Produce then
		local ProductItem = ItemDEF.new(Produce.id, 0)
		self.ProductItemInfo = ProductItem
		local productBase = ProductItem:get_base_data()
		ui.seticon(SubProductItem.spIcon, productBase.icon)
	else
		--ui.seticon(SubProductItem.spIcon, nil)
		rfsh_exhibit_product_icon()
	end
	local ownAmount = self.ProduceCache[1] and self.ProduceCache[1].amount or 0

	if self.GuildWorkingCnt > 0 then
		if ProductItem == nil then
			local Product = Formula.Product
			ProductItem = ItemDEF.new(Product.id, 0)
			self.ProductItemInfo = ProductItem
			productBase = ProductItem:get_base_data()
			ui.seticon(SubProductItem.spIcon, productBase.icon)
		end

		libunity.SetActive(SubOprs.btnCancelWork, true)
		libunity.SetActive(SubOprs.btnEditCnt, false)

		libunity.SetActive(Ref.SubWork.spWorkNotice, true)
		libunity.SetActive(Ref.SubWork.spTimecount, true)
		Ref.SubWork.lbWorkNotice.text = TEXT.Processing_Working:csfmt(productBase.name)

		libunity.SetActive(SubWorking.go, false)

		--SubProduct.lbLastCnt.text = string.format(TEXT.LastCount, self.GuildWorkingCnt)
		--SubProduct.lbDoneCnt.text = string.format(TEXT.DoneCount, ownAmount)
		SubProductItem.lbProc.text = string.format("%d/%d", ownAmount, (ownAmount + self.GuildWorkingCnt))

		local tm = DY_TIMER.replace_timer("WORKING", Formula.duration, Formula.duration, on_guild_working_fin)
		tm:subscribe_counting(Ref.go, on_guild_working_timer)
		on_guild_working_timer(tm)
	else
		libunity.SetActive(SubOprs.btnCancelWork, false)

		libunity.SetActive(Ref.SubWork.spWorkNotice, false)
		libunity.SetActive(Ref.SubWork.spTimecount, false)
		Ref.SubWork.lbWorkNotice.text = nil

		libunity.SetActive(SubWorking.go, true)
		libunity.SetActive(SubOprs.btnEditCnt, true)

		--ui.seticon(SubProductItem.spIcon, nil)
		SubProductItem.spProc.fillAmount = 0
		SubProductItem.lbProc.text = nil
		--.lbLastCnt.text = nil
		--SubProduct.lbDoneCnt.text = nil

		DY_TIMER.stop_timer("WORKING")
	end
end

--刷新成品面板
local function rfsh_product_view()
	local SubProductItem = Ref.SubWork.SubFormulaInfo.SubProduct.SubProductItem
	libugui.SetAlpha(SubProductItem.spIcon, 1)
	if self.workingBagType == "Normal" then
		rfsh_normal_product_view()
	elseif self.workingBagType == "Guild" then
		rfsh_guild_produce_view()
	end
end

local function rfsh_cost_guild_energy_view()
	local needAssets = editInfo.formula and editInfo.formula.fictitiousAssets[1]
	local energyStr

	if needAssets and needAssets.id == CVar.ASSET_TYPE.GuildEnergy then
		local needCost = editInfo.curSelectCnt == 0 and needAssets.amount or (needAssets.amount * editInfo.curSelectCnt)
		energyStr = string.format(TEXT.fmtCnt_Adequate, needCost, self.Energy)
	else
		energyStr = self.Energy
	end

	local SubFuel = Ref.SubWork.SubFormulaInfo.SubFuel
	SubFuel.lbAmount.text = TEXT.GuildEnergyValue:csfmt(energyStr)
end

--刷新燃料面板
local function rfsh_fuel_list(productCnt)
	local Fuels = self.Fuels

	local SubFuel = Ref.SubWork.SubFormulaInfo.SubFuel

	-----------
	-- 生产设备只有一个燃料，并且不需要选择
	-- SubFuel.SubScroll.GrpFuel:dup(#Fuels, function (i, Ent, isNew)
	-- 	local Fuel = Fuels[i]
	-- 	local cnt = get_item_cnt(Fuel.id)
	-- 	local Item = ItemDEF.new(Fuel.id, cnt)
	-- 	UTIL.flex_itement(Ent, "SubItem", 0)
	-- 	show_item_view(Item, Ent.SubItem)

	-- 	if self.selectFuelIndex == i then
	-- 		forceUpdateFuelSelected(Ent.go)
	-- 	else
	-- 		libunity.SetActive(Ent.spSelected, false)
	-- 	end

	-- 	libugui.SetInteractable(Ent.go, cnt > 0)
	-- end)
	-----------

	if hasFuel then
		libunity.SetActive(SubFuel.go, true)

		local Produce = Context.Data.Produce
		local working = Produce.working and Produce.id > 0
		local fuelIndex, produceIndex = get_slot_index()
		local FuelItem = DY_DATA:iget_item(fuelIndex)

		-------------------------
		-- 常显示该设备需要的燃料
		local fuelInfo = Fuels[self.selectFuelIndex]
		self.FuelItemInfo = ItemDEF.new(fuelInfo.id, 1)
		local fuelBase = self.FuelItemInfo:get_base_data()
		ui.seticon(SubFuel.SubFuelItem.spIcon, fuelBase.icon)

		SubFuel.lbNotice.text = nil
		ui.seticon(SubFuel.SubFuelItem.spFuelBG, "Building/ico_pro_03")

		if working then
			local fuelCnt = FuelItem and FuelItem.amount or 0
			SubFuel.SubFuelItem.lbAmount.text = fuelCnt
			libugui.SetColor(SubFuel.SubFuelItem.go, "#FFFFFF")
		else
			if productCnt == nil or productCnt == 0 then
				productCnt = 1
			end
			local Formula = get_select_formula(self.SelectedFormulaIndex)
			local needFuelCnt, fuelCnt = calc_need_fuel_cnt(fuelInfo, Formula, productCnt)
			SubFuel.SubFuelItem.lbAmount.text = generate_item_cnt_str(needFuelCnt, fuelCnt)

			local color = needFuelCnt > fuelCnt and "#F27B60" or "#FFFFFF"
			libugui.SetColor(SubFuel.SubFuelItem.go, color)
			SubFuel.SubFuelItem.barProc.value = 0
		end

		if working then
			if Produce.burnTimeLeft == 0 then
				on_burntime_fin()
			end
			local tm = DY_TIMER.replace_timer("BURNING",
				Produce.burnTimeLeft, Produce.maxBurnTime, on_burntime_fin)
			tm:subscribe_counting(Ref.go, on_burning_timer)
			on_burning_timer(tm)
		else
			SubFuel.SubFuelItem.barProc.value = Produce.burnTimeLeft / Produce.maxBurnTime
			DY_TIMER.stop_timer("BURNING")
		end
	else
		if self.workingBagType == "Guild" then
			self.FuelItemInfo = ItemDEF.new(CVar.ASSET_TYPE.GuildEnergy, 1)
			local guildEnergyBase = self.FuelItemInfo:get_base_data()
			ui.seticon(SubFuel.SubFuelItem.spIcon, guildEnergyBase.icon)
			libunity.SetActive(SubFuel.go, true)
			ui.seticon(SubFuel.SubFuelItem.spFuelBG, "Building/ico_pro_05")
			rfsh_cost_guild_energy_view()
		else
			libunity.SetActive(SubFuel.go, false)
			SubFuel.lbNotice.text = TEXT.NoFuelRequired
			SubFuel.SubFuelItem.lbAmount.text = nil
		end
		SubFuel.SubFuelItem.barProc.value = 0
		ui.seticon(SubFuel.SubFuelItem.spIcon, nil)
		Ref.SubWork.SubWorking.SubProc.spFuel.fillAmount = 1
	end
end

--刷新配方列表
local function rfsh_material_list(formulaIndex, productCnt)
	if formulaIndex == nil then
		formulaIndex = self.SelectedFormulaIndex
	end

	if productCnt == nil or productCnt == 0 then
		productCnt = 1
	end

	local Formula = get_select_formula(formulaIndex)

	local working = false
	if self.workingBagType == "Normal" then
		local Produce = Context.Data.Produce
		working = Produce.working and Produce.id == Formula.id
	end

	local GrpMats = Ref.SubWork.SubFormulaInfo.SubMats.GrpMats
	local Mats = Formula and Formula.Mats or {}
	GrpMats:dup(4 , function (i, Ent, isNew)
		local Mat = Mats[i]
		if Mat then
			libunity.SetActive(Ent.spBlack, false)
			local cnt = get_item_cnt(Mat.id)
			local Item = ItemDEF.new(Mat.id, 1)
			UTIL.flex_itement(Ent, "SubItem", 0)
			local ItemBase = Item:get_base_data()
			show_item_view(Item, Ent.SubItem)
			if working then
				Ent.SubItem.lbAmount.text = get_material_cnt_incell(Mat.id)
			else
				local matNeedCnt = productCnt * Mat.amount
				Ent.SubItem.lbAmount.text = generate_item_cnt_str(matNeedCnt, cnt)
			end
		else
			libunity.SetActive(Ent.spBlack, true)
			UTIL.flex_itement(Ent, "SubItem", 0)
			show_item_view(nil, Ent.SubItem)
		end
	end)
end

--处理选择数量显示
local function rfsh_edit_cnt_view(barValue)
	if barValue == nil then
		barValue = Ref.SubWork.SubWorking.SubProc.bar.value
	end
	local SubEditCnt = Ref.SubWork.SubFormulaInfo.SubEditCnt

	editInfo.curSelectCnt = barValue--math.floor(barValue * editInfo.matMaxCnt + 0.5)
	editInfo.totalDuraTime = editInfo.formula and editInfo.curSelectCnt * editInfo.formula.duration or 0

	Ref.SubWork.SubWorking.SubProc.lbSelectedCnt.text = string.format("%d", editInfo.curSelectCnt)
	local btnEditCnt = Ref.SubWork.SubOprs.btnEditCnt
	local canClickEdit = (not hasFuel) or editInfo.matMaxCnt <= 0 or ((barValue / editInfo.matMaxCnt) <= editInfo.fuelFillAmount)
	libugui.SetInteractable(btnEditCnt, canClickEdit and (editInfo.curSelectCnt > 0))

	local lbEdit = GO(btnEditCnt, "&lbText")
	libugui.SetColor(lbEdit, canClickEdit and "#c5c5c5" or "#FF0000")
	local editStr = editInfo.curSelectCnt == 0 and TEXT.canEditText or TEXT.BeginWork
	libugui.SetText(lbEdit, canClickEdit and editStr or TEXT.fuelNotEnoughText)

	rfsh_material_list(nil, editInfo.curSelectCnt)
	rfsh_fuel_list(editInfo.curSelectCnt)

	if self.workingBagType == "Guild" then
		rfsh_cost_guild_energy_view()
	end
end

--刷新选择数量面板
local function rfsh_max_editcnt_view()
	local SubWorking = Ref.SubWork.SubWorking

	self.editInfo = { curSelectCnt = self.editInfo and self.editInfo.curSelectCnt}

	local Fuels = self.Fuels
	local fuelInfo = Fuels[self.selectFuelIndex]

	--刷新材料支持的最大数量
	editInfo.formula = get_select_formula(self.SelectedFormulaIndex)
	local fCnt
	editInfo.matMaxCnt, fCnt = calc_max_make_cnt(editInfo.formula, fuelInfo)
	SubWorking.lbMax.text = editInfo.matMaxCnt

	--刷新燃料支持的最大数量
	editInfo.fuelId = 0
	editInfo.fuelFillAmount = 0

	if fuelInfo and editInfo.matMaxCnt > 0 then
		editInfo.fuelId = fuelInfo.id
		local needFuelCnt, fuelMaxCnt = calc_max_fuel_cnt(fuelInfo, editInfo.formula, editInfo.matMaxCnt, fCnt)
		editInfo.fuelFillAmount = fuelMaxCnt / editInfo.matMaxCnt
		SubWorking.SubProc.spFuel.fillAmount = editInfo.fuelFillAmount
	else
		SubWorking.SubProc.spFuel.fillAmount = hasFuel and 0 or 1
	end

	SubWorking.SubProc.bar.value = 0
	SubWorking.SubProc.bar.maxValue = editInfo.matMaxCnt

	rfsh_edit_cnt_view()
end

--刷新配方内容
local function rfsh_formula_detail_info(formulaIndex)
	if formulaIndex then
		self.SelectedFormulaIndex = formulaIndex
	else
		formulaIndex = self.SelectedFormulaIndex
	end

	if productCnt == nil or productCnt == 0 then
		productCnt = 1
	end

	local unit = Ref.SubWork.SubFormulaList.SubScroll.GrpFormulaList:get(formulaIndex)
	if unit then
		forceUpdateFormulaSelected(unit.go)
	end

	rfsh_material_list(formulaIndex)

	rfsh_max_editcnt_view()

	Ref.SubWork.SubWorking.SubProc.bar.value = 0
	rfsh_edit_cnt_view()

	rfsh_exhibit_product_icon()
end

--刷新配方列表
local function rfsh_formula_list()
	local Formulas = self.Formulas
	self.FormulaUnitDict = {}
	Ref.SubWork.SubFormulaList.SubScroll.GrpFormulaList:dup(#Formulas, function (i, Ent, isNew)
		--UTIL.flex_itement(Ent, "SubItem", 0)
		--libugui.SetVisible(Ent.SubItem.lbAmount, false)

		local Formula = WorkingLIB.get_dat(Formulas[i])
		local Product = Formula.Product
		local Item = ItemDEF.new(Product.id, Product.amount)

		local ItemBase = Item:get_base_data()
		show_item_view(Item, Ent)

		Ent.lbName.text = ItemBase.name
		Ent.lbTime.text = os.secs2time(nil, Formula.duration)

		local maxCnt,_ = calc_max_make_cnt(Formula)
		Ent.lbMax.text = maxCnt
		Ent.spProc.fillAmount = 0

		self.FormulaUnitDict[Formulas[i]] = Ent

		if self.SelectedFormulaIndex == nil then
			if Context.Data.Produce.id == Formulas[i] then
				self.SelectedFormulaIndex = i
			end
		end
	end)
end

--设置默认选择的燃料
local function set_default_fuel_index()

	self.selectFuelIndex = 1

	---------
	-- 默认选择第一个有数量的燃料
	-- self.selectFuelIndex = -1
	-- local Fuels = self.Fuels
	-- for idx,v in pairs(Fuels) do
	-- 	local fuelCnt = get_item_cnt(v.id)
	-- 	if fuelCnt and fuelCnt > 1 then
	-- 		self.selectFuelIndex = idx
	-- 		return
	-- 	end
	-- end
	---------
end

local function process_context_value()
	local Obj = CTRL.get_obj(Context.obj)
	local ObjBase = Obj:get_base_data()

	if Context.title == nil then
		Context.title = ObjBase and ObjBase.name or TEXT.S_Processing
	end

	if Context.pageIcon == nil then
		Context.pageIcon = "CommonIcon/ico_main_001"
		if ObjBase and ObjBase.interactIcon and ObjBase.interactIcon ~= "" then
			Context.pageIcon = "CommonIcon/"..ObjBase.interactIcon
		end
	end
end

local function cancel_guild_work()
	DY_TIMER.stop_timer("WORKING")
	self.ProduceCache = {}
	self.GuildWorkingFormulaId = 0
	self.GuildWorkingCnt = 0
	rfsh_formula_list()
	rfsh_product_view()
end

-- 当界面切换为不可见时的回调（关闭或者topbar切换）
function on_wnd_switch_off(callback)
	if self.GuildWorkingCnt and self.GuildWorkingCnt > 0 and self.workingBagType == "Guild" then
		_G.UI.MBox.operate("AskGuildWorkBagSwitchCancel", function ()
			cancel_guild_work()
			callback()
		end)
		return
	end
	callback()
end

function rfsh_other_assets(isInit)
	local assetType = nil
	if self.workingBagType == "Guild" then
		assetType = CVar.ASSET_TYPE.Exploit
	end

	self.otherAssetType = assetType

	if assetType then
		if isInit then
			local AssetInfo = ItemLIB.get_dat(assetType)
			libunity.SetActive(Ref.SubWork.SubOtherAssets.go, true)
			ui.seticon(Ref.SubWork.SubOtherAssets.spIcon, AssetInfo.icon)
		end
		local amount = DY_DATA:nget_asset(assetType)
		Ref.SubWork.SubOtherAssets.lbAmount.text = amount
	else
		if isInit then
			libunity.SetActive(Ref.SubWork.SubOtherAssets.go, false)
		end
	end

end

--!* [开始] 自动生成函数 *--

function on_subwork_subformulalist_subscroll_grpformulalist_entformula_click(btn)
	local index = Ref.SubWork.SubFormulaList.SubScroll.GrpFormulaList:getindex(btn)
	rfsh_formula_detail_info(index)
end

function on_formula_mat_click(evt, data)
	local Formula = get_select_formula(SelectedFormulaIndex)
	local Mats = Formula.Mats
	local Mat = Mats[ui.index(evt)]
	if Mat then
		local Item = ItemDEF.new(Mat.id, 1)
		Item:show_tip(evt)
	end
end

function on_subwork_subformulainfo_submats_grpmats_entmat_subitem_deselect(evt, data)
	_G.DEF.Item.hide_tip()
end

function on_subwork_subformulainfo_subfuel_subfuelitem_spicon_click(evt, data)
	if self.FuelItemInfo then
		self.FuelItemInfo:show_tip(evt)
	end
end

function on_subwork_subformulainfo_subfuel_subfuelitem_spicon_deselect(evt, data)
	_G.DEF.Item.hide_tip()
end

function on_select_fuel(btn)
	local GrpFuel = Ref.SubWork.SubFormulaInfo.SubFuel.SubScroll.GrpFuel
	self.selectFuelIndex = GrpFuel:getindex(btn)
	forceUpdateFuelSelected(btn)
	rfsh_max_editcnt_view()
end

function on_subwork_subformulainfo_subproduct_subproductitem_spicon_click(evt, data)
	if self.ProductItemInfo then
		self.ProductItemInfo:show_tip(evt)
	end
end

function on_subwork_subformulainfo_subproduct_subproductitem_spicon_deselect(evt, data)
	_G.DEF.Item.hide_tip()
end

function on_edit_count_changed(bar)
	rfsh_edit_cnt_view(bar.value)
end

function on_subwork_subworking_btnmuti_click(btn)
	local SubProc = Ref.SubWork.SubWorking.SubProc
	SubProc.bar.value = SubProc.bar.value - 1
end

function on_subwork_subworking_btnadd_click(btn)
	local SubProc = Ref.SubWork.SubWorking.SubProc
	SubProc.bar.value = SubProc.bar.value + 1
end

function on_subwork_subworking_btnmax_click(btn)
	local SubProc = Ref.SubWork.SubWorking.SubProc
	SubProc.bar.value = SubProc.bar.maxValue
end

function on_subwork_suboprs_btncancelwork_click(btn)
	local confirm = function()
		if self.workingBagType == "Normal" then
			local formulaId = Context.Data.Produce.id
			local fuelId = editInfo.fuelId
			NW.op_modify_working_cnt(Context.obj, 3, formulaId, fuelId, 0)
		elseif self.workingBagType == "Guild" then
			cancel_guild_work()
		end
	end

	UI.MBox.make()
		:set_param("content", TEXT.askCancelWork)
		:set_event(confirm)
		:show()
end

function on_subwork_suboprs_btneditcnt_click(btn)
	if self.workingBagType == "Normal" then
		local formulaId = editInfo.formula.id
		local fuelId = editInfo.fuelId
		local curSelectCnt = editInfo.curSelectCnt
		if fuelId == nil or curSelectCnt == 0 then
			return
		end
		NW.op_modify_working_cnt(Context.obj, 1, formulaId, fuelId, curSelectCnt)
	elseif self.workingBagType == "Guild" then
		self.GuildWorkingFormulaId = editInfo.formula.id
		self.GuildWorkingCnt = editInfo.curSelectCnt
		self.ProduceCache = {}
		rfsh_product_view()
	end
end

function on_subwork_suboprs_btntakeall_click(btn)
	local fuelIndex, produceIndex = get_slot_index()
	local Produce = DY_DATA:iget_item(produceIndex)
	local amount = Produce and Produce.amount or 0
	if amount > 0 then
		NW.op_modify_working_cnt(Context.obj, 2, 0, 0, 0)
	end
end

function on_subwork_suboprs_subhasten_click(btn)
	UI.MBox.consume(_G.DEF.Item.new(3, self.HastenCost), "HastenWork", function ()
		NW.op_produce(Context.obj, 1)
	end)
end

function on_subwork_subotherassets_spicon_ptrdown(evt, data)
	if self.otherAssetType then
		ItemDEF.new(self.otherAssetType):show_tip(evt)
	end
end
--!* [结束] 自动生成函数  *--

function init_view()
	ui.group(Ref.SubWork.SubFormulaList.SubScroll.GrpFormulaList)
	ui.group(Ref.SubWork.SubFormulaInfo.SubMats.GrpMats)
	--!* [结束] 自动生成代码 *--
end

function init_logic()
	self.UTIL = _G.PKG["ui/util"]
	self.show_item_view = UTIL.show_item_view
	self.ItemDEF = _G.DEF.Item
	self.packageObj = Context.obj
	self.totalCntFlag = 0
	self.curTotalCntFlag = 0
	self.get_item_amount = DY_DATA.item_counter()

	self.spFormulaSelected = Ref.SubWork.SubFormulaList.SubScroll.spSelected
	self.spFuelSelected = Ref.SubWork.SubFormulaInfo.SubFuel.SubScroll.spSelected

	libunity.SetActive(self.spFormulaSelected, false)
	libunity.SetActive(self.spFuelSelected, false)

	self.workingBagType = Context.ext or "1"
	self.workingBagType = EWorkingBagType[self.workingBagType]

	if self.workingBagType == "Normal" then
		self.Formulas = Context.Data.Formulas
		self.Fuels = Context.Data.Fuels
	elseif self.workingBagType == "Guild" then
		self.Formulas = {}
		self.Fuels = {}
		self.ProduceCache = {}
		self.GuildWorkingFormulaId = 0
		self.GuildWorkingCnt = 0
		NW.GUILD.RequestGuildProduce(Context.obj, 1)
		process_context_value()
	end
	rfsh_other_assets(true)

	self.hasFuel = #self.Fuels > 0
	set_default_fuel_index()

	rfsh_formula_list()
	if self.SelectedFormulaIndex == nil then
		self.SelectedFormulaIndex = 1
	end
	rfsh_formula_detail_info(self.SelectedFormulaIndex)
	rfsh_fuel_list()
	rfsh_product_view()

	Ref.lbTitle.text = Context.title
	self.StatusBar.Menu = {
		icon = Context.pageIcon,
		name = "WNDWorkBagNew",
		title = Context.title,
		Context = Context,
	}
end

function show_view()

end

function on_recycle()
	DY_TIMER.stop_timer("WORKING")
	DY_TIMER.stop_timer("BURNING")

	libunity.SetParent(self.spFormulaSelected, Ref.SubWork.SubFormulaList.SubScroll.go, false, -1)
	libunity.SetActive(self.spFormulaSelected, true)

	libunity.SetParent(self.spFuelSelected, Ref.SubWork.SubFormulaInfo.SubFuel.SubScroll.go, false, -1)
	libunity.SetActive(self.spFuelSelected, true)

	local obj = Context.obj
	if obj and self.workingBagType == "Normal" then
		NW.send(NW.gamemsg("PACKAGE.CS.PACKAGE_CLOSE"):writeU32(obj))
		DY_DATA:del_obj_items(obj)
	end

	libgame.UnitBreak(0)
end

local function total_cnt_flag_increase()
	self.totalCntFlag = self.totalCntFlag + 1
end

local function reget_total_cnt()
	if self.workingBagType == "Normal" and self.totalCntFlag ~= self.curTotalCntFlag then
		local nm = NW.msg("PRODUCE.CS.ITEM_STAT"):writeU32(Context.obj)
		NW.send(nm)
	end
end

local function merge_ProduceCache(produceInfo)
	for _,v in pairs(self.ProduceCache) do
		if v.id == produceInfo.id then
			v.amount = v.amount + produceInfo.amount
			return
		end
	end
	table.insert(self.ProduceCache, produceInfo)
end

Handlers = {
	["CLIENT.SC.TOPBAR_SWITCH"] = function (Wnd)
		if Wnd == self then
			reget_total_cnt()
			rfsh_formula_list()
			rfsh_formula_detail_info(SelectedFormulaIndex)
		end
	end,
	["PRODUCE.SC.PRODUCEINFO"] = function (Ret)
		if Ret.Produce and Ret.Produce.obj == Context.obj then
			Context.Data.Produce = Ret.Produce
			rfsh_formula_list()
			rfsh_fuel_list()
			rfsh_material_list()
			rfsh_product_view()
			--rfsh_working_view()

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
	["PRODUCE.SC.MODIFY_COUNT"] = function (Ret)
		local totalCntDict = Context.totalCntDict
		if Ret.modify then
			for _,v in pairs(Ret.modify) do
				local cnt = totalCntDict[v.id] or 0
				totalCntDict[v.id] = cnt + v.count
			end
			rfsh_formula_detail_info(SelectedFormulaIndex)
			rfsh_formula_list()
			rfsh_fuel_list()
			rfsh_product_view()
		end
	end,

	["PACKAGE.SC.SYNC_ITEM"] = total_cnt_flag_increase,
	["PACKAGE.SC.ITEM_USE"] = total_cnt_flag_increase,
	["PACKAGE.SC.ITEM_DEL"] = total_cnt_flag_increase,
	["PACKAGE.SC.SYNC_PACKAGE"] = total_cnt_flag_increase,
	["PACKAGE.CS.ITEM_MOVE"] = total_cnt_flag_increase,
	["PACKAGE.CS.ITEM_COMPOSE"] = total_cnt_flag_increase,

	["PRODUCE.SC.ITEM_STAT"] = function (totalCntDict)
		self.curTotalCntFlag = self.totalCntFlag
		Context.totalCntDict = totalCntDict
		rfsh_formula_detail_info(SelectedFormulaIndex)
		rfsh_formula_list()
		rfsh_fuel_list()
		rfsh_product_view()
	end,
	["GUILD.SC.GUILD_BUILD_PRODUCE"] = function(Ret)
		if Ret.err == nil then
			self.GuildWorkingCnt = self.GuildWorkingCnt - 1
			self.Formulas = Ret.Data.Formulas
			self.Energy = Ret.Data.Energy
			for _,v in pairs(Ret.Data.Produce) do
				merge_ProduceCache(v)
			end
		else
			if Ret.ret == 1382 then
				self.Energy = 0
			end
			self.GuildWorkingCnt = 0
		end

		rfsh_formula_list()
		rfsh_formula_detail_info(self.SelectedFormulaIndex)
		rfsh_fuel_list()
		rfsh_product_view()
	end,
	["PLAYER.SC.ROLE_ASSET_GET"] = rfsh_other_assets,
}

return self

