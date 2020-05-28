--
-- @file    ui/item/lc_wndfuellist.lua
-- @author  xingweizhen
-- @date    2018-04-24 17:55:58
-- @desc    WNDFuelList
--

local self = ui.new()
local _ENV = self
--!* [开始] 自动生成函数 *--

function on_rfsh_fuel_ent(go, i)
	local Ent = ui.ref(go)
	local Fuel = Context[i + 1]
	local Item = ItemDEF.new(Fuel.id)
	Item:show_view(Ent)

	local FuelBase = Item:get_base_data()
	Ent.lbName.text = FuelBase.name
	Ent.lbTime.text = os.secs2time(nil, Fuel.burnTime)
end
--!* [结束] 自动生成函数  *--

function init_view()
	ui.group(Ref.SubMain.SubScroll.SubView.GrpFuels)
	--!* [结束] 自动生成代码 *--

	local flex_itemgrp = _G.PKG["ui/util"].flex_itemgrp
	flex_itemgrp(Ref.SubMain.SubScroll.SubView.GrpFuels, 0, "Vertical", 0, 90)

	self.ItemDEF = _G.DEF.Item
end

function init_logic()
	libugui.SetVisible(Ref.SubMain.SubScroll.go, false)
end

function show_view()
	libugui.SetVisible(Ref.SubMain.SubScroll.go, true)

	local Fuels = Context
	libugui.SetLoopCap(Ref.SubMain.SubScroll.SubView.GrpFuels.go, #Fuels)
	local scroll = Ref.SubMain.SubScroll.go:GetComponent("ScrollRect")
	scroll.verticalNormalizedPosition = 1
end

function on_recycle()

end

return self

