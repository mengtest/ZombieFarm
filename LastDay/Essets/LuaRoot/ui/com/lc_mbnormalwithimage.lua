--
-- @file    ui/com/lc_mbnormalwithimage.lua
-- @author  shenbingkang
-- @date    2018-07-02 14:48:53
-- @desc    MBNormalWithImage
--

local self = ui.new()
local _ENV = self

local function rfsh_content_view()
	local SubMain = Ref.SubMain
	local Params = _G.UI.MBox.get().Params

	local sprBtnRed = "Common/btn_com_010"--红色按钮
	local sprBtnGreen = "Common/btn_com_007"--绿色按钮

	local cancelSpr = sprBtnRed
	local confirmSpr = sprBtnGreen

	-- 标题
	local title = Params.title
	libunity.SetActive(SubMain.lbTitle, title)
	if title then SubMain.lbTitle.text = title end

	-- 内容
	SubMain.SubContent.lbContent.text = Params.content

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

	--设置操作按钮颜色
	if Params.cancelSpr then
		cancelSpr = Params.cancelSpr
	end
	if Params.confirmSpr then
		confirmSpr = Params.confirmSpr
	end
	libugui.SetSprite(GO(SubOp.btnCancel), cancelSpr)
	libugui.SetSprite(GO(SubOp.btnConfirm), confirmSpr)
	--SubOp.btnCancel:SetSprite(cancelSpr)
	--SubOp.btnConfirm:SetSprite(confirmSpr)

	--设置是否显现关闭按钮
	libunity.SetActive(SubMain.btnClose, Params.show_close_button)

	if Params.position then
		local pos = Params.position
		libunity.SetPos(SubMain.go, pos.x, pos.y, pos.z)
	else
		libunity.SetPos(SubMain.go, 0, 0, 0)
	end
	
	--图片
	SubMain.SubContent.spPic:SetTexture(string.format("rawtex/%s/%s", Params.picture, Params.picture))

	libugui.RebuildLayout(SubMain.SubContent.go)
end

--!* [开始] 自动生成函数 *--

function on_btnback_click(btn)
	local Params = _G.UI.MBox.get().Params

	if not Params.single and not Params.limitBack  then
		_G.UI.MBox.on_btncancel_click()
	end
end

function on_submain_subop_btncancel_click(btn)
	_G.UI.MBox.on_btncancel_click()
end

function on_submain_subop_btnconfirm_click(btn)
	_G.UI.MBox.on_btnconfirm_click()
end
--!* [结束] 自动生成函数  *--

function init_view()
	--!* [结束] 自动生成代码 *--
end

function init_logic()
	
end

function show_view()
	rfsh_content_view()
end

function on_recycle()
	
end

return self

