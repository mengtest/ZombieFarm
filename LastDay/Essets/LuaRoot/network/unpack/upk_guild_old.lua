--
-- @file    network/unpack/upk_guild.lua
-- @author  shenbingkang
-- @date    2018-06-06 19:06:44
-- @desc    描述
--

local NW, P = _G.NW, {}

local function read_GuildInfo(nm)
	local guildInfo = {}
	guildInfo.guildID = nm:readU32()
	guildInfo.guildName = nm:readString()
	guildInfo.guildIcon = nm:readString() --"底图ID#图标ID#背景色Id#底图颜色ID#图标色ID"
	guildInfo.guildNotice = nm:readString()
	guildInfo.leaderName = nm:readString()
	guildInfo.guildLevel = nm:readU32()
	guildInfo.guildMemCnt = nm:readU32()
	guildInfo.guildMemLimitCnt = nm:readU32()
	guildInfo.guildActivity = nm:readU32()
	guildInfo.isOpenApply = nm:readU32() == 0
	guildInfo.isLocked = nm:readU32() == 1
	return guildInfo
end

local function read_MyGuildInfo(nm)
	local myGuildInfo = {}
	myGuildInfo.myWeekContribution = nm:readU32()
	myGuildInfo.rewardState = nm:readArray({}, nm.readU32) --0-未领取 1-已领取
	myGuildInfo.myPosition = nm:readU32() --0-普通 1-管理员 2-会长
	myGuildInfo.guildID = nm:readU32()
	myGuildInfo.guildName = nm:readString()
	myGuildInfo.guildIcon = nm:readString() --"底图ID#图标ID#背景色Id#底图颜色ID#图标色ID"
	myGuildInfo.guildNotice = nm:readString()
	myGuildInfo.guildLevel = nm:readU32()
	myGuildInfo.guildMemCnt = nm:readU32()
	myGuildInfo.guildActivity = nm:readU32()
	myGuildInfo.guildFund = nm:readU32()
	myGuildInfo.guildDisTime = math.floor(nm:readU64() / 1000) --0表示未解散
	myGuildInfo.donateCnt = nm:readU32()
	myGuildInfo.exchangeBuffCnt = nm:readU32()
	return myGuildInfo
end

local function read_GuildMemberInfo(nm)
	local userID = nm:readU64()
	local memberInfo = _G.DEF.Player.new(userID)
	memberInfo.name = nm:readString()
	memberInfo.position = nm:readU32() --0-普通 1-管理员 2-会长
	memberInfo.level = nm:readU32()
	memberInfo.contribution = nm:readU32()
	memberInfo.lastLogoutTime = math.floor(nm:readU64() / 1000) --0表示在线
	return memberInfo
end

local function read_GuildApplyInfo(nm)
	local userID = nm:readU64()
	local applyInfo = _G.DEF.Player.new(userID)
	applyInfo.name = nm:readString()
	applyInfo.level = nm:readU32()
	return applyInfo
end

local function clear_my_guild_info()
	local Player = DY_DATA:get_player()
	Player.guildID = 0
	DY_DATA.MyGuildInfo = {}
	DY_DATA.MyGuildMemberList = {}
end

--========================================SC协议========================================
NW.regist("GUILD.SC.CREATE_GUILD", function (nm)
	local ret, err = NW.chk_op_ret(nm:readU32())
	return  err
end)

NW.regist("GUILD.SC.GUILD_MY_INFO", function (nm)
	DY_DATA.MyGuildInfo = read_MyGuildInfo(nm)
	DY_DATA.MyGuildMemberList = nm:readArray({}, read_GuildMemberInfo)
end)

NW.regist("GUILD.SC.GUILD_CHANGE_DESC", function (nm)
	local ret, err = NW.chk_op_ret(nm:readU32())
	if err == nil and DY_DATA.MyGuildInfo ~= nil then
		DY_DATA.MyGuildInfo.guildNotice = nm:readString()
		return true
	end
	return false
end)

NW.regist("GUILD.SC.GUILD_CHANGE_SETTING", function (nm)
	local ret, err = NW.chk_op_ret(nm:readU32())
	if err == nil then
		local isOpen = nm:readU32()
		return isOpen == 0
	end
	return nil
end)

NW.regist("GUILD.SC.GET_GUILD_LIST", function (nm)
	local data = {}
	local ret, err = NW.chk_op_ret(nm:readU32(), true)
	if err == nil then
		data.GuildList = nm:readArray({}, read_GuildInfo)
	end
	return data
end)

NW.regist("GUILD.SC.SEARCH_GUILD", function (nm)
	local data = {}
	data.GuildList = nm:readArray({}, read_GuildInfo)
	return data
end)

NW.regist("GUILD.SC.APPLY_JOIN_GUILD", function (nm)
	local ret = nm:readU32()
	if ret == 1361 then
		--下次可申请的时间
		local unlockTime = math.floor(nm:readU64() / 1000)
		local lastTime = unlockTime - os.date2secs()
		_G.UI.Toast.norm(string.format(tostring(TEXT.fmtLastTimeCanApply), os.last2string(lastTime, 4)))
		return -1
	end

	local err = nil
	ret, err = NW.chk_op_ret(ret)
	if err == nil then
		local guildID = nm:readU32()
		return guildID
	end
end)

NW.regist("GUILD.SC.GUILD_QUIT", function (nm)
	local ret, err = NW.chk_op_ret(nm:readU32())
	if err == nil then
		clear_my_guild_info()
	end
	return err
end)

NW.regist("GUILD.SC.GET_GUILD_APPLY_LIST", function (nm)
	local data = {}
	local ret, err = NW.chk_op_ret(nm:readU32(), true)
	if err == nil then
		data.ApplyList = nm:readArray({}, read_GuildApplyInfo)
		data.IsOpen = nm:readU32() == 0
	end
	return data
end)

NW.regist("GUILD.SC.GUILD_OPERATE", function (nm)
	local ret, err = NW.chk_op_ret(nm:readU32())
	if err == nil then
		local isNewJoin = nm:readU32() == 2 --1拒绝；2同意
		if isNewJoin then
			local newMemberInfo = read_GuildMemberInfo(nm)
			table.insert(DY_DATA.MyGuildMemberList, newMemberInfo)
			if DY_DATA.MyGuildInfo then
				DY_DATA.MyGuildInfo.guildMemCnt = #DY_DATA.MyGuildMemberList
			end
			return true
		end
	end
	return false
end)

NW.regist("GUILD.SC.GUILD_CHANGE_JOB", function (nm)
	local ret, err = NW.chk_op_ret(nm:readU32())
	if err == nil then
		local userID = nm:readU64()
		local targetPosition = nm:readU32()
		if targetPosition == 2 then
			local memberList = DY_DATA.MyGuildMemberList
			for _,v in pairs(memberList) do
				if v.position == targetPosition then
					v.position = 0
					break
				end
			end
		end
		local targetMemberInfo = DY_DATA:get_guild_member_info(userID)
		if targetMemberInfo then
			targetMemberInfo.position = targetPosition
		end
		return true
	end
	return false
end)

NW.regist("GUILD.SC.GUILD_KICK_OUT", function (nm)
	local ret, err = NW.chk_op_ret(nm:readU32())
	if err == nil then
		local userID = nm:readU64()
		DY_DATA:remove_guild_member_info(userID)
		if DY_DATA.MyGuildInfo then
			DY_DATA.MyGuildInfo.guildMemCnt = #DY_DATA.MyGuildMemberList
		end
		return true
	end
	return false
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
	return logList
end)

NW.regist("GUILD.SC.DISSOLUTION_GUILD", function (nm)
	local ret, err = NW.chk_op_ret(nm:readU32())
	if err == nil then
		DY_DATA.MyGuildInfo.guildDisTime = math.floor(nm:readU64() / 1000)
	end
	return err
end)

NW.regist("GUILD.SC.CANCEL_DISSOLUTION_GUILD", function (nm)
	local ret, err = NW.chk_op_ret(nm:readU32())
	if err == nil then
		DY_DATA.MyGuildInfo.guildDisTime = 0
	end
	return err
end)

NW.regist("GUILD.SC.CONFIRM_DISSOLUTION_GUILD", function (nm)
	local ret, err = NW.chk_op_ret(nm:readU32())
	if err == nil then
		clear_my_guild_info()
	end
end)

NW.regist("GUILD.SC.GET_BUILDING_INFO", function (nm)
	local buildingInfoList = nm:readArray({}, function(nm)
		local buildingInfo = {}
		buildingInfo.buildingID = nm:readU32()
		buildingInfo.buildingLevel = nm:readU32()
		buildingInfo.buildingExp = nm:readU32()
		return buildingInfo
	end)
	return buildingInfoList
end)

NW.regist("GUILD.SC.GUILD_DONATE", function (nm)
	local ret, err = NW.chk_op_ret(nm:readU32())
	if err == nil then
		DY_DATA.MyGuildInfo.donateCnt = DY_DATA.MyGuildInfo.donateCnt + 1
		return true
	end
	--todo:捐献成功后，需要刷新我的本周贡献、我的总贡献、我的7日贡献、建筑列表重新获取
end)

NW.regist("GUILD.SC.GET_BUILDING_DONATE_RANK", function (nm)
	local cfg = config("guildlib")
	local donateRankList = nm:readArray({}, function(nm)
		local rankInfo = {}
		rankInfo.userID = nm:readU64()
		rankInfo.contribution = nm:readU32()

		local memberInfo = DY_DATA:get_guild_member_info(rankInfo.userID)
		rankInfo.name = memberInfo.name
		rankInfo.position = memberInfo.position
		rankInfo.positionName = cfg.get_position_name(rankInfo.position)
		return rankInfo
	end)

	table.sort(donateRankList, function(a, b)
		if a.contribution == b.contribution then
			return a.userID < b.userID
		end
		return a.contribution > b.contribution
	end)

	return donateRankList
end)

NW.regist("GUILD.SC.GET_GUILD_BUFF_LIST", function (nm)
	local ret, err = NW.chk_op_ret(nm:readU32(), true)
	if err == nil then
		local buffList = nm:readArray({}, function(nm)
			local buffInfo = {}
			buffInfo.buffID = nm:readU32()
			buffInfo.buffStall = nm:readU32()
			return buffInfo
		end)
		return buffList
	end
	return {}
end)

NW.regist("GUILD.SC.GUILD_EXCHANGE_BUFF", function (nm)
	local ret, err = NW.chk_op_ret(nm:readU32())
	if err == nil then
		DY_DATA.MyGuildInfo.exchangeBuffCnt = DY_DATA.MyGuildInfo.exchangeBuffCnt + 1
		return true
	end
end)

NW.regist("GUILD.SC.GAIN_WELFARE_REWARD", function (nm)
	local ret, err = NW.chk_op_ret(nm:readU32())
	if err == nil then
		local welfareID = nm:readU32()
		if DY_DATA.MyGuildInfo then
			DY_DATA.MyGuildInfo.rewardState[welfareID] = 1
		end
		return welfareID
	end
	return nil
end)

NW.regist("GUILD.SC.GET_MY_APPLY_LIST", function (nm)
	local data = {}
	data.MyApply = nm:readArray({}, nm.readU32)
	return data
end)

NW.regist("GUILD.SC.GET_DISPATCH_INFO", function (nm)
	local ret, err = NW.chk_op_ret(nm:readU32())
	if err == nil then
		local data = {}
		data.robot = _G.DEF.Robot.new(0, "Robot", 0, "")
		data.robot:read_view(nm)
		data.time = math.floor(nm:readU64() / 1000)
		data.mapID = nm:readU32()
		return data
	end
	return nil
end)

NW.regist("GUILD.SC.CHANGE_MECH_PART", function (nm)
	local ret, err = NW.chk_op_ret(nm:readU32())
	if err == nil then
		local mechpartsID = nm:readU32()
		return mechpartsID
	end
	return nil
end)

NW.regist("GUILD.SC.GUILD_DISPATCH", function (nm)
	local ret, err = NW.chk_op_ret(nm:readU32())
	if err == nil then
		local time = math.floor(nm:readU64() / 1000)
		return time
	end
	return nil
end)

NW.regist("GUILD.SC.GUILD_ID_CHANGE_NOTICE", function (nm)
	--1:加入 2:退出
	local modifyType = nm:readU32()
	local guildID = nm:readU32()

	if modifyType == 2 then
		clear_my_guild_info()
	end

	return modifyType
end)

--========================================CS协议========================================

--创建公会
function P.RequestCreateGuild(guildName, guildDesc, guildIcon)
	guildDesc = (guildDesc == nil) and "" or guildDesc
	local nm = NW.msg("GUILD.CS.CREATE_GUILD")
	nm:writeString(guildName)
	nm:writeString(guildDesc)
	nm:writeString(guildIcon)
 	NW.send(nm)
end

--获取我的公会信息
function P.RequestGetMyGuildInfo()
	local nm = NW.msg("GUILD.CS.GUILD_MY_INFO")
	NW.send(nm)
end

--修改公会公告
function P.RequestModifyGuildNotice(noticeStr)
	local nm = NW.msg("GUILD.CS.GUILD_CHANGE_DESC")
	nm:writeString(noticeStr)
	NW.send(nm)
end

--公会申请开关
function P.RequestChangeSetting(isOpen)
	local nm = NW.msg("GUILD.CS.GUILD_CHANGE_SETTING")
	nm:writeU32(isOpen and 0 or 1)
	NW.send(nm)
end

--获取公会列表
function P.RequestGetGuildList()
	local nm = NW.msg("GUILD.CS.GET_GUILD_LIST")
	NW.send(nm)
end

--搜索公会
function P.RequestSearchGuild(searchKey)
	local nm = NW.msg("GUILD.CS.SEARCH_GUILD")
	nm:writeString(searchKey)
	NW.send(nm)
end

--申请公会
function P.RequestApplyGuild(guildID)
	local nm = NW.msg("GUILD.CS.APPLY_JOIN_GUILD")
	nm:writeU32(guildID)
	NW.send(nm)
end

--退出公会
function P.RequestQuitGuild()
	local nm = NW.msg("GUILD.CS.GUILD_QUIT")
	NW.send(nm)
end

--获取申请列表
function P.RequestGetApplyList()
	local nm = NW.msg("GUILD.CS.GET_GUILD_APPLY_LIST")
	NW.send(nm)
end

--处理公会申请
function P.RequestDealApply(userID, isAgree)
	local nm = NW.msg("GUILD.CS.GUILD_OPERATE")
	nm:writeU32(isAgree and 2 or 1)
	nm:writeU64(userID)
	NW.send(nm)
end

--修改职位 pos：0-普通成员 1-管理员 2-会长
function P.RequestModifyPosition(userID, position)
	local nm = NW.msg("GUILD.CS.GUILD_CHANGE_JOB")
	nm:writeU64(userID)
	nm:writeU32(position)
	NW.send(nm)
end

--公会踢人
function P.RequestKickOut(userID)
	local nm = NW.msg("GUILD.CS.GUILD_KICK_OUT")
	nm:writeU64(userID)
	NW.send(nm)
end

--获取公会日志列表
function P.RequestGetGuildLog()
	local nm = NW.msg("GUILD.CS.GET_GUILD_LOG_LIST")
	NW.send(nm)
end

--解散公会
function P.RequestDissolveGuild()
	local nm = NW.msg("GUILD.CS.DISSOLUTION_GUILD")
	NW.send(nm)
end

--取消解散公会
function P.RequestCancelDissolveGuild()
	local nm = NW.msg("GUILD.CS.CANCEL_DISSOLUTION_GUILD")
	NW.send(nm)
end

--确认解散公会
function P.RequestConfirmDissolveGuild()
	local nm = NW.msg("GUILD.CS.CONFIRM_DISSOLUTION_GUILD")
	NW.send(nm)
end

--获取建筑信息列表
function P.RequestGetBuildingInfo()
	local nm = NW.msg("GUILD.CS.GET_BUILDING_INFO")
	NW.send(nm)
end

--公会捐献
function P.RequestDonate(buildingID, stallID)
	local nm = NW.msg("GUILD.CS.GUILD_DONATE")
	nm:writeU32(buildingID)
	nm:writeU32(stallID)
	NW.send(nm)
end

--获取公会建设排行榜
function P.RequestGetDonateRankList()
	local nm = NW.msg("GUILD.CS.GET_BUILDING_DONATE_RANK")
	NW.send(nm)
end

--获取公会Buff兑换列表
function P.RequestGetGuildBuffList()
	local nm = NW.msg("GUILD.CS.GET_GUILD_BUFF_LIST")
	NW.send(nm)
end

--兑换公会Buff
function P.RequestExchangeBuff(buffID, buffLevel)
	local nm = NW.msg("GUILD.CS.GUILD_EXCHANGE_BUFF")
	nm:writeU32(buffID)
	nm:writeU32(buffLevel)
	NW.send(nm)
end

--领取公会福利
function P.RequestReceiveWelfare(welfareID)
	local nm = NW.msg("GUILD.CS.GAIN_WELFARE_REWARD")
	nm:writeU32(welfareID)
	NW.send(nm)
end

--获取公会派遣信息
function P.RequestGetDispatchInfo()
	local nm = NW.msg("GUILD.CS.GET_DISPATCH_INFO")
	NW.send(nm)
end

--修改公会机器人零件
function P.RequestChangeMechparts(mechpartsID)
	local nm = NW.msg("GUILD.CS.CHANGE_MECH_PART")
	nm:writeU32(mechpartsID)
	NW.send(nm)
end

--派遣
function P.RequestDispatch(mapID, dispatchType)
	local nm = NW.msg("GUILD.CS.GUILD_DISPATCH")
	nm:writeU32(mapID)--派遣地图ID
	nm:writeU32(dispatchType) -- 1-功勋 2-金币
	NW.send(nm)
end

NW.GUILD = P