--
-- @file    network/unpack/upk_com.lua
-- @anthor  xingweizhen (weizhen.xing@funplus.com)
-- @date    2018-07-18 13:25:22
-- @desc    描述
--


local NW, P = _G.NW, {}

NW.regist("COM.SC.CLIENT_DATA_GET", function (nm)
	local str = nm:readString()
	if #str > 0 then
		DY_DATA.CliData = cjson.decode(str)
	else
		DY_DATA.CliData = {}
	end
	print("clidata:", str)
end)

NW.regist("COM.SC.CLIENT_DATA_UPDATE", NW.common_op_ret)

function P.update_clidata()
	local clidata = cjson.encode(DY_DATA.CliData)
	NW.MainCli:send(NW.msg("COM.CS.CLIENT_DATA_UPDATE"):writeString(clidata))
end

NW.COM = P
