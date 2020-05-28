--
-- @file    debug/d_player.lua
-- @anthor  xingweizhen (weizhen.xing@funplus.com)
-- @date    2018-03-30 10:37:17
-- @desc    描述
--


local Player = DY_DATA:get_player()
Player.nChangeName = 1
Player.uniqueId = "xwz"
Player.name = "Survivor"
Player.icon = 0
Player.frame = 0
Player.verified = false

Player.level = 30
--Player.Vip
Player.totalRechange = 0
Player.exp = 3

local ItemDEF = _G.DEF.Item
local Energy = ItemDEF.new(1, 98)
Energy.limit = 100
Player.Assets = {
	[1] = Energy,
	[3] = ItemDEF.new(3, 121005),
	[12] = ItemDEF.new(12, 200),
}

_G.PKG["game/timers"].launch_asset_timer(Energy, 10, 60)

local PrefDEF = _G.DEF.Pref
DY_DATA.RecentlyMets = PrefDEF.new("rmp#" .. Player.id)

-- 成就
DY_DATA.Achieves = { [1] = true, [2] = true, }
