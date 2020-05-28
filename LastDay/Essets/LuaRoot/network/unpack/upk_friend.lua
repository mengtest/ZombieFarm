--
-- @file    network/unpack/upk_friend.lua
-- @author  shenbingkang
-- @date    2018-06-19 11:32:00
-- @desc    描述
--

local NW, P = _G.NW, {}

--黑名单数据版本号
local blackListVersion =0

--好友申请列表数据版本号
local applyListVersion = 0
--玩家查看的申请列表版本号
local hadCheckApplyVersion

local onlineStateDict = {}

local function read_FriendBaseData(nm)
	local roleId = nm:readU64()
	local player = _G.DEF.Player.new(roleId)
	player:read_friendInfo(nm)
	--NW.read_RoleBaseData(nm, player)

	--player.guildID = nm:readU32()
	--player.guildName = nm:readString()
	--player.guildIcon = nm:readString()
	--player.lastTime = nm:readU64()
	--player.serverid = nm:readString()
	--player.isOnline = nm:readU32() == 1
	return player
end

local function read_online_state(nm)
	local userID = nm:readU64()
	onlineStateDict[userID] = 1
	return userID
end
local function change_redpoint_state()
	local redState = applyListVersion ~= hadCheckApplyVersion and #DY_DATA.friendApplyList>0
	DY_DATA.RedSystem:SetRedDotState(CVar.RedDotName.FriendApply,redState)
end
local  function my_friendlist_comp(element1,element2)
 	if element1 == nil then
 		return false
 	end
 	if element2 == nil then
 		return true
 	end

 	if element1.isOnline then
 		if element2.isOnline then
 			return element1.level > element2.level
 		else
 			return true
 		end
 	else
 		if element2.isOnline then
 			return false
 		else
			return element1.level > element2.level
 		end
 	end
end

local function check_recentlymets(friendid)
	for i,v in ipairs(NW.CHAT.RecentlyMets) do
 		if v.id == friendid then
 			table.remove(NW.CHAT.RecentlyMets,i)
 			break
 		end
	end
end

local function add_friend(nm)
	local friendInfo = read_FriendBaseData(nm)
	for i,v in ipairs(DY_DATA.friendList) do
		if v.id == friendInfo.id then
			return
		end
	end
	table.insert(DY_DATA.friendList, friendInfo)
	check_recentlymets(friendInfo.id)

end

local function remove_friend(nm)
	local targetId = nm:readU64()
	DY_DATA:remove_friend_info(targetId, "FRIEND")
end

local function apply_friend(nm)
	local friendInfo = read_FriendBaseData(nm)
	for i,v in ipairs(DY_DATA.friendApplyList) do
		if v.id == friendInfo.id then
			return
		end
	end
	table.insert(DY_DATA.friendApplyList, friendInfo)
end

local function add_black(nm)
	local friendInfo = read_FriendBaseData(nm)
	for i,v in ipairs(DY_DATA.blackList) do
		if v.id == friendInfo.id then
			return
		end
	end
	table.insert(DY_DATA.blackList, friendInfo)
end

local function update_friend_info(nm)
	local friendInfo = read_FriendBaseData(nm)

	DY_DATA:update_friend_info(friendInfo, "FRIEND")
end

function P.hadCheckApplyList()
	hadCheckApplyVersion = applyListVersion
	change_redpoint_state()
end

function P.check_isfriend(targetId)
	local isfriend = false
	for i,v in ipairs(DY_DATA.friendList) do
		if targetId == v.id then
			isfriend = true
			break
		end
	end
	return isfriend
end
--========================================SC协议========================================

NW.regist("FRIEND.SC.FRIEND_LIST", function (nm)
	local ret, err = NW.chk_op_ret(nm:readU32(), true)
	if err == nil then
		local ver =  nm:readU32()
		if not DY_DATA.friendListVersion  or DY_DATA.friendListVersion ~= ver then
			DY_DATA.friendListVersion = ver
			nm:readArray({}, add_friend)
			table.sort(DY_DATA.friendList, my_friendlist_comp)
		end
	end
end)

NW.regist("FRIEND.SC.FRIEND_ONLINE_STATE", function (nm)
	local ret, err = NW.chk_op_ret(nm:readU32(), true)
	if err == nil then
		local synchronization = nm:readU32()

		onlineStateDict = {}
		nm:readArray({}, read_online_state)

		for _,v in pairs(DY_DATA.friendList) do
			if synchronization > 0 then
				v.isOnline = onlineStateDict[v.id] == 1
			elseif onlineStateDict[v.id] then
				v.isOnline =  true
			end
		end
		for _,v in pairs(DY_DATA.blackList) do
			if synchronization > 0 then
				v.isOnline = onlineStateDict[v.id] == 1
			elseif onlineStateDict[v.id] then
				v.isOnline =  true
			end
		end
		for _,v in pairs(DY_DATA.friendApplyList) do
			if synchronization > 0 then
				v.isOnline = onlineStateDict[v.id] == 1
			elseif onlineStateDict[v.id] then
				v.isOnline =  true
			end
		end
	end
end)

NW.regist("FRIEND.SC.FRIEND_APPLY_LIST", function (nm)
	local ret, err = NW.chk_op_ret(nm:readU32(), true)
	if err == nil then
		local  applyVersion = nm:readU32()

		if applyVersion ~= applyListVersion then
			applyListVersion = applyVersion
			DY_DATA.friendApplyList = nm:readArray({}, read_FriendBaseData)
		end

		change_redpoint_state()
	end
end)

NW.regist("FRIEND.SC.FRIEND_APPLY_OPERATE", function (nm)
	local ret, err = NW.chk_op_ret(nm:readU32())
	if err == nil then
		--local isAgree = nm:readU32() == 1 --1同意 2拒绝
		local userID = nm:readU64()
		DY_DATA:remove_friend_info(userID, "APPLYLIST")

		--if isAgree then
		--	table.insert(DY_DATA.friendList, friendInfo)
		--	debug.print(DY_DATA.friendList)
		--end

		return true
	end
	return false
end)

NW.regist("FRIEND.SC.FRIEND_APPLY_ADD", function (nm)
	local ret, err = NW.chk_op_ret(nm:readU32())
	if err == nil then
		local userID = nm:readU64()
		UI.Toast.norm(TEXT["HadSendApply"])
		return true
	end
	return false
end)

NW.regist("FRIEND.SC.FRIEND_RECOMMEND_LIST", function (nm)
	local ret, err = NW.chk_op_ret(nm:readU32())
	if err == nil then
		local rocommendList = nm:readArray({}, function (nm)
			local player = read_FriendBaseData(nm)
			player.bHasApplied = nm:readU32() == 1
			return player
		end)
		return rocommendList
	end
	return {}
end)

NW.regist("FRIEND.SC.FRIEND_REMOVE", function (nm)
	local ret, err = NW.chk_op_ret(nm:readU32())
	if err == nil then
		local userID = nm:readU64()
		--DY_DATA:remove_friend_info(userID, "FRIEND")

		return true
	end
	return false
end)

NW.regist("FRIEND.SC.FRIEND_MEMBER_INFO", function (nm)
	local operateType = nm:readU32()
	 --1.添加好友  2.删除好友 3.申请好友 4.添加黑名單 5.好友信息变更
	if operateType == 1 then
		add_friend(nm)
	elseif operateType == 2 then
		remove_friend(nm)
	elseif operateType == 3 then
		apply_friend(nm)
		hadCheckApplyVersion = nil
		change_redpoint_state()
	elseif operateType == 4 then
		add_black(nm)
	elseif operateType == 5 then
		update_friend_info(nm)
	end
	return operateType
end)

NW.regist("FRIEND.SC.JOIN_BLACKLIST", function (nm)
	local ret, err = NW.chk_op_ret(nm:readU32())
	if err == nil then
		--add_black(nm)
		return true
	end
	return false
end)

NW.regist("FRIEND.SC.REMOVE_BLACKLIST", function (nm)
	local ret, err = NW.chk_op_ret(nm:readU32())
	if err == nil then
		local userID = nm:readU64()
		DY_DATA:remove_friend_info(userID, "BLACKLIST")

		return true
	end
	return false
end)

NW.regist("FRIEND.SC.FRIEND_SEARCH", function (nm)
	local friendInfo = nm:readArray({}, read_FriendBaseData)
	return friendInfo
end)

NW.regist("FRIEND.SC.FRIEND_BLACK_LIST", function (nm)
	local ret, err = NW.chk_op_ret(nm:readU32(), true)
	if err == nil then
		local  blackVersion = nm:readU32()
		if blackListVersion ~= blackVersion then
			blackListVersion = blackVersion
			DY_DATA.blackList = nm:readArray({}, read_FriendBaseData)
		end
	end
end)

--========================================CS协议========================================

function P.RequestGetFriendList()
	--好友列表只请求一次
	local nm = NW.msg("FRIEND.CS.FRIEND_LIST")
	nm:writeU32(DY_DATA.friendListVersion or 0)
	NW.MainCli:send(nm)
end

function P.RequestFriendOnlineState()
	local nm = NW.msg("FRIEND.CS.FRIEND_ONLINE_STATE")
	NW.MainCli:send(nm)
end

function P.RequestGetApplyList()
	local nm = NW.msg("FRIEND.CS.FRIEND_APPLY_LIST")
	nm:writeU32(applyListVersion)
	NW.MainCli:send(nm)
end

function P.RequestApplyOperate(userID, isAgree)
	local nm = NW.msg("FRIEND.CS.FRIEND_APPLY_OPERATE")
	nm:writeU64(userID)
	nm:writeU32(isAgree and 1 or 2)
	NW.MainCli:send(nm)
end

function P.RequestAddFriend(userID)
	-- if _G.PKG["game/uicheck"].check_ahievement(CVar.Achieves.RADIO) then

	-- end
	local radioAch = DY_DATA.Achieves[_G.CVar.Achieves.RADIO]
	if radioAch then
		local nm = NW.msg("FRIEND.CS.FRIEND_APPLY_ADD")
		nm:writeU64(userID)
		NW.MainCli:send(nm)
	else
		UI.Toast.norm(TEXT["AddFriendPrerequisite"])
	end
end

function P.RequestGetRecommendList()
	local nm = NW.msg("FRIEND.CS.FRIEND_RECOMMEND_LIST")
	NW.MainCli:send(nm)
end

function P.RequestRemoveFriend(userID)
	local nm = NW.msg("FRIEND.CS.FRIEND_REMOVE")
	nm:writeU64(userID)
	NW.MainCli:send(nm)
end

function P.RequestAddBlackList(userID)
	local nm = NW.msg("FRIEND.CS.JOIN_BLACKLIST")
	nm:writeU64(userID)
	NW.MainCli:send(nm)
end

function P.RequestRemoveBlackList(userID)
	local nm = NW.msg("FRIEND.CS.REMOVE_BLACKLIST")
	nm:writeU64(userID)
	NW.MainCli:send(nm)
end

function P.RequestFriendSearch(userID)
	local nm = NW.msg("FRIEND.CS.FRIEND_SEARCH")
	nm:writeString(userID)
	NW.MainCli:send(nm)
end

function P.RequestGetBlackList()
	local nm = NW.msg("FRIEND.CS.FRIEND_BLACK_LIST")
	nm:writeU32(blackListVersion)
	NW.MainCli:send(nm)
end

function P.OnPrivateChat(userId,userName,depth,from)
	local wnd = ui.find("WNDChatNew")
	local Receiver = {id = userId, name = userName}
	if wnd then
		wnd.on_privat_chat(Receiver)
	else
		local Bag = {
						PrivateChat = Receiver
					}
		Bag.title = TEXT["n.chat"]
		Bag.pageIcon = "CommonIcon/ico_main_058"

		ui.open("UI/WNDChatNew", depth, Bag)
	end
end
function P.OnRemoveFriAddBlack(userId,userName,depth,from)
	local  needremovefriend = P.check_isfriend(userId)

	if needremovefriend then
		P.RequestRemoveFriend(userId)
	end
	P.RequestAddBlackList(userId)
end

function  P.OnAddFriend(userId,userName,depth,from)
	P.RequestAddFriend(userId)
end
NW.FRIEND = P
