--
-- @file    data/object/world.lua
-- @anthor  xingweizhen (weizhen.xing@funplus.com)
-- @date    2018-10-12 11:48:19
-- @desc    描述
--

local OBJDEF = {}
OBJDEF.__index = OBJDEF

function OBJDEF.new(Data)
	return setmetatable(Data or {}, OBJDEF)
end

function OBJDEF:find_entrance(id)
	local Entrances = self.Entrances
	if id == nil then id = self.Travel.src end

	for i,v in ipairs(Entrances) do
		if v.id == id then return i, v end
	end
end

-- 打开世界地图入口
function OBJDEF:show_stage_info(Entrance, Paths)
	local Team = rawget(DY_DATA, "Team")
	if Team and Team.entId == Entrance.id and Team.entId == DY_DATA.World.Travel.src then
		-- 需要先检查门票
		ui.open("UI/WNDCreateTeam")
	else
		ui.show("UI/WNDStageInfo", nil, { Entrance = Entrance, Paths = Paths, } )
	end
end

function OBJDEF:open_stage_info(Entrance)
	local Travel = self.Travel
	if Travel.dst == 0 then
		-- 非移动状态才能打开关卡详情
		if type(Entrance) ~= "table" then
			_, Entrance = self:find_entrance(Entrance)
		end

		if Entrance then
			libunity.PlayAudio("UI/UI_mapChoose")

			if Entrance.entranceState == 1 or Entrance.entranceState == 3 then
				local EntrancePaths = self.EntrancePaths
				local Paths = EntrancePaths and EntrancePaths[Entrance.id]
				if Entrance.id == Travel.src or Paths or not NW.connected() then
					self:show_stage_info(Entrance, Paths)
				else
					NW.send(NW.msg("WORLD_MAP.CS.GET_TARGET_PATH_INFO"):writeU32(Entrance.id))
				end
			elseif Entrance.entranceState == 2 then
				UI.Toast.norm(TEXT.EntranceNotOpen)
			end
		else
			libunity.LogW("没有找到入口: {0}", Entrance)
		end
	end
end


function OBJDEF:get_curr_stage(Entrance)
	if Entrance == nil then
		_, Entrance = self:find_entrance()
	end
	return Entrance.Stages and Entrance.Stages[1] or nil
end

function OBJDEF:get_curr_room(mapId)
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

function OBJDEF:enter_stage()
	local _, Entrance = self:find_entrance()
	local Stage = self:get_curr_stage(Entrance)
	if Stage.mapId == CVar.HOME_ID then
		-- 自己家里，先检查有没有被攻击
		local Room = self:get_curr_room(Stage.mapId)
		if Room and Room.roomType == 4 and Room.status ~= "Closed" then
			if Room.status == "InBattle" then
				NW.MULTI.get_room_token(Room.id)
			else

			end
		return end
	end

	if Stage.global then
		local Room = self:get_curr_room(Stage.mapId)
		if Room and Room.status == "InBattle" then
			-- 进入
			NW.MULTI.get_room_token(Room.id)
		else
			-- 单人匹配
			NW.alone_apply_map(Entrance)
		end
	else
		NW.apply_map(Stage.play, Stage.mapId)
	end
end

function OBJDEF:has_bundle(Entrance)
	if type(Entrance) == "number" then
		_, Entrance = self:find_entrance(Entrance)
	end
	local Stage = self:get_curr_stage(Entrance)
	if Stage == nil then return true end

	local StageBase = config("maplib").get_dat(Stage.mapId)
	local levelGrp, n = StageBase.path:gsub("(%a+%_%w+)%_%w+", "scenes/%1")
	if n > 0 and not SCENE.has_bundle(levelGrp) then return false end

	if DY_DATA:get_player().level > 6 and Entrance.id == CVar.HOME_ID then
		-- 当前方案，玩家等级大于6时检测下载包是否已下载，如果未下载完，家也不能进入
		local LFL = rawget(_G.ENV, "LFL")
		if LFL and LFL.Downloads["Others"] then
			return false
		end
	end
	return true
end

function OBJDEF:check_energy_enough(Entrance, travelTool)
	if type(Entrance) ~= "table" then
		_, Entrance = self:find_entrance(Entrance)
	end

	local Paths = self.EntrancePaths and self.EntrancePaths[Entrance.id]
	if Paths then
		local path = Paths[travelTool]
		local Energy = DY_DATA:get_player().Assets[1]
		if path.cost > Energy.amount then
			UI.MBox.buy_energy_alert()
			return false
		end
	end
	return true
end

function OBJDEF:check_passcard_enough(Entrance, travelTool)
	local Team = rawget(DY_DATA, "Team")
	if Team and Team.status == "Fighting" then
		return true
	end

	if Entrance == nil then
		_, Entrance = self:find_entrance()
	end
	local NewTeamCosts = Entrance.NewTeamCosts
	if NewTeamCosts then
		-- 检查创建队伍的体力消耗是否足够
		local Energy = DY_DATA:get_player().Assets[1]
		if NewTeamCosts.energy > Energy.amount then
			UI.MBox.buy_energy_alert()
			return false
		end

		-- 进入道具检查
		for _,v in ipairs(NewTeamCosts.Items) do
			local nOwn = DY_DATA:nget_item(v.id)
			if v.amount > nOwn then
				if v.id == 601 then
					UI.MBox.buy_mbpass_alert()
				end
				return false
			end
		end

	end
	return true
end

function OBJDEF:try_entrance(Entrance, action)
	local Team = rawget(DY_DATA, "Team")
	if Entrance == nil then
		_, Entrance = self:find_entrance()
	end

	if not self:has_bundle(Entrance) then
		ui.show("UI/WNDDownload")
	return end

	if Team and Entrance.id ~= Team.entId and Entrance.id ~= CVar.HOME_ID then
		UI.MBox.operate("TryWorldEntrance", function () NW.TEAM.exit(); action() end)
	else
		action()
	end
end

return OBJDEF