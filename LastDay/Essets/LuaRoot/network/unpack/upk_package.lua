--
-- @file    network/unpack/unp_package.lua
-- @anthor  xingweizhen (weizhen.xing@funplus.com)
-- @date    2017-11-08 15:03:21
-- @desc    描述
--

local NW, P = _G.NW, {}

function P.set_slot_dirty(pos, Item)
	local Self = rawget(DY_DATA, "Self")
	if Self then
		local MAJOR_SLOT = _G.CVar.EQUIP_MAJOR_POS
		local MINOR_SLOT = _G.CVar.EQUIP_MINOR_POS
		local BAG_SLOT = _G.CVar.EQUIP_BAG_POS
		local changed

		if pos == MAJOR_SLOT then
			Self.MajorWeapon = Item
			changed = true
		elseif pos == MINOR_SLOT then
			Self.MinorWeapon = Item
			changed = true
		elseif pos > MAJOR_SLOT and pos <= BAG_SLOT then
			Self:set_dress(pos - MAJOR_SLOT, Item)
			changed = true
		end

		if changed and pos == Item then
			NW.broadcast("CLIENT.SC.EQUIP_CHANGED", pos)
		end
	end
end

function P.set_item_amount(Item)
	DY_DATA:iset_item(Item.pos, Item)
	P.set_slot_dirty(Item.pos, Item.pos)
end

local function read_single_item(obj, bag, nm)
	local idx, dat = nm:readU32(), nm:readU32()
	local pos = CVar.gen_item_pos(obj, bag, idx + 1)

	local Item = _G.DEF.Item.create(pos, dat)
	Item:read_data(nm)

	P.set_item_amount(Item)

	return Item
end

local function get_self_id()
	local Stage = DY_DATA:get_stage()
	if Stage then return Stage.Self.id end

	local Player = DY_DATA:get_player()
	if Player then return Player.obj or 0 end

	return 0
end

-- MapPackage
local function read_map_package(nm)
	local selfId = get_self_id()

	local obj, tmpl = nm:readU32(), nm:readU32()
	local Poses = nm:readArray({}, nm.readU32)
	local canPutIn = nm:readU32() == 0
	local bag, bagCap = nm:readU32(), nm:readU32()
	if obj == selfId then
		obj = 0
		-- 玩家自己的背包
		if bag == 0 then
			DY_DATA.bagCap = bagCap
			DY_DATA.OwnItems = nil
		elseif bag == 1 then
			-- 装备背包
			for pos=_G.CVar.EQUIP_MINOR_POS,_G.CVar.EQUIP_BAG_POS do
				P.set_slot_dirty(pos, pos)
			end
		end
	end

	-- 清空
	local Items = DY_DATA:get_obj_items(obj)
	local split_item_idx = _G.CVar.split_item_idx
	for k,_ in pairs(Items) do
		local _, _bag, _ = split_item_idx(k)
		if _bag == bag then Items[k] = nil end
	end

	local n = nm:readU32()
	for i=1,n do
		read_single_item(obj, bag, nm)
	end
	return {
		obj = obj, bag = bag, cap = bagCap,
		canPutIn = canPutIn,
		Items = Items,
	}
end

-- PackageItem[]
local function read_package_items(nm)
	local selfId = get_self_id()

	local ChItems = {}
	local n = nm:readU32()
	for i=1,n do
		local obj, bag = nm:readU32(), nm:readU32()
		if obj == selfId then obj = 0 end
		local Item = read_single_item(obj, bag, nm)
		table.insert(ChItems, Item)
	end
	return ChItems
end

local function items_change(nm)
	local ret, err = NW.chk_op_ret(nm:readU32())
	if err == nil then
		return read_package_items(nm)
	end
end
P.items_change = items_change

local function clock_items_change(nm)
	local clock = nm:readU64()
	return items_change(nm)
end

local function read_radio_EventInfo(nm)
	return {
		id = nm:readU32(),
		pos = nm:readU32(),
		state = nm:readU32(),
	}
end

local function read_produce_info(nm)
	local produceType = nm:readU32()
	--1.加工台   2.建造台  3.载具 4.特殊的箱子  5.兑换物品  6.装备修理 7:无线电
	if produceType == 1 then
		return {
			produceType = produceType,
			obj = nm:readU32(),
			id = nm:readU32(), timeUsed = nm:readU32(),
			burnTimeLeft = nm:readU32(), maxBurnTime = nm:readU32(),
			working = nm:readU32() == 1,
			lastTime = nm:readU32(), workedTime = nm:readU32(),
		}
	elseif produceType == 2 then
		return {
			produceType = produceType,
			FormulaID = nm:readU32(),
			Mats = nm:readArray({}, NW.read_item)
		}
	elseif produceType == 3 then
		local Data = NW.WORLD.sc_vehicle_info(nm)
		Data.produceType = produceType
		return Data
	elseif produceType == 5 then
		return {
			produceType = produceType,
			FormulaID = nm:readU32(),
			obj = nm:readU32(),
		}
	elseif produceType == 7 then
		return {
			produceType = produceType,
			Events = nm:readArray({}, read_radio_EventInfo),
		}
	end
end

NW.regist("PACKAGE.SC.PACKAGE_OPEN", function (nm)
	local clock = nm:readU64()
	local obj = nm:readU32()
	local ret, err = NW.chk_op_ret(nm:readU32())
	if err == nil then
		local Package = read_map_package(nm)
		local Data
		local pkgType = nm:readU32()
		--1:工作台
		if pkgType == 1 then
			local function read_fuel(nm)
				return { id = nm:readU32(), burnTime = nm:readU32(), }
			end
			-- 工作台
			Data = {
				type = pkgType,
				Formulas = nm:readArray({}, nm.readU32),
				Fuels = nm:readArray({}, read_fuel),
				Produce = read_produce_info(nm),
			}

		--2:建造台
		elseif pkgType == 2 then
			Data = {
				type = pkgType,
				FormulaID = nm:readU32(),
				Mats = nm:readArray({}, NW.read_item),
			}

		--3:载具
		elseif pkgType == 3 then
			Data = NW.WORLD.sc_vehicle_info(nm)
			Data.type = pkgType

		--5:兑换物品
		elseif pkgType == 5 then
			Data = {
				type = pkgType,
				FormulaID = nm:readU32(),
			}

		--6:装备修理
		elseif pkgType == 6 then
			Data = {
				type = pkgType,
				--todo:尚未实现
			}

		--7:电台
		elseif pkgType == 7 then
			Data = {
				type = pkgType,
				Events = nm:readArray({}, read_radio_EventInfo),
			}

		-- 功能建筑
		elseif pkgType == 8 then
			Data = {
				type = pkgType,
				obj = nm:readU32(),
				funcId = nm:readU32(),
			}
		end

		local totalCntDict = {}
		if pkgType > 0 then
			local totalCntArr = nm:readArray({}, NW.read_item)
			for _,v in pairs(totalCntArr) do
				totalCntDict[v.id] = v.amount
			end
		end

		return {
			obj = obj,
			cap = Package.cap,
			type = pkgType,
			Data = Data,
			totalCntDict = totalCntDict,
			canPutIn = Package.canPutIn,
		}
	end
end)

NW.regist("PACKAGE.SC.PACKAGE_PICKUP", function (nm)
	local clock = nm:readU64()
	local obj = nm:readU32()
	local ret, err = NW.chk_op_ret(nm:readU32())
	if err == nil then
		return read_package_items(nm)
	end
end)

NW.regist("PACKAGE.SC.PACKAGE_INTO", clock_items_change)

NW.regist("PACKAGE.SC.ITEM_DEL", clock_items_change)

NW.regist("PACKAGE.SC.ITEM_COMPOSE", clock_items_change)

NW.regist("PACKAGE.SC.SYNC_PACKAGE", read_map_package)

NW.regist("PACKAGE.SC.ITEM_MOVE", function (nm)
	local clock = nm:readU64()
	local ret, err = NW.chk_op_ret(nm:readU32())
	if err == nil then
		return read_package_items(nm)
	end
end)

NW.regist("PACKAGE.SC.SYNC_ITEM", function (nm)
	local clock = nm:readU64()
	return read_package_items(nm)
end)

NW.regist("PACKAGE.SC.ITEM_USE", function (nm)
	local clock = nm:readU64()
	local obj, bag, pos = nm:readU32(), nm:readU32(), nm:readU32()
	local itemId = nm:readU32()
	local ret, err = NW.chk_op_ret(nm:readU32())
	if err == nil then
		local ItemBase = config("itemlib").get_dat(itemId)
		local useSfx = ItemBase.useSfx
		if useSfx and #useSfx > 0 then
			libunity.PlayAudio(useSfx)
		end
		-- 记录冷却
		if ItemBase.cooldown then
			DY_DATA.ItemReadyTimes[itemId]
				= UE.Time.realtimeSinceStartup + ItemBase.cooldown
		end
		if ItemBase.cooldownGroupID then
			DY_DATA.ItemGroupReadyTimes[ItemBase.cooldownGroupID]
				= UE.Time.realtimeSinceStartup + ItemBase.cooldownGroup
		end

		NW.BATTLE.read_hp_changes(nm)
		local ChItems = read_package_items(nm)
		NW.BATTLE.read_eff_changes(nm)

		return ChItems

	end
end)

NW.regist("PACKAGE.SC.NEATEN_PACKET", function (nm)
	local clock = nm:readU64()
	return NW.common_op_ret(nm)
end)

NW.regist("PACKAGE.SC.SYNC_ITEM_STAT", function (nm)
	local Inventory = DY_DATA.Inventory
	local ItemDEF = _G.DEF.Item
	local n = nm:readU32()
	for i=1,n do
		local dat, amount = nm:readU32(), nm:readU32()
		if amount > 0 then
			Inventory[dat] = ItemDEF.new(dat, amount)
		else
			Inventory[dat] = nil
		end
	end
end)

NW.regist("PRODUCE.SC.PRODUCEINFO", function (nm)
	local ret, err = NW.chk_op_ret(nm:readU32())
	local Produce
	if err == nil then
		Produce = read_produce_info(nm)
	end
	return { ret = ret, err = err, Produce = Produce, }
end)

NW.regist("PRODUCE.SC.MODIFY_COUNT", function (nm)
	local ret, err = NW.chk_op_ret(nm:readU32())
	local modify
	if err == nil then
		local isMut = nm:readU32() == 2
		local function read_modify(nm)
			local modifyInfo = {}
			modifyInfo.id = nm:readU32()
			modifyInfo.count = nm:readU32()
			if isMut then
				modifyInfo.count = -modifyInfo.count
			end
			return modifyInfo
		end
		modify = nm:readArray({}, read_modify)
	end
	return { ret = ret, err = err, modify = modify, }
end)

NW.regist("PRODUCE.SC.ITEM_STAT", function (nm)
	local totalCntDict = {}
	local totalCntArr = nm:readArray({}, NW.read_item)
	for _,v in pairs(totalCntArr) do
		totalCntDict[v.id] = v.amount
	end
	return totalCntDict
end)

NW.regist("PRODUCE.SC.PRODUCE_FRIEND_HELP", function (nm)
	local ret, err = NW.chk_op_ret(nm:readU32())
	if err == nil then
		local obj = nm:readU32()
		return obj
	end
end)

NW.PACKAGE = P
