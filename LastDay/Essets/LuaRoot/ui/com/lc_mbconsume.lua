--
-- @file    ui/com/lc_mbconsume.lua
-- @author  xingweizhen
-- @date    2018-04-24 16:42:39
-- @desc    MBConsume
--

local self = ui.new()
local _ENV = self

local function on_reset_shop_fin(tm)
	return true
end

local function on_reset_shop_timer(tm)
	local SubInfo = Ref.SubMain.SubInfo
	if tm.count == 0 then
		libunity.SetActive(SubInfo.spRefresh, false)
		libunity.SetActive(GO(SubInfo.btnRefresh, "SubCost"), false)
		libunity.SetActive(GO(SubInfo.btnRefresh, "lbFree"), true)
		return
	end
	libunity.SetActive(SubInfo.spRefresh, true)
	SubInfo.lbRefreshTime.text = tm:to_time_string()
end

local function rfsh_content_view()
	local SubMain = Ref.SubMain
	local Params = _G.UI.MBox.get().Params

	-- 标题
	SubMain.lbTitle.text = Params.title

	local Cost = Params.Cost
	local CostBase = Cost:get_base_data()

	-- 内容
	local content = string.format(TEXT.fmtAskConsumeCost,
		Cost.amount, "#000000", CostBase.name, Params.oper)
	local tips = Params.tips
	if tips then content = content .. "\n" .. tips end
	SubMain.lbContent.text = content

	libugui.SetSprite(GO(SubMain.SubOp.btnConfirm, "spIcon"), CostBase.icon)
	libugui.SetText(GO(SubMain.SubOp.btnConfirm, "lbAmount"), Cost.amount)

	-- 不使用hint
	-- libunity.SetActive(SubMain.SubHint.go, not Params.hint)
	-- if not Params.hint then
	-- 	SubMain.SubHint.lbHint.text = TEXT.tipNoMoreConsumeHint
	-- end

	if Params.lastCnt then
		libunity.SetActive(SubMain.SubInfo.go, true)
		SubMain.SubInfo.lbLastCnt.text = string.format(TEXT.LastPayCount, Params.lastCnt)
		if Params.validityTime then
			local leftTime = Params.validityTime - os.date2secs()
			if leftTime < 0 then leftTime = 0 end
			local tm = DY_TIMER.replace_timer("ConsumeResetTime",
				leftTime, leftTime, on_reset_shop_fin)
			tm:subscribe_counting(Ref.go, on_reset_shop_timer)
			on_reset_shop_timer(tm)
		end
	else
		libunity.SetActive(SubMain.SubInfo.go, false)
	end
end

--!* [开始] 自动生成函数 *--

function on_submain_subhint_tglhint_click(tgl)

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
	rfsh_content_view()
end

function show_view()

end

function on_recycle()
	DY_TIMER.stop_timer("ConsumeResetTime")
end

return self

