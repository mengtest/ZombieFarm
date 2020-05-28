--
-- @file    ui/login/lc_wndserver.lua
-- @author  xingweizhen
-- @date    2017-11-02 15:52:48
-- @desc    WNDServer
--

local self = ui.new()
setfenv(1, self)

local LOGIN = _G.PKG["network/login"]
local BATCH_AMOUNT = 50

local function get_recommend_servers()
	local ServerInf = Session.ServerInf
	return ServerInf.Recommend or {}
end

local function get_played_servers()
	local List = ServerBatchList.Played
	if List == nil then
		List = {}
		ServerBatchList.Played = List
	end

	return List
end

local function get_batch_servers(fIdx, tIdx)
	local ServerInf = Session.ServerInf
	local List = ServerBatchList[fIdx]
	if List == nil then
		if ServerInf.List == nil then return end
		local maxAmount = #ServerInf.List
		if maxAmount < fIdx then return end

		List = {}
		for i=fIdx,math.min(tIdx, maxAmount) do
			table.insert(List, ServerInf.List[i])
		end
		ServerBatchList[fIdx] = List
	end
	return List
end

local function rfsh_serverlist_view()
	local GrpServer = Ref.SubServerList.SubServers.SubScroll.SubView.GrpServer
	libugui.SetLoopCap(GrpServer.go, #ServerList, true)
end

local function start_view()
	libunity.SetActive(Ref.SubServerList.go, false)
	local ServerInf = Session.ServerInf
	Session.Server = ServerInf.Default
	Session.Server:show_view(Ref.SubServer)
end

local function init_servers_frame()
	local checkedTab = 1

	self.ServerTabs = {}
	
	table.insert(ServerTabs, { name = TEXT.DefServerTabs[1], getter = get_recommend_servers, })
	table.insert(ServerTabs, { name = TEXT.DefServerTabs[2], getter = get_played_servers, })

	local pos = #ServerTabs + 1

	local ServerInf = Session.ServerInf
	local nTotal = ServerInf.nTotal
	for i=1,nTotal,BATCH_AMOUNT do
		local fIdx, tIdx = i, math.min(i + BATCH_AMOUNT, nTotal)
		table.insert(ServerTabs, 3, {
				name = string.format(TEXT.fmtServerTab, fIdx, tIdx),
				getter = function () return get_batch_servers(fIdx, tIdx) end,
			})
	end

	Ref.SubServerList.SubServers.GrpTabs:dup(#ServerTabs, function (i, Ent, isNew)
		local Tab = ServerTabs[i]
		Ent.lbTab.text = Tab.name
		Ent.lbChkTab.text = Tab.name

		if i == checkedTab then Ent.tgl.value = true end
	end)
end

local function set_submain_active(isActive)
	libunity.SetActive(Ref.SubServer.go, isActive)
	libunity.SetActive(Ref.btnEnter, isActive)
	libunity.SetActive(Ref.SubServerList.go, isActive)
end

--!* [开始] 自动生成函数 *--

function on_subserver_click(btn)
	local ServerInf = Session.ServerInf
	if ServerInf.List == nil then
		LOGIN.try_server_list(0, BATCH_AMOUNT)
	else
		libunity.SetActive(Ref.SubServerList.go, true)
		init_servers_frame()
	end
end

function on_btnenter_click(btn)
	LOGIN.try_enter_game()
end

function on_subserverlist_subservers_grptabs_enttab_click(tgl)
	local getter = ServerTabs[ui.index(tgl)].getter
	self.ServerList = getter()
	if ServerList then
		rfsh_serverlist_view()
	end
end

function on_server_ent(go, i)
	local index = i + 1
	ui.index(go, index)

	local Server = ServerList[index]
	local Ent = ui.ref(go)
	Server:show_view(Ent)
	libugui.SetVisible(Ent.spCheck, Server == Session.Server)
end

function on_subserverlist_subservers_subscroll_subview_grpserver_entserver_click(btn)
	local index = ui.index(btn)
	Session.Server = ServerList[index]
	libunity.SetActive(Ref.SubServerList.go, false)
	Session.Server:show_view(Ref.SubServer)
end

function on_subserverlist_subservers_btnhide_click(btn)
	libunity.SetActive(Ref.SubServerList.go, false)
end
--!* [结束] 自动生成函数  *--

function init_view()
	ui.group(Ref.SubServerList.SubServers.GrpTabs)
	ui.group(Ref.SubServerList.SubServers.SubScroll.GrpStatus)
	ui.group(Ref.SubServerList.SubServers.SubScroll.SubView.GrpServer)
	--!* [结束] 自动生成代码 *--

	local _, AssetsVer = libasset.GetVersion()
	Ref.lbVer.text = "Ver: " .. AssetsVer.version

	self.Session = LOGIN.get_session()
	--self.ServerInf = Session.ServerInf
	self.ServerBatchList = {}
end

function init_logic()

	set_submain_active(not LOGIN.AutoEnterGame)
	
	start_view()

	if LOGIN.CacheServer then
		Session.Server = LOGIN.CacheServer
		LOGIN.CacheServer = nil
		Session.Server:show_view(Ref.SubServer)
	end

	if LOGIN.AutoEnterGame then
		LOGIN.try_enter_game()
	end
end

function show_view()

end

function on_recycle()
	libugui.AllTogglesOff(Ref.SubServerList.SubServers.GrpTabs.go)
end

Handlers = {
	["CLIENT.SC.SERVER_LIST"] = function (Ret)
		if libunity.IsActive(Ref.SubServerList.go) then
			rfsh_serverlist_view()
		else
			libunity.SetActive(Ref.SubServerList.go, true)
			init_servers_frame()
		end
	end,

	["LOGIN.SC.LOGIN"] = function (Ret)
		if Ret.err == nil then
			if Ret.RanNames then
				-- 进入创角
				ui.open("UI/WNDRoleCreation", nil, Ret.RanNames)
			end
		else
			libunity.Invoke(Ref.go, 1, function ()
				_G.UI.MBox.operate("ReloginAlert", nil, nil, true):set_event(
					function ()
						LOGIN.try_enter_game()
					end,
					function ()
						UE.Application.Quit()
					end
				):show()
			end)
			--set_submain_active(true)
		end
	end,
}

return self

