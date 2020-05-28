--
-- @file    game/dydataapi.lua
-- @authors xing weizhen (xingweizhen@firedoggame.com)
-- @date    2018-05-20 13:06:44
-- @desc    描述
--

local CVar = _G.CVar
local DY_DATA = _G.DY_DATA

rawset(DY_DATA, "reset", function (P)
	_G.DEF.Stage.Instance = nil
end)

rawset(DY_DATA, "get_player", function (P)
	local Player = P.Player
	if getmetatable(Player) == nil then
		Player.id = 0
		setmetatable(Player, _G.DEF.Player)
	end
	return Player
end)

rawset(DY_DATA, "get_self", function (P)
	local Self = P.Self
	if getmetatable(Self) == nil then
		setmetatable(Self, _G.DEF.Human)
		Self.dat = 1
		Self.player = true
		Self.type = "Player"
		Self.class = "Player"
	end
	return Self
end)

rawset(DY_DATA, "get_usercard", function (P)
	return {
		playerId = P.Player.id,
		uniqueId = P.Player.uniqueId,
		name = P.Player.name,
		hair = P.Self.hair,
		gender = P.Self.gender,
		face = P.Self.face,
		haircolor = P.Self.haircolor,
		guildName = P.Player.guildName,
		guildChanel = P.Player.guildChannel,
		level = P.Player.level,
	}
end)

rawset(DY_DATA, "get_stage", function (P)
	return _G.DEF.Stage.Instance
end)

local OBJ_ITEM_LIMIT = CVar.OBJ_ITEM_LIMIT
local gen_item_pos = CVar.gen_item_pos
local split_item_pos = CVar.split_item_pos
local split_item_idx = CVar.split_item_idx

rawset(DY_DATA, "get_obj_items", function (P, obj)
	if obj == 0 then
		return P.Items
	else
		local _OtherItems = rawget(P, "OtherItems")
		if _OtherItems == nil then
			_OtherItems = setmetatable({}, _G.MT.AutoGen)
			P.OtherItems = _OtherItems
		end
		return _OtherItems[obj]
	end
end)

rawset(DY_DATA, "del_obj_items", function (P, obj)
	if obj then
		if obj == 0 then
			P.Items = nil
		else
			local _OtherItems = rawget(P, "OtherItems")
			if _OtherItems then _OtherItems[obj] = nil end
		end
	else
		P.OtherItems = nil
	end
end)

-- 获取指定格子的道具
rawset(DY_DATA, "iget_item", function (P, index)
	if index == nil then return end

	if index < OBJ_ITEM_LIMIT then
		return P.Items[index]
	else
		local obj, pos = split_item_pos(index)
		local Items = P:get_obj_items(obj)
		return Items[pos]
	end
end)

rawset(DY_DATA, "iset_item", function (P, index, Item)
	if index == nil then return end

	local Items, pos

	if index < OBJ_ITEM_LIMIT then
		Items =  P.Items
		pos = index

		--清空计数缓存
		local Cache = Items[index]
		local cacheID = Cache and Cache.dat or 0
		P.OwnItems[cacheID] = nil
		if Item and cacheID ~= Item.dat then
			P.OwnItems[Item.dat] = nil
		end

	else
		local obj
		obj, pos = split_item_pos(index)
		Items = P:get_obj_items(obj)
	end

	if Item == nil then
		Items[pos] = nil
	else
		if Item.amount == 0 then
			Item.dat = 0
		end
		if Item.dat == 0 then
			Items[pos] = nil
		else
			Items[pos] = Item
		end
	end
end)

-- 获取自己拥有的某种道具的数量
rawset(DY_DATA, "nget_item", function (P, dat)
	local OwnItems = P.OwnItems
	local own = OwnItems[dat]
	if own == nil then
		own = 0
		local ITEM_LIMIT = OBJ_ITEM_LIMIT
		for _,v in pairs(P.Items) do
			if v.pos < ITEM_LIMIT and v.dat == dat then
				own = own + v.amount
			end
		end
		OwnItems[dat] = own
	end
	return own
end)

rawset(DY_DATA, "get_item_amount", function (P, dat)
	local Item = P.Inventory[dat]
	if Item then return Item.amount, Item end

	return 0
end)

rawset(DY_DATA, "item_counter", function ()
	if SCENE.inLevel and DY_DATA:get_stage().home then
		return function (dat)
			return DY_DATA:get_item_amount(dat)
		end
	else
		return function (dat)
			return DY_DATA:nget_item(dat)
		end
	end
end)

-- 获取自己拥有的某种资源的数量
rawset(DY_DATA, "nget_asset", function (P, AssetKey)
	local Player = P:get_player()

	local _assetKey = tonumber(AssetKey)
	if _assetKey == nil then
		_assetKey = CVar.ASSET_TYPE[AssetKey]
	end
	local Assets = Player.Assets[_assetKey]

	return Assets and Assets.amount or 0
end)

-- 检查道具数量是否足够
rawset(DY_DATA, "check_item", function (P, Cost)
	if Cost.dat < 100 then
		local Player = P:get_player()
		local Item = Player.Assets[Cost.dat]
		return Item and Item.amount >= Cost.amount
	else
		local amount = P:nget_item(Cost.dat)
		return amount >= Cost.amount
	end
end)

-- 获取一个背包里面的首个空格子
rawset(DY_DATA, "get_empty_itempos", function (P, obj, bag, cap)
	local startIdx = gen_item_pos(obj, bag, 0)
	if cap == nil then cap = P.bagCap end
	for i=startIdx+1,startIdx+cap do
		local Item = P:iget_item(i)
		if Item == nil then return i end
	end
end)

rawset(DY_DATA, "is_stackable", function (P, pos, dat, shortcut)
	local Item = P:iget_item(pos)
	if shortcut then
		if Item == nil then return end

		local ItemBase = config("itemlib").get_dat(dat)
		if ItemBase == nil or not ItemBase.shortcut then return end
	end

	if Item == nil then return pos end
	if Item.dat == dat then
		local ItemBase = Item:get_base_data()
		if Item.amount < ItemBase.nStack then return pos end
	end
end)

-- 获取一个背包里面的首个未满的格子
rawset(DY_DATA, "get_stackable_itempos", function (P, obj, bag, cap, dat)
	local startIdx = gen_item_pos(obj, bag, 0)
	if cap == nil then cap = P.bagCap end
	for i=startIdx+1,startIdx+cap do
		if P:is_stackable(i, dat) then return i end
	end
end)

-- 获取道具的冷却时间
--rst1: cooldown(剩余时间)  rst2: cycle(冷却需要的时间)
rawset(DY_DATA, "get_item_cool", function (P, Item)
	if Item == nil then return end

	local ItemBase = Item:get_base_data()
	local selfReady = P.ItemReadyTimes[ItemBase.id]
	if selfReady then
		local cooldown = selfReady - UE.Time.realtimeSinceStartup
		if cooldown > 0 then return cooldown, ItemBase.cooldown or cooldown end
	end

	if ItemBase.cooldownGroupID then
		local groupReady = P.ItemGroupReadyTimes[ItemBase.cooldownGroupID]
		if groupReady then
			local cooldown = groupReady - UE.Time.realtimeSinceStartup
			if cooldown > 0 then return cooldown, ItemBase.cooldownGroup end
		end
	end
end)

rawset(DY_DATA, "set_item_cool", function (P, Item, cooldown, groupCooldown)
	if type(Item) == "number" then
		Item = P:iget_item(Item)
	end

	local ItemBase = Item:get_base_data()
	if cooldown == nil then
		cooldown = ItemBase.cooldown
		groupCooldown = ItemBase.cooldownGroup
	end

	local realtimeSinceStartup = UE.Time.realtimeSinceStartup
	if cooldown then
		P.ItemReadyTimes[ItemBase.id] = realtimeSinceStartup + cooldown
	end
	if groupCooldown then
		P.ItemGroupReadyTimes[ItemBase.cooldownGroupID] = realtimeSinceStartup + groupCooldown
	end

	return cooldown, groupCooldown
end)

-- 获取当前的工艺列表
rawset(DY_DATA, "get_formula_list", function (P, col)
	local FormulaList = rawget(P, "FormulaList")
	local FormulaAmounts = rawget(P, "FormulaAmounts")
	if FormulaList == nil then
		local Lib = config("formulalib")

		-- 根据产出物记录的天赋表
		local TalentProducts = {}
		for _,v in Lib.pairs() do
			local productId = v.Item.id
			if TalentProducts[productId] == nil then
				TalentProducts[productId] = v
			end
		end

		local Talents = DY_DATA.Talents
		local CraftGroups = setmetatable({}, _G.MT.AutoGen)

		for _,v in pairs(TalentProducts) do
			local Data = v
			while Data.upgradeId > 0 do
				if Talents[Data.upgradeId] then
					Data = Lib.get_dat(Data.upgradeId)
				else break end
			end
			table.insert(CraftGroups[Data.group], Data)
		end
		setmetatable(CraftGroups, nil)

		local function sort_func(a, b) return a.sort < b.sort end
		for k,v in pairs(CraftGroups) do table.sort(v, sort_func) end

		FormulaList, FormulaAmounts = {}, {}
		for _,Grp in Lib.groups() do
			local Group = CraftGroups[Grp.id]
			for _,v in ipairs(Group) do
				table.insert(FormulaList, v)
			end

			local n = #Group
			local r = n % col
			if r > 0 then
				-- 补空位
				for i=1,r do table.insert(FormulaList, false) end
			end
			table.insert(FormulaAmounts, math.ceil(n / col))
		end

		P.FormulaList = FormulaList
		P.FormulaAmounts = FormulaAmounts
	end
	return FormulaList, FormulaAmounts
end)


-- 天赋的状态：
-- true		已解锁
-- false    已激活
-- nil 		未激活
rawset(DY_DATA, "get_talent_status", function (P, Talent)
	if Talent.unlockCost == 0 then return true end

	local P_Talents = P.Talents
	if P_Talents[Talent.id] then return true end

	local Player = P:get_player()
	if Talent.reqPlayerLevel > Player.level then return end

	if Talent.prevTalent > 0 then
		if P_Talents[Talent.prevTalent] == nil then
			local PrevTalent = config("formulalib").get_dat(Talent.prevTalent)
			if PrevTalent.unlockCost > 0 then return end
		end
	end

	return false
end)

-- 根据邮件ID，获取邮件信息
rawset(DY_DATA, "get_mail", function (P, mailID)
	local mailList = P.MailList
	for _,v in pairs(mailList) do
		local mailUnit = v
		if mailUnit.mailID == mailID then
			return mailUnit
		end
	end
	return nil
end)

rawset(DY_DATA, "get_top_task", function (P, taskType)
	local tasklib = config("tasklib")
	if taskType and type(taskType) == "string" then
		taskType = tasklib.TaskType[taskType]
	end

	local get_task_dat = config("tasklib").get_dat
	local minId, Task, TaskBase = math.huge
	for k,v in pairs(P.Tasks) do
		local Base = get_task_dat(v.id)
		if Base then
			if taskType == nil or Base.type == taskType and v.status ~= "hidden" and v.status ~= "fnished" then
				if Base.sort < minId then
					minId, Task, TaskBase = Base.sort, v, Base
				elseif taskType == nil and Task == nil then
					Task = v
				end
			end
		else
			if taskType == nil and Task == nil then
				Task = v
			end
			libunity.LogE("没有配置任务#{0}", v.id)
		end
	end
	return Task, TaskBase
end)

rawset(DY_DATA, "get_endfirst_task", function (P, taskType)
	local tasklib = config("tasklib")
	if taskType and type(taskType) == "string" then
		taskType = tasklib.TaskType[taskType]
	end

	local time = os.date2secs()

	local get_task_dat = config("tasklib").get_dat
	local endMinTime, Task, TaskBase = math.huge
	for k,v in pairs(P.Tasks) do
		local Base = get_task_dat(v.id)
		if Base then
			local taskEndTime = v.endTime
			taskEndTime = taskEndTime == 0 and math.huge - 1 or taskEndTime
			if taskEndTime > time then
				if taskType == nil or Base.type == taskType and v.status ~= "hidden" then
					if taskEndTime < endMinTime then
						endMinTime, Task, TaskBase = taskEndTime, v, Base
					elseif taskType == nil and Task == nil then
						Task = v
					end
				end
			end
		else
			if taskType == nil and Task == nil then
				Task = v
			end
			libunity.LogE("没有配置任务#{0}", v.id)
		end
	end
	return Task, TaskBase
end)

rawset(DY_DATA, "get_task_list", function (P, taskType)
	local tasklib = config("tasklib")
	if type(taskType) == "string" then
		taskType = tasklib.TaskType[taskType]
	end
	local time = os.date2secs()
	local get_task_dat = tasklib.get_dat
	local taskList = {}
	for k,v in pairs(P.Tasks) do
		local Base = get_task_dat(v.id)
		if Base.type == taskType and v.endTime > time and v.status ~= "hidden" then
			table.insert(taskList, Base)
		end
	end

	table.sort(taskList, function(a, b)
		return a.sort < b.sort
	end)

	return taskList
end)

-- 获取公会成员信息
rawset(DY_DATA, "get_guild_member_info", function (P, userID)
	if userID == nil then
		userID = DY_DATA:get_player().id
	end
	local memberList = P.MyGuildMemberList
	if memberList == nil then
		libunity.LogE("MyGuildMemberList is nil.")
		return nil
	end
	for _,v in pairs(memberList) do
		local memberInfo = v
		if memberInfo.id == userID then
			return memberInfo
		end
	end
	return nil
end)

rawset(DY_DATA, "modify_guild_member_info", function (P, newMemberInfo)
	local memberList = P.MyGuildMemberList
	if memberList == nil then
		libunity.LogE("MyGuildMemberList is nil.")
		return
	end
	for i,v in pairs(memberList) do
		local memberInfo = v
		if memberInfo.id == newMemberInfo.id then
			P.MyGuildMemberList[i] = newMemberInfo
			return
		end
	end
	table.insert(P.MyGuildMemberList, newMemberInfo)
end)

rawset(DY_DATA, "remove_guild_member_info", function (P, userID)
	local memberList = P.MyGuildMemberList
	if memberList == nil then
		return nil
	end
	for index,v in pairs(memberList) do
		local memberInfo = v
		if memberInfo.id == userID then
			table.remove(memberList, index)
			return
		end
	end
end)

rawset(DY_DATA, "get_shopgoods_info", function (P, shopID, goodsID)
	local goodsList = DY_DATA.ShopGoodsInfo[shopID]
	if goodsList then
		for _,v in pairs(goodsList) do
			if v.goodsID == goodsID then
				return v
			end
		end
	end
	return nil
end)

local function get_friend_info_list(friendType)
	if type(friendType) == "string" then
		friendType = CVar.FRIEND_TYPE[friendType]
	end

	if friendType == CVar.FRIEND_TYPE["FRIEND"] then
		return DY_DATA.friendList
	elseif friendType == CVar.FRIEND_TYPE["BLACKLIST"] then
		return DY_DATA.blackList
	elseif friendType == CVar.FRIEND_TYPE["APPLYLIST"] then
		return DY_DATA.friendApplyList
	else
		return {}
	end
end

rawset(DY_DATA, "get_friend_info", function (P, userID, friendType)
	for i,v in pairs(get_friend_info_list(friendType)) do
		if v.id == userID then
			return i, v
		end
	end
end)

rawset(DY_DATA, "remove_friend_info", function (P, userID, friendType)
	local dataList = get_friend_info_list(friendType)
	local dataindex = 0
	for i,v in pairs(dataList) do
		if v.id == userID then
			dataindex = i
			break
		end
	end
	if dataindex >0  then
		table.remove(dataList, dataindex)
	end
end)
rawset(DY_DATA, "update_friend_info", function (P,userInfo, friendType)
	local dataList = get_friend_info_list(friendType)
	local dataindex = 0
	for i,v in pairs(dataList) do
		if v.id == userInfo.id then
			dataindex = i
			break
		end
	end
	if dataindex ~=0 then
		dataList[dataindex] = userInfo
	else
		table.insert(dataList,userInfo)
	end

end)

rawset(DY_DATA, "get_network_letency", function (P)
	local letency = tonumber(P.latency)
	if letency then
		if letency > 999 then
			letency = 999
		end
		if letency < 200 then
			return string.format("<color=green>%sms</color>", letency)
		elseif letency < 500 then
			return string.format("<color=yellow>%sms</color>", letency)
		else
			return string.format("<color=red>%sms</color>", letency)
		end
	end
	return "--"
end)