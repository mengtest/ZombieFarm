using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TencentMobileGaming;

public class GVoiceMgr : MonoSingleton<GVoiceMgr>
{
    public const int MS_TIMEOUT = 15000;
    private int m_SelfId;

    private const string LUA_SCRIPT = "game/voice";

    private ITMGContext m_Context;
    public static ITMGContext context { get { return Instance.m_Context; } }

    #region UserConfig
    private string m_AppId, m_AppKey;
    private string m_OpenId;
    private string m_RoomId;
    private bool m_EnablePlay = true;
    private bool m_EnableSend = false;
    #endregion

    public void Log(string fmt, params object[] args)
    {
        Debug.LogFormat("[GVoice] " + fmt, args);
    }

    protected override void Awaking()
    {
        base.Awaking();

        // 初始化GVoice

        m_Context = ITMGContext.GetInstance();
        
        m_Context.OnEnterRoomCompleteEvent += OnEnterRoomComplete;
        m_Context.OnExitRoomCompleteEvent += OnExitRoomComplete;
        m_Context.OnRoomDisconnectEvent += OnRoomDisconnect;
        m_Context.OnEndpointsUpdateInfoEvent += OnEndpointsUpdateInfo;
        m_Context.GetAudioCtrl().OnAudioRouteChangeComplete += OnAudioRouteChange;
        m_Context.GetAudioEffectCtrl().OnAccompanyFileCompleteHandler += OnAccomponyFileCompleteHandler;
        m_Context.OnRoomTypeChangedEvent += OnRoomTypeChangedEvent;
        m_Context.GetRoom().OnChangeRoomtypeCallback += OnChangeRoomtypeCallback;
    }

    private void Update()
    {
        m_Context.Poll();
    }

    protected override void Destroying()
    {
        base.Destroying();

        m_Context.OnEnterRoomCompleteEvent -= OnEnterRoomComplete;
        m_Context.OnExitRoomCompleteEvent -= OnExitRoomComplete;
        m_Context.OnRoomDisconnectEvent -= OnRoomDisconnect;
        m_Context.OnEndpointsUpdateInfoEvent -= OnEndpointsUpdateInfo;
        m_Context.GetAudioCtrl().OnAudioRouteChangeComplete -= OnAudioRouteChange;
        m_Context.GetAudioEffectCtrl().OnAccompanyFileCompleteHandler -= OnAccomponyFileCompleteHandler;
        m_Context.OnRoomTypeChangedEvent -= OnRoomTypeChangedEvent;
        m_Context.GetRoom().OnChangeRoomtypeCallback -= OnChangeRoomtypeCallback;
    }

    private void OnApplicationFocus(bool focus)
    {
        if (focus) {
            m_Context.Pause();
        } else {
            m_Context.Resume();
        }
    }

    private void SendVoiceEvent(string eventName, int result, string arg2, string arg3)
    {
        var lua = LuaComponent.lua;
        lua.GetGlobal("PKG", LUA_SCRIPT);
        lua.GetField(-1, eventName);
        if (lua.IsFunction(-1)) {
            var b = lua.BeginPCall();
            lua.PushInteger(result);
            lua.PushString(arg2);
            lua.PushString(arg3);
            lua.ExecPCall(3, 0, b);
        } else {
            LogMgr.E("未知的语音事件：{0}", eventName);
            lua.Pop(1);
        }
        lua.Pop(1);
    }

    private void OnEnterRoomComplete(int result, string error)
    {
        Log("Join Room: {0} = {1}: {2}", m_RoomId, result, error);

        if (result == QAVError.OK) {
            m_Context.GetAudioCtrl().EnableAudioPlayDevice(true);
            m_Context.GetAudioCtrl().EnableAudioCaptureDevice(true);
            m_Context.GetAudioCtrl().EnableAudioRecv(m_EnablePlay);
            m_Context.GetAudioCtrl().EnableAudioSend(m_EnableSend);
        }

        SendVoiceEvent("join_room", result, error, m_RoomId);
    }

    private void OnExitRoomComplete()
    {
        Log("Quit Room: {0}", m_RoomId);
        SendVoiceEvent("quit_room", QAVError.OK, null, m_RoomId);
    }

    private void OnRoomDisconnect(int result, string error)
    {
        Log("Leave Room: {0} = {1}: {2}", m_RoomId, result, error);
    }

    private void OnEndpointsUpdateInfo(int eventID, int count, string[] openIdList)
    {

    }

    private void OnAudioRouteChange(int code)
    {

    }

    private void OnAccomponyFileCompleteHandler(int code, bool isfinished, string filepath)
    {

    }

    private void OnRoomTypeChangedEvent(int roomtype)
    {

    }

    private void OnChangeRoomtypeCallback(int result, string error_info)
    {

    }

    private byte[] GetAuthBuffer(int room)
    {
        return QAVAuthBuffer.GenAuthBuffer(int.Parse(m_AppId), room, m_OpenId, m_AppKey);
    }

    public int Init(string appId, string appKey, string openId)
    {
        m_AppId = appId; m_AppKey = appKey; m_OpenId = openId;

        return VerifyRet(m_Context.Init(appId, openId));
    }

    public int Uninit()
    {
        m_AppId = null; m_AppKey = null; m_OpenId = null;
        if (m_Context.IsRoomEntered()) {
            m_Context.ExitRoom();
        }
        return VerifyRet(m_Context.Uninit());
    }

    public int JoinRoom(int room, int type, int teamId)
    {
        if (m_AppId == null) return -1;

        m_RoomId = room.ToString();

        byte[] authBuffer = GetAuthBuffer(room);

        var roomType = (ITMGRoomType)type;
        int ret;
        if (teamId != 0) {
            ret = m_Context.EnterTeamRoom(room, roomType, authBuffer, teamId, 0);
        } else {
            ret = m_Context.EnterRoom(room, roomType, authBuffer);
        }

        return VerifyRet(ret);
    }

    public int QuitRoom()
    {
        return m_Context.IsRoomEntered() ? VerifyRet(m_Context.ExitRoom()) : 0;
    }

    public void EnableVoiceRecv(bool value)
    {
        m_Context.GetAudioCtrl().EnableAudioRecv(value);
    }

    public void EnableVoiceSend(bool value)
    {
        m_Context.GetAudioCtrl().EnableAudioSend(value);
    }

    public int StartRecording(string filePath)
    {
        return m_Context.GetPttCtrl().StartRecording(filePath);
    }

    public int StopRecording()
    {
        return m_Context.GetPttCtrl().StopRecording();
    }

    public int UploadRecordedFile(string filePath, int timeout)
    {
        return m_Context.GetPttCtrl().UploadRecordedFile(filePath);
    }

    public int DownloadRecordedFile(string fileId, string filePath, int timeout)
    {
        return m_Context.GetPttCtrl().DownloadRecordedFile(fileId, filePath);
    }

    public int PlayRecordedFile(string filePath)
    {
        if (!System.IO.File.Exists(filePath)) {
            return QAVError.ERR_VOICE_RECORD_OPENFILE_ERR;
        }

        return m_Context.GetPttCtrl().PlayRecordedFile(filePath);
    }

    public int StopPlayFile()
    {
        return m_Context.GetPttCtrl().StopPlayFile();
    }

    public static int VerifyRet(int ret, object param = null)
    {
        if (ret != QAVError.OK) {
            if (param != null) {
                LogMgr.E("Voice failure:{0} {1}", ret, param);
            } else {
                LogMgr.E("Voice failure:{0}", ret);
            }
        }
        return ret;
    }
}
