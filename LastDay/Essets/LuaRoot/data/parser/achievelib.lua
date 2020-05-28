--
-- @file    data/parser/achievelib.lua
-- @anthor  xingweizhen (weizhen.xing@funplus.com)
-- @date    2018-06-27 15:51:55
-- @desc    描述
--

local DB = {}

local TargetDB = {}
local TARGET = dofile("config/achievement_target")
for i,v in ipairs(TARGET) do
	TargetDB[v.ID] = {
		type = v.TargetType,
		Params = { v.Param1, v.Param2, v.Param3, }
	}
end

local RewardDB = {}
local REWARD = dofile("config/achievement_reward")
for i,v in ipairs(REWARD) do
	RewardDB[v.ID] = {
		type = v.RewardType, Rewards = v.Reward:splitn("|"),
	}
end


local ACHIEVE = dofile("config/achievement_achievement")
for i,v in ipairs(ACHIEVE) do
	DB[v.ID] = {
		Target = TargetDB[v.Target],
		Rewards = RewardDB[v.Reward],
	}
end

local P = {}
function P.get_dat(dat)
	return DB[dat]
end

return P
