--
-- @file    ui/mail/lc_wndmail.lua
-- @author  shenbingkang
-- @date    2018-05-22 11:55:12
-- @desc    WNDMail
--

local self = ui.new()
local _ENV = self
self.StatusBar =
{
	AssetBar = true,
	HealthyBar = false,
}
self.ItemDEF = _G.DEF.Item

local sprBtnRed = "Common/btn_com_010"--红色按钮
local sprBtnGreen = "Common/btn_com_007"--绿色按钮

local selectedIndex = 1

local function forceUpdateSelected(go)
	libunity.SetParent(self.spSelected, go, false, -1)
	libunity.SetActive(self.spSelected, true)
end

local function rfsh_mailcontentview(mailInfo)
	local SubContent = Ref.SubContent.SubContent
	local unSelected = mailInfo == nil
	libugui.SetVisible(SubContent.go, not unSelected)
	libunity.SetActive(Ref.SubContent.spNotSelectMail, unSelected)

	if not unSelected then
		libugui.SetAnchoredPos(SubContent.SubScrContent.SubView.SubContent.go, 0, 0)
		SubContent.lbTitle.text = mailInfo.title
		SubContent.lbAuthor.text = mailInfo.senderName
		if mailInfo.content == nil then
			NW.MAIL.RequestGetMailContent(mailInfo.mailID)
			SubContent.SubScrContent.SubView.SubContent.lbContent.text = ""
			libunity.SetActive(SubContent.SubScrContent.SubView.SubContent.GrpAttachment.go, false)
			libunity.SetActive(SubContent.SubScrContent.SubView.SubContent.SubAtt.go, false)
		else
			SubContent.SubScrContent.SubView.SubContent.lbContent.text = mailInfo.content

			libunity.SetActive(SubContent.SubScrContent.SubView.SubContent.GrpAttachment.go, mailInfo.attaState ~= 0)
			
			libunity.SetActive(SubContent.SubScrContent.SubView.SubContent.SubAtt.go, mailInfo.attaState ~= 0)

			self.AttaItem = {}
			SubContent.SubScrContent.SubView.SubContent.GrpAttachment:dup(#mailInfo.attaList,
				function (i, Ent, isNew)
					local attaData = mailInfo.attaList[i]
					self.AttaItem[i] = ItemDEF.new(attaData.id, attaData.amount)
					self.AttaItem[i]:show_view(Ent)
					Ent.lbAmount.text = attaData.amount
				end)

			libunity.SetActive(SubContent.SubScrContent.SubView.SubContent.SubAtt.spReceived, mailInfo.attaState ~= 1)
			if mailInfo.attaState == 1 then
				--按钮显示为领取
				libugui.SetText(GO(SubContent.btnDelete, "lbDelete"), TEXT.takeIt)
				libugui.SetSprite(GO(SubContent.btnDelete), sprBtnGreen)
			else
				--按钮显示为删除
				libugui.SetText(GO(SubContent.btnDelete, "lbDelete"), TEXT.delete)
				libugui.SetSprite(GO(SubContent.btnDelete), sprBtnRed)
			end
		end

		--邮件未读
		if mailInfo.mailState == 1 then
			NW.MAIL.RequestSetMailState(mailInfo.mailID, 1)
			local mailCnt = #DY_DATA.MailList
			libugui.SetLoopCap(Ref.SubContent.SubScrMailList.SubView.GrpMailList.go, mailCnt, true)
		end
	end
end

local function rfsh_maillist_view()
	local mailList = DY_DATA.MailList
	local mailCnt = #mailList
	if selectedIndex > mailCnt then
		selectedIndex = mailCnt
	end
	local SubScrMailList = Ref.SubContent.SubScrMailList
	libunity.SetActive(SubScrMailList.go, mailCnt > 0)
	libunity.SetActive(Ref.SubContent.spNoMail, mailCnt == 0)

	if mailCnt ~= 0 then
		libugui.SetLoopCap(SubScrMailList.SubView.GrpMailList.go, mailCnt, true)
	end
	local curSelectedMailInfo = mailList[selectedIndex]
	rfsh_mailcontentview(curSelectedMailInfo)
end

local function contains_attr()
	for _,v in pairs(DY_DATA.MailList) do
		if v.attaState == 1 then
			return true
		end
	end
	return false
end

--!* [开始] 自动生成函数 *--

function on_grpmaillist_ent(go, i)
	local GrpMailList = Ref.SubContent.SubScrMailList.SubView.GrpMailList
	local n = i + 1
	GrpMailList:setindex(go, n)

	local mailList = DY_DATA.MailList
	local mailInfo = mailList[n]

	local Ent = ui.ref(go)
	local mod,_ = math.modf(n % 2)
	libugui.SetVisible(Ent.spOddBG, mod == 0)
	Ent.lbTitle.text = mailInfo.title

	libunity.SetActive(Ent.spUnread, mailInfo.mailState == 1)
	libunity.SetActive(Ent.spReaded, mailInfo.mailState == 2)
	libunity.SetActive(Ent.spHaveAtta, mailInfo.attaState == 1)
	Ent.lbSendTime.text = os.secs2date("%Y-%m-%d", mailInfo.sendTime)

	local lastTime = mailInfo.expireTime - os.date2secs()
	local lastDay = math.floor(lastTime / 86400)
	if lastDay > 0 then
		Ent.lbRemaining.text = string.format(TEXT.fmtExpire_Day, lastDay)
	else
		Ent.lbRemaining.text = string.format(TEXT.fmtExpire_Day, "<1")
	end

	if n == selectedIndex then
		forceUpdateSelected(go)
	else
		libunity.SetActive(Ent.spSelected, false)
	end
end

function on_subcontent_subscrmaillist_subview_grpmaillist_entmail_click(btn)
	local GrpMailList = Ref.SubContent.SubScrMailList.SubView.GrpMailList
	local index = GrpMailList:getindex(btn)
	selectedIndex = index
	forceUpdateSelected(btn)
	local mailInfo = DY_DATA.MailList[index]
	rfsh_mailcontentview(mailInfo)
end

function on_subcontent_subcontent_subscrcontent_subview_subcontent_lbcontent_click(evt, data)
	if data then
		local idx,_ = data:find("http")
		if idx == 1 then
			UE.Application.OpenURL(data)
		end
	end
end

function on_subcontent_subcontent_subscrcontent_subview_subcontent_grpattachment_entitem_click(evt, data)
	local index = ui.index(evt)
	self.AttaItem[index]:show_tip(evt)
end

function on_subcontent_subcontent_subscrcontent_subview_subcontent_grpattachment_entitem_deselect(evt, data)
	_G.DEF.Item.hide_tip()
end

function on_subcontent_subcontent_btndelete_click(btn)
	local mailInfo = DY_DATA.MailList[selectedIndex]
	--0无附件 1有附件未领取 2已经领取
	if mailInfo.attaState == 1 then
		--领取附件
		NW.MAIL.RequestGetMallAttachment(mailInfo.mailID)
	else
		--删除邮件
		NW.MAIL.RequestSetMailState(mailInfo.mailID, 2)
		rfsh_maillist_view()
	end
end

function on_btntakeall_click(btn)
	if contains_attr() then
		_G.UI.MBox.operate("ReceiveAllMailAtta", function()
			NW.MAIL.RequestGetMallAttachment(-1)
		end ,{
			cancelStyle = "Yellow", confirmStyle = "Yellow",
			txtConfirm = TEXT["v.confirm"],
		})
	end
end

function on_btndelall_click(btn)
	_G.UI.MBox.operate("DeleteReadMail", function()
		local delMailIdList = {}
		for _,v in pairs(DY_DATA.MailList) do
			if v.mailState == 2 and v.attaState ~= 1 then
				table.insert(delMailIdList, v.mailID)
			end
		end
		NW.MAIL.RequestSetMailState(delMailIdList, 2)
		rfsh_maillist_view()
	end ,{
		cancelStyle = "Yellow", confirmStyle = "Yellow",
		txtConfirm = TEXT["v.confirm"],
	})
end--!* [结束] 自动生成函数  *--
--!* [结束] 自动生成函数  *--

function init_view()
	ui.group(Ref.SubContent.SubScrMailList.SubView.GrpMailList)
	ui.group(Ref.SubContent.SubContent.SubScrContent.SubView.SubContent.GrpAttachment)
	--!* [结束] 自动生成代码 *--
	self.spSelected = Ref.SubContent.SubScrMailList.SubView.spSelected
	local flex_itemgrp = _G.PKG["ui/util"].flex_itemgrp
	flex_itemgrp(Ref.SubContent.SubContent.SubScrContent.SubView.SubContent.GrpAttachment)
end

function init_logic()
	self.StatusBar.Menu = {
		icon = "CommonIcon/ico_main_062",
		name = "WNDMail",
		Context = Context,
	}

	selectedIndex = 1
	rfsh_maillist_view()
end

function show_view()

end

function on_recycle()
	libunity.SetParent(self.spSelected, Ref.SubContent.SubScrMailList.SubView.go, true, -1)
	libunity.SetActive(self.spSelected, true)
end

local function OnHandleGetContent(mailidList)
	local curSelectedMailInfo = DY_DATA.MailList[selectedIndex]
	rfsh_mailcontentview(curSelectedMailInfo)

	for _,v in pairs(mailidList) do
		if curSelectedMailInfo.mailID == v then
			local mailUnit = DY_DATA:get_mail(v)
			rfsh_mailcontentview(mailUnit)
			return
		end
	end
end

Handlers = {
	["MAIL.SC.GET_LIST"] = rfsh_maillist_view,
	["MAIL.SC.GET_CONTENT"] = OnHandleGetContent,
	["MAIL.SC.GET_AFFIX"] = function (items)
		rfsh_maillist_view()
		--_G.UI.MBox.item_received(items)
	end,
}

return self

