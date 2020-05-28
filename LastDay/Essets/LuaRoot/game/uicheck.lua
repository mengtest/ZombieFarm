--
-- @file    game/uicheck.lua
-- @anthor  xingweizhen (weizhen.xing@funplus.com)
-- @date    2018-06-27 17:04:04
-- @desc    描述
--

local P = {}

function P.check_ahievement(id)
	local ret = DY_DATA.Achieves[id]
	if not ret then
		UI.MBox.make("MBAchievement"):set_param("dat", id):show()
	end
	return ret
end

function P.WNDTradeHouse()
	return P.check_ahievement(_G.CVar.Achieves.TRADE)
end

function P.WNDGuild()
	return P.check_ahievement(_G.CVar.Achieves.GUILD)
end

return P
