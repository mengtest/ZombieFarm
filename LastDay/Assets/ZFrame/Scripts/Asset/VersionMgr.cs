using UnityEngine;
using System.Collections;
using System.IO;

namespace ZFrame.Asset
{

    public static class VersionMgr
    {
        public struct VersionInfo
        {
            public string version;
            public string timeCreated;
            public string whoCreated;

            public override string ToString()
            {
                return string.Format("版本号：{0}，日期：{1}，生成：{2}", version, timeCreated, whoCreated);
            }

            public string ToFormatString(string fmt)
            {
                return string.Format(fmt, version, timeCreated, whoCreated);
            }
        }

        private static VersionInfo s_AppVer, s_AssetVer;

        public static VersionInfo AppVersion {
            get {
#if UNITY_EDITOR
                if (!Application.isPlaying) {
                    s_AppVer.version = null;
                }
#endif
                if (s_AppVer.version == null) {
                    var txt = Resources.Load<TextAsset>("version");
                    if (txt) {
                        var lines = txt.text.Split(new char[] { '\n', '\r' });
                        s_AppVer = ParseVersionInfo(lines);
                    } else {
                        s_AppVer.version = "";
                        s_AppVer.timeCreated = "";
                        s_AppVer.whoCreated = "";
                    }
                }
                return s_AppVer;
            }
        }

        public static void Reset()
        {
            s_AppVer.version = null;
            s_AssetVer.version = null;
        }

        public static VersionInfo AssetVersion {
            get {
#if UNITY_EDITOR
                if (!Application.isPlaying) {
                    s_AssetVer.version = null;
                }
#endif
                if (s_AssetVer.version == null) {
                    try {
                        if (AssetBundleLoader.I) {
                            var filelist = AssetBundleLoader.FILE_LIST;
                            string jsonStr = File.ReadAllText(AssetBundleLoader.bundleRootPath + "/" + filelist);
                            var jo = TinyJSON.JSON.Load(jsonStr);
                            s_AssetVer.version = jo["version"];
                            s_AssetVer.timeCreated = null;
                            s_AssetVer.whoCreated = null;
                        } else {
#if UNITY_EDITOR
                            string AssetVersionPath = string.Format("Assets/{0}/version.txt", AssetBundleLoader.DIR_ASSETS);
                            var lines = File.ReadAllLines(AssetVersionPath);
                            s_AssetVer = ParseVersionInfo(lines);
#else
                            
#endif
                        }
                        
                    } catch (System.Exception e) {
                        s_AssetVer.version = "unknow";
                        LogMgr.E(e.Message);
                    }                    
                }

                return s_AssetVer;
            }
        }

        private static VersionInfo ParseVersionInfo(string[] lnies)
        {
            VersionInfo verInf = new VersionInfo();
            if (lnies.Length > 0) verInf.version = lnies[0];
            if (lnies.Length > 1) verInf.timeCreated = lnies[1];
            if (lnies.Length > 2) verInf.whoCreated = lnies[2];
            return verInf;
        }
        
        public static void SaveAppVersion(string ver)
        {
#if UNITY_EDITOR
            string AppVersionPath = "Assets/Resources/version.txt";
            var dateTime = System.DateTime.Now;
            File.WriteAllText(AppVersionPath, string.Format(
                "{0}\n{1} {2}\n{3}", ver,
                dateTime.ToShortDateString(),
                dateTime.ToLongTimeString(),
                SystemInfo.deviceName));
            s_AppVer.version = ver;
#else
            LogMgr.W("非编辑器模式无法修改应用版本号");
#endif
        }
        
        public static void SaveAssetVersion(string ver)
        {
#if UNITY_EDITOR
            string AssetVersionPath = string.Format("Assets/{0}/version.txt", AssetBundleLoader.DIR_ASSETS);
            var dateTime = System.DateTime.Now;
            File.WriteAllText(AssetVersionPath, string.Format(
                "{0}\n{1} {2}\n{3}", ver,
                dateTime.ToShortDateString(),
                dateTime.ToLongTimeString(),
                SystemInfo.deviceName));
            s_AssetVer.version = ver;
#else
            LogMgr.W("非编辑器模式无法修改资源版本号");
#endif
        }

    }
}
