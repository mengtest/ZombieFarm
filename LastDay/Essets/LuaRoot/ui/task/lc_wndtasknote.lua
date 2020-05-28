--
-- @file    ui/task/lc_wndtasknote.lua
-- @author  shenbingkang
-- @date    2018-09-18 17:07:40
-- @desc    WNDTaskNote
--

local self = ui.new()
local _ENV = self

local tasklib = config("tasklib")
local itemlib = config("itemlib")

local ToggleList = {
	[1] = "btnMainTask",
	[2] = "btnTLTask",
}

local FLIP_PAGE_TIME = 0.6

local function forceUpdateMainTaskSelected(go)
	libunity.SetParent(self.spMainTaskSelected, go, false, 1)
	libunity.SetActive(self.spMainTaskSelected, true)
end

local function rfsh_chapter_reward_btn_state()
	local SubDetail = Ref.SubMain.SubView.SubMainTask.SubTaskReward.SubDetail
	local state = DY_DATA.MainTaskChapter[CurChapterIndex]
	libugui.SetInteractable(SubDetail.btnReceive, state == 1)
	local showBtn = state ~= 2
	libunity.SetActive(SubDetail.btnReceive, showBtn)
	libunity.SetActive(SubDetail.spReceived, not showBtn)
	
	local receiveStr = state == 2 and TEXT.Received or TEXT.Receive
	libugui.SetText(GO(SubDetail.btnReceive, "lbText_"), receiveStr)
end

local function rfsh_main_task_view()
	local CurChapterIndex = self.CurChapterIndex
	local chapterInfo = tasklib.get_chapter_info(CurChapterIndex)
	local taskList = tasklib.get_chapter_task_list(CurChapterIndex)
	self.CurSelectedMainTaskIndex = 0
	libunity.SetActive(self.spMainTaskSelected, false)

	local SubMainTask = Ref.SubMain.SubView.SubMainTask

	local ForcusMainTaskID = DY_DATA.TASK.ForcusMainTaskID
	libugui.AllTogglesOff(SubMainTask.GrpMainTaskList.go)

	SubMainTask.lbTitle.text = chapterInfo.name

	local GrpMainTaskList = Ref.SubMain.SubView.SubMainTask.GrpMainTaskList
	GrpMainTaskList:dup(#taskList, function (i, Ent, isNew)
		local taskInfo = taskList[i]
		libugui.SetSizeDelta(Ent.go, nil, 56)
		libunity.SetEuler(Ent.spArrow, 0, 0, 0)

		local isForceTask = taskInfo.id == ForcusMainTaskID
		Ent.tglMark.value = isForceTask
		libugui.SetColor(GO(Ent.tglMark, "spMark"), isForceTask and "#FFFFFF" or "#9A938D")

		local taskName = taskInfo.name
		local isFinish = CurChapterIndex < DY_DATA.MainTaskChapterId
		if not isFinish then
			local taskData = DY_DATA.Tasks[taskInfo.id]
			if taskData then
				isFinish = taskData.status == "fnished"
				taskName = taskName .. string.format("(%s)", taskData.progress)
			else
				isFinish = true
			end
		end

		Ent.lbTaskName.text = taskName

		libunity.SetActive(Ent.spFinish, isFinish)
		libunity.SetActive(Ent.tglMark, not isFinish)

		Ent.lbInfo.text = "-" .. taskInfo.desc
		Ent.lbTarget.text = "-" .. taskInfo.taskTip

		local rewardStr = TEXT.None

		if #taskInfo.rewardInfo > 0 then
			rewardStr = ""
			for _,v in pairs(taskInfo.rewardInfo) do
				local itemInfo = itemlib.get_dat(v.id)
				rewardStr = rewardStr .. string.format(" %s+%d", itemInfo.name, v.amount)
			end
		end
		Ent.lbReward.text = "-" .. TEXT.TaskReward .. rewardStr

		if self.jumpToTaskId == taskInfo.id then
			self.jumpToTaskId = nil
			on_entmaintask_click(Ent.go)
		end
	end)

	rfsh_chapter_reward_btn_state()

	local chapterReward = chapterInfo.reward
	local SubDetail = SubMainTask.SubTaskReward.SubDetail
	SubDetail.GrpMainReward:dup(#chapterReward, function (i, Ent, isNew)
		UTIL.flex_itement(Ent, "SubItem", 0)
		
		local rewardData = chapterReward[i]
		local Item = _G.DEF.Item.new(rewardData.id, rewardData.amount)
		local baseItemInfo = Item:get_base_data()
		show_item_view(Item, Ent.SubItem)
	end)

	libunity.SetActive(SubMainTask.btnPreChapter, CurChapterIndex ~= 1)
	libunity.SetActive(SubMainTask.btnNextChapter, CurChapterIndex ~= tasklib.get_chapter_total_cnt())

	local showPreRed = false
	local showNextRed = false

	for k,v in pairs(DY_DATA.MainTaskChapter) do
		if v==1 then	
			if k < CurChapterIndex then
				showPreRed = true
			elseif k > CurChapterIndex then
				showNextRed = true
			end
		end	
	end

	local redPreChapter = GO(SubMainTask.btnPreChapter,"spPoint")
	libunity.SetActive(redPreChapter, showPreRed)
	local redNextChapter = GO(SubMainTask.btnNextChapter,"spPoint")
	libunity.SetActive(redNextChapter, showNextRed)
end

local function rfsh_timelimit_task_elem(target, SubTimeLimitTask, taskData)
	if taskData == nil then
		libugui.SetVisible(SubTimeLimitTask.go, false)
		return
	end
	libugui.SetVisible(SubTimeLimitTask.go, true)

	local taskInfo = tasklib.get_dat(taskData.id)

	
	local SubTask = SubTimeLimitTask.SubTask

	local taskName = taskInfo.name
	local taskData = DY_DATA.Tasks[taskInfo.id]
	local isFinish = false
	if taskData then
		isFinish = taskData.state == 3
		taskName = taskName .. string.format("(%s)", taskData.progress)
	end

	SubTask.lbTaskName.text = taskName
	libunity.SetActive(SubTask.spFinish, isFinish)
	libunity.SetActive(SubTask.tglMark, not isFinish)

	local ForcusTimeLimitTaskID = DY_DATA.TASK.ForcusTimeLimitTaskID
	local isForceTask = taskInfo.id == ForcusTimeLimitTaskID
	SubTask.tglMark.value = isForceTask
	libugui.SetColor(GO(SubTask.tglMark, "spMark"), isForceTask and "#FFFFFF" or "#9A938D")

	local SubTaskDetail = SubTask.SubTaskDetail
	SubTaskDetail.lbInfo.text = "-" .. taskInfo.desc

	SubTaskDetail.lbTarget.text = "-" .. taskInfo.taskTip

	SubTaskDetail.lbReward.text = "-" .. TEXT.TaskReward

	SubTaskDetail.GrpTLReward:dup(#taskInfo.rewardInfo, function (i, Ent, isNew)
		UTIL.flex_itement(Ent, "SubItem", 0)
		
		local rewardData = taskInfo.rewardInfo[i]
		local Item = _G.DEF.Item.new(rewardData.id, rewardData.amount)
		local baseItemInfo = Item:get_base_data()
		show_item_view(Item, Ent.SubItem)
	end)

	libugui.SetText(GO(SubTimeLimitTask.SubTask.btnReceive, "lbText_"), TEXT.Receive)
	if taskData.status == "fnished" then
		libunity.SetActive(SubTimeLimitTask.SubTask.spReceived, true)
		libunity.SetActive(SubTimeLimitTask.SubTask.btnReceive, false)
		libugui.SetInteractable(SubTimeLimitTask.SubTask.btnReceive, false)
	else
		libunity.SetActive(SubTimeLimitTask.SubTask.spReceived, false)
		libunity.SetActive(SubTimeLimitTask.SubTask.btnReceive, true)
		libugui.SetInteractable(SubTimeLimitTask.SubTask.btnReceive, taskData.status == "complete")
	end
end

local function rfsh_timelimit_task_page()
	local pageIndex = self.timeLimitTaskPageIndex
	local leftTask = self.timeLimitTaskList[pageIndex * 2 - 1]
	local rightTask = self.timeLimitTaskList[pageIndex * 2]

	local SubTimeLimitTask = Ref.SubMain.SubView.SubTimeLimitTask
	rfsh_timelimit_task_elem("SubLeftTLTask", SubTimeLimitTask.SubLeftTask, leftTask)
	rfsh_timelimit_task_elem("SubRightTLTask", SubTimeLimitTask.SubRightTask, rightTask)

	function on_timelimit_timer(tm)
        SubTimeLimitTask.lbRefreshTime.text = tm:to_time_string_hour()
        if tm.count == 0 then
            return
        end
	end
	if type(DY_DATA.NextDailyTaskRefreshTime) ~= "number" then
		DY_DATA.NextDailyTaskRefreshTime = 0
	end
    local leftTime = DY_DATA.NextDailyTaskRefreshTime - os.date2secs()
    local tm = DY_TIMER.replace_timer("DailyTaskTimer",
        leftTime, leftTime, function(_)    return true    end)
    tm:subscribe_counting(Ref.go, on_timelimit_timer)
    on_timelimit_timer(tm)

    local showBtn = self.timeLimitTaskPageIndex > 1 
	libunity.SetActive(SubTimeLimitTask.btnPreTLTaskPage,showBtn)
    local ttPageCnt = math.floor((#self.timeLimitTaskList + 1) / 2)
    showBtn = self.timeLimitTaskPageIndex ~= ttPageCnt 
    libunity.SetActive(SubTimeLimitTask.btnNextTLTaskPage,showBtn)
    
end

local function rfsh_timelimit_task_view()
	self.timeLimitTaskList = DY_DATA:get_task_list("TimeLimitTask")

	if self.jumpToTaskId then
		local taskIndex = 1
		for i,v in pairs(self.timeLimitTaskList) do
			if v.id == self.jumpToTaskId then
				taskIndex = i
				break
			end
		end
		self.jumpToTaskId = nil
		self.timeLimitTaskPageIndex = math.floor((taskIndex + 1) / 2)
	else
		self.timeLimitTaskPageIndex = 1
	end

	rfsh_timelimit_task_page()
end

local function show_task_view(SubView, isShow)
	libugui.SetAlpha(SubView.go, isShow and 1 or 0)
	libugui.SetBlockRaycasts(SubView.go, isShow)
end

local function flip_page_fx(aniState, pageCnt, flipEndCallback)
	libunity.CancelInvoke(Ref.go)
	for i=1,pageCnt do
		local fx = self.NotePageFx[i]
		libunity.Invoke(Ref.go, 0.1 * (i - 1), function ()
			libunity.SetActive(self.pageFxGo[i], true)
			self.NotePageFx[i]:Play(aniState)
			libunity.Invoke(Ref.go, FLIP_PAGE_TIME, function ()
				libunity.SetActive(self.pageFxGo[i], false)
				if i == pageCnt and flipEndCallback then
					flipEndCallback()
				end
			end)
		end)
	end
end

local function select_task_toggle(index)
	self.selectTaskType = index

	local SubLeft = Ref.SubMain.SubLeft
	local SubRight = Ref.SubMain.SubRight

	for i,v in pairs(ToggleList) do
		local btnName = ToggleList[i]
		libunity.SetActive(SubLeft[btnName], i <= index)
		libunity.SetActive(SubRight[btnName], i > index)

		local spriteName = i == index and "Common/frm_com_050" or "Common/frm_com_051"
		local taskColor = i == index and "#FFFFFF" or "#000000"
		libugui.SetSprite(GO(SubLeft[btnName], "spIcon"), spriteName)
		libugui.SetColor(GO(SubLeft[btnName], "lbTaskType"), taskColor)
	end

	local SubView = Ref.SubMain.SubView
	if index == 1 then
		show_task_view(SubView.SubMainTask, false)
		show_task_view(SubView.SubTimeLimitTask, false)
		rfsh_main_task_view()

		flip_page_fx("forword", #self.NotePageFx, function()
			show_task_view(SubView.SubMainTask, true)
		end)

	elseif index == 2 then
		show_task_view(SubView.SubMainTask, false)
		show_task_view(SubView.SubTimeLimitTask, false)
		rfsh_timelimit_task_view()

		flip_page_fx("backword", #self.NotePageFx, function()
			show_task_view(SubView.SubTimeLimitTask, true)
		end)
	end
end

--!* [开始] 自动生成函数 *--

function on_entmaintask_click(btn)
	local GrpMainTaskList = Ref.SubMain.SubView.SubMainTask.GrpMainTaskList

	local orgSelectedEnt = GrpMainTaskList:find(self.CurSelectedMainTaskIndex)
	if orgSelectedEnt then
		libugui.DOTween("Size", orgSelectedEnt.go, nil, UE.Vector2(448, 56), {
			duration = 0.1,
		})
		libugui.DOTween("Rotation", orgSelectedEnt.spArrow, nil, UE.Vector3(0, 0, 0), {
			duration = 0.1,
		})
	end

	local index = GrpMainTaskList:getindex(btn)
	local Ent = GrpMainTaskList:find(index)

	if self.CurSelectedMainTaskIndex == index then
		self.CurSelectedMainTaskIndex = 0
		libunity.SetActive(Ent.spMainTaskSelected, false)
	else
		libugui.DOTween("Size", btn, nil, UE.Vector2(448, 224), {
			duration = 0.1,
		})
		libugui.DOTween("Rotation", Ent.spArrow, nil, UE.Vector3(0, 0, 180), {
			duration = 0.1,
		})

		forceUpdateMainTaskSelected(btn)
		self.CurSelectedMainTaskIndex = index
	end
end

function on_entmaintask_tglmark_click(tgl)
	local ForcusMainTaskID = DY_DATA.TASK.ForcusMainTaskID
	local taskList = tasklib.get_chapter_task_list(self.CurChapterIndex)

	local GrpMainTaskList = Ref.SubMain.SubView.SubMainTask.GrpMainTaskList
	local index = GrpMainTaskList:getindex(tgl.transform.parent)
	local taskInfo = taskList[index]

	libugui.SetColor(GO(tgl, "spMark"), tgl.value and "#FFFFFF" or "#9A938D")

	if tgl.value then
		DY_DATA.TASK.ForcusMainTaskID = taskInfo.id
	elseif ForcusMainTaskID == taskInfo.id then
		DY_DATA.TASK.ForcusMainTaskID = nil
	end

	NW.broadcast("CLIENT.SC.TASK_FORCUS", {
		type = "MainTask",
		taskID = DY_DATA.TASK.ForcusMainTaskID,
	})
end

function on_submain_subview_submaintask_subtaskreward_subdetail_grpmainreward_entmainreward_click(evt, data)
	local rewardIndex = ui.index(evt)

	local chapterInfo = tasklib.get_chapter_info(self.CurChapterIndex)
	local rewardData = chapterInfo.reward[rewardIndex]
	local Item = _G.DEF.Item.new(rewardData.id, rewardData.amount)
	Item:show_tip(evt)
end

function on_submain_subview_submaintask_subtaskreward_subdetail_grpmainreward_entmainreward_deselect(evt, data)
	_G.DEF.Item.hide_tip()
end

function on_submain_subview_submaintask_subtaskreward_subdetail_btnreceive_click(btn)
	NW.TASK.RequestGetChapterReward(self.CurChapterIndex)
end

function on_submain_subview_submaintask_btnprechapter_click(btn)
	self.CurChapterIndex = self.CurChapterIndex - 1
	if self.CurChapterIndex < 1 then
		self.CurChapterIndex = 1
	end
	rfsh_main_task_view()
	libunity.SetActive(self.pageFxGo[1], true)
	libunity.SetActive(Ref.SubMain.SubView.go, false)

	flip_page_fx("forword", 1, function()
		libunity.SetActive(Ref.SubMain.SubView.go, true)
	end)

end

function on_submain_subview_submaintask_btnnextchapter_click(btn)
	self.CurChapterIndex = self.CurChapterIndex + 1
	if self.CurChapterIndex > DY_DATA.MainTaskChapterId then
		_G.UI.Toast.norm(TEXT.TaskFrontChapterUnfinish)
		self.CurChapterIndex = DY_DATA.MainTaskChapterId
		return
	end
	rfsh_main_task_view()
	libunity.SetActive(self.pageFxGo[1], true)
	libunity.SetActive(Ref.SubMain.SubView.go, false)

	flip_page_fx("backword", 1, function()
		libunity.SetActive(Ref.SubMain.SubView.go, true)
	end)
end

function on_submain_subview_subtimelimittask_sublefttask_subtask_subtaskdetail_grptlreward_enttlreward_click(evt, data)
	local rewardIndex = ui.index(evt)

	local pageIndex = self.timeLimitTaskPageIndex
	local leftTask = self.timeLimitTaskList[pageIndex * 2 - 1]

	local taskInfo = tasklib.get_dat(leftTask.id)
	local rewardData = taskInfo.rewardInfo[rewardIndex]
	local Item = _G.DEF.Item.new(rewardData.id, rewardData.amount)
	Item:show_tip(evt)
end

function on_submain_subview_subtimelimittask_sublefttask_subtask_subtaskdetail_grptlreward_enttlreward_deselect(evt, data)
	_G.DEF.Item.hide_tip()
end

function on_tltask_tglmark_left_click(tgl)
	local pageIndex = self.timeLimitTaskPageIndex
	local leftTask = self.timeLimitTaskList[pageIndex * 2 - 1]

	local ForcusTimeLimitTaskID = DY_DATA.TASK.ForcusTimeLimitTaskID

	libugui.SetColor(GO(tgl, "spMark"), tgl.value and "#FFFFFF" or "#9A938D")
	libugui.SetInteractable(tgl, not tgl.value)

	if tgl.value then
		DY_DATA.TASK.ForcusTimeLimitTaskID = leftTask.id
	elseif ForcusTimeLimitTaskID == leftTask.id then
		-- 必须有一个时限任务被追踪
		--DY_DATA.TASK.ForcusTimeLimitTaskID = nil
	end

	NW.broadcast("CLIENT.SC.TASK_FORCUS", {
		type = "TimeLimitTask",
		taskID = DY_DATA.TASK.ForcusTimeLimitTaskID,
	})
end

function on_submain_subview_subtimelimittask_sublefttask_subtask_btnreceive_click(btn)
	local pageIndex = self.timeLimitTaskPageIndex
	local leftTask = self.timeLimitTaskList[pageIndex * 2 - 1]

	NW.TASK.RequestGetTaskReward(leftTask.id)
end

function on_submain_subview_subtimelimittask_subrighttask_subtask_subtaskdetail_grptlreward_enttlreward_click(evt, data)
	local rewardIndex = ui.index(evt)

	local pageIndex = self.timeLimitTaskPageIndex
	local rightTask = self.timeLimitTaskList[pageIndex * 2]

	local taskInfo = tasklib.get_dat(rightTask.id)
	local rewardData = taskInfo.rewardInfo[rewardIndex]
	local Item = _G.DEF.Item.new(rewardData.id, rewardData.amount)
	Item:show_tip(evt)
end

function on_submain_subview_subtimelimittask_subrighttask_subtask_subtaskdetail_grptlreward_enttlreward_deselect(evt, data)
	_G.DEF.Item.hide_tip()
end

function on_tltask_tglmark_right_click(tgl)
	local pageIndex = self.timeLimitTaskPageIndex
	local rightTask = self.timeLimitTaskList[pageIndex * 2]
	
	local ForcusTimeLimitTaskID = DY_DATA.TASK.ForcusTimeLimitTaskID

	libugui.SetColor(GO(tgl, "spMark"), tgl.value and "#FFFFFF" or "#9A938D")
	libugui.SetInteractable(tgl, not tgl.value)

	if tgl.value then
		DY_DATA.TASK.ForcusTimeLimitTaskID = rightTask.id
	elseif ForcusTimeLimitTaskID == rightTask.id then
		-- 必须有一个时限任务被追踪
		--DY_DATA.TASK.ForcusTimeLimitTaskID = nil
	end

	NW.broadcast("CLIENT.SC.TASK_FORCUS", {
		type = "TimeLimitTask",
		taskID = DY_DATA.TASK.ForcusTimeLimitTaskID,
	})
end

function on_submain_subview_subtimelimittask_subrighttask_subtask_btnreceive_click(btn)
	local pageIndex = self.timeLimitTaskPageIndex
	local rightTask = self.timeLimitTaskList[pageIndex * 2]

	NW.TASK.RequestGetTaskReward(rightTask.id)
end

function on_submain_subview_subtimelimittask_btnpretltaskpage_click(btn)
	self.timeLimitTaskPageIndex = self.timeLimitTaskPageIndex - 1
	if self.timeLimitTaskPageIndex < 1 then
		self.timeLimitTaskPageIndex = 1
	end
	rfsh_timelimit_task_page()
end

function on_submain_subview_subtimelimittask_btnnexttltaskpage_click(btn)
	local ttPageCnt = math.floor((#self.timeLimitTaskList + 1) / 2)
	self.timeLimitTaskPageIndex = self.timeLimitTaskPageIndex + 1
	if self.timeLimitTaskPageIndex > ttPageCnt then
		self.timeLimitTaskPageIndex = ttPageCnt
	end
	rfsh_timelimit_task_page()
end

function on_btnmaintask_click(btn)
	if self.selectTaskType ~= 1 then
		select_task_toggle(1)
	end
end

function on_btntltask_click(btn)
	if self.selectTaskType ~= 2 then
		select_task_toggle(2)
	end
end
--!* [结束] 自动生成函数  *--

function init_view()
	ui.group(Ref.SubMain.SubView.SubMainTask.GrpMainTaskList)
	ui.group(Ref.SubMain.SubView.SubMainTask.SubTaskReward.SubDetail.GrpMainReward)
	ui.group(Ref.SubMain.SubView.SubTimeLimitTask.SubLeftTask.SubTask.SubTaskDetail.GrpTLReward)
	ui.group(Ref.SubMain.SubView.SubTimeLimitTask.SubRightTask.SubTask.SubTaskDetail.GrpTLReward)
	--!* [结束] 自动生成代码 *--

	self.UTIL = _G.PKG["ui/util"]
	self.show_item_view = UTIL.show_item_view

	if self.pageFxGo == nil then
		self.pageFxGo = {}
		self.NotePageFx = {}
		for i=1,4 do
			self.pageFxGo[i] = libunity.NewChild(Ref.go, "uifx/PageTurning/notes_page")
			self.NotePageFx[i] = self.pageFxGo[i]:GetComponentInChildren(typeof(UE.Animator))
			libunity.SetActive(self.pageFxGo[i], false)
		end
	end
end

function init_logic()
	local SubView = Ref.SubMain.SubView

	self.spMainTaskSelected = SubView.SubMainTask.spSelected
	libunity.SetActive(self.spMainTaskSelected, false)
	self.CurChapterIndex = DY_DATA.MainTaskChapterId
	self.CurSelectedMainTaskIndex = 0
	
	libugui.SetAlpha(SubView.SubMainTask.go, 0)
	libugui.SetAlpha(SubView.SubTimeLimitTask.go, 0)

	if Context then
		self.jumpToTaskId = Context.jumpToTaskId
		if jumpToTaskId then
			local taskType = tasklib.get_dat(jumpToTaskId).type
			if taskType == tasklib.TaskType["MainTask"] then
				select_task_toggle(1)
				return
			elseif taskType == tasklib.TaskType["TimeLimitTask"] then
				select_task_toggle(2)
				return
			end
		end
	end
	select_task_toggle(1)
end

function show_view()
	
end

function on_recycle()
	local SubView = Ref.SubMain.SubView
	libunity.SetParent(self.spMainTaskSelected, SubView.SubMainTask.go, true, -1)
	libunity.SetActive(self.spMainTaskSelected, true)
end

Handlers = {
	["TASK.SC.TASK_CHAPTER_GET"] = function()
		rfsh_chapter_reward_btn_state()
	end,
	["TASK.SC.REWARD_GET"] = function()
		rfsh_timelimit_task_page()
	end,
}

return self

