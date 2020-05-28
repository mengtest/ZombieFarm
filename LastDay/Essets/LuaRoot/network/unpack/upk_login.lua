--
-- @file    network/unpack/upk_login.lua
-- @anthor  xingweizhen (weizhen.xing@funplus.com)
-- @date    2017-11-08 14:47:06
-- @desc    描述
--

local NW, P = _G.NW, {}

local _lastGameServerHeartTime
local _lastBattleServerHeartTime
local _heartCounter

--断线重连数据处理
local function processing_relogin_data()
	DY_DATA.friendListVersion = nil
end

NW.regist("LOGIN.SC.LOGIN", function (nm)
	local ret, err = NW.chk_op_ret(nm:readU32())
	local RanNames
	if err == nil then
		NW.send(NW.msg("COM.CS.CLIENT_DATA_GET"))
		local Session = _G.PKG["network/login"].get_session()
		Session.serverToken = nm:readU64()
		local hasRole = nm:readU32() ~= 0
		if hasRole then
			NW.send(NW.msg("LOGIN.CS.ENTER_GAME"), "LOGIN.SC.ENTER_GAME")
		else
			RanNames = {
				nm:readArray({}, nm.readString),
				nm:readArray({}, nm.readString),
			}
		end

		libsystem.SetAppTitle(Session.Account.acc.."@"..Session.Server.serverName)

		DY_DATA.RedSystem = _G.DEF.RedDotMgr.new()
		DY_DATA.RedSystem:init()
	end

	return { ret = ret, err = err, RanNames = RanNames, }
end)

NW.regist("LOGIN.SC.ENTER_GAME", function (nm)

	-- 登录完成，设置账号相关的用户数据
	local PrefDEF = _G.DEF.Pref
	local mainPlayer = DY_DATA:get_player()
	DY_DATA.RecentlyMets = PrefDEF.new("rmp#" .. mainPlayer.id)
	DY_DATA.RecentlyMets:onload(function (Data)
		-- 加载时要更新关系
		for _,v in ipairs(Data) do
			-- TODO 是否好友/队友/公会成员/陌生人
		end
	end)
	DY_DATA.RecentlyMets:onsave(function (Data)
		-- 保存时忽略关系
		for _,v in ipairs(Data) do v.relation = nil end
	end)
	local Settings = _G.Prefs.Settings:load()
	local settingVal = Settings["chat.channel.set"]

	if settingVal then
		DY_DATA.ChannelSet = settingVal
	else
		DY_DATA.ChannelSet = 127
	end

	local serverTime = nm:readU64()
	os.synctime(serverTime / 1000)
	local gameUidCreateTs = nm:readU64()

	local selfInfo = DY_DATA:get_self()
	if selfInfo.hp == nil then
		libunity.LogE("玩家血量数据丢失！！")
		selfInfo.hp = 100
	end

	if selfInfo.hp <= 0 then
		NW.get("GameTcp"):send(NW.msg("ROLE.CS.ROLE_REVIVAL"))
	else
		if not _G.PKG["guide/api"].load(0) then
			_G.SCENE.showSmoke = true
			_G.SCENE.allowSceneActivation = false
			_G.SCENE.limitLoadingBGM = true
			_G.SCENE.CloseWNDPrelude =  function ()
				local preludwnd = ui.find("WNDPrelude")
				if preludwnd then
					preludwnd.on_close_action()
				end
			end
			_G.SCENE.add_preload("atlas/OpeninAni/", "Cache")

			_G.SCENE.add_preload("fmod/CG/", "Cache")

			ui.show("UI/WNDPrelude",102)
		else
			local mapId = mainPlayer.map
			if mapId then
				-- 存在地图，进入地图
				NW.apply_map(1, mapId)
			else
				-- 进入世界地图
				SCENE.load_main()
			end
		end
	end

	local libvoice = require "libvoice.cs"
	libvoice.Init("1400136801", "kTSuMz7JyblWml3o", tostring(DY_DATA:get_player().id))

	local Team = rawget(DY_DATA, "Team")
	if Team then require("libvoice.cs").JoinRoom(Team.id, 1) end

	local radioAch = DY_DATA.Achieves[_G.CVar.Achieves.RADIO]

	if radioAch then
		NW.FRIEND.RequestGetFriendList()
		NW.FRIEND.RequestGetApplyList()
	end

end)

NW.regist("LOGIN.SC.RELOGIN", function (nm)
	local ret, err = NW.chk_op_ret(nm:readU32(), true)
	if err then
		_G.PKG["network/login"].drop_game(nil)
		processing_relogin_data()
	end

	return { ret = ret, err = err, }
end)

NW.regist("LOGIN.SC.LOGOFF_GAME", function (nm)
	local code = nm:readU32()
	_G.PKG["network/login"].drop_game(nil, code)
end)

local function get_ts(time)
	return math.ceil(time * 1000)
end

--GameServer:21
--BattleServer:22

NW.regist("COM.CS.KEEP_HEART", function (nm)
	local serverType = nm:readU32()
	debug.printY("[KEEP_HEART]"..serverType)

	local battleTcp = _G.DEF.Client.find("BattleTcp")
	local lastHeartTime = nil

	if serverType == 21 then
		_heartCounter = 0
		if battleTcp == nil or (not battleTcp:connected()) then
			lastHeartTime = _lastGameServerHeartTime
		end
		_lastGameServerHeartTime = nil
	elseif serverType == 22 then
		lastHeartTime = _lastBattleServerHeartTime
		_lastBattleServerHeartTime = nil
	end

	if lastHeartTime then
		local currTime = UE.Time.realtimeSinceStartup
		local requestTs, receivedTs = get_ts(lastHeartTime), get_ts(currTime)
		
		local latency = receivedTs - requestTs
		debug.printG("latency"..latency)
		DY_DATA.latency = latency
		if _G.ENV.development then
			libunity.SendMessage("/UIROOT", "SetPingValue", latency)
		end
	end
end)

function P.heart_beat_loop()
	_heartCounter = 0
	_lastGameServerHeartTime = nil
	_lastBattleServerHeartTime = nil
    libunity.StartCoroutine(nil, function ()
        while true do
			coroutine.yield(CVar.HEART_BEAT_INTERVAL)
			local nowTime = UE.Time.realtimeSinceStartup
			
			-- 游戏服心跳
			local isConnected = NW.MainCli:connected()
			if not isConnected then
				NW.MainCli:reconnect()
				_lastGameServerHeartTime = nil
				_heartCounter = 0
			elseif _heartCounter < 3 then
				if _lastGameServerHeartTime == nil then
					_lastGameServerHeartTime = nowTime
				end
				_heartCounter = _heartCounter + 1
				NW.MainCli:send(NW.msg("COM.CS.KEEP_HEART"))
            else
                -- 断线重连
                NW.disconnect(nil, true)
				_lastGameServerHeartTime = nil
				_heartCounter = 0
			end
			
			-- 战斗服心跳
			local battleTcp = _G.DEF.Client.find("BattleTcp")
			if battleTcp and battleTcp:connected() then
				if _lastBattleServerHeartTime == nil then
					_lastBattleServerHeartTime = nowTime
				end
				battleTcp:send(NW.msg("COM.CS.KEEP_HEART"))
			else
				_lastBattleServerHeartTime = nil
			end
        end
    end)
end

NW.LOGIN = P
