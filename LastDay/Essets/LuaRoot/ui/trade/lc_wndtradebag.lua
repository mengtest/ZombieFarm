--
-- @file    ui/trade/lc_wndtradebag.lua
-- @author  xingweizhen
-- @date    2018-06-30 17:31:35
-- @desc    WNDTradeBag
--

local self = ui.new()
local _ENV = self

--!* [开始] 自动生成函数 *--

function on_subtrade_grpconsum_entitem_pressed(evt, data)
	if data then
		local Item = self.Consums[Ref.SubTrade.GrpConsum:getindex(evt)]
		if Item then Item:show_tip(evt) end
	else
		_G.DEF.Item.hide_tip()
	end
end

function on_subtrade_grpobtain_entitem_pressed(evt, data)
	if data then
		local Item = self.Obtains[Ref.SubTrade.GrpObtain:getindex(evt)]
		if Item then Item:show_tip(evt) end
	else
		_G.DEF.Item.hide_tip()
	end
end

function on_subtrade_btndeal_click(btn)
	local DlgData = config("npclib").get_dat(tonumber(Context.ext))
	local OptData = DlgData.Params[1]
	local nm = NW.gamemsg("SUB_BATTLE.CS.OBJ_TALK_NPC")
	NW.send(nm:writeU32(Context.obj):writeU32(OptData.id):writeString(""))
end
--!* [结束] 自动生成函数  *--

function init_view()
	ui.group(Ref.SubTrade.GrpConsum)
	ui.group(Ref.SubTrade.GrpObtain)
	--!* [结束] 自动生成代码 *--

	self.Primary = Context.Primary
	self.Primary.Secondary = self

	local flex_itemgrp = _G.PKG["ui/util"].flex_itemgrp
	flex_itemgrp(Ref.SubTrade.GrpConsum)
	flex_itemgrp(Ref.SubTrade.GrpObtain)
	
end

function init_logic()
	local DlgData = config("npclib").get_dat(tonumber(Context.ext))
	local OptData = DlgData.Params[1]
	Ref.SubTrade.SubTrader.lbSpeak.text = OptData.option

	local ItemDEF = _G.DEF.Item
	self.Consums = {}
	for i,v in ipairs(OptData.Conds) do
		if v.type == "checkItem" then
			Ref.SubTrade.GrpConsum:dup(#v.Params, function (i, Ent, isNew)
				local Item = ItemDEF.gen(v.Params[i])
				table.insert(self.Consums, Item)
				Item:show_view(Ent)
				Ent.lbAmount.text = string.own_needs(DY_DATA:nget_item(Item.dat), Item.amount)
			end)
		break end
	end

	self.Obtains = {}
	for i,v in ipairs(OptData.Rewards) do
		if v.type == "addItem" then
			Ref.SubTrade.GrpObtain:dup(#v.Params, function (i, Ent, isNew)
				local Item = ItemDEF.gen(v.Params[i])
				table.insert(self.Obtains, Item)
				Item:show_view(Ent)
			end)
		break end
	end
end

function show_view()

end

function on_recycle()
end

Handlers = {
	["SUB_BATTLE.SC.OBJ_TALK_NPC"] = function (Ret)
		if Ret.err == nil then
			Context.Primary:close(true)
		end
	end,
}

return self

