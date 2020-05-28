--
-- @file    ui/social/lc_wndchat_new.lua
-- @author  Administrator
-- @date    2018-09-11 17:45:20
-- @desc    WNDChatNew
--

local self = ui.new()
local _ENV = self
self.StatusBar = {
	HealthyBar = true,
}
--SubMembers节点 选中了第几个子对象
local membersSelectedIdx = 0
--SubSymmetry.SubLeft节点 选中了第几个子对象
local symmetrySelectedIdx = 0
--好友申请、好友搜索和黑名单共用一个界面UI（SubMembers节点）bottomBtnEnum标识当前是哪个界面
local bottomBtnEnum = 0 -- 1：好友申请，2：好友搜索 （黑名单用currentchannel区分）

local function rfsh_guild_badge(SubGuild,badgeStr)

	local guildBadge = _G.DEF.GuildBadge.gen(badgeStr)
	guildBadge:show_bgcolor(SubGuild.spGuildBadge)
	guildBadge:show_sdicon(SubGuild.SubMask.spGuildBadgeSd)
	guildBadge:show_sdcolor(SubGuild.SubMask.spGuildBadgeSd)
	guildBadge:show_pticon(SubGuild.SubMask.spGuildBadgePt)
	guildBadge:show_ptcolor(SubGuild.SubMask.spGuildBadgePt)
end

local function find_changnel_tabIndex(channel)
	local channelInd = 0
	for i,v in ipairs(self.channelList) do
		if v == channel then
			channelInd = i
			break
		end
	end
	return channelInd
end

local function members_selected_reset()
	membersSelectedIdx = 0
	libugui.SetVisible(Ref.SubMembers.spSelected, false)
	libunity.SetParent(Ref.SubMembers.spSelected, Ref.SubMembers.go)

	libugui.SetInteractable(Ref.SubMembers.SubBtn.btnIgnore, false)
	libugui.SetInteractable(Ref.SubMembers.SubBtn.btnAgree, false)
end

local function members_selected(go)
	libugui.SetVisible(spMemberSelected, true)
	libunity.SetParent(spMemberSelected, go, false, -1)

	libugui.SetInteractable(Ref.SubMembers.SubBtn.btnIgnore, true)
	libugui.SetInteractable(Ref.SubMembers.SubBtn.btnAgree, true)
end

local function symmetry_selected(go)
	libugui.SetVisible(spChatSelected, true)
	libunity.SetParent(spChatSelected, go, false, -1)
end


local function rfsh_chat_ent(Msg,Ent)
	local Sender = Msg.Sender
	local Content = Msg.Content
	local isSelf = Sender.id == DY_DATA:get_player().id

	local selfone = isSelf and 1 or 0
	--local selfzero = isSelf and 0 or 1
	--local selfpositive = isSelf and 1 or -1
	local selfnegative = isSelf and -1 or 1

	local face , hair = AvatarLIB.get_player_head(Sender.gender,Sender.face,Sender.hair,Sender.haircolor)

	libugui.SetSprite(GO(Ent.spHead,"spFace"), "PlayerIcon/"..face)
	libugui.SetSprite(GO(Ent.spHead,"spHair"), "PlayerIcon/"..hair)

    libugui.SetAnchor(Ent.spHead,selfone,1,selfone,1)
	libugui.SetAnchoredPos(Ent.spHead, selfnegative * 51, -51)

	libugui.SetLabelAlign(Ent.lbName,isSelf and CVar.TextAnchor.MiddleRight or CVar.TextAnchor.MiddleLeft)

	libugui.SetLabelAlign(Ent.lbContent,isSelf and CVar.TextAnchor.MiddleRight or CVar.TextAnchor.MiddleLeft)

    Ent.lbName.text = Sender.name
	Ent.lbContent.text = Content.text
	Ent.lbTime.text = os.secs2date("%H:%M", Msg.time)
end
local function rfsh_right_chat_ent(Msg,Ent)
	local Sender = Msg.Sender
	local Content = Msg.Content
	local isSelf = Sender.id == DY_DATA:get_player().id

	local selfone = isSelf and 1 or 0
	--local selfzero = isSelf and 0 or 1
	local selfpositive = isSelf and 1 or -1
	--local selfnegative = isSelf and -1 or 1

	local face , hair = AvatarLIB.get_player_head(Sender.gender,Sender.face,Sender.hair,Sender.haircolor)

	libugui.SetSprite(GO(Ent.spHead,"spFace"), "PlayerIcon/"..face)
	libugui.SetSprite(GO(Ent.spHead,"spHair"), "PlayerIcon/"..hair)

    libugui.SetAnchor(Ent.spHead,selfone,1,selfone,1)
	libugui.SetAnchoredPos(Ent.spHead, selfpositive * 42, -36)

	libugui.SetLabelAlign(Ent.lbName,isSelf and CVar.TextAnchor.UpperRight or CVar.TextAnchor.UpperLeft)

	libugui.SetLabelAlign(Ent.lbContent,isSelf and CVar.TextAnchor.UpperRight or CVar.TextAnchor.UpperLeft)

    Ent.lbName.text = Sender.name
	Ent.lbContent.text = Content.text
	Ent.lbTime.text = os.secs2date("%H:%M", Msg.time)
end
local function on_refresh_symmetry_left_item(memberinfo,itemIndex,state)
	local Ent = Ref.SubSymmetry.SubLeft.SubLayout.SubScroll.SubView.GrpFormulaList:get(itemIndex)
	if Ent then
		libunity.SetActive(Ent.spPoint,state and symmetrySelectedIdx ~= itemIndex)
	end
end

local function on_refresh_symmetry_left()
	local memberlist = {}
	if currChannel == CVar.ChatChannel.FRIEND then
		memberlist = DY_DATA.friendList
	elseif currChannel == CVar.ChatChannel.STRANGER then
		memberlist = NW.CHAT.RecentlyMets
	else
		return {}
	end

	if memberlist == nil then
		memberlist ={}
	end
	local GrpFormulas = Ref.SubSymmetry.SubLeft.SubLayout.SubScroll.SubView.GrpFormulaList
	libugui.SetLoopCap(GrpFormulas.go, #memberlist, true)
	return memberlist
end

local function member_change_newstate(player)
	for i,v in ipairs(DY_DATA.friendList) do
		if player == v.id then
			if currChannel == CVar.ChatChannel.FRIEND and state and i == symmetrySelectedIdx then
				return
			end

			if currChannel ~= CVar.ChatChannel.STRANGER then
				local haveNew = v.haveNew -- rawget(v ,"haveNew")
				on_refresh_symmetry_left_item(v,i,haveNew)
			end
			return
		end
	end

	for i,v in ipairs(NW.CHAT.RecentlyMets) do
		if player == v.id then
			if currChannel == CVar.ChatChannel.STRANGER and state and i == symmetrySelectedIdx then
				return
			end
			
			if currChannel ~= CVar.ChatChannel.FRIEND then
				local haveNew = v.haveNew -- rawget(v ,"haveNew")
				on_refresh_symmetry_left_item(v,i,haveNew)
			end
			return
		end
	end
end

local function update_symmetry_selected(index)
	symmetrySelectedIdx = index
	local info = nil
	if self.currChannel == CVar.ChatChannel.FRIEND then
		info = DY_DATA.friendList[index]
	elseif self.currChannel == CVar.ChatChannel.STRANGER then
		info = NW.CHAT.RecentlyMets[symmetrySelectedIdx]
	end

	if info then
		info.haveNew = false --rawset(info ,"haveNew",false)
		Ref.SubSymmetry.SubRight.lbTitle.text = info.name
		member_change_newstate(info.id)
	end
end

local function on_refresh_symmetry_right()
	local channel = 1

	local operation = nil
	if self.currChannel == CVar.ChatChannel.FRIEND then
		--好友界面，选中的好友
		operation = DY_DATA.friendList[symmetrySelectedIdx]
	elseif self.currChannel == CVar.ChatChannel.STRANGER then
		--陌生人界面，选中的陌生人
		operation = NW.CHAT.RecentlyMets[symmetrySelectedIdx]
	end

	if operation then
		self.rightinfos = DY_DATA.ChatMsgs[operation.id]
	else
		self.rightinfos = {}
	end
	if self.rightinfos ==nil then
		self.rightinfos = {}
	end
	local GrpFormulas = Ref.SubSymmetry.SubRight.SubScroll.SubView.GrpMsgs

	--libugui.SetLoopCap(GrpFormulas.go, #rightinfos, true)

	GrpFormulas:dup(#rightinfos, function (i, Ent, isNew)

		local msginfo = self.rightinfos[i]

		if msginfo then
			rfsh_right_chat_ent(msginfo,Ent)
		end
	end)

    local scroll = Ref.SubSymmetry.SubRight.SubScroll.go:GetComponent("ScrollRect")

    if not self.freezeEnt then
        libugui.DOTween(nil, scroll, nil, 0, { duration = 0.2 })
	end

end

local function symmetry_selected_reset()
	symmetrySelectedIdx = 0
	Ref.SubSymmetry.SubRight.lbTitle.text = ""
	libugui.SetVisible(Ref.SubSymmetry.SubLeft.spSelected, false)
	libunity.SetParent(Ref.SubSymmetry.SubLeft.spSelected, Ref.SubSymmetry.SubLeft.go)
	on_refresh_symmetry_right()
end

local function on_refresh_symmetry(forceselect)

	symmetry_selected_reset()

	local memberlist = on_refresh_symmetry_left()

	local leftScroll = Ref.SubSymmetry.SubLeft.SubLayout.SubScroll
	local scroll = leftScroll.go:GetComponent("ScrollRect")
	scroll.verticalNormalizedPosition = 1
	on_refresh_symmetry_right()
	if forceselect then
	-- 延迟一帧更新
		local GrpFormulas = Ref.SubSymmetry.SubLeft.SubLayout.SubScroll.SubView.GrpFormulaList
		libunity.Invoke(leftScroll.go, 0, function ()
			symmetry_selected(GrpFormulas:find(1).go)
			update_symmetry_selected(1)
		end)
		Context.PrivateChat = nil
	end
end

local function on_refresh_members(memberlist,btnEnum)
	if memberlist == nil then
		memberlist = {}
	end

	bottomBtnEnum = btnEnum
	if self.currChannel == CVar.ChatChannel.BLACK then
		libunity.SetActive(Ref.SubMembers.SubBtn.go,false)
		libunity.SetActive(Ref.SubMembers.SubBlack.go,true)
		libunity.SetActive(Ref.SubMembers.SubSearch.go,false)
	elseif self.currChannel == CVar.ChatChannel.FRIEND then
		if btnEnum == 1 then--申请列表
			libunity.SetActive(Ref.SubMembers.SubBtn.go,true)
			libunity.SetActive(Ref.SubMembers.SubBlack.go,false)
			libunity.SetActive(Ref.SubMembers.SubSearch.go,false)
		else--搜索
			libunity.SetActive(Ref.SubMembers.SubBtn.go,false)
			libunity.SetActive(Ref.SubMembers.SubBlack.go,false)
			libunity.SetActive(Ref.SubMembers.SubSearch.go,true)
		end
	end

	members_selected_reset()

	libunity.SetActive(Ref.SubMembers.SubScroll.lbEmpleResult,#memberlist == 0)

	local GrpFormulas = Ref.SubMembers.SubScroll.GrpFormulaList
	libugui.SetLoopCap(GrpFormulas.go, #memberlist, true)
	local memberScroll = Ref.SubMembers.SubScroll
	local scroll = memberScroll.go:GetComponent("ScrollRect")
	scroll.verticalNormalizedPosition = 1

end

local function on_refresh_subfull()

	self.ChatMsgs = DY_DATA.ChatMsgs[self.currChannel]

	local GrpFormulas = Ref.SubFull.SubScroll.SubView.GrpMsgs
	if ChatMsgs then
		libugui.SetLoopCap(GrpFormulas.go, #ChatMsgs, true)
	else
		libugui.SetLoopCap(GrpFormulas.go, 0, true)
	end
	local memberScroll = Ref.SubFull.SubScroll
	local scroll = memberScroll.go:GetComponent("ScrollRect")

    --if not self.freezeEnt then
        libugui.DOTween(nil, scroll, nil, 0, { duration = 0.2 })
	--end
end

local function on_refresh_mainui(channel,forceselect)
	self.currChannel = channel

	if channel == 7 then
		libunity.SetActive(Ref.SubFull.go, false)
		libunity.SetActive(Ref.SubMembers.go, true)
		libunity.SetActive(Ref.SubSymmetry.go, false)
		Ref.SubMembers.lbTitle.text = TEXT["chat.blacklist"]
		on_refresh_members(DY_DATA.blackList,bottomBtnEnum)
	elseif channel == 1 then
		libunity.SetActive(Ref.SubFull.go, false)
		libunity.SetActive(Ref.SubMembers.go, false)
		libunity.SetActive(Ref.SubSymmetry.go, true)
		Ref.SubSymmetry.SubLeft.lbTitle.text = TEXT["chat.maillist"]
		libunity.SetActive(Ref.SubSymmetry.SubLeft.SubLayout.SubSearch.go, true)
		on_refresh_symmetry(forceselect)

		DY_DATA.RedSystem:SetRedDotState(CVar.RedDotName.FriendNew,false)
	elseif channel == 6 then
		libunity.SetActive(Ref.SubFull.go, false)
		libunity.SetActive(Ref.SubMembers.go, false)
		libunity.SetActive(Ref.SubSymmetry.go, true)
		Ref.SubSymmetry.SubLeft.lbTitle.text = TEXT["chat.stranger"]
		libunity.SetActive(Ref.SubSymmetry.SubLeft.SubLayout.SubSearch.go, false)
		on_refresh_symmetry(forceselect)

		DY_DATA.RedSystem:SetRedDotState(CVar.RedDotName.StrangerNew,false)
	else
		libunity.SetActive(Ref.SubFull.go, true)
		libunity.SetActive(Ref.SubMembers.go, false)
		libunity.SetActive(Ref.SubSymmetry.go, false)

		on_refresh_subfull()
	end
end
local function check_is_friend(ReceiverId)
	if ReceiverId == DY_DATA:get_player().id then
		return false
	end
	local isFriend = false
	local theFriendInd = 0
	local theFriendInfo = nil
	for i,v in ipairs(DY_DATA.friendList) do
		if ReceiverId == v.id then
			isFriend = true
			theFriendInd = i
			theFriendInfo = v
			break
		end
	end
	return isFriend ,theFriendInd ,theFriendInfo
end
local function insert_friends(Receiver)
	local isFriend ,theFriendInd, theFriendInfo = check_is_friend(Receiver.id)
	if isFriend then
		table.remove(DY_DATA.friendList,theFriendInd)
		table.insert(DY_DATA.friendList,1,theFriendInfo)

	end

	return isFriend ,theFriendInfo
end
local function insert_recentlymets(Receiver)
	if Receiver.id == DY_DATA:get_player().id then
		return
	end

	local isFriend = NW.FRIEND.check_isfriend(Receiver.id)

	if isFriend then
		return
	end

	for i,v in ipairs(NW.CHAT.RecentlyMets) do
		 if Receiver.id == v.id then
		 	table.remove(NW.CHAT.RecentlyMets,i)
		 	break
		 end
	end

	table.insert(NW.CHAT.RecentlyMets,1,Receiver)

end
function on_privat_chat(Receiver)

	local isFriend = insert_friends(Receiver)
	local tabInd = 0
	if isFriend then
		tabInd = find_changnel_tabIndex(CVar.ChatChannel.FRIEND)
	else
		--私聊 将对方加入自己的陌生人列表
		insert_recentlymets(Receiver)
		tabInd = find_changnel_tabIndex(CVar.ChatChannel.STRANGER)

	end
	Context.PrivateChat = Receiver

 	local tab = Ref.GrpTabs:find(tabInd)
 	if tab then
 		tab.tgl.value = true
 	else
 		local ret = 359
 		local err = NW.get_error(ret)
 		err = cfgname({ name = err, id = ret,})
            _G.UI.Toast.make(nil, err):show()
 	end
	--on_refresh_mainui(4,true)
end
--!* [开始] 自动生成函数 *--

function on_grptabs_enttab_click(tgl)
	local value = tgl.value
	if value then
		libugui.SetAlpha(GO(tgl, "spTabBg"), 1)
		local index = Ref.GrpTabs:getindex(tgl)
		local channel = channelList[index]

		on_refresh_mainui(channel,Context.PrivateChat)
	else
		libugui.SetAlpha(GO(tgl, "spTabBg"), 0.5)
	end
end

function on_subfull_chatmsg_ent(go, i)
	local index = i + 1
	Ref.SubFull.SubScroll.SubView.GrpMsgs:setindex(go, index)

	local msginfo = self.ChatMsgs[index]

	if msginfo then
		local Ent = ui.ref(go)
		rfsh_chat_ent(msginfo,Ent)
	end
end

function on_subfull_subscroll_subview_grpmsgs_entmsg_click(btn,event)
	local index = Ref.SubFull.SubScroll.SubView.GrpMsgs:getindex(btn)
	local msginfo = self.ChatMsgs[index]

	if msginfo and msginfo.Sender.id ~= DY_DATA:get_player().id then
		local rightmenu = _G.PKG["ui/rightmenu"]

		local MenuArr = {rightmenu.AddFriend ,rightmenu.Whisper}
		local rSource =  CVar.ChatSource.None
		if self.currChannel ==  CVar.ChatChannel.NEARBY then
			rSource = CVar.ChatSource.Nearby
		elseif self.currChannel == CVar.ChatChannel.GUILD then
			rSource = CVar.ChatSource.Guild
		elseif self.currChannel == CVar.ChatChannel.TEAM then
			rSource = CVar.ChatSource.Team
		end
		ui.show("UI/WNDPlayerRightMenu", 0,
			{ pos = event.position, MenuArr = MenuArr,
			Args = { msginfo.Sender.id, msginfo.Sender.name,self.depth, rSource},
			})
	end
end

function on_SubScroll_input_content_changed(inp, text)
	local SubInput = Ref.SubFull.SubScroll.SubInput

	SubInput.btnSend.interactable = text and #text > 0
end

function on_subfull_subscroll_subinput_btnsend_click(btn)
	local Receiver

	local radioAch = DY_DATA.Achieves[_G.CVar.Achieves.RADIO]
	if radioAch == nil then
	--修理完成收音机前使用聊天功能触发
	end

	if self.currChannel ==  CVar.ChatChannel.NEARBY then
		--附近频道聊天生成日志

		local _, Entrance = DY_DATA.World:find_entrance()
	elseif self.currChannel == CVar.ChatChannel.GUILD then
		--避难所频道聊天生成日志
		local player = DY_DATA:get_player()
	elseif self.currChannel == CVar.ChatChannel.TEAM then

	end

	local text = Ref.SubFull.SubScroll.SubInput.SubCnt.inp.text
	if text == nil or #text == 0 then
		UI.Toast.norm(TEXT.tipSendEmptyMsg)
	return end

	if NW.connected() then
		NW.CHAT.send(self.currChannel, Receiver, 1, text)
	else
		DY_DATA.d_send_chatmsg(self.currChannel, Receiver, text)
	end
	Ref.SubFull.SubScroll.SubInput.SubCnt.inp.text = ""
end

function on_subsymmetry_subleft_sublayout_subsearch_btnsearch_click(btn)
	NW.FRIEND.RequestFriendSearch(Ref.SubSymmetry.SubLeft.SubLayout.SubSearch.SubSearchCnt.inp.text)
	libunity.SetActive(Ref.SubFull.go, false)
	libunity.SetActive(Ref.SubMembers.go, true)
	libunity.SetActive(Ref.SubSymmetry.go, false)
	Ref.SubMembers.lbTitle.text = TEXT["chat.search"]
	on_refresh_members(tempSearchList,2)
	Ref.SubSymmetry.SubLeft.SubLayout.SubSearch.SubSearchCnt.inp.text = ""
	--点击搜索功能触发
end

function on_subsymmetry_subleft_sublayout_subsearch_btnapplelist_click(btn)
	libunity.SetActive(Ref.SubFull.go, false)
	libunity.SetActive(Ref.SubMembers.go, true)
	libunity.SetActive(Ref.SubSymmetry.go, false)
	Ref.SubMembers.lbTitle.text = TEXT["chat.applyList"]

	NW.FRIEND.hadCheckApplyList()

	on_refresh_members(DY_DATA.friendApplyList,1)
end

function on_serach_input_content_changed(inp, text)
	local SubSearch = Ref.SubSymmetry.SubLeft.SubLayout.SubSearch

	SubSearch.btnSearch.interactable = text and #text > 0


	libunity.SetActive(Ref.SubSymmetry.SubLeft.SubLayout.SubSearch.btnClearInp, text and #text > 0)
end

function on_subsymmetry_subleft_sublayout_subsearch_btnclearinp_click(btn)
	Ref.SubSymmetry.SubLeft.SubLayout.SubSearch.SubSearchCnt.inp.text =""
end

function on_subleft_grpformula_ent(go, i)
	local index = i + 1
	Ref.SubSymmetry.SubLeft.SubLayout.SubScroll.SubView.GrpFormulaList:setindex(go, index)
	local memberinfo = nil

	if self.currChannel == CVar.ChatChannel.FRIEND then
		memberinfo = DY_DATA.friendList[index]
	elseif self.currChannel == CVar.ChatChannel.STRANGER then
		memberinfo = NW.CHAT.RecentlyMets[index]
	end
	if memberinfo then
		local Ent = ui.ref(go)
		libugui.SetColor(Ent.spProc, index%2 ==0 and "#616161" or "#474747")

		Ent.lbName.text = TEXT.NameAndLevel:csfmt(memberinfo.name,memberinfo.level)
		if memberinfo.guildName and memberinfo.guildName ~= "" then
			Ent.lbGuildName.text = memberinfo.guildName
		else
			Ent.lbGuildName.text = TEXT.GuildNameEmpty
		end

		rfsh_guild_badge(Ent,memberinfo.guildIcon)
		
		if memberinfo.isOnline then
			Ent.lbTime.text =  TEXT["online"]
		else
			if memberinfo.lastTime then
			local logTime = os.date2secs() - memberinfo.lastTime
				Ent.lbTime.text = string.format(TEXT.fmtOffline, os.last2string(logTime, 1))
			else
				Ent.lbTime.text =  TEXT["online"]
			end
			--Ent.lbTime.text = "" .. memberinfo.lastTime
		end
		local haveNew = memberinfo.haveNew  -- rawget(memberinfo ,"haveNew")

		libunity.SetActive(Ent.spPoint, haveNew and symmetrySelectedIdx ~= index )
	end
end

function on_subsymmetry_subleft_sublayout_subscroll_subview_grpformulalist_entformula_click(btn)
	symmetry_selected(btn)
	local index = Ref.SubSymmetry.SubLeft.SubLayout.SubScroll.SubView.GrpFormulaList:getindex(btn)

	if symmetrySelectedIdx ~= index then
		update_symmetry_selected(index)

		on_refresh_symmetry_right()
	end
end

function on_subsymmetry_subright_subscroll_subview_grpmsgs_entmsg_subevent_ptrdown(evt, data)
	self.freezeEnt = true
end

function on_subsymmetry_subright_subscroll_subview_grpmsgs_entmsg_subevent_ptrup(evt, data)
	self.freezeEnt = false
end

function on_subsymmetry_subright_btnoperation_click(btn,event)
	if self.currChannel == CVar.ChatChannel.FRIEND then
		local info = DY_DATA.friendList[symmetrySelectedIdx]
		if info then
			local rightmenu = _G.PKG["ui/rightmenu"]

			local MenuArr = {rightmenu.ViewProfile ,rightmenu.DelFriend ,rightmenu.AddBlack }
			local Stage =  DY_DATA:get_stage()
			if Stage then
				local MapDat = config("maplib").get_dat(Stage.Base.id)

				if MapDat and MapDat.inviteButtonDisplay == 1 then
					local inviteToLocation = { name = "RightMenu.InviteLocation" ,
					 action = NW.CHAT.InviteToLocation }
					table.insert(MenuArr,inviteToLocation)
				end
			end
			local player = DY_DATA:get_player()
			local Session = _G.PKG["network/login"].get_session()
			if Session.Server.serverId == info.serverId and player.guildID ~= 0
				and info.guildID ==0 then
				local inviteToGuild = { name = "RightMenu.Guild_Invite" ,
				 action = NW.CHAT.InviteToGuild }

				table.insert(MenuArr,inviteToGuild)
			end
			ui.show("UI/WNDPlayerRightMenu", 0,
				{ pos = event.position, MenuArr = MenuArr,
				Args = { info.id, info.name,self.depth, CVar.ChatSource.None},
				})
		end
	elseif self.currChannel == CVar.ChatChannel.STRANGER then
		local info = NW.CHAT.RecentlyMets[symmetrySelectedIdx]
		if info then
			local rightmenu = _G.PKG["ui/rightmenu"]

			local MenuArr = {rightmenu.AddFriend ,rightmenu.AddBlack }
			local Stage =  DY_DATA:get_stage()
			if Stage then
				local MapDat = config("maplib").get_dat(Stage.Base.id)

				if MapDat and MapDat.inviteButtonDisplay == 1 then
					local inviteToLocation = { name = "RightMenu.InviteLocation" ,
					 action = NW.CHAT.InviteToLocation }
					table.insert(MenuArr,inviteToLocation)
				end
			end

			ui.show("UI/WNDPlayerRightMenu", 0,
				{ pos = event.position, MenuArr = MenuArr,
				Args = { info.id, info.name,self.depth, CVar.ChatSource.None},})
		end
	end
end

function on_SubSymmetry_input_content_changed(inp, text)
	local SubInput = Ref.SubSymmetry.SubInput

	SubInput.btnSend.interactable = text and #text > 0
end

function on_subsymmetry_subinput_btnsend_click(btn)
	local channel = 1

	local Receiver

	if self.currChannel == CVar.ChatChannel.FRIEND then
		local info = DY_DATA.friendList[symmetrySelectedIdx]
		if info then
			Receiver = {id = info.id, name = info.name}
		end
		--好友对话后生成日志

	elseif self.currChannel == CVar.ChatChannel.STRANGER then
		local info = NW.CHAT.RecentlyMets[symmetrySelectedIdx]
		if info then
			Receiver = {id = info.id, name = info.name}
		end
		--陌生人对话后生成日志
	end

	if Receiver == nil then
		UI.Toast.norm(TEXT.tipSendToNobody)
	return end

	local text = Ref.SubSymmetry.SubInput.SubCnt.inp.text
	if text == nil or #text == 0 then
		UI.Toast.norm(TEXT.tipSendEmptyMsg)
	return end

	if NW.connected() then
		NW.CHAT.send(channel, Receiver, 1, text)
	else
		DY_DATA.d_send_chatmsg(channel, Receiver, text)
	end
	Ref.SubSymmetry.SubInput.SubCnt.inp.text = ""
end

function on_submembers_grpformula_ent(go, i)
	local index = i + 1

	Ref.SubMembers.SubScroll.GrpFormulaList:setindex(go, index)
	local memberinfo = nil
	if self.currChannel == CVar.ChatChannel.BLACK then
		memberinfo = DY_DATA.blackList[index]
	elseif self.currChannel == CVar.ChatChannel.FRIEND then
		if bottomBtnEnum == 1 then
			memberinfo = DY_DATA.friendApplyList[index]
		else
			memberinfo = tempSearchList[index]
		end
	end

	if memberinfo then
		local Ent = ui.ref(go)
		libugui.SetColor(Ent.spProc, index%2 ==0 and "#616161" or "#474747")

		Ent.lbName.text = TEXT.NameAndLevel:csfmt(memberinfo.name,memberinfo.level)
		if memberinfo.guildName and memberinfo.guildName ~= "" then
			Ent.lbGuildName.text = memberinfo.guildName
		else
			Ent.lbGuildName.text = TEXT.GuildNameEmpty
		end
		
		rfsh_guild_badge(Ent,memberinfo.guildIcon)
		
		if memberinfo.isOnline then
			Ent.lbTime.text =  TEXT["online"]
		else
			local logTime = os.date2secs() - memberinfo.lastTime
			Ent.lbTime.text = string.format(TEXT.fmtOffline, os.last2string(logTime, 1))
			--Ent.lbTime.text = "" .. memberinfo.lastTime
		end
	end
end

function on_submembers_subscroll_grpformulalist_entformula_click(btn)
	members_selected(btn)
	local index = Ref.SubMembers.SubScroll.GrpFormulaList:getindex(btn)
	if membersSelectedIdx ~= index then
		membersSelectedIdx = index
	end
end

function on_submembers_subbtn_btncancel_click(btn)
	libunity.SetActive(Ref.SubFull.go, false)
	libunity.SetActive(Ref.SubMembers.go, false)
	libunity.SetActive(Ref.SubSymmetry.go, true)
end

function on_submembers_subbtn_btnignore_click(btn)
	if membersSelectedIdx ~= 0 then
		if membersSelectedIdx <= #DY_DATA.friendApplyList then
			local applyinfo = DY_DATA.friendApplyList[membersSelectedIdx]
			NW.FRIEND.RequestApplyOperate(applyinfo.id,false)
		end
	end
end

function on_submembers_subbtn_btnagree_click(btn)
	if membersSelectedIdx ~= 0 then
		if membersSelectedIdx <= #DY_DATA.friendApplyList then
			local applyinfo = DY_DATA.friendApplyList[membersSelectedIdx]
			NW.FRIEND.RequestApplyOperate(applyinfo.id,true)
		end
	end
end

function on_submembers_subblack_btnremove_click(btn)
	if membersSelectedIdx ~= 0 then
		if membersSelectedIdx <= #DY_DATA.blackList then
			UI.MBox.make("MBNormal")
				:set_param("content", TEXT["Remove Black"])
				:set_event(function ()
					local blackinfo = DY_DATA.blackList[membersSelectedIdx]
					NW.FRIEND.RequestRemoveBlackList(blackinfo.id)
				end, function ()

				end)
				:show()

		end
	end
end

function on_submembers_subsearch_btncancel_click(btn)
	libunity.SetActive(Ref.SubFull.go, false)
	libunity.SetActive(Ref.SubMembers.go, false)
	libunity.SetActive(Ref.SubSymmetry.go, true)
	tempSearchList = nil
end

function on_submembers_subsearch_btnapply_click(btn)
	if membersSelectedIdx ~= 0 then
		if tempSearchList and membersSelectedIdx <= #tempSearchList then
			local applerinfo = tempSearchList[membersSelectedIdx]

			NW.FRIEND.RequestAddFriend(applerinfo.id)
		end
	end
end

function on_btnset_click(btn)

	ui.open("UI/WNDChannelSet", self.depth + 1)
end



--[[--!* [结束] 自动生成函数  *--]]
--!* [结束] 自动生成函数  *--


function init_view()

	self.AvatarLIB = config("avatarlib")

	ui.group(Ref.GrpTabs)
	ui.group(Ref.SubFull.SubScroll.SubView.GrpMsgs)
	ui.group(Ref.SubSymmetry.SubLeft.SubLayout.SubScroll.SubView.GrpFormulaList)
	ui.group(Ref.SubSymmetry.SubRight.SubScroll.SubView.GrpMsgs)
	ui.group(Ref.SubMembers.SubScroll.GrpFormulaList)
	--!* [结束] 自动生成代码 *--

	--ui.group(Ref.SubFull.SubScroll.SubView.GrpMsgs)
	--ui.group(Ref.SubMembers.SubScroll.GrpFormulaList)

	Ref.SubFull.SubScroll.SubInput.SubCnt.inp.characterLimit = CVar.CHAT.TypeWordsLimit
	Ref.SubSymmetry.SubInput.SubCnt.inp.characterLimit = CVar.CHAT.TypeWordsLimit

	self.spMemberSelected = Ref.SubMembers.spSelected
	self.spChatSelected = Ref.SubSymmetry.SubLeft.spSelected


	NW.FRIEND.RequestGetFriendList()
	NW.FRIEND.RequestGetBlackList()
end

function init_logic()
	self.channelList = {}

	local defChannel = CVar.ChatChannel.NEARBY

	local ChatChannelName = TEXT.ChatChannelName

	local radioAch = DY_DATA.Achieves[_G.CVar.Achieves.RADIO]
	local player = DY_DATA:get_player()

	table.insert(self.channelList, CVar.ChatChannel.NEARBY)

	if radioAch then
		table.insert(self.channelList, CVar.ChatChannel.FRIEND)
		defChannel = CVar.ChatChannel.FRIEND
	end

	if player.guildID ~= 0 then
		table.insert(self.channelList, CVar.ChatChannel.GUILD)
	end

	table.insert(self.channelList, CVar.ChatChannel.TEAM)

	if radioAch then
		table.insert(self.channelList, CVar.ChatChannel.STRANGER)
	end

	table.insert(self.channelList, CVar.ChatChannel.BLACK)


	if Context.PrivateChat then
		--检查私聊的频道是否是好友频道
		local isFriend = insert_friends(Context.PrivateChat)

		if not isFriend then
			--私聊 将对方加入自己的陌生人列表
			insert_recentlymets(Context.PrivateChat)

			defChannel = CVar.ChatChannel.STRANGER
		else
			defChannel = CVar.ChatChannel.FRIEND
		end
	end

	Ref.GrpTabs:dup(#self.channelList, function (i, Ent, isNew)
		local channel = self.channelList[i]

		local tabName = ChatChannelName[channel]
		Ent.lbTab.text = tabName
		Ent.lbChkTab.text = tabName
		if channel == defChannel then
			libugui.SetAlpha(Ent.spTabBg, 1)
			Ent.tgl.value = true
		else
			libugui.SetAlpha(Ent.spTabBg, 0.5)
		end

		if channel ==CVar.ChatChannel.FRIEND then
			DY_DATA.RedSystem:BuildRedDotUI(CVar.RedDotName.FriendNew,Ent.spTabBg)

		elseif channel == CVar.ChatChannel.STRANGER then

			DY_DATA.RedSystem:BuildRedDotUI(CVar.RedDotName.StrangerNew,Ent.spTabBg)

		end
	end)

	DY_DATA.RedSystem:BuildRedDotUI(CVar.RedDotName.FriendApply,Ref.SubSymmetry.SubLeft.SubLayout.SubSearch.btnAppleList)

	libugui.SetVisible(self.spMemberSelected, false)
	libugui.SetVisible(self.spChatSelected, false)
	libunity.SetActive(Ref.SubFull.go, false)
	libunity.SetActive(Ref.SubMembers.go, false)

	libunity.SetActive(Ref.SubSymmetry.SubLeft.SubLayout.SubSearch.btnClearInp, false)
	Ref.SubSymmetry.SubLeft.SubLayout.SubSearch.btnSearch.interactable = false

	Ref.SubSymmetry.SubInput.btnSend.interactable = false
	--libugui.SetAlpha(Ref.GrpSimple.go, 0)
	Ref.SubSymmetry.SubRight.lbTitle.text = ""

	on_refresh_mainui(defChannel,Context.PrivateChat)

	self.StatusBar.Menu = {
		icon = Context.pageIcon,
		name = "WNDChatNew",
		title = Context.title,
		Context = Context,
	}
end

function show_view()

end

function on_recycle()
	members_selected_reset()
	symmetry_selected_reset()

	DY_DATA.RedSystem:UnbuildRedDotUI(CVar.RedDotName.FriendNew)

	DY_DATA.RedSystem:UnbuildRedDotUI(CVar.RedDotName.StrangerNew)

	DY_DATA.RedSystem:UnbuildRedDotUI(CVar.RedDotName.FriendApply)

end
Handlers = {--FRIEND.SC.FRIEND_APPLY_LIST
	["FRIEND.SC.FRIEND_LIST"] = function()
		if self.currChannel == CVar.ChatChannel.FRIEND then --好友界面刷新好友列表
			on_refresh_symmetry()
		end
	end,
	["FRIEND.SC.FRIEND_ONLINE_STATE"] = function()
		if self.currChannel == CVar.ChatChannel.FRIEND then --好友界面刷新好友列表
			on_refresh_symmetry()
		end
	end,
	["FRIEND.SC.FRIEND_SEARCH"] = function(SearchList)
		if self.currChannel == CVar.ChatChannel.FRIEND then --好友搜索
			self.tempSearchList = SearchList
			if bottomBtnEnum == 2 then
				on_refresh_members(SearchList,bottomBtnEnum)
			end
		end
	end,
	["FRIEND.SC.FRIEND_APPLY_LIST"] = function()
		if self.currChannel == CVar.ChatChannel.FRIEND then --好友申请界面

			if bottomBtnEnum == 1 then --好友
				on_refresh_members(DY_DATA.friendApplyList,bottomBtnEnum)
			end
		end
	end,
	["FRIEND.SC.FRIEND_APPLY_OPERATE"] = function (success)
		if self.currChannel == CVar.ChatChannel.FRIEND then

			if bottomBtnEnum == 1 then
				on_refresh_members(DY_DATA.friendApplyList,bottomBtnEnum)
			end
		end
	end,
	["FRIEND.SC.FRIEND_MEMBER_INFO"] = function (operateType)
		if self.currChannel == CVar.ChatChannel.FRIEND then
			if operateType == 3 then
				if bottomBtnEnum == 1 then
					on_refresh_members(DY_DATA.friendApplyList,bottomBtnEnum)
				end
			elseif operateType == 2 then
				on_refresh_symmetry()
			elseif operateType == 1 then
				if bottomBtnEnum == 1 then
					on_refresh_members(DY_DATA.friendApplyList,bottomBtnEnum)
				end

				on_refresh_symmetry()

			elseif operateType == 5 then
				on_refresh_symmetry()
			end
		end
	end,
	["FRIEND.SC.JOIN_BLACKLIST"] = function (success)
		if success then
			if self.currChannel == CVar.ChatChannel.BLACK then
				on_refresh_members(DY_DATA.blackList,bottomBtnEnum)
			elseif self.currChannel == CVar.ChatChannel.FRIEND then
				on_refresh_symmetry()
			end
		end
	end,
	["FRIEND.SC.REMOVE_BLACKLIST"] = function (success)
		if success then
			if self.currChannel == CVar.ChatChannel.BLACK then
				on_refresh_members(DY_DATA.blackList,bottomBtnEnum)
			end
		end
	end,

	["CHAT.SC.CHAT_BROADCAST"] = function (Msgs)
		for i,v in ipairs(Msgs) do
			if v.channel == 5 or v.channel == 3 or v.channel == 4 then
				on_refresh_subfull()
			elseif v.channel ==1 then
				if currChannel ==CVar.ChatChannel.FRIEND then

					DY_DATA.RedSystem:SetRedDotState(CVar.RedDotName.FriendNew,false)

				end
				if currChannel == CVar.ChatChannel.STRANGER then

					DY_DATA.RedSystem:SetRedDotState(CVar.RedDotName.StrangerNew,false)

				end

				member_change_newstate(v.Sender.id)

				on_refresh_symmetry_right()

			end
		end
	end,

}
return self

