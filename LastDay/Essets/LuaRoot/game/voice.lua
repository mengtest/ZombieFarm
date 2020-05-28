--
-- @file    game/voice.lua
-- @anthor  xingweizhen (weizhen.xing@funplus.com)
-- @date    2018-08-13 18:39:27
-- @desc    语音模块
--

local libvoice = require "libvoice.cs"
local P = {}

function P.join_room(code, room, member)

end

function P.quit_room(code, room, member)

end

function P.apply_msgkey(code)

end

function P.upload_complete(code, filePath, fileId)
	if code == 11 then
		local Args = filePath:getfile():split("_")
		local _, channel, rid, time = table.unpack(Args)
		local Receiver = rid and { id = rid, name = "player" .. rid, }
		_G.NW.CHAT.send(channel, Receiver, 3, fileId)
	end
end

function P.download_complete(code, filePath, fileId)
	libvoice.PlayRecordedFile(filePath)
end

return P

