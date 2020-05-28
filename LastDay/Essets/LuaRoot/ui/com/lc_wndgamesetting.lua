--
-- @file    ui/com/lc_wndgamesetting.lua
-- @author  Administrator
-- @date    2018-10-17 18:50:41
-- @desc    WNDGameSetting
--

local self = ui.new()
local _ENV = self


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

--!* [开始] 自动生成函数 *--

function on_submain_btnclose_click(btn)
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

function on_sound_volume_changed(bar)
	if not freezingData then
		local value = bar.value
		ChangedSettings["aud.bgm.vol"] = value
		libunity.SetAudioVolume("BGM", value / 100)
	end
end

function on_submain_subscroll_subviewport_subcontent_subaudio_tglvoice_click(tgl)
	local value = tgl.value
	anim_toggle_changed(tgl)
	if not freezingData then
		ChangedSettings["aud.bgm.mute"] = not value
		libunity.SetAudioMute("BGM", not value)
	end
end

function on_sound_effect_changed(bar)
	if not freezingData then
		local value = bar.value
		ChangedSettings["aud.sfx.vol"] = value
		libunity.SetAudioVolume("SFX", value / 100)
	end
end

function on_submain_subscroll_subviewport_subcontent_subaudio_tgleffect_click(tgl)
	local value = tgl.value
	anim_toggle_changed(tgl)
	if not freezingData then
		ChangedSettings["aud.sfx.mute"] = not value
		libunity.SetAudioMute("SFX", not value)
	end
end

function on_submain_subscroll_subviewport_subcontent_subprioritytarget_tglnearest_click(tgl)
	anim_toggle_changed(tgl)
	if not freezingData and tgl.value then
		ChangedSettings["battle.focus.preferredHp"] = false
	end	
end

function on_submain_subscroll_subviewport_subcontent_subprioritytarget_tglhplowest_click(tgl)
	anim_toggle_changed(tgl)
	if not freezingData and tgl.value then
		ChangedSettings["battle.focus.preferredHp"] = true
	end
end

function on_submain_subscroll_subviewport_subcontent_subattacklock_tgllock_click(tgl)
	anim_toggle_changed(tgl)
	if not freezingData then
		ChangedSettings["battle.focus.lockOnHit"] = tgl.value
	end
end

function on_submain_subscroll_subviewport_subcontent_subdeafult_btnyellow_click(btn)
	
end

--!* [结束] 自动生成函数  *--

function init_view()
	--!* [结束] 自动生成代码 *--

	self.Settings = _G.Prefs.Settings:load()
end

function init_logic()
	
	self.ChangedSettings = {}
	self.freezingData = true
	-- 初始化所有设置
	local SubBasic = Ref.SubMain.SubScroll.SubViewport.SubContent

	-- 音频
	local function init_audio_volume(setting, bus)
		local volume = Settings[setting]
		if volume == nil then
			volume = math.floor(libunity.GetAudioVolume(bus) * 100 + 0.5)
			Settings[setting] = volume
		end
		return volume
	end

	SubBasic.SubAudio.tglVoice.value = not libunity.GetAudioMute("BGM")
	SubBasic.SubAudio.barVoice.value = init_audio_volume("aud.bgm.vol", "BGM")
	SubBasic.SubAudio.tglEffect.value = not libunity.GetAudioMute("SFX")
	SubBasic.SubAudio.barEffect.value = init_audio_volume("aud.sfx.vol", "SFX")

	-- 操作

	local preferredHp = Settings["battle.focus.preferredHp"]
	
	if preferredHp then
		SubBasic.SubPriorityTarget.tglHpLowest.value = true
	else
		SubBasic.SubPriorityTarget.tglNearest.value = true
	end

	SubBasic.SubAttackLock.tglLock.value = Settings["battle.focus.lockOnHit"]


	self.freezingData = nil
end

function show_view()
	
end

function on_recycle()
	self.freezingData = true

	-- 音频设置生效
	libunity.SetAudioMute("BGM", Settings["aud.bgm.mute"])
	libunity.SetAudioVolume("BGM", Settings["aud.bgm.vol"] / 100)

	libunity.SetAudioMute("SFX", Settings["aud.sfx.mute"])
	libunity.SetAudioVolume("SFX", Settings["aud.sfx.vol"] / 100)
end

return self

