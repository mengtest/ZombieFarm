--
-- @file    ui/com/lc_wndguiding.lua
-- @author  xingweizhen
-- @date    2018-07-16 22:49:04
-- @desc    WNDGuiding
--

local self = ui.new()
local _ENV = self
local _focusTar
-- 引导焦点首次淡入时间
local FIRST_FADE_IN = 0.5
-- 引导焦点反复淡入时间
local AGAIN_FADE_IN = 0.5

local function guide_next_step()
	_focusTar = nil

	local Step, step, keyStep = move_next()
	if Step then
		API.save(Step.id, step)

		if Step.event == nil then Step.event = "click" end
		if Step.stepover == nil then Step.stepover = "click" end
		self.CurrStep = Step
		self.isKeyStep = keyStep
		libugui.SetBlockRaycasts(Ref.go, Step.block)
		libunity.StartCoroutine(Ref.go, focus_target, Step)
	else
		if Step == nil then
			print("引导完成")
			API.save(CurrStep.id, 0)
			-- 每个引导结束后触发下一个引导
			-- _G.next_action("/UIROOT", _G.PKG["datamgr/data"].launch_guide)

			self:close(true)
		else
			print("引导异常，未完成")
			self:close(true)
		end
	end
end

function focus_target(Step)
	local target = Step.target

	local guider = Ref.SubFocus.go
	local view = libunity.Find(guider, "View=")
	local style = "sp" .. (Step.style or "Circle")
	libunity.SetActive(Ref.SubFocus.spCircle, style == "spCircle")
	libunity.SetActive(Ref.SubFocus.spRect, style == "spRect")
	libunity.SetActive(Ref.SubFocus.spMask, Step.mask)
	libunity.SetActive(Ref.SubFocus.spCMask, Step.mask and style == "spCircle")
	libunity.SetActive(Ref.SubFocus.spFinger, true)

	libugui.KillTween(view)
	libugui.SetAlpha(view, 0)

	-- 让前一个协程退出
	_focusTar = nil
	coroutine.yield()

	-- 等待网络
	while _G.UI.Waiting.is_active() do coroutine.yield() end

	-- 等待自由操作
	if Step.wait then
		while not Step.wait() do coroutine.yield() end
	end

	if isKeyStep then API.save(CurrStep.id, 0) end

	-- 存在性检测
	-- 检测计数，如果超过还未找到目标，则中断该引导
	local waitForFound, waitOne = 10, 0.5
	_focusTar = API.find_target(target)
	while _focusTar == nil and waitForFound > 0 do
		coroutine.yield(waitOne)
		waitForFound = waitForFound - waitOne
		libunity.LogD("Finding {0}", target)
		_focusTar = API.find_target(target)
	end
	if _focusTar == nil then
		libunity.LogW("超时，放弃引导")
		self:close(true)
	return end

	libunity.LogD("Found {0} = {1}", target, _focusTar)
	
	local UE_Time = UE.Time
	local waitForActive = 10
	while not _focusTar.activeInHierarchy and waitForActive > 0 do
		coroutine.yield()
		waitForActive = waitForActive - UE_Time.deltaTime
	end
	if not _focusTar.activeInHierarchy then
		libunity.LogW("不可见，放弃引导")
		self:close(true)
		return
	end

	-- 引导开始 将按钮恢复
	libugui.SetInteractable(guider, true)
	libugui.SetWindowDepth("WNDGuiding", Step.block and API.WINDOW_DEPTH or 0)
	local spTips = Ref.SubFocus.spTips
	local tipsText = Step.tips and config("textlib").get_dat(Step.tips)
	Ref.SubFocus.lbTips.text = tipsText
	libunity.SetActive(spTips, tipsText ~= nil)

	local isViewVisible = libugui.IsVisible(_focusTar)
	if isViewVisible then
		libugui.DOTween("Alpha", view, 0, 1, { duration = FIRST_FADE_IN, })
	end

	coroutine.yield()

	local isOverUI = _focusTar.layer == 5
	if isOverUI then
		-- 在UI层
		local rectSize = libugui.GetRectSize(_focusTar)
		if style == "spCircle" then
			local side = (rectSize.x + rectSize.y) / 2
			if side > 150 then side = 150 elseif side < 50 then side = 50 end
			libugui.SetAnchoredSize(guider, side, side)
		else
			libugui.SetAnchoredSize(guider, rectSize.x, rectSize.y)
		end
	else
		libugui.SetAnchoredSize(guider, 100, 100)
	end
	-- local finger = libunity.Find(guider, "Finger").transform
	-- local spFinger = libunity.Find(finger, "spFinger_", "UISprite")

	local Vector2 = UE.Vector2
	local left, right, center = Vector2(0, 1), Vector2(1, 1), Vector2(0.5, 0.5)
	local waiting
	while libunity.IsObject(_focusTar) do
		if _focusTar.activeInHierarchy then
			waiting = 0.5

			local curVisible
			-- 保持跟随
			if isOverUI then
				curVisible = libugui.IsVisible(_focusTar)
				libugui.DOAnchor(guider, center, _focusTar, center)
			else
				curVisible = libunity.IsActive(_focusTar)
				local beOverlay = libugui.Overlay(guider, _focusTar)
				if curVisible then
					curVisible = beOverlay
				end
			end

			if curVisible ~= isViewVisible then
				isViewVisible = curVisible
				if curVisible then
					libugui.DOTween("Alpha", view, 0, 1, { duration = AGAIN_FADE_IN,})
				else
					libugui.KillTween(view)
					libugui.SetAlpha(view, 0)
				end
			end

			local pos = guider.transform.localPosition
			if pos.x > 0 then
				libugui.DOAnchor(spTips, right, guider, left, Vector2(-30, 0))
				-- libugui.DOAnchor(finger, "Top", guider, "Bottom")
				-- spFinger.flip = "Horizontally"
			else
				libugui.DOAnchor(spTips, left, guider, right, Vector2(30, 0))
				-- libugui.DOAnchor(finger, "Bottom", guider, "Top")
				-- spFinger.flip = "Nothing"
			end
			libugui.InsideScreen(spTips)
		else
			if waiting < 0 then
				if Step.block then
					libunity.LogW("引导异常关闭。")
					--_G.next_action(Ref.root, guide_next_step)
				else
					libunity.LogD("引导被忽略。")
				end
				self:close(true)
				break
			else
				waiting = waiting - UE_Time.deltaTime
			end
		end
		coroutine.yield()
	end
	-- 检查是否关键步骤
	-- if chk_key_step() then
	-- 	_G.next_action("/UIROOT", _G.PKG["datamgr/data"].save_clidata)
	-- end
end

local function on_subfocus_event(event, execute, data)
	if not self.flag then return end

	if libunity.IsActive(_focusTar) then
		if CurrStep[event] then
			CurrStep[event](_focusTar)
		else
			libugui.ExecuteEvent(_focusTar, execute, data)
		end

		if CurrStep.event == event then
			libugui.SetAlpha(GO(Ref.SubFocus.go, "View="), 0)
		end
		if CurrStep.stepover == event then
			libunity.SetActive(Ref.SubFocus.spFinger, false)
			libunity.Invoke(Ref.go, 0, guide_next_step)
		end
	elseif CurrStep.event == event then
		print(_focusTar, "没有激活")
	end
end

--!* [开始] 自动生成函数 *--

function on_subfocus_ptrdown(evt, data)
	self.flag = true
	on_subfocus_event("ptrdown", "PointerDown", data)
end

function on_subfocus_ptrup(evt, data)
	on_subfocus_event("ptrup", "PointerUp", data)
end

function on_subfocus_click(evt, data)
	on_subfocus_event("click", "PointerClick", data)
end

function on_subfocus_begindrag(evt, data)
	on_subfocus_event("begindrag", "BeginDrag", data)
end

function on_subfocus_drag(evt, data)
	on_subfocus_event("drag", "Drag", data)
end

function on_subfocus_enddrag(evt, data)
	on_subfocus_event("enddrag", "EndDrag", data)
end
--!* [结束] 自动生成函数  *--

function init_view()
	--!* [结束] 自动生成代码 *--

	self.API = _G.PKG["guide/api"]
end

function init_logic()
	libunity.StopAllCoroutine(Ref.go)
	move_next = Context
	guide_next_step()
end

function show_view()

end

function on_recycle()

end

return self

