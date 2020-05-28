using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using clientlib.net;
using ZFrame.NetEngine;
#if ULUA
using LuaInterface;
#else
using XLua;
using LuaCSFunction = XLua.LuaDLL.lua_CSFunction;
#endif
using ILuaState = System.IntPtr;

public static class LibNetwork
{
    public const string LIB_NAME = "libnetwork.cs";

    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    public static int OpenLib(ILuaState lua)
    {
        lua.NewTable();

        lua.SetDict("GetLocalIPs", GetLocalIPs);
        lua.SetDict("RefreshAddressFamily", RefreshAddressFamily);
        lua.SetDict("HttpGet", HttpGet);
        lua.SetDict("HttpPost", HttpPost);
        lua.SetDict("HttpDownload", HttpDownload);

        lua.SetDict("SetParam", SetParam);

        return 1;
    }

    public static string KeyValue2Param<T>(IEnumerable<KeyValuePair<string, T>> enumrable) where T : System.IConvertible
    {
        var itor = enumrable.GetEnumerator();
        System.Text.StringBuilder strbld = new System.Text.StringBuilder();
        while (itor.MoveNext()) {
            string key = itor.Current.Key;
            string value = itor.Current.Value.ToString(null);
            strbld.AppendFormat("{0}={1}&", WWW.EscapeURL(key), WWW.EscapeURL(value));
        }
        return strbld.ToString();
    }
    
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int GetLocalIPs(ILuaState lua)
    {
        var nics = System.Net.NetworkInformation.NetworkInterface.GetAllNetworkInterfaces();
        lua.NewTable();
        for (int i = 0; i < nics.Length; ++i) {
            var ni = nics[i];
            if (ni.NetworkInterfaceType == System.Net.NetworkInformation.NetworkInterfaceType.Loopback ||
                ni.NetworkInterfaceType == System.Net.NetworkInformation.NetworkInterfaceType.Unknown) continue;

            var uniCast = ni.GetIPProperties().UnicastAddresses;
            int n = 0;
            foreach (var uni in uniCast) {
                var addr = uni.Address;
                lua.SetString(-1, ++n, addr.ToString());
            }
        }
        return 1;
    }
    
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
	static int RefreshAddressFamily(ILuaState lua)
	{
		var host = lua.ToString(1);
        string ip = null;
        try {
            ip = NetSession.RefreshAddressFamily(host);
        } catch (System.Exception e) {
            LogMgr.W("{0}", e);
        }
        if (!string.IsNullOrEmpty(ip)) {
            lua.PushString(ip);
        } else {
            lua.PushNil();
        }
		return 1;
	}

    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    static int HttpGet(ILuaState lua)
    {
        string tag = lua.ChkString(1);
        string url = lua.ChkString(2);
        float timeout = (float)lua.OptNumber(4, 10);
        string param = null;
        var luaT = lua.Type(3);
        if (luaT == LuaTypes.LUA_TSTRING) {
            param = lua.ToString(3);
        } else {
            var joParam = lua.ToJsonObj(3) as TinyJSON.ProxyObject;
            if (joParam != null) {
                param = KeyValue2Param(joParam);
            }
        }

        var httpHandler = NetworkMgr.Instance.GetHttpHandler("HTTP");
        if (httpHandler) httpHandler.StartGet(tag, url, param, timeout);

        return 0;
    }

    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    static int HttpPost(ILuaState lua)
    {
        string tag = lua.ChkString(1);
        string url = lua.ChkString(2);
        string strHeader = lua.ToString(4);
        float timeout = (float)lua.OptNumber(5, 10);

        //测试日志，输出请求host
        Debug.Log(string.Format("tag:{0};url:{1};strHeader:{2}", tag, url, strHeader));

        string postData = null;
        var luaT = lua.Type(3);
        if (luaT == LuaTypes.LUA_TSTRING) {
            postData = lua.ToString(3);
        } else {
            var joParam = lua.ToJsonObj(3) as TinyJSON.ProxyObject;
            if (joParam != null) {
                postData = KeyValue2Param(joParam);
            }
        }

        // "key:value\nkey:value"
        Dictionary<string, string> headers = new Dictionary<string, string>();
        if (!string.IsNullOrEmpty(strHeader)) {
            string[] segs = strHeader.Split('\n');
            foreach (string seg in segs) {
                string[] kv = seg.Split(':');
                if (kv.Length == 2) {
                    headers.Add(kv[0].Trim(), kv[1].Trim());
                }
            }
        }

        var httpHandler = NetworkMgr.Instance.GetHttpHandler("HTTP");
        if (httpHandler) httpHandler.StartPost(tag, url, System.Text.Encoding.UTF8.GetBytes(postData), headers, timeout);

        return 0;
    }

    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    static int HttpDownload(ILuaState lua)
    {
        string url = lua.ChkString(1);
        string path = lua.ChkString(2);
        float timeout = (float)lua.OptNumber(3, 10);

        var httpHandler = NetworkMgr.Instance.GetHttpHandler("HTTP-DL");
        if (httpHandler) httpHandler.StartDownload(url, path, timeout);

        return 0;
    }

    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int SetParam(ILuaState lua)
    {
        //ExceptionReporter.Instance.SetParam(lua.ToLuaString(1), lua.ToLuaString(2));
        HockeyAppMgr.Instance.SetParam(lua.ToLuaString(1), lua.ToLuaString(2));
        return 0;
    }

}
