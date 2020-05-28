--
-- @file    ui/guild/lc_mbguildrequestclaim.lua
-- @author  shenbingkang
-- @date    2018-09-06 17:33:17
-- @desc    MBGuildRequestClaim
--

local self = ui.new()
local _ENV = self

local guildlib = config("guildlib")
local itemlib = config("itemlib")

local function forceUpdateSelected(go)
	libunity.SetParent(self.spSelected, go, false, -1)
	libunity.SetActive(self.spSelected, true)
end

--!* [开始] 自动生成函数 *--

function on_grpclaimview_ent(go, i)
	local GrpClaimView = Ref.SubMain.SubClaimView.GrpClaimView

	local n = i + 1
	GrpClaimView:setindex(go, n)

	local claimInfo = self.claimList[n]
	local Ent = ui.ref(go)
	
	local Item = ItemDEF.new(claimInfo.itemId, 1)
	self.claimItemList[i] = Item
	local itemData = Item:get_base_data()

	Item:show_icon(Ent.spItemIcon)
	Item:show_rarityIcon(Ent.spRarity)

	Ent.lbItemName.text = itemData.name
	Ent.lbItemCnt.text = claimInfo.requestCnt

	if claimInfo.requestLvLimit > self.friendlyLvInfo.level then
		libunity.SetActive(Ent.SubLocked.go, true)
		libugui.SetInteractable(Ent.go, false)
		Ent.SubLocked.lbFriendlyLevel.text = claimInfo.requestLvLimit
	else
		libugui.SetInteractable(Ent.go, true)
		libunity.SetActive(Ent.SubLocked.go, false)
	end

	if self.selectedIndex == n then
		forceUpdateSelected(Ent.go)
	else
		libunity.SetActive(Ent.spSelected, false)
	end
end

function on_submain_subclaimview_grpclaimview_entclaim_click(btn)
	local GrpClaimView = Ref.SubMain.SubClaimView.GrpClaimView
	self.selectedIndex = ui.index(btn)
	local Ent = GrpClaimView:get(self.selectedIndex)
	forceUpdateSelected(Ent.go)
end

function on_submain_subclaimview_grpclaimview_entclaim_spitemicon_pressed(evt, data)
	if data then
		local index = ui.index(evt)
		self.claimItemList[index]:show_tip(evt)
	else
		_G.DEF.Item.hide_tip()
	end
end

function on_submain_subop_btnconfirm_click(btn)
	local claimInfo = self.claimList[self.selectedIndex]
	if claimInfo then
		local itemData = itemlib.get_dat(claimInfo.itemId)
		_G.UI.MBox.operate("AskRequestClaim", function ()
			NW.GUILD.RequestClaim(claimInfo.id)
		end,{
			content = tostring(TEXT.AskOperation.AskRequestClaim.content)
				:csfmt(claimInfo.requestCnt, itemData.name),
		})
	end
end
--!* [结束] 自动生成函数  *--

function on_submain_subclaimview_grpclaimview_entclaim_spitemicon_ptrdown(evt, data)
	
end

function on_submain_subclaimview_grpclaimview_entclaim_spitemicon_ptrup(evt, data)
	
end

function init_view()
	ui.group(Ref.SubMain.SubClaimView.GrpClaimView)
	--!* [结束] 自动生成代码 *--
	self.ItemDEF = _G.DEF.Item
end

function init_logic()
	self.selectedIndex = 0
	self.spSelected = Ref.SubMain.SubClaimView.spSelected
	libunity.SetActive(self.spSelected, false)

	self.friendlyLvInfo = guildlib.get_exchange_friendly_level(Context.myFriendlyValue)
	Ref.SubMain.lbFriendlyLevel.text = self.friendlyLvInfo.level
	 
	self.claimList = guildlib.get_request_claim_list()

	self.claimItemList = {}
	libugui.SetLoopCap(Ref.SubMain.SubClaimView.GrpClaimView.go, #self.claimList, true)
end

function show_view()
	
end

function on_recycle()
	libunity.SetParent(self.spSelected, Ref.SubMain.SubClaimView.go, true, -1)
	libunity.SetActive(self.spSelected, true)
end

Handlers = {
	["GUILD.SC.GUILD_CLAM"] = function(err)
		if err == nil then
			self:close()
		end
	end,
}

return self

