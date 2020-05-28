--
-- @file    network/unpack/upk_task.lua
-- @anthor  xingweizhen (weizhen.xing@funplus.com)
-- @date    2018-06-27 16:48:31
-- @desc    描述
--

local NW, P = _G.NW, {}

local TaskStatus = {
	[0] = "hidden", -- 不可见
	[1] = "process", -- 接受（可见）
	[2] = "complete", -- 完成（可领取奖励）
	[3] = "fnished", -- 已经结束（不可见）
	[5] = "destroy", -- 销毁任务
}
local function sc_task_data(nm, Task)
	Task.status = TaskStatus[nm:readU32()]
	Task.endTime = math.floor(nm:readU64() / 1000)
	Task.progress = nm:readString()
	return Task
end

NW.regist("TASK.SC.TASK_GET", function (nm)
	local Tasks = DY_DATA.Tasks
	local nTask = nm:readU32()
	for i=1,nTask do
		local id = nm:readU32()
		local Task = Tasks[id]
		if Task == nil then
			Task = { id = id }
			sc_task_data(nm, Task)
			if Task.status ~= "fnished" then
				Tasks[id] = Task
			end
		else
			sc_task_data(nm, Task)
			if Task.status == "fnished" then

				-- 不删除已完成并且已领取奖励的任务
				--Tasks[id] = nil

			elseif Task.status == "destroy" then
				Tasks[id] = nil
			end

			-- 完成正在关注的任务
			if Task.id == DY_DATA.TASK.ForcusMainTaskID then
				if Task.status == "fnished" then
					DY_DATA.TASK.ForcusMainTaskID = nil
				end
				NW.broadcast("CLIENT.SC.TASK_FORCUS", {
					type = "MainTask",
				})
			elseif Task.id == DY_DATA.TASK.ForcusTimeLimitTaskID then
				if Task.status == "fnished" then
					DY_DATA.TASK.ForcusTimeLimitTaskID = nil
				end
				NW.broadcast("CLIENT.SC.TASK_FORCUS", {
					type = "TimeLimitTask",
				})
			end
		end

		debug.printY("获得任务。ID"..id..",status:"..Task.status..",".."endTime:"..Task.endTime)
	end

	if DY_DATA.TASK.ForcusMainTaskID == nil then
		NW.broadcast("CLIENT.SC.TASK_FORCUS", {
			type = "MainTask",
		})
	end
	if DY_DATA.TASK.ForcusTimeLimitTaskID == nil then
		NW.broadcast("CLIENT.SC.TASK_FORCUS", {
			type = "TimeLimitTask",
		})
	end

	return Tasks
end)

NW.regist("TASK.SC.TASK_CHAPTER_GET", function (nm)
	DY_DATA.MainTaskChapterId = nm:readU32()
	debug.printY("当前章节:"..DY_DATA.MainTaskChapterId)
	local nChapter = nm:readU32()
	local haveChapterRecode = false
	for i=1,nChapter do
		local chapterId = nm:readU32()
		local chaterState = nm:readU32() --0-不可领取 1-可领取 2-已领取
		DY_DATA.MainTaskChapter[chapterId] = chaterState
		debug.print("章节".. chapterId .."的奖励信息变更为:"..DY_DATA.MainTaskChapter[chapterId])
		
	end
	for k,v in pairs(DY_DATA.MainTaskChapter) do
		if v == 1 then
			haveChapterRecode =  true
			break
		end
	end
	DY_DATA.RedSystem:SetRedDotState(CVar.RedDotName.TaskRecode,haveChapterRecode)
end)

NW.regist("TASK.SC.REWARD_GET", function (nm)
	local ret, err = NW.chk_op_ret(nm:readU32())
	if err == nil then
		local Tasks = DY_DATA.Tasks
		local taskId = nm:readU32()
		local Task = Tasks[taskId]
		if Task then
			Task.status = "fnished"
		end
	end
	return err
end)

NW.regist("TASK.SC.GAIN_GROUP_REWARD", function (nm)
	local ret, err = NW.chk_op_ret(nm:readU32())
	return err
end)

NW.regist("TASK.SC.ACHIEVEMENT_GET", function (nm)
	DY_DATA.Achieves = table.arrvalue(nm:readArray({}, nm.readU32))
	return DY_DATA.Achieves
end)

NW.regist("TASK.SC.DAILY_TASK_RESET_TIME", function (nm)
	DY_DATA.NextDailyTaskRefreshTime = math.floor(nm:readU64() / 1000)
end)

-- 请求任务信息。参数为0时获取所有任务列表
function P.RequestGetTask(taskId)
	local nm = NW.msg("TASK.CS.TASK_GET")
	nm:writeU32(taskId or 0)
	NW.send(nm)
end

-- 获取任务奖励
function P.RequestGetTaskReward(taskId)
	local nm = NW.msg("TASK.CS.REWARD_GET")
	nm:writeU32(taskId)
	NW.send(nm)
end

-- 获取章节奖励
function P.RequestGetChapterReward(taskGroupId)
	local nm = NW.msg("TASK.CS.GAIN_GROUP_REWARD")
	nm:writeU32(taskGroupId)
	NW.send(nm)
end

NW.TASK = P
