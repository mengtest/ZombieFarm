--
-- @file    ui/guild/lc_wndguilddispatch.lua
-- @author  shenbingkang
-- @date    2018-06-21 19:31:41
-- @desc    WNDGuildDispatch
--

local self = ui.new()
local _ENV = self

local CVar = _G.CVar
local Cfg = config("guildlib")
local UTIL = _G.PKG["ui/util"]
local show_attr_view = UTIL.show_attr_view
local show_item_view = UTIL.show_item_view

local employeeInfo

local function forceUpdateExpandEquipListSelected(go)
	libunity.SetParent(self.spExpandEquipSelected, go, false, -1)
	libunity.SetActive(self.spExpandEquipSelected, true)
end

local function expand_equip_list_view(mechpartsPos, position)
	libunity.SetActive(Ref.SubMain.SubExpandEquipView.go, true)
	libunity.SetPos(Ref.SubMain.SubExpandEquipView.SubExpandEquipList.go, position.x, position.y, position.z, true)

	local curEquipInfo = robot:get_dress(mechpartsPos)
	self.mechpartsInfoList = Cfg.get_mechparts_list(mechpartsPos)
	local SubScroll = Ref.SubMain.SubExpandEquipView.SubExpandEquipList.SubEquipMask.SubScroll
	local GrpEquipList = SubScroll.GrpEquipList
	GrpEquipList:dup(#self.mechpartsInfoList, function (i, Ent, isNew)
		local mechpartsInfo = self.mechpartsInfoList[i]
		UTIL.flex_itement(Ent, "SubItem", 0)
		show_item_view(nil, Ent.SubItem, mechpartsInfo.icon)
		if curEquipInfo.id == mechpartsInfo.id then
			forceUpdateExpandEquipListSelected(Ent.SubItem.go)
		end
	end)

	local tweenDura = 0.2
	local SubMain = Ref.SubMain

	libugui.DOTween("Position", SubScroll.go, nil, UE.Vector2.zero, { 
		duration = tweenDura,
	})
end

local function update_robot_view(pose, Model)
	if libunity.IsActive(self.robotView) then
		libgame.UpdateUnitView(self.robotView, pose, { model = Model})
	end
end

local function create_robot_view()
	local RobotForm = self.robot:get_form_data()
	self.robotView = libgame.CreateView("/UIROOT/ROLE", "RobotOverUI",	0, RobotForm.View)
	libugui.Follow(self.robotView, Ref.SubMain.SubDispatchView.evtModel, 8)
	libunity.FaceCamera(self.robotView)
	local trans = self.robotView.transform
	local euler = trans.localEulerAngles
	euler.y = 42
	trans.localEulerAngles = euler
end

local function rfsh_all_equip_list_view()
	local robot = self.robot
	local SubDispatchView = Ref.SubMain.SubDispatchView
	--填充装备
	SubDispatchView.GrpEquip:dup(CVar.ROBOT_MECHPARTS_NUM, function (i, Ent, isNew)
		local mechpartsInfo = robot:get_dress(i)
		UTIL.flex_itement(Ent, "SubItem", 0)
		show_item_view(nil, Ent.SubItem, mechpartsInfo.icon)
	end)

	--刷新机器人模型
	if self.robotView == nil then
		create_robot_view()
	else
		update_robot_view(0, robot:get_view_dresses())
	end
end

local function calc_exploit_value(exploitTime, receiveTime, totalEfficiency)
	local v1 = math.max(0, (totalEfficiency - CVar.GUILD.EfficiencyAdjust))
	local v2 = CVar.GUILD.EfficiencyCorrect / 1000
	local v3 = v1 ^ v2

	local value = exploitTime / receiveTime * (1 + (v3 / 10))
	return math.ceil(value)
end

local function rfsh_guild_dispatch_attr_view()
	local robot = self.robot
	local SubDispatchView = Ref.SubMain.SubDispatchView
	local SubExploit = SubDispatchView.SubWorkOpera.SubExploit

	--属性值
	local Attr = robot:calc_attr()
	local Keys = { "Damage", "def", "hp" }
	show_attr_view(SubDispatchView.GrpAttrs, Attr, Keys)

	--额外属性
	local totalEfficiency, totalEndurance, totalCost = robot:calc_extra_attr()
	local efficiencyPrecent = totalEfficiency / 100
	local endurancePrecent = totalEndurance / 100
	self.exploitTime = Cfg.get_exploit_time(totalEndurance)

	local mapList = Cfg.get_exploit_map_list()
	local mapInfo = mapList[self.selectStageIndex]
	local receiveTime = mapInfo.receiveTime
	local exploitOutputValue = calc_exploit_value(self.exploitTime, receiveTime, totalEfficiency)

	SubDispatchView.SubEfficiency.barEfficiency.value = efficiencyPrecent > 1 and 1 or efficiencyPrecent
	SubDispatchView.SubEndurance.barEndurance.value = endurancePrecent > 1 and 1 or endurancePrecent

	UTIL.flex_itement(SubExploit, "SubItem", 0)
	local Item = _G.DEF.Item.new(mapInfo.itemID, exploitOutputValue)
	show_item_view(Item, SubExploit.SubItem)

	--采集时间展示
	local exploitTime_H = self.exploitTime / 3600
	SubDispatchView.SubWorkOpera.SubExploit.lbExploitTime.text = string.format(TEXT.fmtGuildExploitTime, exploitTime_H)

	--派遣消耗
	SubDispatchView.SubWorkOpera.SubDispatchBtns.SubNormalDispatch.SubAsset.lbAmount.text = totalCost
	SubDispatchView.SubWorkOpera.SubDispatchBtns.SubGoldDispatch.SubAsset.lbAmount.text = math.ceil(totalCost / CVar.GUILD.ExploitExchangeRate)

end

local function on_exploit_fin()
	self.mapID = 0
	self.dispatchEndTime = 0
	DY_TIMER.stop_timer("GUILD_EXPLOIT")
	rfsh_all_equip_list_view()
	rfsh_guild_dispatch_attr_view()
	rfsh_guild_dispatch_state()
end

local function on_exploit_timer(tm)
	local SubExploit = Ref.SubMain.SubDispatchView.SubWorkOpera.SubExploit
	SubExploit.lbExploitTime.text = string.format(TEXT.fmtRemainingTime, tm:to_time_string())
end

local function rfsh_guild_dispatch_state()
	local SubDispatchView = Ref.SubMain.SubDispatchView
	if employeeInfo == nil then
		--没有雇佣兵，不可派遣
		libunity.SetActive(SubDispatchView.SubWorkOpera.go, false)
		libunity.SetActive(SubDispatchView.SubWaiting.go, true)
	else
		libunity.SetActive(SubDispatchView.SubWorkOpera.go, true)
		libunity.SetActive(SubDispatchView.SubWaiting.go, false)
		
		local unDispatch = self.mapID == 0
		DY_TIMER.stop_timer("GUILD_EXPLOIT")
		libunity.SetActive(SubDispatchView.SubWorkOpera.SubDispatchBtns.go, unDispatch)
		if not unDispatch then
			local timeLeft = self.dispatchEndTime - os.date2secs()
			local tm = DY_TIMER.replace_timer("GUILD_EXPLOIT", timeLeft, timeLeft, on_exploit_fin)
			tm:subscribe_counting(Ref.go, on_exploit_timer)
			on_exploit_timer(tm)
		end
	end
end

local function rfsh_select_stage_view()
	local mapList = Cfg.get_exploit_map_list()
	Ref.SubMain.SubDispatchView.SubWorkOpera.GrpStage:dup(#mapList, function (i, Ent, isNew)
		local mapInfo = mapList[i]
		Ent.lbStageName.text = mapInfo.name
		Ent.spBack.color = self.selectStageIndex == i and "#C59836" or "#C5C5C5"
		Ent.spStage:SetTexture(string.format("rawtex/%s/%s", mapInfo.icon, mapInfo.icon))
	end)
end

local function rfsh_employee_npc_info()
	if employeeInfo then
		local SubGuard = Ref.SubMain.SubNPCInfo.SubGuard
		libunity.SetActive(SubGuard.go, true)
		local npcBaseInfo = config("unitlib").get_dat(employeeInfo.npcID)
		SubGuard.lbGuardName.text = npcBaseInfo.name
		SubGuard.lbGuardInfo.text = npcBaseInfo.desc
		--todo:npc头像

		libugui.RebuildLayout(Ref.SubMain.SubNPCInfo.go)
	end
end

local function rfsh_npc_info()
	local Obj = CTRL.get_obj(Context.obj)
	local npcBaseInfo = Obj:get_base_data()
	local SubNPCInfo = Ref.SubMain.SubNPCInfo
	SubNPCInfo.lbNpcName.text = npcBaseInfo.name
	SubNPCInfo.lbNpcInfo.text = npcBaseInfo.desc
	--todo:npc头像

	libunity.SetActive(SubNPCInfo.SubGuard.go, false)
	libugui.RebuildLayout(SubNPCInfo.go)
end

--!* [开始] 自动生成函数 *--

function on_submain_subdispatchview_grpequip_entequip_subitem_click(btn)
	local bDispatching = self.mapID ~= 0
	if bDispatching == true then
		--派遣中不可点击
		return
	end

	local GrpEquip = Ref.SubMain.SubDispatchView.GrpEquip
	local index = GrpEquip:getindex(btn.transform.parent)
	expand_equip_list_view(index, btn.transform.position)
end

function on_submain_subdispatchview_subworkopera_grpstage_entstage_click(btn)
	local bDispatching = self.mapID ~= 0
	if bDispatching == true then
		--派遣中不可点击
		return
	end

	local GrpStage = Ref.SubMain.SubDispatchView.SubWorkOpera.GrpStage
	self.selectStageIndex = GrpStage:getindex(btn)
	rfsh_select_stage_view()
	rfsh_guild_dispatch_attr_view()
end

function on_btndispatch_normal_click(btn)
	local mapList = Cfg.get_exploit_map_list()
	local mapInfo = mapList[self.selectStageIndex]
	NW.GUILD.RequestDispatch(mapInfo.mapID, 1)
end

function on_btndispatch_gold_click(btn)
	local mapList = Cfg.get_exploit_map_list()
	local mapInfo = mapList[self.selectStageIndex]
	NW.GUILD.RequestDispatch(mapInfo.mapID, 2)
end

function on_evtmodel_drag(evt, data)
	if self.robotView and self.robotView.transform then
		local delta = data.delta
		local trans = self.robotView.transform
		local euler = trans.localEulerAngles
		euler.y = euler.y - delta.x
		trans.localEulerAngles = euler
	end
end

function on_close_expandequiplist_click(btn)
	local SubScroll = Ref.SubMain.SubExpandEquipView.SubExpandEquipList.SubEquipMask.SubScroll
	libugui.SetAnchoredPos(SubScroll.go, 365, 0)

	libunity.SetActive(Ref.SubMain.SubExpandEquipView.go ,false)
end

function on_select_expand_equip_ent(btn)
	forceUpdateExpandEquipListSelected(btn)
	local GrpEquipList = Ref.SubMain.SubExpandEquipView.SubExpandEquipList.SubEquipMask.SubScroll.GrpEquipList
	local index = GrpEquipList:getindex(btn)
	local mechpartsInfo = self.mechpartsInfoList[index]
	NW.GUILD.RequestChangeMechparts(mechpartsInfo.id)

	on_close_expandequiplist_click()
end
--!* [结束] 自动生成函数  *--

function init_view()
	ui.group(Ref.SubMain.SubDispatchView.GrpAttrs)
	ui.group(Ref.SubMain.SubDispatchView.GrpEquip)
	ui.group(Ref.SubMain.SubDispatchView.SubWorkOpera.GrpStage)
	ui.group(Ref.SubMain.SubExpandEquipView.SubExpandEquipList.SubEquipMask.SubScroll.GrpEquipList)
	--!* [结束] 自动生成代码 *--

	self.spExpandEquipSelected = Ref.SubMain.SubExpandEquipView.SubExpandEquipList.SubEquipMask.SubScroll.spSelected
	libunity.SetActive(self.spExpandEquipSelected, false)

	local SubScroll = Ref.SubMain.SubExpandEquipView.SubExpandEquipList.SubEquipMask.SubScroll
	libugui.SetAnchoredPos(SubScroll.go, 365, 0)
	libunity.SetActive(Ref.SubMain.SubExpandEquipView.go, false)
	
	self.selectStageIndex = 1
	rfsh_select_stage_view()
end

function init_logic()
	ui.moveout(Ref.spBack, 1)
	if NW.connected() then
		rfsh_npc_info()
		NW.GUILD.RequestGetDispatchInfo()
		NW.GUILD.RequestGetBuildingInfo()
	else
		self.robot = _G.DEF.Robot.new(0, "Robot", 0, "")
		self.robot:set_view({23110, 23120, 23130, 23140, 23150, 23160})
		create_robot_view()
	end
end

function show_view()
	
end

function on_recycle()
	ui.putback(Ref.spBack, Ref.go)

	DY_TIMER.stop_timer("GUILD_EXPLOIT")

	libunity.SetParent(self.spExpandEquipSelected, 
		Ref.SubMain.SubExpandEquipView.SubExpandEquipList.SubEquipMask.SubScroll.go, true, -1)

	libunity.SetActive(self.spExpandEquipSelected, true)
	libunity.SetActive(Ref.SubMain.SubExpandEquipView.go, true)

	libgame.Recycle(self.robotView and self.robotView.gameObject)
end

Handlers = {
	["GUILD.SC.GET_DISPATCH_INFO"] = function (data)
		self.robot = data.robot
		self.dispatchEndTime = data.time
		self.mapID = data.mapID
		rfsh_all_equip_list_view()
		rfsh_guild_dispatch_attr_view()
		rfsh_guild_dispatch_state()
	end,
	["GUILD.SC.CHANGE_MECH_PART"] = function (mechpartsID)
		if mechpartsID then
			local modifyInfo = Cfg.get_mechparts_info(mechpartsID)
			self.robot:set_dress(modifyInfo.class, mechpartsID)
			rfsh_all_equip_list_view()
			rfsh_guild_dispatch_attr_view()
		end
	end,
	["GUILD.SC.GET_BUILDING_INFO"] = function (buildingInfoList)
		if buildingInfoList then
			for _,v in pairs(buildingInfoList) do
				if v.buildingID == 4 then
					employeeInfo = Cfg.get_employee_info(v.buildingLevel)
					rfsh_employee_npc_info()
					rfsh_guild_dispatch_state()
					return
				end
			end
		end
	end,
	["GUILD.SC.GUILD_DISPATCH"] = function (dispatchEndTime)
		if dispatchEndTime then
			self.dispatchEndTime = dispatchEndTime
			local mapList = Cfg.get_exploit_map_list()
			local mapInfo = mapList[self.selectStageIndex]
			self.mapID = mapInfo.mapID

			rfsh_all_equip_list_view()
			rfsh_guild_dispatch_attr_view()
			rfsh_guild_dispatch_state()
		end
	end,
}

return self

