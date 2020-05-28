--
-- @file    network/unpack/upk_build.lua
-- @anthor  xingweizhen (weizhen.xing@funplus.com)
-- @date    2017-12-15 10:43:24
-- @desc    描述
--

local NW, P = _G.NW, {}

NW.regist("BUILD.SC.BUILDING", NW.PACKAGE.items_change)
NW.regist("BUILD.SC.DESTORY", NW.common_op_ret)
NW.regist("BUILD.SC.REPAIR", NW.common_op_ret)
NW.regist("BUILD.SC.OPERATION", NW.common_op_ret)

NW.BUILD = P
