--
-- @file    ui/com/lc_mbaccountmanager.lua
-- @author  shenbingkang
-- @date    2018-10-17 11:36:04
-- @desc    MBAccountManager
--

local self = ui.new()
local _ENV = self
local AvatarLIB = config("avatarlib")

local function rfsh_social_status()
	libunity.SetActive(Ref.SubMain.SubSocial.go, false)
end

local function rfsh_playerinfo_view()
	local SubMain = Ref.SubMain

	local myData = DY_DATA:get_usercard()

	local hair = myData.hair
	local gender = myData.gender
	local face = myData.face
	local haircolor = myData.haircolor

	local faceIconPath, hairIconPath = nil, nil
	if hair and gender and face and haircolor then
		faceIconPath , hairIconPath = AvatarLIB.get_player_head(gender, face, hair, haircolor)
		
		faceIconPath = "PlayerIcon/"..faceIconPath
		hairIconPath = "PlayerIcon/"..hairIconPath
	end
	libugui.SetSprite(SubMain.spFace, faceIconPath)
	libugui.SetSprite(SubMain.spHair, hairIconPath)

	SubMain.lbName.text = myData.name
	SubMain.lbPlayerLevel.text = TEXT.fmtLevel:csfmt(myData.level)

	local LOGIN = _G.PKG["network/login"]
	local Session = LOGIN.get_session()
	SubMain.lbServerName.text = string.format(TEXT.fmtServerName, Session.Server.serverName)
end

local function on_click_switch_acount(accountType)
	
end

--!* [开始] 自动生成函数 *--

function on_submain_btnmanageaccount_click(btn)
	ui.show("UI/MBSocialBand")
end

function on_submain_btnswitchaccount_click(btn)
	local MenuArr = {}
	table.insert(MenuArr, {
		name = TEXT.Facebook,
		callback = on_click_switch_acount,
		icon = "Common/ico_set_07",
		params = "Facebook",
	})
	local OptionContext = { 
		subTitle = TEXT.SocialAccountSwitchTitle,
		MenuArr = MenuArr,
	}
	ui.show("UI/MBOption", 0, OptionContext)
end

function on_submain_btnswitchserver_click(btn)
	ui.show("UI/MBSelectServer")
end
--!* [结束] 自动生成函数  *--

function init_view()
	--!* [结束] 自动生成代码 *--
end

function init_logic()
	rfsh_playerinfo_view()
	rfsh_social_status()
end

function show_view()
	
end

function on_recycle()
	
end

Handlers = {
	["CLIENT.SC.SDK_SOCIAL_ACCCOUNT_BIND"] = rfsh_social_status,
	["CLIENT.SC.SDK_SOCIAL_ACCCOUNT_UNBIND"] = rfsh_social_status,
}

return self

