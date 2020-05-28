--
-- @file    network/unpack/upk_world.lua
-- @anthor  xingweizhen (weizhen.xing@funplus.com)
-- @date    2018-04-08 11:23:24
-- @desc    描述
--

local NW, P = _G.NW, {}
local log = _G.newlog()

local StagePlayMODE = {
	[1] = "Single", [2] = "Multi",
	[3] = "CampAttack", [4] = "CampRevenge",
}
-- WMStageInfo
local function sc_stage_info(nm)
	local Info = {
		id = nm:readU32(),
		mapId = nm:readU64(),
		mType = nm:readU32(),
		play = nm:readU32(),
		global = nm:readU32() ~= 0,
		allowRematch = nm:readU32() ~= 0,
		allowPublic = nm:readU32() ~= 0,
		campAllotMode = nm:readU32(),
		maxPlayerCount = nm:readU32(),
	}
	Info.mode = StagePlayMODE[Info.play]

	local extPlay = nm:readString()
	if Info.mType == 3 then
		-- 多人双阵营对抗
		Info.Ext = cjson.decode(extPlay)
	end

	return Info
end

-- WMEnterInfo
local function sc_entrance_base(nm, Info)
	if Info == nil then Info = {} end
	Info.id = nm:readU32()
	Info.mType = nm:readU32()
	Info.reqLevel = nm:readU32()
	Info.fov = nm:readU32()
	Info.SupportVehicles = nm:readArray({}, nm.readU32)
	Info.maxMatchTeam = nm:readU32()
	Info.maxNewTeam = nm:readU32()
	Info.NewTeamCosts = {
		energy = nm:readU32(),
		Items = nm:readArray({}, NW.read_item),
	}

	return Info
end

-- WMStageGroupData
local function sc_entrance_ext(nm, Info)
	if Info == nil then
		Info = {}
		Info.id = nm:readU32()
	end

	Info.entranceState = nm:readU32() --剩余时间显示状态 1：入口关闭剩余时间 2：入口下次开放的剩余时间
	local dura = nm:readU32()

	if Info.entranceState == 0 then
		Info.entranceState = 1
		dura = -1
	end

	--debug.printY("入口id:"..Info.id..",剩余时间状态:"..Info.entranceState..",倒计时:"..dura)
	if dura > 0 then
		_G.PKG["game/timers"].launch_stageclose_timer(Info.id, dura)
	end
	Info.dura = dura

	--上次死亡的地点
	Info.IsDeathPlace = nm:readU32() == 1

	Info.nMatchTeam = nm:readU32()
	Info.nNewTeam = nm:readU32()
	Info.Coord = NW.read_coord(nm)
	Info.name = nm:readString()
	Info.eventId = nm:readU32()
	Info.Stages = nm:readArray({}, sc_stage_info)
	table.sort(Info.Stages, function (a, b) return a.play < b.play end)

	return Info
end

local function sc_entrance_info(nm)
	local Info = {}
	sc_entrance_base(nm, Info)
	Info.hide = nm:readU32() == 0
	if not Info.hide then
		nm:readU32()
		sc_entrance_ext(nm, Info)
	end
	return Info
end

local function sc_travel_info(nm)
	local Info = {
		src = nm:readU32(),
		dst = nm:readU32(),
	}
	if Info.dst > 0 then
		Info.lastTool = Info.tool
		Info.tool = nm:readU32()
		Info.leftTime, Info.totalTime = math.floor(nm:readU64() / 1000), math.floor(nm:readU64() / 1000)
		Info.Points = nm:readArray({}, NW.read_coord)
	end
	print(cjson.encode(Info))

	return Info
end

local function sc_path_info(nm)
	return {
		tool = nm:readU32(),
		dura = math.ceil(nm:readU32() / 1000),
		cost = nm:readU32(),
	}
end

-- VehicleInfo
function P.sc_vehicle_info(nm)
	return {
		curDura = nm:readU32(), maxDura = nm:readU32(),
		curFuel = nm:readU32(), maxFuel = nm:readU32(),
		id = nm:readU32(), obj = nm:readU32(), dat = nm:readU32(),
	}
end

local function sc_chk_vehicle_info(nm)
	local vehicleId = nm:readU32()
	return vehicleId > 0 and P.sc_vehicle_info(nm) or nil
end

local function read_Weather(nm)
	local weatherInfo = {}
	weatherInfo.entranceId = nm:readU32()
	weatherInfo.weather = nm:readU32()
	weatherInfo.temperature = nm:readU32()
	weatherInfo.endTime = math.floor(nm:readU64() / 1000)
	return weatherInfo
end

NW.regist("WORLD_MAP.SC.WORLD_INFO", function (nm)
	local World = setmetatable(DY_DATA.World, _G.DEF.World)

	local ver = nm:readU32()
	print(string.format("World Ver: %s->%s", tostring(World.ver), tostring(ver)))
	local dirty
	if World.ver ~= ver then
		dirty = true
		World.ver = ver
		local WorldTime = nm:readU32()--世界时间（分钟），用于地图入口显示
		WorldTime = 86400 - WorldTime * 60 --一天剩下的时间(秒)

		local step = 24 / _G.CVar.TIME.DayTime
		WorldTime = WorldTime / step
		local oneDaySeconds = _G.CVar.TIME.DayTime * 3600

		_G.PKG["game/timers"].launch_worldtime_timer(WorldTime, oneDaySeconds)

		local prevsrc = World.Travel and World.Travel.src
		World.Travel = sc_travel_info(nm)
		World.Entrances = nm:readArray({}, sc_entrance_info)
		-- 地图信息更新时，清空缓存路径信息
		if prevsrc ~= World.Travel.src then
			World.EntrancePaths = nil
		end
	end
	World.Vehicle = sc_chk_vehicle_info(nm)

	return { World = World, dirty = dirty, }
end)

NW.regist("WORLD_MAP.SC.WORLD_MOVE", function (nm)
	local ret, err = NW.chk_op_ret(nm:readU32())
	if err == nil then
		local World = DY_DATA.World
		World.Travel = sc_travel_info(nm)
		World.Vehicle = sc_chk_vehicle_info(nm)
		return World
	else
		-- 尝试移动失败要还原状态
		local World = rawget(DY_DATA, "World")
		if World and World.Travel and World.Travel.Points == nil then
			World.Travel.dst = 0
		end
	end
end)

NW.regist("WORLD_MAP.SC.STAGE_GROUP_INFO", function (nm)
	local alertEventArr = {}

	local World = DY_DATA.World
	if World.Entrances == nil then
		libunity.LogE("没有收到地图入口信息就收到了[WORLD_MAP.SC.STAGE_GROUP_INFO]")
		return
	end
	nm:readArray({}, function(nm)
		local newStageID = nm:readU32()
		local stageExt = nil
		local orgDura = 1
		for _,v in pairs(World.Entrances) do
			if v.id == newStageID then
				stageExt = v
				orgDura = v.dura and v.dura or 0
				break
			end
		end
		local bStageInfoErr = false
		if stageExt == nil then
			bStageInfoErr = true
			libunity.LogE("StageGroupInfo:#{0}信息刷新错误。原因：WORLD_INFO中未包含此入口信息", newStageID)
			stageExt = {id = newStageID,}
		end

		sc_entrance_ext(nm, stageExt)

		if orgDura <= 0 and stageExt.dura > 0 and not bStageInfoErr then
			stageExt.hide = false
			table.insert(alertEventArr, stageExt)
		end
	end)

	return alertEventArr
end)

NW.regist("WORLD_MAP.SC.GET_TARGET_PATH_INFO", function (nm)
	local entranceId = nm:readU32()
	local EntrancePaths = table.need(DY_DATA.World, "EntrancePaths")
	local Paths = table.tomap(nm:readArray({}, sc_path_info), "tool")
	EntrancePaths[entranceId] = Paths
	return { id = entranceId, Paths = Paths, }
end)

NW.regist("WORLD_MAP.SC.SELECT_MOVE_TOOL", NW.common_op_ret)

NW.regist("WORLD_MAP.SC.WORLD_ARRIVE", function (nm)
	local ret, err = NW.chk_op_ret(nm:readU32())
	if err == nil then
		local World = DY_DATA.World
		-- 抵达新入口时，清空缓存路径信息
		World.EntrancePaths = nil

		World.Travel.lastTool = World.Travel.tool
		World.Travel.Points = nil
		World.Vehicle = sc_chk_vehicle_info(nm)
		return World
	end
end)

--同步入口的天气
NW.regist("WORLD_MAP.SC.WORLD_WEATHER", function (nm)
	local World = DY_DATA.World
	if World.AllWeather == nil then
		World.AllWeather = {}
	end
	local ls = nm:readArray({}, read_Weather)
	for _,v in pairs(ls) do
		World.AllWeather[v.entranceId] = v
	end
	return ls
end)

local function sc_home_info(nm)
	return {
		beingAttacked = nm:readU32() == 1,
		protectCool = nm:readU32(),
		revengeCool = nm:readU32(),
	}
end

NW.regist("HOME.SC.GET_HOME_INFO", function (nm)
	return sc_home_info(nm)
end)

function P.get_home_info()
	NW.send(NW.msg("HOME.CS.GET_HOME_INFO"))
end

function P.move_to_ent(toolId, entId)
	DY_DATA.World.Travel.dst = entId
	local nm = NW.msg("WORLD_MAP.CS.WORLD_MOVE")
	NW.send(nm:writeU32(toolId):writeU32(entId))
end

NW.WORLD = P
