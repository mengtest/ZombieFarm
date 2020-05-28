--
-- @file    game/event/prelude.lua
-- @anthor  xingweizhen (weizhen.xing@funplus.com)
-- @date    2018-07-17 10:29:15
-- @desc    描述
--

return function (CTRL)
	libasset.LoadAsync(nil, "atlas/Guide/")

	local API = _G.PKG["game/api"]
	local GUIDE = _G.PKG["guide/api"]
	local self = ui.find("FRMExplore")
	local Ref = self.Ref
	local show_goal = API.show_goal

	local step = GUIDE.load(0) or 1

	local tarId, Boxes = nil, {}
	for _,v in pairs(DY_DATA:get_stage().Units) do
		if v.dat == 999 then
			tarId = v.id
			break
		end
	end

	local function stop_moving()
		libugui.ExecuteEvent(Ref.SubMove.go, "PointerUp")
		self.cancel_moving(true)
	end

	local function stop_attack()
		libugui.ExecuteEvent(Ref.SubMajor.go, "PointerUp")
		libgame.PlayerAttack()
	end

	local function hook_goal(Goal)
		DY_DATA.Goal = Goal
		show_goal(nil, "NewPlayerTask")
	end

	local showArrow
	local function show_guide_arrow(i, lookId)
		if showArrow == step then
			local pos = libgame.GetUnitPos(0)
			local lookPos = libgame.GetUnitPos(lookId)
			if lookPos == nil then return true end

			if UE.Vector3.Distance(pos, lookPos) > 5 then
				local Fxes = libgame.PlayFx(0, "Common/guide_arrow")
				local go = Fxes and Fxes[1]
				if go == nil then return end

				go.transform.localScale = UE.Vector3(1, 1, 0)
				go.transform:LookAt(lookPos)
			end
		else
			showArrow = nil
			return true
		end
	end

	local function show_leaving_arrow(i)
		if showArrow == step then
			local tarPos = libgame.GetUnitPos(0, true)
			if tarPos == nil then return true end

			local Fxes = libgame.PlayFx(0, "Common/guide_arrow")
			local go = Fxes and Fxes[1]
			if go == nil then return end

			local Stage = DY_DATA:get_stage()
			local lowx, lowz = tarPos.x < Stage.w / 2, tarPos.z < Stage.h / 2
			local x = lowx and tarPos.x or Stage.w - tarPos.x
			local z = lowz and tarPos.z or Stage.h - tarPos.z

			if x < z then
				x = lowx and -1 or Stage.w + 1
				z = tarPos.z
			else
				x = tarPos.x
				z = lowz and -1 or Stage.h + 1
			end

			local lookPos = libgame.Local2World(UE.Vector3(x, 0, z))
			go.transform.localScale = UE.Vector3(1, 1, 0)
			go.transform:LookAt(lookPos)
		else
			showArrow = nil
			return true
		end
	end

	local function save_guide(n)
		step = n
		GUIDE.save(0, step)
	end

	local guideObj, GuideDats
	local function show_pick_obj_hud(i, icon)
		if GuideDats == nil then
			if guideObj then
				API.del_hud_elm("InteractHUD#" .. guideObj)
				guideObj = nil
			end
		return true end

		local Dats = GuideDats
		local SortedObjs = libgame.GetSortedUnits()
		for _,v in ipairs(SortedObjs) do
			local Obj = CTRL.get_obj(v)
			if Obj then
				for _,dat in ipairs(Dats) do
					if dat == Obj.dat then
						if guideObj ~= v then
							if guideObj then API.del_hud_elm("InteractHUD#" .. guideObj) end

							-- Show Hud
							local Hud = API.show_hud_elm(v, "InteractHUD")
							ui.seticon(Hud.spIcon, icon)
							guideObj = v
						end
					return end
				end
			end
		end
	end
	local function show_wndexplore()

		libunity.SetActive(Ref.SubMove.go, true)
		self.set_visible(true)
		--libgame.PlayFx(crushedId, "Common/pickup_smoke", crushedId)
	end
	local GuideSteps
	GuideSteps = {
		[1] = function ()
			self.set_visible(false)
			-- 初始...
			API.show_chat_bubble(0, 9000001)
			libunity.SetActive(Ref.SubMove.go, false)
			GuideSteps[2]()
			libunity.Invoke(Ref.go,4, show_wndexplore)
		end,
		[2] = function ()
			GUIDE.focus(Ref.SubMove.go, { event = "begindrag", stepover = "ptrup", tips = 9000201, block = true })
			hook_goal{ name = config("textlib").get_dat(9000101), }
			-- 箭头指向，提醒寻找目标
			if showArrow == nil then
				libunity.InvokeRepeating(Ref.go, 1, 3, show_guide_arrow, tarId)
			end
			showArrow = 2
		end,
		[3] = function ()
			GuideDats = { 10002, 10003, 10004, 10005 }
			libunity.InvokeRepeating(Ref.go, 0.1, 0.1, show_pick_obj_hud, "CommonIcon/ico_main_024")
			-- 提醒拾取石头/树枝
			libunity.SetActive(Ref.SubFuncs.btnInventory, true)
			libunity.SetActive(Ref.SubReload.go, true)
			libunity.SetActive(Ref.SubSwitch.go, true)
			libunity.SetActive(Ref.SubRPocket.go, true)
			libunity.SetActive(Ref.SubLPocket.go, true)
			libunity.SetActive(Ref.SubMinor.go, true)
		end,
		[4] = function ()
			-- 学习工艺
			libgame.UnitStay(0, true)
			GUIDE.launch("crafting", 1, true)
			libunity.Invoke(Ref.go, 1, function ()
				libunity.SetActive(Ref.SubFuncs.btnCraft, true)
			end)
		end,
		[5] = function ()
			GuideDats = { 1001, 1002, }
			libunity.InvokeRepeating(Ref.go, 0.1, 0.1, show_pick_obj_hud, "CommonIcon/ico_main_048")
		end,
		[6] = function ()
			-- showArrow = 6
			-- libunity.InvokeRepeating(Ref.go, 1, 3, show_leaving_arrow)
		end,
	}

	CTRL.subscribe("INIT_STAGE", function ()
		libunity.SetActive(Ref.SubMove.go, step > 1)
		libunity.SetActive(Ref.SubMajor.go, step > 2)
		libunity.SetActive(Ref.SubMinor.go, step > 2)
		libunity.SetActive(Ref.SubFuncs.btnInventory, step > 2)
		libunity.SetActive(Ref.SubReload.go, step > 2)
		libunity.SetActive(Ref.SubSwitch.go, step > 2)
		libunity.SetActive(Ref.SubRPocket.go, step > 2)
		libunity.SetActive(Ref.SubLPocket.go, step > 2)
		libunity.SetActive(Ref.SubFuncs.btnCraft, step > 3)

		libunity.SetActive(Ref.SubFuncs.btnBuild, step > 5)
		-- libunity.SetActive(Ref.SubFuncs.btnMall, false)
		-- libunity.SetActive(Ref.SubFuncs.btnGuild, step > 5)
		libunity.SetActive(Ref.tglSneak, step > 5)

		--libunity.SetActive(ui.find("WNDChat").Ref.SubNode.go, step > 5)


		-- 新手引导中不处理天气变换等地图事件
		local handler = self.Handlers["MAP.SC.SYNC_MAP_EVENT"]
		if handler then
			self:subscribe("MAP.SC.SYNC_MAP_EVENT", function (EventInfo)
				if type(EventInfo) == "table" and EventInfo.eventType == 3 then
					return
				end
				handler(EventInfo)
			end, true)
		end

		local Stage = DY_DATA:get_stage()
		-- 新手引导过程中，固定天时为正午&晴天
		libgame.GetDayNight():SendMessage("SetFixTime", 0.4)
		Stage:update_weather(1)

		show_goal(nil, "NewPlayerTask")

		return true
	end)

	CTRL.subscribe("VIEW_LOAD", function (obj, alpha)
		if obj == CTRL.selfId then

			hook_goal(nil)
			if step < 5 and GUIDE.load(2) == 0 then
				step = 5
			end

			if step < 3 and tarId == nil then
				step = 3
			end

			GuideSteps[step]()
			if step < 2 then
				libgame.UnitAnimate(0, "getup")
				save_guide(2)
			end
		else
			local Obj = CTRL.get_obj(obj)
			if Obj == nil then
				libunity.LogW("VIEW_LOAD对象不存在：#{0}", obj)
			return end
			if _G.SCENE.showSmoke then
		 	--报废汽车的id 53061
			 	if Obj and 53061 == Obj.dat then
					libgame.PlayFx(Obj.id, "Common/pickup_smoke", Obj.id)
				end
			end
		end
	end)

	if step < 3 then
		local targetFoundFlag
		local function guide_target()
			ui.close("WNDGuiding", true)
			libunity.SetActive(Ref.SubMajor.go, true)
			GUIDE.focus(Ref.SubMajor.go, { tips = 9000202, })
		end

		CTRL.subscribe("TARGET_CHANGED", function (obj, target)
			if obj == CTRL.selfId then
				if target == tarId then
					hook_goal(nil)
					if targetFoundFlag then
						guide_target()
					else
						targetFoundFlag = true
						stop_moving()
						API.show_chat_bubble(obj, 9000002)
						libunity.Invoke(nil, 1, function ()
							if libgame.GetAutoTarget() == tarId then
								guide_target()
							end
						end)
					end
				return end

				-- 容错处理
				if step == 2 then ui.close("WNDGuiding") end
			end
		end)

		CTRL.subscribe("OBJ_DEAD", function (obj)
			if obj ~= CTRL.selfId then
				API.show_chat_bubble(0, 9000003)
				if step < 3 then
					ui.close("WNDGuiding")
					save_guide(3)
				end
				GuideSteps[3]()
				return true
			else
				-- 自己死了，万事皆休
				ui.close("WNDGuiding")
			end
		end)
	end

	if step < 4 then
		self:subscribe("PACKAGE.SC.SYNC_ITEM", function (Items)
			local nWood = DY_DATA:get_item_amount(11001)
			local nStone = DY_DATA:get_item_amount(13001)
			if nWood >= 3 and nStone >= 3 then
				API.show_chat_bubble(0, 9000004)
				ui.close("WNDGuiding", true)
				hook_goal(nil)
				save_guide(4)
				GuideSteps[4]()
				GuideDats = nil
				return true
			end
		end)
	end

	if step < 5 then
		self:subscribe("CLIENT.SC.WND_CLOSE", function (Wnd)
			if Wnd.name == "WNDCraft" then
				save_guide(5)
				GuideSteps[5]()
				return true
			end
		end)
	end

	self:subscribe("TASK.SC.TASK_GET", function (Tasks)
		--show_goal(nil, "NewPlayerTask")
		hook_goal(nil)

		local endTask = Tasks[1021]
		if endTask then
			ui.close("WNDGuiding")
			API.show_chat_bubble(0, 9000005)
			-- 结束新手引导
			save_guide(0)
			GuideDats = nil

			--GuideSteps[6]()

			libunity.SetActive(Ref.SubFuncs.btnBuild, true)
			libunity.SetActive(Ref.tglSneak, true)
			libunity.SetActive(ui.find("WNDChat").Ref.SubNode.go, true)

			return true
		end
	end)
end

