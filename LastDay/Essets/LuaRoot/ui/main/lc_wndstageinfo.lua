--
-- @file    ui/main/lc_wndstageinfo.lua
-- @author  xingweizhen
-- @date    2018-04-06 17:30:40
-- @desc    WNDStageInfo
--

local self = ui.new()
setfenv(1, self)

local function get_curr_stage()
	local Entrance = Context.Entrance
	if Entrance.Stages then
		return Entrance.Stages and Entrance.Stages[1]
	end
end

local function get_curr_room(mapId)
	if mapId == nil then
		local Stage = get_curr_stage()
		mapId = Stage and Stage.mapId or nil
	end

	if mapId then
		-- 大于2^31表示是玩家营地地图
		if mapId > 2147483648 then mapId = CVar.HOME_ID end

		local RoomList = rawget(DY_DATA, "RoomList")
		if RoomList then
			for _,v in ipairs(RoomList) do
				if v.status ~= "Closed" and v.mapId == mapId then return v end
			end
		end
	end
end

local function rfsh_traveling_weather_panel()
	local SubMain = Ref.SubMain
	local SubProfile = SubMain.SubProfile

	local dst = Context.Entrance.id
	local AllWeather = DY_DATA.World.AllWeather
	local WeatherInfo = AllWeather and AllWeather[dst]
	if WeatherInfo == nil then
		libunity.LogE("天气信息为空。地图id:{0}", dst)
		return
	end
	local MapLib = config("maplib")
	local WeatherConfig = MapLib.get_env(WeatherInfo.weather)

	local temperature = WeatherInfo.temperature and WeatherInfo.temperature or 0
	local weatherIcon = WeatherConfig and ("MOW/"..WeatherConfig.weatherIcon)
	SubProfile.lbWeather.text = string.format(TEXT.fmtWeather, temperature)
	SubProfile.spWeather:SetSprite(weatherIcon)
end

local function rfsh_explore(Stage, traveling)
	local SubExplore = Ref.SubMain.SubExplore
	SubExplore.btnExplore.interactable = not traveling

	local SubFindNew = SubExplore.SubFindNew
	local Entrance = Context.Entrance
	local maxNewTeam = Entrance.maxNewTeam
	local canFindNew =  maxNewTeam and maxNewTeam ~= 0
	libunity.SetActive(SubFindNew.go, canFindNew)
	if canFindNew then
		SubFindNew.btn.interactable = not traveling

		libunity.SetActive(GO(SubFindNew.go, "Cost="), canFindNew)
		if maxNewTeam > 0 then
			SubFindNew.lbLimit.text = string.format("%d(%d/%d)",
				Entrance.NewTeamCosts.energy, maxNewTeam - Entrance.nNewTeam, maxNewTeam)
		else
			SubFindNew.lbLimit.text = nil
		end
	end
end

local function rfsh_multi_play(Stage, traveling)
	local SubMulti = Ref.SubMain.SubMulti
	SubMulti.SubCreate.btn.interactable = not traveling
	SubMulti.SubMatch.btn.interactable = not traveling

	local Entrance = Context.Entrance
	local Room = get_curr_room()
	local hasRoom = Room and (Room.status == "InBattle")

	local CurrTeam = rawget(DY_DATA, "Team")
	local hasTeam = CurrTeam and CurrTeam.entId == Entrance.id
	local isCampBattle = Stage.mode == "CampAttack" or Stage.mode == "CampRevenge"
	local allowMatch = Entrance.maxMatchTeam ~= 0

	libunity.SetActive(SubMulti.SubMatch.go, allowMatch and not hasTeam and not isCampBattle)
	libunity.SetActive(SubMulti.SubMatch.spWait, false)
end

local function rfsh_vehicles(traveling)
	local Paths = Context.Paths
	local SubVehicles = Ref.SubMain.SubVehicles
	local GrpVehicles = SubVehicles.GrpVehicles
	GrpVehicles:hide()

	if Paths and next(Paths) then
		local function show_vehicle_view(i, Path, text, Icon)
			local Ent = GrpVehicles:gen(i)
			Ent.lbOper.text = text
			Ent.btn.interactable = not traveling

			-- local SubFuel = Ent.SubTravel.SubFuel
			-- SubFuel.spVehicle:SetSprite(Icon.icon)
			-- libugui.SetColor(SubFuel.barFuel.fillRect, Icon.color)

			local showCost = Path and Path.cost > 0
			libunity.SetActive(Ent.SubCost.go, showCost)
			if showCost then
				Ent.SubCost.spIcon:SetSprite(Icon.costIco)
				Ent.SubCost.lbAmount.text = Path.cost
			end
			Ent.lbTime.text = Path and os.secs2time(nil, Path.dura) or "??:??:??"
		end

		local SupportVehicles = Context.Entrance.SupportVehicles or { 1 }
		-- 携带的交通工具
		local Vehicle = DY_DATA.World.Vehicle
		local vehicleId = Vehicle and Vehicle.id or 0
		local canDrive, canWalk, reqiueVehicle
		for _,v in ipairs(SupportVehicles) do
			if v == 1 then
				canWalk = true
			else
				if reqiueVehicle == nil then
					reqiueVehicle = v
				end

				if v == vehicleId then
					canDrive = true
				end
			end
		end

		local MapTravelTool = TEXT.MapTravelTool
		local TravelTool, TravelICON = CVar.TravelTool, CVar.TravelICON
		if canDrive then
			show_vehicle_view(1, Paths[vehicleId], MapTravelTool.drive, TravelICON.Drive[vehicleId])
		end

		if canWalk then
			local RushPath = Paths[TravelTool.rush]
			show_vehicle_view(2, RushPath, MapTravelTool.rush, TravelICON.Rush)
			if RushPath.cost > 0 then
				show_vehicle_view(3, Paths[TravelTool.walk], MapTravelTool.walk, TravelICON.Walk)
			end
		end

		local warningTxt
		if not canDrive and not canWalk then
			if reqiueVehicle then
				-- 需要某种载具
				warningTxt = string.format(TEXT.fmtRequireVehicle, tostring(reqiueVehicle))
			end
		end

		libunity.SetActive(SubVehicles.SubWarning.go, warningTxt)
		if warningTxt then
			SubVehicles.SubWarning.lbWarning.text = warningTxt
		end
	else
		-- 无移动路径
		libunity.SetActive(SubVehicles.SubWarning.go, true)
		SubVehicles.SubWarning.lbWarning.text = TEXT.tipEntranceUnreachable
	end
end

local function rfsh_stage_oper()
	local Entrance = Context.Entrance
	local SubMain = Ref.SubMain
	local SubProfile = SubMain.SubProfile
	local SubExplore = SubMain.SubExplore
	local SubVehicles = SubMain.SubVehicles
	local SubMulti = SubMain.SubMulti

	--local EntData = config("maplib").get_ent(Entrance.reqLevel)
	if DY_DATA:get_player().level < Entrance.reqLevel then
		libunity.SetActive(SubMain.btnEnter, false)
		libunity.SetActive(SubExplore.go, false)
		libunity.SetActive(SubVehicles.go, false)
		libunity.SetActive(SubMulti.go, false)
		libunity.SetActive(SubMain.SubLock.go, true)
		SubMain.SubLock.lbLevel.text = TEXT.fmtLevel:csfmt(Entrance.reqLevel)
		return
	else
		libunity.SetActive(SubMain.SubLock.go, false)
	end

	local Travel = DY_DATA.World.Travel
	local traveling = Travel.dst > 0
	local arrived = Travel.src == Entrance.id

	libunity.SetActive(SubVehicles.go, not arrived)

	local maxMatchTeam = Entrance.maxMatchTeam or -1
	local nMatchTeam = Entrance.nMatchTeam or 0
	if maxMatchTeam <= 0 or not arrived then
		SubProfile.lbResidues.text = nil
	else
		rfsh_traveling_weather_panel()
		SubProfile.lbResidues.text = TEXT.fmtResiduesCnt:csfmt((maxMatchTeam - nMatchTeam), maxMatchTeam)
	end

	if arrived then
		local Stage = get_curr_stage()
		local ishome = Entrance.id == CVar.HOME_ID
		local isTeamStage = Stage and Stage.global and Stage.mode ~= "Single"

		libunity.SetActive(SubMain.btnEnter, ishome)
		libunity.SetActive(SubExplore.go, not ishome and not isTeamStage)
		libunity.SetActive(SubMulti.go, not ishome and isTeamStage)

		if ishome then return end

		if isTeamStage then
			rfsh_multi_play(Stage, traveling)
		else
			rfsh_explore(Stage, traveling)
		end
	else
		libunity.SetActive(SubMain.btnEnter, false)
		libunity.SetActive(SubExplore.go, false)
		libunity.SetActive(SubMulti.go, false)

		rfsh_vehicles(traveling)
	end
end

local function rfsh_entrance_view()
	local Entrance = Context.Entrance
	local EntData = config("maplib").get_ent(Entrance.id)
	local SubMain = Ref.SubMain
	local SubProfile = SubMain.SubProfile
	SubMain.lbName.text = #Entrance.name > 0 and cfgname(Entrance) or cfgname(EntData)
	SubProfile.lbDesc.text = "<space=5em>" .. (EntData.desc or "")
	SubProfile.spPic:SetTexture("")
	SubProfile.spPic:SetTexture(string.format("rawtex/%s/%s", EntData.picture, EntData.picture))
	rfsh_traveling_weather_panel()

	local Stage = Entrance.Stages[1]

	local SubBrief = SubMain.SubBrief
	SubBrief.lbPvp.text = EntData.pvp and TEXT.allow or TEXT.forbid
	SubBrief.lbTeam.text = Stage.maxPlayerCount > 1 and TEXT.yes or TEXT.no
	libugui.SetAnchoredSize(SubBrief.spThreat, 34 * EntData.threatLevel, nil)

	libunity.SetActive(SubBrief.SubCond.go, EntData.Cost)

	local hasCost = EntData.Cost ~= nil
	local SubMulti = SubMain.SubMulti
	libunity.SetActive(SubMulti.SubCreate.spIcon, hasCost)
	libunity.SetActive(SubMulti.SubMatch.spIcon, hasCost)
	if hasCost then
		local Cost = ItemDEF.gen(EntData.Cost)
		local costIcon = Cost:get_base_data().icon
		ui.seticon(SubBrief.SubCond.spCond, costIcon)

		ui.seticon(SubMulti.SubCreate.spIcon, costIcon)
		SubMulti.SubCreate.lbAmount.text = ""

		ui.seticon(SubMulti.SubMatch.spIcon, costIcon)
		SubMulti.SubMatch.lbAmount.text = ""
	end

	local Loots = EntData.Loots
	Ref.SubMain.SubReward.GrpReward:dup(#Loots, function (i, Ent, isNew)
		ItemDEF.new(Loots[i]):show_view(Ent)
	end)

	rfsh_stage_oper()
end

local function open_team_create(Room)
	self:close()
	ui.open("UI/WNDCreateTeam", nil, Room)
end

local function open_team_list()
	self:close()
	ui.open("UI/WNDTeamList", nil, {
		Entrance = Context.Entrance,
		Stage = get_curr_stage(),
	})
end

local function show_matching_status(Matching)
	local SubMatch = Ref.SubMain.SubMulti.SubMatch
	SubMatch.lbOper.text = Matching and TEXT["team.unmatch"] or TEXT["team.match"]
	libunity.SetActive(SubMatch.spWait, Matching)
	if Matching then
		_G.PKG["ui/util"].start_time_counting(SubMatch.spWait, SubMatch.lbWaitTime, 0, 1)
	else
		libunity.CancelInvoke(SubMatch.spWait)
	end
end

local function cancel_alone_apply()
	if DY_DATA.World.Matching then
		NW.MULTI.cancel_alone_apply(Context.Entrance.id)
		show_matching_status()
	end
end

--!* [开始] 自动生成函数 *--

function on_submain_subbrief_subcond_click(evt, data)
	local Cost = config("maplib").get_ent(Context.Entrance.id).Cost
	ItemDEF.gen(Cost):show_tip(evt)
end

function on_submain_subbrief_subcond_deselect(evt, data)
	ItemDEF.hide_tip()
end

function on_submain_subreward_grpreward_entreward_click(evt, data)
	local Loots = config("maplib").get_ent(Context.Entrance.id).Loots
	local lootId = Loots[ui.index(evt)]
	if lootId then ItemDEF.new(lootId):show_tip(evt) end
end

function on_submain_subreward_grpreward_entreward_deselect(evt, data)
	ItemDEF.hide_tip()
end

function on_enter_stage(btn)
	local Entrance = Context.Entrance
	if Entrance.Stages then
		DY_DATA.World:try_entrance(Entrance, function ()
			DY_DATA.World:enter_stage()
		end)
	else
		-- 本地操作
		local Stage = DY_DATA:get_stage()
		CTRL.init(Stage)
        SCENE.load_stage(Stage.Base)
	end
end

function on_submain_subvehicles_grpvehicles_entvehicle_click(btn)
	local Entrance = Context.Entrance
	local index = ui.index(btn)

	local travelTool = -1

	if index == 1 then
		-- 使用交通工具
		travelTool = DY_DATA.World.Vehicle.id
	elseif index == 2 then
		-- 急行
		travelTool = CVar.TravelTool.rush
	elseif index == 3 then
		-- 走~
		travelTool = CVar.TravelTool.walk
	else
		libunity.LogE("未知移动方式#{0}", index)
		return
	end

	if DY_DATA.World:check_energy_enough(Entrance, travelTool) then
		DY_DATA.World:try_entrance(Entrance, function ()
			NW.WORLD.move_to_ent(travelTool, Entrance.id)
		end)
	end
end

function on_submain_subexplore_subfindnew_click(btn)

end

function on_submain_submulti_subcreate_click(btn)
	if DY_DATA.World:check_passcard_enough() then
		if rawget(DY_DATA, "Team") then
			open_team_create()
		else
			cancel_alone_apply()
			NW.TEAM.create(Context.Entrance, get_curr_stage())
		end
	end
end

function on_submain_submulti_submatch_click(btn)
	if DY_DATA.World:check_passcard_enough() then
		if DY_DATA.World.Matching then
			cancel_alone_apply()
		else
			NW.alone_apply_map(Context.Entrance)
		end
	end
end
--!* [结束] 自动生成函数  *--

function init_view()
	ui.group(Ref.SubMain.SubReward.GrpReward)
	ui.group(Ref.SubMain.SubVehicles.GrpVehicles)
	--!* [结束] 自动生成代码 *--

	self.ItemDEF = _G.DEF.Item

	_G.PKG["ui/util"].flex_itemgrp(Ref.SubMain.SubReward.GrpReward)
	Ref.SubMain.SubVehicles.GrpVehicles:dup(3)
end

function init_logic()
	rfsh_entrance_view()
	NW.request_get_entrance_weather(Context.Entrance.id)

	show_matching_status(DY_DATA.World.Matching)
end

function show_view()

end

function on_recycle()
	cancel_alone_apply()
end

Handlers = {
	["WORLD_MAP.SC.WORLD_MOVE"] = function (World)
		if World then self:close() end
	end,

	["MULTI_MAP.SC.APPLY_ROOM"] = function (Ret)
		if Ret.err == nil then
			NW.apply_global_map(Ret.Room)
		end
	end,

	["TEAM.SC.SYNC_TEAM_INFO"] = function (Team)
		self.aloneApply = nil
		if Team and Team.status ~= "Fighting" then
			if Context.Entrance.id == Team.entId then
				open_team_create()
			end
		end
	end,

	["MULTI_MAP.SC.SYNC_ROOM_INFO"] = function (RoomList)
		local Stage = get_curr_stage()
		if Stage.mode == "CampAttack" or Stage.mode == "CampRevenge" then
			local Room = get_curr_room(Stage.mapId)
			if Room and Room.status == "InBattle" then
				NW.MULTI.get_room_token(Room.id)
			end
		end
	end,

	["MULTI_MAP.SC.SYNC_BEGIN_MATCH"] = show_matching_status,

	["WORLD_MAP.SC.WORLD_WEATHER"] = function(modifyWeatherList)
		rfsh_traveling_weather_panel()
	end,
}

return self

