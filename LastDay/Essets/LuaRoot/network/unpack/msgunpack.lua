--
-- @file    network/unpack/nmsgunpack.lua
-- @anthor  xingweizhen (weizhen.xing@funplus.com)
-- @date    2017-10-30 09:46:47
-- @desc    描述
--

local ClientDEF = _G.DEF.Client
ClientDEF.noresponse("PACKAGE.CS.PACKAGE_CLOSE")
ClientDEF.noresponse("COM.CS.COM_EXIT")
ClientDEF.noresponse("MAIL.CS.SET_READED")
ClientDEF.noresponse("TEAM.CS.PUBLIC_LIST_ADD_LISTEN")
ClientDEF.noresponse("TEAM.CS.PUBLIC_LIST_REMOVE_LISTEN")
ClientDEF.noresponse("TEAM.CS.TEAM_INVITE")
ClientDEF.noresponse("TEAM.CS.INVITE_ACT")
ClientDEF.noresponse("COM.CS.KEEP_HEART")
ClientDEF.noresponse("GUILD.CS.GUILD_BUILD_MANAGER")
ClientDEF.noresponse("TEAM.CS.TEAM_CLOSE_BATTLE_ACT")
ClientDEF.noresponse("MULTI_MAP.CS.CANCEL_ALONE_APPLY")
ClientDEF.noresponse("LOGIN.CS.SWITCH_NOHUP")
ClientDEF.noresponse("LOGIN.CS.SUSPEND_HEARTBEAT")

ClientDEF.norequest("TEAM.SC.PUBLIC_LIST")
ClientDEF.norequest("COM.CS.KEEP_HEART")

dofile "network/unpack/upk_com"
dofile "network/unpack/upk_battle"
dofile "network/unpack/upk_login"
dofile "network/unpack/upk_map"
dofile "network/unpack/upk_package"
dofile "network/unpack/upk_role"
dofile "network/unpack/upk_build"
dofile "network/unpack/upk_world"
dofile "network/unpack/upk_multi"
dofile "network/unpack/upk_mail"
dofile "network/unpack/upk_team"
dofile "network/unpack/upk_guild"
dofile "network/unpack/upk_chat"
dofile "network/unpack/upk_vendue"
dofile "network/unpack/upk_shop"
dofile "network/unpack/upk_friend"
dofile "network/unpack/upk_task"
