--
-- @file    ui/login/lc_wndnotice.lua
-- @author  xingweizhen
-- @date    2018-06-07 09:56:43
-- @desc    WNDNotice
--

local self = ui.new()
local _ENV = self
--!* [开始] 自动生成函数 *--
--!* [结束] 自动生成函数  *--

function init_view()
	--!* [结束] 自动生成代码 *--
end

function init_logic()
	local Act = _G.PKG["network/login"].get_session().Act
	if Act then
		Ref.SubMain.SubScroll.SubView.lbContent.text = "<pos=5%>" .. Act.content
		Ref.SubMain.lbTitle.text = Act.title
	else
		Ref.SubMain.SubScroll.SubView.lbContent.text = TEXT.emptyNotice
		Ref.SubMain.lbTitle.text = TEXT.notice
	end
end

function show_view()

end

function on_recycle()

end

return self

