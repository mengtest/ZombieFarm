--
-- @file    network/login.lua
-- @anthor  xingweizhen (weizhen.xing@funplus.com)
-- @date    2017-11-02 11:11:32
-- @desc    描述
--


local P = {}

-- 进入游戏跳过选服界面
P.AutoEnterGame = (not _G.ENV.debug) and (not _G.ENV.development)

local Session
function P.get_session() return Session end

-- 账号存取
-- ============================================================================
local AccountPref = _G.DEF.Pref.new("account")
local loadpref = AccountPref.load
AccountPref.load = function (self)
	local Data = loadpref(self)
	if Data.List == nil then Data.List = {} end
	return Data
end

-- 获取保存的帐号信息
function P.load_account(acc)
    local Accounts = AccountPref:load()

    if acc then
        return table.match(Accounts.List, { acc = acc })
    else return Accounts end
end

-- 保存的帐号信息

function P.save_account(Acc)
    local Accounts = P.load_account()
    local Account = table.match(Accounts.List, { acc = Acc.acc })
    if Account == nil then
        table.insert(Accounts.List, Acc)
    else
        Account.name, Account.pass, Account.type, Account.date
        	= Acc.name, Acc.pass, Acc.type, Acc.date
        if Acc.server then Account.server = Acc.server end
    end
    Accounts.last = Acc.acc
    table.sort(Accounts.List, function (a, b)
            if a.date == nil then a.date = 0 end
            if b.date == nil then b.date = 0 end
            return a.date > b.date
        end)
    AccountPref:save()
end

function P.clear_account()
	AccountPref:clear()
end

-- ============================================================================

local _HttpParams_
local function get_http_params(...)
	if _HttpParams_ == nil then
		local SystemInfo, Screen, Application = UE.SystemInfo, UE.Screen, UE.Application

		local info = libsystem.ProcessingData(cjson.encode({method = "DeviceData"}))
		local Info = info ~= "" and cjson.decode(info) or {}

		local deviceUniqueIdentifier = string.lower(SystemInfo.deviceUniqueIdentifier)
		local _, AssetVer = libasset.GetVersion()
		local Params = {
			mac = libsystem.GetMacAddr(),
			pf = string.lower(SystemInfo.deviceModel),
			os = string.lower(SystemInfo.operatingSystem),
			rl = string.format("%dX%d", Screen.width, Screen.height),
			idfa = Info.idfa or "",
			idfv = Info.idfv or "",
			desc = "",
			net = tostring(Application.internetReachability),
			imei = Info.imei or deviceUniqueIdentifier,
			ver = AssetVer.version,
		}


		-- 截取过长的文本
		for k, v in pairs(Params) do
			if type(v) == "string" and v:len() > 128 then
				libunity.LogE("String Len out,Key:"..k..",Value:"..v)
				Params[k] = v:sub(1,128)
			end
		end
		_HttpParams_ = Params

		libnetwork.SetParam("imei", Params.imei)
		libnetwork.SetParam("ver", AssetVer.version)
		libnetwork.SetParam("pf", string.lower(SystemInfo.deviceModel))
		libnetwork.SetParam("os", string.lower(SystemInfo.operatingSystem))
		libnetwork.SetParam("rl", string.format("%dX%d", Screen.width, Screen.height))
		libnetwork.SetParam("idfa", Info.idfa or "")
		libnetwork.SetParam("desc", "")
		libnetwork.SetParam("net", tostring(Application.internetReachability))
	end

	local Params = {}
	local Fields = {...}
	for _,v in ipairs(Fields) do
		Params[v] = _HttpParams_[v]
	end
	return Params
end

-- @===========================================================================
-- 验证会话定义
local SessionDEF = {}
SessionDEF.__index = SessionDEF
function SessionDEF.new(acc, data, callback)
	local temp = nil
	if acc == nil then
		acc = SystemInfo.deviceUniqueIdentifier
		data = acc
		temp = true
	end
	local self = {
		Account = {
			acc = acc:lower(), data = CS.CMD5.MD5String(data),
		},
		temp = temp,
		callback = callback,
	}
	return setmetatable(self, SessionDEF)
end
function SessionDEF.create(Account, callback)
	return setmetatable({ Account = Account, callback = callback, }, SessionDEF)
end

function SessionDEF:regist()
	-- body
end

function SessionDEF:login()
	local CHANNEL = _G.PKG["network/channel"]
	local url = CHANNEL.get_url("login")
	local Params = get_http_params("mac", "pf", "os", "rl", "idfa", "desc", "net", "ver", "imei")
	Params.lang = _G.lang
	Params.pid = CHANNEL.get_pid()
	Params.packid = CHANNEL.get_packid()
	Params.uid = self.Account.acc
	Params.data = self.Account.data
	Params.lastServer = self.Account.server or 0

	NW.http_post("LOGIN", url, Params, nil, self.callback)
	UI.Waiting.show(TEXT.tipConnecting)
end

function SessionDEF:set_patch(appUrl, resUrl)
	self.appUrl, self.resUrl = appUrl, resUrl
end

function SessionDEF:save_account()
	self.Account.date = os.date2secs()
	P.save_account(self.Account)
end

-- @===========================================================================
-- 服务器定义
local ServerDEF = {}
ServerDEF.__index = ServerDEF
ServerDEF.__tostring = function (self)
	return string.format("[Server#%d@%s:%d]", self.serverId, self.server.ip, self.server.port)
end
local ServerStatusIcon = {
	[0] = "Common/ico_log_04", -- normal
	[1] = "Common/ico_log_08", -- offline
	--"Login/ico_log_05",	-- busy
	--"Login/ico_log_06",	-- full
}
local ServerFlagLay = {
	[1] = "#5FA818",
	[2] = "#FF2400",
}

function ServerDEF:show_view(Ent)
    Ent.lbName.text = self.serverName

    local TEXT = _G.TEXT
    local flag, status = self.flagId, self.server.status
    libunity.SetActive(Ent.spFoot, status == 0 or flag ~= 0)
    Ent.spStatus:SetSprite(ServerStatusIcon[status])
    libunity.SetActive(Ent.spFlag, flag ~= 0)
    if flag ~= 0 and Ent.lbFlag then
    	Ent.spFlag.color = ServerFlagLay[flag]
    	Ent.lbFlag.text = TEXT.ServerFlags[flag]
    end
    --libunity.SetActive(Ent.spRole, (table.ifind(Session.Data.roleList, self.serverId)))
end
-- ============================================================================


local function handle_gamecenter(Ret)
	local othergc = cjson.decode(Ret.ext).othergc
	local gcs = othergc:split("|")
	local gc = gcs and gcs[1] or ""
	print(gc)

	UI.MBox.make("MBNormal")
		:set_param("content", TEXT.tipAccountChoose)
		:set_event(function ()
			libsystem.ProcessingData(cjson.encode{ method = "BindLogin", gc = gc, })
		end, function ()
			libsystem.ProcessingData(cjson.encode{ method = "NewLogin", })
		end)
		:show()
end

local function handle_verify_passed()
	local VerifyData = Session.Data
	local DefServer = VerifyData.server and setmetatable(VerifyData.server, ServerDEF)
	Session.ServerInf = {
		nTotal = VerifyData.serverSize,
		Default = DefServer,
		Recommend = nil, List = nil,
	}

	if VerifyData.ext then
		local CHANNEL = _G.PKG["network/channel"]
		if CHANNEL.get_pid() == 203 then
			local ext = cjson.decode(VerifyData.ext)
			if ext and type(ext) == "table" then
				Session.Ext = {
					isTemp = ext.istemp,
					gc = ext.gc,
					idfa = ext.idfa,
				}
				-- _LoginedAcc.gc = ext.gc
				-- _LoginedAcc.idfa = ext.idfa
				print(string.format("该账号是否是临时账号：%s", tostring(ext.istemp)))
			end
		end
	end
	Session:save_account()
	NW.broadcast("CLIENT.SC.VERIFY", {retCode = 1})

	libsystem.SetAppTitle(Session.Account.acc)
end

local function on_filelist_get(resp, isDone, err)
	if not isDone or err then return end

	if isDone and err == nil then
		ui.open("UI/WNDPatch", nil, {
				LFL = cjson.decode(resp),
				resUrl = Session.resUrl,
			})
	end
end

-- 版本有变更
local function handle_version_change(Ret)
	if not _G.ENV.using_assetbundle then
		libunity.LogE("版本不对，并且该版本无法更新")
		return
	end

	-- 版本过低

	local function calc_version(VerA, VerB)
		local n = #VerA
		for i=1,n do
			local v = VerA[i] - VerB[i]
			if v ~= 0 then return v, i end
		end
		return 0, nil
	end

	local function do_version_chk(locVer)
		local Ret_ver = Ret.ver
		local rootUrl, tarVer, lowVer = Ret_ver.url, Ret_ver.ver, Ret_ver.oldVer
		local folder = UE.Application.isEditor and "Editor" or _G.ENV.unity_platform
		local resUrl, appUrl =
			string.format("%s/Assets/%s/", rootUrl, folder),
			string.format("%s/App/%s/", rootUrl, folder)

		-- 最新版本号
		local TarVers = tarVer:splitn(".")
		-- 最低版本号
		local LowVers = lowVer:splitn(".")
		-- 本地版本号
		local LocVers = locVer:splitn(".")
		-- 是否强制更新
		local forceUpdate = (calc_version(LowVers, LocVers)) > 0
		local versionTip = TEXT["ver.new_update"] .."\n"..
			(forceUpdate and TEXT["ver.force_update"] or TEXT["ver.recommend_update"])

		local verUpdate, vi = calc_version(TarVers, LocVers)
		if verUpdate > 0 then
			Session:set_patch(appUrl, resUrl)
			if vi < 3 then
				-- print("存在更高的包版本")
		    	local function try_download_app()
		    		NW.check_internet(function ()
						ui.open("UI/WNDPatch", nil, {
								forceUpdate = forceUpdate,
								tarVer = tarVer, appUrl = appUrl,
							 })
		    		end)
		    	end
		    	if _G.ENV.unity_platform == "Android" then
		    		UI.MBox.make("MBNormal")
		    			:set_param("title", " ")
		    			:set_param("content", versionTip)
		    			:set_event(try_download_app, libunity.AppQuit)
		    			:show()
		    	else
		    		UI.MBox.make("MBNormal")
		    			:set_param("title", " ")
		    			:set_param("content", TEXT["ver.fmt_lower"]:csfmt(tarVer))
		    			:set_param("single", true)
		    			:set_param("block", true)
		    			:as_final()
		    			:set_event(libunity.AppQuit)
		    			:show()
				end
			else
				-- print("存在更高的资源版本")
				local function try_get_filelist()
					local filelist = resUrl .. "filelist"
					NW.http_get("PATCH", filelist, "", on_filelist_get)
				end

				UI.MBox.make("MBNormal")
					:set_param("title", " ")
					:set_param("content", versionTip)
					:set_event(try_get_filelist, forceUpdate and libunity.AppQuit or handle_verify_passed)
					:show()
			end
		end
	end

	local function prepare_vesion_chk()
		local LFL = rawget(_G.ENV, "LFL")
		if LFL then
			do_version_chk(LFL.version)
		else
			_G.UI.MBox.exception(prepare_vesion_chk)
		end
	end

	prepare_vesion_chk()
end

local function validate_resp(resp, isDone, err)
	if not isDone or err then
		-- TODO 是否要换域名重试？

		_G.UI.Toast.norm(TEXT.tipConnectPoorNetwork)
		print("网络连接失败")
	return end

	libnetwork.SetParam("uid", Session.Account.acc)

	print(resp)
	local Ret = cjson.decode(resp)
	if type(Ret) ~= "table" then return end

	local ValidateData = Ret.data
	Session.Data = ValidateData
	Session.Act = Ret.act

	if P.cdnUrl == nil then
		P.cdnUrl = ValidateData and ValidateData.cdnUrl
		if P.cdnUrl then
			SCENE.try_asset_download("Others")
		end
	end

	if Ret.ver then
		-- 版本有变更
		handle_version_change(Ret)
	else
		local libcsharpio = require "libcsharpio.cs"
		-- 尝试删除apk文件
		local patchRoot = _G.ENV.app_persistentdata_path .. "/Updates/"
		libcsharpio.CreateDir(patchRoot)
		libcsharpio.DeleteFile(patchRoot.."tmd.apk")

		local retCode = Ret.code
		if retCode == 1 then
			-- 登录成功
			handle_verify_passed()
			return true
		-- elseif retCode == 61 then
		-- 	-- 需要修改密码
		-- 	-- P.on_require_chpass()
		-- elseif retCode == 70 then
		-- 	handle_gamecenter(Ret)
		-- else
		-- 	if Session.temp then
		-- 		if retCode == 107 then
		-- 			print("临时账号已存在，自动登录")
		-- 			Session:login()
		-- 		elseif retCode == 101 then
		-- 			print("临时账号不存在，自动注册")
		-- 			Session:regist()
		-- 		else
		-- 			NW.chk_op_ret(retCode)
		-- 		end
		-- 	else
		-- 		if retCode == 54 or retCode == 53 then
		-- 			P.drop_game(nil, NW.get_error(retCode))
		-- 		else
		-- 			NW.chk_op_ret(retCode)
		-- 		end
		-- 	end
		end
		NW.broadcast("CLIENT.SC.VERIFY", {retCode = retCode})

	end
end

local function on_login_resp(resp, isDone, err)
	if not isDone or err then 
		NW.broadcast("CLIENT.SC.VERIFY", {retCode = -1})
		return
	end

	if validate_resp(resp, isDone, err) then
		libsystem.ProcessingData(cjson.encode{
				method = "SubmitData",
				tag = "OnLogined",
				Data = { account = Session.Account.acc, },
			})
	end
end

local function on_regist_resp(resp, isDone, err)
	if not isDone or err then return end

	if validate_resp(resp, isDone, err) then
		libsystem.ProcessingData(cjson.encode({
				method = "SubmitData",
				tag = "OnRegisted",
				Data = { account = Session.Account.acc, },
			}))
	end
end

local function on_server_list_resp(resp, isDone, err)
	if not isDone or err then return end

	print(resp)
	local Ret = cjson.decode(resp)
    if Ret.code == 1 then
        local ServerInf = Session.ServerInf
        local Default = ServerInf.Default
        local Recommend = setmetatable(Ret.server.defaultServer, ServerDEF)
        local start = Ret.server.start
        local ServerList = table.need(ServerInf, "List")
        for i,v in ipairs(Ret.server.list) do
            if Default.id == v.id then
                v = Default
            end
            setmetatable(v, ServerDEF)
            ServerList[start + i] = v

            if Recommend.id == v.id then
                Recommend = v
            end
        end

        ServerInf.Recommend = { Recommend }
        NW.broadcast("CLIENT.SC.SERVER_LIST", { start = start, amount = #Ret.server.list })
    else
    	NW.chk_op_ret(Ret.code)
    end
end

local function on_version_resp(resp, isDone, err)
	if not isDone or err then return end

	print(resp)
	local Ret = cjson.decode(resp)
	if Ret.code == 1 then

	end
end

function P.try_getver()
	local CHANNEL = _G.PKG["network/channel"]
	local Params = {
        pid = CHANNEL.get_pid(),
    }
	NW.http_get("VERSION", CHANNEL.get_url("getver"), Params, on_version_resp)
end

function P.try_regist(acc, pass)
	-- body
end

function P.try_login(acc, pass)
	if type(acc) == "table" then
		Session = SessionDEF.create(acc, on_login_resp)
	else
		local Account = P.load_account(acc)
		if Account then
			Session = SessionDEF.create(Account, on_login_resp)
		else
			Session = SessionDEF.new(acc, pass, on_login_resp)
		end
	end
	Session:login()
end

function P.try_server_list(index, amount, cbf)
	local CHANNEL = _G.PKG["network/channel"]
	local Params = {
        pid = CHANNEL.get_pid(),
		packid = CHANNEL.get_packid(),
        start = index,
        len = amount,
        token = Session.Data.token,
    }
	NW.http_get("SERVER", CHANNEL.get_url("serverlist"), Params, on_server_list_resp)
end

function P.try_enter_game(Server)
	local function on_enter_login()
		-- 登录前清除数据
		DY_DATA.clear()

		local CHANNEL = _G.PKG["network/channel"]
		local Params = get_http_params("ver", "imei", "mac", "pf", "os", "rl", "idfa", "desc", "net", "idfv")

		local nm = NW.msg("LOGIN.CS.LOGIN")
		-- 版本
		local ProtocolID = CHANNEL.get_protocol_id()
		nm:writeU32(ProtocolID)  --协议版本号
		nm:writeU32(CHANNEL.get_packid())  --渠道包号
		nm:writeU32(Server.serverId) --登陆服务器ID
		nm:writeString(Session.Data.token)  --userToken
		nm:writeString(Session.Data.sgin or "") --userChecker
		nm:writeString(_G.lang) --客户端语言
		nm:writeString(Params.ver) -- 客户端版本
		nm:writeString(Params.imei) --客户端唯一设备号
		nm:writeString(Params.mac) --mac地址
		nm:writeString(Params.pf) --设备机型
		nm:writeString(Params.os) 	--设备操作系统和版本
		nm:writeString(Params.rl) --设备分辨率
		nm:writeString(Params.idfa)  --苹果广告标识
		nm:writeString(Params.desc) --设备描述
		nm:writeString(Params.net)  --联网类型
		nm:writeString(Params.idfv)  --vindor标示符

		NW.send(nm)
		UI.Waiting.show(TEXT.tipLogingIn)
	end

	if Server == nil then
		Server = Session.Server
	else
		Session.Server = Server
	end

	if Server then
		local Default = Server.server
		local host, port = Default.ip, Default.port
		NW.connect(host, port, on_enter_login, P.relogin_server, P.drop_game)

		Session.Account.server = Server.serverId
		Session:save_account()

		UI.Waiting.show(TEXT.tipConnecting)
	end
end

function P.relogin_server()
	local function on_relogin_server()
	    local nm = NW.msg("LOGIN.CS.RELOGIN")
	    nm:writeString(Session.Data.token)
	    nm:writeString(Session.Data.sign)
	    nm:writeU64(Session.serverToken or 0)
	    NW.MainCli:send(nm)
	    UI.Waiting.show(TEXT.tipLogingIn)
	end
    local Server = Session.Server
    local Default = Server.server
    local host, port = Default.ip, Default.port
	NW.connect(host, port, on_relogin_server, P.relogin_server, P.drop_game)
	UI.Waiting.show(TEXT.tipConnecting)
end


function P.drop_game(cli, ret)
	NW.disconnect()
	_G.UI.Waiting.hide()
	local tips
	if type(ret) == "number" then
		tips = TEXT.LogoffTips[ret]
	else
		tips = ret
	end
	if tips == nil then tips = TEXT.UnknowLogoff end

	--_G.UI.MBox.clear()
	_G.UI.MBox.make()
		:as_final():set_depth(200)
		:set_param("title", TEXT.tipDropGame)
		:set_param("content", tips)
		:set_param("single", true)
		:set_param("block", true)
		:set_event(P.logout)
		:show()
end

function P.logout()
	DY_TIMER.clear()
	require("libvoice.cs").Uninit()
	NW.disconnect()
	_G.SCENE.load_login()
end

return P
