--
-- @file    game/ctrl.lua
-- @anthor  xingweizhen (weizhen.xing@funplus.com)
-- @date    2017-10-13 14:42:10
-- @desc    描述
--

local libgame = _G.libgame
local P = { }

-- @ 事件处理
--
local EVENT_Handlers = setmetatable({}, _G.MT.AutoGen)
function P.subscribe(event, handler)
	table.insert_once(EVENT_Handlers[event], handler)
end

function P.unsubscribe(event, handler)
	local Handlers = rawget(EVENT_Handlers, event)
	if Handlers then
		table.remove_elm(Handlers, handler)
		if #Handlers == 0 then
			EVENT_Handlers[event] = nil
		end
	end
end

function P.handle(event, ...)
	local Handlers = rawget(EVENT_Handlers, event)
	if Handlers then
		for i=#Handlers,1,-1 do
			local handler = Handlers[i]
			local status, ret = trycall(handler, ...)
			if status and ret then table.remove(Handlers, i) end
		end
	end
end
-- @ --

-- 后端定义操作
function P.open_package(action, obj)
	local SkillLIB = config("skilllib")
	if action == SkillLIB.OPEN_ID or action == SkillLIB.WORK_ID then
		NW.open_package(action, obj)
	elseif action == SkillLIB.PORT_ID then
		-- 打开传送点
		local Obj = P.get_obj(obj)
		print(cjson.encode(Obj.ExInfo, true))
	elseif action == SkillLIB.FRIENDLY_WORK_ID then
		--好友交互
		local nm = NW.msg("PRODUCE.CS.PRODUCE_FRIEND_HELP")
		nm:writeU32(obj)
		NW.send(nm)
	else
		-- 未定义行为
		debug.printR("未定义行为", true)
	end
end

-- 其他同步操作
function P.sync_action(action, obj)
	local SkillLIB = config("skilllib")
	if action == SkillLIB.URINATE_ID then
		-- 排泄完成
		NW.send(NW.gamemsg("SUB_BATTLE.CS.ROLE_URINATE"))
	elseif action == SkillLIB.TALK_ID then
		if NW.connected() then
			NW.send(NW.gamemsg("SUB_BATTLE.CS.OBJ_TALK_NPC"):writeU32(obj):writeU32(0):writeString(""))
		else
			config("npclib").open(obj, P.get_obj(obj).dlg)
		end
	else
		-- 未定义行为
	end
end

-- 技能指示器
function P.create_itor(Skill, itemPos)
	local Target = Skill and Skill.Target
	if Target then
		local Vector3 = UE.Vector3
		local euler = UE.Camera.main.transform.eulerAngles
        local camRot = UE.Quaternion.Euler(0, euler.y, 0)
        local rangeType = Target.rangeType

        local rngItor, itor
		local tarPos, angle = libgame.GetUnitCoord(0, false)

		rawset(P, "move_itor", function (offset)
			local selfPos = libgame.GetUnitCoord(0, false)
			offset = Vector3.ClampMagnitude(offset, Skill.maxRange - 0.5)
			tarPos = selfPos + camRot * offset
			if itor then
				itor.position = Skill.tarType ~= 3 and tarPos or selfPos
				if rangeType ~= 2 then
					itor.forward = (tarPos - selfPos).normalized
				end
			end
			return tarPos
		end)

		rawset(P, "delete_itor", function ()
			libgame.Recycle(rngItor)
			libgame.Recycle(itor)

			rawset(P, "move_itor", nil)
			rawset(P, "delete_itor", nil)

			return tarPos, Skill, itemPos
		end)

		libasset.LoadAsync(nil, "fx/itor/", nil, function ()
			if rawget(P, "move_itor") == nil then return end

			rngItor = libgame.PlayFx(0, "Itor/RangeItor", P.selfId)[1]
			local proj = libunity.Find(rngItor, "PROJECT", "Projector")
			proj.orthographicSize = Skill.maxRange

			local itorType, Params
			local Indicator = Skill.Indicator
			if Indicator then
				itorType = Indicator.type
				Params = Indicator.Params
			else
				itorType = rangeType
				Params = Target.Params
			end

			if itorType == 2 then
				-- 圆
				itor = libgame.PlayFx(0, "Itor/CircleItor")[1]
				local proj = libunity.Find(itor, "PROJECT", "Projector")
				proj.orthographicSize = Params[1] / 1000
			elseif itorType == 3 then
				-- 扇形
				itor = libgame.PlayFx(0, "Itor/Sector" .. Params[2])[1]
				local proj = libunity.Find(itor, "PROJECT", "Projector")
				proj.orthographicSize = Params[1] / 1000
				itor.eulerAngles = Vector3(0, angle, 0)
			elseif itorType == 4 then
				-- 矩形（方向）
				itor = libgame.PlayFx(0, "Itor/RectItor")[1]
				local proj = libunity.Find(itor, "PROJECT", "Projector")
				proj.orthographicSize = Params[1] / 1000
				proj.aspectRatio = Params[2] / Params[1]
				itor.eulerAngles = Vector3(0, angle, 0)
			end
		end)

		return tarPos
	end
end

-- @ --

-- @ 场景单位
local Objects
function P.create(Obj)
	local id = Obj.id
	local CacheObj = Objects[id]
	if CacheObj.Form == nil then
		Obj.datDirty = nil
		Obj.tmplDirty = nil
		Obj.infoDirty = nil
		Obj.baseDirty = nil
		Obj.actionDirty = nil
		Obj.statusDirty = nil
		if Obj.dat then
			if Obj.coord then
				local ObjForm = Obj:get_form_data()
				if Obj.type == "Corpse" then
					-- 创建尸体
					if libgame.CreateCorpse(ObjForm, Obj.srcObj) then
						-- 更新View
						libgame.UpdateUnitData(Obj.id, {
								model = Obj:get_view_dresses(),
								Affixes = Obj:get_view_affixes(),
							})
					end
				else
					if ObjForm then
						libgame.CreateObj(ObjForm)
					else
						libunity.LogE("获取单位数据为空！{0}", Obj)
					end
				end
			else
				-- 数据不完整，忽略
			end
		else
			libunity.LogW("创建对象失败：{0}", tostring(Obj))
		end
	else
		local ObjForm = CacheObj.Form
		if CacheObj.datDirty then
			CacheObj.datDirty = nil
			-- 模板发生变化
			ObjForm = Obj:get_form_data()
			if ObjForm then
				libgame.CreateView(id, ObjForm.View, true)
				libgame.UpdateUnitData(id, { Attr = ObjForm.Data.Attr, Init = ObjForm.Data.Init, })
			else
				libunity.LogE("获取单位数据为空！{0}", Obj)
			return end
		end

		local FormDataInit = ObjForm.Data.Init

		if CacheObj.tmplDirty then
			CacheObj.tmplDirty = nil
			local class = CacheObj.Form.class
			if class == "Human" then
				-- Upate Obj Data
				local Weapons, model
				local Attr, Affixes = {}, {}

				if type(CacheObj.MajorWeapon) == "number" then
					Weapons = CacheObj:get_weapon_data()
				end

				if CacheObj.Dresses then
					for i=1,_G.CVar.DRESS_NUM do
						if type(CacheObj.Dresses[i]) == "number" then
							model = CacheObj:get_view_dresses()
							if model ==  ObjForm.View.model then model = nil end
						break end
					end

					CacheObj:update_view_affixes(Affixes)
				end

				if #Affixes == 0 then Affixes = nil end

				local OldAttr = CacheObj.Form.Data.Attr
				local NewAttr = CacheObj:calc_attr()
				for key,name,old,new in _G.DEF.Attr.pairs(OldAttr, NewAttr) do
					if old ~= new then Attr[key] = new or 0 end
				end

				if next(Attr) or Weapons or model or Affixes then
					P.update(CacheObj,
						{ Attr = NewAttr, Weapons = Weapons, },
						{ model = model, Affixes = Affixes })
				end
			end
		end

		if CacheObj.infoDirty then
			CacheObj.infoDirty = nil
			FormDataInit.camp = CacheObj.camp
			FormDataInit.status = CacheObj.status
			FormDataInit.operId = CacheObj:get_oper() or -1
			FormDataInit.disappear = CacheObj.disappear
			-- 同步信息变化
			libgame.SyncUnitInfo(id, {
					hpLimit = CacheObj.Attr.hp, hp = CacheObj.hp,
					operId = FormDataInit.operId,
					camp = FormDataInit.camp,
					disappear = FormDataInit.disappear,
					status = FormDataInit.status,
				})
			-- 同步MapObjBuff
			P.handle("BUFF_UPDATE", Obj)
		elseif CacheObj.baseDirty then
			CacheObj.baseDirty = nil
			FormDataInit.camp = CacheObj.camp
			FormDataInit.status = CacheObj.status
			FormDataInit.operId = CacheObj:get_oper() or -1
			FormDataInit.disappear = CacheObj.disappear
			-- 同步信息变化
			libgame.SyncUnitInfo(id, {
					operId = FormDataInit.operId,
					camp = FormDataInit.camp,
					disappear = FormDataInit.disappear,
					status = FormDataInit.status,
				})
		end

		if CacheObj.actionDirty then
			CacheObj.actionDirty = nil
			-- 更新位置和朝向
			libgame.SetUnitCoord(id, CacheObj.coord, CacheObj.angle)
		end

		if CacheObj.statusDirty then
			CacheObj.statusDirty = nil
			FormDataInit.status = CacheObj.status
			libgame.SyncUnitInfo(id, {
					status = FormDataInit.status,
				})

			if Obj.type == "Monster" then
				P.handle("monster_idlestatus_modify", id)
			end

			--libgame.SetUnitStealth(id, CacheObj.status == 2)
		end
	end
end

function P.update(Obj, Data, View)
	local ObjForm = Obj.Form
	local NewData = {}
	if Data then
		for k,v in pairs(Data) do
			ObjForm.Data[k] = v
			NewData[k] = v
		end
	end
	if View then
		for k,v in pairs(View) do
			ObjForm.View[k] = v
			NewData[k] = v
		end
	end

	libgame.UpdateUnitData(Obj.id, NewData)
	return ObjForm
end

function P.update_team()
	local Stage = DY_DATA:get_stage()
	local Team = rawget(DY_DATA, "Team")
	if Stage and Team then
		local API = _G.PKG["game/api"]
		local OldTeam
		if Stage.Team == nil then
			Stage.Team = {}
			OldTeam = {}
		else
			OldTeam = table.swapkv(Stage.Team)
			table.clear(Stage.Team)
		end
		for k,v in pairs(Team.Members) do
			local Obj = P.get_human(v.id)
			if Obj then table.insert(Stage.Team, Obj.id) end
		end

		for i,v in ipairs(Stage.Team) do
			if OldTeam[v] then
				OldTeam[v] = nil
			else
				if v ~= P.selfId then
					-- 新增队友
					libgame.ReplaceView(v, { mapIco = "Battle/mmap_otherRole_b_d", mapItor = "Common/ico_com_104" })
					local Sub = API.get_obj_hud(v)
					if Sub then Sub.SubPlate.lbName.color = CVar.UnitColors.team end
				end
				libgame.SetFOWStatus(v, 1)
			end
		end
		for k,_ in pairs(OldTeam) do
			-- 非队友
			local Obj = P.get_obj(k)
			if Obj and Obj.View then
				libgame.ReplaceView(k, { mapIco = Obj.View.Fxes.mapIco, mapItor = "" })
				local Sub = API.get_obj_hud(k)
				if Sub then Sub.SubPlate.lbName.color = API.get_unit_color(Obj) end
			end
			libgame.SetFOWStatus(k, 2)
		end
	end
end

function P.get_obj(id)
	return Objects and Objects[id]
end

function P.get_self()
	return P.get_obj(P.selfId)
end

function P.get_human(pid)
	for k,v in pairs(Objects) do
		if v.pid == pid then return v end
	end
end

-- @ --

function P.init(Stage)
	Objects = Stage.Units
end

function P.clear()
	table.clear(EVENT_Handlers)
	if Objects then
		for k,v in pairs(Objects) do
			v.Form = nil
		end
		Objects = nil
	end

	for k,v in pairs(P) do
		if type(v) ~= "function" then
			P[k] = nil
		end
	end
end

function P.add_reg(reg)
	local Registers = table.need(P, "Registers")
	table.insert(Registers, reg)
end

function P.register()
	local Registers = P.Registers
	if Registers then
		for _,reg in ipairs(Registers) do
			local rType = type(reg)
			if rType == "function" then
				reg(P)
			elseif rType == "string" then
				MERequire(reg)(P)
			end
		end
		P.Registers = nil
	end
end

function P.update_item(Item)
	local loss = true
	setmetatable(Item, _G.DEF.Item)
	if Item.dat > 0 then
		if Item.amount > 0 then
			local dura, _ = Item:get_durability()
			loss = dura == 0
		end
		if loss then Item:play_loss() end
	else
		libunity.LogW("有道具坏了，但是不知道是什么{0}", Item)
	end

	DY_DATA:iset_item(Item.pos, Item)
	NW.PACKAGE.set_slot_dirty(Item.pos, loss and Item.pos or Item)
	NW.broadcast("PACKAGE.SC.SYNC_ITEM", { Item })
end

function P.load_stage()
	local Stage = DY_DATA:get_stage()
	local SortedUnits = table.toarray(Stage.Units, function (a, b)
		if a.dat and b.dat then
			return a.dat < b.dat
		end
		return a.id < b.id
	end)
	for _,v in ipairs(SortedUnits) do v.Form = nil end

	local Self = Stage.Self
	P.selfId = Self.id
	P.create(Self)

	for _,v in ipairs(SortedUnits) do P.create(v) end

	return Stage
end

function P.load_missile(id)
	return config("skilllib").get_missile(id)
end

function P.load_effect(id)
	return config("skilllib").get_eff(id)
end

function P.load_buff(id)
	return config("skilllib").get_buff(id)
end

function P.load_subsk(id)
	return config("skilllib").get_sub(id)
end

function P.load_action(id)
	return config("skilllib").get_dat(id)
end

function P.load_hurt(id)
	return config("skilllib").get_hurt(id)
end

local DefWeapon
function P.get_def_weapon()
	if DefWeapon == nil then
		DefWeapon = _G.DEF.Item.new(1000)
		DefWeapon.id = 0
		DefWeapon.pos = _G.CVar.EQUIP_MAJOR_POS
		local maxDura, maxAmmo = DefWeapon:get_max_durability()
		DefWeapon:set_durability(maxDura, maxAmmo)
	end
	return DefWeapon
end
function P.load_weapon(id)
	if id >= 0 then
		local Weapon = DY_DATA:iget_item(id)
		if Weapon then return Weapon:get_weapon_data() end

		return P.get_def_weapon():get_weapon_data()
	else
		return _G.DEF.Item.new(-id, 1):get_weapon_data()
	end
end

function P.load_alloper()
	local Opers = {}
	local function get_opers(Item)
		if Item then
			local ItemBase = Item:get_base_data()
			if ItemBase.Oper then
				for k,v in pairs(ItemBase.Oper) do
					Opers[k] = true
				end
			end
		end
	end

	local Self = P.get_self()
	local Major, Minor = Self:get_weapon()
	get_opers(Major)
	get_opers(Minor)

	local DY_DATA_Items = DY_DATA:get_obj_items(0)
	for i=1,DY_DATA.bagCap do get_opers(DY_DATA_Items[i]) end

	return Opers
end

function P.check_stakable(Obj)
	if type(Obj) == "number" then Obj = P.get_obj(Obj) end
	if Obj then
		local ObjBase = Obj:get_base_data()
		if ObjBase.Drops then
			-- 检查自己的背包是否存在可堆叠格子
			local itemPos = nil
			for _,v in ipairs(ObjBase.Drops) do
				itemPos = DY_DATA:get_stackable_itempos(0, 0, DY_DATA.bagCap, v)
					   -- or DY_DATA:is_stackable(CVar.EQUIP_LPOCKET_POS, v, true)
					   -- or DY_DATA:is_stackable(CVar.EQUIP_RPOCKET_POS, v, true)
				if itemPos then break end
			end
			return itemPos ~= nil
		end
	end

	return true
end

function P.find_tool(oper)
	local Tool
	local Self = P.get_self()
	local function item_operable(Item, oper)
		if Item then
			local ItemBase = Item:get_base_data()
			return ItemBase.Oper and ItemBase.Oper[oper]
		end
	end
	local Major, Minor = Self:get_weapon()
	if item_operable(Major, oper) then
		Tool = Major
	elseif item_operable(Minor, oper) then
		Tool = Minor
	end

	if Tool == nil then
		local DY_DATA_Items = DY_DATA:get_obj_items(0)
		for i=1,DY_DATA.bagCap do
			local Item = DY_DATA_Items[i]
			if item_operable(Item, oper) then Tool = Item; break end
		end
	end

	return Tool
end

function P.load_tool(oper)
	local Tool = P.find_tool(oper)
	P.get_self().tool = Tool and Tool.pos
	return Tool
end

return P
