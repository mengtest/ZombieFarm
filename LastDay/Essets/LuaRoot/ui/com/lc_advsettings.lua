--
-- @file    ui/com/lc_advsettings.lua
-- @author  xingweizhen
-- @date    2018-07-03 23:44:28
-- @desc    ADVSettings
--

local self = ui.new()
local _ENV = self

local GraphicFuncs = {
	Outline = {
		get = libgame.EnableOutline,
		set = libgame.EnableOutline,
	},
	["Point Light"] = {
		get = libgame.EnablePointlit,
		set = libgame.EnablePointlit,
	},
	Resolution = {
		get = libasset.GetResHeight,
		set = function (value)
			value = math.tointeger(value)
			if value == nil then value = 0 end
			libunity.SendMessage("/AssetsMgr", "SetResolution", value)
		end,
	},
	FrameRate = {
		get = function () return UE.Application.targetFrameRate end,
		set = function (value) UE.Application.targetFrameRate = value end,
	},
}

local Shadows = { [0] = "Disable", [1] = "HardOnly", [2] = "All" }
local ShadowResolution = { [0] = "Low", [1] = "Medium", [2] = "High", [3] = "VeryHigh", }
local Resolutions = { 720, 1080, 0, }

local SettingOptions = {
	{
		tab = "Quality",
		get = function (name) return UE.QualitySettings[name] end,
		set = function (name, value) UE.QualitySettings[name] = value end,
		{
			name = "antiAliasing", min = 0, max = 3,
			v2s = function (v) return v > 0 and 2 ^ v or 0 end,
			s2v = function (s) return s > 0 and math.log(s, 2) or 0 end,
			tot = function (s) return math.tointeger(s) .. "x" end,
		},
		{
			name = "vSyncCount", min = 0, max = 2,
			v2s = function (v) return v end,
			s2v = function (s) return s end,
			tot = function (s) return tostring(math.tointeger(s)) end,
		},
		{
			name = "shadows", min = 0, max = 2,
			v2s = function (v) return v end,
			s2v = function (s) return s.id end,
			tot = function (s) return Shadows[s] or s.name end,
		},
		{
			name = "shadowResolution", min = 0, max = 3,
			v2s = function (v) return v end,
			s2v = function (s) return s.id end,
			tot = function (s) return ShadowResolution[s] or s.name end,
		},
	},
	{
		tab = "Graphic",
		get = function (name) return GraphicFuncs[name].get() end,
		set = function (name, value) GraphicFuncs[name].set(value) end,
		{
			name = "Outline", min = 0, max = 1,
			v2s = function (v) return v == 1 end,
			s2v = function (s) return s and 1 or 0 end,
			tot = function (s) return tostring(s) end,
		},
		{
			name = "Point Light", min = 0, max = 1,
			v2s = function (v) return v == 1 end,
			s2v = function (s) return s and 1 or 0 end,
			tot = function (s) return tostring(s) end,
		},
		{
			name = "Resolution", min = 1, max = 3,
			v2s = function (v) return Resolutions[v] end,
			s2v = function (s) return table.ifind(Resolutions, s) end,
			tot = function (s) return s == 0 and "Auto" or tostring(s) end,
		},
		{
			name = "FrameRate", min = 0, max = 1,
			v2s = function (v) return v == 0 and 30 or 60 end,
			s2v = function (s) return s == 30 and 0 or 1 end,
			tot = function (s) return s == 30 and "30" or "60" end,
		},
	},
}

local function update_settings(Settings)
	self.freezingData = true
	Ref.SubMain.SubOptions.SubView.GrpOptions:dup(#Settings, function (i, Ent, isNew)
		local Set = Settings[i]
		local s = Settings.get(Set.name)
		Ent.lbOpt.text = Set.name
		Ent.lbValue.text = Set.tot(s)
		Ent.barOpt.minValue = Set.min
		Ent.barOpt.maxValue = Set.max
		Ent.barOpt.value = Set.s2v(s)
	end)
	self.freezingData = nil
end

--!* [开始] 自动生成函数 *--

function on_submain_grptabs_enttab_click(tgl)
	if self.freezingData then return end

	if tgl.value then
		update_settings(SettingOptions[ui.index(tgl)])
	end
end

function on_setting_value_changed(bar)
	local Settings = SettingOptions[ui.index(libugui.GetTogglesOn(Ref.SubMain.GrpTabs.go)[1])]
	local i = ui.index(bar)
	local Opt = Settings[i]
	local s = Opt.v2s(bar.value)
	Ref.SubMain.SubOptions.SubView.GrpOptions:get(i).lbValue.text = Opt.tot(s)

	if self.freezingData then return end
	Settings.set(Opt.name, s)
end
--!* [结束] 自动生成函数  *--

function init_view()
	ui.group(Ref.SubMain.GrpTabs)
	ui.group(Ref.SubMain.SubOptions.SubView.GrpOptions)
	--!* [结束] 自动生成代码 *--
end

function init_logic()

	Ref.SubMain.GrpTabs:dup(#SettingOptions, function (i, Ent, isNew)
		local Setting = SettingOptions[i]
		Ent.lbTab.text = Setting.tab
		Ent.lbChkTab.text = Setting.tab
		if i == 1 then Ent.tgl.value = true end
	end)
end

function show_view()

end

function on_recycle()
	libugui.AllTogglesOff(Ref.SubMain.GrpTabs.go)
end

return self

