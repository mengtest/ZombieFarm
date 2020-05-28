--
-- @file    ui/com/lc_mbitemsubmit.lua
-- @author  xingweizhen
-- @date    2018-06-26 13:35:46
-- @desc    MBItemSubmit
--

local self = ui.new()
local _ENV = self

--!* [开始] 自动生成函数 *--

function on_submain_subop_btncancel_click(btn)
	
	local Params = Context

	if not Params.single then
		_G.UI.MBox.on_btncancel_click()
	end
end

function on_submain_subop_btnconfirm_click(btn)
	_G.UI.MBox.on_btnconfirm_click()
end
--!* [结束] 自动生成函数  *--

function init_view()
	ui.group(Ref.SubMain.GrpItems)
	--!* [结束] 自动生成代码 *--

	_G.PKG["ui/util"].flex_itemgrp(Ref.SubMain.GrpItems)
end

function init_logic()
	local Params = Context
	local SubMain = Ref.SubMain
	SubMain.lbTitle.text = Params.title
	libugui.SetVisible(SubMain.lbTips, Params.tips)
	if Params.tips then SubMain.lbTips.text = Params.tips end

	-- 操作按钮
	local TEXT = _G.TEXT
	local SubOp = SubMain.SubOp
	libugui.SetText(GO(SubOp.btnConfirm, "&lbText"),
		Params.txtConfirm or TEXT["v.confirm"])

	libunity.SetActive(SubOp.btnCancel, not Params.single)
	if not Params.single then
		libugui.SetText(GO(SubOp.btnCancel, "&lbText"),
			Params.txtCancel or TEXT["v.cancel"])
	end

	-- 道具列表
	local enough = true
	local Items = Params.Items

	local LPOCKET = DY_DATA:iget_item(CVar.EQUIP_LPOCKET_POS)
	local RPOCKET = DY_DATA:iget_item(CVar.EQUIP_RPOCKET_POS)
	local pocket = {}
	if LPOCKET then
		if pocket[LPOCKET.dat] then
			pocket[LPOCKET.dat] = pocket[LPOCKET.dat] + LPOCKET.amount
		else
			pocket[LPOCKET.dat] = LPOCKET.amount
		end
	end
	if RPOCKET then
		if pocket[RPOCKET.dat] then
			pocket[RPOCKET.dat] = pocket[RPOCKET.dat] + RPOCKET.amount
		else
			pocket[RPOCKET.dat] = RPOCKET.amount
		end
	end

	SubMain.GrpItems:dup(#Items, function (i, Ent, isNew)
		local Item = Items[i]
		local nOwn = DY_DATA:nget_item(Item.dat)
		if pocket[Item.dat] then
			nOwn = nOwn - pocket[Item.dat]
		end
		Item:show_view(Ent)
		Ent.lbAmount.text = string.own_needs(nOwn, Item.amount)
		enough = enough and nOwn >= Item.amount
	end)
	SubOp.btnConfirm.interactable = enough

end

function show_view()

end

function on_recycle()
	libgame.UnitBreak(0)
end

return self

