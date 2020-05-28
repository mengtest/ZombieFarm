--
-- @file    network/unpack/upk_mail.lua
-- @author  shenbingkang
-- @date    2018-05-22 16:39:44
-- @desc    描述
--

local NW, P = _G.NW, {}


local function check_text_string(str)
	return _G.PKG["ui/util"].check_text_string(str)
end

local function check_mail_title(title)
	local maildata = config("maillib").get_dat(tonumber(title))
	if maildata then
		return  check_text_string(maildata.title)
	end

	return title
end 

local function check_mail_sender(senderName)
	local maildata = config("maillib").get_dat(tonumber(senderName))
	if maildata then
		return  check_text_string(maildata.sender)
	end

	return senderName
end 

local function split_content(contentStr)
	local strarr = contentStr:split("|")

	if #strarr > 2 then
		local mailId = strarr[1]
		local maildata = config("maillib").get_dat(tonumber(mailId))
		if maildata then
			local content = check_text_string(maildata.content)

			return string.gsub(content,strarr[2],strarr[3])
		end
	end
	return contentStr
end
local function readMailHead(nm)
	local mailID = nm:readU64() -- 邮件ID

	local mailUnit = DY_DATA:get_mail(mailID)
	if mailUnit == nil then
		mailUnit = {mailID = mailID}
		table.insert(DY_DATA.MailList, mailUnit)
	end
	mailUnit.mailType = nm:readU32() -- 邮件类型 1用户邮件 2系统邮件
	mailUnit.iconID = nm:readU32() -- 图标ID
	mailUnit.attaState = nm:readU32() -- 附件状态 0无附件 1有附件未领取 2已经领取
	mailUnit.itemId = nm:readU32() -- 附件物品
	mailUnit.sendTime = math.floor(nm:readU64() / 1000) -- 发件时间
	mailUnit.expireTime = math.floor(nm:readU64() / 1000) -- 过期时间
	mailUnit.mailState = nm:readU32() -- 邮件状态 1未读 2已读

	local senderName = nm:readString()
	mailUnit.senderName = check_mail_sender(senderName)  --发件人
	
	local title = nm:readString()
	mailUnit.title = check_mail_title(title)  --标题
end

local function readMailContent(nm)
	local mailID = nm:readU64() -- 邮件ID

	local mailUnit = DY_DATA:get_mail(mailID)
	if mailUnit == nil then
		mailUnit = {mailID = mailID}
		table.insert(DY_DATA.MailList, mailUnit)
	end
	local contentStr = nm:readString()

	mailUnit.content = split_content(contentStr) -- 邮件内容
	mailUnit.attaList = nm:readArray({}, NW.read_item) --附件列表 key=物品Id value=数量
	return mailID
end

NW.regist("MAIL.SC.GET_LIST", function (nm)
	nm:readArray({}, readMailHead)
	if DY_DATA.RedSystem and DY_DATA.RedSystem.inited then
 		P.CheckHaveUnLookMail()
	end
	return true
end)

NW.regist("MAIL.SC.GET_CONTENT", function (nm)
	return nm:readArray({}, readMailContent)
end)

NW.regist("MAIL.SC.GET_AFFIX", function (nm)
	local ret, err = NW.chk_op_ret(nm:readU32())
	if err == nil then
		return nm:readArray({}, function (nm)
			local mailID = nm:readU64()
			local attaList = nm:readArray({}, NW.read_item)
			local mailUnit =  DY_DATA:get_mail(mailID)
			if mailUnit then
				mailUnit.attaState = 2
				-- table.remove_elm(DY_DATA.MailList, mailUnit)
			end
			return attaList
		end)
	end
end)

--获取邮件列表
function P.RequestGetMailList()
	NW.send(NW.msg("MAIL.CS.GET_LIST"))
end

--获取邮件内容
function P.RequestGetMailContent(mailIdList)
	local fixedTable
	if type(mailIdList) == "table" then
		fixedTable = mailIdList
	else
		fixedTable = { mailIdList }
	end
	local nm = NW.msg("MAIL.CS.GET_CONTENT")
	nm:writeArray(fixedTable, nm.writeU64)
 	NW.send(nm)
end

--设置邮件状态 --state:1.已读 2.删除
function P.RequestSetMailState(mailIdList, state)
	local fixedTable
	if type(mailIdList) == "table" then
		fixedTable = mailIdList
	else
		fixedTable = { mailIdList }
	end

	--客户端直接标记邮件为已读状态
	if state == 1 then
		for _,v in pairs(fixedTable) do
			local mailUnit = DY_DATA:get_mail(v)
			if mailUnit then
				mailUnit.mailState = 2
			end
		end
	--客户端直接移除邮件
	elseif state == 2 then
		for _,v in pairs(fixedTable) do
			local mailUnit = DY_DATA:get_mail(v)
			if mailUnit then
				table.remove_elm(DY_DATA.MailList, mailUnit)
			end
		end
	end

	local nm = NW.msg("MAIL.CS.SET_READED")
	nm:writeU32(state)
	nm:writeArray(fixedTable, nm.writeU64)
 	NW.send(nm)
 	P.CheckHaveUnLookMail()
end

--领取邮件附件
function  P.RequestGetMallAttachment(mailID)
	NW.send(NW.msg("MAIL.CS.GET_AFFIX"):writeU64(mailID))
end

function P.CheckHaveUnLookMail()
	local  haveNew = false
	for i,v in ipairs(DY_DATA.MailList) do
		if v.mailState == 1 then
			haveNew = true
			break
		end
	end

    DY_DATA.RedSystem:SetRedDotState(CVar.RedDotName.MailNew,haveNew)
end

NW.MAIL = P
