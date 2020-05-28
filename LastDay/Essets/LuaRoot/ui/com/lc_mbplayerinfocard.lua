--
-- @file    ui/com/lc_mbplayerinfocard.lua
-- @author  shenbingkang
-- @date    2018-10-11 10:49:21
-- @desc    MBPlayerInfoCard
--

local self = ui.new()
local _ENV = self

local AvatarLIB = config("avatarlib")

local function rfsh_playerinfo_view()
	local SubPersonInfo = Ref.SubMain.SubPersonInfo

	local hair = self.Data.hair
	local gender = self.Data.gender
	local face = self.Data.face
	local haircolor = self.Data.haircolor

	local faceIconPath, hairIconPath = nil, nil
	if hair and gender and face and haircolor then
		faceIconPath , hairIconPath = AvatarLIB.get_player_head(gender, face, hair, haircolor)
		
		faceIconPath = "PlayerIcon/"..faceIconPath
		hairIconPath = "PlayerIcon/"..hairIconPath
	end
	libugui.SetSprite(SubPersonInfo.spFace, faceIconPath)
	libugui.SetSprite(SubPersonInfo.spHair, hairIconPath)

	SubPersonInfo.SubName.lbName.text = self.Data.name
	SubPersonInfo.SubId.lbId.text = self.Data.uniqueId

	if self.Data.guildName and #self.Data.guildName > 0 then
		local guildChanel = self.Data.guildChanel or 0 
		local chTemp = math.floor(guildChanel / 1000)
		local chTempD = guildChanel - chTemp * 1000
		local guildChanelStr = string.format("%03d", chTemp).."."..string.format("%03d", chTempD)
		SubPersonInfo.SubGuildName.lbGuildName.text = self.Data.guildName .. string.format("(%s)", guildChanelStr)
	else
		SubPersonInfo.SubGuildName.lbGuildName.text = nil
	end
end

local function ShowElva()
	
end 

local function ShowFAQs()
	
end 


--!* [开始] 自动生成函数 *--

function on_submain_subpersoninfo_subname_btnmodifyname_click(btn)
	ui.show("UI/WNDChangeName")
end

function on_submain_subpersoninfo_subid_btncopyuserid_click(btn)
	libugui.CopyToClipboard(self.Data.uniqueId)
	UI.Toast.norm(TEXT.copyOk)
end

function on_submain_subnode_btngamesetting_click(btn)
	ui.show("UI/WNDGameSetting")
end

function on_submain_subnode_btngamesetting_pressed(evt, data)
	if _G.ENV.development then
		ui.show("UI/ADVSettings")
	end
end

function on_submain_subnode_btnlanguage_click(btn)
	ui.show("UI/MBLanguageSettings")
end

function on_submain_subnode_btnaccount_click(btn)
	ui.show("UI/MBAccountManager")
end

function on_submain_subnode_btngiftexchange_click(btn)
	
end

function on_submain_subnode_btngamehelp_click(btn)
	local MenuArr = {}
	table.insert(MenuArr, {
		name =_G.TEXT["ContactCustomerService"],
		callback = ShowElva,
	})
	table.insert(MenuArr, {
		name =_G.TEXT["FAQ"],
		callback = ShowFAQs,
	})
	local OptionInfo = { 
		subTitle = _G.TEXT["GameHelp"],
		MenuArr = MenuArr,
		context = TEXT.OpenAIHelpAlert,
	}
	ui.show("UI/MBOption", 0, OptionInfo)
end
--!* [结束] 自动生成函数  *--

function init_view()
	--!* [结束] 自动生成代码 *--
end

function init_logic()
	self.Data = Context

	local isMyself = self.Data.playerId == DY_DATA:get_player().id
	libunity.SetActive(Ref.SubMain.SubPersonInfo.SubName.btnModifyName, isMyself)
	libunity.SetActive(Ref.SubMain.SubNode.go, isMyself)
	libugui.RebuildLayout(Ref.SubMain.go)
	
	if self.Data.uniqueId == nil then
		local nm = NW.msg("PLAYER.CS.GET_OTHER_ROLE_INFO")
		nm:writeU64(self.Data.playerId)
		NW.send(nm)
	end

	rfsh_playerinfo_view()
end

function show_view()
	
end

function on_recycle()
	
end

Handlers = {
	["PLAYER.SC.GET_OTHER_ROLE_INFO"] = function (data)
		if data then
			data.playerId = data.id
			self.Data = data
			rfsh_playerinfo_view()
		end
	end,
	["PLAYER.SC.GET_ROLE_INFO"] = function(Ret)
		if self.Data.playerId == DY_DATA:get_player().id then
			local myData = DY_DATA:get_usercard()
			self.Data = myData
			rfsh_playerinfo_view()
		end
	end,
}

return self

