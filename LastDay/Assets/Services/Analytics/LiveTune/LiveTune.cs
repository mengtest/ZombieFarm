using System.Collections;
using System.Collections.Generic;
using UnityEngine;
#if UNITY_5_4_OR_NEWER
//https://unity3d.com/unity/whats-new/unity-5.4.0
//Scripting: Promoted WebRequest interface from UnityEngine.Experimental.Networking to 
//UnityEngine.Networking.Unity 5.2 and 5.3 projects that use UnityWebRequest will need to be updated.
using UnityEngine.Networking;
#else
using UnityEngine.Experimental.Networking;
#endif
using UnityEngine.Analytics;
using Unity.Performance;
using System;
using System.IO;

namespace Unity.LiveTune
{

#if LIVETUNE_STAGING
	class DummyCertCheck : CertificateHandler {
		protected override bool ValidateCertificate(byte[] certificateData) {
			return true;
		}
	}
#endif

    /// <summary>The LiveTune class provides access to the LiveTune service.</summary>
	public class LiveTune : MonoBehaviour
	{
		private static string CLIENT_DEFAULT_SEGMENT = "-1";
		private static string LiveTuneDir = "/unity.autotune";
		private static string SegmentConfigCacheFilePath = LiveTuneDir + "/segmentconfig.json";

		private static string[] Endpoints = new string[3] {
#if LIVETUNE_STAGING
			"https://internal-aff7a7605442411e89b5a020f66684a1-2089975515.us-west-1.elb.amazonaws.com",
			"https://internal-affa92ce8442411e89b5a020f66684a1-948043733.us-west-1.elb.amazonaws.com",
#else
			"https://sandbox-livetune.uca.cloud.unity3d.com",
			"https://prod-livetune.uca.cloud.unity3d.com",
#endif
			"http://localhost:4567"
		};

        /// <summary>Defines which service endpoint to use.</summary>
		public enum Endpoint
		{
            ///<summary>The testing endpoint to use before your LiveTune integration goes live. </summary>
			Sandbox = 0,
            ///<summary>The production endpoint for live apps.</summary>
			Production = 1,
            ///<summary>Do not use. For internal (Unity) testing.</summary>
			Local = 2
		};

        ///<summary>Defines the signature of the callback function called by LiveTune when it receives your configuration.</summary>
        /// <remarks>
        /// Pass a reference to your callback funtion to the <see cref="LiveTune.Init"/> function.
        /// </remarks>
        /// <param name="settingsJson">The LiveTune configuration in JSON format.</param>
        /// <param name="isBaseline">Whether or not this device is part of the baseline group. If isBaseLine is true, then the 
        /// settings and values in settingsJSON are those that you passed to <see cref="LiveTune.Init"/>. In other words,
        /// devices in the baseline group always use your default settings.</param>
        /// <param name="segmentName">The name assigned to the LiveTune segment containing the current device.</param>
		public delegate void Callback(string settingsJson, bool isBaseline, string segmentName);

		/// STATIC METHODS & PROPS
#region StaticMethods
		private static LiveTune _instance;

		[RuntimeInitializeOnLoadMethod]
		private static LiveTune GetInstance()
		{
			if (_instance == null)
			{
				_instance = FindObjectOfType<LiveTune>();
				if (_instance == null)
				{
					var gO = new GameObject("LiveTune");
					_instance = gO.AddComponent<LiveTune>();
					gO.hideFlags = HideFlags.HideAndDontSave;
				}
				DontDestroyOnLoad(_instance.gameObject);
			}
			return _instance;
		}

        /// <summary>
        /// Initializes LiveTune and makes a network request for the LiveTune configuration.
        /// </summary>
        /// <remarks>
        /// <para>The response to the LiveTune configuration request arrives asynchronously. 
        /// When LiveTune receives the configuration, LiveTune invokes your callback function, 
        /// passing it a JSON string containing the configuration.
        /// Use your callback function to apply the setting values in the LiveTune configuration 
        /// to the appropriate game settings.</para>
        /// </remarks>
        /// <param name="buildVersion">Your application build version.</param>
        /// 
        /// <param name="usePersistentPath">Set true to cache the configuration at the 
        /// <a href="https://docs.unity3d.com/ScriptReference/Application-persistentDataPath.html">persistentDataPath</a>; 
        /// set false to store the configuration at the 
        /// <a href="https://docs.unity3d.com/ScriptReference/Application-temporaryCachePath.html">temporaryCachePath</a>.
        /// LiveTune uses the stored configuration if it cannot connect to the LiveTune service. Data stored using the persistent
        /// path is less likely to be deleted.</param>
        /// 
        /// <param name="defaultValues">An object containing the default values for your settings. The fields of this object must be
        /// simple, serializable types and the object class must be marked as serializable. LiveTune passes a JSON version of this object
        /// to your callback function when it cannot connect to the LiveTune service and no cached configuration is available. 
        /// (A cached configuration won't be available for new installs or when the cache has been deleted.) LiveTune also
        /// passes the defaultValues object to your callback for any devices in the baseline group.</param>
        /// 
        /// <param name="callback">LiveTune invokes this callback function when the configuration is received or the request fails. 
        /// When a request fails, the cached configuration is passed to your function. If no cached configuration is available,
        /// LiveTune passes a JSON representation of <paramref name="defaultValues"/> object instead.</param>
        /// 
        /// <param name="endpoint">The LiveTune service endpoint. Use <see cref="LiveTune.Endpoint.Sandbox"/> when developing and 
        /// testing your LiveTune integration. Change to <see cref="LiveTune.Endpoint.Production"/> when you release your game. 
        /// Defaults to Sandbox.</param>
		public static void Init(string buildVersion,
								bool usePersistentPath,
								object defaultValues,
								Callback callback,
								Endpoint endpoint = Endpoint.Sandbox)
		{
			if (String.IsNullOrEmpty(Application.cloudProjectId))
			{
				throw new Exception("You must enable Analytics to be able to use AutoTune");
			}
			string defJson = defaultValues is string ? (string)defaultValues : JsonUtility.ToJson(defaultValues);
			GetInstance()._projectId = Application.cloudProjectId;
			// by default, the client config is *NOT* baseline
			GetInstance()._clientDefaultConfig = new SegmentConfig(CLIENT_DEFAULT_SEGMENT, false, defJson, "client_default", "client_default");
			// Application.persistentDataPath can only be called from the main thread so we cache it in init
			GetInstance()._storePath = usePersistentPath ? Application.persistentDataPath : Application.temporaryCachePath;
			GetInstance()._buildVersion = buildVersion;
			GetInstance()._endpoint = endpoint;

			// load cache segment config last after all other variables has been set
			GetInstance().LoadCacheSegmentConfig();
			GetInstance().SetBuildVersion(buildVersion);
			
			// fetch new settings for this specific device
			GetInstance().CleanUp();
			GetInstance()._callback = callback;
			GetInstance()._startTime = GetCurrentTimestamp();
			GetInstance()._fetchInGameTime = Time.time;
			GetInstance().StartCoroutine("TryFetch");
		}
		
		/// <summary>
		/// Sets the build version. Only needs to be set once after application start.
		/// </summary>
		private void SetBuildVersion (string buildVersion)
		{
			Benchmarking.buildVersion = buildVersion;
		}

        /// <summary>
        /// Captures a performance snapshot of the specified duration.
        /// </summary>
        /// <remarks>You can only capture one snapshot at a time.
        /// LiveTune sends the snapshot data to the service automatically.</remarks>
        /// <param name="snapshotName">A name to identify this snapshot. This name appears in your LiveTune reports.</param>
        /// <param name="duration">The amount of time, in seconds, to monitor frame rate.</param>
		public static void StartTimedSnapshot(string snapshotName, long duration)
		{
			GetInstance().StartCoroutine(GetInstance().InnerStartTimedSnapshot(snapshotName, duration));
		}

		private IEnumerator InnerStartTimedSnapshot(string snapshotName, long duration)
		{
			StartSnapshot(snapshotName);
			yield return new WaitForSeconds(duration);
			EndSnapshot();
		}

        /// <summary>
        /// Begin monitoring performance.
        /// </summary>
        /// <remarks>Terminate a snapshot by calling <see cref="EndSnapshot"/>. You can only capture one snapshot at a time.
        /// LiveTune sends the snapshot data to the service automatically.</remarks>
        /// <param name="snapshotName">A name to identify this snapshot. This name appears in your LiveTune reports.</param>
		public static void StartSnapshot(string snapshotName)
		{
			
			if (GetInstance()._runningSnapshot)
			{
				Debug.LogError("Can't run two snapshots at the same time");
			}
			else
			{
				GetInstance()._runningSnapshot = true;
				Benchmarking.BeginExperiment(snapshotName);
			}
		}
		
        /// <summary>
        /// End the current snapshot.
        /// </summary>
        /// <remarks>LiveTune sends the snapshot data to the service automatically.
        /// <para>See also: <seealso cref="StartSnapshot"></seealso></para></remarks>
		public static void EndSnapshot()
		{
			Benchmarking.EndExperiment();
			Benchmarking.Finished();
			GetInstance()._runningSnapshot = false;
		}

		/// <summary>
		/// Returns true if a snapshot is running
		/// </summary>
		public static bool IsSnapshotRunning()
		{
			return GetInstance()._runningSnapshot;
		}
		

        /// <summary>
        /// Call this method, passing in true, when you allow a player to manually override your
        /// LiveTune-recommended settings.</summary>
        /// <remarks>
        /// <para>If you allow players to manually choose specific quality settings, you must exclude those
        /// players from your LiveTune performance monitoring by calling SetPlayerOverride(true). 
        /// Otherwise, the results from players who chose their own settings can distort the 
        /// data collected for their device segment.</para>
        /// <para>
        /// If a player chooses to restore the recommended settings, you can begin monitoring their performance again
        /// by calling SetPlayerOverride(false). 
        /// </para>
        /// <para>See also: <seealso cref="ChangeTargetFrameRate"></seealso></para>
        /// </remarks>
        /// <param name="isPlayerOverride">Specify whether the current player has manually changed your performance 
        /// settings (true); or is no longer overriding the recommended settings (false).</param>
		public static void SetPlayerOverride(bool isPlayerOverride)
		{
			GetInstance()._isPlayerOverride = isPlayerOverride;
		}

		private static long GetCurrentTimestamp()
		{
			return DateTime.Now.Ticks / TimeSpan.TicksPerMillisecond;
		}
		#endregion

		/// MONOBEHAVIOUR METHODS & INSTANCE PROPS
		#region MonoBehaviourMethods
		private string _projectId;
		private string _buildVersion;
		private SegmentConfig _clientDefaultConfig;
		private string _storePath;
		private Endpoint _endpoint;

		// once initialized, the _cachedSegmentConfig is never null
		private SegmentConfig _cachedSegmentConfig;
		private bool _isPlayerOverride = false;

		// request state
		private bool _isError = false;
		private long _startTime = 0;
		private long _requestTime = 0;
		private float _fetchInGameTime = 0;
		private Callback _callback;
		private DeviceInfo _deviceInfo = null;

		private bool _runningSnapshot = false;

		void Awake()
		{
			if (!GetInstance().Equals(this)) Destroy(gameObject);
		}

		private void SendCallback()
		{
			if (_callback != null)
			{
				var segmentConfig = _cachedSegmentConfig;
				try
				{
					var callbackInGameTime = Time.time;
					var callbackTime = GetCurrentTimestamp() - _startTime;
					var baseline = segmentConfig.is_baseline;
					
					var settingsJson = (baseline ? _clientDefaultConfig.settingsJson : segmentConfig.settingsJson);
					var name = (baseline ? _clientDefaultConfig.segment_name : segmentConfig.segment_name);
					_callback(settingsJson, baseline, name);
					
					Dictionary<string, object> segmentRequestInfoEvent = PopulateAutoTuneEvent();
					segmentRequestInfoEvent.Add("request_latency", _requestTime);
					segmentRequestInfoEvent.Add("callback_latency", callbackTime);
					segmentRequestInfoEvent.Add("fetch_time", _fetchInGameTime);
					segmentRequestInfoEvent.Add("callback_time", callbackInGameTime);

					Analytics.CustomEvent("autotune.SegmentRequestInfo", segmentRequestInfoEvent);
				}
				catch (System.Exception e)
				{
					Debug.LogError(e);
				}
				finally
				{
					_isError = false;
				}
			}
		}

		private IEnumerator TryFetch()
		{
			DeviceInfo di = new DeviceInfo(_projectId, _buildVersion);
			string payload = JsonUtility.ToJson(di);
			_deviceInfo = di;
			byte[] bytes = System.Text.Encoding.UTF8.GetBytes(payload);
			string baseUrl = Endpoints[(int)_endpoint];
			var req = new UnityWebRequest(baseUrl + "/v3/settings");
			var uploader = new UploadHandlerRaw(bytes) { contentType = "application/json" };
			req.uploadHandler = uploader;
			req.downloadHandler = new DownloadHandlerBuffer();
			req.method = UnityWebRequest.kHttpVerbPOST;
			req.chunkedTransfer = false;
#if LIVETUNE_STAGING
			req.certificateHandler = new DummyCertCheck();
#endif
#if UNITY_2017_1_OR_NEWER
			req.timeout = 10;
#endif
			var startTime = LiveTune.GetCurrentTimestamp();
#if UNITY_2017_3_OR_NEWER
			yield return req.SendWebRequest();
#else
			yield return req.Send();
#endif
			_requestTime = LiveTune.GetCurrentTimestamp() - startTime;
#if UNITY_2017_1_OR_NEWER
			var error = req.isNetworkError || req.isHttpError;
#else
			var error = req.isError;
#endif
			if (error)
			{
				Debug.LogError(req.error);
				lock (this)
				{
					_isError = true;
				}
			}
			else
			{
				try
				{
					var jsonStr = System.Text.Encoding.UTF8.GetString(req.downloadHandler.data);
					var resp = JsonUtility.FromJson<SegmentConfig>(jsonStr);

					lock (this)
					{
						if (_cachedSegmentConfig.config_hash != resp.config_hash)
						{
							CacheSegmentConfig(resp);
						}
						_cachedSegmentConfig = resp;
					}
					if (!resp.is_baseline) {
						QualitySettingsCarrier.Apply(resp.qs_settingsJson);
					}
				}
				catch (Exception ex)
				{
					Debug.LogError("LiveTune error parsing response: " + ex);
					lock (this)
					{
						_isError = true;
					}
				}				
			}
			SendCallback();
		}

		private void CacheSegmentConfig(SegmentConfig config)
		{
			var dirPath = _storePath + LiveTuneDir;
			if (!Directory.Exists(dirPath))
			{
				Directory.CreateDirectory(dirPath);
			}

			var filePath = _storePath + SegmentConfigCacheFilePath;
			using (var writer = new StreamWriter(filePath))
			{
				writer.Write(JsonUtility.ToJson(config));
			}
		}

		/// <summary>
		/// Loads from file.
		/// On failure this defaults to use client default setting.
		/// </summary>
		private void LoadCacheSegmentConfig()
		{
			var filePath = _storePath + SegmentConfigCacheFilePath;
			if (!File.Exists(filePath))
			{
				_cachedSegmentConfig = _clientDefaultConfig;
				return;
			}

			try
			{
				using (var reader = new StreamReader(filePath))
				{
					var json = reader.ReadToEnd();
					_cachedSegmentConfig = JsonUtility.FromJson<SegmentConfig>(json);
				}
			}
			catch (Exception ex)
			{
				// for any issues with the file, use client defaults
				_cachedSegmentConfig = _clientDefaultConfig;
				Debug.LogError("LiveTune error processing cached config file: " + filePath + " , error: " + ex);
			}
		}
		
        /// <summary>
        /// Changes <a href="https://docs.unity3d.com/ScriptReference/Application-targetFrameRate.html">Application.targetFrameRate</a>
        /// and informs the LiveTune service of the change.</summary>
        /// <remarks>Any running performance snapshots are also terminated. Call this function instead of setting 
        /// <a href="https://docs.unity3d.com/ScriptReference/Application-targetFrameRate.html">Application.targetFrameRate</a> directly
        /// to avoid invalidating your LiveTune performance monitoring data.</remarks>
        /// <param name="targetFrameRate">The new target frame rate.</param>
		public static void ChangeTargetFrameRate(int targetFrameRate)
		{
			GetInstance().InnerChangeTargetFrameRate(targetFrameRate);
		}

		private void InnerChangeTargetFrameRate(int targetFrameRate)
		{
			Dictionary<string, object> autoTuneEvent = PopulateAutoTuneEvent();
			autoTuneEvent.Add("new_target_framerate", targetFrameRate);
			autoTuneEvent.Add("current_target_framerate", Application.targetFrameRate);
			
			Analytics.CustomEvent("autotune.TargetFrameRateChanged", autoTuneEvent);
			
			
			if (_runningSnapshot)
			{
				Debug.LogWarning("There is a snapshot running. Ending snapshot before changing target frame rate.");
				EndSnapshot();
			}
			Application.targetFrameRate = targetFrameRate;
		}
		
		/// <summary>
		/// Returns a dictionary with populated device info data.
		/// </summary>
		private Dictionary<string, object> PopulateAutoTuneEvent()
		{
			var segmentConfig = _cachedSegmentConfig;
			var deviceInfo = _deviceInfo;
			
			// should not happen but do not want to write null checks in code below this
			if (deviceInfo == null)
			{
				deviceInfo = new DeviceInfo(_projectId, _buildVersion);
			}
			
			// device information data should reuse the same naming convention as DeviceInfo event
			Dictionary<string, object> autoTuneEvent = new Dictionary<string, object>()
			{
				{"segment_id", segmentConfig.segment_id},
				{"group_id", segmentConfig.is_baseline ? 2 : 1},
				{"player_override", _isPlayerOverride},
				{"model", deviceInfo.model},
				{"ram", deviceInfo.ram},
				{"cpu", deviceInfo.cpu},
				{"cpu_count", deviceInfo.cpu_count},
				{"gfx_name", deviceInfo.gfx_name},
				{"gfx_vendor", deviceInfo.gfx_vendor},
				{"screen", deviceInfo.screen},
				{"dpi", deviceInfo.dpi},
				{"gfx_ver", deviceInfo.gfx_ver},
				{"gfx_shader", deviceInfo.gfx_shader},
				{"max_texture_size", deviceInfo.max_texture_size},
				{"os_ver", deviceInfo.os_ver},
				{"platform_id", deviceInfo.platform_id},
				{"app_build_version", _buildVersion},
				{"plugin_version", LiveTuneMeta.version},
				{"project_id", deviceInfo.project_id},
				{"environment", _endpoint.ToString()},
				{"errored", _isError}
			};

			return autoTuneEvent;
		}

		private void CleanUp()
		{
			_isError = false;
			_deviceInfo = null;
			_callback = null;
			_startTime = 0;
		}
		#endregion

		#region DeviceInfoClass
		/// <summary>
		/// This is a custom version of DeviceInfo that we will use to get a segment
		/// for this particular device.
		/// </summary>
		private class DeviceInfo
		{
			public string model;
			public int ram;
			public string cpu;
			public string gfx_name;
			public string gfx_vendor;
			public string device_id;
			public int cpu_count;
			public float dpi;
			public string screen;
			public string project_id;
			public int platform_id;
			public string os_ver;
			public int gfx_shader;
			public string gfx_ver;
			public int max_texture_size;
			public string app_build_version;
			public bool in_editor;
			public string user_id;

			public DeviceInfo(string projectId, string app_build_version)
			{
				this.project_id = projectId;
				this.app_build_version = app_build_version;
				this.model = GetDeviceModel();
				this.device_id = SystemInfo.deviceUniqueIdentifier;
				this.ram = SystemInfo.systemMemorySize;
				this.cpu = SystemInfo.processorType;
				this.cpu_count = SystemInfo.processorCount;
				this.gfx_name = SystemInfo.graphicsDeviceName;
				this.gfx_vendor = SystemInfo.graphicsDeviceVendor;
				this.screen = Screen.currentResolution.ToString();
				this.dpi = Screen.dpi;
				this.in_editor = false;
				if (Application.isEditor)
				{
					Debug.LogWarning("*** LiveTune running in editor: Will send platform as Android");
					this.platform_id = (int)RuntimePlatform.Android;
					this.in_editor = true;
				}
				else
				{
					this.platform_id = (int)Application.platform;
				}
				this.os_ver = SystemInfo.operatingSystem;
				this.gfx_shader = SystemInfo.graphicsShaderLevel;
				this.gfx_ver = SystemInfo.graphicsDeviceVersion;
				this.max_texture_size = SystemInfo.maxTextureSize;
#if UNITY_2017_2_OR_NEWER
				this.user_id =  AnalyticsSessionInfo.userId;
#else
				this.user_id =  PlayerPrefs.GetString("unity.cloud_userid");
#endif
			}

			private string GetDeviceModel()
			{
#if UNITY_ANDROID && !UNITY_EDITOR
			// get manufacturer/model/device
			AndroidJavaClass jc = new AndroidJavaClass("android.os.Build");
			string manufacturer = jc.GetStatic<string>("MANUFACTURER");
			string model = jc.GetStatic<string>("MODEL");
			string device = jc.GetStatic<string>("DEVICE");
			return String.Format("{0}/{1}/{2}", manufacturer, model, device);
#else
				return SystemInfo.deviceModel;
#endif
			}
		}
		#endregion
	}
}
