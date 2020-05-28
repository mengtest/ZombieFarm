--
-- @file    data/parser/tasklib.lua
-- @anthor  xingweizhen (weizhen.xing@funplus.com)
-- @date    2018-07-23 11:31:56
-- @desc    描述
--


local DB = {}
local MainTaskDB = {}
local RewardDB = {}
local CharpterInfoDB = {}

local TaskType = {
	MainTask = 1,
	TimeLimitTask = 2,
	HideTask = 3,
	StageTask = 4,
	LoopTask = 5,
	NewPlayerTask = 6,
}

local text_obj = config("textlib").text_obj

local TASK_REWARD = dofile("config/task_reward")
for i,v in pairs(TASK_REWARD) do
	local data = {id = v.ID,}
	data.type = v.RewardType

	if data.type == 1 or data.type == 5 then
		data.reward = v.Reward:splitgn(":")
	else
		data.reward = v.Reward
	end
	RewardDB[v.ID] = data
end

local TASK_BASE = dofile("config/task_base")
for i,v in ipairs(TASK_BASE) do
	DB[v.ID] = {
		id = v.ID, type = v.QuestType, sort = v.Order,
		groupID = v.GroupID,
		name = text_obj("task_base", "taskName", v),
		desc = text_obj("task_base", "taskDescription", v),
		taskTip = text_obj("task_base", "taskTips", v),
		rewardInfo = {},
	}

	if DB[v.ID].type == 2 then
		DB[v.ID].callDescription = text_obj("task_base", "CallDescription", v)
		DB[v.ID].answerDescription = text_obj("task_base", "AnswerDescription", v)
	end

	local rewardArr =  v.Reward:splitn("|")
	for _,rewardId in pairs(rewardArr) do
		local rewardItem = RewardDB[rewardId]
		if rewardItem then
			if type(rewardItem.reward) == "table" then
				for _,rw in pairs(rewardItem.reward) do
					table.insert(DB[v.ID].rewardInfo, rw)
				end
			else
				table.insert(DB[v.ID].rewardInfo, rewardItem.reward)
			end
		end
	end

	if v.QuestType == TaskType["MainTask"] then
		local GroupTB = table.need(MainTaskDB, v.GroupID)
		table.insert(GroupTB, DB[v.ID])
	end
end
for _,gTb in pairs(MainTaskDB) do
	table.sort(gTb, function(a, b)
		return a.sort < b.sort
	end)
end

local TASK_CHAPTER = dofile("config/task_chapter")
for i,v in pairs(TASK_CHAPTER) do
	CharpterInfoDB[v.ID] = {
		id = v.ID,
		reward = v.reward:splitgn(":"),
		name = text_obj("task_chapter", "chapterName", v),
	}
end

local P = {}
P.TaskType = TaskType

function P.get_dat(dat)
	return DB[dat]
end

function P.get_chapter_task_list(chapterId)
	return MainTaskDB[chapterId]
end

function P.get_chapter_info(chapterId)
	return CharpterInfoDB[chapterId]
end

function P.get_chapter_total_cnt()
	return #CharpterInfoDB
end

return P
