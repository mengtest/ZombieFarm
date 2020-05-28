

local text_obj = config("textlib").text_obj

local DB = {}
local TEXT_DB = {}

local BUBBLE_TEXT = dofile("config/dialoguebubble_bubbletext")
for _,v in ipairs(BUBBLE_TEXT) do
	TEXT_DB[v.id] = text_obj("dialoguebubble_bubbletext", "bubbleText", v)
end

local BUBBLE_GROUP = dofile("config/dialoguebubble_bubblegroup")
for _,v in ipairs(BUBBLE_GROUP) do
	DB[v.id] = {
		id = v.id,
		bubbleTime = v.bubbleTime,
		type = v.type,--1:随机一个始终显示  2：间隔bubbleTime秒切换一次  3：随机显示一次，持续bubble秒消失
	}
	local bubbleTextIDArr = v.bubbleText:splitn('|')
	local bubbleTextArr = {}
	for _,textID in pairs(bubbleTextIDArr) do
		table.insert(bubbleTextArr, TEXT_DB[textID])
	end
	DB[v.id].bubbleText = bubbleTextArr
end

local P = {}

function P.get_dialogue_bubble_dat(id)
	return DB[id]
end

return P