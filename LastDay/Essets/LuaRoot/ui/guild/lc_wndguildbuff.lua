--
-- @file    ui/guild/lc_wndguildbuff.lua
-- @author  shenbingkang
-- @date    2018-06-14 14:48:54
-- @desc    WNDGuildBuff
--

local self = ui.new()
local _ENV = self

local selectedIndex

local function forceUpdateMemberListSelected(go)
	libunity.SetParent(self.spSelected, go, false, 0)
	libunity.SetActive(self.spSelected, true)
end

local function rfsh_player_assets()
	local SubAsset = Ref.SubMain.SubNPCInfo.SubAsset
	local amount = DY_DATA:nget_asset("Exploit")
	SubAsset.lbAmount.text = amount
end

local function rfsh_exchange_cnt()
	local btnExchange = Ref.SubMain.SubDonateView.btnExchange
	local maxCnt = CVar.GUILD.BuffExchangeNum
	libugui.SetText(GO(btnExchange, "&lbText"), 
		string.format(TEXT.fmtGuildBuffExchange, (maxCnt - DY_DATA.MyGuildInfo.exchangeBuffCnt), maxCnt))
end

local function rfsh_buff_list_view(buffList)
	self.buffList = buffList
	local SubDonateView = Ref.SubMain.SubDonateView

	local cfg = config("guildlib")

	if #buffList == 0 then
		libunity.SetActive(SubDonateView.lbNoBuffMsg, true)
		libunity.SetActive(SubDonateView.GrpBuffView.go, false)
	else
		libunity.SetActive(SubDonateView.lbNoBuffMsg, false)
		libunity.SetActive(SubDonateView.GrpBuffView.go, true)
		
		SubDonateView.GrpBuffView:dup(#buffList, function (i, Ent, isNew)
			UTIL.flex_itement(Ent, "SubItem", 0)
			libugui.SetVisible(Ent.SubItem.lbAmount, false)

			local buildingInfo = buffList[i]

			local data = cfg.get_guild_buff_info(buildingInfo.buffID, buildingInfo.buffStall)

			local Item = _G.DEF.Item.new(buildingInfo.buffID, 1)
			local baseItemInfo = Item:get_base_data()
			show_item_view(Item, Ent.SubItem)
			Ent.lbName.text = baseItemInfo.name
			Ent.lbAmount.text = buildingInfo.cost
		end)
	end
end

local function rfsh_npc_info()
	local Obj = CTRL.get_obj(Context.obj)
	local npcBaseInfo = Obj:get_base_data()
	local SubNPCInfo = Ref.SubMain.SubNPCInfo
	SubNPCInfo.lbNpcName.text = npcBaseInfo.name
	SubNPCInfo.lbNpcInfo.text = npcBaseInfo.desc
	--todo:npc头像
end

--!* [开始] 自动生成函数 *--

function on_submain_subdonateview_grpbuffview_entbuffunit_btnselectbuff_click(btn)
	local GrpBuffView = Ref.SubMain.SubDonateView.GrpBuffView
	selectedIndex = GrpBuffView:getindex(btn.transform.parent)
	local Ent = GrpBuffView:get(selectedIndex)
	forceUpdateMemberListSelected(Ent.SubItem.go)

	libugui.SetInteractable(Ref.SubMain.SubDonateView.btnExchange, true)
end

function on_submain_subdonateview_btnmenulist_click(btn)
	ui.show("UI/MBGuildBuffMenu", 0)
end

function on_submain_subdonateview_btnexchange_click(btn)
	local selectedBuffInfo = self.buffList[selectedIndex]
	if selectedBuffInfo then
		NW.GUILD.RequestExchangeBuff(selectedBuffInfo.buffID, selectedBuffInfo.buffStall)
	end
end
--!* [结束] 自动生成函数  *--

function init_view()
	ui.group(Ref.SubMain.SubDonateView.GrpBuffView)
	--!* [结束] 自动生成代码 *--

	libugui.SetInteractable(Ref.SubMain.SubDonateView.btnExchange, false)
	self.spSelected = Ref.SubMain.SubDonateView.spSelected
	libunity.SetActive(self.spSelected, false)

	self.UTIL = _G.PKG["ui/util"]
	self.show_item_view = UTIL.show_item_view	
end

function init_logic()
	NW.GUILD.RequestGetMyGuildInfo()
	NW.GUILD.RequestGetGuildBuffList()
	rfsh_player_assets()
	rfsh_npc_info()
end

function show_view()
	
end

function on_recycle()
	libunity.SetParent(self.spSelected, Ref.SubMain.SubDonateView.GrpBuffView.go, true, -1)
	libunity.SetActive(self.spSelected, true)
end

Handlers = {
	["GUILD.SC.GET_GUILD_BUFF_LIST"] = rfsh_buff_list_view,
	["GUILD.SC.GUILD_EXCHANGE_BUFF"] = rfsh_exchange_cnt,
	["GUILD.SC.GUILD_MY_INFO"] = rfsh_exchange_cnt,
	["PLAYER.SC.ROLE_ASSET_GET"] = rfsh_player_assets,
}

return self

