--
-- @file    ui/social/lc_wndchat.lua
-- @author  xingweizhen
-- @date    2018-06-07 12:20:13
-- @desc    WNDChat
--

local self = ui.new()
local _ENV = self

local channelList = {}
local selectChannelind = 0

local Vector2 = UE.Vector2

local NodePosStack = {}

local function show_channel(Acc)
	local tglObj = Ref.SubNode.SubChat.SubInput.lbChannel
	local ChatChannelName = TEXT.ChatChannelName

	local channelName = ChatChannelName[Acc]
	if channelName then
		tglObj.text = channelName
	else
		tglObj.text = TEXT["chat.noselect"]
	end
end

local function on_check_channel_state(channel)
	local state = (1 << channel-1)

	local isopen = self.chatchannel & state

	return (isopen>> channel-1) == 1
end
local function on_change_channels(forceShow,defChannel)
	self.chatchannel = tonumber(DY_DATA.ChannelSet) or 127

	channelList = {}

	local ChatChannelName = TEXT.ChatChannelName

	local player = DY_DATA:get_player()

	for k,v in pairs(CVar.ChatChannel) do
		if v ~= CVar.ChatChannel.BLACK and v ~= CVar.ChatChannel.WORLD and
		 v ~= CVar.ChatChannel.STRANGER and v ~= CVar.ChatChannel.FRIEND then
		 	if on_check_channel_state(v) then
		 		if v == CVar.ChatChannel.GUILD then
		 			if forceShow or player.guildID ~= 0  then
		 				table.insert(channelList,v)
					end
				elseif v == CVar.ChatChannel.NEARBY then
					table.insert(channelList,v)
					if defChannel == nil then
						defChannel = CVar.ChatChannel.NEARBY
					end
				else
					table.insert(channelList,v)
		 		end
		 	end
		end
	end

	local GrpAccs = Ref.SubNode.SubChat.SubInput.GrpAccs
	GrpAccs.go:SetActive(false)
	GrpAccs:dup(#channelList, function (i, Ent, isNew)
		local Acc = channelList[i]
		Ent.lbAcc.text = ChatChannelName[Acc]
		Ent.tgl.value = defChannel == Acc
	end)

	if defChannel == nil then
		defChannel = channelList[1]
		if defChannel then
			selectChannelind = 1
		end
	else
		for i,v in ipairs(channelList) do
			if defChannel == v then
		 		selectChannelind = i
		 	end
		end
	end

	show_channel(defChannel)
end

local function get_curr_channel()
	local GrpAccs = Ref.SubNode.SubChat.SubInput.GrpAccs
	local tgl = libugui.GetTogglesOn(GrpAccs.go)[1]
	local curCha = ui.index(tgl)
	return channelList[curCha]
end


local function rfsh_chat_ent(Msg)
	if Msg == nil or Msg.Content == nil then
		return
	end
	
	local Sender = Msg.Sender
	local Content = Msg.Content
	local contentStr = ""

	local ChatChannelName = TEXT.ChatChannelName

	local isSelf = Sender.id == DY_DATA:get_player().id
	if Msg.channel ~= 1 then
		contentStr = string.format(TEXT.fmtChatMsg,
			isSelf and "#FFFFFF" or "#FFFFFF", Sender.name, Content.text)
	else
		if isSelf then
			contentStr = string.format(TEXT.fmtWhisperMsg,
				"#FFFFFF", Msg.Receiver.name, Content.text)
		else
			contentStr = string.format(TEXT.fmtChatMsg,
				"#FFFFFF", Sender.name, Content.text)
		end
	end

	return string.format("[%s]%s", ChatChannelName[Msg.channel], contentStr)
end

local function rfsh_input_info(currChannel)
	-- 私聊频道处理
	local SubInput = Ref.SubNode.SubChat.SubInput
	local isWhisper = currChannel ~= 1

	local SubCnt = Ref.SubNode.SubChat.SubInput.SubCnt
	local hasContent = SubCnt.inp.text and #SubCnt.inp.text > 0
	SubInput.btnSend.interactable = isWhisper and hasContent

	if isWhisper then
		local Receiver = DY_DATA.Chat.Receiver
		SubInput.SubCnt.lbWhisper.text = Receiver and
			string.format(TEXT.fmtSpeakTo, "#7AB23F", Receiver.name) or TEXT.tipNoChatTarget
	end
end

local function rfsh_detail_chat(forced)
	self.ChatMsgs = DY_DATA.NewChatMsgs

	local SimpleStr = {}

	if ChatMsgs and #ChatMsgs > 0 then
		for i = 1,#ChatMsgs do

				local Msg = ChatMsgs[i]
				local str = rfsh_chat_ent(Msg)
				table.insert(SimpleStr, str)
		end
	end
	libugui.KillTween(Ref.SubNode.SubChat.lbContact)
    libugui.SetAlpha(Ref.SubNode.SubChat.lbContact, 1)

	Ref.SubNode.SubChat.lbContact.text = table.concat(SimpleStr, "\n")

	libugui.DOTween("Alpha", Ref.SubNode.SubChat.lbContact, 1, 0, {
            duration = 0.5, delay = 8,
        })

end

local function rfsh_chat_node(NodePos)
	libugui.AnchorPresets(Ref.SubNode.go, NodePos.ax, NodePos.ay, NodePos.ox, NodePos.oy)
	libunity.SetActive(Ref.SubNode.SubCtrl.go, NodePos.ctrl)
end

function change_channels_set( channel )
 	if channel ~= chatchannel then
		on_change_channels()
		--rfsh_detail_chat()
	end
end

local function other_wnd_open(Wnd)
	local NodePos = Wnd.ChatPos
	if NodePos == nil and Wnd.StatusBar == nil and not Wnd.fullScreen then return end

	local exist = false
	for i,v in ipairs(NodePosStack) do
		if v.name == Wnd.name then exist = true; break end
	end

	if not exist then
		table.insert(NodePosStack, 1, NodePos or { name = Wnd.name })
	end
	libugui.SetVisible(Ref.go, NodePos and not NodePos.hide)
	if NodePos then
		NodePos.name = Wnd.name
		rfsh_chat_node(NodePos)
		local NodeChannel = NodePos.channel
		if NodeChannel then
			on_change_channels(false,NodeChannel)
		end
	end

end

local function other_wnd_close(Wnd)
	local NodePos = Wnd.ChatPos
	if NodePos == nil and Wnd.StatusBar == nil and not Wnd.fullScreen then return end

	for i,v in ipairs(NodePosStack) do
		if v.name == Wnd.name then
			table.remove(NodePosStack, i)
		break end
	end

	local NodePos = NodePosStack[1]
	libugui.SetVisible(Ref.go, NodePos ~= nil)
	if NodePos then
		rfsh_chat_node(NodePos)
	end

end

--!* [开始] 自动生成函数 *--

function on_input_content_changed(inp, text)
	local SubInput = Ref.SubNode.SubChat.SubInput

	SubInput.btnSend.interactable = text and #text > 0
end

function on_subnode_subchat_subinput_btnsend_click(btn)
	local currChannel = channelList[selectChannelind]
	local Receiver
	--if currChannel == 1 then
	--	Receiver = DY_DATA.Chat.Receiver
	--	if Receiver == nil then
	--		UI.Toast.norm(TEXT.tipSendToNobody)
	--	return end
	--end
	local text = Ref.SubNode.SubChat.SubInput.SubCnt.inp.text
	if text == nil or #text == 0 then
		UI.Toast.norm(TEXT.tipSendEmptyMsg)
	return end

	if NW.connected() then
		NW.CHAT.send(currChannel, Receiver, 1, text)
	else
		DY_DATA.d_send_chatmsg(currChannel, Receiver, text)
	end
	Ref.SubNode.SubChat.SubInput.SubCnt.inp.text = nil
end

function on_subnode_subchat_subinput_grpaccs_entacc_click(tgl)
	local currChannel = ui.index(tgl)
	if tgl.value then
		selectChannelind = currChannel
		local curCha = channelList[currChannel]
		show_channel(curCha)

		Ref.SubNode.SubChat.SubInput.tglList.value = false
	else
		if currChannel == selectChannelind then
			selectChannelind = 0
			show_channel(selectChannelind)
		end
	end
	--rfsh_detail_chat()
end

function on_subnode_subchat_subinput_tgllist_click(tgl)
	local value = tgl.value
	Ref.SubNode.SubChat.SubInput.GrpAccs.go:SetActive(value)
end


function on_subnode_subctrl_tglshrink_click(tgl)
	libunity.SetActive(Ref.SubNode.SubChat.go, tgl.value)
end

function on_subnode_subctrl_btnchatui_click(btn)
	local Bag = { }
	Bag.title = TEXT["n.chat"]
	Bag.pageIcon = "CommonIcon/ico_main_058"
	ui.open("UI/WNDChatNew", nil, Bag)
end
--!* [结束] 自动生成函数  *--

function init_view()
	ui.group(Ref.SubNode.SubChat.SubInput.GrpAccs)
	--!* [结束] 自动生成代码 *--
	Ref.SubNode.SubChat.SubInput.SubCnt.inp.characterLimit = CVar.CHAT.TypeWordsLimit

	DY_DATA.RedSystem:BuildRedDotUI(CVar.RedDotName.ChatNew,Ref.SubNode.SubCtrl.spNode)

	local GUIDE = _G.PKG["guide/api"]

	libunity.SetActive(Ref.SubNode.go, GUIDE.load(0) == 0)
end

function init_logic()
	on_change_channels()

	local SubCnt = Ref.SubNode.SubChat.SubInput.SubCnt
	on_input_content_changed(SubCnt.inp, SubCnt.inp.text)

 	rfsh_detail_chat()
end

function show_view()
	libugui.SetVisible(Ref.go, true)
end

function on_recycle()
	DY_DATA.RedSystem:UnbuildRedDotUI(CVar.RedDotName.ChatNew)
end

Handlers = {
	["CLIENT.SC.WND_OPEN"] = other_wnd_open,
	["CLIENT.SC.TOPBAR_WND_SHOW"] = other_wnd_open,
	["CLIENT.SC.WND_CLOSE"] = other_wnd_close,
	["CLIENT.SC.TOPBAR_WND_HIDE"] = other_wnd_close,

	["CHAT.SC.CHAT_BROADCAST"] = function ()
		rfsh_detail_chat()
	end,

	["GUILD.SC.APPLY_JOIN_GUILD"] = function(applyGuildID)
		if applyGuildID then
			return
		end
		on_change_channels(true)

	end,
}
return self

