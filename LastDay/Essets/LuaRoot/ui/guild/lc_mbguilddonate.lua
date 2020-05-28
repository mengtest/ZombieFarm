--
-- @file    ui/guild/lc_mbguilddonate.lua
-- @author  shenbingkang
-- @date    2018-06-13 17:49:10
-- @desc    MBGuildDonate
--

local self = ui.new()
local _ENV = self

local DonateItemInfo = {}

local function rfsh_donate_stall_elem(stallIndex, SubStall, donateInfo)
	local UTIL = _G.PKG["ui/util"]
	UTIL.flex_itement(SubStall, "SubItem", 0)
	libugui.SetVisible(SubStall.SubItem.lbAmount, false)
	local Item = _G.DEF.Item.gen(donateInfo.cost)
	DonateItemInfo[stallIndex] = Item
	show_item_view(Item, SubStall.SubItem)

	local ownAmount = DY_DATA:nget_item(donateInfo.cost.id)
	SubStall.lbCnt.text = string.format("%d/%d", ownAmount, donateInfo.cost.amount)

	SubStall.lbAddExp.text = string.format(TEXT.fmtGuildDonate.addExp, donateInfo.addExp)
	SubStall.lbAddCapital.text = string.format(TEXT.fmtGuildDonate.addCapital, donateInfo.addCapital)
	SubStall.lbAddCt.text = string.format(TEXT.fmtGuildDonate.addConribution, donateInfo.addConrtibution)
end

local function rfsh_donate_view()
	local buildingInfo = Context.buildingInfo
	local cfg = config("guildlib")
	local baseInfo, extInfo = cfg.get_building_info(buildingInfo.buildingID ,buildingInfo.buildingLevel)

	local SubStalls = Ref.SubMain.SubStalls
	
	rfsh_donate_stall_elem(1, SubStalls.SubStall1, extInfo.donateLv1)
	rfsh_donate_stall_elem(2, SubStalls.SubStall2, extInfo.donateLv2)
	rfsh_donate_stall_elem(3, SubStalls.SubStall3, extInfo.donateLv3)
end

--!* [开始] 自动生成函数 *--

function on_submain_substalls_substall1_subitem_pressed(evt, data)
	if data then
		DonateItemInfo[1]:show_tip(evt)
	else
		_G.DEF.Item.hide_tip()
	end
end

function on_submain_substalls_substall1_btndonate_click(btn)
	NW.GUILD.RequestDonate(Context.buildingInfo.buildingID, 1)
end

function on_submain_substalls_substall2_subitem_pressed(evt, data)
	if data then
		DonateItemInfo[2]:show_tip(evt)
	else
		_G.DEF.Item.hide_tip()
	end
end

function on_submain_substalls_substall2_btndonate_click(btn)
	NW.GUILD.RequestDonate(Context.buildingInfo.buildingID, 2)
end

function on_submain_substalls_substall3_subitem_pressed(evt, data)
	if data then
		DonateItemInfo[3]:show_tip(evt)
	else
		_G.DEF.Item.hide_tip()
	end
end

function on_submain_substalls_substall3_btndonate_click(btn)
	NW.GUILD.RequestDonate(Context.buildingInfo.buildingID, 3)
end
--!* [结束] 自动生成函数  *--

function init_view()
	--!* [结束] 自动生成代码 *--
	self.show_item_view = _G.PKG["ui/util"].show_item_view
end

function init_logic()
	rfsh_donate_view()
end

function show_view()
	
end

function on_recycle()
	
end

Handlers = {
	["GUILD.SC.GUILD_DONATE"] = rfsh_donate_view,
}

return self

