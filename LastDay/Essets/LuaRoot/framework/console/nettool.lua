--
-- @file    framework/console/nettool.lua
-- @anthor  xing weizhen (xingweizhen@rongygame.com)
-- @date    2016-02-29 11:11:58
-- @desc    描述
--

local P = {}

function P:chhost(tag)
    _G.PKG["network/channel"].update_host(tag)
end

function P:connect(host, strPort)
    local port = tonumber(strPort)
    local NW = MERequire "network/networkmgr"
    NW.connect(host, port)
end

function P:enter(index)
    local LOGIN = _G.PKG["network/login"]
    LOGIN.enter_server(tonumber(index))
end

function P:logout()
    local LOGIN = _G.PKG["network/login"]
    LOGIN.logout()
end

function P:close()
    local NW = _G.PKG["network/networkmgr"]
    NW.disconnect()
end

function P:pid(pid)
    _G.PKG["libmgr/login"].Channel.pid = tonumber(pid)
    _G.UI.Toast.make(nil, "已修改渠道号为："..pid):show()
end

function P:reset_cli()
    local DY_DATA = _G.PKG["datamgr/dydata"]
    DY_DATA.CliData = nil

    local NW = _G.PKG["network/networkmgr"]
    NW.send(NW.msg("COMMON.CS.CLIENT_DATA_SET"):writeString(""))
end

function P:invite(pid)
    _G.NW.TEAM.invite(tonumber(pid))

end

function P:attackhome(pid)
    _G.NW.MULTI.attack_player_home(0, pid, 2)
end

return P
