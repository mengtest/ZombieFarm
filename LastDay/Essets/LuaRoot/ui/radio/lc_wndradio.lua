--
-- @file    ui/radio/lc_wndradio.lua
-- @author  shenbingkang
-- @date    2018-07-23 11:52:20
-- @desc    WNDRadio
--

local self = ui.new()
local _ENV = self

self.StatusBar = {
	AssetBar = true,
	HealthyBar = true,
}

local eventlib = config("eventlib")
local tasklib = config("tasklib")

local dragPrePos

local totalLength = 360 * 6
local curRot = 0
local offset = 0.5

local curShowingEventID
local radioRate = 20
local function rfsh_all_event_pos()
	local GrpEventPoint = Ref.SubMain.SubModifyRadio.SubCtrl.SubPointer.GrpEventPoint
	local Events = Context.Data.Events
	local showEventList = {}
	for i,v in pairs(Events) do
		if v.state == 3 or v.state == -1 then
			table.insert(showEventList, v)
		end
	end

	GrpEventPoint:dup(#showEventList, function (i, Ent, isNew)
		local eventInfo = showEventList[i]
		local xPos = radioCtrlSize.x * eventInfo.pos / radioRate
		libugui.SetAnchoredPos(Ent.go, UE.Vector3(xPos, 0, 0))
	end)

end

local function add_answerdesc_to_info(message,answerDescs)
	for i,v in ipairs(answerDescs) do
		if v.text then
			message = message..v.text
		end
	end
	return message
end

local function rfsh_radio_event_info(event)
	local SubRadioInfo = Ref.SubMain.SubRadioInfo
	local eventID = event and event.id or nil
	if curShowingEventID == eventID and curShowingEventID ~= nil then
		return
	end

	libunity.StopAllCoroutine(SubRadioInfo.SubScroll.go)

	curShowingEventID = eventID
	if eventID == nil then
		SubRadioInfo.SubScroll.SubView.lbInfo.text = nil
		libunity.SetActive(SubRadioInfo.btnAccept, false)
		return
	end

	local eventInfo = eventlib.get_event_dat(eventID)
	local message

	if eventInfo then
		local adstr = tostring(eventInfo.answerDescription)
        local ad = adstr:totablearray("|", "$", "text", "delay")

		if event.state == 3 then
			message = add_answerdesc_to_info(eventInfo.callDescription,ad)
		else
			message = eventInfo.callDescription
			self.answerDescs = ad
		end
	else
		eventInfo = tasklib.get_dat(eventID)
		local adstr = tostring(eventInfo.answerDescription)
        local ad = adstr:totablearray("|", "$", "text", "delay")
		if event.state == 3 then
			message = add_answerdesc_to_info(eventInfo.callDescription,ad)
		else
			message = eventInfo.callDescription
			self.answerDescs = ad
		end
	end
	
	SubRadioInfo.SubScroll.SubView.lbInfo.text = message

	local canAccept = event.state == 1 or event.state == -1
	libunity.SetActive(SubRadioInfo.btnAccept, canAccept)
	if event.state == 1 then
		event.state = -1 -- （-1:已被探索）
	end
	rfsh_all_event_pos()
end

local function get_radio_event(rate)
	local Events = Context.Data.Events
	local rateH = rate * radioRate
	for _,v in pairs(Events) do
		if v.pos > (rateH - offset) and v.pos < (rateH + offset) then
			return v
		end
	end
	return nil
end

local function rfsh_pointer(delta)
	curRot = curRot - delta
	if curRot < 0 then
		curRot = 0
	elseif curRot > totalLength then 
		curRot = totalLength
	end

	local rate = curRot / totalLength
	local xPos = radioCtrlSize.x * rate
	libugui.SetAnchoredPos(SubPointer.spPointer, UE.Vector3(xPos, 0, 0))

	libunity.StopAllCoroutine(Ref.SubMain.SubRadioInfo.SubScroll.go)
	local radioEvent = get_radio_event(rate)
	rfsh_radio_event_info(radioEvent)
end
local function start_show_answerdesc()
	if self.answerDescs then
		for i,v in ipairs(self.answerDescs) do
			local subscroll = Ref.SubMain.SubRadioInfo.SubScroll
			if v.text then
				subscroll.SubView.lbInfo.text = subscroll.SubView.lbInfo.text .. v.text
			else
    			coroutine.yield()
			end
			local scroll = subscroll.go:GetComponent("ScrollRect")

        	libugui.DOTween(nil, scroll, nil, 0, { duration = 0.2 })
        	local v_delay = 1
        	if v.delay and tonumber(v.delay) then
        		v_delay = tonumber(v.delay)/1000
        	else
        		libunity.LogW(v)
        	end
    		coroutine.yield(v_delay)
		end
    else
    	coroutine.yield()
    end
end

local  function refresh_events(newevent)
	for i,v in ipairs(Context.Data.Events) do
		if newevent.id == v.id then
			v = newevent
			return
		end
	end
	table.insert(Context.Data.Events,newevent) 
end 
--!* [开始] 自动生成函数 *--

function on_submain_subradioinfo_btnaccept_click(btn)
	if curShowingEventID then
		local rate = curRot / totalLength
		local radioEvent = get_radio_event(rate)
		radioEvent.state = 3

		libunity.SetActive(Ref.SubMain.SubRadioInfo.btnAccept, false)
		
		libunity.StopAllCoroutine(Ref.SubMain.SubRadioInfo.SubScroll.go)
		libunity.StartCoroutine(Ref.SubMain.SubRadioInfo.SubScroll.go, start_show_answerdesc)

		NW.op_produce(Context.obj, 6, curShowingEventID)
	end
end

function on_submain_submodifyradio_subdrag_drag(evt, data)
	local dragPos = libugui.ScreenPoint2Local(data.position, SubDrag.go)

	local angle = UE.Vector3.Angle(dragPrePos, dragPos)
	local cross = UE.Vector3.Cross(dragPrePos, dragPos);
    if cross.z < 0 then
        angle = -angle;
	end

	local newAngle = spDrag.transform.localEulerAngles.z + angle
	spDrag.transform.localEulerAngles = UE.Vector3(0, 0, newAngle)

	rfsh_pointer(angle)
	dragPrePos = dragPos
end

function on_submain_submodifyradio_subdrag_ptrdown(evt, data)
	dragPrePos = libugui.ScreenPoint2Local(data.position, SubDrag.go)
end

function on_submain_submodifyradio_subdrag_ptrup(evt, data)
	dragPrePos = nil
end
--!* [结束] 自动生成函数  *--

function init_view()
	ui.group(Ref.SubMain.SubModifyRadio.SubCtrl.SubPointer.GrpEventPoint)
	--!* [结束] 自动生成代码 *--
	
	ui.find("FRMExplore").set_visible(false)
end

function init_logic()
	self.StatusBar.Menu = {
		icon = "CommonIcon/ico_main_063",
		name = "WNDRadio",
		Context = Context,
	}

	self.SubDrag = Ref.SubMain.SubModifyRadio.SubDrag
	self.spDrag = SubDrag.spDrag
	self.SubPointer = Ref.SubMain.SubModifyRadio.SubCtrl.SubPointer
	self.radioCtrlSize = libugui.GetRectSize(SubPointer.go)
	rfsh_pointer(0)
	rfsh_all_event_pos()
end

function show_view()
	
end

function on_recycle()
	libgame.UnitBreak(0)

	local Wnd = ui.find("FRMExplore")
	if Wnd then Wnd.set_visible(true) end
end

Handlers = {
	["PRODUCE.SC.PRODUCEINFO"] = function (Ret)
		if Ret.err == nil then
			local Produce = Ret.Produce
			if Produce.produceType == 7 then
				for i,v in ipairs(Produce.Events) do
					refresh_events(v)
				end
				--Context.Data.Events = Produce.Events
				--rfsh_pointer(0)
				--rfsh_all_event_pos()
			end
		end
	end,
}

return self

