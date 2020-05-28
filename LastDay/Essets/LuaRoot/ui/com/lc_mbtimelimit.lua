--
-- @file    ui/com/lc_mbtimelimit.lua
-- @author  xingweizhen
-- @date    2018-05-31 09:53:13
-- @desc    MBTimeLimit
--

local self = ui.new()
local _ENV = self

local function rfsh_content_view()
	local SubMain = Ref.SubMain
	local Params = _G.UI.MBox.get().Params

	-- 内容
	SubMain.lbContent.text = Params.content

	-- 子内容
	local intro = Params.intro
	SubMain.lbIntro.text = intro
	libunity.SetActive(SubMain.lbIntro, intro)

	local SubOp = SubMain.SubOp
	libunity.SetActive(SubOp.go, Params.Options == nil)
	libunity.SetActive(SubMain.tglMenu, Params.Options ~= nil)
	if Params.Options then
		libugui.SetText(GO(SubMain.btnMenu, "&lbText"),
		Params.txtOption or TEXT.options)
		-- 菜单
		Ref.GrpMenu:dup(#Params.Options, function (i, Ent, isNew)
			Ent.lbOption.text = Params.Options[i].text
		end)
	else
		libugui.SetText(GO(SubOp.btnConfirm, "&lbText"),
			Params.txtConfirm or TEXT["v.confirm"])

		libunity.SetActive(SubOp.btnCancel, Params.mode == "cancel")
		libunity.SetActive(SubMain.btnClose, Params.mode == "close")
		if Params.mode == "cancel" then
			libugui.SetText(GO(SubOp.btnCancel, "&lbText"),
				Params.txtCancel or TEXT["v.cancel"])
		end
	end

	-- 倒计时
	libugui.DOTween(nil, SubMain.barTime, 0, 1, {
			duration = Params.time,
			complete = _G.UI.MBox.on_btncancel_click,
		})
end

--!* [开始] 自动生成函数 *--

function on_grpmenu_entoption_click(btn)
	local Option = _G.UI.MBox.get().Params.Options[ui.index(btn)]
	if Option and Option.action then Option.action() end
	_G.UI.MBox.on_btnconfirm_click()
end

function on_submain_btnclose_click(btn)
	_G.UI.MBox.on_btncancel_click()
end

function on_submain_subop_btncancel_click(btn)
	_G.UI.MBox.on_btncancel_click()
end

function on_submain_subop_btnconfirm_click(btn)
	_G.UI.MBox.on_btnconfirm_click()
end
--!* [结束] 自动生成函数  *--

function init_view()
	ui.group(Ref.GrpMenu)
	--!* [结束] 自动生成代码 *--
end

function init_logic()
	libugui.SetAlpha(Ref.GrpMenu.go, 0)
	Ref.SubMain.tglMenu.value = false

	rfsh_content_view()
end

function show_view()

end

function on_recycle()

end

return self

