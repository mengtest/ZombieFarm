--
-- @file    ui/com/lc_wnddeath.lua
-- @author  shenbingkang
-- @date    2018-08-14 14:16:07
-- @desc    WNDDeath
--

local self = ui.new()
local _ENV = self

local SCREEN_GRAY_TIME = 1
local SCREEN_GRAY_STAY_TIME = 4
local DEATH_WINDOW_FADEIN_TIME = 0.3
local objMainCamera

local function coroutine_death_fx()
	for _,wnd in ui.foreach_lcwnds() do
		if wnd.go ~= Ref.go then
			if wnd.set_visible then
				wnd.set_visible(false)
			else
				wnd:close()
			end
		end
	end
	coroutine.yield()
	local Wnd = ui.find("FRMExplore")
	if Wnd then Wnd.set_visible(false) end

	objMainCamera = UE.GameObject.FindGameObjectWithTag("MainCamera")

	local screenGrayEndTime = UE.Time.time + SCREEN_GRAY_TIME
	libunity.SendMessage(objMainCamera, "BegineScreenGrayFx", SCREEN_GRAY_TIME)
	while UE.Time.time <= screenGrayEndTime do
		coroutine.yield()
	end

	local screenGrayStayEndTime = UE.Time.time + SCREEN_GRAY_STAY_TIME
	while UE.Time.time <= screenGrayStayEndTime do
		coroutine.yield()
	end

	local fadeInTime = UE.Time.time + DEATH_WINDOW_FADEIN_TIME
	while UE.Time.time <= fadeInTime do
		libugui.SetAlpha(Ref.go, 1 - ((fadeInTime - UE.Time.time) / DEATH_WINDOW_FADEIN_TIME))
		coroutine.yield()
	end
end

--!* [开始] 自动生成函数 *--

function on_submain_btnrelive_click(btn)
	NW.get("GameTcp"):send(NW.msg("ROLE.CS.ROLE_REVIVAL"))
end
--!* [结束] 自动生成函数  *--

function init_view()
	--!* [结束] 自动生成代码 *--
end

function init_logic()
	objMainCamera = UE.GameObject.FindGameObjectWithTag("MainCamera")

	local SubMain = Ref.SubMain
	SubMain.lbDeath.text = Context.deathTitle
	SubMain.lbDeathReason.text = Context.deathReason
	SubMain.lbLiveTime.text = TEXT.fmtLiveTime:csfmt(os.last2string(Context.liveTime, 4, nil, 2))

	libugui.SetAlpha(Ref.go, 0)

	libunity.StartCoroutine(Ref.go, coroutine_death_fx)
end

function show_view()
	
end

function on_recycle()
	libunity.SendMessage(objMainCamera, "StopScreenGrayFx")
end

Handlers = {
	["ROLE.SC.ROLE_REVIVAL"] = function (Ret)
		if Ret.err == nil then
			self:close()
		end
	end,
}

return self

