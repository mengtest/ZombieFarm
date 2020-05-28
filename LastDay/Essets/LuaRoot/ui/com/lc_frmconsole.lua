--
-- @file    ui/com/lc_frmconsole.lua
-- @author  xingweizhen
-- @date    2017-10-31 18:44:05
-- @desc    FRMConsole
--

local self = ui.new()
setfenv(1, self)

--!* [开始] 自动生成函数 *--

function on_inpcmd_submit(inp, text)
	local CONSOLE = _G.PKG["framework/console/console"]
	CONSOLE.parse_cmd(text)
	self:close()
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

