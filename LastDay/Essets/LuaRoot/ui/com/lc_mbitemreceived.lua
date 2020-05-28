--
-- @file    ui/com/lc_mbitemreceived.lua
-- @author  shenbingkang
-- @date    2018-05-25 17:56:05
-- @desc    MBItemReceived
--

local self = ui.new()
local _ENV = self

local function rfsh_content_view()
	local ItemDEF = _G.DEF.Item

	local SubMain = Ref.SubMain
	local Params = _G.UI.MBox.get().Params
	local SrcItems = Params.items

	local mergedSrcItems = {}

	for _,t in pairs(SrcItems) do
	for _,v in pairs(t) do
			if mergedSrcItems[v.id] then
				mergedSrcItems[v.id] = mergedSrcItems[v.id] + v.amount
			else
				mergedSrcItems[v.id] = v.amount
			end
		end
	end

	self.itemList = {}
	for itemid,amount in pairs(mergedSrcItems) do
		local SrcItem = ItemDEF.new(itemid, amount)
		local baseData = SrcItem:get_base_data()

		--拆分
		while (amount > baseData.nStack and baseData.nStack > 0)
		do
			local splitItem = ItemDEF.new(itemid, baseData.nStack)
			amount = amount - baseData.nStack
			table.insert(itemList, splitItem)
		end
		SrcItem.amount = amount
		table.insert(itemList, SrcItem)
	end

	libugui.SetLoopCap(Ref.SubMain.SubScroll.GrpRewardsList.go, #itemList, true)

end

--!* [开始] 自动生成函数 *--

function on_submain_btnconfirm_click(btn)
	_G.UI.MBox.on_btncancel_click()
end

function on_grprewardslist_ent(go, i)
	local GrpRewardsList = Ref.SubMain.SubScroll.GrpRewardsList
	local n = i + 1
	GrpRewardsList:setindex(go, n)
	local rewardItem = self.itemList[n]

	local Ent = ui.ref(go)
	rewardItem:show_view(Ent)
	Ent.lbAmount.text = rewardItem.amount
end
--!* [结束] 自动生成函数  *--

function init_view()
	ui.group(Ref.SubMain.SubScroll.GrpRewardsList)
	--!* [结束] 自动生成代码 *--

	local flex_itemgrp = _G.PKG["ui/util"].flex_itemgrp
	flex_itemgrp(Ref.SubMain.SubScroll.GrpRewardsList)
end

function init_logic()
	rfsh_content_view()
end

function show_view()
	
end

function on_recycle()
	
end

return self

