using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;
using ZFrame.Asset;
using FMOD.Studio;

namespace FMODUnity
{
    public class FMODMgr : MonoSingleton<FMODMgr>
    {
        public const int MAIN_LISTENER = 0;
        public const string BUS = "bus:/";
        public const string BUS_BGM = "bus:/BGM";
        public const string BUS_SFX = "bus:/SFX";
        public const string BUS_UI = "bus:/UI";
        public const string EVENT = "event:/{0}";
        public const string SNAPSHOT = "snapshot:/{0}";

        public const string SNAPSHOT_indoor = "snapshot:/snapshot_indoor";

        [SerializeField, AssetRef]
        private string[] m_ResidentBanks;

        [System.NonSerialized, Description("室内")]
        public bool InDoor = false;

        [Description("音源")]
        private List<FMODAudioEmitter> m_Emitters = new List<FMODAudioEmitter>();
        [Description("Banks")]
        private List<string> m_Banks = new List<string>();
        [Description("Listeners")]
        private List<StudioListener> m_Listeners = new List<StudioListener>(FMOD.CONSTANTS.MAX_LISTENERS);
        private List<Transform> m_ListenerPos = new List<Transform>(FMOD.CONSTANTS.MAX_LISTENERS);
        private List<Transform> m_ListenerRot = new List<Transform>(FMOD.CONSTANTS.MAX_LISTENERS);

        public bool ready { get { return m_Listeners.Count > 0; } }
        
        public FMODAudioEmitter GetEmitter(Transform parent)
        {
            FMODAudioEmitter emitter = null;
            for (int i = 0; i < m_Emitters.Count;) {
                var emit = m_Emitters[i];
                if (emit != null) {
                    if (!emit.IsPlaying()) {
                        emitter = emit;
                        break;
                    }
                    ++i;
                } else {
                    m_Emitters.RemoveAt(i);
                }
            }

            if (emitter == null) {
                var prefab = AssetsMgr.A.Load(typeof(GameObject), "UI/AudioEmitter") as GameObject;
                GameObject go = GoTools.NewChild(null, prefab);
                emitter = go.GetComponent(typeof(FMODAudioEmitter)) as FMODAudioEmitter;
                m_Emitters.Add(emitter);
            } else {
                emitter.enabled = true;
            }

            var emitterTrans = emitter.transform;
            emitterTrans.SetParent(parent);
            emitterTrans.localPosition = Vector3.zero;
            emitterTrans.localRotation = Quaternion.identity;

            return emitter;
        }

        private FMODAudioEmitter FindEmitter(string fmt, string eventName, Transform parent)
        {
            var eventPath = string.Format(fmt, eventName);
            for (int i = 0; i < m_Emitters.Count;) {
                var emitter = m_Emitters[i];
                if (emitter != null) {
                    if (emitter.IsPlaying()
                        && parent == emitter.transform.parent
                        && emitter.current == eventPath) {
                        return emitter;
                    }
                    ++i;
                } else {
                    m_Emitters.RemoveAt(i);
                }
            }

            return null;
        }

        public static FMODAudioEmitter Find(string eventName, Transform parent = null)
        {
            return Instance.FindEmitter(EVENT, eventName, parent);
        }

        public static FMODAudioEmitter NewEmitter(string fmt, string eventName,
            Transform parent = null, bool fadeout = true)
        {
            var emitter = Instance.GetEmitter(parent);
            return emitter.Init(string.Format(fmt, eventName));
        }

        public static FMODAudioEmitter Play(string eventName,
            Transform parent = null, bool fadeout = true)
        {
            var emitter = NewEmitter(EVENT, eventName, parent, fadeout);
            emitter.Play();
            return emitter;
        }

        public static FMODAudioEmitter PlayEvent(string eventPath,
            Transform parent = null, bool fadeout = true)
        {
            var emitter = Instance.GetEmitter(parent);
            emitter.Init(eventPath).Play();
            return emitter;
        }

        public static void Snapshot(string snapshot, bool on)
        {
            if (on) {
                var emitter = NewEmitter(SNAPSHOT, snapshot);
                emitter.Play();
            } else {
                var emitter = Instance.FindEmitter(SNAPSHOT, snapshot, null);
                if (emitter) emitter.Stop(false);
            }
        }

        private void StopEvent(string eventName, Transform parent)
        {
            var emitter = FindEmitter(EVENT, eventName, parent);
            if (emitter) emitter.Stop(false);
        }

        public static void Stop(string eventName, Transform parent = null)
        {
            Instance.StopEvent(eventName, parent);
        }

        public StudioListener NewListener()
        {
            var index = m_Listeners.Count;
            if (index < FMOD.CONSTANTS.MAX_LISTENERS) {
                var go = new GameObject("FMODListener" + index);
                DontDestroyOnLoad(go);
                var listener = go.AddComponent(typeof(StudioListener)) as StudioListener;
                listener.ListenerNumber = index;
                m_Listeners.Add(listener);
                m_ListenerPos.Add(null);
                m_ListenerRot.Add(null);
                return listener;
            }
            return null;
        }

        public void SetListener(int index, Transform pos, Transform rot)
        {
            if (index < m_Listeners.Count) {
                var listener = m_Listeners[index];
                if (listener != null) {
                    m_ListenerPos[index] = pos;
                    m_ListenerRot[index] = rot;
                }
            }
        }
        
        public static void AttachInstance(EventInstance instance, Transform transform, Rigidbody rigidBody)
        {
            RuntimeManager.AttachInstanceToGameObject(instance, transform, rigidBody);
        }

        public static void DetachInstance(EventInstance instance)
        {
            RuntimeManager.DetachInstanceFromGameObject(instance);
        }

        public static float GetBusVolume(string bus)
        {
            float volume, finalVolume;
            RuntimeManager.GetBus(BUS + bus).getVolume(out volume, out finalVolume);
            return volume;
        }
        
        public static void SetBusVolume(string bus, float volume)
        {
            RuntimeManager.GetBus(BUS + bus).setVolume(volume);
        }
        
        public static bool GetBusPause(string bus)
        {
            bool ret;
            RuntimeManager.GetBus(BUS + bus).getPaused(out ret);
            return ret;
        }

        public static void SetBusPause(string bus, bool pause)
        {
            RuntimeManager.GetBus(BUS + bus).setPaused(pause);
        }

        public static bool GetBusMute(string bus)
        {
            bool ret;
            RuntimeManager.GetBus(BUS + bus).getMute(out ret);
            return ret;
        }

        public static void SetBusMute(string bus, bool mute)
        {
            RuntimeManager.GetBus(BUS + bus).setMute(mute);
        }

        protected override void Awaking()
        {
			base.Awaking();
            SceneManager.sceneLoaded += OnSceneLoaded;
            
            var masterBanks = Settings.Instance.MasterBanks;//MasterBank
            foreach(var masterBank in masterBanks)
            {
                AssetsMgr.A.LoadAsync(null, string.Format("fmod/{0}-strings/{0}.strings", masterBank), LoadMethod.Forever);
                AssetsMgr.A.LoadAsync(null, string.Format("fmod/{0}/", masterBank), LoadMethod.Forever);
            }
            if (m_ResidentBanks != null) {
                foreach (var bank in m_ResidentBanks) {
                    AssetsMgr.A.LoadAsync(null, bank, LoadMethod.Forever);
                }
            }
            AssetsMgr.A.LoadAsync(null, null, LoadMethod.Forever, (a, o, p) => {
                NewListener(); // for MAIN
            });
        }

        private void OnDestroy()
        {
            SceneManager.sceneLoaded -= OnSceneLoaded;
        }
        
        private void Update()
        {
            for (int i = 0; i < m_Listeners.Count; ++i) {
                var listenerTrans = m_Listeners[i].transform;
                var pos = m_ListenerPos[i];
                if (pos) listenerTrans.position = pos.position;

                var rot = m_ListenerRot[i];
                if (rot) listenerTrans.rotation = rot.rotation;
            }
        }

        private void OnSceneLoaded(Scene scene, LoadSceneMode mode)
        {
            var mainCam = Camera.main;
            if (mainCam) SetListener(MAIN_LISTENER, mainCam.transform, mainCam.transform);

            for (int i = m_Emitters.Count - 1; i >= 0; --i) {
                if (m_Emitters[i] == null) {
                    m_Emitters.RemoveAt(i);
                }
            }

            for (int i = m_Banks.Count - 1; i >= 0; --i) {
                var bank = m_Banks[i];
                var bundleName = bank.Replace('.', '-').ToLower();
                if (!AssetsMgr.A.Loader.IsLoaded(string.Format("fmod/{0}/", bundleName))) {
                    m_Banks.RemoveAt(i);
                    RuntimeManager.UnloadBank(bank);
                }
            }    
        }

        public static void OnBankBundleLoaded(string bundleName, AbstractAssetBundleRef ab)
        {
            //if (ab != null) ab.Release();
        }

        public static void OnBankAssetLoaded(string a, object o, object p)
        {
            var asset = o as TextAsset;
            if (asset != null) {
                if (!Instance.m_Banks.Contains(asset.name)) {
                    RuntimeManager.LoadBank(asset, true); //Settings.Instance.AutomaticSampleLoading);
                    Instance.m_Banks.Add(asset.name);
                }
            }
        }
    }
}
