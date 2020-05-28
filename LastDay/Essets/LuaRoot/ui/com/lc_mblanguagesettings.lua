--
-- @file    ui/com/lc_mblanguagesettings.lua
-- @author  shenbingkang
-- @date    2018-10-18 10:40:51
-- @desc    MBLanguageSettings
--

local self = ui.new()
local _ENV = self

local Langs

local function get_langu()
	local Langs = {}
	table.insert(Langs, { name = "English", lang = "en", })

	local hasCnBundle = DY_DATA.World:has_bundle("fonts/MainFont.cn")
	if hasCnBundle then
		table.insert(Langs, { name = "简体中文", lang = "cn", })
	end

	return Langs
end

local function select_lang(Lang)
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
		   Ref.SubMain.GrpLangs:get(preIndex).tgl.value = true
		   freezingData = nil
	   end

	   UI.MBox.make()
		   :set_param("content", TEXT.askChangeLang)
		   :set_event(confirm, cancel)
		   :show()
   end
end


--!* [开始] 自动生成函数 *--

function on_submain_grplangs_entlang_click(tgl)
	if tgl.value then
		local index = ui.index(tgl)
		select_lang(Langs[index])
	end
end
--!* [结束] 自动生成函数  *--

function init_view()
	ui.group(Ref.SubMain.GrpLangs)
	--!* [结束] 自动生成代码 *--
	self.Settings = _G.Prefs.Settings:load()
end

function init_logic()
	Langs = get_langu()

	self.ChangedSettings = {}
	self.freezingData = true

	local GrpLangs = Ref.SubMain.GrpLangs

	GrpLangs:dup(#Langs, function (i, Ent, isNew)
		local Lang = Langs[i]
		Ent.lbLang.text = Lang.name
	end)

	for i,v in ipairs(Langs) do
		if v.lang == _G.lang then
			GrpLangs:find(i).tgl.value = true
		break end
	end

	self.freezingData = nil
end

function show_view()
	
end

function on_recycle()
	self.freezingData = true

	libugui.AllTogglesOff(Ref.SubMain.GrpLangs.go)
end

return self

