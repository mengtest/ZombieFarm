--
-- @file    data/parser/maplib.lua
-- @anthor  xingweizhen (weizhen.xing@funplus.com)
-- @date    2017-12-19 15:06:20
-- @desc    描述
--

local text_obj = config("textlib").text_obj
local LENGTH_SCALE = _G.CVar.LENGTH_SCALE

local log = _G.newlog()
local DB = {}

local ResMap = table.tomap(dofile("config/map_resource"), "ID")
local DefMap = {}

local MAP_ENV = dofile("config/map_environment")
local MapEnvDB = {}
for _,v in ipairs(MAP_ENV) do
	MapEnvDB[v.ID] = {
		id = v.ID,
		dayVision = v.dayVision * LENGTH_SCALE,
		nightVision = v.nightVision * LENGTH_SCALE,
		fx = v.effect, fog = v.fog,
		weatherIcon = v.weatherIcon,
	}
end

local MAP_TMPL = dofile("config/map_maptemplate")
local TmplDB = {}
for _,v in ipairs(MAP_TMPL) do
	local Res = ResMap[v.ID] or DefMap
	local EnvWeights = {}
	for i,v in ipairs(v.environment:totablearray("|", ":", "id", "weight")) do
		local Env = MapEnvDB[v.id]
		if Env then
			table.insert(EnvWeights, { Env = Env, weight = v.weight, })
		end
	end
	local Tmpl = {
		tmpl = v.ID,
		res = v.resID,
		day = v.day,
		night = v.night,
		envDura = v.weatherChanges,
		EnvWeights = EnvWeights,
		path = Res.resPath,
	}
	Tmpl.__index = Tmpl
	TmplDB[v.ID] = Tmpl
end

local MAP_ENTRANCE_VEHICLE = dofile("config/mapgroup_entrancevehicleroute")
local EntVehicles = {}
for _,v in ipairs(MAP_ENTRANCE_VEHICLE) do
	EntVehicles[v.RouteID] = {
		model = v.model,
		Start = v.startPosition:totable(":", "x", "y"),
		height = v.height,
		earlyApearTime = v.bornTime,
	}
end

local MapEntranceRes = table.tomap(dofile("config/mapgroup_mapgroupresource"), "ID")
local DefEntranceRes = {}

-- 世界地图各个关卡入口
local MAP_ENTRANCE = dofile("config/mapgroup_mapgrouptemplate")
local Entrances = {}
for _,v in ipairs(MAP_ENTRANCE) do
	local Res = MapEntranceRes[v.ID]
	if Res == nil then
		Res = DefEntranceRes
		log("地图入口#%d缺少资源配置", v.ID)
	end

	Entrances[v.ID] = {
		id = v.ID, mapId = v.mapID, mType = v.type,
		reqLevel = v.level, enterLevel = v.enterLevel,
		Coord = v.coordinates:totable(":", "x", "y"),

		label = Res.label, Cost = #v.enterPrice > 0 and v.enterPrice:totable(":", "id", "amount") or nil,
		peaceType = Res.peaceType,
		model = Res.model, picture = Res.picture, difficulty = Res.difficulty,
		threatLevel = Res.threatLevel, pvp = Res.PVP == 1,
		Loots = Res.infoLevel:splitn("|"),
		EarlyAppear = EntVehicles[v.RouteID],

		name = text_obj("mapgroup_mapgroupresource", "mapName", Res),
		--tips = text_obj("mapgroup_mapgroupresource", "mapTips", Res),
		desc = text_obj("mapgroup_mapgroupresource", "mapDescription", Res),
	}
end

local MAP_MAP = dofile("config/map_map")
for _,v in ipairs(MAP_MAP) do
	local Tmpl = TmplDB[v.tempID]
	if Tmpl == nil then
		log("[map#%d]引用了不存在的模板#%d", v.mapID, v.tempID)
	end
	local tb = { id = v.mapID, type = v.type, fow = v.Fog ~= 0, }
	tb.inviteButtonDisplay = v.inviteButtonDisplay
	DB[v.mapID] = setmetatable(tb, Tmpl)
end


log()

local P = {
	Entrances = Entrances,
}
function P.get_dat(dat)
	-- 大于2^31表示这是个玩家的数据
	return dat < 2147483648 and DB[dat] or DB[CVar.HOME_ID]
end
function P.get_ent(dat) return Entrances[dat] end

--获取天气信息
function P.get_env(dat) return MapEnvDB[dat] end

return P
