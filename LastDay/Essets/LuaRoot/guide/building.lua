--
-- @file    guide/building.lua
-- @anthor  xingweizhen (weizhen.xing@funplus.com)
-- @date    2018-07-17 15:47:43
-- @desc    描述
--

local P = {
	group = select(1, ...),
	name = "Building",
	mask = true, block = true,
}
P.__index = P

function P:chk_cond()
	return true
end

function P:gen_guider(API)
	local nStep = 1
	local nDoor = 0
	for _,v in pairs(DY_DATA:get_stage().Units) do
		if v.dat == 50201 then
			nDoor = nDoor + 1
		end
	end

	return function ()
		local Step, keyStep
		if nStep == 1 then
			local startTime = UE.Time.time + 1
			Step = {
				wait = function () return UE.Time.time > startTime end,
				style = "Circle", tips = 40205,
				target = API.finder("FRMExplore", "SubFuncs/btnBuild"),
			}
			if nDoor == 0 then
				nStep = nStep + 1
			else
				nStep = nStep + 3
			end
		elseif nStep == 2 then
			nStep, Step = nStep + 1, {
				style = "Rect", tips = 40206,
				target = API.grpfinder("FRMDesign", 3, "SubScroll", "SubView", "GrpItems"),
				click = function (tar)
					libugui.ExecuteEvent(tar, "PointerClick")
					ui.find("FRMDesign").put_building(UE.Vector3(19.5, 0, 22.5))
				end,
			}
		elseif nStep == 3 then
			nStep, Step = nStep + 1, {
				style = "Circle", tips = 40207,
				target = API.finder("FRMDesign", "SubOper/btnConfirm"),
			}
		elseif nStep == 4 then
			nStep, Step = nStep + 1, {
				style = "Rect", tips = 40208,
				target = API.grpfinder("FRMDesign", 2, "GrpTabs"),
			}
		elseif nStep == 5 then
			nStep, Step = nStep + 1, {
				style = "Rect", tips = 40209,
				target = API.grpfinder("FRMDesign", 1, "SubScroll", "SubView", "GrpItems"),
				click = function (tar)
					libugui.ExecuteEvent(tar, "PointerClick")
					ui.find("FRMDesign").put_building(UE.Vector3(26.5, 0, 24.5))
				end,
			}
		elseif nStep == 6 then
			nStep, Step = nStep + 1, {
				style = "Circle", tips = 40207,
				target = API.finder("FRMDesign", "SubOper/btnConfirm"),
			}
		elseif nStep == 7 then
			nStep, Step = nStep + 1, {
				style = "Rect", tips = 40211,
				target = API.finder("FRMDesign", "btnClose"),
			}
		else return end

		return setmetatable(Step, self), nStep, keyStep
	end
end

return P
