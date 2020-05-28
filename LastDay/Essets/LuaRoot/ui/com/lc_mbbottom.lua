--
-- @file    ui/com/lc_mbbottom.lua
-- @author  shenbingkang
-- @date    2018-05-15 14:20:06
-- @desc    MBBottom
--

local self = ui.new()
local _ENV = self

function rfsh_content_view()
	local tweenDura = 0.2
	local SubMain = Ref.SubMain
	local Params = _G.UI.MBox.get().Params

	--设置标题
	local strTitle = Params.title
	if strTitle then
		SubMain.lbTitle.text = strTitle
		libunity.SetActive(SubMain.lbTitle ,true)
		libunity.SetActive(SubMain.elmSEP ,true)
	else
		libunity.SetActive(SubMain.lbTitle ,false)
		libunity.SetActive(SubMain.elmSEP ,false)
	end

	--设置提示框文本
	local strContent = Params.content
	SubMain.lbContent.text = strContent

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

	--初始化SubMain面板位置
	local size = libugui.GetRectSize(SubMain.go, true)
	local toPos = UE.Vector2(0, size.y)

	libugui.SetAnchoredPos(SubMain.go , 0, 0)
	libugui.DOTween("Position", SubMain.go, nil, toPos, { duration = tweenDura })
end

function hide_content_view(callback)
	local tweenDura = 0.2
	local SubMain = Ref.SubMain

	libugui.DOTween("Position", SubMain.go, nil, UE.Vector2.zero, { 
		duration = tweenDura,
		complete = callback,
	})
end

--!* [开始] 自动生成函数 *--

function on_submain_subop_btncancel_click(btn)
	local Params = _G.UI.MBox.get().Params
	if not Params.single then
		_G.UI.MBox.on_btncancel_click()
	end
end

function on_submain_subop_btnconfirm_click(btn)
	_G.UI.MBox.on_btnconfirm_click()
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
end

return self

