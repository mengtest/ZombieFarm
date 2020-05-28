--
-- @file    data/parser/maillib.lua
-- @anthor  xingweizhen (ye.xin@funplus.com)
-- @date    2018-01-29 11:48:21
-- @desc    描述
--

local text_id = config("textlib").text_id
local DB = {}
local TEXT = dofile("config/mail_mail")
for _,v in ipairs(TEXT) do
	DB[v.ID] = {
		sender = text_id("mail_mail", "senderName", v),
		title = text_id("mail_mail", "titleText", v),
		content = text_id("mail_mail", "contentText", v),
	}
end

local P = {}
function P.get_dat(id) return DB[id] end


return P