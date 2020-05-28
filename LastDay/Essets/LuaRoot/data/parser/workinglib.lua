--
-- @file    data/parser/workinglib.lua
-- @anthor  xingweizhen (weizhen.xing@funplus.com)
-- @date    2018-01-04 10:55:50
-- @desc    描述
--

local text_obj = config("textlib").text_obj

local GARDENBED_DB = table.tomap(dofile("config/building_gardenbed"), "ID")

local DB = {}
local MACHINING = dofile("config/building_machining")
for _,v in ipairs(MACHINING) do
	DB[v.ID] = {
		id = v.ID, type = v.type, sort = v.sort,
		duration = v.machiningTime,
		Product = v.product:splitgn(":")[1],
		Mats = v.material:splitgn(":"),
		hastenCost = v.speedUpCost,
		bluePrints = v.bluePrints,
		overSfx = v.machiningOverVoice,
		machiningText = text_obj("building_machining", "machiningDescription", v),
		fictitiousAssets = v.fictitiousAssets:splitgn(":"),
	}

	local gardenbed_info = GARDENBED_DB[v.ID]
	if gardenbed_info then
		DB[v.ID].growingCrop = gardenbed_info.growingCrop
		DB[v.ID].ripeCrop = gardenbed_info.ripeCrop
	end
end

local BUILDING_INTERACTIVE_DB = {}
local BUILDING_INTERACTIVE = dofile("config/building_buildinteractive")
for _,v in pairs(BUILDING_INTERACTIVE) do
	BUILDING_INTERACTIVE_DB[v.objectID] =
	{
		id = v.objectID,
		selfAction = v.selfAction,
		targetAction = v.targetAction,
		selfSFX = v.selfCasted,
		targetSFX = v.targetCasted,
		pointName = v.InteractionPoint,
		duration = v.castingTime / 1000,
	}
end

local P = {}
function P.get_dat(id)
	return DB[id]
end

function P.get_interactive_info(id)
	return	BUILDING_INTERACTIVE_DB[id]
end

return P