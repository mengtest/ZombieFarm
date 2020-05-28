-- File Name : framework/notify.lua

local FocusEvents = {}

local function send_pause_switch(paused)
	local nm = NW.msg("LOGIN.CS.SWITCH_NOHUP")
	nm:writeU32(paused and 1 or 2)
	NW.send(nm)
end

local function on_app_pause(paused)
	print("on_app_pause", paused)
	if paused then
		return
	end
	send_pause_switch(paused)
end

local function on_app_focus(focus)
	print("on_app_focus", focus)
	for _,event in pairs(FocusEvents) do event(focus) end
end

local function on_alert_click(msg)
	-- print("on_alert_click", msg)
	local AlertCBF = DY_DATA.AlertCBF
	local cbf = AlertCBF[msg]
	if cbf then
		cbf()
		AlertCBF[msg] = nil
	end
end

-- 收到内存警告
local function on_mem_warning(msg)

end

local function subscribe_focus(key, value)
	FocusEvents[key] = value
end

local function unsubscribe_focus(key)
	FocusEvents[key] = nil
end

return {
	on_app_pause = on_app_pause,
	on_app_focus = on_app_focus,
	on_alert_click = on_alert_click,
	on_mem_warning = on_mem_warning,
	subscribe_focus = subscribe_focus,
	unsubscribe_focus = unsubscribe_focus,
}
