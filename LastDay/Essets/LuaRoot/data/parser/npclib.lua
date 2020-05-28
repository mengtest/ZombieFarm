--
-- @file    data/parser/npclib.lua
-- @anthor  xingweizhen (weizhen.xing@funplus.com)
-- @date    2018-06-12 09:21:51
-- @desc    描述
--

local text_obj = config("textlib").text_obj
local DB = {}

local CondDB = {}
local DLG_COND = dofile("config/npcdialogue_request")
for i,v in ipairs(DLG_COND) do
	CondDB[v.ID] = {
		id = v.ID, type = v.type,
		Params = v.param1:totablearray("|", ":", "id", "amount"),
		ParamsLimit = v.param2:totablearray("|", ":", "id", "amount"),
	}
end

local RewardDB = {}
local DLG_REWARD = dofile("config/npcdialogue_reward")
for i,v in ipairs(DLG_REWARD) do
	RewardDB[v.ID] = {
		id = v.ID, type = v.type,
		Params = v.param:totablearray("|", ":", "id", "amount"),
	}
end

local OptDB = {}
local DLG_OPTIONS = dofile("config/npcdialogue_option")
for i,v in ipairs(DLG_OPTIONS) do
	OptDB[v.ID] = {
		id = v.ID, UIArgs = v.ui:split("|"),
		Conds = table.subarray(CondDB, v.request:splitn("|")),
		Rewards = table.subarray(RewardDB, v.request:splitn("|")),
		option = text_obj("npcdialogue_option", "optionText", v),
	}
end

local ActionType = {
	[1] = "uiopen",
	[2] = "options",
	[3] = "check",
	[4] = "bubble",
}

local DLG = dofile("config/npcdialogue_dialogue")
for i,v in ipairs(DLG) do
	local action = ActionType[v.dialogueType]
	local ParamIDs = v.dialogueParam:splitn("|")
	local Params = table.subarray(OptDB, ParamIDs)
	local UIArgs
	if action == "uiopen" then
		local Opt = OptDB[ParamIDs[1]]
		UIArgs = Opt and Opt.UIArgs
	end
	local content = nil
	if v.TextType == 0 then
		content = nil
	else
		content = text_obj("npcdialogue_dialogue", "dialogueText", v)
	end
	DB[v.ID] = {
		id = v.ID, action = ActionType[v.dialogueType],
		Params = Params, UIArgs = UIArgs,
		content = content,
	}
end

local P = {}
function P.get_dat(dat) return DB[dat] end
function P.gotoui(obj, UIArgs)
	local method, path, depth, ext = unpack(UIArgs)
	local uimethod = ui[method]
	if uimethod then
		uimethod(path, tonumber(depth), {obj = obj, ext = ext})
	else
		libunity.LogE("通过对话打开界面参数错误: {0}", cjson.encode(UIArgs))
	end
end
function P.open(obj, dat)
	local Data = DB[dat]
	if Data then
		if Data.action == "uiopen" then
			if Data.UIArgs then
				P.gotoui(obj, Data.UIArgs)
			else
				libunity.LogE("对话#{0}参数为nil", dat)
				libgame.UnitBreak(0)
			end
		elseif Data.action == "options" then
			ui.show("UI/WNDDlgOptions", nil, { Dlg = Data, obj = obj, })
		elseif Data.action == "bubble" then
			_G.PKG["game/api"].show_chat_bubble(obj, Data.content)
			libgame.UnitBreak(0)
		else
			libgame.UnitBreak(0)
		end
	else
		libunity.LogE("未知的npc交互数据={0}", dat)
	end
end

return P
