--
-- @file 	ui/_tool/netwaiting.lua
-- @anthor  xing weizhen (xingweizhen@firedoggame.com)
-- @date	2016-10-24 17:09:53
-- @desc    描述
--

local P = {}
local NetWaiting
local SHOW_DELAY = 3
local InvokeTAG = "NET_WAITING"

local function coro_net_mask()
	libugui.SetAlpha(NetWaiting.SubMain.go, 1)
end

local function coro_timeout()
	P.hide()
end

local function repeatint_rot(i, spRot)
	libunity.SetEuler(spRot, 0, 0, -45 * i)
end

function P.show(text, delay, timeout, msg)
	if P.msg == nil then P.msg = msg end

	if text == nil then text = TEXT.tipConnecting end
	if delay == nil then delay = SHOW_DELAY end
	if timeout == nil then timeout = 30 end

	libunity.CancelInvoke(InvokeTAG)

	local go = NetWaiting and NetWaiting.go
	local activated = libunity.IsEnable(go, "Canvas")
	if #text == 0 and activated then
		libunity.Invoke(go, delay, coro_net_mask, nil, InvokeTAG)
		libunity.Invoke(go, timeout, coro_timeout, nil, InvokeTAG)
	return end

	if not activated then
		go = ui.create("UI/SubNetWaiting", 100)
		if NetWaiting == nil or NetWaiting.go ~= go then
			NetWaiting = ui.ref(go)
		end
	end

	local SubMain = NetWaiting.SubMain
	-- SubMain.lbText.text = text
	-- libunity.SetActive(SubMain.spBack, #text > 0)
	libunity.CancelInvoke("NET_ROTATE")
	libunity.InvokeRepeating(go, 0, 0.1, repeatint_rot, SubMain.spRot, "NET_ROTATE")

	libugui.SetAlpha(SubMain.go, 0)
	libunity.Invoke(go, delay, coro_net_mask, nil, InvokeTAG)
	libunity.Invoke(go, timeout, coro_timeout, nil, InvokeTAG)
end

function P.hide(msg)
	if msg and P.msg and msg ~= P.msg then return end
	P.msg = nil
	if P.is_active() then
		ui.close(NetWaiting.go)
	end
end

function P.is_active()
	return NetWaiting and libunity.IsEnable(NetWaiting.go, "Canvas")
end

_G.UI.Waiting = P
