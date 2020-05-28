--
-- @file    ui/item/lc_wndconstructing.lua
-- @author  shenbingkang
-- @date    2018-05-28 15:02:58
-- @desc    WNDConstructing
--

local self = ui.new()
local _ENV = self

local MatItemList = {}
local MatItemInfoList = {}	--key:所需材料格的genIndex  value:ItemInfo}
local Formula

local flex_itement = _G.PKG["ui/util"].flex_itement

--ui最多支持12个物品
local uiMaxMatsCnt = 12

local function rfsh_mat_cnt(idx, curCnt, needCnt)
	if needCnt > curCnt then
		MatItemList[idx].lbAmount.text = string.format(TEXT.fmtCnt_Inadequate, curCnt, needCnt)
	else
		MatItemList[idx].lbAmount.text = string.format(TEXT.fmtCnt_Adequate, curCnt, needCnt)
	end
end

function iget_entitem(index)
	local entKey = "SubMat"..index
	local SubMats = Ref.SubWork.SubMats

	for i=1,4,1 do
		local SubMatGroup = SubMats["SubMatGroup"..i]
		local unit = SubMatGroup[entKey]
		if unit then
			return unit
		end
	end

	return null
end

local function rfsh_allmat_cnt()
	local SubMats = Ref.SubWork.SubMats
	local ItemDEF = _G.DEF.Item

	local putMats = Context.Data.Mats

	local curCntDict = {}
	for _,v in pairs(putMats) do
		curCntDict[v.id] = v.amount
	end

	local bCanBuild = true

	for i=1,uiMaxMatsCnt do
		local matUnit = iget_entitem(i)
		local Mat = Formula.Mats[i]

		if Mat then
			libunity.SetActive(matUnit.go, true)
			local needCnt = Mat.amount
			local curCnt = curCntDict[Mat.id]
			if curCnt == nil then
				curCnt = 0
			end

			--策划需求，只有当该格材料填满时，该格才点亮
			local initCnt = 1
			if curCnt < needCnt then
				bCanBuild = false
				initCnt = 0
			end

			flex_itement(matUnit, "SubItem", 0)
			ItemDEF.new(Mat.id, initCnt):show_view(matUnit)

			local genIndex = CVar.gen_item_pos(Context.obj, 0, i)
			ui.index(matUnit.go, genIndex)
			MatItemList[i] = matUnit
			MatItemInfoList[genIndex] = ItemDEF.new(Mat.id, curCnt)
			rfsh_mat_cnt(i, curCnt, needCnt)
		else
			libunity.SetActive(matUnit.go, false)
		end
	end

	libugui.SetInteractable(Ref.SubWork.btnComplete, bCanBuild)
end

--!* [开始] 自动生成函数 *--

function on_enddrag_item(evt, data)
	Primary.on_enddrag_item(evt, data)
end

function on_drop_item(evt, data)
	Primary.on_drop_item(evt, data)
end

function on_item_ptrdown(evt, data)
	local matItemInfo = MatItemInfoList[ui.index(evt)]
	matItemInfo:show_tip(evt)
end

function on_item_dualclick(evt, data)
	Primary.on_item_dualclick(evt, data)
end

function on_item_deselect(evt, data)
	_G.DEF.Item.hide_tip()
end

function on_subwork_btncomplete_click(btn)
	NW.send(NW.msg("BUILD.CS.OPERATION"):writeU32(Context.obj):writeU32(2))
end
--!* [结束] 自动生成函数  *--

function on_item_selected(evt, data)
	Primary.on_item_selected(evt, data)
end

function on_begindrag_item(evt, data)
	Primary.on_begindrag_item(evt, data)
end

function on_drag_item(evt, data)
	Primary.on_drag_item(evt, data)
end

function on_item_pressed(evt, data)
	if data then
		local matItemInfo = MatItemInfoList[ui.index(evt)]
		matItemInfo:show_tip(evt)
	else
		_G.DEF.Item.hide_tip()
	end
	Primary.on_item_pressed(evt, data)
end

function init_view()
	--!* [结束] 自动生成代码 *--
end

function init_logic()
	ui.moveout(Ref.spBack, 1)

	self.Primary = Context.Primary
	self.Primary.Secondary = self

	--设置Title
	--Ref.SubWork.lbTitle.text = Context.title

	--设置蓝图
	local formulaID = Context.Data.FormulaID
	local WorkingLIB = config("workinglib")
	Formula = WorkingLIB.get_dat(formulaID)
	Ref.SubWork.spBluePrint:SetTexture(string.format("rawtex/%s/%s", Formula.bluePrints, Formula.bluePrints))

	rfsh_allmat_cnt()
	Ref.lbTitle.text = Context.title
end

function show_view()
end

function on_recycle()
	ui.putback(Ref.spBack, Ref.go)
	
	MatItemList = {}
	MatItemInfoList = {}

	-- libgame.UnitBreak(0)
	-- NW.send(NW.gamemsg("PACKAGE.CS.PACKAGE_CLOSE"):writeU32(Context.obj))
end

Handlers = {
	["PACKAGE.SC.SYNC_PACKAGE"] = function (Ret)
		rfsh_allmat_cnt()
	end,
	["PRODUCE.SC.PRODUCEINFO"] = function  (Ret)
		if Ret.Produce then
			if Ret.Produce.FormulaID == Context.Data.FormulaID then
				Context.Data.Mats = Ret.Produce.Mats
				rfsh_allmat_cnt()
			end
		end
	end,
	["BUILD.SC.OPERATION"] = function (Ret)
		if Ret.err == nil then
			self.Primary:close()
		end
	end,
}

return self

