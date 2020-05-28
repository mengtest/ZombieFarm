using System.Collections;
using System.Collections.Generic;
using UnityEngine;

#if UNITY_EDITOR || UNITY_ANDROID
namespace ZFrame.Platform
{
    public class Android : IPlatform
    {
        public const string UTIL_PKG_NAME = "com.rongygame.util";
        public const string SDK_PKG_NAME = "com.rongygame.sdk";

        public void OnAppLaunch()
        {
#if !DEVELOPMENT_BUILD
            Application.logMessageReceived += Application_logMessageReceived;
#endif
        }

        private static void Application_logMessageReceived(string condition, string stackTrace, LogType type)
        {
            if (type == LogType.Error || type == LogType.Assert) {
                var trace = new System.Diagnostics.StackTrace();
                Debug.Log(trace.ToString());
            }
        }

        public void CancelAllNotification()
        {
            //Call(UTIL_PKG_NAME + ".XNotification", "CancelAllNotifications");
        }

        public void ScheduleNotification(Notice notice)
        {
            //if (notice.daily) {
            //    Call(UTIL_PKG_NAME + ".XNotification", "RegDailyNotification", 
            //        notice.id, notice.title, notice.icon, notice.message, notice.remainingHour);
            //} else {
            //    Call(UTIL_PKG_NAME + ".XNotification", "RegOnceNotification",
            //        notice.id, notice.title, notice.icon, notice.message, (int)(notice.remainingHour * 3600));
            //}
        }

        public void MessageBox(string json)
        {
            //Call(UTIL_PKG_NAME + ".XAlertDialog", "Alert", json);
        }

        public string ProcessingData(string json)
        {
            return string.Empty;
            //return CallR<string>(SDK_PKG_NAME + ".SDKApi", "OnGameMessageReturn", json);
        }

        public void Call(string className, string method, params object[] args)
        {
            using (AndroidJavaClass jc = new AndroidJavaClass("com.unity3d.player.UnityPlayer")) {
                using (AndroidJavaObject jo = jc.GetStatic<AndroidJavaObject>("currentActivity")) {
                    using (AndroidJavaClass jc_info = new AndroidJavaClass(className)) {
                        List<object> li = new List<object>();
                        li.Add(jo);
                        li.AddRange(args);
                        jc_info.CallStatic(method, li.ToArray());
                    }
                }
            }
        }

        public T CallR<T>(string className, string method, params object[] args)
        {
            using (AndroidJavaClass jc = new AndroidJavaClass("com.unity3d.player.UnityPlayer")) {
                using (AndroidJavaObject jo = jc.GetStatic<AndroidJavaObject>("currentActivity")) {
                    using (AndroidJavaClass jc_info = new AndroidJavaClass(className)) {
                        List<object> li = new List<object>();
                        li.Add(jo);
                        li.AddRange(args);
                        return jc_info.CallStatic<T>(method, li.ToArray());
                    }
                }
            }
        }
    }
}
#endif
