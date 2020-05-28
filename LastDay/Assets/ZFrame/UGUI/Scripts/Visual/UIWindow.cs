using UnityEngine;
using UnityEngine.EventSystems;
using System.Collections;
using System.Collections.Generic;

namespace ZFrame.UGUI
{
    [DisallowMultipleComponent]
    public class UIWindow : MonoBehaviour, IPoolable
    {
        protected static Dictionary<string, UIWindow> s_OpenWindows = new Dictionary<string, UIWindow>();
        public string cachedName { get; private set; }

        public static UIWindow FindByName(string wndName)
        {
            UIWindow wnd;
            s_OpenWindows.TryGetValue(wndName, out wnd);
            return wnd;
        }

        [SerializeField, HideInInspector, AssetRef(bundleOnly = true)]
        private string[] m_PreloadAssets;

        private List<Canvas> m_SubCanvas = new List<Canvas>();

        public string[] preloadAssets { get { return m_PreloadAssets; } }

        [System.NonSerialized] public int depth;

        protected virtual void Awake()
        {
            gameObject.NeedComponent(typeof(Canvas));
            gameObject.NeedComponent(typeof(CanvasGroup));
            
            gameObject.GetComponentsInChildren(m_SubCanvas);
        }

        protected virtual void Start()
        {
            if (string.IsNullOrEmpty(cachedName)) cachedName = name;
            if (!s_OpenWindows.ContainsKey(cachedName)) {
                s_OpenWindows.Add(cachedName, this);
            }
        }
        
        public virtual void OnRecycle()
        {
            for (int i = 0; i < m_SubCanvas.Count; ++i) {
                m_SubCanvas[i].enabled = false;
            }
            gameObject.SetEnable(typeof(CanvasGroup), false);

            if (!string.IsNullOrEmpty(cachedName))
                s_OpenWindows.Remove(cachedName);
        }

        public virtual void SendEvent(Component sender, UIEvent eventName, string eventParam, object data = null) { }

        private void OnDestroy()
        {
#if UNITY_EDITOR
            if (!LuaScriptMgr.Instance) return;
#endif
            if (cachedName != null && s_OpenWindows.ContainsKey(cachedName)) {
                OnRecycle();
            }
        }

        void IPoolable.OnRestart()
        {
            this.enabled = true;
            gameObject.SetEnable(typeof(CanvasGroup), true);
            for (int i = 0; i < m_SubCanvas.Count; ++i) {
                m_SubCanvas[i].enabled = true;
            }

            Start();            
        }

        void IPoolable.OnRecycle()
        {
            OnRecycle();
            this.enabled = false;
            
            this.Attach(transform.parent.parent, false);
        }
    }
}
