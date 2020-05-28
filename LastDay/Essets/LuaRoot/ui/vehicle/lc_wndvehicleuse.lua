--
-- @file    ui/vehicle/lc_wndvehicleuse.lua
-- @author  xingweizhen
-- @date    2018-05-13 00:33:15
-- @desc    WNDVehicleUse
--

local self = ui.new()
local _ENV = self

local function rfsh_vehicle_dura()
	local SubRepair = Ref.SubVehicle.SubRepair
	local VehicleData = Context.Data
	local hpRate = VehicleData.curDura / VehicleData.maxDura
	SubRepair.barHp.value = hpRate > 1 and 1 or hpRate

	if VehicleData.curDura < VehicleData.maxDura then
		libunity.SetActive(SubRepair.spCost, true)
		libunity.SetActive(SubRepair.lbCost, true)

		local RepairCost = CVar.get_pickup_repair_cost()
		RepairCost:show_icon(SubRepair.spCost)
		local repairAmount = math.ceil(RepairCost.amount * (1 - hpRate))
		SubRepair.lbCost.text = string.own_needs(DY_DATA:nget_item(RepairCost.dat), repairAmount)
	else
		libunity.SetActive(SubRepair.spCost, false)
		libunity.SetActive(SubRepair.lbCost, false)
	end
end

local function rfsh_vehicle_fuel()
	local SubGas = Ref.SubVehicle.SubGas
	local VehicleData = Context.Data
	SubGas.barGas.value = VehicleData.curFuel / VehicleData.maxFuel
end

local function rfsh_vehicle_slots()
	local SubGas = Ref.SubVehicle.SubGas
	local fuelIdx = CVar.gen_item_pos(Context.obj, 0, 1)
	local Item = DY_DATA:iget_item(fuelIdx)
	if Item then
		Item:show_view(SubGas.SubFuel)
	else
		ItemDEF.clear_view(SubGas.SubFuel)
	end

	local GrpSlots = Ref.SubVehicle.SubTrunk.GrpSlots
	GrpSlots:dup(Context.cap - 1, function (i, Ent, isNew)
		local itemPos = CVar.gen_item_pos(Context.obj, 0, i + 1)
		GrpSlots:setindex(Ent.go, itemPos)
		local Item = DY_DATA:iget_item(itemPos)
		if Item then
			Item:show_view(Ent)
		else
			ItemDEF.clear_view(Ent)
		end
	end)
end

function iget_entitem(index)
	local fuelIndex = CVar.gen_item_pos(Context.obj, 0, 1)

	if index == fuelIndex then
		return Ref.SubVehicle.SubGas.SubFuel
	else
		return Ref.SubVehicle.SubTrunk.GrpSlots:find(index)
	end
end

local function on_model_loaded(a, o, p)
	self.carModel = libunity.NewChild("/UIROOT/ROLE", o)
	print(self.carModel)

	libugui.Follow(self.carModel, Ref.SubVehicle.evtModel, 15)
	libunity.FaceCamera(self.carModel.gameObject)
	local trans = self.carModel.transform
	local euler = trans.localEulerAngles
	euler.y = 60
	trans.localEulerAngles = euler
end

local function create_pickup_model()
	libasset.LoadAsync(typeof(UE.GameObject),
		string.format("Units/%s/%s", "PickupTruckGroup", "PickupTruckOverUI"), "Default", on_model_loaded)
end

--!* [开始] 自动生成函数 *--

function on_evtmodel_drag(evt, data)
	if self.carModel and self.carModel.transform then
		local delta = data.delta
		local trans = self.carModel.transform
		local euler = trans.localEulerAngles
		euler.y = euler.y - delta.x
		trans.localEulerAngles = euler
	end
end

function on_subvehicle_subrepair_btnrepair_click(btn)
	NW.op_produce(Context.obj, 4)
end

function on_item_selected(evt, data)
	Primary.on_item_selected(evt, data)
end

function on_begindrag_item(evt, data)
	Primary.on_begindrag_item(evt, data)
end

function on_drag_item(evt, data)
	Primary.on_drag_item(evt, data)
end

function on_enddrag_item(evt, data)
	Primary.on_enddrag_item(evt, data)
end

function on_drop_item(evt, data)
	Primary.on_drop_item(evt, data)
end

function on_item_pressed(evt, data)
	Primary.on_item_pressed(evt, data)
end

function on_item_dualclick(evt, data)
	Primary.on_item_dualclick(evt, data)
end

function on_subvehicle_subgas_btnrefuel_click(btn)
	NW.op_produce(Context.obj, 3)
end

function on_subvehicle_btndrive_click(btn)
	-- 检查耐久和汽油
	local VehicleData = Context.Data
	if VehicleData.curDura <= 0 then
		UI.Toast.norm(TEXT.tipVehileIsBroken)
	return end

	local fuelRequired = tonumber(CVar.PICKUP.TravelDemand)
	if VehicleData.curFuel < fuelRequired then
		UI.Toast.norm(string.format(TEXT.fmtNoEnoughFuel4Vehicle, fuelRequired))
	return end

	local view = libgame.GetViewOfObj(libgame.GetFocusUnit())
	if view then
		self.Primary:close(true)

		local driver = libunity.Find(view, "Model/DRIVER")
		if driver then
			local trans = driver.transform
			local tarPos, tarFwd = trans.position, trans.forward
			libgame.UnitMove(0, tarPos)
			libgame.UnitTurn(0, tarFwd)

			libunity.StartCoroutine(nil, function ()
				local Vector3 = UE.Vector3
				local objTrans = libgame.GetViewOfObj(0).transform
				while true do
					-- 等待到位
					coroutine.yield(0.1)
					local pos = libgame.GetUnitCoord(0)
					if Vector3.Distance(pos, tarPos) < 0.1
						and Vector3.Dot(tarFwd, objTrans.forward) > 0.99 then
					break end
				end

				-- 隐藏头顶信息
				_G.PKG["game/api"].set_obj_hud(CTRL:get_self().id, 0)

				-- 开门上车
				local focusID = libgame.GetFocusUnit()
				local objCar = libgame.GetViewOfObj(focusID)
				libgame.UnitAnimate(0, "getonpickup", 0.25)
				libgame.UnitAnimate(focusID, "getondrive", 0.25)
				libunity.PlayAudio("SFX/Object/Pickuptruck_start", objCar, false)

				if NW.connected() then
					local VehicleData = Context.Data
					NW.send(NW.msg("WORLD_MAP.CS.SELECT_MOVE_TOOL"):writeU32(VehicleData.id))
				else
					NW.broadcast("WORLD_MAP.SC.SELECT_MOVE_TOOL", {})
				end
			end)
		end
	end
end
--!* [结束] 自动生成函数  *--

function init_view()
	ui.group(Ref.SubVehicle.SubTrunk.GrpSlots)
	--!* [结束] 自动生成代码 *--

	local UTIL = _G.PKG["ui/util"]
	UTIL.flex_itement(Ref.SubVehicle.SubGas, "SubFuel", 1)
	UTIL.flex_itemgrp(Ref.SubVehicle.SubTrunk.GrpSlots)

	self.ItemDEF = _G.DEF.Item
end

function init_logic()
	create_pickup_model()

	self.Primary = Context.Primary
	self.Primary.Secondary = self

	local SubVehicle = Ref.SubVehicle
	local Obj = CTRL.get_obj(Context.obj)
	libunity.SetActive(SubVehicle.btnDrive, Obj ~= nil)
	if Obj == nil then
		Obj = _G.DEF.Unit.new(Context.obj, Context.Data.dat, 0)
		Obj:get_form_data()
	end
	SubVehicle.lbName.text = Obj.Form.View.name

	ui.index(SubVehicle.SubGas.SubFuel.go, CVar.gen_item_pos(Context.obj, 0, 1))

	rfsh_vehicle_dura()
	rfsh_vehicle_fuel()
	rfsh_vehicle_slots()
end

function show_view()

end

function on_recycle()
	libgame.Recycle(self.carModel.gameObject)

	-- libgame.UnitBreak(0)
	-- NW.send(NW.gamemsg("PACKAGE.CS.PACKAGE_CLOSE"):writeU32(Context.obj))
end

Handlers = {
	["PRODUCE.SC.PRODUCEINFO"] = function (Ret)
		print(Ret.err)
		if Ret.err == nil then
			local Produce = Ret.Produce
			local VehicleData = Context.Data
			for k,v in pairs(VehicleData) do
				VehicleData[k] = Produce[k]
			end

			--播放加油音效
			if Produce.produceType == 3 then
				libunity.PlayAudio("UI/UI_Fuel_add", nil, false)
			end


			rfsh_vehicle_dura()
			rfsh_vehicle_fuel()
		end
	end,

	["PACKAGE.SC.SYNC_PACKAGE"] = function (Package)
		if Package.obj == Context.obj then
			rfsh_vehicle_slots()
		end
	end,
}

return self

