using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Assertions;
using Object = UnityEngine.Object;
#if ULUA
using LuaInterface;
#else
using XLua;
#endif

namespace World.Control
{
    using View;
    public class StageCtrl : MonoSingleton<StageCtrl>
    {
        private bool m_Debug;
        public static bool debug {
            get { return Instance && Instance.m_Debug; }
            set { if (Instance) Instance.m_Debug = value; }
        }

        private bool m_UnitGuideLine;
        public static bool unitGuideLine {
            get { return Instance && Instance.m_UnitGuideLine; }
            set { if (Instance) Instance.m_UnitGuideLine = value; }
        }

        private bool m_DayNight = true;
        public static bool DayNight {
            get { return !Instance || Instance.m_DayNight; }
            set { if (Instance) Instance.m_DayNight = value; }
        }

        private bool m_HideObjOnOutScreen = true;
        public static bool hideObjOnOutScreen {
            get { return !Instance || Instance.m_HideObjOnOutScreen; }
            set { if (Instance) Instance.m_HideObjOnOutScreen = value; }
        }

        private bool m_ShowFogOfWar = true;
        public static bool showFogOfWar {
            get { return !Instance || Instance.m_ShowFogOfWar; }
            set {
                if (Instance) {
                    Instance.m_ShowFogOfWar = value;
                    var enabled = value && enableFOW;
                    if (MiniMap.Instance) {
                        MiniMap.Instance.EnableMask(enabled);
                    }
                    if (FogOfWarEffect.Instance) {
                        FogOfWarEffect.Instance.enabled = enabled;
                    }
                }
            }
        }

        private bool m_EnableFOW = true;
        public static bool enableFOW {
            get { return !Instance || Instance.m_EnableFOW; }
            set {
                if (Instance) Instance.m_EnableFOW = value;
            }
        }

#if UNITY_EDITOR
        [Description("客户端视野")]
        private float editorClientVision { get { return clientVision; } }
#endif

        public static float clientVision {
            get {
                if (Instance && DayNightView.Instance && P != null) {
                    var visionReplace = P.GetAttr(ATTR.visionReplace);
                    if (visionReplace > 0) return visionReplace;

                    var baseVision = DayNightView.Instance.vision;
                    return baseVision + P.GetAttr(ATTR.visionAdd);
                }

                return 0f;
            }
        }

        [SerializeField]
        private L_Settings m_Settings = new L_Settings();
        public static L_Settings Settings { get { return Instance ? Instance.m_Settings : null; } }

        private Stage m_Stage;
        public static Stage L { get { return Instance ? Instance.m_Stage : null; } }

        private Player m_Player;
        public static Player P { get { return Instance ? Instance.m_Player : null; } }

        private StageSync m_Sync;
        public static StageSync S { get { return Instance ? Instance.m_Sync : null; } }

        private IObj m_Focus;
        public static IObj rawFocus { get { return Instance ? Instance.m_Focus : null; } }
        public static IObj focus {
            get { return ObjectExt.IsNull(Instance.m_Focus) ? null : Instance.m_Focus; }
            set { Instance.m_Focus = value; }
        }

        private int m_MapTmpl;
        public static int mapTmpl { get { return Instance.m_MapTmpl; } }

        public ClosedAreaFinding roofFinding { get; private set; }

        public event System.Action onLogicWillUpdate, onLogicHasUpdated, onLogicEnd;

        public List<IObj> SortedObjs { get; private set; }

        public Vector sortCenter;
        public GridBasedSceneManager Objs;

        private System.Comparison<IObj> m_ObjSortFunc;
        private System.Action<IObj> m_ObjJoin, m_ObjLeave;
        private const int VisiableRange = 15;
        private const int GridSize = 5;
        private const int MaxMapSize = 100;

        /// <summary>
        /// 关卡环境管理
        /// </summary>
        //public readonly StageEnvMgr envMgr = new StageEnvMgr();
        public StageEnv currEnv = new StageEnv();


        protected override void Awaking()
        {
            DontDestroyOnLoad(gameObject);

            base.Awaking();

            SimpleBuff.SetLib(new ConfigLib<SimpleBuff>(100, L_Buff.Creator));
            CFG_Action.SetLib(new ConfigLib<IAction>(100, L_Action.Creator));

            if (CFG_Weapon.Loader == null) {
                CFG_Weapon.Loader = L_Weapon.Loader;
            }

            if (CFG_SubSk.Creator == null) {
                CFG_SubSk.Creator = L_SubSk.Creator;
            }

            m_Sync = gameObject.GetComponent(typeof(StageSync)) as StageSync;
            SortedObjs = new List<IObj>();
            Objs = new GridBasedSceneManager(MaxMapSize, MaxMapSize, GridSize);
            m_ObjSortFunc = (a, b) => {
                float fret = 0;
                if (a.Dist < 0 && b.Dist < 0) {
                    fret = b.Dist - a.Dist;
                } else {
                    fret = a.Dist - b.Dist;
                }

                int ret = Mathf.RoundToInt(fret * CVar.LENGTH_MUL);
                if (ret == 0) {
                    // 距离相等，判定交互类型
                    IEntity enta = a as IEntity, entb = b as IEntity;
                    if (enta != null && entb != null) { ret = enta.operId - entb.operId; }

                    return ret == 0 ? a.id - b.id : ret;
                }

                return ret;
            };
            // m_ObjJoin = o => SortedObjs.Add(o);
            // m_ObjLeave = o => SortedObjs.Remove(o);
            m_ObjJoin = o => Objs.Add(o);
            m_ObjLeave = o => Objs.Remove(o);

            var lua = LuaComponent.lua;
            lua.GetGlobal(LuaComponent.PKG, LibGame.CTRL);
            m_Tb = lua.ToLuaTable(-1);
            lua.Pop(1);
        }

        public void Launch()
        {
            m_Stage = new Stage();
            m_Stage.onObjBorn += m_ObjJoin;
            m_Stage.onObjLeave += m_ObjLeave;

            m_Sync.Begin();

            var lua = m_Tb.CallFunc(1, "load_stage");
            // --{Stage
            m_Stage.uniqueId = lua.GetValue(I2V.ToLong, -1, "id");
            if (lua.GetBoolean(-1, "home")) {
                // roofFinding = new ClosedAreaFinding(lua.ToLuaTable(-1));
            }
            Map.size = new Vector(lua.GetNumber(-1, "w"), lua.GetNumber(-1, "h"));
            
            // --{Stage - Base
            lua.GetField(-1, "Base");
            m_MapTmpl = (int)lua.GetNumber(-1, "res");
            DayNightView.DayTIME = (int)lua.GetNumber(-1, "day");
            DayNightView.NightTIME = (int)lua.GetNumber(-1, "night");
            enableFOW = lua.GetBoolean(-1, "fow");
            lua.Pop(1);
            // --}

            lua.Pop(1);
            // --}

            // 读取常量
            lua.GetGlobal("CVar", "BATTLE");
            m_Stage.G.SKILL_ID_BURN_REED = (int)lua.GetNumber(-1, "BurnGrassSkillID");
            m_Stage.G.PET_SMELLING_ALERT_FREQ = (int)lua.GetNumber(-1, "PetSmellingAlertFrequency") / 1000;
            lua.Pop(1);
        }

        public void Stop()
        {
            SortedObjs.Clear();
            Objs.Clear();
            m_Sync.End();
            m_Stage = null;
            m_Player = null;
            m_Focus = null;
            onLogicWillUpdate = null;
            onLogicHasUpdated = null;
            if (onLogicEnd != null) {
                onLogicEnd.Invoke();
                onLogicEnd = null;
            }

            if (roofFinding != null) {
                roofFinding.Uninit();
                roofFinding = null;
            }

            //envMgr.Clear();

            if (StageView.Instance) {
                // 必须置为不可用，以免下一个地图申请时错误创建可视单位
                StageView.Instance.enabled = false;
            }

            currEnv.fx = null;
        }

        public bool JoinObj(IObj newObj)
        {
            var obj = L.FindById(newObj.id);

            var player = newObj as Player;
            if (player != null) {
                Assert.IsFalse(ObjectExt.IsAlive(m_Player));
                player.autoTargetFilter = Settings.targetFilter;
                player.autoTargetAmount = Settings.focus_showNearby;
                m_Player = player;
                Objs.CenterObj = m_Player;
                Objs.VisibleRange = VisiableRange;
            }

            if (StageView.Enabled) {
                if (ObjectExt.IsNull(obj) || !obj.IsAlive()) {
                    L.Join(newObj);

                    if (obj == null || obj.view == null || obj.view.IsNull()) {
                        SendLuaEvent("OBJ_CREATE", newObj.id);
                        Debugger.LogI("新单位加入：{0}", newObj);
                        return true;
                    }

                    obj.view.Subscribe(newObj);                    
                    Debugger.LogI("单位转化：{0}->{1}", obj, newObj);
                } else {
                    // 存在相同id的单位，等待其单位死亡后再加入
                    StageView.Instance.DelayedJoin(newObj);
                    Debugger.LogI("单位延迟加入：{0}", newObj);
                }
            } else {
                L.Join(newObj);
                Debugger.LogI("新单位创建：{0}", newObj);
            }

            return false;
        }

        public void DeleteObj(int id, float delay)
        {
            delay = Mathf.Max(0.01f, delay);
            LogMgr.D("DeleteObj #{0} IN {1}s", id, delay);

            var Obj = L.FindById(id, true);
            if (Obj != null) {
                Obj.Destroy();
                var view = Obj.view as EntityView;
                if (view) {
                    view.recycleDelay = delay;
                    if (!Obj.IsAlive()) {
                        view.Destruct(ObjCtrl.FADING_DURA);
                    }
                }
            }
        }

        private void FixedUpdate()
        {
            if (m_Stage == null) return;

            UnityEngine.Profiling.Profiler.BeginSample("onLogicWillUpdate");
            if (onLogicWillUpdate != null) {
                onLogicWillUpdate.Invoke();
            }
            UnityEngine.Profiling.Profiler.EndSample();


            UnityEngine.Profiling.Profiler.BeginSample("UpdateLogic");
            L.UpdateLogic();
            UnityEngine.Profiling.Profiler.EndSample();

            UnityEngine.Profiling.Profiler.BeginSample("StageSync");
            S.Sync();
            UnityEngine.Profiling.Profiler.EndSample();

            UnityEngine.Profiling.Profiler.BeginSample("Sort Objs");
            UnityEngine.Profiling.Profiler.BeginSample("Sort Objs 1");

            // for (var i = 0; i < SortedObjs.Count; ++i) {
            //     var obj = SortedObjs[i];
            //     obj.Dist = sortCenter.DistanceTo(obj);
            // }
            //
            // SortedObjs.Sort(m_ObjSortFunc);

            SortedObjs.Clear();

            UnityEngine.Profiling.Profiler.EndSample();
            UnityEngine.Profiling.Profiler.BeginSample("Sort Objs 2");
            Objs.GetObjInside(sortCenter.x, sortCenter.z, VisiableRange, SortedObjs);
            Objs.ViewedPosition = sortCenter;
            UnityEngine.Profiling.Profiler.EndSample();
            UnityEngine.Profiling.Profiler.BeginSample("Sort Objs 3");
            foreach (IObj obj in SortedObjs) {
                obj.Dist = sortCenter.DistanceTo(obj);
                if (Mathf.Approximately(obj.Dist, 0)) {
                    obj.Dist = -Vector3.Distance(sortCenter, obj.coord);
                }
            }

            UnityEngine.Profiling.Profiler.EndSample();
            UnityEngine.Profiling.Profiler.BeginSample("Sort Objs 4");
            SortedObjs.Sort(m_ObjSortFunc);

            UnityEngine.Profiling.Profiler.EndSample();
            UnityEngine.Profiling.Profiler.EndSample();

            UnityEngine.Profiling.Profiler.BeginSample("onLogicHasUpdated");
            if (onLogicHasUpdated != null) {
                onLogicHasUpdated.Invoke();
            }

            UnityEngine.Profiling.Profiler.EndSample();
        }

        public void GetObjOutViewRange(Func<IObj, bool> func)
        {
            Objs.GetObjOutside(m_Player, VisiableRange, func);
        }

        public static int Timestamp2Frame(long timestamp)
        {
            if (timestamp > 0) {
                timestamp -= StageSync.timestamp;
                return L.frameIndex + (int)(timestamp / 1000f * CVar.FRAME_RATE);
            } else {
                return (int)timestamp;
            }
        }

#region Lua接口

        private LuaTable m_Tb;
        public static LuaTable LT { get { return Instance.m_Tb; } }

        public const string LUA_FUNC = "handle";

        public static System.IntPtr LoadLuaData(string loadName, int id)
        {
            var lua = LT.PushField(loadName);
            if (lua.IsFunction(-1)) {
                int errFunc = lua.BeginPCall();
                lua.PushInteger(id);
                lua.ExecPCall(1, 1, errFunc);
            } else lua.Pop(1);

            return lua;
        }

        public static void SendLuaEvent(string eventName)
        {
            var lua = LT.PushField(LUA_FUNC);
            if (lua.IsFunction(-1)) {
                int errFunc = lua.BeginPCall();
                lua.PushString(eventName);
                lua.ExecPCall(1, 0, errFunc);
            } else lua.Pop(1);
        }

        public static void SendLuaEvent(string eventName, float arg0)
        {
            var lua = LT.PushField(LUA_FUNC);
            if (lua.IsFunction(-1)) {
                int errFunc = lua.BeginPCall();
                lua.PushString(eventName);
                lua.PushNumber(arg0);
                lua.ExecPCall(2, 0, errFunc);
            } else lua.Pop(1);
        }

        public static void SendLuaEvent(string eventName, bool arg0)
        {
            var lua = LT.PushField(LUA_FUNC);
            if (lua.IsFunction(-1)) {
                int errFunc = lua.BeginPCall();
                lua.PushString(eventName);
                lua.PushBoolean(arg0);
                lua.ExecPCall(2, 0, errFunc);
            } else lua.Pop(1);
        }

        public static void SendLuaEvent(string eventName, Vector2 arg0)
        {
            var lua = LT.PushField(LUA_FUNC);
            if (lua.IsFunction(-1)) {
                int errFunc = lua.BeginPCall();
                lua.PushString(eventName);
                lua.PushX(arg0);
                lua.ExecPCall(2, 0, errFunc);
            } else lua.Pop(1);
        }

        public static void SendLuaEvent(string eventName, float arg0, float arg1)
        {
            var lua = LT.PushField(LUA_FUNC);
            if (lua.IsFunction(-1)) {
                int errFunc = lua.BeginPCall();
                lua.PushString(eventName);
                lua.PushNumber(arg0);
                lua.PushNumber(arg1);
                lua.ExecPCall(3, 0, errFunc);
            } else lua.Pop(1);
        }

        public static void SendLuaEvent(string eventName, float arg0, TinyJSON.Variant arg1)
        {
            var lua = LT.PushField(LUA_FUNC);
            if (lua.IsFunction(-1)) {
                int errFunc = lua.BeginPCall();
                lua.PushString(eventName);
                lua.PushNumber(arg0);
                lua.PushX(arg1);
                lua.ExecPCall(3, 0, errFunc);
            } else lua.Pop(1);
        }

        public static void SendLuaEvent(string eventName, float arg0, Object arg1)
        {
            var lua = LT.PushField(LUA_FUNC);
            if (lua.IsFunction(-1)) {
                int errFunc = lua.BeginPCall();
                lua.PushString(eventName);
                lua.PushNumber(arg0);
                lua.PushLightUserData(arg1);
                lua.ExecPCall(3, 0, errFunc);
            } else lua.Pop(1);
        }

        public static void SendLuaEvent(string eventName, float arg0, float arg1, float arg2)
        {
            var lua = LT.PushField(LUA_FUNC);
            if (lua.IsFunction(-1)) {
                int errFunc = lua.BeginPCall();
                lua.PushString(eventName);
                lua.PushNumber(arg0);
                lua.PushNumber(arg1);
                lua.PushNumber(arg2);
                lua.ExecPCall(4, 0, errFunc);
            } else lua.Pop(1);
        }

        public static void SendLuaEvent(string eventName, float arg0, string arg1, string arg2)
        {
            var lua = LT.PushField(LUA_FUNC);
            if (lua.IsFunction(-1)) {
                int errFunc = lua.BeginPCall();
                lua.PushString(eventName);
                lua.PushNumber(arg0);
                lua.PushString(arg1);
                lua.PushString(arg2);
                lua.ExecPCall(4, 0, errFunc);
            }
        }

        public static void SendLuaEvent(string eventName, float arg0, float arg1, float arg2, float arg3)
        {
            var lua = LT.PushField(LUA_FUNC);
            if (lua.IsFunction(-1)) {
                int errFunc = lua.BeginPCall();
                lua.PushString(eventName);
                lua.PushNumber(arg0);
                lua.PushNumber(arg1);
                lua.PushNumber(arg2);
                lua.PushNumber(arg3);
                lua.ExecPCall(5, 0, errFunc);
            } else lua.Pop(1);
        }

        #endregion


        #region 空间分割

        private class Grid : IGrid
        {
            private HashSet<IGridBasedObj> _objs = new HashSet<IGridBasedObj>();

            public Grid(int x, int y)
            {
                X = x;
                Y = y;
            }

            public void GetObjInGrid<T>(List<T> result) where T : IGridBasedObj
            {
                foreach (var obj in _objs) { result.Add((T)obj); }
            }

            public bool GetObjInGrid<T>(Func<T, bool> func) where T : IGridBasedObj
            {
                foreach (var obj in _objs) {
                    if (!func((T)obj)) return false;
                }

                return true;
            }

            public int X { get; private set; }
            public int Y { get; private set; }

            public bool Add(IGridBasedObj obj)
            {
                obj.Grid = this;
                return _objs.Add(obj);
            }

            public bool Remove(IGridBasedObj obj)
            {
                obj.Grid = null;
                return _objs.Remove(obj);
            }

            public void Clear() { _objs.Clear(); }
        }

        public class GridBasedSceneManager
        {
            private Grid[] _grids;
            private int _cellSize;
            private int _column;
            private int _row;
            private int _count;

            private Vector2 _viewPosition;

            public Vector2 ViewedPosition {
                get { return _viewPosition; }
                set {

                    if (_viewPosition == value) return;

                    var newx = Mathf.FloorToInt(value.x / _cellSize);
                    var newy = Mathf.FloorToInt(value.y / _cellSize);

                    var oldx = Mathf.FloorToInt(_viewPosition.x / _cellSize);
                    var oldy = Mathf.FloorToInt(_viewPosition.y / _cellSize);

                    _viewPosition = value;
                    
                    if (newx != oldx || newy != oldy) {
                        NotifyViewPosChanged(newx, newy, oldx, oldy, VisibleRange);
                    }
                }
            }

            public Action<IGridBasedObj> OnObjComeIn;
            public Action<IGridBasedObj> OnObjGoOut;

            public GridBasedSceneManager(int width, int height, int cellSize)
            {
                _cellSize = cellSize;
                _column = Mathf.CeilToInt((float)width / cellSize);
                _row = Mathf.CeilToInt((float)height / cellSize);
                _grids = new Grid[_column * _row];
                for (int i = 0; i < _column; i++) {
                    for (int j = 0; j < _row; j++) { _grids[i * _row + j] = new Grid(i, j); }
                }
            }
            
            public IGridBasedObj CenterObj { get; set; }
            public int VisibleRange { get; set; }

            public void Add(IGridBasedObj obj)
            {
                if(obj == null)
                    return;
                
                var x = Mathf.FloorToInt(obj.pos.x / _cellSize);
                var y = Mathf.FloorToInt(obj.pos.z / _cellSize);
                
                if (x < 0 || x >= _column || y < 0 || y >= _row) return;
                
                _grids[x * _row + y].Add(obj);
                _count++;

                if (CenterObj != null && CenterObj.Grid != null && Visible(x, y, CenterObj.Grid, VisibleRange)) {
                    if (OnObjComeIn != null) OnObjComeIn(obj);
                }
            }

            
            /// <summary>
            /// Search in a area, func return false will stop the search.
            /// </summary>
            /// <param name="obj">area around this obj</param>
            /// <param name="dist">search area</param>
            /// <param name="func">return true means contine search, false means stop</param>
            /// <typeparam name="T"></typeparam>
            public void GetObjOutside<T>(IGridBasedObj obj, float dist, Func<T, bool> func) where T : IGridBasedObj
            {
                if(obj == null || obj.Grid == null || func == null)
                    return;
                
                var maxR = Mathf.CeilToInt(dist / _cellSize);
                var r = maxR;
                var x = Mathf.FloorToInt(obj.pos.x / _cellSize);
                var y = Mathf.FloorToInt(obj.pos.z / _cellSize);
                var grid = obj.Grid;

                var range = Mathf.Max(_column, _row);

                while (r < range) {
                    x++;
                    y++;
                    var t = r * 2;
                    for (int dir = 0; dir < 4; dir++) {
                        for (int i = 0; i < t; i++) {
                            if (x >= 0 && x < _column && y >= 0 && y < _row) {
                                grid = _grids[x * _row + y];
                                if (!grid.GetObjInGrid(func)) return;
                            }

                            switch (dir) {
                                case 0:
                                    y--;
                                    break;
                                case 1:
                                    x--;
                                    break;
                                case 2:
                                    y++;
                                    break;
                                case 3:
                                    x++;
                                    break;
                            }
                        }
                    }

                    r++;
                }
            }

            private void GetObjInside<T>(IGrid grid, float dist, List<T> result) where T : IGridBasedObj
            {
                if(grid == null)
                    return;
                
                var maxR = Mathf.CeilToInt(dist / _cellSize);
                var r = 1;
                var x = grid.X;
                var y = grid.Y;

                grid.GetObjInGrid(result);

                while (r < maxR) {
                    x++;
                    y++;
                    var t = r * 2;
                    for (int dir = 0; dir < 4; dir++) {
                        for (int i = 0; i < t; i++) {
                            if (x >= 0 && x < _column && y >= 0 && y < _row) {
                                grid = _grids[x * _row + y];
                                grid.GetObjInGrid(result);
                            }

                            switch (dir) {
                                case 0:
                                    y--;
                                    break;
                                case 1:
                                    x--;
                                    break;
                                case 2:
                                    y++;
                                    break;
                                case 3:
                                    x++;
                                    break;
                            }
                        }
                    }

                    r++;
                }
            }
            
            public void GetObjInside<T>(float x, float y, float dist, List<T> result) where T : IGridBasedObj
            {
                if (result == null) return;
                
                var ix = Mathf.FloorToInt(x / _cellSize);
                var iy = Mathf.FloorToInt(y / _cellSize);
                
                if (ix >= 0 && ix < _column && iy >= 0 && iy < _row) {
                    var grid = _grids[ix * _row + iy];
                    GetObjInside(grid, dist, result);
                }
            }

            public void GetObjInside<T>(IGridBasedObj obj, float dist, List<T> result) where T : IGridBasedObj
            {
                if (obj == null || result == null) return;
                GetObjInside(obj.Grid, dist, result);
            }

            public void Remove(IGridBasedObj obj)
            {
                if (obj == null || obj.Grid == null) return;
                
                obj.Grid.Remove(obj);
                obj.Grid = null;
                _count--;

                var x = Mathf.FloorToInt(obj.pos.x / _cellSize);
                var y = Mathf.FloorToInt(obj.pos.z / _cellSize);

                if (CenterObj != null && CenterObj.Grid != null && Visible(x, y, CenterObj.Grid, VisibleRange)) {
                    if (OnObjGoOut != null) OnObjGoOut(obj);
                }
            }

            public void Clear()
            {
                for (int i = 0; i < _column; i++) {
                    for (int j = 0; j < _row; j++) { _grids[i * _row + j].Clear(); }
                }

                _count = 0;
            }

            private bool Visible(int x, int y, IGrid g, int r)
            {
                return Mathf.Max(Mathf.Abs(x - g.X), Mathf.Abs(y - g.Y)) <= r;
            }

            public void NotifyPosChanged(IGridBasedObj obj)
            {
                if (obj == null || obj.Grid == null) return;

                var x = Mathf.FloorToInt(obj.pos.x / _cellSize);
                var y = Mathf.FloorToInt(obj.pos.z / _cellSize);

                if (x < 0 || x >= _column || y < 0 || y >= _row) return;

                if (x != obj.Grid.X || y != obj.Grid.Y) {
                    obj.Grid.Remove(obj);
                    obj.Grid = _grids[x * _row + y];
                    obj.Grid.Add(obj);
                }
            }

            private List<IGridBasedObj> _innerBuffer = new List<IGridBasedObj>();

            private void NotifyViewPosChanged(int newx, int newy, int oldx, int oldy, float dist)
            {
                if (newx != oldx || newy != oldy) {
                    var t = Mathf.CeilToInt(dist / _cellSize);
                    var maxx = Mathf.Min(Mathf.Max(oldx, newx) + t, _column - 1);
                    var maxy = Mathf.Min(Mathf.Max(oldy, newy) + t, _row - 1);

                    var minx = Mathf.Max(Mathf.Min(oldx, newx) - t, 0);
                    var miny = Mathf.Max(Mathf.Min(oldy, newy) - t, 0);

                    for (int i = minx; i <= maxx; ++i) {
                        for (int j = miny; j <= maxy; ++j) {
                            var grid = _grids[i * _row + j];
                            var oldv = Visible(oldx, oldy, grid, t);
                            var newv = Visible(newx, newy, grid, t);
                            if (newv && !oldv && OnObjComeIn != null) {
                                _innerBuffer.Clear();
                                grid.GetObjInGrid(_innerBuffer);
                                foreach (var o in _innerBuffer) { OnObjComeIn(o); }
                            } else if (!newv && oldv && OnObjGoOut != null) {
                                _innerBuffer.Clear();
                                grid.GetObjInGrid(_innerBuffer);
                                foreach (var o in _innerBuffer) { OnObjGoOut(o); }
                            }
                        }
                    }
                }
            }
        }

        #endregion
    }
}