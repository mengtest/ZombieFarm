using UnityEngine;
using UnityEngine.Assertions;
using System.Collections;
using System.Collections.Generic;
using IUnitTarget = World.IObj;

namespace FX
{
    [DisallowMultipleComponent]
    public abstract class FxInst : FxObj, IFxCtrl, IPoolable
    {
        protected static bool s_Paused = false;

        private static readonly List<FxInst> _ActiveFxes = new List<FxInst>();

#if UNITY_EDITOR
        private static int MaxFxCount;
#endif

        public static void Init()
        {
            s_Paused = false;
        }

        public static void Release()
        {
            _ActiveFxes.Clear();
#if UNITY_EDITOR
            MaxFxCount = 0;
#endif
        }

        public static void PauseAll()
        {
            FMODUnity.FMODMgr.SetBusPause(FMODUnity.FMODMgr.BUS_SFX, true);

            for (int i = 0; i < _ActiveFxes.Count; ++i) {
                _ActiveFxes[i].OnPauseGame();
            }
            s_Paused = true;
        }

        public static void ResumeAll()
        {
            FMODUnity.FMODMgr.SetBusPause(FMODUnity.FMODMgr.BUS_SFX, false);

            for (int i = 0; i < _ActiveFxes.Count; ++i) {
                _ActiveFxes[i].OnResumeGame();
            }
            s_Paused = false;
        }

        public static List<IFxCtrl> FindFxesOn(IUnitTarget holder)
        {
            var list = FxTool.GetPool();
            for (int i = _ActiveFxes.Count - 1; i >= 0; --i) {
                var fx = _ActiveFxes[i];
                if (fx) {
                    if (holder == null || (fx.holder != null && fx.holder.id == holder.id)) {
                        list.Add(_ActiveFxes[i]);
                    }
                } else {
                    _ActiveFxes.RemoveAt(i);
                }
            }
            return list;
        }

        public static bool HasFx(IUnitTarget holder, IFxCtrl fxCtrl)
        {
            var ret = false;
            if (holder != null) {
                var list = FindFxesOn(holder);
                for (int i = 0; i < list.Count; ++i) {
                    if (fxCtrl.prefab == list[i].prefab) {
                        ret = true;
                        break;
                    }
                }

                FxTool.ReleasePool(list);
            }

            return ret;
        }

        public static bool HasLoopFx(IUnitTarget holder, string fxName)
        {
            var ret = false;
            var list = FindFxesOn(holder);
            for (int i = 0; i < list.Count; ++i) {
                var fx = list[i];
                if (fx.autoDespwan == 0 && string.CompareOrdinal(fxName, fx.fxName) == 0) {
                    ret = true;
                    break;
                }
            }
            FxTool.ReleasePool(list);

            return ret;
        }

        public static void StopAll()
        {
            if (_ActiveFxes.Count > 0) {
                var list = FindFxesOn(null);
                foreach (var fx in list) fx.Stop(true);
                FxTool.ReleasePool(list);
            }
        }

        public static void Stop(IUnitTarget holder, bool instantly)
        {
            var list = FindFxesOn(holder);
            foreach (var fx in list) fx.Stop(instantly);
            FxTool.ReleasePool(list);
        }

        public static void Stop(IUnitTarget holder, string fxName, bool instantly)
        {
            var list = FindFxesOn(holder);
            foreach (var fx in list) {
                if (string.CompareOrdinal(fxName, fx.fxName) == 0) {
                    fx.Stop(instantly);
                }
            }
            FxTool.ReleasePool(list);
        }

        public static void SetVisible(IUnitTarget holder, bool visible)
        {
            for (int i = 0; i < _ActiveFxes.Count; ++i) {
                var fx = _ActiveFxes[i];
                if (fx.IsFollow && fx.holder == holder) {
                    fx.SetVisible(visible);
                }
            }
        }

        [Description("特效名称")]
        public string fxName { get; set; }

        [Description("存在")]
        protected float time;

        [Description("所属")]
        protected IUnitTarget m_Caster;
        public virtual IUnitTarget caster { get { return m_Caster; } set { m_Caster = value; } }

        [Description("命中")]
        protected IUnitTarget m_Holder;
        public virtual IUnitTarget holder { get { return m_Holder; } set { m_Holder = value; } }

        public override IFxCtrl fxCtrl { get { return this; } }

        [SerializeField, NamedProperty("允许多个")]
        private bool m_Multiple = true;
        public bool multiple { get { return m_Multiple; } }

        [SerializeField]
        protected int m_Level;
        public int level { get { return m_Level; } }

        public bool ignoreTimeScale;
        public bool ignoreGamePause;

        public virtual bool IsPooled { get { return true; } set { } }
        public virtual bool IsFading { get { return true; } }
        public abstract bool IsFollow { get; }        
        public abstract float autoDespwan { get; }

        private GameObject m_Prefab;
        public GameObject prefab { get { return m_Prefab != null ? m_Prefab : gameObject; } }
        public virtual GameObject go { get { return gameObject; } }
        public virtual Vector3 position {
            get { return transform.position; }
            set { transform.position = value; }
        }

        public IFxCtrl Instantiate(GameObject parent, string fullName)
        {
            var go = FxTool.AddChildPooled(null, prefab);
            go.SetActive(true);
            go.name = fullName;
            var fx  = (FxInst)go.GetComponent(typeof(FxInst));
            fx.m_Prefab = prefab;
            return fx;
        }

        public bool IsNull() { return this == null; }

        protected bool IsUpdate()
        {
            return ignoreGamePause || (ignoreTimeScale && !s_Paused);
        }
        
        protected virtual void Awake()
        {

        }

        protected virtual void Start()
        {

        }

        protected virtual void Update()
        {
            float curr = time;
            time += deltaTime;
            ChkAutoDespwan(curr);
        }

        protected virtual void OnEnable()
        {
            Assert.IsFalse(_ActiveFxes.Contains(this));
            _ActiveFxes.Add(this);
#if UNITY_EDITOR
            var count = _ActiveFxes.Count;
            if (MaxFxCount < count) {
                MaxFxCount = count;
                LogMgr.D("最大激活特效数量：{0}", MaxFxCount);
            }
#endif
        }

        protected virtual void OnDisable()
        {
            _ActiveFxes.Remove(this);
        }

        protected virtual void OnRecycle()
        {
            time = 0;
            holder = null;
            caster = null;
            SetVisible(true);
        }

        protected bool ChkAutoDespwan(float curr)
        {
            // 若配置了自动销毁，存在时间经过销毁时间时，自动销毁（非立即）
            if (curr < autoDespwan && time >= autoDespwan) {
                Stop(false);
                return true;
            }

            // 非自动销毁的特效。如果其持有者死亡，或者持有者的表现为空，则需要立即销毁
            if (autoDespwan == 0 && holder != null && (holder.IsNull() || !holder.IsAlive())) {
                Stop(true);
                return true;
            }

            return false;
        }

        protected virtual void OnDestroy()
        {
            //OnRecycle();
        }

        public virtual IFxCtrl Get(int i, object holder) { return i == 0 ? this : null; }

        public float deltaTime {
            get {
                return IsUpdate() ? Time.unscaledDeltaTime : Time.deltaTime;
            }
        }

        public virtual void Reset() { }

        public virtual void OnPauseGame()
        {

        }

        public virtual void OnResumeGame()
        {
           
        }

#if UNITY_EDITOR
        [ContextMenu("停止")]
        public void StopAtEditor()
        {
            Stop(false);
        }
#endif
        public virtual void SetVisible(bool visible) { }

        void IViewable.ShowView(float fadeTime)
        {
            SetVisible(true);
        }

        void IViewable.HideView(float fadeTime)
        {
            SetVisible(false);
        }
        
        void IPoolable.OnRestart()
        {
            if (!IsPooled) gameObject.SetActive(true);
            enabled = true;
            Start();
        }

        void IPoolable.OnRecycle()
        {
            OnRecycle();
            enabled = false;
            cachedTransform.SetParent(FxTool.FxRoot);

            if (!IsPooled) gameObject.SetActive(false);
        }

        public virtual float Stop(bool instanly)
        {
            ObjectPoolManager.DestroyPooledScenely(gameObject);
            return 0;
        }

        public virtual void OnInitDone()
        {
            var list = ZFrame.ListPool<Component>.Get();
            gameObject.GetComponents(typeof(IFxEvent), list);
            foreach (IFxEvent evt in list) evt.OnFxInit();
            ZFrame.ListPool<Component>.Release(list);
        }


        public override string ToString()
        {
            return string.Format("[FX:{0}; Caster={1}; Holder={2}]", this.name, caster, holder);
        }

#if UNITY_EDITOR
        public virtual string FxChecking()
        {
            return null;
        }
#endif
    }
}
