--
-- @file    network/unpack/upk_map.lua
-- @anthor  xingweizhen (weizhen.xing@funplus.com)
-- @date    2017-10-30 10:36:58
-- @desc    描述
--

local NW, P = _G.NW, {}

local function sc_objs_join(Objs)
	local CTRL = _G.PKG["game/ctrl"]
	for _,v in ipairs(Objs) do
		if v.name then CTRL.create(v) end
	end
	return Objs
end

local function sc_transport_info(nm)
	local pType, floor, id = nm:readU32(), nm:readU32(), nm:readU32()
	local Dsts = {}
	local n = nm:readU32()
	for i=1,n do
		table.insert(Dsts, {
				id = nm:readU32(), floor = nm:readU32(), textId = nm:readU32(),
				Needs = nm:readArray({}, NW.read_item),
				Costs = nm:readArray({}, NW.read_item),
			})
	end
	-- 传送
	return { type = pType, floor = floor, id = id, Dsts = Dsts, }
end

local function processing_map_events(nm, Stage)
	local eventInfo = {}
	local eventType = nm:readU32()
	eventInfo.eventType = eventType

	--地图关闭事件
	if eventType == 1 then
		eventInfo.leftTime = nm:readU32()
		eventInfo.closeTime = nm:readU32()

	--地图文本提示事件
	elseif eventType == 2 then
		eventInfo.textId = nm:readU32()

	--地图天气变化事件
	elseif eventType == 3 then
		local weather = nm:readU32()
		if Stage then
			Stage.weather = weather
		end
		eventInfo.weather = weather
		libunity.LogI("Update Weather:{0}", weather)

	--获得物品提示
	elseif eventType == 4 then
		local delayTime = nm:readU32()/1000 -- 服务器返回的是毫秒，转换成秒
		eventInfo.delayTime = delayTime
		eventInfo.ItemList = {}

		nm:readArray(eventInfo.ItemList, function(nm)
			return {
				id =  nm:readU32(),
				amount = nm:readU32()
			}
		end)

	--地图是否可以离开
	elseif eventType == 5 then
		--服务器没做
		local state = nm:readU32()

	--玩家升级提示
	elseif eventType == 6 then
		eventInfo.level = nm:readU32()

	--玩家死亡提示
	elseif eventType == 7 then
		--0:不知道的原因 1：饿死 2：渴死 3：饥渴死 4：被其他玩家杀死 5：被自己害死 6：被怪物杀死
		eventInfo.deathType = nm:readU32()
		eventInfo.liveTime = nm:readU32()
		eventInfo.monsterID = nm:readU32()
		eventInfo.killerName = nm:readString()

	--地图中箭头指引
	elseif eventType == 8 then
		local state = nm:readU32() == 1
		if state then
			eventInfo.EventArrowInfo = {
				targetType = nm:readU32(), --0:以对象ID为指引坐标 1：以坐标为指引
				obj = nm:readU32(),
				x = nm:readU32(),
				y = nm:readU32(),
			}
		end
		if Stage then
			Stage.EventArrowInfo = eventInfo.EventArrowInfo
		end

	--提示文字
	elseif eventType == 9 then
		eventInfo.state = nm:readU32() == 1
		if eventInfo.state then
			local content = nm:readString()
			eventInfo.showType = nm:readU32()--动态文字类型 0:无 1:倒计时 2：时间
			eventInfo.time = nm:readU32()

			local textId = tonumber(content)
			if textId then content = tostring(config("othertextlib").get_dat(textId)) end

			if eventInfo.showType == 1 then
				content = content:gsub("<TIME>", "{0}")
			else
				content = content:gsub("<TIME>", tostring(eventInfo.time - os.date2secs()))
			end
			eventInfo.EventHintText = content

			if Stage then
				Stage.EventHintText = content
			end
		end
	elseif eventType == 10 then
		local count = nm:readU32()
		if Stage then
			Stage.radioEventNum = count
		end

	elseif eventType == 11 then
		-- 已生存时长
		local Self = DY_DATA:get_self()
		local isSurviveTiming = nm:readU32() == 1
		local surviveTime = nm:readU32()

		Self.isSurviveTiming = isSurviveTiming

		if isSurviveTiming then
			Self.surviveTime = os.date2secs() - surviveTime
		else
			Self.surviveTime = surviveTime
		end

	-- 帮助日志
	elseif eventType == 12 then
		eventInfo.obj = nm:readU32()
		eventInfo.helpLogList = {}
		nm:readArray(eventInfo.helpLogList ,function(nm)
			local data = {
				helperUserId = nm:readU64(),
			}
			local paramStr = nm:readString()
			local params = paramStr:split_normal()
			local helpLog = TEXT.BuildHelpLog
			for _,v in pairs(params) do
				local realValue = v.value
				if v.key == "<Build_Id>" then
					local baseData = config("unitlib").get_dat(tonumber(v.value))
					realValue = tostring(baseData.name)
				end
				helpLog = string.gsub(helpLog, v.key, realValue)
			end
			data.helpLog = helpLog
			return data
		end)
	-- 限制区域
	elseif eventType == 14 then
		local open = nm:readU32() == 1
		local id = nm:readU32()

		local LimitAreas = nil
		if Stage then
			LimitAreas = table.need(Stage, "LimitAreas")
			for i,v in ipairs(LimitAreas) do
				if v.id == id then
					if open then
						-- 已存在，更新
						eventInfo = v
						eventInfo.open = open
					else
						-- 移除
						table.remove(LimitAreas, i)
					end
				break end
			end
		end

		if eventInfo.open == nil then
			-- 新增限制区域
			eventInfo.open = open
			eventInfo.id = id
			if LimitAreas then
				table.insert(LimitAreas, eventInfo)
			end
		end

		eventInfo.fx = nm:readU32()
		eventInfo.duration = nm:readU32()
		eventInfo.pos = UE.Vector3(nm:readU32() / 1000, 0, nm:readU32() / 1000)
		eventInfo.param1 = nm:readU32() / 1000
		eventInfo.param2 = nm:readU32() / 1000

		print(cjson.encode(eventInfo))
	end

	return eventInfo
end

function P.exit_map()
	NW.set_cli()
	-- 断开战斗服连接
	NW.disconnect("BattleTcp")
	-- 清空其他单位的道具信息
	DY_DATA:del_obj_items()
	-- 清除宠物数据
	DY_DATA:get_self().Pet = nil
end

function P.sc_apply_join(nm)
	local type, mapType = nm:readU32(), nm:readU32()
	-- 申请方式：1主动，2被动
	local act = nm:readU32()
	local ret, err = NW.chk_op_ret(nm:readU32())
	if err == nil then
		local CTRL = _G.PKG["game/ctrl"]

		-- 退出当前地图（如果有）
		_G.DEF.Stage.stop()
		CTRL.clear()

		local stageId = nm:readU64()
		local clock = nm:readU64()

		--地图当前天气及时间
		local timeScale = nm:readU32()
		local weather = nm:readU32()

		local Player = DY_DATA:get_player()
		local Self = DY_DATA:get_self()
		Self:reset()
		Self.pid = Player.id
		Self.id = nm:readU32()
		Self.pet = nm:readU32()
		Self.camp = nm:readU32()
		Self.level = Player.level
		Self.name = nil

		-- 地图信息
		local mapDat, mapType = nm:readU32(), nm:readU32()
		local mapW, mapH = nm:readU32(), nm:readU32()

		local Stage = _G.DEF.Stage.new(stageId, mapW, mapH)
		Stage:set_clock(clock)
		Stage.beginColck = clock
		libgame.SyncTimestamp(clock)
		Stage:set_dat(mapDat)
		Stage.home = stageId == Player.id
		Stage.fow = not Stage.home
		Stage.timeScale = timeScale
		Stage.weather = weather

		if Stage.home then
			-- 检查启动开局引导
			if _G.PKG["guide/api"].load(0) ~= 0 then
				CTRL.add_reg("game/event/prelude")
			end
		end

		print(string.format("NEW Stage = %s(%d)", tostring(Stage), mapDat))

		Self:read_id_action(nm)
		Self:set_weapon(_G.CVar.EQUIP_MAJOR_POS, _G.CVar.EQUIP_MINOR_POS)
		local EQUIP_SLOT2POS = _G.CVar.EQUIP_SLOT2POS
		for i,v in ipairs(EQUIP_SLOT2POS) do
			Self:set_dress(i, v)
		end
		Stage.Self = Self
		Stage:add_unit(Self)

		Stage.Pet = _G.DEF.Unit.new(Self.pet)

		Stage:read_units(nm, "read_sample")

		-- 载入地图
		SCENE.load_stage(Stage.Base)

		return Stage
	else
		-- 断开战斗服连接（如果有）
		NW.disconnect("BattleTcp")
	end
	return { ret = ret, err = err }
end

NW.regist("MAP.SC.APPLY_JOIN", P.sc_apply_join)

NW.regist("MAP.SC.JOIN", function (nm)
	local Stage = DY_DATA:get_stage()
	local mapId = nm:readU64()
	local ret, err = NW.chk_op_ret(nm:readU32())
	if err == nil then
		local clock = Stage:set_clock(nm:readU64())
	end
	return { ret = ret, err = err }
end)

NW.regist("MAP.SC.EXIT", function (nm)
	local stageId = nm:readU64()
	local ret, err = NW.chk_op_ret(nm:readU32())
	if err == nil then
		if stageId == 0 then
			local Stage = DY_DATA.World:get_curr_stage()
			if Stage and Stage.global then
				return
			end
		end
		P.exit_map()
	end

	return { ret = ret, err = err}
end)

NW.regist("MAP.SC.SYNC_MAP_EVENT", function (nm)
	local Stage = DY_DATA:get_stage()
	return processing_map_events(nm, Stage)
end)

NW.regist("MAP.SC.SYNC_ROLE_SURVIVE_INFO", function (nm)
	local Stage = DY_DATA:get_stage()
	if Stage then
		return Stage:read_units(nm, "read_healthy")
	else
		libunity.LogW("没有进入地图就收到了[MAP.SC.SYNC_ROLE_SURVIVE_INFO]")
	end
end)

NW.regist("MAP.SC.SYNC_OBJ_ADD", function (nm)
	local Stage = DY_DATA:get_stage()
	nm:readU64()
	Stage:set_clock(nm:readU64())
	return Stage:read_units(nm, "read_sample")
end)

NW.regist("MAP.SC.SYNC_OBJ_INFO", function (nm)
	local Stage = DY_DATA:get_stage()
	nm:readU64()
	Stage:set_clock(nm:readU64())
	return sc_objs_join(Stage:read_units(nm, "read_info"))
end)

NW.regist("MAP.SC.SYNC_OBJ_ADD_JOIN", function (nm)
	local Stage = DY_DATA:get_stage()
	if Stage then
		nm:readU64()
		Stage:set_clock(nm:readU64())
		return sc_objs_join(Stage:read_units(nm, "read_full"))
	else
		libunity.LogW("没有进入地图就收到了[MAP.SC.SYNC_OBJ_ADD_JOIN]")
	end
end)

NW.regist("MAP.SC.SYNC_OBJ_REMOVE", function (nm)
	local Stage = DY_DATA:get_stage()
	nm:readU64()
	Stage:set_clock(nm:readU64())

	local CTRL = _G.PKG["game/ctrl"]
	local IDs = {}
	local n = nm:readU32()
	for i=1,n do
		local id = nm:readU32()
		local Unit = Stage:del_unit(id)
		CTRL.handle("OBJ_LEAVE", Unit)

		libgame.DeleteObj(id, 1.5)
		if Unit.Pet then
			Stage:del_unit(Unit.Pet.id)
			libgame.DeleteObj(Unit.Pet.id, 1.5)
		end
		table.insert(IDs, id)
	end
	return IDs
end)

NW.regist("MAP.SC.SYNC_MAP_TEAMPLATE", function (nm)
	local Stage = DY_DATA:get_stage()
	if Stage then
		nm:readU64()
		Stage:set_clock(nm:readU64())

		return sc_objs_join(Stage:read_units(nm, "read_sample"))
	end
end)

NW.regist("MAP.SC.SYNC_OBJ_SPEED", function (nm)
	local Stage = DY_DATA:get_stage()
	local id = nm:readU32()
	local move = nm:readU32() * _G.CVar.LENGTH_SCALE
	local Unit = Stage:find_unit(id)
	if Unit then
		Unit.Attr.move = move
		if Unit.Form then
			local CacheAttr = Unit.Form.Data.Attr
			if CacheAttr and CacheAttr.move ~= move then
				CacheAttr.move = move
				_G.PKG["game/ctrl"].update(Unit, { Attr = CacheAttr })
			end
		end
	end
	return Unit
end)

NW.regist("MAP.SC.SYNC_OBJ_ATT", function (nm)
	local Stage = DY_DATA:get_stage()
	local id, Unit = nm:readU32()
	if Stage then
		Unit = Stage:find_unit(id)
	else
		Unit = DY_DATA:get_self()
	end
	if Unit then
		local Attr = table.need(Unit, "Attr")
		Attr.Damage = _G.DEF.Attr.dmg({
				lowL = nm:readU32(), lowU = nm:readU32(),
				midU = nm:readU32(), highU = nm:readU32(),
			})
		Attr.def = nm:readU32()
		nm:readU32() --Attr.move = nm:readU32() * _G.CVar.LENGTH_SCALE
		if Stage and Unit.Form then
			local CacheAttr = Unit.Form.Data.Attr
			if CacheAttr then
				local ChangedAttr = {}
				for k,v in pairs(Attr) do
					if CacheAttr[k] ~= v then
						CacheAttr[k] = v
						ChangedAttr[k] = v
					end
				end
				if next(ChangedAttr) then
					_G.PKG["game/ctrl"].update(Unit, { Attr = CacheAttr })
				end
			end
		end
	end
	return Unit
end)

NW.regist("MAP.SC.SYNC_OBJ_APPEND", function (nm)
	nm:readU64()--mapId
	nm:readU64()--timer

	local MapObjAppendInfoArr = nm:readArray({}, function(nm)
		local BBDlgLib = config("dialoguebubblelib")
		local MapObjAppendInfo = {}
		MapObjAppendInfo.objId = nm:readU32()
		MapObjAppendInfo.bubbleGroupID = nm:readU32()

		local bbDialogueInfo = BBDlgLib.get_dialogue_bubble_dat(MapObjAppendInfo.bubbleGroupID)

		if bbDialogueInfo then
			if bbDialogueInfo.type == 3 then
				return MapObjAppendInfo
			end

			local Stage = DY_DATA:get_stage()
			if Stage then
				if Stage.Obj_Append == nil then
					Stage.Obj_Append = {}
				end
				Stage.Obj_Append[MapObjAppendInfo.objId] = MapObjAppendInfo.bubbleGroupID
			end
			return MapObjAppendInfo
		end
	end)
	return MapObjAppendInfoArr
end)

NW.regist("TRANSPORT.SC.TRANSPORT", function (nm)
	nm:readU64()
	local ret, err = NW.chk_op_ret(nm:readU32())
	return { ret = ret, err = err }
end)

NW.regist("TRANSPORT.SC.TRANSPORT_INFO", function (nm)
	nm:readU64() -- time
	nm:readU32() -- objId
	local ret, err = NW.chk_op_ret(nm:readU32())
	local Info
	if err == nil then
		Info = sc_transport_info(nm)
	end

	return { ret = ret, err = err, Info = Info }
end)

NW.MAP = P
