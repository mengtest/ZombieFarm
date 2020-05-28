--
-- @file    network/unpack/upk_guild.lua
-- @author  shenbingkang
-- @date    2018-09-03 16:29:00
-- @desc    描述
--

local NW, P = _G.NW, {}

local function read_GuildInfo(nm)
	local guildInfo = {}
	guildInfo.guildID = nm:readU32()

	guildInfo.guildChanel = nm:readU32()
	local chTemp = math.floor(guildInfo.guildChanel / 1000)
	local chTempD = guildInfo.guildChanel - chTemp * 1000
	guildInfo.guildChanelStr = string.format("%03d", chTemp).."."..string.format("%03d", chTempD)

	local oldName = nm:readString()

	local hex = string.format("%02X", guildInfo.guildID)
	guildInfo.guildName = string.format(TEXT.GuildNameFormat, hex)
	guildInfo.guildIcon = nm:readString() --"底图ID#图标ID#背景色Id#底图颜色ID#图标色ID"
	guildInfo.guildDesc = nm:readString()
	guildInfo.guildLevel = nm:readU32()
	guildInfo.guildMemCnt = nm:readU32()
	guildInfo.guildMemLimitCnt = nm:readU32()
	guildInfo.guildActivity = nm:readU32()
	guildInfo.guildBuildings = nm:readArray({}, function(nm)
		return {
			buildingId = nm:readU32(),
			buildingLv = nm:readU32(),
		}
	end)
	return guildInfo
end

local function read_MyGuildInfo(nm)
	local myGuildInfo = read_GuildInfo(nm)
	myGuildInfo.guildCaptial = nm:readU32()
	myGuildInfo.guildManten = nm:readU32()
	myGuildInfo.guildNextMantenTime = math.floor(nm:readU64() / 1000) + 2
	return myGuildInfo
end

local function read_GuildMemberInfo(nm)
	local userID = nm:readU64()
	local memberInfo = _G.DEF.Player.new(userID)
	memberInfo.name = nm:readString()
	if #memberInfo.name == 0 then
		memberInfo.name = TEXT.GuildBoss
	end
	memberInfo.position = nm:readU32() --0-无状态 1-考核期 2-正式成员 3.副所长 4.所长
	memberInfo.level = nm:readU32()
	memberInfo.contribution = nm:readU32()
	memberInfo.lastLogoutTime = math.floor(nm:readU64() / 1000) --0表示在线
	return memberInfo
end

local function read_GuildClaim(nm)
	return {
		requestId = nm:readU32(),
		requestUserId = nm:readU64(),
		requestItemId = nm:readU32(),
		requestItemCnt = nm:readU32(),
		receiveItemCnt = nm:readU32(),
	}
end

local function clear_my_guild_info()
	local Player = DY_DATA:get_player()
	Player.guildID = 0
	DY_DATA.MyGuildInfo = {}
	DY_DATA.MyGuildMemberList = {}
end

local function sort_guild_member_list()
	table.sort(DY_DATA.MyGuildMemberList, function(a, b)
		if a.position ~= b.position then
			return a.position > b.position
		end

		if a.level ~= b.level then
			return a.level > b.level
		end

		if a.contribution ~= b.contribution then
			return a.contribution > b.contribution
		end

	end)
end

--========================================SC协议========================================
NW.regist("GUILD.SC.GET_GUILD_LIST", function (nm)
	local ret, err = NW.chk_op_ret(nm:readU32())
	if err == nil then
		DY_DATA.GuildList = nm:readArray({}, read_GuildInfo)
		DY_DATA.GuildRefreshTime = nm:readU32() --刷新次数
		DY_DATA.GuildListRefreshTime = math.floor(nm:readU64() / 1000)
		DY_DATA.GuildSearchCDTime = math.floor(nm:readU64() / 1000)
	end
	return err
end)

NW.regist("GUILD.SC.SEARCH_GUILD", function (nm)
	local ret, err = NW.chk_op_ret(nm:readU32())
	
	if err == nil then
		local SearchResultList = nm:readArray({}, read_GuildInfo)
		DY_DATA.GuildSearchCDTime = math.floor(nm:readU64() / 1000)
		return SearchResultList
	end
	return {}
end)

NW.regist("GUILD.SC.APPLY_JOIN_GUILD", function (nm)
	local errCode = nm:readU32()
	if errCode == 1360 then
		return errCode
	end
	local ret, err = NW.chk_op_ret(errCode)
	
	return err
end)

NW.regist("GUILD.SC.GUILD_CHANGE_DESC", function (nm)
	local ret, err = NW.chk_op_ret(nm:readU32())
	if err == nil then
		DY_DATA.MyGuildInfo.guildDesc = nm:readString()
	end
	return err
end)

NW.regist("GUILD.SC.GUILD_QUIT", function (nm)
	local ret, err = NW.chk_op_ret(nm:readU32())
	if err == nil then
		clear_my_guild_info()
	end
	return err
end)

NW.regist("GUILD.SC.GUILD_MY_INFO", function (nm)
	local ret, err = NW.chk_op_ret(nm:readU32())
	if err == nil then
		local dataVersion = nm:readU32()
		if dataVersion ~= DY_DATA.GuildInfoVersion then
			DY_DATA.GuildInfoVersion = dataVersion
			DY_DATA.MyGuildInfo = read_MyGuildInfo(nm)
			DY_DATA.MyGuildMemberList = nm:readArray({}, read_GuildMemberInfo)
			DY_DATA.GuildClaimTime = math.floor(nm:readU64() / 1000)
			sort_guild_member_list()
		end
	end
	return err
end)

NW.regist("GUILD.SC.GUILD_DONATE", function (nm)
	local ret, err = NW.chk_op_ret(nm:readU32())
	if err == nil then
		DY_DATA.MyGuildInfo.guildCaptial = nm:readU32()
		DY_DATA.MyGuildInfo.guildActivity = nm:readU32()
		local donateItemId = nm:readU32()
		local donateItemCnt = nm:readU32()
		local buildingNewLevel = nm:readU32()
		local buildingId = nm:readU32()
		local ItemBase = config("itemlib").get_dat(donateItemId)
		UI.Toast.norm(TEXT.GuildDonateFormat:csfmt(ItemBase.name, donateItemCnt))
		if buildingNewLevel > 0 then
			local resInfo, departmentInfo = config("guildlib").get_building_info(buildingId, buildingNewLevel)
			UI.Toast.norm(TEXT.GuildDonateLvUpFormat:csfmt(resInfo.name, buildingNewLevel))
		end
	end
	return err
end)

NW.regist("GUILD.SC.GET_GUILD_LOG_LIST", function (nm)
	local cfg = config("guildlib")

	local logList = nm:readArray({}, function(nm)
		local templateInfo = {}
		templateInfo.templateID = nm:readU32()
		templateInfo.time = math.floor(nm:readU64() / 1000)
		templateInfo.params = nm:readString()
		templateInfo.logStr = cfg.get_guildlog(templateInfo.templateID, templateInfo.params)
		
		return templateInfo
	end)

	table.sort(logList, function(a, b)
		if a.time == b.time then
			return a.templateID < b.templateID 
		end
		return a.time > b.time
	end)

	return logList
end)

NW.regist("GUILD.SC.GUILD_CLAIM_LIST", function (nm)
	local ret, err = NW.chk_op_ret(nm:readU32())
	if err == nil then
		local claimList = nm:readArray({}, read_GuildClaim)
		local myFriendlyValue = nm:readU32()
		local myExchangeArr = nm:readArray({}, nm.readU32)
		local myExchangeList = {}
		for _,v in pairs(myExchangeArr) do
			myExchangeList[v] = 1
		end

		return {
			claimList = claimList,
			myFriendlyValue = myFriendlyValue,
			myExchangeList = myExchangeList,
		}
	end
end)

NW.regist("GUILD.SC.GUILD_CLAM", function (nm)
	local ret, err = NW.chk_op_ret(nm:readU32())
	DY_DATA.GuildClaimTime = math.floor(nm:readU64() / 1000)
	return err
end)

NW.regist("GUILD.SC.GUILD_CLAIM_COMPLETE", function (nm)
	local ret, err = NW.chk_op_ret(nm:readU32())
	if err == nil then
		local claimId = nm:readU32()
		local myFriendlyValue = nm:readU32()
		return {
			claimId = claimId,
			myFriendlyValue = myFriendlyValue,
		}
	end
end)

NW.regist("GUILD.SC.SYN_CLAIM_INFO", function (nm)
	return read_GuildClaim(nm)
end)

NW.regist("GUILD.SC.GUILD_CHANGE_ICON", function (nm)
	local ret, err = NW.chk_op_ret(nm:readU32())
	if err == nil then
		DY_DATA.MyGuildInfo.guildIcon = nm:readString()
	end
	return err
end)

NW.regist("GUILD.SC.MEMBER_INFO", function (nm)
	local memberInfo = read_GuildMemberInfo(nm)

	local memberTtCnt = DY_DATA.MyGuildInfo.guildMemCnt
	if memberInfo.position == 0 then
		DY_DATA:remove_guild_member_info(memberInfo.id)
		if memberTtCnt then
			DY_DATA.MyGuildInfo.guildMemCnt = memberTtCnt - 1
		end
	else
		DY_DATA:modify_guild_member_info(memberInfo)
		DY_DATA.MyGuildInfo.guildMemCnt = #DY_DATA.MyGuildMemberList
	end

	sort_guild_member_list()
end)

NW.regist("GUILD.SC.SYN_GUILD_INFO", function (nm)
	DY_DATA.GuildList = nm:readArray({}, read_GuildInfo)
end)

NW.regist("GUILD.SC.GUILD_BUILD_INFO", function (nm)
	local ret, err = NW.chk_op_ret(nm:readU32())
	if err == nil then
		local data = {}
		data.buildingId = nm:readU32()
		data.buildingLv = nm:readU32()
		local donateProgress = nm:readArray({}, function(nm)
			return {
				id = nm:readU32(),
				amount = nm:readU32(),
			}
		end)

		data.donateProgress = {}
		for _,v in pairs(donateProgress) do
			data.donateProgress[v.id] = v.amount
		end

		return data
	end
end)

NW.regist("GUILD.SC.SYN_MY_GUILD_INFO", function (nm)
	DY_DATA.MyGuildInfo = read_MyGuildInfo(nm)
end)

NW.regist("GUILD.SC.GUILD_BUILD_PRODUCE", function (nm)
	local ret, err = NW.chk_op_ret(nm:readU32())
	if err == nil then
    	local obj = nm:readU32()
    	local Data = {
    		Formulas = nm:readArray({}, nm.readU32),
     		Energy = nm:readU32(),
        	Produce = nm:readArray({}, function(nm)
           		return {
                	id = nm:readU32(),
                	amount = nm:readU32(),
            	}
       	 end),
		}
		return { err = err, ret = ret, obj = obj , Data = Data, }
	end
    return { err = err, ret = ret, }
end)

--========================================CS协议========================================
-- 获取公会列表
function P.RequestGetGuildList(isForceRefresh)
	if type(DY_DATA.GuildListRefreshTime) ~= "number" then DY_DATA.GuildListRefreshTime = 0 end
	if not isForceRefresh and DY_DATA.GuildListRefreshTime > os.date2secs() then
		NW.broadcast("GUILD.SC.GET_GUILD_LIST", nil)
		return
	elseif DY_DATA.GuildListRefreshTime <= os.date2secs() then
		isForceRefresh = true
	end
	local nm = NW.msg("GUILD.CS.GET_GUILD_LIST")
	nm:writeU32(isForceRefresh and 1 or 0)
	NW.send(nm)
end

-- 搜索公会
function P.RequestSearchGuild(guildChanel)
	if type(DY_DATA.GuildSearchCDTime) ~= "number" then DY_DATA.GuildSearchCDTime = 0 end
	if DY_DATA.GuildSearchCDTime > os.date2secs() then
		-- 搜索CD时间，不允许搜索
		NW.chk_op_ret(1380)
		return
	end

	local nm = NW.msg("GUILD.CS.SEARCH_GUILD")
	nm:writeU32(guildChanel)
	NW.send(nm)
end

-- 申请加入公会
function P.RequestApplyJoinGuild(guildID)
	local nm = NW.msg("GUILD.CS.APPLY_JOIN_GUILD")
	nm:writeU32(guildID)
	NW.send(nm)
end

-- 修改公会公告
function P.RequestModifyGuildDesc(desc)
	local nm = NW.msg("GUILD.CS.GUILD_CHANGE_DESC")
	nm:writeString(desc)
	NW.send(nm)
end

-- 退出公会
function P.RequestQuitGuild(desc)
	local nm = NW.msg("GUILD.CS.GUILD_QUIT")
	NW.send(nm)
end

-- 获取我的公会信息
function P.RequestMyGuildInfo()
	local nm = NW.msg("GUILD.CS.GUILD_MY_INFO")
	local dataVersion = tonumber(DY_DATA.GuildInfoVersion)
	nm:writeU32(dataVersion or 0)
	NW.send(nm)
end

-- 捐献
function P.RequestDonate(buildingId, itemId, donateCnt)
	if buildingId == nil then
		buildingId = 0
	end

	local nm = NW.msg("GUILD.CS.GUILD_DONATE")
	nm:writeU32(buildingId)
	nm:writeU32(itemId)
	nm:writeU32(donateCnt)
	NW.send(nm)
end

-- 获取公会日志
function P.RequestGetGuildLog()
	local nm = NW.msg("GUILD.CS.GET_GUILD_LOG_LIST")
	NW.send(nm)
end

-- 获取公会索要列表
function P.RequestGuildClaimList()
	local nm = NW.msg("GUILD.CS.GUILD_CLAIM_LIST")
	NW.send(nm)
end

-- 索要物品
function P.RequestClaim(claimId)
	local nm = NW.msg("GUILD.CS.GUILD_CLAM")
	nm:writeU32(claimId)
	NW.send(nm)
end

-- 捐赠
function P.RequestClaimComplete(requestId)
	local nm = NW.msg("GUILD.CS.GUILD_CLAIM_COMPLETE")
	nm:writeU32(requestId)
	NW.send(nm)
end

-- 修改公会徽章
function P.RequestModifyBadge(badge)
	local nm = NW.msg("GUILD.CS.GUILD_CHANGE_ICON")
	nm:writeString(badge)
	NW.send(nm)
end

-- 请求建筑详细信息
function P.RequestBuildingInfo(departmentId)
	local nm = NW.msg("GUILD.CS.GUILD_BUILD_INFO")
	nm:writeU32(departmentId)
	NW.send(nm)
end

-- 客户端检测到公会资金维护期到了，通知服务器刷新
function P.RequestForceManager()
	local nm = NW.msg("GUILD.CS.GUILD_BUILD_MANAGER")
	NW.send(nm)
end

-- 避难所生产 (obj:地图对象ID   oper:1获取生产信息 2:制造  formulaID:生产配方)
function P.RequestGuildProduce(obj, oper, formulaID)
    local nm = NW.msg("GUILD.CS.GUILD_BUILD_PRODUCE")
    nm:writeU32(obj)
    nm:writeU32(oper)
    nm:writeU32(formulaID or 0)
    NW.send(nm)
end

NW.GUILD = P