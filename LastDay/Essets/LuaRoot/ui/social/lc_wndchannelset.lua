--
-- @file    ui/social/lc_wndchannelset.lua
-- @author  Administrator
-- @date    2018-09-13 18:00:19
-- @desc    WNDChannelSet
--

local self = ui.new()
local _ENV = self
--!* [开始] 自动生成函数 *--
local chatchannel =  127
function on_submain_grphint_enthint_tglhint_click(tgl)
	local GrpHint = Ref.SubMain.GrpHint
	local index  = ui.index(tgl)
	
	local pos = channels[index]
	local state = (1 << pos-1)

	if tgl.value then
		chatchannel = chatchannel | state
	else
		state = ~state
		chatchannel = chatchannel & state
	end
end

function on_submain_subop_btnconfirm_click(btn)
	DY_DATA.ChannelSet = chatchannel
	Settings["chat.channel.set"] = chatchannel
	_G.Prefs.Settings:save()
	local wnd = ui.find("WNDChat")
   wnd.change_channels_set(chatchannel)
	self:close()
end
--!* [结束] 自动生成函数  *--

function init_view()
	ui.group(Ref.SubMain.GrpHint)
	--!* [结束] 自动生成代码 *--
	self.Settings = _G.Prefs.Settings:load()

end

function init_logic()
	local settingVal = DY_DATA.ChannelSet
	
	if settingVal then
		chatchannel = settingVal
	end
	local ChatChannelName = TEXT.ChatChannelName
	local SortedChannelName = {}
	self.channels = {}
	for k,v in pairs(CVar.ChatChannel) do
		if v ~= CVar.ChatChannel.BLACK and v ~= CVar.ChatChannel.WORLD  then
			if v == CVar.ChatChannel.STRANGER or v == CVar.ChatChannel.FRIEND then
				local radioAch = DY_DATA.Achieves[_G.CVar.Achieves.RADIO]
				if radioAch then
					table.insert(SortedChannelName, ChatChannelName[v])
					table.insert(channels, v)
				end
			elseif 	v == CVar.ChatChannel.GUILD then 
				local player = DY_DATA:get_player()
				if player.guildID ~= 0 then
					table.insert(SortedChannelName, ChatChannelName[v])
					table.insert(channels, v)
				end
			else
				table.insert(SortedChannelName, ChatChannelName[v])
				table.insert(channels, v)
			end
		end
	end

	local GrpHint = Ref.SubMain.GrpHint

	GrpHint:dup(#SortedChannelName, function (i, Ent, isNew)
		local pos = channels[i]
		local state = (1 << pos-1)

		local isopen =   chatchannel & state
	
		Ent.tglHint.value = (isopen>> pos-1) == 1
		
		Ent.lbHint.text = SortedChannelName[i]
	end)
end

function show_view()
	
end

function on_recycle()
	
end

return self

