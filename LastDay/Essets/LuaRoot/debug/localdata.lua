--
-- @file    debug/localdata.lua
-- @anthor  xingweizhen (weizhen.xing@funplus.com)
-- @date    2017-10-31 16:12:58
-- @desc    描述
--

dofile "debug/d_player"
dofile "debug/d_item"
dofile "debug/d_build"
dofile "debug/d_stage"
dofile "debug/d_world"
dofile "debug/d_chat"
dofile "debug/d_trade"
dofile "debug/d_context"

DY_DATA.RedSystem = _G.DEF.RedDotMgr.new()
DY_DATA.RedSystem:init()

return {}
