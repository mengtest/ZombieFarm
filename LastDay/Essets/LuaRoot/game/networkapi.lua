--
-- @file    game/networkapi.lua
-- @anthor  xingweizhen (weizhen.xing@funplus.com)
-- @date    2017-11-23 19:00:15
-- @desc    描述
--

local NW = _G.NW

function NW.get_bs_tcp(host, port)
	local MainCli = NW.MainCli
	if MainCli.host == host and MainCli.port == port then
		return MainCli
	end

	local Cli = _G.DEF.Client.get("BattleTcp"):initialize()
	if Cli:connected() and Cli.host == host and Cli.port == port then
		return Cli
	end

	Cli:connect(host, port)
	return Cli
end

function NW.exit_game()
	NW.send(NW.msg("COM.CS.COM_EXIT"))
	local MainCli = NW.MainCli
	MainCli.host, MainCli.port = nil, nil
end

function NW.apply_map(play, map)
	local mType = map == CVar.HOME_ID and 0 or 1
	local nm = NW.msg("MAP.CS.APPLY_JOIN")
	nm:writeU32(play):writeU32(mType):writeU64(map):writeU32(0)
	NW.send(nm, "MAP.SC.APPLY_JOIN")
end

function NW.request_get_entrance_weather(entranceId)
	-- local AllWeather = DY_DATA.World.AllWeather
	-- if AllWeather then
	-- 	local weatherEndTime = AllWeather[entranceId] and AllWeather[entranceId].endTime or 0
	-- 	local curTime = os.date2secs()
	-- 	if (weatherEndTime - curTime) > 0 then
	-- 		return
	-- 	end
	-- end
	local nm = NW.msg("WORLD_MAP.CS.WORLD_WEATHER")
	nm:writeU32(entranceId)
	NW.send(nm)
end

function NW.alone_apply_map(Entrance)
	local nm = NW.msg("MULTI_MAP.CS.ALONE_APPLY")
	nm:writeU32(Entrance.id)
	NW.send(nm)
end

function NW.team_apply_map(entId, autoTeam)
	NW.send(NW.msg("MULTI_MAP.CS.TEAM_APPLY"):writeU32(entId):writeU32(autoTeam and 1 or 2))
end

function NW.apply_global_map(Room)
	local function on_cli_connected(cli)
		NW.set_cli(cli)
		local nm = cli.msg("MULTI_MAP.CS.BS_APPLY_JOIN")
		nm:writeU64(Room.id):writeU64(Room.token)
		nm:writeU64(DY_DATA:get_player().id)
		cli:send(nm)
	end

	local function on_cli_disconnected(cli)
		NW.set_cli()
		if cli.host then
			_G.UI.MBox.make()
				:as_final():set_depth(200)
				:set_param("title", TEXT.tipDropGame)
				:set_param("content", TEXT.UnknowLogoff)
				:set_param("single", true)
				:set_param("block", true)
				:set_event(SCENE.load_main)
				:show()
		end
	end

	local Cli = NW.get_bs_tcp(Room.host, Room.port)
	if Cli:connected() then
		on_cli_connected(Cli)
	else
		Cli:set_connected(on_cli_connected)
		Cli:set_disconnected(on_cli_disconnected)
	end
end

-- 删除道具
function NW.del_item(Item)
	if NW.connected() then
		local obj, bag, idx = CVar.split_item_idx(Item.pos)
		local nm = NW.gamemsg("PACKAGE.CS.ITEM_DEL")
		nm:writeU32(obj):writeU32(bag):writeU32(idx - 1):writeU32(Item.dat)
		NW.send(nm)
	else
		NW.PACKAGE.set_slot_dirty(Item.pos)
		DY_DATA:iset_item(Item.pos, nil)
		Item.dat = 0
		Item.amount = 0
		NW.broadcast("PACKAGE.SC.ITEM_DEL", { Item })
	end
end

-- 移动道具
function NW.move_item(src, dst, amount)
	-- 判断能否移动
	local MAJOR_SLOT = _G.CVar.EQUIP_MAJOR_POS
	local MINOR_SLOT = _G.CVar.EQUIP_MINOR_POS
	local BAG_SLOT = _G.CVar.EQUIP_BAG_POS
	local small, large = src, dst

	if small > large then small, large = large, small end
	if small == MINOR_SLOT and large == MAJOR_SLOT then
		-- 能否切换武器？
		if not libgame.IsWeaponSwith(0) then return false end
		if not libgame.SwitchUnitMajor(0, MINOR_SLOT) then
			-- 忙中，无法切换武器，将延迟到空闲时才处理
		return false end
	end

	local SrcItem, DstItem = DY_DATA:iget_item(src), DY_DATA:iget_item(dst)
	if SrcItem == nil and DstItem == nil then return false end

	if SrcItem == nil then
		SrcItem, DstItem = DstItem, SrcItem
		src, dst = dst, src
	end

	-- 网络消息
	if NW.connected() then
		local srcObj, srcBag, srcIdx = CVar.split_item_idx(src)
		local dstObj, dstBag, dstIdx = CVar.split_item_idx(dst)

		local nm = NW.gamemsg("PACKAGE.CS.ITEM_MOVE")
		nm:writeU32(srcObj):writeU32(srcBag):writeU32(srcIdx - 1)
		  :writeU32(SrcItem.dat):writeU32(amount or 0)
		  :writeU32(dstObj):writeU32(dstBag):writeU32(dstIdx - 1)
		NW.send(nm)
	else
		local ItemDEF = _G.DEF.Item
		SrcItem = ItemDEF.dup(SrcItem)
		DY_DATA:iset_item(SrcItem.pos, SrcItem)
		if DstItem then
			DstItem = ItemDEF.dup(DstItem)
			DY_DATA:iset_item(DstItem.pos, DstItem)
		end

		NW.PACKAGE.set_slot_dirty(dst)
		NW.PACKAGE.set_slot_dirty(src)
		if amount and amount > 0 then
			-- 拆分
			SrcItem.amount = SrcItem.amount - amount
			DstItem = DY_DATA:iget_item(dst)
			if DstItem then
				DstItem.amount = DstItem.amount + amount
			else
				DstItem = ItemDEF.create(dst, SrcItem.dat, amount)
				NW.PACKAGE.set_item_amount(DstItem)
			end
		else
			local nStack = SrcItem:get_base_data().nStack
			if DstItem and SrcItem.dat == DstItem.dat and nStack > 1 then
				-- 堆叠
				DstItem.amount = DstItem.amount + SrcItem.amount
				if DstItem.amount > nStack then
					SrcItem.amount = DstItem.amount - nStack
					DstItem.amount = nStack
				else
					SrcItem.amount = 0
					NW.PACKAGE.set_item_amount(SrcItem)
				end
			else
				-- 移动
				SrcItem.pos = dst
				if DstItem == nil then
					DstItem = _G.DEF.Item.create(src, 0, 0)
				else
					DstItem.pos = src
				end
				NW.PACKAGE.set_item_amount(SrcItem)
				NW.PACKAGE.set_item_amount(DstItem)
			end
		end
		NW.broadcast("PACKAGE.SC.ITEM_MOVE", { SrcItem, DstItem })
	end

	return true
end

function NW.use_item(Item)
	if Item then
		local cooldown,_ = DY_DATA:get_item_cool(Item)
		if cooldown and cooldown > 0 then
			-- 道具冷却中
			-- _G.UI.Toast.norm(_G.TEXT.tipItemCooling)
		return end

		local obj, bag, idx = CVar.split_item_idx(Item.pos)
		local nm = NW.gamemsg("PACKAGE.CS.ITEM_USE")
		nm:writeU32(obj):writeU32(bag):writeU32(idx - 1):writeU32(Item.dat)
		NW.send(nm)
	end
end

function NW.put_item(Item, obj, idx, tarObj)
	if Item then
		local nm = NW.gamemsg("PACKAGE.CS.PACKAGE_INTO")
		nm:writeU32(obj):writeU32(idx - 1):writeU32(Item.dat):writeU32(tarObj)
		NW.send(nm)
	end
end

-- 玩家打开包裹/工作台
function NW.open_package(action, obj)
	if obj == 0 then
		libgame.UnitBreak(0)
	return end

	if NW.connected() then
		local nm = NW.gamemsg("PACKAGE.CS.PACKAGE_OPEN")
		local Vec, angle = libgame.GetUnitCoord(0, true)
		if Vec then
			nm:writeU32(obj)
			  :writeU32(Vec.x * 1000):writeU32(Vec.z * 1000):writeU32(angle)
		else
			nm:writeU32(obj):writeU32(0):writeU32(0):writeU32(0)
		end
		NW.send(nm)
	else
		local SkillLIB = config("skilllib")
		if action == SkillLIB.OPEN_ID then
			-- 打开箱子
			local ItemDEF = _G.DEF.Item
			DY_DATA:iset_item(obj * 1000 + 1, ItemDEF.create(obj * 1000 + 1, 10001, 1))
			DY_DATA:iset_item(obj * 1000 + 3, ItemDEF.create(obj * 1000 + 3, 12001, 3))
			NW.broadcast("PACKAGE.SC.PACKAGE_OPEN", { obj = obj, cap = 100, })
		elseif action == SkillLIB.WORK_ID then
			local Obj = _G.PKG["game/ctrl"].get_obj(obj)
			if Obj.dat == 54031 then
				-- 皮卡车
				NW.broadcast("PACKAGE.SC.PACKAGE_OPEN", {
					obj = obj, cap = 4,
					Data = {
						type = 3,
						curFuel = 100, maxFuel = 100,
						curDura = 50, maxDura = 100,
					},
				})
			else
				-- 其他工作台
				local ItemDEF = _G.DEF.Item
				DY_DATA:iset_item(obj * 1000 + 1, ItemDEF.create(obj * 1000 + 1, 10001, 1))
				DY_DATA:iset_item(obj * 1000 + 2, ItemDEF.create(obj * 1000 + 2, 11001, 10))
				-- 打开工作台
				NW.broadcast("PACKAGE.SC.PACKAGE_OPEN", {
					obj = obj, cap = 6,
					Data = {
						type = 1,
						Fuels = {
							{ id = 11001, burnTime = 30 },
							{ id = 11002, burnTime = 40 },
							{ id = 12001, burnTime = 50 },
							{ id = 13001, burnTime = 60 },
							{ id = 14001, burnTime = 70 },
							{ id = 15001, burnTime = 80 },
						},
						Formulas = { 101, 201, 202, 203, 204, },
						Produce = {
							working = true,
							id = 101, timeUsed = 1, burnTimeLeft = 100, maxBurnTime = 200,
						},
					},
				})
			end
		end
	end
end

-- 生产操作（0=时间到,1=立即完成,2=燃料用完,3=加油,4=载具维修, 5=装备修理, 6=无线电）
function NW.op_produce(obj, produceType, itemPos)
	local nm = NW.msg("PRODUCE.CS.PRODUCEINFO")
	nm:writeU32(obj):writeU32(produceType):writeU32((itemPos == nil) and 0 or itemPos)
	NW.send(nm)
end

--生产操作(修改数量)(type 1=修改材料数量, 2=取出成品)
function NW.op_modify_working_cnt(obj, modifyType, formulaId, fuelId, count)
	local nm = NW.msg("PRODUCE.CS.MODIFY_COUNT")
	nm:writeU32(obj):writeU32(modifyType):writeU32(formulaId):writeU32(fuelId):writeU32(count)
	NW.send(nm)
end

function NW.read_item(nm)
	return { id = nm:readU32(), amount = nm:readU32(), }
end

function NW.read_coord(nm)
	return { x = nm:readU32(), y = nm:readU32(), }
end

function NW.read_int_pair(nm, key, value)
	if key == nil then
		key = "key"
	end
	if value == nil then
		value = "value"
	end
	return { [key] = nm:readU32(), [value] = nm:readU32(), }
end

function NW.read_RoleBaseData(nm, Role)
	local serverId = nm:readU32()--服务器ID
	local name = nm:readString()--名称
	local level = nm:readU32()--等级
	local power = nm:readU32()--战力
	local uniqueId = nm:readString()--短id
	local guildName = nm:readString()--公会名字
	local guildChanel = nm:readU32()--公会频段
	local guildID = nm:readU32()--公会ID

	if Role == nil then
		libunity.LogE("读取RoleBaseData失败。table-Role不能为空。")
		return
	end

	Role.serverId = serverId
	Role.name = name
	Role.level = level
	Role.power = power
	Role.uniqueId = uniqueId
	Role.guildName = guildName
	Role.guildChanel = guildChanel
end
