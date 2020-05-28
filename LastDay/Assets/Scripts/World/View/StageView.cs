//
//  StageView.cs
//  survive
//
//  Created by xingweizhen on 10/13/2017.
//
//

using System.Collections;
using System.Collections.Generic;
using System.Diagnostics;
using Vectrosity;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Assertions;
using ZFrame;
using ZFrame.Tween;
using UnityEngine.AI;
using MEC;
using Unity.LiveTune;
using ZFrame.UGUI;

namespace World.View
{
    using Control;

    public sealed class StageView : MonoSingleton<StageView>, FX.IFxEnv
    {
        public static Stage L { get { return StageCtrl.L; } }
        public static bool Enabled { get { return Instance && Instance.isActiveAndEnabled; } }

        [Description("关卡模版")]
        private StageEdit m_Edit;
        public static StageEdit M { get { return Instance ? Instance.m_Edit : null; } }

        private StageFOWData m_FowData;
        public static StageFOWData fowData { get { return Instance ? Instance.m_FowData : null; } }

        private Canvas m_Canvas;
        private CanvasGroup m_CanvasGrp;
        public bool IsUIVisible()
        {
            return m_Canvas.enabled && m_CanvasGrp.alpha > 0;
        }

        private readonly List<IObj> m_DelayedObjs = new List<IObj>();
        public void DelayedJoin(IObj obj)
        {
            m_DelayedObjs.Add(obj);
        }
        public Vector3 origin { get; private set; }

        public Camera mainCam { get; private set; }
        /// <summary>
        /// 原始摄像机位置
        /// </summary>
        public Vector3 camperaPos { get; private set; }
        /// <summary>
        /// 原始摄像机旋转
        /// </summary>
        public Vector3 cameraRot { get; private set; }
        public Transform camCenter { get; private set; }

        private LightProbeUsage m_LightProbeUsage;
        public static LightProbeUsage lightProbeUsage {
            get {
                return Instance ? Instance.m_LightProbeUsage : LightProbeUsage.Off;
            }
        }
        public static bool unlit {
            get {
                return !Instance || Instance.m_LightProbeUsage != LightProbeUsage.Off;
            }
        }

        [SerializeField, NamedProperty("可视半径")]
        private float m_VisibleRange = 15f;
        public float visibleRange { get { return m_VisibleRange; } }

        [SerializeField, NamedProperty("战争迷雾扩展")]
        private int m_FogOfWarExtend = 5;
        public int fogOfWarExtend { get { return m_FogOfWarExtend; } }

        private bool m_bIsInDelayExit = false;

        #region DataBase
        private CurveLib m_CurveL;
        public static CurveLib curveL {
            get {
                if (!Instance) return null;
                if (Instance.m_CurveL == null) {
                    Instance.m_CurveL = AssetsMgr.A.Load(typeof(CurveLib), "Game/CurveLib") as CurveLib;
                }
                return Instance.m_CurveL;
            }
        }

        private AssetCacher m_Assets;

        public static AssetCacher Assets {
            get {
                if (!Instance) return null;
                return Instance.m_Assets ?? (Instance.m_Assets = new AssetCacher());
            }
        }

        private readonly Pool<TmpData> m_TmpDataPool = new Pool<TmpData>(TmpData.Reset, TmpData.Reset);
        private readonly Dictionary<int, TmpData> m_CachedTmpDatas = new Dictionary<int, TmpData>();
        public TmpData GetTmpData(IObj obj, bool cached)
        {
            TmpData tmp;
            if (!m_CachedTmpDatas.TryGetValue(obj.id, out tmp)) {
                tmp = m_TmpDataPool.Get();
                tmp.Obj = obj;
                if (cached) m_CachedTmpDatas.Add(obj.id, tmp);
            }
            return tmp;
        }
        public void SetTmpData(TmpData data)
        {
            data.SetData();
            m_TmpDataPool.Release(data);
        }
        private void SetCacheData(IObj obj)
        {
            TmpData tmpData;
            if (m_CachedTmpDatas.TryGetValue(obj.id, out tmpData)) {
                SetTmpData(tmpData);
                m_CachedTmpDatas.Remove(obj.id);
            }
        }

        #region LiveTune
        private Coroutine m_LiveTuneSnapshotCoroutine = null;

        private void OnEnable()
        {
            if (string.IsNullOrEmpty(WNDLoading.loadedLevelName)) return;

            m_LiveTuneSnapshotCoroutine = StartCoroutine(LiveTuneSnapshotCoroutine());
        }

        private void OnDisable()
        {
            if (m_LiveTuneSnapshotCoroutine != null)
                StopCoroutine(m_LiveTuneSnapshotCoroutine);
        }

        private IEnumerator LiveTuneSnapshotCoroutine()
        {
            var wait = new WaitForSeconds(10);
            yield return wait;

            LiveTune.StartTimedSnapshot(WNDLoading.loadedLevelName, 10);
            var frame = Time.frameCount;
            var time = Time.realtimeSinceStartup;
            yield return wait;

            var framePass = Time.frameCount - frame;
            var timePass = Time.realtimeSinceStartup - time;
            var avgFps = framePass / timePass;
            StageCtrl.SendLuaEvent("SAMPLE_FPS", avgFps);            
        }
        #endregion

        private readonly Dictionary<int, HurtData> m_HurtDatas = new Dictionary<int, HurtData>();
        public HurtData GetHurtData(int id)
        {
            HurtData hurtData = null;
            if (id > 0 && !m_HurtDatas.TryGetValue(id, out hurtData)) {
                var lua = LuaComponent.lua;
                StageCtrl.LoadLuaData("load_hurt", id);
                if (lua.IsTable(-1)) {
                    hurtData = new HurtData(id) {
                        sfx = lua.GetString(-1, "sfx"),
                        force = lua.GetNumber(-1, "force") / 10f
                    };

                    lua.GetField(-1, "Fx");
                    lua.PushNil();
                    while (lua.Next(-2)) {
                        var fx = lua.ToString(-1);
                        hurtData.Fxes.Add(fx);
                        lua.Pop(1);
                    }
                    lua.Pop(1);

                    m_HurtDatas.Add(id, hurtData);
                }
                lua.Pop(1);
            }
            return hurtData;
        }
        #endregion

        #region Util API
        public Vector3 Pos2World(IObj pos)
        {
            return Local2World(pos.coord);
        }

        public Vector3 Fwd2World(IObj pos)
        {
            var entity = pos as IEntity;
            if (entity != null)
                return FwdLocal2World(entity.forward);
            return Vector3.forward;
        }

        public static Vector3 Local2World(Vector local)
        {
            var pos = Instance.cachedTransform.TransformPoint(local) + Instance.origin;
            pos.y += 0.01f;
            return pos;
        }

        public static Vector World2Local(Vector3 world)
        {
            var pos = Instance.cachedTransform.InverseTransformPoint(world - Instance.origin);
            pos.y = 0;
            return pos;
        }

        public static Vector3 FwdLocal2World(Vector forward)
        {
            return Instance.cachedTransform.TransformDirection(forward);
        }

        public static Vector3 FwdWorld2Local(Vector3 forward)
        {
            return Instance.cachedTransform.InverseTransformDirection(forward);
        }

        #endregion

        #region 事件通知

        private ObjView GetObjView(IObj obj)
        {
            var view = obj.view as ObjView;
            if (view && view.obj == obj) return view;
            return null;
        }

        private EntityView GetUnitView(IObj obj)
        {
            return obj.view as EntityView;
        }

        private void OnHealthChanged(IObj obj, VarChange Inf)
        {
            var view = GetUnitView(obj);
            if (view != null) view.OnHealthChanged(Inf);

            StageCtrl.SendLuaEvent("HEALTH_CHANGED", obj.id, JsonVarChange.Get(Inf));
        }

        private void OnDuraChanged(IObj obj, DuraChange Inf)
        {
            var view = GetUnitView(obj);
            if (view != null) view.OnDuraChanged(Inf);

            StageCtrl.SendLuaEvent("DURA_CHANGED", obj.id, JsonDuraChange.Get(Inf));
        }

        private void OnFSMTransition(IObj obj, IEventParam param)
        {
            var view = GetUnitView(obj);
            if (view != null) view.OnFSMTransition(param);

            if (obj.id == StageCtrl.P.id) {
                var trans = param as FSMTransition;
                StageCtrl.SendLuaEvent("FSM_STATE_TRANS", obj.id,
                    ((FSM_STATE)trans.src.id).ToString(),
                    ((FSM_STATE)trans.dst.id).ToString());
            }
        }

        private void OnSwapWeapon(IObj obj, IEventParam param)
        {
            var view = GetUnitView(obj);
            if (view != null) view.OnSwapWeapon(param);

            StageCtrl.SendLuaEvent("SWAP_WEAPON", obj.id, JsonSwapWeapon.Get(obj));
        }

        private void OnObjMoving(IObj obj, IEventParam param)
        {
            UnityEngine.Profiling.Profiler.BeginSample("Moving");
            var view = GetUnitView(obj);
            if (view != null) view.OnObjMoving(param);
            UnityEngine.Profiling.Profiler.EndSample();
        }

        private void OnObjTurning(IObj obj, IEventParam param)
        {
            UnityEngine.Profiling.Profiler.BeginSample("Turning");
            var view = GetUnitView(obj);
            if (view != null) view.OnObjTurning(param);
            UnityEngine.Profiling.Profiler.EndSample();
        }

        private void OnTargetUpdate(IObj obj, IObj target)
        {
            var view = GetUnitView(obj);
            if (view != null) view.OnTargetUpdate(target);
        }

        private void OnActionReady(IObj obj, IEventParam param)
        {
            var view = GetUnitView(obj);
            if (view != null) view.OnActionReady(param);
        }

        private void OnActionStart(IObj obj, IEventParam param)
        {
            var view = GetUnitView(obj);
            if (view != null) {
                view.OnActionStart(param);
            }
        }

        private void OnActionSuccess(IObj obj, IEventParam param)
        {
            var view = GetUnitView(obj);
            if (view != null) view.OnActionSuccess(param);
        }

        private void OnActionFinish(IObj obj, IEventParam param)
        {
            var view = GetUnitView(obj);
            if (view != null) view.OnActionFinish(param);

            SetCacheData(obj);
        }

        private void OnActionBreak(IObj obj, IEventParam param)
        {
            var view = GetUnitView(obj);
            if (view != null) view.OnActionBreak(param);

            SetCacheData(obj);
        }

        private void OnActionStop(IObj obj, IEventParam param)
        {
            var view = GetUnitView(obj);
            if (view != null) view.OnActionStop(param);
        }

        private void OnHitTarget(IObj obj, IEventParam param)
        {
            var view = GetUnitView(obj);
            if (view != null) view.OnHitTarget(param);
        }

        private void OnBeingHit(IObj obj, IEventParam param)
        {
            var view = GetUnitView(obj);
            if (view != null) view.OnBeingHit(param);
        }

        private void OnEffecting(IObj obj, IEventParam param)
        {
            var view = GetUnitView(obj);
            if (view != null) view.OnEffecting(param);
        }

        private void OnFireMissile(IObj obj, IEventParam param)
        {
            var view = GetUnitView(obj);
            if (view != null) view.OnFireMissile(param);
        }

        private void OnAttrChanged(IObj obj, IEventParam param)
        {
            var view = GetUnitView(obj);
            if (view != null) view.OnAttrChanged(param);
        }

        private void OnObjDead(IObj obj)
        {
            var view = GetUnitView(obj);
            if (view != null) {
                view.OnObjDead();

                // 玩家死亡时，尸体和本体可能会临时共享一个View，
                // 本体死亡后要把View留给尸体使用，
                // 此处取消了本地的View引用
                if (!Equals(obj, view.obj)) {
                    obj.view = null;
                }
            }

            if (obj.id != 0) {
                StageCtrl.SendLuaEvent("OBJ_DEAD", obj.id);
            }

            for (int i = 0; i < m_DelayedObjs.Count; ++i) {
                var NewObj = m_DelayedObjs[i];
                if (NewObj.id == obj.id) {
                    L.Join(NewObj);
                    if (obj.view != null) {
                        obj.view.Subscribe(NewObj);
                    }
                    m_DelayedObjs.RemoveAt(i);
                    break;
                }
            }
        }

        private void OnObjLeave(IObj obj)
        {
            MiniMap.Instance.Exit(obj, true);

            var view = GetUnitView(obj);
            if (view) view.OnObjLeave();
        }

        private void OnShiftRateChange(IObj obj, float value)
        {
            var view = GetUnitView(obj);
            if (view != null) view.OnShiftRateChange(value);

            StageCtrl.SendLuaEvent("SHIFT_RATE_CHANGE", obj.id, value);
        }

        private void OnOperChange(IObj obj, int limit, int value)
        {
            var view = GetUnitView(obj);
            if (view != null) view.OnOperChange(limit, value);
        }

        private void OnCampChange(IObj obj, int value)
        {
            var view = GetUnitView(obj);
            if (view != null) view.OnCampChange(value);
        }

        private void OnStatusChange(IObj obj, int value)
        {
            var view = GetObjView(obj);
            if (view != null) view.OnStatusChange(value);

            var reedObj = obj as ReedObj;
            if (reedObj != null) {
                if (value == 1) {
                    m_Edit.LoadReedView(L, reedObj, -origin);
                    MiniMap.Instance.Enter(reedObj);
                } else {
                    m_Edit.UnloadReedView(L, reedObj);
                    MiniMap.Instance.Exit(reedObj);
                }
            }
        }

        private void OnGridChange(IObj obj, Vector last)
        {
            var view = GetUnitView(obj);
            if (view != null) view.OnGridChange(last);
        }

        #endregion

        [SerializeField]
        private Transform m_PlateRoot;

        public Transform PlateRoot {
            get { return m_PlateRoot; }
        }

        [SerializeField]
        private Transform m_HudRoot;

        public Transform HudRoot {
            get { return m_HudRoot; }
        }

        private void UpdateObjViewVisible(IGridBasedObj o)
        {
            var obj = (IObj)o;
            obj.Dist = StageCtrl.Instance.sortCenter.DistanceTo(obj);
            TestViewVisible(obj);
        }

        private void UpdateViewVisible()
        {
            for (int i = 0; i < StageCtrl.Instance.SortedObjs.Count; ++i) {
                TestViewVisible(StageCtrl.Instance.SortedObjs[i]);
            }

            if (IsUIVisible()) {
                StageCtrl.Instance.sortCenter = StageCtrl.P.coord;
            } else {
                RaycastHit hit;
                if (mainCam.ViewportRaycast(new Vector3(0.5f, 0.5f, 0), 100f, LAYERS.Ground, out hit)) {
                    StageCtrl.Instance.sortCenter = World2Local(hit.point);
                }
            }
        }

        public void TestViewVisible(IObj obj)
        {
            if (!StageCtrl.hideObjOnOutScreen) return;

            var showDist = m_VisibleRange - 1;
            var hideDist = m_VisibleRange;

            var view = obj.view as EntityView;
            if (view == null) return;

            var distance = obj.Dist;
            if (!view.IsCombineView()) {
                if (distance < showDist) {
                    if (view.control == null && !view.loading) {
                        Creator.LoadObjView(view, view.model);
                        var role = obj as Role;
                        if (role == null || !role.IsAlive()) {
                            MiniMap.Instance.Enter(obj);
                        }
                    }
                } else if (distance > hideDist) {
                    if (view.control != null && !view.alwaysView) {
                        view.loading = false;
                        UnityEngine.Profiling.Profiler.BeginSample("UnloadView");
                        view.UnloadView();
                        UnityEngine.Profiling.Profiler.EndSample();
                        MiniMap.Instance.Exit(obj);
                    }
                }
            } else {
                if (distance < showDist) {
                    view.enabled = true;
                } else if (distance > hideDist) {
                    view.enabled = false;
                }
            }
        }

        protected override void Awaking()
        {
            base.Awaking();

            ObjectPoolManager.NewScenePool();

            m_NavMesh = new NavMeshData();
            m_NavMeshInst = NavMesh.AddNavMeshData(m_NavMesh);

            var wnd = UIWindow.FindByName("FRMExplore");
            m_Canvas = wnd.GetComponent(typeof(Canvas)) as Canvas;
            m_CanvasGrp = wnd.GetComponent(typeof(CanvasGroup)) as CanvasGroup;

            var lib = FindObjectOfType(typeof(ZFrame.Asset.ObjectLibrary)) as ZFrame.Asset.ObjectLibrary;
            if (lib != null) {
                using (var itor = lib.ObjectsOfType<Renderer>()) {
                    while (itor.MoveNext()) {
                        var rdr = itor.Current;
                        if (rdr != null && rdr.sharedMaterial && rdr.sharedMaterial.shader.name.Contains(MaterialSet.OUTLINE)) {
                            rdr.sharedMaterial = Assets.GetMaterialSet(rdr.sharedMaterial).GetNorm();
                        }
                    }
                }
            }

            mainCam = Camera.main;
            //mainCam.depthTextureMode |= DepthTextureMode.Depth;
            camperaPos = mainCam.transform.localPosition;
            cameraRot = mainCam.transform.localEulerAngles;

            camCenter = mainCam.transform.parent;

            // 描边需要在初始化完成后才能调用
            // Assets.SetOutline(GameSettings.Instance.stroke);
        }

        private void Launch()
        {
            Timing.RunCoroutine(CoroStart());
        }

        // Use this for initialization
        private IEnumerator<float> CoroStart()
        {
            L.onFSMTransition += OnFSMTransition;
            L.onSwapWeapon += OnSwapWeapon;
            L.onObjMoving += OnObjMoving;
            L.onObjTurning += OnObjTurning;
            L.onTargetUpdate += OnTargetUpdate;
            L.onActionReady += OnActionReady;
            L.onActionStart += OnActionStart;
            L.onActionSuccess += OnActionSuccess;
            L.onActionFinish += OnActionFinish;
            L.onActionBreak += OnActionBreak;
            L.onActionStop += OnActionStop;
            L.onHitTarget += OnHitTarget;
            L.onBeingHit += OnBeingHit;
            L.onEffecting += OnEffecting;
            L.onFireMissile += OnFireMissile;
            L.onAttrChanged += OnAttrChanged;
            L.onObjDead += OnObjDead;
            L.onObjLeave += OnObjLeave;
            L.onShiftRateChange += OnShiftRateChange;
            L.onOperChange += OnOperChange;
            L.onCampChange += OnCampChange;
            L.onStatusChange += OnStatusChange;
            L.onGridChange += OnGridChange;
            L.onHealthChanged += OnHealthChanged;
            L.onDuraChanged += OnDuraChanged;
            L.onPositionChange += StageCtrl.Instance.Objs.NotifyPosChanged;

            StageCtrl.Instance.onLogicWillUpdate += UpdateViewVisible;

            StageCtrl.Instance.Objs.OnObjComeIn += UpdateObjViewVisible;
            StageCtrl.Instance.Objs.OnObjGoOut += UpdateObjViewVisible;

            FX.FxTool.ENV = this;
            FX.FxTool.FxRoot = cachedTransform.Find("FXROOT");

            var mainLight = GameObject.FindGameObjectWithTag(TAGS.MainLight);
            var probes = LightmapSettings.lightProbes;
            if (mainLight == null && probes != null && probes.count > 0) {
                m_LightProbeUsage = LightProbeUsage.BlendProbes;
                Assets.SetPointlit(false);
            } else {
                m_LightProbeUsage = LightProbeUsage.Off;
                Assets.SetPointlit(true);
            }

            origin = new Vector3(0.5f, 0, 0.5f);

            var objs = FindObjectsOfType(typeof(StageEdit));
            m_Edit = null;
            foreach (StageEdit o in objs) {
                if (o.templateId == 0) continue;
                if (o.start) {
                    m_Edit = o;
                    if (o.templateId == StageCtrl.mapTmpl) break;
                }
            }
            foreach (StageEdit o in objs) {
                if (o.templateId == 0) continue;
                o.gameObject.SetActive(m_Edit == o);
            }

            if (m_Edit != null) {
                cachedTransform.position = m_Edit.start.position;
                cachedTransform.rotation = m_Edit.start.rotation;
                m_Edit.Init(L);
                m_Edit.GenNavMeshBuildSources(m_Sources);
                if (L.localMode) {
                    Map.size = m_Edit.size;
                } else if (Map.size != (Vector)m_Edit.size) {
                    LogMgr.E("地图大小不一致！本地={0}；远端={1}", (Vector)m_Edit.size, Map.size);
                }

                while (!m_Edit.inited) yield return Timing.WaitForOneFrame;
                MiniMap.Instance.InitMap(m_Edit);
            }

            VectorLine.SetCamera3D(mainCam);

#if UNITY_EDITOR || UNITY_STANDALONE
            gameObject.AddComponent(typeof(Debugger));
            gameObject.AddComponent(typeof(KeyboardInput));
#endif

#if UNITY_EDITOR
            var ssv = mainCam.gameObject.AddComponent(typeof(SyncSceneView)) as SyncSceneView;
            ssv.target = camCenter;
            ssv.enabled = m_SyncSceneView;

            UIManager.Instance.RegDrawGUI(DrawGUI);
#endif

            m_NavMeshDirty = false;
            var async = RebuildNavMesh(true);

            while (!async.isDone) yield return Timing.WaitForOneFrame;

            LogMgr.D("NavMesh Build Done");
            StageCtrl.SendLuaEvent("INIT_SELF", QualityAdjuster.GetQuality());
            while (StageCtrl.P.view == null) yield return Timing.WaitForOneFrame;

            // 场景初始化
            StageCtrl.SendLuaEvent("INIT_STAGE", Map.size);

            if (StageCtrl.Instance.roofFinding != null) {
                StageCtrl.Instance.roofFinding.Update();
            }

            // 启动战争迷雾
            m_FowData = (StageFOWData)mainCam.GetComponent(typeof(StageFOWData));
            m_FowData.Init(Map.size);
            L.onBlockChanged += m_FowData.BlockChanged;

            var fowEff = FogOfWarEffect.Instance;
            if (fowEff) {
                fowEff.ReInit(Map.size, Local2World(Map.size / 2) - origin, 2, fogOfWarExtend);
                MiniMap.Instance.SetMask(fowEff.fogTex);

                fowEff.enabled = StageCtrl.enableFOW && StageCtrl.showFogOfWar;
            }
        }

        // Update is called once per frame
        private void Update()
        {
            if (m_NavMeshDirty) {
                m_NavMeshDirty = false;
                RebuildNavMesh(true);
            }

#if UNITY_EDITOR || UNITY_STANDALONE

            PlateRoot.rotation = mainCam.transform.rotation;
            HudRoot.rotation = mainCam.transform.rotation;

            if (Input.GetKey(KeyCode.LeftShift)) {
                if (Input.GetKeyDown(KeyCode.Z)) {
                    var plateCv = (Canvas)PlateRoot.GetComponent(typeof(Canvas));
                    plateCv.enabled = !plateCv.enabled;

                    var hudCv = (Canvas)HudRoot.GetComponent(typeof(Canvas));
                    hudCv.enabled = !hudCv.enabled;

                    var lua = LuaScriptMgr.Instance.L;
                    lua.GetGlobal("PKG", "framework/console/console", "parse_cmd");
                    var b = lua.BeginPCall();
                    lua.PushString(string.Format("ui capturemode {0}", plateCv.enabled ? "off" : "on"));
                    lua.ExecPCall(1, 0, b);
                }
            }
#endif
        }

        protected override void Destroying()
        {
            if (StageCtrl.Instance) {
                StageCtrl.Instance.onLogicWillUpdate -= UpdateViewVisible;
                StageCtrl.Instance.Objs.OnObjComeIn -= UpdateObjViewVisible;
                StageCtrl.Instance.Objs.OnObjGoOut -= UpdateObjViewVisible;
            }

            if (MiniMap.Instance) {
                MiniMap.Instance.Clear();
            }

            FX.FxInst.Release();
            if (this.Equals(FX.FxTool.ENV)) {
                FX.FxTool.ENV = null;
                FX.FxTool.FxRoot = null;
            }

            m_NavMeshInst.Remove();

            if (m_Assets != null) m_Assets.Clear();

#if UNITY_EDITOR
            if (UIManager.Instance)
                UIManager.Instance.UnregDrawGUI(DrawGUI);
#endif
        }

        public void ResetCamera(float duration)
        {
            if (mainCam) {
                mainCam.transform.SetParent(camCenter, true);
                mainCam.transform.TweenLocalPosition(camperaPos, duration);
                mainCam.transform.TweenLocalRotation(cameraRot, duration);
            }
        }

        public void DelayLeave(bool isLeave)
        {
            if (m_bIsInDelayExit != isLeave) {
                m_bIsInDelayExit = isLeave;
                StageCtrl.SendLuaEvent("LEAVING_STAGE", isLeave);
            }
        }

        #region 寻路网格
        private Bounds QuantizedBounds()
        {
            var offset = new Vector(1f, 0, 1f);
            var size = Map.size + new Vector(2f, 0, 2f);
            var center = Local2World((Map.size - offset) / 2);
            size.y = 20f;
            return new Bounds(center, size);
        }

        private bool m_NavMeshDirty;
        private readonly List<NavMeshBuildSource> m_Sources = new List<NavMeshBuildSource>();
        private List<NavMeshBuildSource> m_AllSources = new List<NavMeshBuildSource>();
        private NavMeshData m_NavMesh;
        private NavMeshDataInstance m_NavMeshInst;
        private AsyncOperation RebuildNavMesh(bool asyncUpdate)
        {
            NavMeshBuildTag.Collect(ref m_AllSources);
            m_AllSources.AddRange(m_Sources);
            var defaultBuildSettings = NavMesh.GetSettingsByID(0);
            defaultBuildSettings.overrideVoxelSize = true;
            defaultBuildSettings.voxelSize = 0.1f;
            defaultBuildSettings.overrideTileSize = true;
            defaultBuildSettings.tileSize = 64;
            var bounds = QuantizedBounds();
            LogMgr.D("RebuildNavMesh Tags={0}", m_AllSources.Count);

            NavMeshBuilder.Cancel(m_NavMesh);
            if (asyncUpdate) {
                return NavMeshBuilder.UpdateNavMeshDataAsync(m_NavMesh, defaultBuildSettings, m_AllSources, bounds);
            }

            NavMeshBuilder.UpdateNavMeshData(m_NavMesh, defaultBuildSettings, m_AllSources, bounds);
            return null;
        }

        private IEnumerator UpdatingNavMesh()
        {
            while (true) {
                yield return RebuildNavMesh(true);
            }
        }

        public bool IsNewNavMeshBuild(IObjView view)
        {
            foreach (var source in m_Sources) {
                if (view.Equals(source.component)) return false;
            }

            return true;
        }

        public void AddNavMeshBuild(IObjView view, NavMeshBuildSource source)
        {
            source.component = view as Component;
            m_Sources.Add(source);
            m_NavMeshDirty = true;
        }

        public void RemoveNavMeshBuild(IObjView view)
        {
            for (var i = 0; i < m_Sources.Count; i++) {
                var source = m_Sources[i];
                if (view.Equals(source.component)) {
                    m_Sources.RemoveAt(i);
                    m_NavMeshDirty = true;
                }
            }
        }

        public void SetNavMeshDirty(Object o)
        {
            IUnitView view = null;
            var go = o as GameObject;
            if (go != null) {
                view = go.GetComponent(typeof(IUnitView)) as IUnitView;
            } else {
                view = o as IUnitView;
            }

            if (view != null) {
                RemoveNavMeshBuild(view);
                view.SetNavMeshBuild();
            }
        }

        #endregion

#if UNITY_EDITOR
        private bool m_SyncSceneView;
        private void DrawGUI()
        {
            var syncSceneView = GUILayout.Toggle(m_SyncSceneView, "同步SceneView");
            if (syncSceneView != m_SyncSceneView) {
                m_SyncSceneView = syncSceneView;
                Camera.main.SetEnable(typeof(SyncSceneView), m_SyncSceneView);
            }
        }
        private void OnDrawGizmosSelected()
        {
            if (!Application.isPlaying) return;

            if (L == null) return;

            if (m_NavMesh) {
                Gizmos.color = Color.green;
                Gizmos.DrawWireCube(m_NavMesh.sourceBounds.center, m_NavMesh.sourceBounds.size);
            }

            Gizmos.color = Color.yellow;
            var bounds = QuantizedBounds();
            Gizmos.DrawWireCube(bounds.center, bounds.size);
        }
#endif
    }
}
