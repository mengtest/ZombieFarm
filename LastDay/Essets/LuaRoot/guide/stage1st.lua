--
-- @file    guide/stage1st.lua
-- @anthor  xingweizhen (weizhen.xing@funplus.com)
-- @date    2018-07-18 11:21:10
-- @desc    描述
--

local P = {
	id = 4,
	group = select(1, ...),
	name = "第一个关卡",
	mask = false, block = false,
}
P.__index = P

function P:chk_cond()
	return ui.find("FRMWorld") ~= nil
end

function P:gen_guider(API)
	local nStep = 1

	local targeEnt
	for i,v in ipairs(DY_DATA.World.Entrances) do
		if v.id == 11002 then
			targeEnt = "/WORLD/ent" .. i
		end
	end
	if targeEnt == nil then return end

	local keyStep
	return function ()
		local Step
		if nStep == 1 then
			ui.find("FRMWorld").align_view2ent(targeEnt)
			Step = {
				style = "Circle", tips = 9000210,
				target = targeEnt,
				click = ui.find("FRMWorld").open_stage_ent,
			}
			keyStep = true
			if DY_DATA.World.Travel.src ~= 11002 then
				nStep = nStep + 1
			else
				nStep = nStep + 3
			end
		elseif nStep == 2 then
			nStep, Step = nStep + 1, {
				style = "Rect", tips = 9000211,
				target = API.finder("WNDStageInfo", "SubMain/SubVehicles/GrpVehicles/entVehicle2"),
			}
		elseif nStep == 3 then
			ui.find("FRMWorld").align_view2ent(targeEnt)
			nStep, Step = nStep + 1, {
			  	wait = function() return DY_DATA.World.Travel.dst == 0 end,
				style = "Circle",
				target = targeEnt,
				click = ui.find("FRMWorld").open_stage_ent,
			}
		elseif nStep == 4 then
			nStep, Step = nStep + 1, {
				style = "Rect",
				target = API.finder("WNDStageInfo", "SubMain/SubExplore/btnExplore"),
			}
		else return end

		return setmetatable(Step, self), nStep, keyStep
	end
end

return P
