--
-- @file    guide/takeall.lua
-- @anthor  xingweizhen (weizhen.xing@funplus.com)
-- @date    2018-07-17 12:02:46
-- @desc    强制引导：拾取界面-全部拿走
--

local P = {
	group = select(1, ...),
	name = "Take all",
	mask = true, block = true,
}
P.__index = P

function P:chk_cond()
	return true
end

function P:gen_guider(API)
	local nStep = 1

	return function ()
		local Step, keyStep
		if nStep == 1 then
			nStep, Step = 2, {
				style = "Circle", event = "ptrdown", stepover = "ptrup", mask = false,
				tips = 40203,
				target = API.finder("FRMExplore", "SubMinor"),
			}
		elseif nStep == 2 then
			nStep, Step = 3, {
				style = "Rect",
				tips = 40204,
				target = API.finder("WNDLootBag", "SubLoot/SubOp/btnPick"),
			}
		else return end

		return setmetatable(Step, self), nStep, keyStep
	end
end

return P
