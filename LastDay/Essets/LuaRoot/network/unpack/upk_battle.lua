--
-- @file    network/unpack/upk_battle.lua
-- @anthor  xingweizhen (weizhen.xing@funplus.com)
-- @date    2017-10-30 14:50:44
-- @desc    描述
--

local NW, P = _G.NW, {}

function P.read_hp_changes(nm)
	local HPChanges = {}
	local n = nm:readU32()
	for i=1,n do
		local id = nm:readU32()
		local hp = nm:readU32()
		HPChanges[id] = hp
		libgame.SetUnitHealth(id, hp)
	end
	return HPChanges
end

function P.read_eff_changes(nm)
	local EffectChanges = {}
	local n = nm:readU32()
	for i=1,n do
		local id = nm:readU32()
		EffectChanges[id] = {
			id = nm:readU32(),
			disappear = nm:readU64(),
		}
	end
	return EffectChanges
end

NW.regist("SUB_BATTLE.SC.OBJ_PICKUP", function (nm)
	local Stage = DY_DATA:get_stage()
	Stage:set_clock(nm:readU64())
	local objId = nm:readU32()
	local ret, err = NW.chk_op_ret(nm:readU32())
	if err then libgame.PlayerAuto(false) end

	return { ret = ret, err = err }
end)

NW.regist("SUB_BATTLE.SC.OBJ_GEAR_TRIGGER", function (nm)
	local Stage = DY_DATA:get_stage()
	Stage:set_clock(nm:readU64())
	local objId = nm:readU32()
	local ret, err = NW.chk_op_ret(nm:readU32(), true)
	local status
	if err == nil then
		status = nm:readU32()
	end
	return { ret = ret, err = err, status = status, }
end)

NW.regist("SUB_BATTLE.SC.ROLE_URINATE", NW.common_op_ret)

NW.regist("SUB_BATTLE.SC.OBJ_TALK_NPC", function (nm)
	nm:readU64()
	local obj = nm:readU32()
	local ret, err = NW.chk_op_ret(nm:readU32())
	local dlgDat = nm:readU32()
	print("OBJ_TALK_NPC dat = ", dlgDat)
	if err == nil then
		if dlgDat > 0 then
			-- 必须延迟打开
			libunity.Invoke(nil, 0, function ()
				config("npclib").open(obj, dlgDat)
			end)
		end
	end
	return { ret = ret, err = err, objId = obj, dlg = dlgDat }
end)

NW.regist("BATTLE.CS.SYNC_ROLE_ACTION", function (nm)
	-- 时钟
	nm:readU64()
	local Stage = DY_DATA:get_stage()
	if Stage then
		local Unit = Stage:find_unit(nm:readU32())
		if Unit then Unit:read_action(nm) end
	end
end)

NW.regist("BATTLE.SC.SYNC_OBJ_BASE_INFO", function (nm)
	nm:readU64()
	local Stage = DY_DATA:get_stage()
	if Stage then
		local id = nm:readU32()
		local Unit = Stage:find_unit(id)
		if Unit then
			Unit:read_base(nm)
			_G.PKG["game/ctrl"].create(Unit)
			return Unit
		end
	end
end)

NW.regist("BATTLE.SC.ROLE_INTO_REED", function (nm)
	nm:readU64()
	local ret, err = NW.chk_op_ret(nm:readU32(), true)
	return { ret = ret, err = err, }
end)

NW.regist("BATTLE.SC.ROLE_OUT_REED", function (nm)
	nm:readU64()
	local ret, err = NW.chk_op_ret(nm:readU32(), true)
	if err == nil then
		local nextTime = nm:readU64()
		libgame.SetUnitStealth(0, false, nextTime)
	end
	return { ret = ret, err = err, }
end)

NW.regist("BATTLE.SC.SYNC_REED_DEAD", function (nm)
	nm:readU64()
	local Stage = DY_DATA:get_stage()
	if Stage then
		local id = nm:readU32()
		local Unit = Stage:find_unit(id)
		if Unit then
			Unit:read_base(nm)
			local coord, angle = Unit.read_vector(nm)
			libgame.SetUnitCoord(Unit.id, coord, angle)
			_G.PKG["game/ctrl"].create(Unit)
			return Unit
		end
	end
end)

NW.regist("BATTLE.SC.SYNC_OBJ_BUFF_INFO", function (nm)
	nm:readU64()
	local Stage = DY_DATA:get_stage()
	if Stage then
		local Unit = Stage:find_unit(nm:readU32())
		if Unit then Unit:read_buffs(nm) end
		return Unit
	end
end)

NW.BATTLE = P
