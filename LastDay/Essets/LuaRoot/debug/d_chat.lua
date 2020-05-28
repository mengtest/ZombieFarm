--
-- @file    debug/d_chat.lua
-- @anthor  xingweizhen (weizhen.xing@funplus.com)
-- @date    2018-06-07 13:27:29
-- @desc    描述
--

local MsgDEF = NW.CHAT.MsgDEF

local Other = {
	type = 1, id = 9, level = 1, vipLevel = 0,
	icon = 0, frame = 0, name = "Player9",
}

local Player = DY_DATA:get_player()
local Self = {
	type = 1, id = Player.id, level = 1, vipLevel = 0,
	icon = 0, frame = 0, name = Player.name,
}

local now = os.date2secs()

local ChatMsgs = { }

local d_channel
local function add_chatmsg(Sender, text, time, channel)
	if channel == nil then channel = d_channel end
	local Msg = {
		time = time, channel = channel, Sender = Sender, type = 1,
		Content = { text = text },
	}

	table.insert(table.need(ChatMsgs, channel), Msg)

	return MsgDEF.new(Msg)
end

-- 世界频道
d_channel = 2
add_chatmsg(Other, "English", now - 900)
add_chatmsg(Self, "简体中文", now - 800)
add_chatmsg(Other, "繁體中文", now - 700)
add_chatmsg(Other, "日本語", now - 600)
add_chatmsg(Other, "Español", now - 500)
add_chatmsg(Other, "Français", now - 400)
add_chatmsg(Other, "Deutsch", now - 300)
add_chatmsg(Other, "Pусский", now - 200)
add_chatmsg(Other, "Português", now - 100)
add_chatmsg(Other, "Italiano", now - 50)
add_chatmsg(Other, "한국어\n우주도 우리의 것입니다.", now)

-- 公会频道
d_channel = 3
add_chatmsg(Other, "啊大家好啊，想死你们啦\n哈哈哈哈.FMODUnity.BusNotFoundException: FMOD Studio bus not found 'bus:/'", now - 777)

DY_DATA.ChatMsgs = ChatMsgs

function DY_DATA.d_send_chatmsg(channel, Receiver, text)
	local Msg = add_chatmsg(Self, text, os.date2secs(), channel)
	if Receiver then
		Msg.Receiver = {
			type = 1, id = Receiver.id, level = Receiver.level, vipLevel = nil,
			icon = nil, frame = nil, name = Receiver.name,
		}
	end

	local NewChatMsgs = DY_DATA.NewChatMsgs
	if #NewChatMsgs > 3 then
		table.remove(NewChatMsgs, 1)
	end
	table.insert(NewChatMsgs, Msg)

	NW.broadcast("CHAT.SC.CHAT_BROADCAST", { Msg })
end
