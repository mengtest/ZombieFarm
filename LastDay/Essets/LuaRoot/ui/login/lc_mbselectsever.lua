--
-- @file    ui/login/lc_mbselectsever.lua
-- @author  shenbingkang
-- @date    2018-10-22 14:23:11
-- @desc    MBSelectServer
--

local self = ui.new()
local _ENV = self

local LOGIN = _G.PKG["network/login"]
local BATCH_AMOUNT = 50

local SERVER_STATUS = {
	{name = TEXT.ServerStatus_Fast, icon = "Common/ico_log_04"},
	{name = TEXT.ServerStatus_Hot, icon = "Common/ico_log_06"},
	{name = TEXT.ServerStatus_Slow, icon = "Common/ico_log_05"},
	{name = TEXT.ServerStatus_Preserve, icon = "Common/ico_log_08"},
}

local function init_serverlist()
	self.myServerList = {}
	if Session.Data.myServerList then
		for _,serverId in ipairs(Session.Data.myServerList) do
			self.myServerList[serverId] = true
		end
	end

	self.ServerList = {}
	for _,v in ipairs(ServerInf.List) do
		table.insert(self.ServerList, v)
	end

	local curSelectedServerId = Session.Server.id
	self.myServerList[curSelectedServerId] = true

	table.sort(self.ServerList, function(a, b)
		-- 排最近登陆
		if a.id == curSelectedServerId then
			return true
		elseif b.id == curSelectedServerId then
			return false
		end

		-- 排已有账号
		if self.myServerList[a.id] and self.myServerList[b.id] == nil then
			return true
		elseif self.myServerList[a.id] == nil and self.myServerList[b.id] then
			return false
		end

		return a.id < b.id
	end)
end

local function rfsh_serverlist_view()
	init_serverlist()
	
	local GrpServer = Ref.SubServerList.SubServers.SubScroll.SubView.GrpServer
	libugui.SetLoopCap(GrpServer.go, #ServerList, true)
end

--!* [开始] 自动生成函数 *--

function on_server_ent(go, i)
	local index = i + 1
	ui.index(go, index)

	local Server = ServerList[index]
	local Ent = ui.ref(go)
	Server:show_view(Ent)
	libugui.SetVisible(Ent.spCheck, self.myServerList[Server.id])
end

function on_subserverlist_subservers_subscroll_subview_grpserver_entserver_click(btn)
	_G.UI.MBox.operate("SelectServerAlert", function ()
		local index = ui.index(btn)
		LOGIN.CacheServer = ServerList[index]
		LOGIN.CacheAccount = true
		LOGIN.logout()
	end)
end
--!* [结束] 自动生成函数  *--

function init_view()
	ui.group(Ref.SubServerList.SubServers.SubScroll.SubView.GrpServer)
	ui.group(Ref.SubServerList.SubServers.GrpStatus)
	--!* [结束] 自动生成代码 *--
end

function init_logic()
	self.Session = LOGIN.get_session()
	self.ServerInf = Session.ServerInf

	Ref.SubServerList.SubServers.GrpStatus:dup(#SERVER_STATUS, function (i, Ent, isNew)
		local status = SERVER_STATUS[i]
		Ent.lbStatus.text = status.name
		ui.seticon(Ent.spStatus, status.icon)
	end)

	if ServerInf.List == nil then
		LOGIN.try_server_list(0, BATCH_AMOUNT)
	else
		rfsh_serverlist_view()
	end
end

function show_view()
	
end

function on_recycle()
	
end

Handlers = {
	["CLIENT.SC.SERVER_LIST"] = function (Ret)
		rfsh_serverlist_view()
	end,
}

return self

