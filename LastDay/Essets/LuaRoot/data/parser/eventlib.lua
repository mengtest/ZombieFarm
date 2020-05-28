
local text_obj = config("textlib").text_obj

local DB = {}
local EVENT_BASE = dofile("config/event_base")
for _,v in ipairs(EVENT_BASE) do
	DB[v.ID] = {
		id = v.ID,
		icon = v.icon,
		name = text_obj("event_base", "eventName", v),
		desc = text_obj("event_base", "eventDescription", v),
		callDescription = text_obj("event_base", "CallDescription", v),
		answerDescription = text_obj("event_base", "AnswerDescription", v),
	}
end

local P = {}

function P.get_event_dat(id)
	return DB[id]
end

return P