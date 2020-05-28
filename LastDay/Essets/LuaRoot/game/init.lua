--
-- @file    game/init.lua
-- @anthor  xingweizhen (weizhen.xing@funplus.com)
-- @date    2017-12-18 13:14:29
-- @desc    描述
--

dofile("game/constant")
dofile("game/networkapi")
dofile("game/sceneapi")
dofile("game/dydataapi")

local ui = ui

local function chk_statusbar(Wnd)
	local StatWnd = ui.find("WNDTopBar")
	local StatusBar = Wnd.StatusBar
	if StatusBar then
		if StatWnd == nil then
			StatWnd = ui.show("UI/WNDTopBar", 99, StatusBar, true)
		elseif StatWnd.Ref then
			StatWnd.Context = StatusBar
			StatWnd.rfsh_topbar()
		else return end
		StatWnd.Wnd = Wnd
	elseif StatusBar == false then
		if StatWnd then StatWnd:close() end
	end
end

local UICheck = MERequire "game/uicheck"
ui.hook("willopen", function (wndName)
	local check = UICheck[wndName]
	if check then return check() end
	return true
end)

ui.hook("awaking", function (Wnd)
	NW.broadcast("CLIENT.SC.WND_OPEN", Wnd)
end)

ui.hook("starting", function (Wnd)
	chk_statusbar(Wnd)
end)

ui.hook("closing", function (Wnd)
	NW.broadcast("CLIENT.SC.WND_CLOSE", Wnd)
end)

ui.hook("pop", function (Wnd, PopWnd)
	-- if Wnd.StatusBar and (PopWnd == nil or not PopWnd.StatusBar) then
	-- 	ui.close("WNDTopBar")
	-- end
end)

local PrefDEF = _G.DEF.Pref
rawset(_G, "Prefs", {
	Settings = PrefDEF.new("Settings"),
})

rawset(ui, "package", function (prefab, depth, Context)
	if Context == nil then Context = {} end
	Context.wndName = prefab
	Context.pageIcon = "CommonIcon/ico_main_001"--默认页签icon
	ui.open("UI/WNDPackage", nil, Context)
end)

UGUI.UIButton.defaultSfx = "event:/UI/UI_click"
UGUI.UIToggle.defaultSfx = "event:/UI/UI_click"

_G.AUD.parent = "/UIROOT"

local DefaultGraphicSettigns = {
	stroke = true, resolution = 720, texture = 0, shadowQuality = 0, animationQuality = 2, frameRate = 30,
	maxModelCount = 30,
}
local GraphicSettings
local function get_setting_value(key)
	local Settings = GraphicSettings or DefaultGraphicSettigns
	return Settings[key] or DefaultGraphicSettigns[key]
end

rawset(_G, "def_graphic_settings", cjson.encode(DefaultGraphicSettigns))

rawset(_G, "apply_graphic_settings", function (settingsJson, isBaseline, segmentName)
	print("apply_graphic_settings: ", settingsJson)

	GraphicSettings = cjson.decode(settingsJson)

	UE.QualitySettings.masterTextureLimit = get_setting_value "texture"
	UE.QualitySettings.shadowResolution = get_setting_value "shadowQuality"
	UE.QualitySettings.blendWeights = get_setting_value "animationQuality"
	UE.Application.targetFrameRate = get_setting_value "frameRate"

	libgame.EnableOutline(GraphicSettings.stroke)
	libunity.SendMessage("/AssetsMgr", "SetResolution", get_setting_value("resolution"))
end)

rawset(_G, "get_graphic_settings", get_setting_value)
