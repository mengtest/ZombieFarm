--
-- @file    game/sceneapi.lua
-- @anthor  xingweizhen (weizhen.xing@funplus.com)
-- @date    2017-12-18 13:13:49
-- @desc    描述
--

local SCENE = _G.SCENE

local function get_filelist_path()
	return string.format("%s/AssetBundles/filelist", _G.ENV.app_persistentdata_path)
end

SCENE.BGMForScene = {
	Login = "Music/C_WorldmapBGM",
	Main = "Music/C_WorldmapBGM",
}

local PreloadsForLevel = {
	Login = {
		{ path = "atlas/Login/", method = "Cache", },
		{ path = "fmod/worldmapBGM/", },
	},
	Main = {
		{ path = "shared/world/", },
		{ path = "atlas/MOW/", method = "Cache", },
		{ path = "fmod/worldmapBGM/", },
	},
	Stage = {
		{ path = "atlas/Battle/", method = "Cache", },
		{ path = "atlas/Building/", },
		{ path = "shared/fx/", },
		{ path = "fx/common/", method = "Cache" },
		{ path = "fx/move/", method = "Cache" },
		{ path = "fmod/Common/", },
		{ path = "fmod/Footsteps/", },
		{ path = "fmod/Weather/", },

		-- TODO 根据配置加载
		{ path = "fmod/Battle BGM/", },
	},
}

local function prepare_level_assets(level, Preloads)
	if Preloads == nil then Preloads = {} end
	local Assets = PreloadsForLevel[level]
	if Assets then
		for _,v in ipairs(Assets) do
			table.insert(Preloads, v)
		end
	end
	return Preloads
end

local function on_stage_loadded(launching)
	if not NW.connected() and launching then
		MERequire("debug/localdata")
		_G.DEF.Stage.launch()
	end
	ui.show("UI/WNDChat", 11)
	ui.show("UI/FRMExplore", 10)
end

local function load_file_list()
	if _G.ENV.using_assetbundle then
		local filelistPath = get_filelist_path()
		local json = require("libcsharpio.cs").ReadAllText(filelistPath)
		rawset(_G.ENV, "LFL", cjson.decode(json))

		_G.PKG["network/login"].try_getver()
		--SCENE.try_asset_download("Others")
	end
end

local LoadedLevelCBF = {
	Launch = function (launching)
		UE.Object.DontDestroyOnLoad(libunity.Find("/LaunchCanvas"))
		SCENE.hideLoadingBar = true
		SCENE.load_login()
	end,
	Login = function (launching)
		libunity.Destroy("/LaunchCanvas")
		libsystem.SetAppTitle()
		ui.open("UI/WNDLogin")
	end,

	Main = function (launching)
		if not NW.connected() then MERequire("debug/localdata") end
		ui.show("UI/WNDChat", 11)
		ui.show("UI/FRMWorld", 1)
	end,
}

function SCENE.user_level_loaded(levelName, launching)
	-- 关闭当前消息框（如果有）
	UI.MBox.close()

	print(string.format("Level Loaded [%s]", levelName))

	SCENE.inLevel = levelName:sub(0, 5) == "stage"
	local on_loaded = nil
	if SCENE.inLevel then
		on_loaded = on_stage_loadded
	else
		on_loaded = LoadedLevelCBF[levelName]
	end

	if launching then
		if launching then trycall(load_file_list) end
		-- 设置初始化
		local SettingsData = _G.Prefs.Settings:load()
    	libgame.UpdateSettings(SettingsData)

		-- 设置语言选项
	    local LangNames = setmetatable({
	    	--Chinese = "cn", ChineseSimplified = "cn",
	    }, { __index = function (t, n) return "en" end })
	    local lang = SettingsData.lang or LangNames[UE.Application.systemLanguage.name]
	    libugui.SetLocalize(lang, "en")
	    ui.setloc(nil, lang)

		libasset.LoadAsync(nil, "rawtex/bg_com_001/", "Always")
		libasset.LoadAsync(nil, "rawtex/bg_com_002/", "Always")

		libasset.LoadAsync(nil, "atlas/PlayerIcon/", "Always")
		libasset.LoadAsync(nil, "atlas/Common/", "Always")
		libasset.LoadAsync(nil, "atlas/Battle/", "Always")
		libasset.LoadAsync(nil, "atlas/CommonIcon/", "Always")
		libasset.LoadAsync(nil, "atlas/Itemicon/", "Always")
		libasset.LoadAsync(nil, "shared/Animation/", "Always")
		libasset.LoadAsync(nil, "Game/", "Forever")
		libasset.LoadAsync(nil, "dynamicfont/", "Always")
		libasset.LoadAsync(nil, "fonts/MainFont." .. lang .. "/", "Always")
		libasset.LoadAsync(nil, "ui/", "Forever")
		local Preloads = PreloadsForLevel[SCENE.inLevel and "Stage" or levelName]
		if Preloads then
			for i,v in ipairs(Preloads) do libasset.LoadAsync(nil, v.path, v.method) end
		end
		libasset.FinishLoadAsync(function ()
			on_loaded(launching)
			if _G.ENV.debug or _G.ENV.development then
				ui.create("UI/LogViewer", 1000)
			end
			_G.AUD.new(SCENE.BGMForScene[levelName])
		end)

		-- 音频设置
		local Settings = _G.Prefs.Settings:load()
		libunity.SetAudioMute("BGM", Settings["aud.bgm.mute"])
		libunity.SetAudioVolume("BGM", (Settings["aud.bgm.vol"] or 100) / 100)

		libunity.SetAudioMute("SFX", Settings["aud.sfx.mute"])
		libunity.SetAudioVolume("SFX", (Settings["aud.sfx.vol"] or 100) / 100)

	else
		on_loaded(launching)
	end
end

local function load_level(levelPath)
	libunity.LoadLevel(levelPath, nil, function(levelName, launching)
		SCENE.on_level_loaded(levelName, launching)
	end)
end

local function get_asset4loading(world)
	DY_DATA.Asset4LoadingLevel.Tip = config("loadinglib").ran_get()
	if world then

	else
		local World = rawget(DY_DATA, "World")
		local entId = CVar.HOME_ID
		if World and World.Travel and World.Travel.src then
			entId = World.Travel.src
		end

		local EntData = config("maplib").get_ent(entId)
		if EntData then
			DY_DATA.Asset4LoadingLevel.entId = entId
			local path = string.format("rawtex/%s/%s", EntData.picture, EntData.picture)
			DY_DATA.Asset4LoadingLevel.picPath = path
			return { path = path }
		else
			libunity.LogE("关卡入口数据为空！id={0}", entId)
		end
	end
end

local function prepare_extra_assets(Preloads)
	local ExtPreloads = table.take(SCENE, "Preloads")
	if ExtPreloads then
		for _,v in ipairs(ExtPreloads) do
			table.insert(Preloads, v)
		end
	end
	libasset.PrepareAssets(Preloads)
end

function SCENE.add_preload(path, method)
	table.insert(table.need(SCENE, "Preloads"), { path = path, method = method })
end

function SCENE.load_login()
	local Preloads = {
		{ path = "rawtex/bg_com_002/", }
	}
	prepare_level_assets("Login", Preloads)
	prepare_extra_assets(Preloads)
	load_level("scenes/login/Login")
end

function SCENE.load_main(Preloads)
	-- 请求世界地图数据更新
	local World = DY_DATA.World
	local ver = World.ver or 0
	NW.send(NW.msg("WORLD_MAP.CS.WORLD_INFO"):writeU32(ver))

	local Preload = get_asset4loading(true)
	if Preload then
		if Preloads == nil then Preloads = {} end
		table.insert(Preloads, 1, Preload)
	end

	Preloads = prepare_level_assets("Main", Preloads)
	prepare_extra_assets(Preloads)
	load_level("scenes/world/Main")
end

function SCENE.load_stage(StageData)
	local levelName = StageData.path
	local levelGrp, n = levelName:gsub("(%a+%_%w+)%_%w+", "scenes/%1/")
	if n > 0 then
		_G.DEF.Stage.launch()

		local Preloads = {}
		local Preload = get_asset4loading(false)
		if Preload then table.insert(Preloads, Preload) end

		prepare_level_assets("Stage", Preloads)
		-- 预加载建筑资源
		for _,v in pairs(DY_DATA:get_stage().Units) do
			local UnitBase = v:get_base_data()
			if UnitBase.oType == "building" then
				local UnitTmpl = v:get_tmpl_data()

				local modelName = UnitTmpl.model
				if v.randomModelIndex then
					modelName = UnitTmpl.modelGroup[v.randomModelIndex]
				end

				table.insert(Preloads, {
						path = string.format("units/%s/", modelName),
						method = "Cache",
					})
			end
		end
		prepare_extra_assets(Preloads)
		load_level(levelGrp..levelName)
	else
		libunity.LogE("场景名称错误：{0}", levelName)
	end
end

-- 资源下载管理
local start_download, start_unpack
local dl_pack, dl_url, dl_save, dl_current, dl_total, dl_try
local download_progress
local unpack_progress, UnpackAssets
local asset_error

local function on_unpacking(progress, List)
	local LFL = rawget(_G.ENV, "LFL")
	if LFL then
		for _,v in ipairs(List) do
			UnpackAssets[v.name] = { md5 = v.md5, siz = v.siz, }
		end
	end

	unpack_progress = progress
	if progress < 0 then
		local err = List
		libunity.LogW("unpack error: {0}", err)
		-- 错误：删除源文件
		require("libcsharpio.cs").DeleteFile(dl_save)

		--UI.MBox
		UnpackAssets = nil
		dl_url, dl_save = nil, nil
		libunity.LogE("{0}", List)
	elseif progress == 1 then
		if LFL then
			LFL.Downloads[dl_pack] = nil
			for k,v in pairs(UnpackAssets) do LFL.Assets[k] = v end
			libasset.UpdateBundleList(LFL.Assets)
			local filelist = string.format("%s/AssetBundles/filelist", _G.ENV.app_persistentdata_path)
			require("libcsharpio.cs").WriteAllText(filelist, cjson.encode(LFL))
		end
		require("libcsharpio.cs").DeleteFile(dl_save)
		-- 完成
		UnpackAssets = nil
		dl_url, dl_save = nil, nil
		download_progress, unpack_progress = nil, nil
	end

	NW.broadcast("CLIENT.SC.UNPACKING_ASSET", progress)
end

local function on_download(url, current, total, isDone, err)
	download_progress = current / total
	NW.broadcast("CLIENT.SC.DOWNLOADING_ASSET", download_progress)
	dl_current, dl_total = current, total

	if isDone then
		if err == nil then

			-- 开始解压文件
			download_progress, unpack_progress = nil, 0
			UnpackAssets = {}
			start_unpack(dl_save)
			NW.broadcast("CLIENT.SC.UNPACKING_ASSET", 0)
		else
			libunity.LogW("download error: {0}", err)
			if string.find(err, "IOException") then
				-- IO错误，无法继续，提醒

			else
				libunity.Invoke(nil, 1, start_download)
			end
		end
	end
end

start_download = function()
	dl_try = dl_try + 1
	print(string.format("开始第%d次下载：%s", dl_try, dl_url))
	NW.http_download(dl_url, dl_save, on_download)
end

start_unpack = function ()
	local dest = string.format("%s/Downloads", _G.ENV.app_persistentdata_path)
	return libasset.Unpack(dl_save, dest, 1024 * 128, on_unpacking)
end

function SCENE.try_asset_download(pack)
	local LFL = rawget(_G.ENV, "LFL")
	if LFL then
		local Info = LFL.Downloads[pack]
		if Info then
			local cdnUrl = _G.PKG["network/login"].cdnUrl

			local folder = UE.Application.isEditor and "Editor" or _G.ENV.unity_platform
			dl_pack = pack
			dl_url = string.format("%s/%s/%s", cdnUrl, folder, pack)
			dl_save = string.format("%s/Updates/%s", _G.ENV.app_persistentdata_path, pack)
			dl_try = 0
			download_progress, unpack_progress = 0, nil


			start_download()
		end
	end
end

-- 单个资源下载完成
function SCENE.on_asset_downloaded(bundleName, siz)
	local LFL = rawget(_G.ENV, "LFL")
	if LFL then
		LFL.Assets[bundleName].siz = siz

		libcsharpio.WriteAllText(get_filelist_path(), cjson.encode(LFL))
	end
end

function SCENE.get_progress()
	return download_progress, unpack_progress
end

function SCENE.has_bundle(bundleName)
	local LFL = rawget(_G.ENV, "LFL")
	if LFL then
		return LFL.Assets[bundleName] ~= nil
	end

	return true
end
