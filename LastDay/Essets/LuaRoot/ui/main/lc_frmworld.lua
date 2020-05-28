--
-- @file    ui/main/lc_frmworld.lua
-- @author  xingweizhen
-- @date    2017-10-22 10:01:20
-- @desc    FRMWorld
--

local self = ui.new()
setfenv(1, self)

self.ChatPos = { ax = 1, ay = 0, ox = -190, oy = 14, ctrl = true }

local min = UE.Vector2(-5, -4)
local max = UE.Vector2(6, 6)

function set_visible(visible)
	libugui.SetVisible(Ref.go, visible)
	ui.setvisible("TaskAndTeam", visible)
end

local function on_energy_timer(Tm, updateBar)
	local SubEp = Ref.SubPlayer.SubEp

	if Tm and not Tm.paused then
		libunity.SetActive(SubEp.spCountdown, true)
		SubEp.lbCountdown.text = os.secs2time("%M:%S", Tm.count)
	else
		libunity.SetActive(SubEp.spCountdown, false)
	end

	if updateBar or Tm == nil or Tm.count == 0 then
		local Energy = DY_DATA:get_player().Assets[1]
		SubEp.bar.value = Energy.amount / Energy.limit
		SubEp.lbEp.text = string.format("%d/%d", Energy.amount, Energy.limit)
	end
end

local function rfsh_player_view()
	local Player = DY_DATA:get_player()
	local Sub = Ref.SubPlayer
	Sub.lbName.text = string.format("LV.%d %s", Player.level, Player.name)

	local Self = DY_DATA:get_self()
	local value, limit = Self.hp, Self.Attr.hp
	Sub.barHp.value = value and value / limit or 1
	Sub.lbHp.text = value and string.format("%d/%d", value, limit) or ""

	DY_DATA:get_self():show_view(Sub.SubHead)

	local Tm = _G.DY_TIMER.get_timer("Asset#"..1)
	if Tm and not Tm.paused then
		Tm:subscribe_counting(Ref.go, on_energy_timer)
	end
	on_energy_timer(Tm, true)
end

local function on_entmodel_loaded(a, o, p)
	if o == nil then return end
	libunity.NewChild(p.go, o)

	if p.id == 11002 then
		-- 检查关卡引导
		local GUIDE = _G.PKG["guide/api"]
		if  GUIDE.load(4) ~= 0 then
			libgame.AddChild(GO(p.go, p.modelName.."/FOCUS"), "uifx/FocusEnt/FocusEnt")
		end
	end
end

local function processing_camera_position(x, y, z)
	if x < min.x then x = min.x end
	if z < min.y then z = min.y end
	if x > max.x then x = max.x end
	if z > max.y then z = max.y end

	return x, y, z
end

local function rfsh_world_info(World)
	local MapLIB = config("maplib")
	local srcEnt = World.Travel.src
	local Entrances = World.Entrances
	local goType = typeof(UE.GameObject)
	local GrpIndicator = Ref.GrpIndicator

	local Travel = DY_DATA.World.Travel
	local notTraveling = Travel.dst == 0
	GrpIndicator:hide()

	for i,v in ipairs(Entrances) do
		if notTraveling and Travel.src ~= v.id and v.entranceState == 1 and v.dura == 0 then
			v.hide = true
		end

		if v.entranceState == 2 and v.dura == 0 then
			v.entranceState = 1
			v.dura = -1
		end

		local go = self.WorldEnts[i]

		local IndicatorEnt = GrpIndicator:get(i)
		if IndicatorEnt == nil then
			IndicatorEnt = GrpIndicator:gen(i)
		end

		if v.hide then
			libunity.SetActive(IndicatorEnt.go, false)
			if go then
				libunity.SetActive(go, false)
			end
		else
			local EntData = MapLIB.get_ent(v.id)
			libunity.SetActive(IndicatorEnt.go, true)

			if go == nil then
				go = libunity.NewChild("/WORLD", "game/WorldEnt", "ent"..i)
				ui.index(go, i)
				self.WorldEnts[i] = go
			end

			if EntData then
				if go.transform.childCount < 3 then
					local prefab = EntData.model
					local group = prefab:match("[^%d]+")
					local path = string.format("entmodel/%s/%s", group, prefab)
					libasset.LoadAsync(goType, path, "Default", on_entmodel_loaded, {
						go = go, id = v.id, modelName = prefab,})
				end
			else
				libunity.LogE("EntData is nil.ID={0}", v.id)
			end

			local Coord = v.Coord
			libunity.SetPos(go, Coord.x, 0, Coord.y)
			if v.id == srcEnt and not self.inited then
				align_view2ent(go, 0)
			end

			if EntData then
				local label = EntData.label
				local peaceType = EntData.peaceType

				IndicatorEnt.SubIndicator.spLay.spriteName = peaceType
				IndicatorEnt.SubIndicator.spIcon.spriteName = label
				IndicatorEnt.SubIndicator.spLay:SetNativeSize()
				IndicatorEnt.SubIndicator.spIcon:SetNativeSize()

				libugui.Indicate(IndicatorEnt.go, go)

				local tm = _G.DY_TIMER.get_timer("StageClose#"..v.id)
				if tm and not tm.paused then

				else
					local showIndicator = not v.hide
					if showIndicator then
						showIndicator = v.id == CVar.HOME_ID
					end
					libunity.SetActive(IndicatorEnt.go, showIndicator)
				end
			end
		end
	end

	if not self.inited then
		self.inited = true
		local Team = rawget(DY_DATA, "Team")
		if Team then
			if rawget(DY_DATA, "flagExitStage") then
				local _, Entrance = DY_DATA.World:find_entrance(srcEnt)
				if Team.entId == Entrance.id then
					ui.open("UI/WNDCreateTeam")
				end
			else
				local entIdx, _ = DY_DATA.World:find_entrance(Team.entId)
				align_view2ent(index2ent(entIdx))
			end
		end
	end
end

local function rfsh_vehicle_info(Vehicle)
	local SubVehicle = Ref.SubVehicle
	libunity.SetActive(SubVehicle.go, Vehicle ~= nil)
	if Vehicle then
		SubVehicle.barFuel.value = Vehicle.curFuel / Vehicle.maxFuel
		SubVehicle.barDura.value = Vehicle.curDura / Vehicle.maxDura
	end
end

local function rfsh_traveling_weather_panel(traveling)
	--libunity.SetActive(Ref.SubWeather.go, traveling)

	if traveling then
		local MapLib = config("maplib")
		local Travel = DY_DATA.World.Travel
		local AllWeather = DY_DATA.World.AllWeather
		local WeatherInfo = DY_DATA.World.AllWeather and DY_DATA.World.AllWeather[Travel.dst] or {}
		local WeatherConfig = MapLib.get_env(WeatherInfo.weather)

		local temperature = WeatherInfo.temperature and WeatherInfo.temperature or 0
		local weatherIcon = WeatherConfig and ("MOW/"..WeatherConfig.weatherIcon)
		Ref.SubWeather.lbWeather.text = string.format(TEXT.fmtWeather, temperature)
		Ref.SubWeather.spWeather:SetSprite(weatherIcon)

		--时间
		local tm = _G.DY_TIMER.get_timer("WorldTime")
		if tm and not tm.paused then
			tm:subscribe_counting(Ref.go, function(tm)
				local step = 24 / _G.CVar.TIME.DayTime
				local oneDaySeconds = _G.CVar.TIME.DayTime * 3600
				local second = 86400 - tm.count * step
				local offsetTime = (second / 3600) - 6
				offsetTime = (offsetTime < 0) and (offsetTime + 24) or offsetTime
				Ref.SubWeather.SubDN.bar.value = offsetTime / 24
			end)
		end
	end
end

local function on_battery_timer()
	local SubBattery = Ref.SubSys.SubBattery
	local batteryLevel = UE.SystemInfo.batteryLevel
	if batteryLevel < 0 then batteryLevel = 1 end
	SubBattery.bar.value = batteryLevel
	SubBattery.lbPercent.text = string.format("%d%%", math.floor(batteryLevel * 100 + 0.5))
	libugui.SetVisible(SubBattery.spCharge, UE.SystemInfo.batteryStatus.name == "Charging")
end

local function on_network_status()
	local SubSys = Ref.SubSys
	local status = UE.Application.internetReachability.name
	local Status2Name = {
		NotReachable = "",
		ReachableViaCarrierDataNetwork = "ico_main_030",
		ReachableViaLocalAreaNetwork = "ico_main_027",
	}
	SubSys.SubNet.spIcon.spriteName = Status2Name[status]
end

function align_view2ent(ent, duration)
	if duration == nil then duration = 1 end

	local x, y, z = libunity.GetPos(ent)
	x, y, z = processing_camera_position(x, y, z)
	if duration > 0 then
		libugui.DOTween("Position", "/WORLD/View", nil, UE.Vector3(x, y, z), {
				duration = duration, ease = "OutQuad",
			})
	else
		libunity.SetPos("/WORLD/View", x, y, z)
	end
end

function index2ent(index)
	return self.WorldEnts[index]
end

function open_stage_ent(ent)
	local Entrance = DY_DATA.World.Entrances[ui.index(ent)]
	DY_DATA.World:open_stage_info(Entrance)
end

local function show_buff_tip(Buff, Sub)
	local BuffBase = config("skilllib").get_buff(Buff.id)
	if BuffBase then
		Sub.lbName.text = BuffBase.name
		Sub.lbDesc.text = "<line-indent=10%>" .. BuffBase.desc
	else
		libunity.LogW("增益#{0}配置不存在", Buff.id)
	end
end

--!* [开始] 自动生成函数 *--

function on_grpindicator_entindicator_click(btn)
	local World = DY_DATA.World
	local GrpIndicator = Ref.GrpIndicator
	local index = GrpIndicator:getindex(btn)
	align_view2ent(index2ent(index), 0.25)
end

function on_subplayer_subsurvive_ptrdown(evt, data)
	local Buff = { id = CVar.SURVIVE_BUFF_ID }
	local Sub = ui.ref(ui.show("UI/TIPSurvive").go)
	show_buff_tip(Buff, Sub)

	local Self = DY_DATA:get_self()
	local totalSurviveTime = Self:calc_survive_time()
	Sub.lbDura.text = os.last2string(totalSurviveTime, 4, nil, 2)
	if Self.isSurviveTiming then
		libunity.InvokeRepeating(Sub.go, 1, 1, function ()
			totalSurviveTime = totalSurviveTime + 1
			Sub.lbDura.text = os.last2string(totalSurviveTime, 4, nil, 2)
		end)
	end

	local expRate = Self:calc_survive_exp(totalSurviveTime)
	Sub.lbReward.text = string.format("%.1f%%", expRate * 100)
end

function on_subplayer_subsurvive_ptrup(evt, data)
	ui.close("TIPSurvive")
end

function on_subplayer_subhead_click(btn)
	local UserCard = DY_DATA:get_usercard()
	ui.show("UI/MBPlayerInfoCard",0 , UserCard)
end

function on_subplayer_subep_btnadd_click(btn)
	local fmtOper = TEXT.AskConsumption.ResetEnergy.fmtOper
	local energyShopGoodsInfo = DY_DATA:get_shopgoods_info(
		CVar.SHOP_TYPE["VIRTUAL_SHOP"], CVar.VIRTUAL_GOODS["ENERGY"])

	local payCnt = energyShopGoodsInfo.nPayCnt + 1
	local payLimitCnt = energyShopGoodsInfo.nPayLimitCnt

	if payLimitCnt == 0 or payCnt <= payLimitCnt then
		local Cost = _G.DEF.Item.new(energyShopGoodsInfo.assetType, energyShopGoodsInfo.curPrice)
		UI.MBox.consume(Cost, "ResetEnergy", function ()
			NW.SHOP.RequestBuyGoods(
				CVar.SHOP_TYPE["VIRTUAL_SHOP"], CVar.VIRTUAL_GOODS["ENERGY"])
		end, { oper = string.format(fmtOper, CVar.SHOP.BuyEnergyValue), })
	else
		UI.Toast.norm(TEXT.PayEnergyCntUpperLimit)
	end
end

function on_subvehicle_click(btn)
	-- 打开载具界面
	NW.open_package(config("skilllib").OPEN_ID, DY_DATA.World.Vehicle.obj)
end

function on_btninvitations_click(btn)
	ui.open("UI/WNDInvitationList")
end
--!* [结束] 自动生成函数  *--

function init_view()
	ui.group(Ref.GrpIndicator)
	--!* [结束] 自动生成代码 *--

	--UE.Camera.main.depthTextureMode = 1
	self.WorldEnts = {}

	--DY_DATA.RedSystem:BuildRedDotUI(CVar.RedDotName.BuildNew,Ref.SubFuncs.btnBuild)

	DY_DATA.RedSystem:BuildRedDotUI(CVar.RedDotName.CraftNew,Ref.SubFuncs.btnCraft)

	DY_DATA.RedSystem:BuildRedDotUI(CVar.RedDotName.MailNew,GO(Ref.btnMail,"spPoint"))

	NW.MAIL.CheckHaveUnLookMail()
	
	DY_DATA:get_player():check_newcraft_state()
end

function init_logic()
	on_network_status()

	local Tm = DY_TIMER.get_timer("BATTERY")
	if Tm then Tm:subscribe_cycle(Ref.go, on_battery_timer) end
	on_battery_timer()

	rfsh_player_view()

	local World = rawget(DY_DATA, "World")
	if World and World.Travel then
		-- 检查关卡引导
		local GUIDE = _G.PKG["guide/api"]
		if  GUIDE.load(4) ~= 0 then GUIDE.launch("stage1st", 1, true) end
		rfsh_world_info(World)

		-- local width, height, _ = libunity.GetScale("/WORLD/Quad")
		-- local HomePos = CVar.WORLDMAP.HomePosition:totable(":", "x", "y")
		-- HomePos.x = HomePos.x - 1; HomePos.y = HomePos.y - 1
		-- libunity.SetPos("/WORLD/Quad", width / 2 - HomePos.x - 0.5, 0, height / 2 - HomePos.y - 0.5)

		NW.request_get_entrance_weather(World.Travel.dst)
	else
		libugui.SetVisible(Ref.go, false)
	end

	ui.show("UI/HUDWorld")
	ui.show("UI/TaskAndTeam")

	-- 存活Buff
	local SubSurvive = Ref.SubPlayer.SubSurvive
	local BuffBase = config("skilllib").get_buff(CVar.SURVIVE_BUFF_ID)
	ui.seticon(SubSurvive.spIcon, BuffBase.icon)
	local surviveTime = DY_DATA:get_self():calc_survive_time()
	local surviveRewardDura = surviveTime - tonumber(CVar.SURVIVE.SurviveTimeReward)
	if surviveRewardDura < 0 then
		libugui.SetVisible(SubSurvive.spLight, false)
		SubSurvive.spIcon.grayscale = true
		libunity.Invoke(Ref.go, -surviveRewardDura, function ()
			libugui.SetVisible(SubSurvive.spLight, true)
			SubSurvive.spIcon.grayscale = false
		end)
	else
		libugui.SetVisible(SubSurvive.spLight, true)
		SubSurvive.spIcon.grayscale = false
	end

	Ref.SubSys.lbLatency.text = DY_DATA:get_network_letency()
end

function show_view()

end

function on_recycle()
	--DY_DATA.RedSystem:UnbuildRedDotUI(CVar.RedDotName.BuildNew)
	DY_DATA.RedSystem:UnbuildRedDotUI(CVar.RedDotName.CraftNew)
	DY_DATA.RedSystem:UnbuildRedDotUI(CVar.RedDotName.MailNew)
	Ref.GrpIndicator:hide()
	ui.close("HUDWorld", true)
end

Handlers = {
	["CLIENT.SC.WND_OPEN"] = function (Wnd)
		if Wnd.name == "WNDTopBar" then
			set_visible(false)
		end
	end,
	["CLIENT.SC.WND_CLOSE"] = function (Wnd)
		if Wnd.name == "WNDTopBar" then
			set_visible(true)
		end
	end,

	["PLAYER.SC.ROLE_ASSET_GET"] = function (Player)
		rfsh_player_view()
	end,

	["WORLD_MAP.SC.WORLD_INFO"] = function (Ret)
		if Ret.dirty then
			libugui.SetVisible(Ref.go, true)
			rfsh_world_info(Ret.World)
		end
	end,

	["PACKAGE.SC.PACKAGE_OPEN"] = function (Bag)
		if Bag then
			if Bag.Data then
				local bagType = Bag.Data.type
				if bagType == 3 then
					Bag.wndName = "WNDVehicleUse"
					ui.open("UI/WNDPackage", nil, Bag)
				return end
			end

			libunity.LogE("异常：箱子类型非法={0}!", bagType)
		end
	end,

	["PLAYER.SC.GET_ROLE_INFO"] = rfsh_player_view,
	["ROLE.SC.GET_ROLE_INFO"] = rfsh_player_view,

	["WORLD_MAP.SC.STAGE_GROUP_INFO"] = function(alertEventArr)
		local World = rawget(DY_DATA, "World")
		rfsh_world_info(World)

		local eventLib = config("eventlib")
		local maplib = config("maplib")
		local fmtContent = TEXT.AskOperation.GeneralAlert.fmtContent
		for _,v in pairs(alertEventArr) do
			local eventInfo = eventLib.get_event_dat(v.eventId)
			local EntData = maplib.get_ent(v.id)
			if eventInfo then
				UI.MBox.operate_with_image("GeneralAlert", function ()
					local x, y, z = processing_camera_position(v.Coord.x, 0, v.Coord.y)
					local tarPos = UE.Vector3(x, y, z)
					libugui.DOTween("PositionW", "/WORLD/View", nil, tarPos, {
						duration = 0.25,
						ease = "OutQuad",
					})
				end, {
					content = string.format(fmtContent, eventInfo.name, eventInfo.desc),
					picture = EntData.picture,
			 	})
			end
		end
	end,

	["WORLD_MAP.SC.WORLD_WEATHER"] = function(modifyWeatherList)
		local Travel = DY_DATA.World.Travel
		local dst = Travel and Travel.dst or 0
		local traveling = dst > 0
		if traveling then
			for _,v in pairs(modifyWeatherList) do
				if v.entranceId == dst then
					rfsh_traveling_weather_panel(true)
					return
				end
			end
		end
	end,
	["COM.CS.KEEP_HEART"] = function ()
		Ref.SubSys.lbLatency.text = DY_DATA:get_network_letency()
	end,

	["CLIENT.SC.UNPACKING_ASSET"] = function (progress)
		if progress == 1 then
			rfsh_world_info(DY_DATA.World)
		end
	end,
}

return self

