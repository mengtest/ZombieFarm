--
-- @file    ui/login/lc_wndchangename.lua
-- @author  xingweizhen
-- @date    2018-05-09 11:08:36
-- @desc    WNDChangeName
--

local self = ui.new()
local _ENV = self

local function chk_name_legal(text)
	local errText = _G.PKG["ui/util"].chk_name_legal(text)

	if errText == nil then errText = self.Illegals[text] end
	if errText then return string.format(TEXT.fmtWARNING, errText) end
end

local function on_chname_timer(Tm)
	local btnConfirm = Ref.SubMain.SubOp.btnConfirm
	if Tm and not Tm.paused then
		libugui.SetText(GO(btnConfirm, "lbText"), os.secs2time(nil, Tm.count))
	else
		btnConfirm.interactable = true
		libugui.SetText(GO(btnConfirm, "lbText"), TEXT["v.modify"])
	end
end

--!* [开始] 自动生成函数 *--

function on_submain_subop_btnconfirm_click(btn)
	local name = Ref.SubMain.inpNewName.text
	local warningTxt = chk_name_legal(name)
	Ref.SubMain.lbWarning.text = warningTxt or ""
	if not warningTxt then
		local Params = { hint = true }
		local free = DY_DATA:get_player().nChangeName == 0
		if free then
			Params.tips = TEXT.AskConsumption.ChangeName.firstTips
		end
		local Cost = _G.DEF.Item.gen(config("paylib").get_dat("ChangeName"))
		if free then Cost.amount = 0 end
		UI.MBox.consume(Cost, "ChangeName", function ()
			NW.send(NW.msg("PLAYER.CS.NAME_CHANGE"):writeString(name))
		end, Params)
	end
end
--!* [结束] 自动生成函数  *--

function on_submain_inpnewname_submit(inp, text)
	Ref.SubMain.lbWarning.text = chk_name_legal(text) or " "
end

function init_view()
	--!* [结束] 自动生成代码 *--

	self.Illegals = {}
end

function init_logic()
	local Player = DY_DATA:get_player()
	local SubMain = Ref.SubMain

	local free = Player.nChangeName == 0
	libugui.SetVisible(SubMain.SubOp.lbFreeTip, free)
	-- 不能为空，布局会自动忽略空的label
	SubMain.lbWarning.text = " "

	local Pay = config("paylib").get_dat("ChangeName")
	SubMain.SubOp.lbAmount.text = string.tag(Pay.amount, { s = free and "" or nil, })

	local Tm = _G.DY_TIMER.get_timer("ChName")
	if Tm and not Tm.paused then
		SubMain.SubOp.btnConfirm.interactable = false
		Tm:subscribe_counting(Ref.go, on_chname_timer)
	end
	on_chname_timer(Tm)
end

function show_view()

end

function on_recycle()

end

Handlers = {
	["PLAYER.SC.NAME_CHANGE"] = function (Ret)
		if Ret.err then
			--self.Illegals[Ref.SubMain.inpNewName.text] = Ret.err
		else
			self:close()
		end
	end,
}

return self

