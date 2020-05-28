using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class HockeyAppMgr : MonoSingleton<HockeyAppMgr>
{
    [System.Serializable]
    public class HockeyConfig
    {
        public RuntimePlatform platform;
        public string appId, packageId, secret;
    }

    [SerializeField]
    private string m_ServerURL;

    [SerializeField]
    private bool m_AutoUploadCrashes;

    [SerializeField]
    private bool m_ExceptionLogging;

    [SerializeField]
    private bool m_UserMetrics;

    [SerializeField]
    private bool m_UpdateAlert;

    [SerializeField]
    private int m_AutoUploadLimit = 5;

    [SerializeField]
    private int m_FileCountLimit = 100;

    [SerializeField]
    private HockeyConfig[] m_Configs;

    private IHockeyApp m_HocKeyApp;

    public void SetParam(string key, string value)
    {
        if (m_HocKeyApp == null)
            return;
        if (string.Compare(key, "fpid", true) == 0) {
            long fpid;
            if (long.TryParse(value, out fpid))
                m_HocKeyApp.fpid = fpid;
        } else if(string.Compare(key, "uid", true) == 0) {
            long uid;
            if (long.TryParse(value, out uid))
                m_HocKeyApp.uid = uid;
        } else {
            // 暂时忽略了其他的参数
        }
    }

    protected override void Awaking()
    {
        base.Awaking();
        HockeyConfig config = null;
        foreach (var _config in m_Configs) {
            if (_config.platform == Application.platform) {
                config = _config;
                break;
            }
        }

        if (config != null) {
            var go = new GameObject("HockeyApp");
            switch (Application.platform) {
                case RuntimePlatform.Android: {
                        var hockeyApp = (HockeyAppAndroid)go.AddComponent(typeof(HockeyAppAndroid));
                        m_HocKeyApp = hockeyApp;
                        hockeyApp.appID = config.appId;
                        hockeyApp.packageID = config.packageId;
                        hockeyApp.secret = config.secret;
                        hockeyApp.serverURL = m_ServerURL;
                        hockeyApp.autoUploadCrashes = m_AutoUploadCrashes;
                        hockeyApp.exceptionLogging = m_ExceptionLogging;
                        hockeyApp.userMetrics = m_UserMetrics;
                        hockeyApp.updateAlert = m_UpdateAlert;
                        hockeyApp.autoUploadLimit = m_AutoUploadLimit;
                        hockeyApp.fileCountLimit = m_FileCountLimit;
                    }
                    return;
                case RuntimePlatform.IPhonePlayer: {
                        var hockeyApp = (HockeyAppIOS)go.AddComponent(typeof(HockeyAppIOS));
                        m_HocKeyApp = hockeyApp;
                        hockeyApp.appID = config.appId;
                        hockeyApp.secret = config.secret;
                        hockeyApp.serverURL = m_ServerURL;
                        hockeyApp.autoUploadCrashes = m_AutoUploadCrashes;
                        hockeyApp.exceptionLogging = m_ExceptionLogging;
                        hockeyApp.userMetrics = m_UserMetrics;
                        hockeyApp.updateAlert = m_UpdateAlert;
                        hockeyApp.autoUploadLimit = m_AutoUploadLimit;
                        hockeyApp.fileCountLimit = m_FileCountLimit;
                    }
                    return;
            }
        }

    }
}
