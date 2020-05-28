--
-- @file    channel.lua
-- @anthor  xingweizhen (weizhen.xing@funplus.com)
-- @date    2017-11-02 11:15:30
-- @desc    描述
--

local P = {
}

P.PROTOCAL_FLAG = {
	Normal = 3,
	USE_KG = 4,
}

--协议版本号
function P.get_protocol_id()
	local ProtocolID = P.PROTOCAL_FLAG.Normal

	debug.printG("ProtocolID:"..ProtocolID)
	return ProtocolID
end

local BASE_INTER = "ld_login/id/v1"

local DEF_PID, userPid = 101

local HostList = {
	Inner = { host = _G.UserSettings.inner_host or "http://10.1.11.52", },
	Release = { host = "http://10.1.11.52", },
	Extra = { host = "http://ld-login-eu.kingsgroupgames.com", base_inter = "id/v1"},
	Update = { host = "http://10.1.11.54", pid = 103, },
}

if _G.ENV.development then
	HostList = {
		Inner = { host = _G.UserSettings.inner_host or "http://10.1.11.52", },
		Release = { host = "http://10.1.11.52", },
		Extra = { host = "http://52.83.128.46", },
		Update = { host = "http://10.1.11.54", pid = 103, },
	}
end

local CurrHost
function P.update_host(tag)
	if tag then
		if #tag > 0 then
			if HostList[tag] == nil then
				libunity.LogW("无效的渠道名：{0}，忽略", tag)
				return
			end
			P.hostTag = tag
			libunity.LogD("设置渠道为：{0}", tag)
		else
			P.hostTag = nil
		end
		CurrHost = nil
	end

	if CurrHost == nil then
		if P.hostTag then
			CurrHost = HostList[P.hostTag]
		else
			-- 自动判断内外网
			local inner = false
			local IPs = libnetwork.GetLocalIPs()
			if #IPs > 0 then
				for _,ip in ipairs(IPs) do
					if ip:sub(1, 2) == "10" then
						inner = true
						break
					end
				end
			else
				libunity.LogW("GetLocalIPs = 0")
			end
			CurrHost = inner and HostList.Inner or HostList.Extra
		end
	end
	return CurrHost
end

function P.get_host()
	P.update_host()
	return CurrHost.host, CurrHost.port, CurrHost.base_inter or BASE_INTER
end

function P.get_url(inter)
	local host, port, base_inter = P.get_host()
	if host then
		if port then
			return string.format("%s:%d/%s/%s", host, port, base_inter, inter)
		else
			return string.format("%s/%s/%s", host, base_inter, inter)
		end
	end
end

function P.get_pid()
	return userPid or (CurrHost and CurrHost.pid) or DEF_PID
end

function P.get_packid()
	return 1
end

function P.switch_pid(channelType)
	if channelType == "KG" then
		userPid = 200
	else
		userPid = nil
	end
end

return P
