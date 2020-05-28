--
-- @file    ui/com/lc_mbnormal.lua
-- @author  xingweizhen
-- @date    2018-04-09 14:22:15
-- @desc    MBNormal
--

-- @anthor  xingweizhen
-- @date    2017-08-31 08:50:21
-- @desc    MBNormal
--

local self = ui.new()
setfenv(1, self)

local function rfsh_content_view()
	local SubMain = Ref.SubMain
	local Params = _G.UI.MBox.get().Params

	-- 标题
	local title = Params.title
	libunity.SetActive(SubMain.lbTitle, title)
	if title then SubMain.lbTitle.text = title end

	-- 内容
	SubMain.lbContent.text = Params.content

	-- 子内容
	local intro = Params.intro
	SubMain.lbIntro.text = intro
	libunity.SetActive(SubMain.lbIntro, intro)

	-- 操作按钮
	local TEXT = _G.TEXT
	local SubOp = SubMain.SubOp

	libugui.SetText(GO(SubOp.btnConfirm, "&lbText"),
		Params.txtConfirm or TEXT["v.confirm"])

	libunity.SetActive(SubOp.btnCancel, not Params.single)
	if not Params.single then
		libugui.SetText(GO(SubOp.btnCancel, "&lbText"),
			Params.txtCancel or TEXT["v.cancel"])
	end

	libunity.SetActive(SubOp.btnOption, Params.txtOption)
	if Params.txtOption then
		libugui.SetText(GO(SubOp.btnOption, "&lbText"), Params.txtOption)
	end

	--设置操作按钮颜色
	local UTIL = _G.PKG["ui/util"]
	UTIL.set_interact_style(SubOp.btnCancel, Params.cancelStyle or "Orange")
	UTIL.set_interact_style(SubOp.btnConfirm, Params.confirmStyle or "Yellow")
	UTIL.set_interact_style(SubOp.btnOption, Params.optionStyle or "Blue")

	--设置是否显现关闭按钮
	libunity.SetActive(SubMain.btnClose, Params.show_close_button)

	-- 倒计时
	libunity.SetActive(SubMain.spTime, Params.time)
	if Params.time then
		local Tm = Params.time
		if type(Tm) == "number" then
			Tm = DY_TIMER.replace_timer("MBNormal", Tm, Tm)
		end
		Tm:subscribe_counting(Ref.go, function (Tm)
			if Tm.paused then
				_G.UI.MBox.close()
			else
				SubMain.lbCountdown.text = os.secs2time(nil, Tm.count)
			end
		end)
		SubMain.lbCountdown.text = os.secs2time(nil, Tm.count)
	end

	if Params.position then
		local pos = Params.position
		libunity.SetPos(SubMain.go, pos.x, pos.y, pos.z)
	else
		libunity.SetPos(SubMain.go, 0, 0, 0)
	end
end

--!* [开始] 自动生成函数 *--

function on_btnback_click(btn)
	local Params = _G.UI.MBox.get().Params
	if not Params.single and not Params.limitBack then
		_G.UI.MBox.on_btncancel_click()
	end
end

function on_submain_btnclose_click(btn)
	_G.UI.MBox.close()
end

function on_submain_subop_btncancel_click(btn)
	_G.UI.MBox.on_btncancel_click()
end

function on_submain_subop_btnconfirm_click(btn)
	_G.UI.MBox.on_btnconfirm_click()
end

function on_submain_subop_btnoption_click(btn)
	_G.UI.MBox.on_btnaction("option")
end
--!* [结束] 自动生成函数  *--

function init_view()
	--!* [结束] 自动生成代码 *--
end

function init_logic()
	rfsh_content_view()
end

function show_view()

end

function on_recycle()
	DY_TIMER.stop_timer("MBNormal")
end

return self

