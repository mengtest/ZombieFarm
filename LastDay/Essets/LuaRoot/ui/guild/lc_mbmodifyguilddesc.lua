--
-- @file    ui/guild/lc_mbmodifyguilddesc.lua
-- @author  shenbingkang
-- @date    2018-09-07 15:01:45
-- @desc    MBModifyGuildDesc
--

local self = ui.new()
local _ENV = self
--!* [开始] 自动生成函数 *--

function on_submain_subop_btnconfirm_click(btn)
	NW.GUILD.RequestModifyGuildDesc(Ref.SubMain.inpModifyDesc.text)
end
--!* [结束] 自动生成函数  *--

function init_view()
	--!* [结束] 自动生成代码 *--
end

function init_logic()
	local MyGuildInfo = DY_DATA.MyGuildInfo
	Ref.SubMain.inpModifyDesc.text = MyGuildInfo.guildDesc
end

function show_view()
	
end

function on_recycle()
	
end

Handlers = {
	["GUILD.SC.GUILD_CHANGE_DESC"] = function(err)
		if err == nil then
			self:close()
		end
	end,
}

return self

