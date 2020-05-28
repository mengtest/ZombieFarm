--
-- @file    ui/com/lc_wndguidingdesigning.lua
-- @author  shenbingkang
-- @date    2018-11-05 17:23:13
-- @desc    WNDGuidingDesigning
--

local self = ui.new()
local _ENV = self

local FINGER_TIME = 0.5
local FINGER_TWEEN_EASE = "OutQuad"

local tarStart = UE.Vector3(100, -100, 0)

local tar0  = UE.Vector3(0, 0, 0)
local tar1 = UE.Vector3(0, 100, 0)
local tar2 = UE.Vector3(-100, 0, 0)
local tar3 = UE.Vector3(100, 0, 0)
local tar4 = UE.Vector3(0, -100, 0)

local FINGER_STEP = {
	[1] = {tar = tar1, time = FINGER_TIME},
	[2] = {tar = tar4, time = FINGER_TIME*2},
	[3] = {tar = tar0, time = FINGER_TIME},
	[4] = {tar = tar2, time = FINGER_TIME},
	[5] = {tar = tar3, time = FINGER_TIME*2},
	[6] = {tar = tar0, time = FINGER_TIME},
}

local function do_finger_ani()
	libugui.DOTween("Position", Ref.SubFocus.spFinger, tarStart, tar0, { 
		duration = FINGER_TIME, ease = FINGER_TWEEN_EASE, 
	})
	coroutine.yield(FINGER_TIME)

	libugui.DOTween("Scale", Ref.SubFocus.spPointFocus, UE.Vector3(1,1,1), UE.Vector3(6,6,1), { 
		duration = FINGER_TIME/2, ease = FINGER_TWEEN_EASE, 
	})
	coroutine.yield(FINGER_TIME/2)
	libugui.DOTween("Scale", Ref.SubFocus.spPointFocus, nil, UE.Vector3(1,1,1), { 
		duration = FINGER_TIME/2, ease = FINGER_TWEEN_EASE, 
	})
	coroutine.yield(FINGER_TIME/2)

	while true do
		for i=1,#FINGER_STEP do
			local step = FINGER_STEP[i]
			libugui.DOTween("Position", Ref.SubFocus.spFinger, nil, step.tar, { 
				duration = step.time, 
				--ease = FINGER_TWEEN_EASE,
			})
			coroutine.yield(step.time)
		end
	end
end

--!* [开始] 自动生成函数 *--

function on_subfocus_ptrdown(evt, data)
	self.FRMDesign.on_spdrag_ptrdown(evt, data)
end

function on_subfocus_ptrup(evt, data)
	self:close()
end

function on_subfocus_click(evt, data)
	
end

function on_subfocus_begindrag(evt, data)
	self.FRMDesign.on_spdrag_begindrag(evt, data)
	libunity.SetActive(GO(Ref.SubFocus.go, "View="), false)
end

function on_subfocus_drag(evt, data)
	self.FRMDesign.on_spdrag_drag(evt, data)
end

function on_subfocus_enddrag(evt, data)
	
end
--!* [结束] 自动生成函数  *--

function init_view()
	--!* [结束] 自动生成代码 *--
end

function init_logic()
	self.FRMDesign = ui.find("FRMDesign")
	libunity.SetActive(GO(Ref.SubFocus.go, "View="), true)
	libunity.StartCoroutine(Ref.go, function()
		do_finger_ani()
	end)
end

function show_view()
	
end

function on_recycle()
	Context.API.save(Context.guideID, 0)
end

return self

