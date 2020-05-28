--
-- @file    ui/main/lc_hudworld.lua
-- @author  xingweizhen
-- @date    2018-09-19 21:56:14
-- @desc    HUDWorld
--

local self = ui.new()
local _ENV = self

local min = UE.Vector2(-5, -4)
local max = UE.Vector2(6, 6)

local function processing_camera_position(x, y, z)
	if x < min.x then x = min.x end
	if z < min.y then z = min.y end
	if x > max.x then x = max.x end
	if z > max.y then z = max.y end

	return x, y, z
end

local function calc_energy_cost(time)
	local rate = CVar.GAME.PlayerRunningTime / CVar.GAME.PlayerWalkingTime
	local cost = (time * 1000) * rate / CVar.GAME.PlayerRunningTimeRate
	return math.ceil(cost)
end

--删除地图上的入口
local function destroy_world_ent(entrance)
	entrance.hide = true
	local srcIndex, _ = DY_DATA.World:find_entrance(entrance.id)
	libunity.Destroy("/WORLD/ent".. srcIndex)

	local Ent = Ref.GrpHuds:find(srcIndex)
	if Ent then
		libunity.SetActive(Ent.go, false)
	end
end

local function update_alone_line_path(Points, go, EntData, lbTime)
	local length, p = 0
	for _,v in ipairs(Points) do
		if p then
			length = length + (v - p).magnitude
		end
		p = v
	end

	local tm = _G.DY_TIMER.get_timer("StageClose#"..EntData.id)
	if tm == nil or tm.paused then return end

	local leftTime, totalTime = tm.count, tm.cycle
	local appearTime = EntData.EarlyAppear.earlyApearTime
	local height = EntData.EarlyAppear.height

	local time = totalTime - leftTime
	local step = length / totalTime

	local Vector3 = UE.Vector3
	local UE_Time = UE.Time
	local startTime = UE_Time.realtimeSinceStartup - time

	libunity.SetActive(go, time + appearTime > totalTime)

	while time < totalTime do
		if lbTime then
			lbTime.text = os.secs2time(nil, math.floor(totalTime - time) + 1)
		end

		local range = step * time
		local p
		for i,v in ipairs(Points) do
			if p then
				local direction = v - p
				local d = direction.magnitude
				if d <= range then
					range = range - d
				else
					if time + appearTime > totalTime then
						libunity.SetActive(go, true)
						local forward = direction.normalized
						local point = p + forward * range
						point.y = point.y + height
						go.transform.position = point
						go.transform.forward = Vector3.RotateTowards(go.transform.forward, forward, UE_Time.deltaTime, 0.1)
					end
					break
				end
			end
			p = v
		end
		coroutine.yield()
		time = UE_Time.realtimeSinceStartup - startTime
	end

	totalTime = UE_Time.realtimeSinceStartup + 3
	while UE_Time.realtimeSinceStartup < totalTime do
		coroutine.yield()
		go.transform:Translate(0, 0, 0.01)
	end

	libunity.Recycle(go)
end

local function update_tranvel(Points)
	local length, p = 0
	for _,v in ipairs(Points) do
		if p then
			length = length + (v - p).magnitude
		end
		p = v
	end

	local lbCountdown = Ref.SubTravel.lbCountdown
	local Travel = DY_DATA.World.Travel
	local leftTime, totalTime = Travel.leftTime, Travel.totalTime
	local time = totalTime - leftTime
	local step = length / totalTime

	local UE_Time = UE.Time
	local startTime = UE_Time.realtimeSinceStartup - time

	local trans = Ref.SubTravel.spVehicle.transform

	while time < totalTime do
		lbCountdown.text = os.secs2time(nil, math.floor(totalTime - time) + 1)
		local range = step * time
		local p
		for i,v in ipairs(Points) do
			if p then
				local direction = v - p
				local d = direction.magnitude
				if d <= range then
					range = range - d
				else
					local point = p + direction.normalized * range
					libugui.Overlay(Ref.SubTravel.go, point)
					local bRotRevert = direction.normalized.x > 0

					local euler = trans.localEulerAngles
					euler.y = bRotRevert and -180 or 0
					trans.localEulerAngles = euler
					break
				end
			end
			p = v
		end
		coroutine.yield()
		time = UE_Time.realtimeSinceStartup - startTime
		Travel.leftTime = Travel.totalTime - time
	end

	lbCountdown.text = os.secs2time(nil, 0)

	--如果玩家之前的位置在已经关闭的事件地图入口上，则销毁该地点
	local SrcEntrance = table.match(DY_DATA.World.Entrances, { id = Travel.src })
	if SrcEntrance.dura == 0 then
		destroy_world_ent(SrcEntrance)
	end

	Travel.src = Travel.dst
	Travel.dst = 0

	if NW.connected() then
		NW.send(NW.msg("WORLD_MAP.CS.WORLD_ARRIVE"):writeU32(Travel.src))
	else
		NW.broadcast("WORLD_MAP.SC.WORLD_ARRIVE", DY_DATA.World)
	end
end

local function gen_path_points(Points)
	local Vector3 = UE.Vector3
	local x, _, z = libunity.GetPos("/WORLD")

	local length = 0
	local NewPoints, p1 = {}
	for _,v in ipairs(Points) do
		local p2 = Vector3(v.x + x, -0.28, v.y + z)
		table.insert(NewPoints, p2)

		if p1 then length = length + (p2 - p1).magnitude end
		p1 = p2
	end
	return NewPoints
end

local function draw_path_line(name, Points, time)
	return libugui.DrawLine3D(name, Points, time, {
		width = 30, color = "#FFFFFF",
		lineType = "Continuous", joins = "Weld",
		textureScale = 1,
		matLib = "Game/SharedObjs", matName = "PathLine",
		make = "spline", nPoint = #Points * 5,

		camera = "/WORLD/LineCamera",
	})
end

local function show_download_progress(progress)
	local operTxt = TEXT.downloading
	local progTxt = string.format("%d%%", math.floor(progress * 100))
	for i,v in Ref.GrpHuds:pairs(true) do
		local SubDL = v.SubDL
		if libunity.IsActive(SubDL.go) then
			SubDL.spFill.fillAmount = progress
			SubDL.lbOper.text = operTxt
			SubDL.lbProgress.text = progTxt
		end
	end
end

local function show_unpack_progress(progress)
	local operTxt = TEXT.unpacking
	local progTxt = string.format("%d%%", math.floor(progress * 100))
	for i,v in Ref.GrpHuds:pairs(true) do
		local SubDL = v.SubDL
		if libunity.IsActive(SubDL.go) then
			SubDL.spFill.fillAmount = progress
			if progress < 1 then
				SubDL.lbOper.text = operTxt
				SubDL.lbProgress.text = progTxt
			else
				libunity.SetActive(v.spLay, true)
				libunity.SetActive(SubDL.go, false)
			end
		end
	end
end

local function rfsh_travel_state(World)
	--rfsh_vehicle_info(World.Vehicle)

	local SubTravel = Ref.SubTravel
	SubTravel.go:SetActive(false)
	libunity.SetActive(Ref.btnReturn, false)
	libunity.SetActive(Ref.btnFasten, false)

	libugui.DestroyLine("TRAVEL")

	local Travel = World.Travel
	local srcIndex, Entrance = DY_DATA.World:find_entrance(Travel.src)
	if srcIndex == nil then
		libunity.LogE("srcIndex is nil.src:{0}", Travel.src)
	end

	local traveling = Travel.dst > 0

	--rfsh_traveling_weather_panel(traveling)
	libunity.SetActive(Ref.SubEnter.go, not traveling)
	local walkTool = CVar.TravelTool.walk
	if traveling then
		local _, Points = draw_path_line("TRAVEL", gen_path_points(Travel.Points), Travel.leftTime)
		if Travel.tool == walkTool then
			libunity.SetActive(Ref.btnReturn, true)
			libugui.Follow(Ref.btnReturn, string.format("/WORLD/ent%d/BTM", srcIndex), self.camera)

			local dstIndex = DY_DATA.World:find_entrance(Travel.dst)
			libunity.SetActive(Ref.btnFasten, true)
			libugui.Follow(Ref.btnFasten, string.format("/WORLD/ent%d/BTM", dstIndex), self.camera)
		end

		SubTravel.go:SetActive(true)
		local TravelIcon = CVar.get_travel_icon(Travel.tool)
		SubTravel.spVehicle:SetSprite(TravelIcon.icon)
		libugui.SetColor(SubTravel.barFuel.fillRect, TravelIcon.color)

		libunity.StopAllCoroutine(Ref.go)
		libunity.StartCoroutine(Ref.go, update_tranvel, Points)
	else
		local TravelIcon = CVar.get_travel_icon(Travel.lastTool or walkTool)
		Ref.SubEnter.spVehicle:SetSprite(TravelIcon.icon)
		Ref.SubEnter.spLay.color = TravelIcon.color
		libugui.Follow(Ref.SubEnter.go, "/WORLD/ent".. srcIndex, self.camera)

		local Stage = Entrance.Stages[1]
		local allowMatch = Entrance.maxMatchTeam ~= 0
		local isTeamStage = Stage and Stage.global and Stage.mode ~= "Single"
		Ref.SubEnter.SubOper.lbOper.text = isTeamStage and TEXT["team.match"] or TEXT.Enter
		libunity.SetActive(Ref.SubEnter.SubOper.go, not isTeamStage or (allowMatch and rawget(DY_DATA, "Team") == nil))
	end
end

local function show_early_appear(goWorldEnt, EntData, time)
	local EarlyAppear = EntData.EarlyAppear
	local Start = EarlyAppear.Start

	local lineName = "Incomming#" .. EntData.id
	libugui.DestroyLine(lineName)
	local Points = {  UE.Vector2(Start.x, Start.y), EntData.Coord, }
	_, Points = draw_path_line(lineName, gen_path_points(Points), time)

	local comerPath = string.format("entmodel/%s/%s", EarlyAppear.model, EarlyAppear.model)
	libasset.LoadAsync(typeof(UE.GameObject), comerPath, "Cache", function (a, o, p)
		libunity.Recycle(GO(p, "Comer"))
		plane = libunity.AddChild(p, o, "Comer")
		libunity.StartCoroutine(plane, update_alone_line_path, Points, plane, EntData)
	end, goWorldEnt)
end

local function rfsh_world_info_delay()
	local World = DY_DATA.World

	local MapLIB = config("maplib")
	local srcEnt = World.Travel.src
	local Entrances = World.Entrances
	local goType = typeof(UE.GameObject)
	local GrpHuds = Ref.GrpHuds

	local Travel = DY_DATA.World.Travel
	local notTraveling = Travel.dst == 0

	GrpHuds:hide()

	local Frm = ui.find("FRMWorld")

	for i,v in ipairs(Entrances) do
		if v.hide then
			GrpHuds:set_active(i, false)
		else
			local EntData = MapLIB.get_ent(v.id)
			if EntData then
				local label = EntData.label
				local peaceType = EntData.peaceType

				local Ent = GrpHuds:get(i)
				if Ent == nil then
					Ent = GrpHuds:gen(i)
				else
					libunity.SetActive(Ent.go, true)
				end

				local goWorldEnt = Frm.index2ent(i)
				libugui.Follow(Ent.go, GO(goWorldEnt, "HUD"), self.camera)
				Ent.spLay.spriteName = peaceType
				Ent.spIcon.spriteName = label
				Ent.spLay:SetNativeSize()
				Ent.spIcon:SetNativeSize()
				Ent.SubCloseTime.lbCloseTimeStage.text = v.entranceState == 1 and TEXT.StageCloseTime or TEXT.StageOpenTime
				libunity.SetActive(Ent.SubCloseTime.go, false)

				local hasBundle = World:has_bundle(v)
				libunity.SetActive(Ent.SubDL.go, not hasBundle)
				libunity.SetActive(Ent.spLay, hasBundle)

				_G.DY_TIMER.unsubscribe(Ent.go)
				local tm = _G.DY_TIMER.get_timer("StageClose#"..v.id)
				if tm and not tm.paused then
					tm:subscribe_counting(Ent.go, function(tm)
						if tm.count == 0 then
							DY_TIMER.stop_timer("StageClose#"..v.id)

							libunity.SetActive(Ent.SubCloseTime.go, false)

							local GrpIndicator = ui.find("FRMWorld").Ref.GrpIndicator
							GrpIndicator:set_active(i, false)
							--libunity.SetActive(Ent.go, false)

							if v.entranceState == 1 then
								v.dura = 0
								notTraveling = DY_DATA.World.Travel.dst == 0

								--没有移动，并且不在该入口
								local notInPlace = notTraveling and DY_DATA.World.Travel.src ~= v.id
								--移动中，并且起点和结束点都不在入口
								local travelingNotInPlace = DY_DATA.World.Travel.src ~= v.id and DY_DATA.World.Travel.dst ~= v.id

								if notInPlace and travelingNotInPlace then
									destroy_world_ent(v)
								end
								return
							elseif v.entranceState == 2 then
								v.entranceState = 1
								v.dura = -1
								return
							end
						end
						libunity.SetActive(Ent.SubCloseTime.go, true)
						Ent.SubCloseTime.lbCloseTime.text = tm:to_time_string()
					end)

					-- 绘制到达线(即将开放)
					if v.entranceState == 3 and EntData.EarlyAppear then
						show_early_appear(goWorldEnt, EntData, tm.count)
					end
				end
			else
				libunity.LogE("EntData is nil.ID={0}", v.id)
			end
		end
	end

	local dl, upk = SCENE.get_progress()
	if dl then
		show_download_progress(dl)
	elseif upk then
		show_unpack_progress(upk)
	end
end

local function rfsh_world_info(World)
	next_action(Ref.go, rfsh_world_info_delay)
end

local function get_entrance_path(entId, tool)
	local EntrancePaths = DY_DATA.World.EntrancePaths
	if EntrancePaths then
		local Paths = EntrancePaths[entId]
		return Paths and Paths[tool]
	end
end

--!* [开始] 自动生成函数 *--

function on_evtdrag_ptrdown(evt, data)
	self.dragFlag = nil
end

function on_evtdrag_begindrag(evt, data)
	self.dragFlag = true
end

function on_evtdrag_drag(evt, data)
	local delta = data.delta * 0.01
	local x, y, z = libunity.GetPos("/WORLD/View")
	x = x - delta.x; z = z - delta.y
	x, y, z = processing_camera_position(x, y, z)
	libunity.SetPos("/WORLD/View", x, y, z)
end

function on_evtdrag_click(evt, data)
	if dragFlag then return end

	local _, go = libunity.Raycast(nil, data.position, 100, 1024)
	if go then
		local Entrance = DY_DATA.World.Entrances[ui.index(go)]
		if Entrance then
			DY_DATA.World:open_stage_info(Entrance)
		end
	end
end

function on_btnreturn_click(btn)
	local Path = get_entrance_path(DY_DATA.World.Travel.dst, CVar.TravelTool.rush)
	local cost = Path and Path.cost or 0

	if cost > 0 then
		local usedTime = DY_DATA.World.Travel.totalTime - DY_DATA.World.Travel.leftTime
		cost = calc_energy_cost(usedTime)
		UI.MBox.consume(_G.DEF.Item.new(1, cost), "Return2Start", function ()
			local nm = NW.msg("WORLD_MAP.CS.WORLD_MOVE")
			NW.send(nm:writeU32(CVar.TravelTool.back):writeU32(DY_DATA.World.Travel.src))
		end)
		return
	end

	local nm = NW.msg("WORLD_MAP.CS.WORLD_MOVE")
	NW.send(nm:writeU32(CVar.TravelTool.back):writeU32(DY_DATA.World.Travel.src))
end

function on_btnfasten_click(btn)
	local Path = get_entrance_path(DY_DATA.World.Travel.dst, CVar.TravelTool.rush)
	local cost = Path and Path.cost or 0

	if cost > 0 then
		cost = calc_energy_cost(DY_DATA.World.Travel.leftTime)
		UI.MBox.consume(_G.DEF.Item.new(1, cost), "Rush2Finish", function ()
			local nm = NW.msg("WORLD_MAP.CS.WORLD_MOVE")
			NW.send(nm:writeU32(CVar.TravelTool.rush):writeU32(DY_DATA.World.Travel.dst))
		end)
		return
	end

	local nm = NW.msg("WORLD_MAP.CS.WORLD_MOVE")
	NW.send(nm:writeU32(CVar.TravelTool.rush):writeU32(DY_DATA.World.Travel.dst))
end

function on_subenter_suboper_click(btn)
	if NW.connected() then
		if DY_DATA.World:check_passcard_enough() then
			DY_DATA.World:try_entrance(nil, function ()
				DY_DATA.World:enter_stage()
			end)
		end
	else
		-- 本地操作
		local Stage = DY_DATA:get_stage()
		CTRL.init(Stage)
        SCENE.load_stage(Stage.Base)
    end
end
--!* [结束] 自动生成函数  *--

function init_view()
	ui.group(Ref.GrpHuds)
	--!* [结束] 自动生成代码 *--

	local root = UE.GameObject.FindGameObjectWithTag("MainCamera")
	self.camera = root:GetComponent("Camera")
end

function init_logic()
	libunity.SetParent(Ref.go, self.camera, false)
	local canvas = Ref.go:GetComponent("Canvas")
	canvas.worldCamera = self.camera

	-- libugui.SetAnchoredPos(Ref.go, 0, 0, 6)
	-- libunity.SetScale(Ref.go, 0.004307365, 0.004307365, 0.004307365)

	local World = rawget(DY_DATA, "World")
	if World and World.Travel then
		rfsh_world_info(World)
		rfsh_travel_state(World)

		---NW.request_get_entrance_weather(World.Travel.dst)
		if World.Travel.dst > 0 then
			NW.send(NW.msg("WORLD_MAP.CS.GET_TARGET_PATH_INFO"):writeU32(World.Travel.dst))
		end
	else
		libugui.SetVisible(Ref.go, false)
	end
end

function show_view()

end

function on_recycle()

end

Handlers = {
	["WORLD_MAP.SC.WORLD_INFO"] = function (Ret)
		if Ret.dirty then
			libugui.SetVisible(Ref.go, true)
			rfsh_world_info(Ret.World)
			rfsh_travel_state(Ret.World)
		end
	end,

	["WORLD_MAP.SC.WORLD_MOVE"] = function (World)
		if World then
			rfsh_travel_state(World)
			local travel = World.Travel
			if travel then
				local params = { worldMove = travel.tool }
				libunity.PlayAudio("UI/UI_worldmove", nil, false, params)
			end
		end
	end,

	["WORLD_MAP.SC.WORLD_ARRIVE"] = function (World)
		rfsh_travel_state(World)
		--如果玩家之前的位置在已经关闭的事件地图入口上，则销毁该地点
		local SrcEntrance = table.match(DY_DATA.World.Entrances, { id = World.Travel.src })
		if SrcEntrance.dura == 0 then
			destroy_world_ent(SrcEntrance)
		end
	end,

	["WORLD_MAP.SC.GET_TARGET_PATH_INFO"] = function (Ret)
		local Travel = DY_DATA.World.Travel
		local dst = Travel and Travel.dst or 0
		local traveling = dst > 0

		if traveling then
			return
		end

		local Entrance = table.match(DY_DATA.World.Entrances, { id = Ret.id })
		if Entrance then
			if Entrance.entranceState == 1 or Entrance.entranceState == 3 then
				DY_DATA.World:show_stage_info(Entrance, Ret.Paths)
			elseif Entrance.entranceState == 2 then
				UI.Toast.norm(TEXT.EntranceNotOpen)
			end
		end
	end,

	["TEAM.SC.SYNC_TEAM_BASE"] = function (Team)
		if Team == nil then
			if DY_DATA.World.Travel.dst == 0 then
				local _, Entrance = DY_DATA.World:find_entrance()
				local Stage = Entrance.Stages[1]
				local allowMatch = Entrance.maxMatchTeam ~= 0
				local isTeamStage = Stage and Stage.global and Stage.mode ~= "Single"
				libunity.SetActive(Ref.SubEnter.SubOper.go, not isTeamStage or allowMatch)
			end
		end
	end,

	["TEAM.SC.SYNC_TEAM_INFO"] = function (Team)
		if Team then
			if DY_DATA.World.Travel.src == Team.entId then
				if Team.statusDirty and Team.status == "Fighting" then
					NW.apply_global_map(DY_DATA.Room)
				end
				libunity.SetActive(Ref.SubEnter.SubOper.go, false)
			return end
		end

		libunity.SetActive(Ref.SubEnter.SubOper.go, true)
	end,

	["MULTI_MAP.SC.SYNC_BEGIN_MATCH"] = function (Ret)
		if ui.find("WNDStageInfo") == nil and rawget(DY_DATA, "Team") == nil then
			DY_DATA.World:open_stage_info()
		end
	end,

	["CLIENT.SC.DOWNLOADING_ASSET"] = show_download_progress,
	["CLIENT.SC.UNPACKING_ASSET"] = show_unpack_progress,

	["WORLD_MAP.SC.STAGE_GROUP_INFO"] = function (alertEventArr)
		local World = rawget(DY_DATA, "World")
		rfsh_world_info(World)
	end,
}

return self

