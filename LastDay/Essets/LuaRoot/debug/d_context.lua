--
-- @file    debug/d_context.lua
-- @anthor  xingweizhen (weizhen.xing@funplus.com)
-- @date    2018-06-20 10:07:14
-- @desc    描述
--

local ItemDEF = _G.DEF.Item

UI.DebugContexts = {
	MBItemSubmit = {
		title = "Repair Building",
		tips = "Complete repair the building needs:",
		Items = {
			ItemDEF.new(11001, 10), ItemDEF.new(11002, 5), ItemDEF.new(11003, 3), ItemDEF.new(11004, 1),
		},
	}
}
