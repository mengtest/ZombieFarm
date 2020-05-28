--
-- @file    game/api.lua
-- @anthor  xingweizhen (weizhen.xing@funplus.com)
-- @date    2018-07-17 10:00:21
-- @desc    描述
--

local Abc

local P = {}
P.find_hud_elm = libgame.FindUnitHud
P.showArrowFlag = 0

local WorkingLIB = config("workinglib")

function P.InitMapEventHint(tnsParent, siblingIndex)
	if Abc == nil then
		Abc = ui.ref(ui.create("UI/AbcGuide", nil, 1))
	end
	if tnsParent then
		libunity.SetParent(Abc.go, tnsParent, false)
		libunity.SetSibling(Abc.go, siblingIndex)
	else
		ui.moveout(Abc.go, 0)
	end
	Abc.lbGoal.text = nil
end

function P.add_hud_elm(hudName)
	local go = libgame.AddUnitHud("UI/".. hudName)
	libugui.SetAlpha(go, 1)
	return go
end

function P.del_hud_elm(hud, fadeout, delay)
	if type(hud) == "string" then
		hud = P.find_hud_elm(hud)
	end
	if hud == nil then return end

	if fadeout then
		libugui.DOTween("Alpha", hud, nil, 0, {
				delay = delay,
				duration = fadeout,
				complete = libgame.Recycle,
			})
	else
		libgame.Recycle(hud)
	end
end

function P.set_hud_alpha(hudName, alpha)
	libugui.SetAlpha(P.find_hud_elm(hudName), alpha)
end

function P.need_hud_elm(name, prefab)
	local isNew
	local go = P.find_hud_elm(name)
	if go == nil and prefab then
		go = P.add_hud_elm(prefab)
		go.name = name
		isNew = true
	end
	return go and ui.ref(go), isNew
end

function P.show_hud_elm(obj, prefab)
	local view = libgame.GetViewOfObj(obj)
	if view then
		if obj == 0 then obj = _G.PKG["game/ctrl"].selfId end
		local Sub, isNew = P.need_hud_elm(prefab .. "#" .. obj, prefab)
		if Sub then
			libugui.Follow(Sub.go, GO(view, "HUD"))
			return Sub, isNew
		end
	end
end

function P.create_obj_hud(Obj, hudName)
	local go = P.add_hud_elm(hudName)
	local Sub = ui.ref(go)

	local debug = _G.ENV.debug
	libugui.SetInteractable(go, debug)
	if debug then
		if Sub.lbDebug2 then
			local ObjForm = Obj.Form
			Sub.lbDebug2.text = string.format("#%d %s", Obj.id, ObjForm.View.name or "")
		end
	end
	return Sub
end

function P.get_obj_hud(obj)
	return P.need_hud_elm("HUD#"..obj)
end

function P.set_obj_hud(obj, alpha)
	libugui.SetAlpha(P.find_hud_elm("HUD#"..obj), alpha)
end

function P.del_obj_hud(obj, fadeout, delay)
	P.del_hud_elm("HUD#"..obj, fadeout, delay)
end

function P.get_chat_bubble(obj)
	return P.need_hud_elm("ChatBubble#" .. obj, "ChatBubble")
end

function P.del_chat_bubble(obj, fadeout, delay)
	P.del_hud_elm("ChatBubble#"..obj, fadeout, delay)
end

function P.show_chat_bubble(obj, text)
	local view = libgame.GetViewOfObj(obj)
	if view then
		if obj == 0 then obj = _G.PKG["game/ctrl"].selfId end

		local Bubble = P.get_chat_bubble(obj)
		if type(text) == "number" then
			text = config("textlib").get_dat(text)
		end
		Bubble.lbContent.text = text

		local Frm = ui.find("FRMExplore")
		libugui.Follow(Bubble.go, GO(view, "HUD"), Frm and Frm.camTrans)

		libugui.KillTween(Bubble.go)
		libugui.DOTween("Alpha", Bubble.go, nil, 1, {
			duration = 0.3,
		})
		P.del_chat_bubble(obj, 0.3, 3)
	end
end

function P.get_unit_color(Obj)
	local Stage = DY_DATA:get_stage()
	if Stage.Team and table.ifind(Stage.Team, Obj.id) then
		return CVar.UnitColors.team
	end

	local selfCamp, color = Stage.Self.camp
	if selfCamp == Obj.camp then
		return CVar.UnitColors.help
	end

	local ObjForm = Obj.Form
	local operId = ObjForm and ObjForm.Data.Init.operId or nil
	if operId and operId > 0 or not Obj:offensive() then
		return CVar.UnitColors.neutral
	else
		return CVar.UnitColors.harm
	end
end

function P.toast_oper_fail(ret, operId)
	local content
	if ret == 2 then
		content = TEXT.tipExitAutoPlayNoRes
	elseif ret == 3 then
		local OperData = config("skilllib").get_dat(operId)
		content = config("textlib").get_dat(OperData.reqTip)
	elseif ret == 4 then
		content = TEXT.tipExitAutoPlayNoPath
	elseif ret == 5 then
		content = TEXT.tipInventoryFull
	end
	if content then
		UI.MonoToast.make("Play", content):show(0.5)
	end
end

-- 设施交互表现
function P.start_building_interaction(obj, bShowCastBar)
	local CTRL = _G.PKG["game/ctrl"]
	local objInteraction = libgame.GetViewOfObj(obj)
	if objInteraction then
		local Obj = CTRL.get_obj(obj)
		local ObjBase = Obj:get_base_data()
		local interactiveInfo = WorkingLIB.get_interactive_info(ObjBase.id)

		if interactiveInfo then
			local Interaction
			if #interactiveInfo.pointName == 0 then
				Interaction = libunity.Find(objInteraction, "Model")
			else
				Interaction = libunity.Find(objInteraction, string.format("Model/%s", interactiveInfo.pointName))
			end

			if Interaction then
				local trans = Interaction.transform
				local tarPos, tarFwd = trans.position, trans.forward
				libgame.UnitMove(0, tarPos)
				libgame.UnitTurn(0, tarFwd)

				local Ref = ui.find("FRMExplore").Ref

				--关闭ui交互
				libugui.SetInteractable(Ref.go, false)
				libugui.SetBlocksRaycasts(Ref.go, false)

				libunity.StartCoroutine(nil, function ()
					local Vector3 = UE.Vector3
					local objPlayer = libgame.GetViewOfObj(0).transform

					local isArrived = false

					while true do
						-- 等待到位
						coroutine.yield(0.1)
						local pos = libgame.GetUnitCoord(0)
						if isArrived == false then
							libgame.UnitMove(0, tarPos)
							if Vector3.Distance(pos, tarPos) < 0.4 then
								isArrived = true
								libgame.UnitStop(0)
							end
						end
						if isArrived then
							libgame.UnitTurn(0, tarFwd)
							if Vector3.Dot(tarFwd, objPlayer.forward) > 0.9 then
								break
							end
						end
					end

					libgame.UnitStop(0)
					-- 隐藏头顶信息
					P.set_obj_hud(CTRL.get_self().id, 0)

					-- 执行交互
					if #interactiveInfo.selfAction > 0 then
						libgame.UnitAnimate(0, interactiveInfo.selfAction, 0.25)
					end
					if #interactiveInfo.targetAction > 0 then
						libgame.UnitAnimate(obj, interactiveInfo.targetAction, 0.25)
					end
					if #interactiveInfo.selfSFX > 0 then
						libunity.PlayAudio(interactiveInfo.selfSFX, objPlayer, false)
					end
					if #interactiveInfo.targetSFX > 0 then
						libunity.PlayAudio(interactiveInfo.targetSFX, objInteraction, false)
					end
					--交互特效
					local tmpl = Obj:get_tmpl_data()
					local modelName = string.lower(tmpl.model)
					local workingRes = string.format("%s/working_%s", modelName, modelName)
					libasset.LoadAsync(nil, "fx/"..workingRes, "Cache", function(a, o, p)
						libgame.PlayFx(obj, workingRes, obj, true, o)
					end)

					--头顶进度条
					if bShowCastBar then
						local Bar = P.need_hud_elm("CastBar", "CastBar")
						libugui.Follow(Bar.bar, GO(objPlayer, "HUD"))
						libugui.DOTween(nil, Bar.bar, 0, 1, {
							ignoreTimescale = false,
							duration = interactiveInfo.duration,
							complete = libgame.Recycle,
						})
					end

					-- 等待锁定时间结束
					local waitTime = 0
					while waitTime < interactiveInfo.duration do
						coroutine.yield(0.1)
						waitTime = waitTime + 0.1
					end

					-- 显示头顶信息
					P.set_obj_hud(CTRL.get_self().id, 1)

					--打开ui交互
					libugui.SetInteractable(Ref.go, true)
					libugui.SetBlocksRaycasts(Ref.go, true)
				end)
			end
		end
	end
end

-- 清除该园地上所有的作物模型
function P.clean_gardenbed_crop_model(view, Obj)
	if Obj.CropGroup == nil then
		Obj.CropGroup = {}
	end
	for i=1,20 do
		local cropUnit = libunity.Find(view, "Model/CropGroup/Crop"..i)
		if Obj.CropGroup[i] == nil then
			Obj.CropGroup[i] = {}
		end
		Obj.CropGroup[i].state = 0  --state 0:没东西 1:正在生长 2:成熟
		Obj.CropGroup[i].resPath = nil
		Obj.CropGroup[i].cropUnit = cropUnit

		local temp = libunity.Find(cropUnit, 0)
		if temp then
			libgame.DelUnitSkin(Obj.id, temp)
			libgame.Recycle(temp.gameObject)
		end
	end
end

-- 刷新园地上的作物状态
function P.show_gardenbed_working(view, Obj, lastTime)
	local formulaTotalTime = Obj.formulaTotalTime

	local formulaInfo = WorkingLIB.get_dat(Obj.formulaID)
	local cropTotalCnt = formulaInfo and math.ceil(formulaTotalTime / formulaInfo.duration) or 0
	local unfinishCropCnt = formulaInfo and math.ceil(lastTime / formulaInfo.duration) or 0

	local needLoad_growingCrop = false
	local needLoad_ripeCrop = false

	for i=1,20 do
		local CropGroupUnit = Obj.CropGroup[i]

		if i <= unfinishCropCnt then
			local isNeed = CropGroupUnit.state ~= 1
			CropGroupUnit.state = 1
			if isNeed then
				CropGroupUnit.resPath = formulaInfo.growingCrop
				needLoad_growingCrop = true
			end
		elseif i <= cropTotalCnt then
			local isNeed = CropGroupUnit.state ~= 2
			CropGroupUnit.state = 2
			if isNeed then
				CropGroupUnit.resPath = formulaInfo.ripeCrop
				needLoad_ripeCrop = true
			end
		else
			CropGroupUnit.state = 0
			CropGroupUnit.resPath = nil
			local cropGameObject = libunity.Find(CropGroupUnit.cropUnit, 0)
			if cropGameObject then
				libgame.Recycle(cropGameObject)
			end
		end
	end

	if needLoad_growingCrop then
		libasset.LoadAsync(typeof(UE.GameObject), string.format("Units/%s/%s", formulaInfo.growingCrop, formulaInfo.growingCrop),
		"Default", function(a, o, p)
			for i=1,20 do
				local CropGroupUnit = Obj.CropGroup[i]
				if p == CropGroupUnit.resPath then
					CropGroupUnit.resPath = nil
					local unit = libunity.Find(CropGroupUnit.cropUnit, 0)
					if unit then
						libgame.DelUnitSkin(Obj.id, unit)
						libgame.Recycle(unit)
					end
					local newCrop = libgame.AddChild(CropGroupUnit.cropUnit, o)
					local rdr = newCrop:GetComponentInChildren(typeof(UE.Renderer))
					rdr.enabled = true
					libgame.AddUnitSkin(Obj.id, newCrop)
				end
			end
		end, formulaInfo.growingCrop)
	end

	if needLoad_ripeCrop then
		libasset.LoadAsync(typeof(UE.GameObject), string.format("Units/%s/%s", formulaInfo.ripeCrop, formulaInfo.ripeCrop),
		"Default", function(a, o, p)
			for i=1,20 do
				local CropGroupUnit = Obj.CropGroup[i]
				if p == CropGroupUnit.resPath then
					CropGroupUnit.resPath = nil
					local unit = libunity.Find(CropGroupUnit.cropUnit, 0)
					if unit then
						libgame.DelUnitSkin(Obj.id, unit)
						libgame.Recycle(unit)
					end
					local newCrop = libgame.AddChild(CropGroupUnit.cropUnit, o)
					local rdr = newCrop:GetComponentInChildren(typeof(UE.Renderer))
					rdr.enabled = true
					libgame.AddUnitSkin(Obj.id, newCrop)
				end
			end
		end, formulaInfo.ripeCrop)
	end
end

-- 初始化园地
function P.init_gardenbed_working(view, Obj, lastTime)
	P.clean_gardenbed_crop_model(view, Obj)
	P.show_gardenbed_working(view, Obj, lastTime or 0)
end

local function show_arrow_loop(i, arrowInfo)
	if P.showArrowFlag ~= arrowInfo.showingArrowFlag then return true end

	local lookPos = arrowInfo.lookWhom
	if type(lookPos) == "number" then
		lookPos = libgame.GetUnitPos(lookPos)
	end
	if lookPos == nil then return true end

	local pos = libgame.GetUnitPos(0)
	if UE.Vector3.Distance(pos, lookPos) > 5 then
		local go = libgame.PlayFx(0, "Common/guide_arrow")[1]
		go.transform.localScale = UE.Vector3(1, 1, 0)
		go.transform:LookAt(lookPos)
	end
end

function P.show_arrow(go, lookWhom)
	P.showArrowFlag = P.showArrowFlag + 1
	if lookWhom then
		libunity.InvokeRepeating(go, 1, 3, show_arrow_loop, {showingArrowFlag = P.showArrowFlag, lookWhom = lookWhom,})
	end
end

function P.show_goal(goalText, taskType)
	if goalText then
		_G.DY_DATA.Goal = { name = goalText, }
	end
	local _wnd = ui.find("FRMExplore")
	local Ref = _wnd and _wnd.Ref
	return _G.PKG["ui/util"].show_goal_view(Ref, taskType)
end

function P.show_limit_area(Area)
	local ViewROOT = ui.find("FRMExplore").ViewROOT
	local limitName = "LimitArea#"..Area.id
	local goLimit = libunity.Find(ViewROOT, limitName)
	if Area.open then
		if goLimit then return end

		local shape = Area.param2 == 0 and "Circle" or "Rect"
		local fxPath = "fx/stage/LimitArea" .. shape .. Area.fx
		libasset.LoadAsync(typeof(UE.GameObject), fxPath, nil, function (a, o, p)
			if o then
				local Vector3 = UE.Vector3
				local go = libgame.AddChild(ViewROOT, o)
				go.name = limitName

				local trans = go.transform
				trans.position = libgame.Local2World(Area.pos)
				if shape == "Circle" then
					for i=1,trans.childCount-1 do
						local obs = trans:GetChild(i):GetComponent("NavMeshObstacle")
						obs.center = Vector3(0, 0, Area.param1 + 0.3)
						obs.size = Vector3(Area.param1, 1, 0.1)
					end
					trans:GetChild(0).localScale = UE.Vector3(Area.param1, Area.param1, 1)
				elseif shape == "Rect" then
					local halfw, halfh = Area.param1 / 2, Area.param2 / 2
					local obs = trans:Find("Wall1"):GetComponent("NavMeshObstacle")
					obs.center = Vector3(0, 0, halfh + 0.3)
					obs.size = Vector3(Area.param1, 1, 0.1)

					obs = trans:Find("Wall2"):GetComponent("NavMeshObstacle")
					obs.center = Vector3(0, 0, halfw + 0.3)
					obs.size = Vector3(Area.param2, 1, 0.1)

					obs = trans:Find("Wall3"):GetComponent("NavMeshObstacle")
					obs.center = Vector3(0, 0, halfh + 0.3)
					obs.size = Vector3(Area.param1, 1, 0.1)

					obs = trans:Find("Wall4"):GetComponent("NavMeshObstacle")
					obs.center = Vector3(0, 0, halfw + 0.3)
					obs.size = Vector3(Area.param2, 1, 0.1)

					trans:GetChild(0).localScale = UE.Vector3(Area.param1, Area.param2, 1)
				end
			end
		end)
	else
		libgame.Recycle(goLimit)
	end
end

return P
