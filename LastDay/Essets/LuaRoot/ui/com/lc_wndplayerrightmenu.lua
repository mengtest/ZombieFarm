--
-- @file    ui/com/lc_wndplayerrightmenu.lua
-- @author  shenbingkang
-- @date    2018-06-12 18:29:11
-- @desc    WNDPlayerRightMenu
--

local self = ui.new()
local _ENV = self

local EMenuOperType = {
	AddFriend = 1,
	PrivateChat = 2,
	Guild_AdjAdmin = 3,
	Guild_TnfPresident = 4,
	Guild_KickOut = 5,
	Guild_AdjNormal = 6,
	InviteLocation = 7,
	Guild_Invite = 8,
	AddBlack = 9,
	RemoveFriend = 10,
	PlayerInfo = 11,
}

local function get_oper_name(operType)
	if type(operType) == "string" then
		return TEXT.RightMenu[operType] or ""
	end

	local Oper = operType
	return TEXT[Oper.name] or ""

	-- if EMenuOperType[operType] == EMenuOperType["AddFriend"] then
	-- 	return TEXT.RightMenu.AddFriend
	-- elseif EMenuOperType[operType] == EMenuOperType["PrivateChat"] then
	-- 	return TEXT.RightMenu.PrivateChat
	-- elseif EMenuOperType[operType] == EMenuOperType["Guild_AdjAdmin"] then
	-- 	return TEXT.RightMenu.Guild_AdjAdmin
	-- elseif EMenuOperType[operType] == EMenuOperType["Guild_TnfPresident"] then
	-- 	return TEXT.RightMenu.Guild_TnfPresident
	-- elseif EMenuOperType[operType] == EMenuOperType["Guild_KickOut"] then
	-- 	return TEXT.RightMenu.Guild_KickOut
	-- elseif EMenuOperType[operType] == EMenuOperType["Guild_AdjNormal"] then
	-- 	return TEXT.RightMenu.Guild_AdjNormal
	-- elseif EMenuOperType[operType] == EMenuOperType["AddBlack"] then
	-- 	return TEXT.RightMenu.AddBlack
	-- elseif EMenuOperType[operType] == EMenuOperType["InvitLocation"] then
	-- 	return TEXT.RightMenu.InviteLocation
	-- elseif EMenuOperType[operType] == EMenuOperType["RemoveFriend"] then
	-- 	return TEXT.RightMenu.RemoveFriend
	-- end

	-- return ""
end

local function rfsh_content_view()
	local anchordPos = libugui.ScreenPoint2Local(Context.pos, Ref.go)
	libugui.SetAnchoredPos(Ref.GrpMenu.go, anchordPos)

	Ref.GrpMenu:dup(#Context.MenuArr, function (i, Ent, isNew)
		Ent.lbText.text = get_oper_name(Context.MenuArr[i])
	end)

	libugui.InsideScreen(Ref.GrpMenu.go)
end

-----EVENT-----
local function do_AddFriend()
	NW.FRIEND.RequestAddFriend(Context.operUserID)
end
local function do_PrivateChat()
	local wnd = ui.find("WNDChatNew")
	local Receiver = {id = Context.operUserID, name = Context.operUserName}
	if wnd then
		wnd.on_privat_chat(Receiver)
	else
		local Bag = {
						type = 3,
						PrivateChat = Receiver
					}
		Bag.title = TEXT["n.chat"]
		Bag.pageIcon = "CommonIcon/ico_main_058"

		ui.open("UI/WNDChatNew", nil, Bag)
	end
end
local function do_AddBlack()
	local  needremovefriend = NW.FRIEND.check_isfriend(Context.operUserID)

	if needremovefriend then
		NW.FRIEND.RequestRemoveFriend(Context.operUserID)
	end
	NW.FRIEND.RequestAddBlackList(Context.operUserID)
end
local function do_Guild_AdjNormal()
	--0-普通成员 1-管理员 2-会长
	NW.GUILD.RequestModifyPosition(Context.operUserID, 0)
end
local function do_Guild_AdjAdmin()
	NW.GUILD.RequestModifyPosition(Context.operUserID, 1)
end
local function do_Guild_TnfPresident()
	NW.GUILD.RequestModifyPosition(Context.operUserID, 2)
end
local function do_Guild_KickOut()
	NW.GUILD.RequestKickOut(Context.operUserID)
end
local function do_InvitLocation()
	local Stage =  DY_DATA:get_stage()
	if Stage == nil then
		return
	end
	local EntData = config("maplib").get_ent(Stage.Base.id)

	local str =  EntData.name
	local playername = DY_DATA:get_player().name

	local contentStr = TEXT.InviteToLocation:csfmt(playername,str)
	local Receiver = {id = Context.operUserID, name = Context.operUserName}

	NW.CHAT.send(1, Receiver, 1,contentStr)
end

local function do_RemoveFriend()
	UI.MBox.make("MBNormal")
		:set_param("content", TEXT["Remove Friend"])
		:set_event(function ()
			NW.FRIEND.RequestRemoveFriend(Context.operUserID)
		end, function ()

		end)
		:show()
end

local function do_Guild_Invite()
	local playername = DY_DATA:get_player().name
	local str =string.formatnumberthousands(DY_DATA:get_player().guildChannel)

	local contentStr = TEXT.Guild_Invite:csfmt(playername, str)
	local Receiver = {id = Context.operUserID, name = Context.operUserName}
	NW.CHAT.send(1, Receiver, 1,contentStr)
end
local function do_PlayerInfo( ... )
	local UserCard = { playerId = Context.operUserID }
	ui.show("UI/MBPlayerInfoCard",0 , UserCard)
end
---------------

--!* [开始] 自动生成函数 *--

function on_grpmenu_entmenu_click(btn)
	local index = Ref.GrpMenu:getindex(btn)
	local operType = Context.MenuArr[index]

	if type(operType) == "string" then
		if EMenuOperType[operType] == EMenuOperType["AddFriend"] then
			do_AddFriend()
		elseif EMenuOperType[operType] == EMenuOperType["PrivateChat"] then
			do_PrivateChat()
		elseif EMenuOperType[operType] == EMenuOperType["Guild_AdjAdmin"] then
			do_Guild_AdjAdmin()
		elseif EMenuOperType[operType] == EMenuOperType["Guild_TnfPresident"] then
			do_Guild_TnfPresident()
		elseif EMenuOperType[operType] == EMenuOperType["Guild_KickOut"] then
			do_Guild_KickOut()
		elseif EMenuOperType[operType] == EMenuOperType["Guild_AdjNormal"] then
			do_Guild_AdjNormal()
		elseif EMenuOperType[operType] == EMenuOperType["AddBlack"] then
			do_AddBlack()
		elseif EMenuOperType[operType] == EMenuOperType["InviteLocation"] then
			do_InvitLocation()
		elseif EMenuOperType[operType] == EMenuOperType["RemoveFriend"] then
			do_RemoveFriend()
		elseif EMenuOperType[operType] == EMenuOperType["Guild_Invite"] then
			do_Guild_Invite()
		elseif EMenuOperType[operType] == EMenuOperType["PlayerInfo"] then
			do_PlayerInfo()
		end
	else
		local action = operType.action
		--Context.Args 一般格式 (userid,username,depth,from)
		if action then action(table.unpack(Context.Args)) end
	end

	self:close()
end
--!* [结束] 自动生成函数  *--

function init_view()
	ui.group(Ref.GrpMenu)
	--!* [结束] 自动生成代码 *--
end

function init_logic()
	rfsh_content_view()
end

function show_view()

end

function on_recycle()

end

return self

