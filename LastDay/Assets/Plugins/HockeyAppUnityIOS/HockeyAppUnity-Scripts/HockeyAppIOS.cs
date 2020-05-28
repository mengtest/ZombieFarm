﻿/*
 * Version: 5.1.0
 */

using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using System;
using System.IO;
using System.Runtime.InteropServices;

public class HockeyAppIOS : MonoBehaviour, IHockeyApp
{
    protected const string HOCKEYAPP_BASEURL = "https://rink.hockeyapp.net/";
    protected const string HOCKEYAPP_CRASHESPATH = "api/2/apps/[APPID]/crashes/upload";
    protected const string LOG_FILE_DIR = "/logs/";
    private const string SERVER_URL_PLACEHOLDER = "your-custom-server-url";
    protected const int MAX_CHARS = 199800;
    private static HockeyAppIOS instance;

    public enum AuthenticatorType
    {
        Anonymous,
        Device,
        HockeyAppUser,
        HockeyAppEmail,
        WebAuth
    }

    [Header("HockeyApp Setup")]
    public string appID = "your-hockey-app-id";
    public string serverURL = SERVER_URL_PLACEHOLDER;

    [Header("Authentication")]
    public AuthenticatorType authenticatorType;
    public string secret = "your-hockey-app-secret";

    [Header("Crashes & Exceptions")]
    public bool autoUploadCrashes = false;
    public bool exceptionLogging = true;

    [Header("Metrics")]
    public bool userMetrics = true;

    [Header("Version Updates")]
    public bool updateAlert = true;

    public int autoUploadLimit = 5;

    public int fileCountLimit = 100;

    public long uid { get; set; }

    public long fpid { get; set; }

#if UNITY_EDITOR || UNITY_IOS
    [DllImport("__Internal")]
    private static extern void HockeyApp_StartHockeyManager(string appID, string serverURL, string authType, string secret, bool updateManagerEnabled, bool userMetricsEnabled, bool autoSendEnabled);
    [DllImport("__Internal")]
    private static extern string HockeyApp_GetVersionCode();
    [DllImport("__Internal")]
    private static extern string HockeyApp_GetVersionName();
    [DllImport("__Internal")]
    private static extern string HockeyApp_GetBundleIdentifier();
    [DllImport("__Internal")]
    private static extern string HockeyApp_GetCrashReporterKey();
    [DllImport("__Internal")]
    private static extern string HockeyApp_GetSdkVersion();
    [DllImport("__Internal")]
    private static extern string HockeyApp_GetSdkName();
    [DllImport("__Internal")]
    private static extern void HockeyApp_ShowFeedbackListView();
    [DllImport("__Internal")]
    private static extern void HockeyApp_CheckForUpdate();

    void Awake()
    {
        if (Application.platform != RuntimePlatform.IPhonePlayer) {
            Destroy(gameObject);
            return;
        }

        if (instance != null) {
            Destroy(gameObject);
            return;
        }

        instance = this;
        DontDestroyOnLoad(gameObject);
        CreateLogDirectory();
    }

    private void Start()
    {
        string urlString = GetBaseURL();
        string authTypeString = GetAuthenticatorTypeString();
        HockeyApp_StartHockeyManager(appID, urlString, authTypeString, secret, updateAlert, userMetrics, autoUploadCrashes);
        
        if (exceptionLogging == true && IsConnected() == true) {
            List<string> logFileDirs = GetLogFiles();
            if (logFileDirs.Count > 0) {
                Debug.Log("Found files: " + logFileDirs.Count);
                StartCoroutine(SendLogs(logFileDirs));
            }
        }
    }

    void OnEnable()
    {
        if (exceptionLogging == true) {
            System.AppDomain.CurrentDomain.UnhandledException += OnHandleUnresolvedException;
            Application.logMessageReceived += OnHandleLogCallback;
        }
    }

    void OnDisable()
    {
        if (exceptionLogging == true) {
            System.AppDomain.CurrentDomain.UnhandledException -= OnHandleUnresolvedException;
            Application.logMessageReceived -= OnHandleLogCallback;
        }
    }

    /// <summary>
    /// Present the modal feedback list user interface.
    /// </summary>
    public static void ShowFeedbackForm()
    {
        HockeyApp_ShowFeedbackListView();
    }

    /// <summary>
    /// Call this to trigger a check if there is a new update available on the HockeyApp servers. If there's a new update, an alert will be shown. When running the app from the App Store, this method call is ignored.
    /// </summary>
    public static void CheckForUpdate()
    {
        HockeyApp_CheckForUpdate();
    }

    /// <summary>
    /// Collect all header fields for the custom exception report.
    /// </summary>
    /// <returns>A list which contains the header fields for a log file.</returns>
    protected virtual List<string> GetLogHeaders()
    {
        List<string> list = new List<string>();

        string bundleID = HockeyApp_GetBundleIdentifier();
        list.Add("Package: " + bundleID);

        string versionCode = HockeyApp_GetVersionCode();
        list.Add("Version Code: " + versionCode);

        string versionName = HockeyApp_GetVersionName();
        list.Add("Version Name: " + versionName);

        string osVersion = "OS: " + SystemInfo.operatingSystem.Replace("iPhone OS ", "");
        list.Add(osVersion);

        list.Add("Model: " + SystemInfo.deviceModel);

        string crashReporterKey = HockeyApp_GetCrashReporterKey();
        list.Add("CrashReporter Key: " + crashReporterKey);

        list.Add("Date: " + DateTime.UtcNow.ToString("ddd MMM dd HH:mm:ss {}zzzz yyyy").Replace("{}", "GMT"));

        list.Add("FPID: " + fpid);
        list.Add("UID: " + uid);

        return list;
    }

    /// <summary>
    /// Create the form data for a single exception report.
    /// </summary>
    /// <param name="log">A string that contains information about the exception.</param>
    /// <returns>The form data for the current exception report.</returns>
    protected virtual WWWForm CreateForm(string log)
    {

        WWWForm form = new WWWForm();

        if (!File.Exists(log)) {

            return form;
        }

        byte[] bytes = null;
        using (FileStream fs = File.OpenRead(log)) {

            if (fs.Length > MAX_CHARS) {
                string resizedLog = null;

                using (StreamReader reader = new StreamReader(fs)) {
                    reader.BaseStream.Seek(fs.Length - MAX_CHARS, SeekOrigin.Begin);
                    resizedLog = reader.ReadToEnd();
                }

                List<string> logHeaders = GetLogHeaders();
                string logHeader = "";

                foreach (string header in logHeaders) {
                    logHeader += header + "\n";
                }

                resizedLog = logHeader + "\n" + "[...]" + resizedLog;

                try {
                    bytes = System.Text.Encoding.Default.GetBytes(resizedLog);
                } catch (ArgumentException ae) {
                    if (Debug.isDebugBuild) Debug.Log("Failed to read bytes of log file: " + ae);
                }
            } else {
                try {
                    bytes = File.ReadAllBytes(log);
                } catch (SystemException se) {
                    if (Debug.isDebugBuild) {
                        Debug.Log("Failed to read bytes of log file: " + se);
                    }
                }

            }
        }

        if (bytes != null) {
            form.AddBinaryData("log", bytes, log, "text/plain");
        }

        return form;
    }

    /// <summary>
    /// Create the log directory if needed.
    /// </summary>
    protected virtual void CreateLogDirectory()
    {
        string logsDirectoryPath = Application.persistentDataPath + LOG_FILE_DIR;

        try {
            Directory.CreateDirectory(logsDirectoryPath);
        } catch (Exception e) {
            if (Debug.isDebugBuild) Debug.Log("Failed to create log directory at " + logsDirectoryPath + ": " + e);
        }
    }

    /// <summary>
    /// Get a list of all existing exception reports.
    /// </summary>
    /// <returns>A list which contains the filenames of the log files.</returns>
    protected virtual List<string> GetLogFiles()
    {
        List<string> logs = new List<string>();

        string logsDirectoryPath = Application.persistentDataPath + LOG_FILE_DIR;

        try {
            DirectoryInfo info = new DirectoryInfo(logsDirectoryPath);
            FileInfo[] files = info.GetFiles();

            if (files.Length > fileCountLimit) {
                info.Delete(true);
                if (Directory.Exists(logsDirectoryPath) == false) {
                    Directory.CreateDirectory(logsDirectoryPath);
                }

                return logs;
            }

            if (files.Length > 0) {
                foreach (FileInfo file in files) {
                    if (file.Extension == ".log") {
                        logs.Add(file.FullName);
                    } else {
                        File.Delete(file.FullName);
                    }
                }
            }
        } catch (Exception e) {
            if (Debug.isDebugBuild) Debug.Log("Failed to write exception log to file: " + e);
        }

        return logs;
    }

    /// <summary>
    /// Upload existing reports to HockeyApp and delete them locally.
    /// </summary>
    protected virtual IEnumerator SendLogs(List<string> logs)
    {
        string crashPath = HOCKEYAPP_CRASHESPATH;
        string url = GetBaseURL() + crashPath.Replace("[APPID]", appID);

        string sdkVersion = HockeyApp_GetSdkVersion();
        string sdkName = HockeyApp_GetSdkName();
        if (sdkName != null && sdkVersion != null) {
            url += "?sdk=" + WWW.EscapeURL(sdkName) + "&sdk_version=" + WWW.EscapeURL(sdkVersion);
        }

        int uploadCount = 0;

        foreach (string log in logs) {

            if (uploadCount >= autoUploadLimit) {
                break;
            }

            ++uploadCount;

            WWWForm postForm = CreateForm(log);
            string lContent = postForm.headers["Content-Type"].ToString();
            lContent = lContent.Replace("\"", "");
            Dictionary<string, string> headers = new Dictionary<string, string>();
            headers.Add("Content-Type", lContent);
            WWW www = new WWW(url, postForm.data, headers);
            yield return www;

            if (String.IsNullOrEmpty(www.error)) {
                try {
                    File.Delete(log);
                } catch (Exception e) {
                    if (Debug.isDebugBuild)
                        Debug.Log("Failed to delete exception log: " + e);
                }
            } else {
                if (Debug.isDebugBuild)
                    Debug.Log("Crash sending error: " + www.error);
            }
        }
    }

    private List<int> CacheStackHash;
    /// <summary>
    /// Write a single exception report to disk.
    /// </summary>
    /// <param name="logString">A string that contains the reason for the exception.</param>
    /// <param name="stackTrace">The stacktrace for the exception.</param>
    protected virtual void WriteLogToDisk(string logString, string stackTrace)
    {
        var hash = stackTrace.GetHashCode();
        if (CacheStackHash == null) CacheStackHash = new List<int>();
        if (CacheStackHash.Contains(hash))
            return;
        else
            CacheStackHash.Add(hash);

        string logSession = DateTime.Now.ToString("yyyy-MM-dd-HH_mm_ss_fff");
        string log = logString.Replace("\n", " ");
        string[] stacktraceLines = stackTrace.Split('\n');

        log = "\n" + log + "\n";
        foreach (string line in stacktraceLines) {
            if (line.Length > 0) {
                log += "  at " + line + "\n";
            }
        }

        List<string> logHeaders = GetLogHeaders();
        using (StreamWriter file = new StreamWriter(Application.persistentDataPath + LOG_FILE_DIR + "LogFile_" + logSession + ".log", true)) {
            foreach (string header in logHeaders) {
                file.WriteLine(header);
            }
            file.WriteLine(log);
        }
    }

    /// <summary>
    /// Get the base url used for custom exception reports.
    /// </summary>
    /// <returns>A formatted base url.</returns>
    protected virtual string GetBaseURL()
    {
        string baseURL = "";

        string urlString = serverURL.Trim();
        if (urlString.Length > 0 && urlString != SERVER_URL_PLACEHOLDER) {
            baseURL = urlString;
            if (baseURL[baseURL.Length - 1].Equals("/") != true) {
                baseURL += "/";
            }
        } else {
            baseURL = HOCKEYAPP_BASEURL;
        }

        return baseURL;
    }

    /// <summary>
    /// Convert selected authentication type to string.
    /// </summary>
    /// <returns>A formatted base url.</returns>
    protected virtual string GetAuthenticatorTypeString()
    {
        string authType = "";

        switch (authenticatorType) {
            case AuthenticatorType.Device:
                authType = "BITAuthenticatorIdentificationTypeDevice";
                break;
            case AuthenticatorType.HockeyAppUser:
                authType = "BITAuthenticatorIdentificationTypeHockeyAppUser";
                break;
            case AuthenticatorType.HockeyAppEmail:
                authType = "BITAuthenticatorIdentificationTypeHockeyAppEmail";
                break;
            case AuthenticatorType.WebAuth:
                authType = "BITAuthenticatorIdentificationTypeWebAuth";
                break;
            default:
                authType = "BITAuthenticatorIdentificationTypeAnonymous";
                break;
        }

        return authType;
    }

    /// <summary>
    /// Checks whether internet is reachable
    /// </summary>
    protected virtual bool IsConnected()
    {
        bool connected = false;
        if (Application.internetReachability == NetworkReachability.ReachableViaLocalAreaNetwork ||
        (Application.internetReachability == NetworkReachability.ReachableViaCarrierDataNetwork)) {
            connected = true;
        }

        return connected;
    }

    /// <summary>
    /// Handle a single exception. By default the exception and its stacktrace gets written to disk.
    /// </summary>
    /// <param name="logString">A string that contains the reason for the exception.</param>
    /// <param name="stackTrace">The stacktrace for the exception.</param>
    protected virtual void HandleException(string logString, string stackTrace)
    {
        WriteLogToDisk(logString, stackTrace);
    }

    /// <summary>
    /// Callback for handling log messages.
    /// </summary>
    /// <param name="logString">A string that contains the reason for the exception.</param>
    /// <param name="stackTrace">The stacktrace for the exception.</param>
    /// <param name="type">The type of the log message.</param>
    public void OnHandleLogCallback(string logString, string stackTrace, LogType type)
    {
        if (LogType.Assert == type || LogType.Exception == type || LogType.Error == type) {
            HandleException(logString, stackTrace);
        }
    }

    /// <summary>
    /// Callback for handling unresolved exceptions.
    /// </summary>
    public void OnHandleUnresolvedException(object sender, System.UnhandledExceptionEventArgs args)
    {
        if (args == null || args.ExceptionObject == null) {
            return;
        }

        if (args.ExceptionObject.GetType() == typeof(System.Exception)) {
            System.Exception e = (System.Exception)args.ExceptionObject;
            HandleException(e.Source, e.StackTrace);
        }
    }
#endif
}