--
-- @file    guide/crafting.lua
-- @anthor  xingweizhen (weizhen.xing@funplus.com)
-- @date    2018-07-18 10:57:11
-- @desc    描述
--

local P = {
	id = 2,
	group = select(1, ...),
	name = "Crafting",
	mask = true, block = true,
}
P.__index = P

function P:chk_cond()
	return true
end

function P:gen_guider(API)
	local nStep, keyStep = 0

	return function ()
		local Step
		if nStep == 0 then
			local startTime = UE.Time.time + 0.5
			nStep, Step = nStep + 1, {
				wait = function () return UE.Time.time > startTime end,
				style = "Rect", tips = 9000204,
				target = API.finder("FRMExplore", "SubFuncs/btnCraft"),
			}
		elseif nStep == 1 then
			local startTime = UE.Time.time + 0.5
			local emptyhandler = function() end
			nStep, Step = nStep + 1, {
				wait = function () return UE.Time.time > startTime end,
				style = "Rect", tips = 9000205,
				target = API.grpfinder("WNDCraft", 1, "SubScroll", "SubView", "GrpFormulas"),
				-- 禁止拖拽
				begindrag = emptyhandler, drag = emptyhandler, enddrag = emptyhandler,
			}
		elseif nStep == 2 then
			local startTime = UE.Time.time + 0.5
			nStep, Step = nStep + 1, {
				wait = function () return UE.Time.time > startTime end,
				style = "Rect", tips = 9000206,
				target = API.finder("WNDCraft", "SubProduct/SubCraft/SubBtn"),
			}
		elseif nStep == 3 then
			keyStep = true
			nStep, Step = nStep + 1, {
				wait = function ()
					local Wnd = ui.find("WNDTopBar")
					return Wnd and Wnd.Ref and Wnd.Ref.btnClose:IsInteractable()
				end,
				style = "Rect", tips = 9000207,
				target = API.finder("WNDTopBar", "btnClose"),
			}
		else return end

		return setmetatable(Step, self), nStep, keyStep
	end
end

return P
