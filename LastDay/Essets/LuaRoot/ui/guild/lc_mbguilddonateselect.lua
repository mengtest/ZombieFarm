--
-- @file    ui/guild/lc_mbguilddonateselect.lua
-- @author  shenbingkang
-- @date    2018-09-07 11:08:37
-- @desc    MBGuildDonateSelect
--

local self = ui.new()
local _ENV = self
local guildlib = config("guildlib")
local UTIL = _G.PKG["ui/util"]

local function rfsh_get_contribution_value(value)
	local SubContribution = Ref.SubMain.SubContribution
	SubContribution.lbContribution.text = string.format("%d", self.ContributionPer * value)
end

--!* [开始] 自动生成函数 *--

function on_submain_subitem_ptrdown(evt, data)
	self.DonateItem:show_tip(evt)
end

function on_edit_count_changed(bar)
	local SubProc = Ref.SubMain.SubSelectedCnt.SubProc
	SubProc.lbSelectedCnt.text = string.format("%d", bar.value)
	rfsh_get_contribution_value(bar.value)
end

function on_submain_subselectedcnt_btnmuti_click(btn)
	local SubProc = Ref.SubMain.SubSelectedCnt.SubProc
	SubProc.bar.value = SubProc.bar.value - 1
end

function on_submain_subselectedcnt_btnadd_click(btn)
	local SubProc = Ref.SubMain.SubSelectedCnt.SubProc
	SubProc.bar.value = SubProc.bar.value + 1
end

function on_submain_subselectedcnt_btnmax_click(btn)
	local SubProc = Ref.SubMain.SubSelectedCnt.SubProc
	SubProc.bar.value = SubProc.bar.maxValue
end

function on_submain_subop_btnconfirm_click(btn)
	local cnt = Ref.SubMain.SubSelectedCnt.SubProc.bar.value
	if cnt > 0 then
		NW.GUILD.RequestDonate(0, self.DonateItemId, cnt)
	end
end
--!* [结束] 自动生成函数  *--

function init_view()
	--!* [结束] 自动生成代码 *--
end

function init_logic()
	self.DonateItemId = tonumber(_G.CVar.GUILD.DonateMoney)
	self.ContributionPer = guildlib.get_donate_contribution(self.DonateItemId)
	DY_DATA.OwnItems = nil
	local ownCnt = DY_DATA:nget_item(self.DonateItemId)

	local SubSelectedCnt = Ref.SubMain.SubSelectedCnt
	SubSelectedCnt.SubProc.bar.value = 0
	rfsh_get_contribution_value(0)
	SubSelectedCnt.SubProc.bar.maxValue = ownCnt
	SubSelectedCnt.lbMax.text = ownCnt

	UTIL.flex_itement(Ref.SubMain, "SubItem", 0)
	self.DonateItem = _G.DEF.Item.new(self.DonateItemId, ownCnt)
	UTIL.show_item_view(self.DonateItem, Ref.SubMain.SubItem)

end

function show_view()
	
end

function on_recycle()
	
end

Handlers = {
	["GUILD.SC.GUILD_DONATE"] = function(err)
		if err == nil then
			self:close()
		end
	end,
}

return self

