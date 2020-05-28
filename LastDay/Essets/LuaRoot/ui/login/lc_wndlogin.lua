--
-- @file    ui/login/lc_wndlogin.lua
-- @author  xingweizhen
-- @date    2017-11-02 10:59:04
-- @desc    WNDLogin
--

local self = ui.new()
setfenv(1, self)

local function get_account(index)
	local Accounts = _G.PKG["network/login"].load_account()
	if index then
		return Accounts.List[index]
	end
	return Accounts.List
end

local function show_account(Acc)
	local SubMain = Ref.SubMain
	if Acc then
		SubMain.inpAcc.text = Acc.acc
		SubMain.inpPass.text = "password"
	else
		SubMain.inpAcc.text = nil
		SubMain.inpPass.text = nil
	end
end

local function start_view()
	local SubScroll = Ref.SubMain.SubScroll
	SubScroll.go:SetActive(false)

	local AccountList = get_account()
	local LastAcc = AccountList[1]
	show_account(LastAcc)
	local GrpAccs = SubScroll.SubView.SubContent.GrpAccs
	GrpAccs:dup(#AccountList, function (i, Ent, isNew)
		local Acc = AccountList[i]
		Ent.lbAcc.text = Acc.acc
	end)
end

local function update_host_tag(tgl)
	local defTag = rawget(_G.ENV, release) and "Release" or "Inner"
	self.hostTag = tgl.value and "Extra" or defTag
	_G.PKG["network/channel"].update_host(self.hostTag)
end

local function auto_kingsgroup_login()
	libunity.SetActive(Ref.SubMain.go, false)
	
	_G.UI.Waiting.show(TEXT.LoginKgSdkWaiting, 0 , 60)
end

local function auto_dxacount_login()
	local AccountList = get_account()
	local LastAcc = AccountList[1]
	_G.PKG["network/login"].try_login(LastAcc.acc, LastAcc.pass)
end

local function auto_login()
	libugui.SetInteractable(Ref.SubMain.btnKG ,false)
	--使用自动登陆
	if not _G.ENV.development then
		 auto_kingsgroup_login()
		 return
	end

	local CacheAccount = _G.PKG["network/login"].CacheAccount
	_G.PKG["network/login"].CacheAccount = nil
	if CacheAccount then
		auto_dxacount_login()
	end
end

--!* [开始] 自动生成函数 *--

function on_submain_inpacc_submit(inp, text)

end

function on_submain_inppass_submit(inp, text)

end

function on_submain_btncorfirm_click(btn)
	_G.PKG["network/channel"].switch_pid()

	local SubMain = Ref.SubMain
	local acc = SubMain.inpAcc.text
	local pass = SubMain.inpPass.text
	_G.PKG["network/login"].try_login(acc, pass)
end

function on_kglogin_click(btn)
	
end


function on_submain_subscroll_subview_subcontent_btnclear_click(btn)
	_G.PKG["network/login"].clear_account()

	Ref.SubMain.SubScroll.SubView.SubContent.GrpAccs:hide()
	Ref.SubMain.tglList.value = false
end

function on_submain_subscroll_subview_subcontent_grpaccs_entacc_click(tgl)
	if tgl.value then
		local Acc = get_account(ui.index(tgl))
		show_account(Acc)

		Ref.SubMain.tglList.value = false
	end
end

function on_submain_tgllist_click(tgl)
	local value = tgl.value
	Ref.SubMain.SubScroll.go:SetActive(value)
	if value then
		local GrpAccs = Ref.SubMain.SubScroll.SubView.SubContent.GrpAccs
		local tglAcc = libugui.GetTogglesOn(GrpAccs.go)[1]
		if tglAcc then
			local inAcc = Ref.SubMain.inpAcc.text
			local Acc = get_account(ui.index(tglAcc))
			if Acc == nil or Acc.acc ~= inAcc then
				tglAcc.value = false
			end
		end
	end
end

function on_submain_tglinnernet_click(tgl)
	update_host_tag(tgl)
end
--!* [结束] 自动生成函数  *--

function init_view()
	ui.group(Ref.SubMain.SubScroll.SubView.SubContent.GrpAccs)
	--!* [结束] 自动生成代码 *--

	Ref.SubMain.tglInnerNet.value = rawget(_G.ENV, release)

	local _, AssetsVer = libasset.GetVersion()
	Ref.lbVer.text = "Ver: " .. AssetsVer.version
end

function init_logic()
	local cacheHostTag = _G.PKG["network/channel"].hostTag
	if cacheHostTag then
		_G.PKG["network/channel"].update_host(cacheHostTag)
	else
		update_host_tag(Ref.SubMain.tglInnerNet)
	end

	start_view()

	auto_login()
end

function show_view()

end

function on_recycle()
	Ref.SubMain.tglList.value = false
end

Handlers = {
	["CLIENT.SC.VERIFY"] = function (Ret)
		--_G.UI.Waiting.hide()
		if Ret.retCode == 1 then
			ui.open("UI/WNDServer")
		else
			libunity.Invoke(Ref.go, 1, function ()
				_G.UI.MBox.operate("ReloginAlert", nil, nil, true):set_event(
					function ()
						auto_login()
					end,
					function ()
						UE.Application.Quit()
					end
				):show()
			end)
		end
	end,
}

return self

