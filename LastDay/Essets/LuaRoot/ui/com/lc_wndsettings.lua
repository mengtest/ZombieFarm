--
-- @file    ui/com/lc_wndsettings.lua
-- @author  xingweizhen
-- @date    2018-01-23 16:26:58
-- @desc    WNDSettings
--

local self = ui.new()
setfenv(1, self)

local Langs = {
	{ name = "English", lang = "en", },
	{ name = "简体中文", lang = "cn", },
}

local function set_lang_scroll(visible)
	local scroll = Ref.SubMain.SubBasic.SubLang.SubScroll.go
	libugui.SetAlpha(scroll, visible and 1 or 0)
	libugui.SetBlockRaycasts(scroll, visible)
end

local TabInitAction = {
	[1] = function (Sub)
		set_lang_scroll(false)
	end,
}

local function anim_toggle_changed(tgl)
	local tarPos = tgl.value and UE.Vector3(30, 0, 0) or UE.Vector3(-30, 0, 0)
	if freezingData then
		libugui.SetAnchoredPos(GO(tgl, "spThumb_"), tarPos)
	else
		libugui.DOTween("Position", GO(tgl, "spThumb_"), nil, tarPos, {
				duration = 0.2, ease = "InCubic",
			})
	end
end

local function rfsh_bar_text(Sub, bar)
	local level = bar.value
	for i=1,bar.maxValue do
		Sub["lbLevel" .. i].fontSize = level == i and 30 or 24
	end
end

local function select_lang(Lang)
	 Ref.SubMain.SubBasic.SubLang.lbLang.text = Lang.name
	if not freezingData then
		local preLang, preIndex = _G.lang, 1
		for i,v in ipairs(Langs) do
			if v.lang == preLang then
				preIndex = i
			break end
		end

		local function confirm()
			local lang = Lang.lang
			Settings.lang = lang
			_G.Prefs.Settings:save()

			libasset.LoadAsync(nil, "fonts/MainFont." .. lang .. "/", "Always", function ()
				libugui.SetLocalize(lang, "en")
				ui.setloc(preLang, lang)
				config("textlib").reset()

				libasset.Unload("fonts/MainFont." .. preLang .. "/")
				_G.PKG["network/login"].logout()
			end)
		end
		local function cancel()
			freezingData = true
			Ref.SubMain.SubBasic.SubLang.SubScroll.SubView.GrpLangs:get(preIndex).tgl.value = true
			freezingData = nil
		end

		UI.MBox.make()
			:set_param("content", TEXT.askChangeLang)
			:set_event(confirm, cancel)
			:show()
	end
end

--!* [开始] 自动生成函数 *--

function on_submain_btnconfirm_click(btn)
	local dirty = false
	for k,v in pairs(ChangedSettings) do
		if Settings[k] ~= v then
			Settings[k] = v
			dirty = true
		end
	end

	if dirty then
		_G.Prefs.Settings:save()
		NW.broadcast("CLIENT.SC.SETTINGS", Settings)
	end
	self:close()
end

function on_submain_grptabs_enttab_click(tgl)
	if tgl.value then
		local index = ui.index(tgl)
		for i,v in ipairs(SubMenu) do
			libunity.SetActive(v.go, i == index)
		end

		local action = TabInitAction[index]
		if action then action(SubMenu[index]) end
	end
end

function on_graphic_level_changed(bar)
	rfsh_bar_text(SubMenu[1].SubGraphic.SubBar, bar)
	if not freezingData then

	end
end

function on_framerate_level_changed(bar)
	rfsh_bar_text(SubMenu[1].SubFrameRate.SubBar, bar)
	if not freezingData then

	end
end

function on_submain_subbasic_submusic_tglswitch_click(tgl)
	local value = tgl.value
	anim_toggle_changed(tgl)
	if not freezingData then
		ChangedSettings["aud.bgm.mute"] = not value
		libunity.SetAudioMute("BGM", not value)
	end
	Ref.SubMain.SubBasic.SubMusic.SubBar.barVolume.interactable = value
end

function on_music_volume_changed(bar)
	if not freezingData then
		local value = bar.value
		ChangedSettings["aud.bgm.vol"] = value
		libunity.SetAudioVolume("BGM", value / 100)
	end
end

function on_submain_subbasic_subsound_tglswitch_click(tgl)
	local value = tgl.value
	anim_toggle_changed(tgl)
	if not freezingData then
		ChangedSettings["aud.sfx.mute"] = not value
		libunity.SetAudioMute("SFX", not value)
	end
	Ref.SubMain.SubBasic.SubSound.SubBar.barVolume.interactable = value
end

function on_sound_volume_changed(bar)
	if not freezingData then
		local value = bar.value
		ChangedSettings["aud.sfx.vol"] = value
		libunity.SetAudioVolume("SFX", value / 100)
	end
end

function on_grplang_ent(go, i)
	local index = i + 1
	ui.index(go, index)

	local Lang = Langs[index]
	local Ent = ui.ref(go)
	Ent.lbLang.text = Lang.name
end

function on_submain_subbasic_sublang_subscroll_subview_grplangs_entlang_click(tgl)
	if tgl.value then
		local index = ui.index(tgl)
		select_lang(Langs[index])
		Ref.SubMain.SubBasic.SubLang.tglShow.value = false
	end
end

function on_submain_subbasic_sublang_tglshow_click(tgl)
	set_lang_scroll(tgl.value)
end

function on_prior_level_changed(bar)
	rfsh_bar_text(SubMenu[2].SubPrior.SubBar, bar)
	if not freezingData then
		local level = bar.value
		ChangedSettings["battle.focus.preferredHp"] = level == 2
	end
end

function on_submain_suboper_sublock_tglonhit_click(tgl)
	anim_toggle_changed(tgl)
	if not freezingData then
		ChangedSettings["battle.focus.lockOnHit"] = tgl.value
	end
end

function on_submain_suboper_subnearby_tglmanual_click(tgl)
	anim_toggle_changed(tgl)
	if not freezingData then
		ChangedSettings["battle.focus.showNearby"] = tgl.value and 5 or 0
	end
end

function on_submain_subother_subplayer_btnlogout_click(btn)
	UI.MBox.operate("Logout", _G.PKG["network/login"].logout)
end

function on_submain_subother_subplayer_btnselectserver_click(btn)
	UI.MBox.operate("Logout", function ()
		local LOGIN = _G.PKG["network/login"]

		LOGIN.CacheAccount = true
		LOGIN.logout()
	end)
end

function on_submain_subother_subcdkey_btnok_click(btn)

end

function on_submain_subother_subcdkey_inpcode_submit(inp, text)

end
--!* [结束] 自动生成函数  *--

function init_view()
	ui.group(Ref.SubMain.GrpTabs)
	ui.group(Ref.SubMain.SubBasic.SubLang.SubScroll.SubView.GrpLangs)
	--!* [结束] 自动生成代码 *--

	self.Settings = _G.Prefs.Settings:load()

	-- 设置分类页签
	local SubMain = Ref.SubMain
	self.SubMenu = {
		SubMain.SubBasic, SubMain.SubOper, SubMain.SubOther,
	}
	SubMain.GrpTabs:dup(#TEXT.SettingsMenu, function (i, Ent, isNew)
		local tabName = TEXT.SettingsMenu[i]
		Ent.lbTab.text = tabName
		Ent.lbChkTab.text = tabName
	end)
end

function init_logic()
	Ref.SubMain.GrpTabs:get(1).tgl.value = true

	self.ChangedSettings = {}
	self.freezingData = true

	-- 初始化所有设置
	local SubBasic = Ref.SubMain.SubBasic

	-- 音频
	local function init_audio_volume(setting, bus)
		local volume = Settings[setting]
		if volume == nil then
			volume = math.floor(libunity.GetAudioVolume(bus) * 100 + 0.5)
			Settings[setting] = volume
		end
		return volume
	end

	SubBasic.SubMusic.tglSwitch.value = not libunity.GetAudioMute("BGM")
	SubBasic.SubMusic.SubBar.barVolume.value = init_audio_volume("aud.bgm.vol", "BGM")
	SubBasic.SubSound.tglSwitch.value = not libunity.GetAudioMute("SFX")
	SubBasic.SubSound.SubBar.barVolume.value = init_audio_volume("aud.sfx.vol", "SFX")

	local GrpLangs = SubBasic.SubLang.SubScroll.SubView.GrpLangs
	libugui.SetLoopCap(GrpLangs.go, #Langs, true)
	for i,v in ipairs(Langs) do
		if v.lang == _G.lang then
			GrpLangs:find(i).tgl.value = true
		break end
	end

	-- 操作
	local SubOper = Ref.SubMain.SubOper
	local SubPrior = SubOper.SubPrior

	local preferredHp = Settings["battle.focus.preferredHp"]
	local priorLevel = preferredHp and 2 or 1
	SubPrior.SubBar.barLevel.value = priorLevel
	rfsh_bar_text(SubPrior.SubBar, SubPrior.SubBar.barLevel)

	SubOper.SubLock.tglOnhit.value = Settings["battle.focus.lockOnHit"]
	SubOper.SubNearby.tglManual.value = Settings["battle.focus.showNearby"] == 5

	-- 其他
	local SubOther = Ref.SubMain.SubOther
	SubOther.SubPlayer.lbName.text = DY_DATA:get_player().name

	self.freezingData = nil
end

function show_view()

end

function on_recycle()
	self.freezingData = true

	libugui.AllTogglesOff(Ref.SubMain.GrpTabs.go)
	libugui.AllTogglesOff(Ref.SubMain.SubBasic.SubLang.SubScroll.SubView.GrpLangs.go)

	-- 音频设置生效
	libunity.SetAudioMute("BGM", Settings["aud.bgm.mute"])
	libunity.SetAudioVolume("BGM", Settings["aud.bgm.vol"] / 100)

	libunity.SetAudioMute("SFX", Settings["aud.sfx.mute"])
	libunity.SetAudioVolume("SFX", Settings["aud.sfx.vol"] / 100)
end

return self

