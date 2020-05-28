--
-- @file    network/unpack/upk_chat.lua
-- @anthor  xingweizhen (weizhen.xing@funplus.com)
-- @date    2018-06-07 15:08:09
-- @desc    描述
--

local NW, P = _G.NW, {}

-- ChatSender
local function sc_chatsender(nm)
	return {
		type = nm:readU32(),
		id = nm:readU64(),
		level = nm:readU32(),
		vipLevel = nm:readU32(),
		icon = nm:readU32(),
		frame = nm:readU32(),
		name = nm:readString(),
		gender = nm:readU32(),
		face = nm:readU32(),
		hair = nm:readU32(),
		haircolor = nm:readU32(),
	}
end
local function sc_chatreceiver(nm)
	return {
		id = nm:readU64(),
		name = nm:readString(),
	}
end
-- ChatInfoAudioView
local function sc_voice_base(nm)
	return { id = nm:readU32(), secs = nm:readU32(), }
end

-- ChatInfoAudioPlay
local function sc_voice_full(nm)
	local Ret = sc_voice_base(nm)
	Ret.data = nm:readString()
	return Ret
end

local function sc_voice_info(nm)
	return { data = nm:readString() }
end

local MsgContentReader = {
	-- 文本
	[1] = function (nm)
		return  { text = nm:readString(), }
	end,

	-- 内链
	[2] = function (nm)
		return { text = nm:readString(), link = nm:readString(), }
	end,

	-- 第三方语音数据
	[3] = sc_voice_info,

	-- 语音内容
	[4] = sc_voice_full,

	-- 实时语音
	[5] = sc_voice_full,

	-- BUG
	[20] = function (nm)
		-- TODO
	end,
}

local MsgDEF = {}
P.MsgDEF = MsgDEF
MsgDEF.__index = MsgDEF
function MsgDEF.__tostring(self)
	local Content = self.Content
	if self.type == 1 then return Content.text end
	if self.type == 2 then
		return string.tag(Content.text, {
				link = string.format("\"%s\"", Content.link),
			})
	end
	return ""
end

function MsgDEF.new(Msg)
	return setmetatable(Msg, MsgDEF)
end
local function on_check_channel_state(channel)
	local chatchannel = DY_DATA.ChannelSet 
	local t = type(chatchannel);
	if t == "number" then
-- 是数字
		local state = (1 << channel-1)

		local isopen = chatchannel & state
	
		return (isopen>> channel-1) == 1
	end
	return false
end

local function add_new_msg(Msg, MsgList, NewChatMsgs)
	local maxDisplayNum = CVar.CHAT.MaxDisplayNum
	if #MsgList > maxDisplayNum then
		table.remove(MsgList, 1)
	end
	table.insert(MsgList, MsgDEF.new(Msg))

	if Msg.channel == 1 or on_check_channel_state(Msg.channel) then
		if #NewChatMsgs > 2 then
			table.remove(NewChatMsgs, 1)
		end
		table.insert(NewChatMsgs, Msg)
	end
end

-- 客户端自定义
MsgContentReader[10] = MsgContentReader[1]
local recentlyMets = {}
P.RecentlyMets = recentlyMets

local function sc_chat_content(nm)
	local msgType = nm:readU32()
	local reader = MsgContentReader[msgType]
	if reader then
		return msgType, reader(nm)
	end

	libunity.LogE("尝试读取不支持的聊天消息类型{0}", msgType)
end
local function insert_recentlymets(Receiver)
	if Receiver.id == DY_DATA:get_player().id then
		return recentlyMets
	end
	
	local isfriend = false
	for i,v in ipairs(DY_DATA.friendList) do
		if Receiver.id == v.id then
			isfriend = true
			v.haveNew = true
			--rawset(v ,"haveNew",true)
			break
		end
	end

	if isfriend then
		DY_DATA.RedSystem:SetRedDotState(CVar.RedDotName.FriendNew,true)
		return recentlyMets
	end
	

	DY_DATA.RedSystem:SetRedDotState(CVar.RedDotName.StrangerNew,true)
	local needAdd = true
	for i,v in ipairs(recentlyMets) do
		 if Receiver.id == v.id then
		 	needAdd = false
			v.haveNew = true
		 	--rawset(v ,"haveNew",true)
		 	break
		 end
	end

	if needAdd then
		Receiver.haveNew = true
		--rawset(Receiver ,"haveNew",true)
		table.insert(recentlyMets,Receiver)
	end

	return recentlyMets
end 

-- ChatMsg
local function sc_chatmsg(nm, time)
	local Msg = {
		time = math.floor(time / 1000 + 0.5),
		channel = nm:readU32(),
		Sender = sc_chatsender(nm),
	}

	local msgType, Content = sc_chat_content(nm)
	if Msg.channel == 1 then
		local receiver = sc_chatreceiver(nm)
		Msg.Receiver = receiver
	end
	Msg.type = msgType
	Msg.Content = Content

	local MsgList = nil

	if Msg.channel == 1 then
		local Player = DY_DATA:get_player()
		if  Msg.Sender.id ~= Player.id then
			MsgList = table.need(DY_DATA.ChatMsgs, Msg.Sender.id)
		else
			MsgList = table.need(DY_DATA.ChatMsgs, Msg.Receiver.id)
		end
		

		local  Receiver = {id = Msg.Sender.id,name = Msg.Sender.name }

		--非好友玩家私聊自己，将对方加入自己的陌生人列表
 		insert_recentlymets(Receiver)
 	else
 		MsgList = table.need(DY_DATA.ChatMsgs, Msg.channel)
 	end
 	if Msg.channel == 12 then
 		table.insert(DY_DATA.ScrollingMsgs, MsgDEF.new(Msg))
 	else
		add_new_msg(Msg, MsgList, DY_DATA.NewChatMsgs)
	end

--[[
	if Msg.type == 4 then
		-- 记录在查找到的语音显示里
		local voiceId = Msg.Content.id
		for i,v in ipairs(MsgList) do
			if v.type == 3 and v.Content.id == voiceId then
				v.type = Msg.type
				v.Content = Msg.Content
			return end
		end
	end
]]


	return Msg
end

NW.regist("CHAT.SC.SEND", NW.common_op_ret)

NW.regist("CHAT.SC.CHAT_SET_GET", function (nm)
	-- TODO
end)

NW.regist("CHAT.SC.CHAT_SET_MODIFY", NW.common_op_ret)

NW.regist("CHAT.SC.CHAT_BROADCAST", function (nm)
	local NewMsgs = {}
	local time = nm:readU64()
	local n = nm:readU32()
	for i=1,n do
		table.insert(NewMsgs, sc_chatmsg(nm, time))
	end
 	if #DY_DATA.ScrollingMsgs > 0 then
    	local sc_wnd = ui.find("FRMScrollingMessage")
    	if sc_wnd == nil then
			ui.show("UI/FRMScrollingMessage", 2)
		end
 	end
	return NewMsgs
end)

NW.regist("CHAT.SC.AUDIO_GET", function (nm)
	local channel = nm:readU32()
	local voiceId = nm:readU32()
	local ret, err = NW.chk_op_ret(nm:readU32())
	if err == nil then
		return sc_voice_full(nm)
	end
end)

local MsgContentWriter = {
	[1] = function (nm, text)
		return nm:writeString(text)
	end,
	[2] = function (nm, text, link)
		return nm:writeString(text):writeString(link)
	end,
	[3] = function (nm, data)
		return nm:writeString(data)
	end,

	[10] = function (nm, data)
		return nm:writeString(data)
	end,
}

local MsgContentMaker = {
	[1] = function (text) return { text = text, } end,
	[2] = function (text, link) return { text = text, link = link } end,
	[3] = function (data) return { data = data, }  end,
 }

function P.send(channel, Receiver, msgType, ...)
	local writer = MsgContentWriter[msgType]
	if writer then
		local nm = NW.msg("CHAT.CS.SEND")
		nm:writeU32(channel):writeU64(Receiver and Receiver.id or 0):writeU32(msgType)
		local contentStr = string.gsub(..., "<[^>]+>", "")
		NW.MainCli:send(writer(nm, contentStr))

 		--[[
			if channel == 1 and Receiver then
			-- 构造一个私聊消息
			local Player = DY_DATA:get_player()
			local human = DY_DATA:get_self()
			
			local Msg = {
				type = msgType, Content = MsgContentMaker[msgType](...),

				time = os.date2secs(), channel = channel,
				Sender = {
					type = 1, id = Player.id, name = Player.name, hair = human.hair,
					gender = human.gender, face = human.face, haircolor = human.haircolor,
				},
				Receiver = {
					type = 1, id = Receiver.id, name = Receiver.name,
				},

			}

			local MsgList = table.need(DY_DATA.ChatMsgs, Receiver.id)
			add_new_msg(Msg, MsgList, DY_DATA.NewChatMsgs)

			NW.MainCli:broadcast("CHAT.SC.CHAT_BROADCAST", { Msg })
		end
 		]]
		
	else
		libunity.LogE("尝试写入不支持的聊天消息类型{0}", msgType)
	end
end
function P.InviteToLocation(userId,userName,depth,from)
	local Stage =  DY_DATA:get_stage()
	if Stage == nil then
		return
	end
	local EntData = config("maplib").get_ent(Stage.Base.id)

	local str =  EntData.name
	local playername = DY_DATA:get_player().name

	local contentStr = TEXT.InviteToLocation:csfmt(playername,str)
	local Receiver = {id = userId, name = userName}

	P.send(1, Receiver, 1,contentStr)
end
function P.InviteToGuild(userId,userName,depth,from)
	local playername = DY_DATA:get_player().name
	local str =string.formatnumberthousands(DY_DATA:get_player().guildChannel)

	local contentStr = TEXT.Guild_Invite:csfmt(playername, str)
	local Receiver = {id = userId, name = userName}
	NW.CHAT.send(1, Receiver, 1,contentStr)
end
NW.CHAT = P
