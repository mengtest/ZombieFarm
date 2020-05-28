--
-- @file    ui/main/lc_frmdesign.lua
-- @author  xingweizhen
-- @date    2017-12-12 15:42:04
-- @desc    FRMDesign
--

local self = ui.new()
setfenv(1, self)
self.fullScreen = true

local API = _G.PKG["game/api"]
local BUILD_PREFAB = "~BUILDING~"

local cam_pos_offset = UE.Vector3(-11, 26, -11)
local cam_rot_offset = UE.Vector3(60, 45, 0)

local BUILD = _G.PKG["game/buildapi"]

local BUILDING_TYPE_NAME = {
	[1] = TEXT.Build_Floor,
	[2] = TEXT.Build_Wall,
	[3] = TEXT.Build_Door,
	[4] = TEXT.Build_Window,
}

-- 计算位置最近的建筑位置点
local function axis2center(size, value)
	if size % 4 == 0 then
		-- 占偶数个建筑格子，位置点在格子边缘(1.5, 3.5, 5.5, ...)
		return math.floor((value + 0.5) / 2 + 0.5) * 2 - 0.5
	else
		-- 占奇数个建筑格子，位置点在格子中间(0.5, 2.5, 4.5, ...)
		return math.floor((value - 0.5) / 2 + 0.5) * 2 + 0.5
	end
end

-- 限制在建造范围内
local function clamp_pos_inside(pos, size, angle)
	local change

	local width, height = size.x, size.z
	if angle % 180 ~= 0 then
		width, height = height, width
	end
	local center = Stage.pos2center(pos, size, angle)

	local minx = 1.5 + width / 2
	local maxx = Stage.w - 1 - minx
	if center.x < minx then
		pos.x = pos.x + minx - center.x
		change = true
	elseif center.x > maxx then
		pos.x = pos.x - (center.x - maxx)
		change = true
	end

	local minz = 1.5 + height / 2
	local maxz = Stage.h - 1 - minz
	if center.z < minz then
		pos.z = pos.z + minz - center.z
		change = true
	elseif pos.z > maxz then
		pos.z = pos.z - (center.z - maxz)
		change = true
	end
	return change
end

local function obj_is_wall(Base)
	return Base.mType == "BUILDING" and Base.sType ~= "FLOOR"
end

-- 根据坐标计算建筑物的模型中心位置（墙壁需要特殊处理）
local function calc_obj_pos(Unit, x, y, angle)
	local Tmpl = Unit:get_tmpl_data()
	local size = Tmpl.size

	local pos = UE.Vector3(x, 0, y)
	if size.x ~= size.z then
		local offset
		if size.x > size.z then
			offset = UE.Vector3(0, 0, (size.x - size.z) / 2)
		else
			offset = UE.Vector3((size.z - size.x) / 2, 0, 0)
		end
		pos = pos + UE.Quaternion.Euler(0, angle, 0) * offset
	end

	return libgame.Local2World(pos)
end

local function rfsh_oper_pos(x, y, angle)
	local pos = calc_obj_pos(Selected, x, y, angle)
	libugui.Follow(self.SubOper.go, pos + UE.Vector3(0, 3, 0))
end

local function rfsh_buildtips_pos(x, y, angle)
	local SubTips = Ref.SubTips
	if x then
		if libunity.IsActive(SubTips.go) then
			local pos = calc_obj_pos(Selected, x, y, angle)
			libugui.Follow(SubTips.go, pos + UE.Vector3(0, 1, 0))
		end
	else
		libugui.Follow(SubTips.go, nil)
		libunity.SetActive(SubTips.go, false)
		Ref.SubTips.lbTips.text = nil
	end
end

--相机移动到建筑中心位置
local function cam_move_to_building()
	local toPos = build.transform.position + cam_pos_offset
	libugui.DOTween("PositionW", self.camTrans, nil, toPos, { duration = 1, ease = "OutCubic" })
end

local function rfsh_operbuild_color(color)
	if Selected.id then
		libgame.SetUnitSkin(Selected.id, "BuildHighlight", color)
	else
		libgame.SetUnitSkin(build, "BuildHighlight", color)
		-- local rdrs =  build:GetComponentsInChildren(typeof(UE.Renderer))
		-- for i=0,rdrs.Length-1 do
		-- 	local rdr = rdrs[i]
		-- 	libunity.SetMaterialProperty(rdr, { _Color = color })
		-- end
	end
end

local function put_building(pos, centerPos)
	local prePos = self.buildPos
	if build == nil then self.buildPos = pos return end

	local Vector3 = UE.Vector3
	local BuildBase = Selected:get_base_data()
	local isWall = obj_is_wall(BuildBase)
	local BuildTmpl = Selected:get_tmpl_data()
	local size = table.dup(BuildTmpl.size)
	local angle = build.transform.localEulerAngles.y

	local x, y, xw, yw
	if isWall then
		-- 墙壁特殊处理
		pos.x = math.clamp(pos.x, 2, Stage.w - 3)
		pos.z = math.clamp(pos.z, 2, Stage.h - 3)
		local x1, z1 = axis2center(0, pos.x), axis2center(size.z, pos.z)
		local x2, z2 = axis2center(size.z, pos.x), axis2center(0, pos.z)
		local d1 = Vector3.Distance(pos, Vector3(x1, 0, z1))
		local d2 = Vector3.Distance(pos, Vector3(x2, 0, z2))
		if d1 < d2 then
			if pos.x < x1 then
				x, y, angle = x1 - 1, z1, 0
				xw, yw = x + 2, y
			else
				x, y, angle = x1 + 1, z1, 180
				xw, yw = x - 2, y
			end
		else
			if pos.z < z2 then
				x, y, angle = x2, z2 - 1, 270
				xw, yw = x, y + 2
			else
				x, y, angle = x2, z2 + 1, 90
				xw, yw = x, y - 2
			end
		end
	else
		angle = angle % 360
		local offset = (size.x - size.z) / 2
		if angle == 0 then
			pos.x = pos.x + offset
		elseif angle == 90 then
			pos.z = pos.z - offset
		elseif angle == 180 then
			pos.x = pos.x - offset
		elseif angle == 270 then
			pos.z = pos.z + offset
		end

		clamp_pos_inside(pos, size, angle)
		local side = math.max(size.x, size.z)
		x, y = axis2center(side, pos.x), axis2center(side, pos.z)
	end

	if x > 1 and x < buildW + 2 and y > 1 and y < buildH + 2 then

		local buildErrInfo

		-- 判断当前位置是否能建造
		local err, ret
		if BuildBase.base == 0 then
			err, ret = Stage:chk_empty_ground(x, y, 1, size, 0, angle, Selected.id)
			-- 如果该位置有地板，则不显示该地板
			if BuildBase.buildingType == 1 then
				if Stage:has_floor(x, y) then
					-- 回滚到之前位置，并且建造按钮可点击
					self.buildPos = prePos
					ret = true

					buildErrInfo = BUILDING_TYPE_NAME[BuildBase.buildingType]
				end
			end

		elseif isWall then
			-- 墙壁处理
			ret = (Stage:has_floor(x, y) or Stage:has_floor(xw, yw))
				and Stage:has_gap(x, y, xw, yw)

			-- 获取该位置已有的门、窗、墙
			local orgWall = Stage:has_wall(x, y, xw, yw)
			if orgWall then
				local orgBase = orgWall:get_base_data()

				-- 回滚到之前位置，并且建造按钮可点击
				ret = true
				self.buildPos = prePos

				buildErrInfo = BUILDING_TYPE_NAME[orgBase.buildingType]
				-- if Selected.dat == orgBase.id then
				-- 	buildErrInfo = BUILDING_TYPE_NAME[BuildBase.buildingType]
				-- end
			end

			if ret == nil then err = -4 end
		else
			err, ret = Stage:chk_empty_floor(x, y, 1, size, BuildBase.base, angle, Selected.id)
		end

		if buildErrInfo then
			buildErrInfo = TEXT.Build_Exist:csfmt(buildErrInfo)
			UI.Toast.norm(buildErrInfo)
			return ret
		else

			self.coord = { x = x, y = y, angle = angle }
			local worldPos = libgame.Local2World(Vector3(x, 0, y))
			worldPos.y = worldPos.y + 0.01

			build.transform.position = worldPos
			build.transform.localEulerAngles = Vector3(0, angle, 0)

			self.Oper.show_panel()

			-- 控制摄像机位置
			local _, inside = libugui.InsideScreen(self.SubOper.go, Ref.ElmCenter, false)
			if not inside then cam_move_to_building() end
		end

		if Selected.id == nil then
			if ret then
				-- 新建建筑：检查修建上限
				if self.buildingLimited then
					err, ret = -5, nil
				-- 新建建筑：检查当前等级是否可建造
				elseif self.buildingLevelLimited then
					err, ret = -6, nil
				else
					-- 如果是新建，最后还需要检查材料
					for _,v in ipairs(BuildBase.Mats) do
                        if v.amount > get_item_amount(v.id) then
							err, ret = -99, nil
						end
					end
				end
			end
		else
			if Selected.coord.x == coord.x and Selected.coord.z == coord.y and Selected.angle == coord.angle then
				-- 位置和旋转无变化
				ret = true
			end
		end

		rfsh_operbuild_color(ret and "#00FF0080" or "#FF000080")

		if err then
			local errTips
			if err < 0 then
				errTips = TEXT.BuildPosError[err]

			elseif err == 0 then
				errTips = TEXT.tipReqEmptyGround
			else
				errTips = string.format(TEXT.fmtReqEmptyFloor, err)
			end
			Ref.SubTips.lbTips.text = errTips
			libunity.SetActive(Ref.SubTips.go, true)
			rfsh_buildtips_pos(coord.x, coord.y, coord.angle)
		else
			rfsh_buildtips_pos(nil)
		end

		return ret ~= nil
	end
end
self.put_building = put_building

local function find_build_pos(center, checker, size, base, obj)
	local side = math.max(size.x, size.z)
	local x, y = axis2center(side, center.x), axis2center(side, center.z)
	local function check_grid(ox, oy, d)
		local bx, by = x + ox, y + oy
		if bx > 2 and bx < buildW + 1 and by > 2 and  by < buildH + 1 then
			local err, ret = checker(Stage, bx, by, d, size, base, obj)
			if ret then return ret end
		end
	end
	-- 先检测当前位置
	local ret = check_grid(0, 0, 1)
	if ret then return ret end

	-- 十字形查找位置（最多查找5圈）
	for n=2,10,2 do
		-- 1、四个方向
		ret = check_grid(0, n, 2) or check_grid(n, 0, 4) or check_grid(0, -n, 8) or check_grid(-n, 0, 6)
		if ret then return ret end

		-- 2、偏移位置
		for i=2,n-2,2 do
			ret = check_grid(-i, n, 2) or check_grid(i, n, 2)
			   or check_grid(n, -i, 4) or check_grid(n, i, 4)
			   or check_grid(i, -n, 8) or check_grid(-i, -n, 8)
			   or check_grid(-n, -i, 6) or check_grid(-n, i, 6)
			if ret then return ret end
		end

		-- 2、对角位置
		ret = check_grid(-n, -n, 9) or check_grid(-n, n, 3) or check_grid(n, n, 1) or check_grid(n, -n, 7)
		if ret then return ret end
	end

	return center
end

local function auto_put_building()
	if Selected == nil then return end

	local hitPos = libunity.Raycast(nil, Ref.ElmCenter, 100, GROUND_LAYER)
	local centerPos = libgame.World2Local(hitPos)
	if self.buildPos == nil then
		local pos = centerPos
		local prevPos = coord and UE.Vector3(coord.x, 0, coord.y)

		local BuildBase = Selected:get_base_data()
		local BuildTmpl = Selected:get_tmpl_data()
		local size = table.dup(BuildTmpl.size)
		if BuildBase.base == 0 then
			-- 需要建造空地上的物件
			-- if prevPos and BuildBase.sType == "FLOOR" then pos = prevPos end
			pos = find_build_pos(pos, Stage.chk_empty_ground, size, Selected.id)
		elseif obj_is_wall(BuildBase) then
			-- 墙壁，需要建在地板的边缘
			pos = find_build_pos(prevPos or pos, Stage.chk_pos4wall, size)
		else
			-- 需要建造在地板上的物件
			pos = find_build_pos(pos, Stage.chk_empty_floor, size, BuildBase.base, Selected.id)
		end
		self.buildPos = pos
	end

	local ret = put_building(self.buildPos, centerPos)
	self.buildPos = nil
	self.SubOper.btnConfirm.interactable = ret
end

local function on_model_loaded(a, o, p)
	if self.nowLoading ~= p then return end
	self.nowLoading = nil
	if Selected == nil then return end

	libunity.Destroy(GO(self.stageRoot, BUILD_PREFAB))
	self.build = libunity.NewChild(self.stageRoot, o, BUILD_PREFAB)
	if build then
		libgame.SetUnitSkin(build, "BuildHighlight", "#00FF0080")
		-- local rdrs = build:GetComponentsInChildren(typeof(UE.Renderer))
		-- local mat = libasset.Get("game/SharedObjs", "BuildHighlight")
		-- for i=0,rdrs.Length-1 do
		-- 	rdrs[i].sharedMaterial = mat
		-- end
	end

	auto_put_building()
end

local function auto_build_obj()
	libunity.Destroy(GO(self.stageRoot, BUILD_PREFAB))
	self.build = nil

	local tmpl = Selected:get_tmpl_data()
	Selected.randomModelIndex = math.random(1, #tmpl.modelGroup)
	local loadingModel = tmpl.modelGroup[Selected.randomModelIndex]
	self.nowLoading = loadingModel
	libgame.LoadModelView(loadingModel, on_model_loaded)
end

local function load_builded_fx(IDs)
	for _,v in pairs(IDs) do
		local Obj = CTRL.get_obj(v.id)
		local BuildTmpl = Obj:get_tmpl_data()
		libgame.PlayFx(0, BuildTmpl.bornFx, v.id)
	end
end

local function cancel_build_mode()
	libunity.Destroy(GO(self.stageRoot, BUILD_PREFAB))
	self.build = nil
	self.buildingLimited = nil
	self.buildingLevelLimited = nil

	libugui.Follow(self.SubOper.go, nil)
	libugui.SetVisible(self.SubOper.go, false)
	libugui.SetVisible(Ref.SubInfo.go, false)

	self.selectedIdx = nil
	libugui.SetVisible(self.spSelected, false)
end

local function cancel_adjust_mode()
	if build then
		local pos, angle = libgame.GetUnitPos(Selected.id)
		if pos and angle then
			build.transform.position = pos
			build.transform.localEulerAngles = UE.Vector3(0, angle, 0)
		end

		build.gameObject.tag = "Untagged"
		libgame.SetUnitSkin(self.Selected.id)
	end

	self.build = nil
	self.Selected = nil
	libugui.Follow(self.SubOper.go, nil)
	libugui.SetVisible(self.SubOper.go, false)
	libugui.SetVisible(Ref.SubInfo.go, false)
end

local function send_building(op)
	-- 如果是移动模式，要判断位置是否发生了变化
	if self.Oper == OperModes.moving then
		local selcoord = Selected.coord
		if coord.x == selcoord.x and coord.y == selcoord.z then
			cancel_mode()
			rfsh_buildtips_pos(nil)
		return end
	end

	local LENGTH_MUL = _G.CVar.LENGTH_MUL
	local BuildBase = Selected:get_base_data()
	local BuildTmpl = Selected:get_tmpl_data()

	if NW.connected() then
		local nm = NW.msg("BUILD.CS.BUILDING")
		if Selected.id then
			-- 旋转或移动
			nm:writeU32(Selected.id):writeU32(Selected.dat):writeU32(op or 1)
			self.WaitRes = {}
		else
			-- 建造
			nm:writeU32(0):writeU32(Selected.dat):writeU32(op or 0)
			self.WaitRes = { item = true, obj = true, }
		end
		nm:writeU32(Selected.randomModelIndex)

		nm:writeU32(coord.x * LENGTH_MUL):writeU32(coord.y * LENGTH_MUL):writeU32(coord.angle)
		NW.send(nm)
	else
		self.WaitRes = {}
		next_action(Ref.go, function ()
			if Selected.id then
				Selected.coord.x, Selected.coord.z, Selected.angle = coord.x, coord.y, coord.angle
				libgame.SetUnitCoord(Selected.id, Selected.coord, Selected.angle)
				NW.broadcast("BUILD.SC.BUILDING", {})
			else
				local Obj = Stage:build_obj(Selected.dat, coord.x, coord.y, coord.angle)
				if #BuildTmpl.modelGroup > 1 then
					Obj.randomModelIndex = Selected.randomModelIndex
				end
				CTRL.create(Obj)
				NW.broadcast("BUILD.SC.BUILDING", {})
				NW.broadcast("MAP.SC.SYNC_OBJ_ADD_JOIN", { Obj })
			end
		end)
	end
end

local function show_build_info(buildId)
	local UnitLIB = config("unitlib")
	local SubInfo = Ref.SubInfo
	libugui.SetVisible(SubInfo.go, true)

	local opName = buildId and TEXT.BuildOp.nameUpgrade or TEXT.BuildOp.nameBuild

	local Data = buildId and UnitLIB.get_dat(buildId) or Selected:get_base_data()

	SubInfo.GrpMats:dup(#Data.Mats, function (i, Ent, isNew)
		local Mat = Data.Mats[i]
		ItemDEF.gen(Mat):show_view(Ent)
		Ent.lbAmount.text = Stage.home and string.own_needs(get_item_amount(Mat.id), Mat.amount) or Mat.amount
	end)

	ui.seticon(SubInfo.spIcon, Data.icon)
	SubInfo.lbOper.text = string.format("%s%s%s", opName, TEXT[":"], cfgname(Data))
	SubInfo.lbIntro.text = Data.desc

	if Data.base ~= 0 then
		local Floor = UnitLIB.get_floor_data(Data.base)
		if Floor then
			SubInfo.lbRequire.text = string.format(TEXT.fmtRequireFloor, Floor.name, Floor.level)
		else
			SubInfo.lbRequire.text = TEXT.unknownFloorLevel
		end
	else
		SubInfo.lbRequire.text = ""
	end

	local Stage = DY_DATA:get_stage()
	local playerLevel = DY_DATA:get_player().level

	self.buildingLevelLimited = playerLevel < Data.reqPlayerLevel

	if self.Oper == OperModes.adjust then
		if Data.reqPlayerLevel > 0 and Data.upgradeId > 0 then
			SubInfo.lbTips.text = Stage.home and string.format(
				TEXT.fmtBuildingUpgradeLimit, Data.reqPlayerLevel)
		else
			SubInfo.lbTips.text = nil
		end
	else
		if Data.group > 0 then
			local nBuilt = Stage:count_building_group(Data.group)
			local GrpData = UnitLIB.get_build_group(Data.group)
			local nLevel, nAmount = GrpData.Step.level, GrpData.Step.amount
			local totalBuild = GrpData.nBuild
			local color, limitText = "#00FF00", ""
			if nLevel > 0 and nAmount > 0 then
				local nStep = math.floor((playerLevel - 1) / nLevel)
				totalBuild = totalBuild + nStep * nAmount
				local nextLevel = 1 + (nStep + 1) * nLevel
				local maxPlayerLevel = config("levellib").get_maxn()
				if maxPlayerLevel >= nextLevel then
					limitText = string.format(TEXT.fmtBuildingGroupNextLimit,
						nextLevel, totalBuild + nAmount)
					if limited then color = "orange" end
				else
					if limited then color = "#FF0000" end
				end
			else
				if limited then color = "#FF0000" end
			end
			local limited = Selected.id == nil and nBuilt >= totalBuild
			self.buildingLimited = limited

			nBuilt = string.color(tostring(nBuilt), color)

			SubInfo.lbTips.text = Stage.home and string.format(
				TEXT.fmtBuildingGroupLimit, GrpData.name, nBuilt, totalBuild)
				.. "\n" .. limitText or nil
		else
			self.buildingLimited = nil
			SubInfo.lbTips.text = nil
		end
	end
end

-- ============================================================================
-- 建造模式操作方法
-- ============================================================================
local BuildingMode = {
	show_panel = function ()
		local SubOper = self.SubOper
		libugui.SetVisible(SubOper.go, true)

		local BuildBase = Selected:get_base_data()

		libunity.SetActive(SubOper.btnCancel, true)
		libunity.SetActive(SubOper.btnRemove, false)
		libunity.SetActive(SubOper.btnMove, false)
		libunity.SetActive(SubOper.btnRotate, BuildBase.rotType > 0)
		libunity.SetActive(SubOper.SubUpgrade.go, false)
		libunity.SetActive(SubOper.btnRepair, false)
		libunity.SetActive(SubOper.btnConfirm, true)

		rfsh_oper_pos(coord.x, coord.y, coord.angle)
	end,
	on_click = function (screenPos)
		-- Layer = 8(Groud)
		local hitPos = libunity.Raycast(nil, screenPos, 100, GROUND_LAYER)
		local ret = put_building(libgame.World2Local(hitPos))
		self.SubOper.btnConfirm.interactable = ret
	end,
	do_confirm = send_building,
	do_cancel = cancel_build_mode,

	on_success = function() end,
	on_exit = cancel_build_mode,
}
BuildingMode.__index = BuildingMode

-- ============================================================================
-- 调整模式操作方法
-- ============================================================================
local AdjustMode = {
	show_panel = function ()
		build.gameObject.tag = "AlwaysView"
		libgame.SetUnitSkin(Selected.id, "BuildHighlight", "#00FF0080")

		local SubOper = self.SubOper
		libugui.SetVisible(SubOper.go, true)

		local BuildBase = Selected:get_base_data()
		libunity.SetActive(SubOper.btnCancel, true)
		libunity.SetActive(SubOper.btnRemove, BuildBase.worth >= 0)
		libunity.SetActive(SubOper.btnMove, BuildBase.moveType > 0)
		libunity.SetActive(SubOper.btnRotate, BuildBase.rotType > 0)
		libunity.SetActive(SubOper.SubUpgrade.go, BuildBase.upgradeId > 0 and BuildBase.method ~= "Transform")
		libunity.SetActive(SubOper.btnRepair, BuildBase.Repair ~= nil)
		libunity.SetActive(SubOper.btnConfirm, false)

		if BuildBase.Repair then
			local value, limit = libgame.GetUnitHealth(Selected.id)
			if value and limit then
				libugui.SetInteractable(SubOper.btnRepair, value < limit)
			else
				libugui.SetInteractable(SubOper.btnRepair, false)
			end
		end

		if BuildBase.upgradeId > 0 then
			show_build_info(BuildBase.upgradeId)
		else
			libugui.SetVisible(Ref.SubInfo.go, false)
		end

		rfsh_oper_pos(coord.x, coord.y, coord.angle)
	end,
	on_click = function (screenPos)
		local _, hitObj = libunity.Raycast(nil, screenPos, 100, self.buildLayer)
		if hitObj then
			local preBuild = build
			local obj, objBuild = libgame.GetObjOfView(hitObj)
			if obj then
				local Obj = CTRL.get_obj(obj)
				if Obj then
					if Obj:get_base_data().showType ~= self.buildType then
						return
					end
				end
				if preBuild then preBuild.gameObject.tag = "Untagged" end
				if self.Selected then libgame.SetUnitSkin(self.Selected.id) end

				objBuild.gameObject.tag = "AlwaysView"
				libgame.SetUnitSkin(obj, "BuildHighlight", "#00FF0080")

				self.Selected = Stage:find_unit(obj)
				self.build = objBuild
				self.coord = { x = Selected.coord.x, y = Selected.coord.z, angle = Selected.angle }
				self.Oper.show_panel()
			end
		end
	end,
	on_success = function ()
		libunity.SendMessage(self.stageRoot, "SetNavMeshDirty", self.build)
		self.Oper.show_panel()
	end,
	do_confirm = cancel_adjust_mode,
	do_cancel = cancel_adjust_mode,
	on_exit = cancel_adjust_mode,
}

-- ============================================================================
-- 移动模式操作方法
-- ============================================================================
local MovingMode = setmetatable({
	show_panel = function ()
		cam_move_to_building()

		local SubOper = self.SubOper
		libugui.SetVisible(SubOper.go, true)

		local BuildBase = Selected:get_base_data()
		libunity.SetActive(SubOper.btnCancel, true)
		libunity.SetActive(SubOper.btnRemove, false)
		libunity.SetActive(SubOper.btnMove, false)
		libunity.SetActive(SubOper.btnRotate, false)
		libunity.SetActive(SubOper.SubUpgrade.go, false)
		libunity.SetActive(SubOper.btnRepair, false)
		libunity.SetActive(SubOper.btnConfirm, true)
		SubOper.btnConfirm.interactable = true
		rfsh_oper_pos(coord.x, coord.y, coord.angle)
	end,
	do_confirm = send_building,
	do_cancel = cancel_adjust_mode,

	on_success = function ()
		libunity.SendMessage(self.stageRoot, "SetNavMeshDirty", self.build)
		--直接关闭
		cancel_adjust_mode()
		self.Oper = nil
	end,
	on_exit = cancel_adjust_mode,
}, BuildingMode)

OperModes = {
	building = BuildingMode,
	adjust = AdjustMode,
	moving = MovingMode,
}

function cancel_mode()
	if self.Oper then
		self.Oper.do_cancel()
		self.Oper = nil
	end
	self.Selected = nil
end

function leave_mode()
	if self.Oper then
		self.Oper.on_exit()
		self.Oper = nil
	end
	self.Selected = nil
	rfsh_buildtips_pos(nil)
end

function enter_mode(mode, Data)
	local NewMode = OperModes[mode]
	if self.Oper ~= NewMode then
		cancel_mode()
	end
	self.Selected = Data
	self.Oper = NewMode
	self.coord = nil

	libugui.SetVisible(Ref.SubInfo.go, false)
end

local function draw_design_lines()
	local Local2World = libgame.Local2World
	local DrawLine3D = libugui.DrawLine3D
	local Vector3 = UE.Vector3

	local go = libgame.AddChild(nil, "Game/GRID")
	local gridTrans = libunity.Find(go, "Mesh").transform
	gridTrans.position = Local2World(Vector3(Stage.w / 2 - 0.5, 0, Stage.h / 2 - 0.5))
	gridTrans.localScale = Vector3(buildW, buildH)
	local rdr = gridTrans:GetComponent("Renderer")
	rdr.material.mainTextureScale = UE.Vector2(buildW / 2, buildH / 2)
end

local function show_building_list()
	libugui.SetLoopCap(Ref.SubScroll.SubView.GrpItems.go, #Items, true)
end

local function leave_building_tab()
	if self.selectedIdx then
		self.selectedIdx = nil
		libugui.SetVisible(self.spSelected, true)
	end
end

local function switch_building_list()
	libugui.SetVisible(Ref.SubInfo.go, false)
	if self.Items then
		leave_mode()
		show_building_list()
	end
end

local function items_filter()
	if self.buildType == nil then
		return
	end
	self.Buildings, self.Furnitures = config("unitlib").gen_building_list(100)
	local itemsList = {}
	if self.buildType == 1 then
		for _,v in pairs(self.Buildings) do
			if v.showType == self.buildType then
				table.insert(itemsList, v)
			end
		end
	else
		for _,v in pairs(self.Furnitures) do
			if v.showType == self.buildType then
				table.insert(itemsList, v)
			end
		end
	end
	return itemsList
end

local function rfsh_building_list()
	items_filter()
	show_building_list()

	if self.Oper == OperModes.building then
		show_build_info()
	end
end

local function obj_view_loaded(obj)
	local Obj = CTRL.get_obj(obj)
	if Obj then
		local ObjBase = Obj:get_base_data()
		local objLayer = MType2Layer[ObjBase.mType]
		--只处理MType2Layer中包含的Type
		if objLayer then
			local view = libgame.GetViewOfObj(obj)
			if self.buildType == ObjBase.showType then
				--当前选中的Type为正常材质球
				libunity.SetActive(GO(view, "Model/Normal"), true)
				libunity.SetActive(GO(view, "Model/BlankModel"), false)
				libgame.SetUnitSkin(obj)
			else
				--当前未选中的Type为高亮材质球
				libunity.SetActive(GO(view, "Model/Normal"), false)
				libunity.SetActive(GO(view, "Model/BlankModel"), true)
				libgame.SetUnitSkin(obj, "BuildHighlight", "#00FFFF80")

				local rdr = libunity.Find(view, "Model/BlankModel", "Renderer")
				libunity.SetMaterialProperty(rdr, { _Color = "#00FFFF80" })
			end
		end
	end
end

local function obj_view_unloaded(obj)
	local Obj = CTRL.get_obj(obj)
	if Obj then
		local ObjBase = Obj:get_base_data()
		local objLayer = MType2Layer[ObjBase.mType]
		--只处理MType2Layer中包含的Type
		if objLayer then
			local view = libgame.GetViewOfObj(obj)
			libunity.SetActive(GO(view, "Model/Normal"), true)
			libunity.SetActive(GO(view, "Model/BlankModel"), false)
			libgame.SetUnitSkin(obj)
		end
	end
end

local function rfsh_building_hpbar(obj)
	local function need_hpbar_for(obj)
		local value, limit = libgame.GetUnitHealth(obj)
		if value and value < limit then
			local barName = "HPBar#" .. obj
			local Sub, isNew = API.need_hud_elm(barName, "HealthBar")
			if isNew then
				self.HPBars[obj] = barName
				local view = libgame.GetViewOfObj(obj)
				libugui.Follow(Sub.bar, GO(view, "HUD"))
			end
			Sub.bar.value = value / limit
		end
	end

	if obj == nil then
		for _,v in pairs(Stage.Walls) do
			need_hpbar_for(v.id)
		end
		for _,v in pairs(Stage:get_furniture_list()) do
			need_hpbar_for(v.id)
		end
	else
		need_hpbar_for(obj)
	end
end

local function obj_health_changed(obj, Inf)
	local hurt = Inf.value < Inf.limit
	if hurt or Inf.change > 0 then
		local Obj = CTRL.get_obj(obj)
		if Obj == nil then return end

		local ObjBase = Obj:get_base_data()
		if ObjBase.building then
			local barName = "HPBar#" .. obj
			if hurt then
				rfsh_building_hpbar(obj)
			else
				self.HPBars[obj] = nil
				API.del_hud_elm(barName, 0.3)
			end
		end
	end
end


local function init_buildtype_tglgrp()
	local buildTypeList = config("unitlib").get_buildtype_list()
	local GrpTabs = Ref.GrpTabs
	for i,v in pairs(buildTypeList) do
		local Ent, isNew = GrpTabs:gen(i)
		Ent.lbBuildType.text = v.name
		Ent.SubCheck.lbBuildType.text = v.name
		libunity.SetActive(Ent.lbGroup, false)
		if i==1 then
			DY_DATA.RedSystem:BuildRedDotUI(CVar.RedDotName.BuildHouse,Ent.lbBuildType)
		elseif i==2 then
			DY_DATA.RedSystem:BuildRedDotUI(CVar.RedDotName.BuildDevice,Ent.lbBuildType)
		elseif i==3 then
			DY_DATA.RedSystem:BuildRedDotUI(CVar.RedDotName.BuildFurniture,Ent.lbBuildType)
		elseif i== 4 then
			DY_DATA.RedSystem:BuildRedDotUI(CVar.RedDotName.BuildSpecial,Ent.lbBuildType)
		end
	end
end

local function try_next_build(tag)
	if self.WaitRes == nil then return end

	self.WaitRes[tag] = nil
	if table.void(self.WaitRes) then
		self.WaitRes = nil
		if self.Oper == OperModes.building then
			next_action(Ref.go, auto_build_obj)
		end
		if self.Selected then
			next_action(Ref.go, show_build_info)
		end
	end
end

--!* [开始] 自动生成函数 *--

function on_spdrag_ptrdown(evt, data)
	self.dragging = nil
end

function on_spdrag_begindrag(evt, data)
	self.dragging = true
	libugui.KillTween(self.camTrans)
end

function on_spdrag_drag(evt, data)
	if Stage.home then
		local delta = data.delta
		local offset = camRot * UE.Vector3(delta.x, 0, delta.y)
		local camPos = self.camTrans.position - offset / 50
		if camPos.x < minPos.x then camPos.x = minPos.x end
		if camPos.x > maxPos.x then camPos.x = maxPos.x end
		if camPos.z < minPos.z then camPos.z = minPos.z end
		if camPos.z > maxPos.z then camPos.z = maxPos.z end

		self.camTrans.position = camPos
	end
end

function on_spdrag_click(evt, data)
	if not self.dragging then
		local screenPos = data.position

		if self.Oper == nil then
			-- Layer = 10(Building)
			local _, hitObj = libunity.Raycast(nil, screenPos, 100, self.buildLayer)
			if hitObj then
				local obj, objBuild = libgame.GetObjOfView(hitObj)
				if obj then
					local buildUnit = Stage:find_unit(obj)
					--销毁建筑，建筑是渐隐消失。此时建筑的碰撞盒还在,但是stage中已无此建筑信息
					if buildUnit == nil then
						return
					end

					if buildUnit:get_base_data().showType ~= self.buildType then
						return
					end

					enter_mode("adjust", buildUnit)
					self.coord = { x = Selected.coord.x, y = Selected.coord.z, angle = Selected.angle }
					self.build = objBuild
					self.Oper.show_panel()
				end
			end
		else
			self.Oper.on_click(screenPos)
		end

	end
end

function on_suboper_btncancel_click(btn)
	cancel_mode()
	rfsh_buildtips_pos(nil)
end

function on_suboper_btnremove_click(btn)
	local SelectedBase = Selected:get_base_data()
	local function send_destroy()
		NW.send(NW.msg("BUILD.CS.DESTORY"):writeU32(Selected.id))
	end

	if SelectedBase.worth == 0 then
		send_destroy()
	else
		if SelectedBase.worth == 1 then
			UI.MBox.operate("DeleteBuilding", send_destroy ,{
				txtConfirm = TEXT.delete,
				confirmStyle = "Red",
			})
		else
			UI.MBox.operate("DeleteBuilding", function ()
				--二次确认
				UI.MBox.operate("DeleteBuildingAskAgain", send_destroy , {
					txtConfirm = TEXT.delete,
					show_close_button = true,
					single = true,
					confirmStyle = "Red",
				}) end, {
				txtConfirm = TEXT.delete,
				confirmStyle = "Red",
			})
		end

	end
end

function on_suboper_btnmove_click(btn)
	local coord = self.Selected.coord
	self.coord = { x = coord.x, y = coord.z, angle = self.Selected.angle }
	-- 进入移动模式
	self.Oper = MovingMode
	self.Oper.show_panel()
end

function on_suboper_btnrotate_click(btn)
	local BuildBase = Selected:get_base_data()

	local rotType = BuildBase.rotType
	local addAngle
	if rotType == 1 then
		-- 180度反转
		addAngle = 180
	elseif rotType == 2 then
		-- 90度
		addAngle = 90
	end
	local isWall = obj_is_wall(BuildBase)
	if addAngle then
		local newAngle = coord.angle + addAngle
		if newAngle >= 360 then newAngle = newAngle - 360 end

		if isWall then
			if coord.angle == 0 then
				coord.x = coord.x + 2
			elseif coord.angle == 90 then
				coord.y = coord.y - 2
			elseif coord.angle == 180 then
				coord.x = coord.x - 2
			else
				coord.y = coord.y + 2
			end
			build.transform.position = libgame.Local2World(UE.Vector3(coord.x, 0, coord.y))
		elseif addAngle == 90 then
			local pos = UE.Vector3(coord.x, 0, coord.y)
			local size = table.dup(Selected:get_tmpl_data().size)
			if clamp_pos_inside(pos, size, newAngle) then
				build.transform.position = libgame.Local2World(pos)
				coord.x, coord.y = pos.x, pos.z
			end
		end

		local err
		if Selected.id then
			local size = Selected:get_tmpl_data().size
			if BuildBase.base == 0 then
				err = Stage:chk_empty_ground(coord.x, coord.y, 1, size, 0, newAngle, Selected.id)
			elseif isWall then

			else
				err = Stage:chk_empty_floor(coord.x, coord.y, 1, size, BuildBase.base, newAngle, Selected.id)
			end
		end

		coord.angle = newAngle
		--libugui.DOTween("EulerAngles", build, nil, UE.Vector3(0, newAngle, 0), { duration = 0.3 })
		build.transform.localEulerAngles = UE.Vector3(0, newAngle, 0)

		rfsh_oper_pos(coord.x, coord.y, coord.angle)
		rfsh_buildtips_pos(coord.x, coord.y, coord.angle)

		if Selected.id then
			rfsh_operbuild_color(err and "#FF000080" or  "#00FF0080" )
			if err == nil then
				if Selected.id then send_building(2) end
			else
				local errTips
				if err < 0 then
					errTips = TEXT.BuildPosError[-1]
				elseif err == 0 then
					errTips = TEXT.tipReqEmptyGround
				else
					errTips = string.format(TEXT.fmtReqEmptyFloor, err)
				end
				UI.Toast.norm(errTips)
			end
		end
	end
end

function on_suboper_subupgrade_click(btn)
	if NW.connected() then
		NW.send(NW.msg("BUILD.CS.OPERATION"):writeU32(Selected.id):writeU32(1))
	else
		NW.broadcast("BUILD.SC.OPERATION", {})

		Stage:del_unit(Selected.id)
		libgame.DeleteObj(Selected.id, 1.5)
		NW.broadcast("MAP.SC.SYNC_OBJ_REMOVE", { Selected.id })

		local upgradeId = Selected:get_base_data().upgradeId
		local Obj = Stage:build_obj(upgradeId, Selected.coord.x, Selected.coord.z, Selected.angle)
		CTRL.create(Obj)
		NW.broadcast("MAP.SC.SYNC_OBJ_ADD_JOIN", { Obj })
	end
end

function on_suboper_btnrepair_click(btn)
	if Selected.id then
		local Repair = Selected:get_base_data().Repair
		if Repair then
			local value, limit = libgame.GetUnitHealth(Selected.id)
			local rate = (limit - value) / limit
			local Mats = {}
			for i,v in ipairs(Repair) do
				table.insert(Mats, ItemDEF.new(v.id, math.ceil(v.amount * rate)))
			end
			local RepairBuilding = TEXT.AskOperation.RepairBuilding
			UI.MBox.make("MBItemSubmit")
				:set_param("title", RepairBuilding.title)
				:set_param("tips", RepairBuilding.tips)
				:set_param("Items", Mats)
				:set_event(function ()
					NW.send(NW.msg("BUILD.CS.REPAIR"):writeU32(Selected.id))
				end)
				:show()
		end
	end
end

function on_suboper_btnconfirm_click(btn)
	if self.Oper then
		self.SubOper.btnConfirm.interactable = false
		self.Oper.do_confirm()
	end
end

function on_subinfo_grpmats_entmat_click(evt, data)
	local BuildBase = Selected:get_base_data()
	if self.Oper == OperModes.adjust then
		BuildBase = config("unitlib").get_dat(BuildBase.upgradeId)
	end

	local Mat = ItemDEF.gen(BuildBase.Mats[ui.index(evt)])
	Mat:show_tip(evt)
end

function on_subinfo_grpmats_entmat_deselect(evt, data)
	ItemDEF.hide_tip()
end

function on_tglroof_click(tgl)

end

function on_tglbusy_click(tgl)

end

function on_grptabs_entbuildtype_click(tgl)
	libugui.SetVisible(GO(tgl, "lbBuildType"), not tgl.value)
	if tgl.value then
		local index = ui.index(tgl)
		local buildTypeData = config("unitlib").get_buildtype(index)

		leave_building_tab()
		self.buildLayer = MType2Layer[buildTypeData.mType]
		self.buildType = buildTypeData.id

		self.Items = items_filter()
		switch_building_list()

		if self.buildType == 1 then
			for _,v in pairs(Stage.Floors) do
				libgame.SetUnitSkin(v.id)
			end
			for _,v in pairs(Stage.Walls) do
				local view = libgame.GetViewOfObj(v.id)
				libunity.SetActive(GO(view, "Model/Normal"), true)
				libunity.SetActive(GO(view, "Model/BlankModel"), false)
				libgame.SetUnitSkin(v.id)
			end
			for _,v in pairs(Stage:get_furniture_list()) do
				libgame.SetUnitSkin(v.id, "BuildHighlight", "#00FFFF80")
			end
		else

			for _,v in pairs(Stage.Floors) do
				libgame.SetUnitSkin(v.id, "BuildHighlight", "#00FFFF80")
			end
			for _,v in pairs(Stage.Walls) do
				local view = libgame.GetViewOfObj(v.id)
				libunity.SetActive(GO(view, "Model/Normal"), false)
				libunity.SetActive(GO(view, "Model/BlankModel"), true)
				libgame.SetUnitSkin(v.id, "BuildHighlight", "#00FFFF80")

				-- local rdr = libunity.Find(view, "Model/BlankModel", "Renderer")
				-- libunity.SetMaterialProperty(rdr, { _Color = "#00FFFF80" })
			end
			for _,v in pairs(Stage:get_furniture_list()) do
				if v:get_base_data().showType == self.buildType then
					libgame.SetUnitSkin(v.id)
				else
					libgame.SetUnitSkin(v.id, "BuildHighlight", "#00FFFF80")
				end
			end
		end
	end
end

function rfsh_building_ent(go, i)
	local index = i + 1
	ui.index(go, index)


	local Data = Items[index]
	local Ent = ui.ref(go)
	ui.seticon(Ent.spIcon, Data.icon)

	local Player = DY_DATA:get_player()
	local bLimited = Player.level < Data.reqPlayerLevel
	libunity.SetActive(Ent.SubLimited.go, bLimited)
 	-- local namePos = bLimited and UE.Vector3(0, 30, 0) or UE.Vector3(0, 0, 0)
	-- libugui.SetAnchoredPos(Ent.lbName, namePos)
	--yexin
	Ent.lbName.text = Data.name
	--libugui.SetInteractable(go,not Stage.home or not bLimited)
	Ent.SubLimited.lbLimited.text = bLimited and TEXT.fmtLevelReq:csfmt(Data.reqPlayerLevel)

	if self.selectedIdx == index then
		libugui.SetVisible(self.spSelected, true)
		libunity.SetParent(self.spSelected, go, false, 1)
	else
		libugui.SetVisible(Ent.spSelected, false)
	end

	local build_state = BUILD.load(Data.id)

	if bLimited then
		if build_state then
			CRAFT.save(Data.id,nil)

			DY_DATA:get_player():check_newbuild_state()
		end
		libunity.SetActive(Ent.spRedPoint, false)
	else
		libunity.SetActive(Ent.spRedPoint, build_state ~= nil)
	end

end

function on_subscroll_subview_grpitems_entitem_click(btn)
	local index = ui.index(btn)
	if self.selectedIdx ~= index then
		self.selectedIdx = index
		libugui.SetVisible(self.spSelected, true)
		libunity.SetParent(self.spSelected, btn, false, 1)

		local Data = Items[index]

		--	yexin
		if Stage.home then
			enter_mode("building", _G.DEF.Unit.new(nil, Data.id, 0))
			show_build_info()
			auto_build_obj()
		else
			self.Selected = _G.DEF.Unit.new(nil, Data.id, 0)
			show_build_info()
		end


		local build_state = BUILD.load(Data.id)
		if build_state then
			BUILD.save(Data.id,nil)
		end

		DY_DATA:get_player():check_newbuild_state()

		libunity.SetActive(GO(btn, "spRedPoint"), false)
	end
end
--!* [结束] 自动生成函数  *--

function init_view()
	ui.group(Ref.SubInfo.GrpMats)
	ui.group(Ref.GrpTabs)
	ui.group(Ref.SubScroll.SubView.GrpItems)
	--!* [结束] 自动生成代码 *--

	self.ItemDEF = _G.DEF.Item
	self.Stage = DY_DATA:get_stage()

	_G.PKG["ui/util"].flex_itemgrp(Ref.SubInfo.GrpMats)

	self.BUILDING_LAYER = 2 ^ 10
	self.FURNITURE_LAYER = 2 ^ 9
	self.GROUND_LAYER = 2 ^ 8

	self.MType2Layer = {
		BUILDING = self.BUILDING_LAYER,
		FURNITURE = self.FURNITURE_LAYER,
	}

	self.SubOper = Ref.SubOper
	self.spSelected = Ref.SubScroll.spSelected
	self.HPBars = {}
	self.stageRoot = libunity.Find("/StageView")

	self.get_item_amount = DY_DATA.item_counter()
end

function init_logic()
	local Frm = ui.find("FRMExplore")
	Frm.set_visible(false)

	math.randomseed(os.date2secs())

	init_buildtype_tglgrp()

	self.buildW, self.buildH = Stage:get_build_size()

	rfsh_buildtips_pos(nil)
	libugui.SetVisible(self.SubOper.go, false)
	libugui.SetVisible(self.spSelected, false)
	Ref.GrpTabs:get(1).tgl.value = true

	self.camTrans = UE.Camera.main.transform
	local ctrTrans = self.camTrans.parent
	local currPos = ctrTrans.localPosition
	self.minPos = self.camTrans.position - currPos
	self.maxPos = self.camTrans.position + UE.Vector3(Stage.w, 0, Stage.h) - currPos
	self.camRot = UE.Quaternion.Euler(0, 45, 0)
	if Stage.home then
		libgame.EnableFOW(false)
		libugui.StopTween(self.camTrans)
		libugui.DOTween("Position", self.camTrans, nil, cam_pos_offset, { duration = 1, ease = "OutCubic" })
		libugui.DOTween("EulerAngles", self.camTrans, nil, cam_rot_offset, { duration = 1, ease = "OutCubic" })
    	draw_design_lines()
    	rfsh_building_hpbar()
    end
    libunity.SetActive(Ref.spDrag, Stage.home)
	--rfsh_building_list()

	-- 动作
	libgame.UnitBreak(0)
	libgame.PlayerInteract(-config("itemlib").BLUEPRINT, config("skilllib").FOLD_ID, 0)

	-- 建造模式下，当建筑模型新载入时，要根据情况修改其材质
	CTRL.subscribe("VIEW_LOAD", obj_view_loaded)
	CTRL.subscribe("HEALTH_CHANGED", obj_health_changed)
	CTRL.subscribe("VIEW_UNLOAD", obj_view_unloaded)

	local GUIDE = _G.PKG["guide/api"]
	if  GUIDE.load(5) ~= 0 then
		ui.show("UI/WNDGuidingDesigning", 0, {
			API = GUIDE,
			guideID = 5,
		})
	end
end

function show_view()

end

function on_recycle()
	CTRL.unsubscribe("VIEW_LOAD", obj_view_loaded)
	CTRL.unsubscribe("HEALTH_CHANGED", obj_health_changed)
	CTRL.unsubscribe("VIEW_UNLOAD", obj_view_unloaded)

	libgame.UnitBreak(0)
	libgame.UnitTransState(0, "LEAVE_ACTION")

	libugui.AllTogglesOff(Ref.GrpTabs.go)
	libunity.SetParent(self.spSelected, Ref.SubScroll.go)

	libgame.Recycle("/GRID")
	cancel_mode()

	libgame.ResetCamera(1)
	libgame.EnableFOW(true)
	--libunity.Invoke(nil, 1, function () libgame.EnableFOW(true) end)

	for _,v in pairs(Stage:get_furniture_list()) do
		libgame.SetUnitSkin(v.id)
	end
	for _,v in pairs(Stage.Floors) do
		libgame.SetUnitSkin(v.id)
	end
	for _,v in pairs(Stage.Walls) do
		local view = libgame.GetViewOfObj(v.id)
		libunity.SetActive(GO(view, "Model/Normal"), true)
		libunity.SetActive(GO(view, "Model/BlankModel"), false)
		libgame.SetUnitSkin(v.id)
	end

	for _,v in pairs(self.HPBars) do API.del_hud_elm(v) end

	local Wnd = ui.find("FRMExplore")
	if Wnd then Wnd.set_visible(true) end


	DY_DATA.RedSystem:UnbuildRedDotUI(CVar.RedDotName.BuildHouse)
	DY_DATA.RedSystem:UnbuildRedDotUI(CVar.RedDotName.BuildDevice)
	DY_DATA.RedSystem:UnbuildRedDotUI(CVar.RedDotName.BuildFurniture)
	DY_DATA.RedSystem:UnbuildRedDotUI(CVar.RedDotName.BuildSpecial)
end

Handlers = {
	["PACKAGE.SC.SYNC_PACKAGE"] = function (Package)
		if Package.obj == 0 then
			rfsh_building_list()
		end
	end,

	["BUILD.SC.BUILDING"] = function (Items)
		if Items then
			self.Oper.on_success()
			rfsh_building_list()
		end
	end,

	["BUILD.SC.OPERATION"] = function (Ret)
		if Ret.err == nil then
			self.Oper.on_success()
		end
	end,

	["BUILD.SC.DESTORY"] = function (Ret)
		if Ret.err == nil then
			leave_mode()
		end
	end,
	["MAP.SC.SYNC_OBJ_ADD_JOIN"] = function (IDs)
		if IDs then
			load_builded_fx(IDs)
			try_next_build("obj")
		end
	end,

	["BUILD.SC.REPAIR"] = function (Ret)
		if Ret.err == nil then
			leave_mode()
		end
	end,

	["PACKAGE.SC.SYNC_ITEM_STAT"] = function ()
		try_next_build("item")
	end,
}

return self

