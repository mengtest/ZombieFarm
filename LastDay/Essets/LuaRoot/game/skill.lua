--
-- @file    game/skill.lua
-- @anthor  xingweizhen (weizhen.xing@funplus.com)
-- @date    2018-10-11 17:29:19
-- @desc    描述
--

local P = {}

local SkillFuncHandler = {
	-- 抬高视角
	Vision = function (Skill, Args, starting)
		if starting then
			libgame.RaiseCamera(Args[1] / 1000, Args[2])
			libgame.SetOverrideVision(Skill.maxRange)
		else
			libgame.RaiseCamera(nil, Args[3])
			libgame.SetOverrideVision(-1)
		end
	end,
}

function P.special_func(action, starting)
	local Skill = config("skilllib").get_dat(action)
	local Specials = Skill and Skill.Specials
	if Specials then
		for _,v in ipairs(Specials) do
			local method = SkillFuncHandler[v.func]
			if method then method(Skill, v.Args, starting) end
		end
	end
end

return P
