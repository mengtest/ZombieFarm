using System.Collections;
using System.Collections.Generic;
using UnityEngine;
#if ULUA
using LuaInterface;
#else
using XLua;
using LuaCSFunction = XLua.LuaDLL.lua_CSFunction;
#endif
using ILuaState = System.IntPtr;
using TencentMobileGaming;

public static class LibGVoice
{
    public const string LIB_NAME = "libvoice.cs";
   
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    public static int OpenLib(ILuaState lua)
    {
        lua.NewTable();
        lua.SetDict("Init", Init);
        lua.SetDict("Uninit", Uninit);
        lua.SetDict("JoinRoom", JoinRoom);
        lua.SetDict("QuitRoom", QuitRoom);
        lua.SetDict("EnableRecv", EnableRecv);
        lua.SetDict("EnableSend", EnableSend);

        lua.SetDict("StartRecording", StartRecording);
        lua.SetDict("StopRecording", StopRecording);
        lua.SetDict("UploadRecordedFile", UploadRecordedFile);
        lua.SetDict("DownloadRecordedFile", DownloadRecordedFile);
        lua.SetDict("PlayRecordedFile", PlayRecordedFile);
        lua.SetDict("StopPlayFile", StopPlayFile);

        return 1;
    }

    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int Init(ILuaState lua)
    {
        if (GVoiceMgr.Instance == null) {
            ZFrame.Platform.SDKManager.Instance.gameObject.AddComponent(typeof(GVoiceMgr));
        }
        var ret = GVoiceMgr.Instance.Init(lua.ToString(1), lua.ToString(2), lua.ToString(3));
        lua.PushInteger(ret);
        return 1;
    }

    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int Uninit(ILuaState lua)
    {
        if (GVoiceMgr.Instance) {
            var ret = GVoiceMgr.Instance.Uninit();
            lua.PushInteger(ret);
            return 1;
        }
        return 0;
    }

    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int JoinRoom(ILuaState lua)
    {
        if (GVoiceMgr.Instance) {
            var room = lua.ToInteger(1);
            var type = lua.ToInteger(2);
            var team = lua.OptInteger(3, 0);
            lua.PushInteger(GVoiceMgr.Instance.JoinRoom(room, type, team));
            return 1;
        }
        return 0;
    }

    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int QuitRoom(ILuaState lua)
    {
        if (GVoiceMgr.Instance) {
            lua.PushInteger(GVoiceMgr.Instance.QuitRoom());
            return 1;
        }
        return 0;
    }

    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int EnableRecv(ILuaState lua)
    {
        if (GVoiceMgr.Instance) {
            GVoiceMgr.Instance.EnableVoiceRecv(lua.ToBoolean(1));
        }
        return 0;
    }

    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int EnableSend(ILuaState lua)
    {
        if (GVoiceMgr.Instance) {
            GVoiceMgr.Instance.EnableVoiceSend(lua.ToBoolean(1));
        }
        return 0;
    }

    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int StartRecording(ILuaState lua)
    {
        if (GVoiceMgr.Instance) {
            var filePath = lua.ToString(1);
            var ret = GVoiceMgr.Instance.StartRecording(filePath);
            lua.PushInteger(GVoiceMgr.VerifyRet(ret, filePath));
            return 1;
        }
        return 0;
    }

    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int StopRecording(ILuaState lua)
    {
        if (GVoiceMgr.Instance) {
            var ret = GVoiceMgr.Instance.StopRecording();
            lua.PushInteger(GVoiceMgr.VerifyRet(ret));
            return 1;
        }
        return 0;
    }

    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int UploadRecordedFile(ILuaState lua)
    {
        if (GVoiceMgr.Instance) {
            var filePath = lua.ToString(1);
            var ret = GVoiceMgr.Instance.UploadRecordedFile(filePath, GVoiceMgr.MS_TIMEOUT);
            lua.PushInteger(GVoiceMgr.VerifyRet(ret, filePath));
            return 1;
        }
        return 0;
    }

    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int DownloadRecordedFile(ILuaState lua)
    {
        if (GVoiceMgr.Instance) {
            var fileId = lua.ToString(1);
            var filePath = lua.ToString(2);
            var ret = GVoiceMgr.Instance.DownloadRecordedFile(fileId, filePath, GVoiceMgr.MS_TIMEOUT);
            lua.PushInteger(GVoiceMgr.VerifyRet(ret, filePath));
            return 1;
        }
        return 0;
    }

    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int PlayRecordedFile(ILuaState lua)
    {
        if (GVoiceMgr.Instance) {
            var filePath = lua.ToString(1);
            var ret = GVoiceMgr.Instance.PlayRecordedFile(filePath);
            if (lua.OptBoolean(2, true)) {
                lua.PushInteger(GVoiceMgr.VerifyRet(ret, filePath));
            } else {
                lua.PushInteger(ret);
            }
            return 1;
        }
        return 0;
    }

    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int StopPlayFile(ILuaState lua)
    {
        if (GVoiceMgr.Instance) {
            var ret = GVoiceMgr.Instance.StopPlayFile();
            lua.PushInteger(GVoiceMgr.VerifyRet(ret));
            return 1;
        }
        return 0;
    }
}
