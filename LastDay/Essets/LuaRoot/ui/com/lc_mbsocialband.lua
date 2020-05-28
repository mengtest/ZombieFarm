--
-- @file    ui/com/lc_mbsocialband.lua
-- @author  shenbingkang
-- @date    2018-10-17 15:22:29
-- @desc    MBSocialBand
--

local self = ui.new()
local _ENV = self

local function rfsh_social_item(KgUserSocialData, Sub)
	libunity.SetActive(Sub.go, true)
	Sub.lbStatus.text = KgUserSocialData and TEXT.SocialBinded or TEXT.SocialUnbind
	libunity.SetActive(Sub.btnBand, KgUserSocialData == nil)
	libunity.SetActive(Sub.btnDisband, KgUserSocialData ~= nil)
end

local function rfsh_social_band_status()
	rfsh_social_item(nil, Ref.SubMain.SubFacebook)
end

--!* [开始] 自动生成函数 *--

function on_submain_subfacebook_btnband_click(btn)
	
end

function on_submain_subfacebook_btndisband_click(btn)
	
end
--!* [结束] 自动生成函数  *--

function init_view()
	--!* [结束] 自动生成代码 *--
end

function init_logic()
	rfsh_social_band_status()
end

function show_view()
	
end

function on_recycle()
	
end

Handlers = {
	["CLIENT.SC.SDK_SOCIAL_ACCCOUNT_BIND"] = rfsh_social_band_status,
	["CLIENT.SC.SDK_SOCIAL_ACCCOUNT_UNBIND"] = rfsh_social_band_status,
}

return self

