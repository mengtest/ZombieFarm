--
-- @file    ui/battle/lc_wndattackedwarn.lua
-- @author  xingweizhen
-- @date    2018-01-20 16:56:53
-- @desc    WNDAttackedWarn
--

local self = ui.new()
setfenv(1, self)

local function tween_attacked(obj, Inf)
	if obj == CTRL.selfId and Inf.change < 0 then
		libugui.DOTween("Alpha", Ref.ElmMask, 0.5, 0, { duration = 0.5, })
	end
end

--!* [开始] 自动生成函数 *--
--!* [结束] 自动生成函数  *--

function init_view()
	--!* [结束] 自动生成代码 *--
end

function init_logic()
	CTRL.subscribe("HEALTH_CHANGED", tween_attacked)
end

function show_view()
	
end

function on_recycle()
	CTRL.unsubscribe("HEALTH_CHANGED", tween_attacked)
	libugui.SetAlpha(Ref.ElmMask, 0)
end

return self

