--
-- @file    ui/com/lc_wndsettingoption.lua
-- @author  Administrator
-- @date    2018-10-16 16:29:47
-- @desc    WNDSettingOption
--

local self = ui.new()
local _ENV = self

local function ShowElva()
	local Player = DY_DATA:get_player()
	local playerName = Player.name
	local playerUid = Player.id

	local Session = _G.PKG["network/login"].get_session()
	local serverId = Session.Server.serverId

end 

local function ShowFAQs()
	
end 

--!* [开始] 自动生成函数 *--

function on_submain_grpnode_btngamesetting_click(btn)
	
end

function on_submain_grpnode_btnlanguage_click(btn)
	
end

function on_submain_grpnode_btnaccount_click(btn)
	
end

function on_submain_grpnode_btngiftexchange_click(btn)
	
end

function on_submain_grpnode_btngamehelp_click(btn)
	local MenuArr = {}
	table.insert(MenuArr,{name =_G.TEXT["ContactCustomerService"],callback = ShowElva })
	table.insert(MenuArr,{name =_G.TEXT["FAQ"],callback = ShowFAQs })
	local UserCard = { 
	subTitle = _G.TEXT["GameHelp"],
	MenuArr = MenuArr

	}
	ui.show("UI/MBOption",0 , UserCard)
end
--!* [结束] 自动生成函数  *--

function init_view()
	--!* [结束] 自动生成代码 *--
end

function init_logic()
	
end

function show_view()
	
end

function on_recycle()
	
end

return self

