--
-- @file    game/craftapi.lua
-- @anthor  xingweizhen (weizhen.xing@funplus.com)
-- @date    2018-07-17 12:07:19
-- @desc    描述
--

local P = {}

local Crafts = {}

function P.save_list(newlist)
	if newlist == nil then return end
	for i,v in ipairs(newlist) do
		if v ~=nil then
			local id = tostring(v.id)
			local CraftData = table.need(DY_DATA.CliData, "NewCraft")
			CraftData[id] = 1
		end
			
	end


	NW.COM.update_clidata()
end

function P.save(id, state)
	if id == nil then return end

	id = tostring(id)
	local CraftData = table.need(DY_DATA.CliData, "NewCraft")
	CraftData[id] = state

	NW.COM.update_clidata()
end

function P.load(id)
	local CraftData = table.need(DY_DATA.CliData, "NewCraft")
	return CraftData[tostring(id)]
end

function P.launch()
	local CraftData = table.need(DY_DATA.CliData, "NewCraft")
	return CraftData
end
return P