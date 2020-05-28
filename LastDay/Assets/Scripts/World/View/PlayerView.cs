//
//  PlayerView.cs
//  survive
//
//  Created by xingweizhen on 10/13/2017.
//
//

using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;
using UnityEngine.Assertions;
using FMODUnity;
using UnityEngine.Profiling;
using Vectrosity;

namespace World.View
{
    using Control;

    public class PlayerView : HumanView
    {
        [SerializeField, NamedProperty("交互半径")]
        private float m_FocusRadius = 2f;

        [SerializeField, NamedProperty("同步间隔")]
        private float m_SyncInterval = 0.5f;
        private float m_SyncRemain;

        #region 摄像机跟随参数
        private Transform m_Center { get { return StageView.Instance.camCenter; } }
        private Vector3 m_Velocity;
        private const float _SMOOTH_TIME = 0.1f;
        #endregion

        private Vector m_LastPos, m_NextPos;
        private Vector m_LastFwd, m_MoveFwd;
        private float m_LastSpeed;
        
        public enum AutoRet
        {
            Success = 0, Cancel, NoRes, NoTool, NoPath, NoSlot,
        }
        public bool autoMode { get; private set; }
        public void SetAuto(bool auto, AutoRet ret = AutoRet.Success, int operId = 0)
        {
            if (autoMode != auto) {
                autoMode = auto;
                if (!auto) {
                    var human = (Human)obj;
                    if (human.Content.prefab != null) {
                        human.Content.Uninit();
                    }
                    human.StopMoving();
                    StageCtrl.SendLuaEvent("EXIT_AUTO", (int)ret, operId);
                }
            }
        }

        public override void SetAction(ObjAnim ctrl, NWObjAction nwAction)
        {
            base.SetAction(ctrl, nwAction);

            var listen = cachedTransform.Find("LISTEN");
            var fwd = m_Center.Find("FWD");

            FMODMgr.Instance.SetListener(FMODMgr.MAIN_LISTENER, listen, fwd);
        }

        protected override void Start()
        {
            base.Start();
            m_Center.position = cachedTransform.position;
            m_LastPos = cachedTransform.position;
            m_SyncRemain = 0;
        }

        private void Awake()
        {
            if (StageCtrl.Instance) {
                StageCtrl.Instance.onLogicWillUpdate += OnLogicPrepare;
                StageCtrl.Instance.onLogicHasUpdated += OnLogicUpdate;
                StageCtrl.Instance.onLogicEnd += OnLogicEnd;
            }
        }

        private void OnDestroy()
        {
            if (StageCtrl.Instance) {
                StageCtrl.Instance.onLogicWillUpdate -= OnLogicPrepare;
                StageCtrl.Instance.onLogicHasUpdated -= OnLogicUpdate;
                StageCtrl.Instance.onLogicEnd -= OnLogicEnd;
            }
        }

        protected override void OnRecycle()
        {
            base.OnRecycle();

            RecycleAura(ref m_SelfAura);
            RecycleAura(ref m_TarAura);
            RecycleAura(ref m_FocusAura);
            VectorLine.Destroy(ref m_LockedLine);
        }

        private IObj m_AutoTarget;

        public IObj autoTarget {
            get { return m_AutoTarget; }
            private set {
                if (!Equals(m_AutoTarget, value)) {
                    m_AutoTarget = value;
                    StageCtrl.SendLuaEvent("TARGET_CHANGED", obj.id, value != null ? value.id : 0);
                }
            }
        }

        private IObj m_AlertTarget;
        private IObj m_LockedTarget;
        public IObj lockedTarget {
            get { return m_LockedTarget; }
            set {
                if (!Equals(m_LockedTarget, value)) {
                    m_LockedTarget = value;

                    RecycleAura(ref m_SelfAura);
                    RecycleAura(ref m_TarAura);

                    if (value != null) {
                        autoTarget = value;
                        StageCtrl.SendLuaEvent("TARGET_LOCKED", value.id);
                        CreateLockAura(value);
                    } else {
                        StageCtrl.SendLuaEvent("TARGET_LOCKED");
                        if (autoTarget != null) {
                            CreateTarAura(autoTarget);
                        }
                    }
                }
            }
        }

        private readonly List<IObj> m_NearbyAlerts = new List<IObj>();
        private Transform m_SelfAura, m_TarAura, m_FocusAura;
        private VectorLine m_LockedLine;

        private void CreateAuraPair(IObj target, string selfAura, string targetAura)
        {
            if (m_TarAura == null) {
                m_TarAura = ObjCtrl.CreateFootAura(targetAura);
            }
            ObjCtrl.InitFootAura(m_TarAura, target.GetRadius(),
                target.camp == StageCtrl.P.camp ? Color.green : Color.yellow);

            if (!string.IsNullOrEmpty(selfAura)) {
                if (m_SelfAura == null) {
                    m_SelfAura = ObjCtrl.CreateFootAura(selfAura);
                    m_SelfAura.Attach(transform, false);
                }
                ObjCtrl.InitFootAura(m_SelfAura, obj.GetRadius(), Color.yellow);
            }
            UpdateTarAura(target);
        }

        private void CreateTarAura(IObj target)
        {
            if (m_LockedLine != null) {
                m_LockedLine.active = false;
            }
            CreateAuraPair(target, null, "TarAura");            
        }

        private void HideTarAura()
        {
            RecycleAura(ref m_SelfAura);
            RecycleAura(ref m_TarAura);
            if (m_LockedLine != null) {
                m_LockedLine.active = false;
            }
        }

        private void CreateLockAura(IObj target)
        {
            if (m_LockedLine == null) {
                var mat = (Material)AssetsMgr.A.Load(typeof(Material), "Shared/FX/LockedLine");
                m_LockedLine = new VectorLine("LOCKED_LINE", new List<Vector3>(2), 3) {
                    material = mat, texture = mat.mainTexture, textureScale = 1,
                };
            } else {
                m_LockedLine.active = true;
            }

            CreateAuraPair(target, "SelfAura", "LockAura");
        }

        private void UpdateTarAura(IObj target)
        {
            var vol = target as IVolume;
            var view = target.view as MonoBehaviour;
            if (view && vol != null && Math.IsEqual(vol.size.x, vol.size.z)) {
                m_TarAura.position = view.transform.position;
            } else {
                m_TarAura.position = StageView.Local2World(target.coord);
            }

            //m_SelfAura.LookAt(m_TarAura);
            //m_TarAura.LookAt(m_SelfAura);
            if (m_LockedLine != null && m_LockedLine.active) {
                var forward = (m_TarAura.position - m_SelfAura.position).normalized;
                m_LockedLine.points3[0] = m_SelfAura.position + forward * obj.GetRadius();
                m_LockedLine.points3[1] = m_TarAura.position - forward * vol.CalcRadius();
                m_LockedLine.Draw3D();
            }
        }

        private void UpdateFocusAura(IObj target)
        {           
            var vol = target as IVolume;
            var view = target.view as MonoBehaviour;
            if (view && vol != null && Math.IsEqual(vol.size.x, vol.size.z)) {
                m_FocusAura.position = view.transform.position;
            } else {
                m_FocusAura.position = StageView.Local2World(target.coord);
            }
            if (vol != null) {
                m_FocusAura.forward = StageView.FwdLocal2World(vol.forward);
            }
        }

        private void RecycleAura(ref Transform auraTrans)
        {
            if (auraTrans) {
                GoTools.DestroyScenely(auraTrans.gameObject);
                auraTrans = null;
            }
        }

        private void CheckFocusTarget()
        {
            var rawFocus = StageCtrl.rawFocus;
            if (rawFocus != null && rawFocus.IsNull()) {
                StageCtrl.focus = null;
                StageCtrl.SendLuaEvent("FOCUS_CHANGED", obj.id, 0);

                RecycleAura(ref m_FocusAura);
            }
        }
        
        /// <summary>
        /// 更新可交互目标
        /// </summary>
        private void UpdateFocusTarget()
        {
            var player = (Player)obj;

            if (!autoMode && player.autoMove) return;
            if (!player.Content.idle) return;

            var area = new Shape2D(obj.coord, m_FocusRadius);

            IEntity newFocus = null;
            foreach (var o in StageCtrl.Instance.SortedObjs) {
                var ent = o as IEntity;
                if (obj.CanInteract(ent) && TargetAlg.IsTargetInRange(ent, ref area)) {
                    newFocus = ent;
                    break;
                }
            }

            var oldFocus = StageCtrl.rawFocus;
            if (!Equals(oldFocus, newFocus)) {
                StageCtrl.focus = newFocus;

                StageCtrl.SendLuaEvent("FOCUS_CHANGED", obj.id, 
                    newFocus != null ? newFocus.id : 0, oldFocus != null ? oldFocus.id : 0);

                if (newFocus != null) {
                    if (m_FocusAura == null) {
                        m_FocusAura = ObjCtrl.CreateFootAura("FocusAura");
                    }

                    var radius = newFocus.GetRadius();
                    ObjCtrl.InitFootAura(m_FocusAura, radius, Color.cyan);

                    UpdateFocusAura(newFocus);
                } else {
                    RecycleAura(ref m_FocusAura);
                }
            }
        }

        /// <summary>
        /// 距离最近的警戒目标
        /// </summary>
        private IObj UpdateNearestAlertTarget(List<IObj> ignoreList = null)
        {
            var player = (Player)obj;
            var area = new Shape2D(player.coord, StageCtrl.clientVision);

            var autoTargetAmount = Mathf.Max(0, player.autoTargetAmount - m_NearbyAlerts.Count);
            IObj alertTarget = null;
            foreach (var o in StageCtrl.Instance.SortedObjs) {
                if (!TargetAlg.IsTargetInRange(o, ref area)) break;                
                if (ignoreList != null && ignoreList.Contains(o)) continue;
                if (!obj.IsSet(o, TARSet.HARM) || !obj.CanAttack(o)) continue;

                var ent = o as IEntity;
                if (autoMode && ent != null && !ent.offensive) continue;

                if (alertTarget == null) alertTarget = o;
                if (alertTarget != null && o is Human) {
                    if (autoTargetAmount == 0) break;
                    if (!m_NearbyAlerts.Contains(o)) {
                        autoTargetAmount -= 1;
                        m_NearbyAlerts.Add(o);
                    }
                }
            }

            return alertTarget;
        }

        /// <summary>
        /// 血量最低的警戒目标
        /// </summary>
        private IObj UpdateThinnestAlertTarget(List<IObj> ignoreList = null)
        {
            var player = (Player)obj;
            var area = new Shape2D(player.coord, StageCtrl.clientVision);

            var autoTargetAmount = Mathf.Max(0, player.autoTargetAmount - m_NearbyAlerts.Count);
            IObj alertTarget = null;
            int hpMin = int.MaxValue;
            foreach (var o in StageCtrl.Instance.SortedObjs) {
                if (!TargetAlg.IsTargetInRange(o, ref area)) break;                
                if (ignoreList != null && ignoreList.Contains(o)) continue;
                if (!obj.IsSet(o, TARSet.HARM) || !obj.CanAttack(o)) continue;

                var ent = o as IEntity;
                if (autoMode && ent != null && !ent.offensive) continue;

                var living = o as ILiving;
                if (living == null) continue;

                var hp = living.Health.GetValue();
                if (hp < hpMin) {
                    hpMin = hp;
                    alertTarget = o;
                }
                
                if (autoTargetAmount > 0 && o is Human) {
                    if (!m_NearbyAlerts.Contains(o)) {
                        autoTargetAmount -= 1;
                        m_NearbyAlerts.Add(o);
                    }
                }
            }

            return alertTarget;
        }

        private void CheckNearbyAlerts()
        {
            if (m_NearbyAlerts.Count > 0) {
                var player = (Player)obj;
                var area = new Shape2D(player.coord, StageCtrl.clientVision);
                for (int i = m_NearbyAlerts.Count - 1; i >= 0; --i) {
                    var o = m_NearbyAlerts[i];
                    if (!TargetAlg.IsTargetInRange(o, ref area) ||
                        !obj.CanAttack(o)) {
                        m_NearbyAlerts.RemoveAt(i);
                    }
                }
            }
        }

        public IObj RelockNearbyAlerts(bool forceRelock = false)
        {
            IObj alertTarget = null;
            List<IObj> prevAlerts = null;
            var player = (Player)obj;

            if (forceRelock && player.autoTargetAmount > 0) {
                prevAlerts = TargetAlg.GetPool();
                prevAlerts.AddRange(m_NearbyAlerts);
                m_NearbyAlerts.Clear();
            }

            switch (player.autoTargetFilter) {
                case TARFilter.Thinnest:
                    alertTarget = UpdateThinnestAlertTarget(prevAlerts);
                    break;
                default:
                    alertTarget = UpdateNearestAlertTarget(prevAlerts);
                    break;
            }

            if (player.autoTargetAmount > 0) {
                if (prevAlerts != null) {
                    // 尝试更新掉所有目标
                    if (m_NearbyAlerts.Count > 0) {
                        if (m_NearbyAlerts.Count < player.autoTargetAmount) {
                            foreach (var o in prevAlerts) {
                                m_NearbyAlerts.Add(o);
                                if (m_NearbyAlerts.Count == player.autoTargetAmount) break;
                            }

                            SyncNearbyTargets();
                        }
                    } else {
                        // 没有变化，无需更新
                        m_NearbyAlerts.AddRange(prevAlerts);
                    }
                } else {
                    // 常规更新；只更新掉无效的目标
                    SyncNearbyTargets();
                }
            }

            if (prevAlerts != null) TargetAlg.ReleasePool(prevAlerts);

            return alertTarget;
        }

        private void SyncNearbyTargets()
        {
            // 更新周围目标
            var lua = StageCtrl.LT.PushField(StageCtrl.LUA_FUNC);
            var b = lua.BeginPCall();
            lua.PushString("UNITS_NEARBY");
            lua.CreateTable(m_NearbyAlerts.Count, 0);
            for (int i = 0; i < m_NearbyAlerts.Count; ++i) {
                lua.SetNumber(-1, i + 1, m_NearbyAlerts[i].id);
            }
            lua.ExecPCall(2, 0, b);
        }

        private void CheckAutoTarget()
        {
            if (autoTarget != null) {
                if (autoTarget.IsNull()) {
                    autoTarget = null;
                    HideTarAura();
                } else if (Equals(autoTarget, StageCtrl.focus)) {
                    //HideTarAura();
                }
            }
        }
        
        private void UpdateAutoTarget()
        {
            var player = (Player)obj;
            var prevTarget = autoTarget;
            // m_AutoTarget = null;

            var castTarget = StageCtrl.P.Content.currTarget;
            if (castTarget != null) {
                castTarget = ObjectExt.GetRefObj(castTarget);
                if (Equals(castTarget, StageCtrl.focus)) {
                    castTarget = null;
                }
            }
            if (Equals(castTarget, obj) || !obj.CanSelect(castTarget)) castTarget = null;

            // 施法中目标会清空当前已锁定目标
            if (castTarget != null && !Equals(castTarget, lockedTarget)) lockedTarget = null;
            
            // 在自动模式下需要寻找警戒目标：自动过程中优先攻击警戒目标
            // 动作目标为空时需要警戒目标作为自动目标
            if (autoMode || castTarget == null || player.autoTargetAmount > 0) {
                CheckNearbyAlerts();
                var alertTarget = RelockNearbyAlerts();
                    
                if (obj.CanSelect(lockedTarget) && obj.IsTargetInRange(lockedTarget, StageCtrl.clientVision)) {
                    m_AlertTarget = lockedTarget;
                } else {
                    lockedTarget = null;
                    m_AlertTarget = alertTarget;
                }
            }

            var currTarget = castTarget ?? m_AlertTarget;
            if (!Equals(prevTarget, currTarget)) {
                prevTarget = currTarget;
                
                if (prevTarget != null) {
                    CreateTarAura(prevTarget);
                } else {
                    HideTarAura();
                }
            }
            autoTarget = prevTarget;
        }

        /// <summary>
        /// 自动打怪
        /// </summary>
        private bool AutoAttackObj()
        {
            var human = obj as Human;
            if (human == null) return false;

            if (!human.Content.idle) {
                // 处理蓄力技能
                var action = human.Content.action;
                if (action.oper == ACTOper.Charged) {
                    var unique = Timer.GenCasting(action.id, human.id);
                    var tm = human.L.tmMgr.Find(unique);
                    if (tm != null && tm.beginning + action.cast < human.L.frameIndex) {
                        // 蓄力技能可以松手了
                        human.Attack(null, null);
                    }
                }

                return true;
            }

            // 自动打怪时使用武器的警戒范围
            var skill = (CFG_Skill)human.IGetAction(-1);
            if (human.CanAttack(m_AlertTarget)
                && human.IsTargetInRange(m_AlertTarget, skill.alertRange)
                && !human.Content.IsCooling(skill.id)) {
                Vector hitPos;
                if (entity.L.Raycast(entity.coord, m_AlertTarget, 0, out hitPos) == null) {
                    EquipTool(human.Major);
                    IAction action = human.IGetAction(-1);
                    human.Attack(action, m_AlertTarget, action.oper);
                }
            }

            var currAction = human.Content.prefab ?? human.Content.action;
            return currAction is CFG_Skill;
        }

        private HashSet<int> m_OperQue = new HashSet<int>();

        private static Lambda_SeekInteractObj s_SeekInteractObjFunc = new Lambda_SeekInteractObj();

        private AutoRet SeekInteractObj(out int operId)
        {
            operId = 0;
            m_OperQue.Clear();
            
            var human = (Human)obj;

            var lua = StageCtrl.LT.CallFunc(1, "load_alloper");
            lua.PushNil();
            while (lua.Next(-2)) {
                var oper = lua.ToInteger(-2);
                lua.Pop(1);
                m_OperQue.Add(oper);
            }
            lua.Pop(1);

            // 选择最近的一个可达目标
            AutoRet ret = AutoRet.Success;
            s_SeekInteractObjFunc.view = this;
            s_SeekInteractObjFunc.focus = null;
            s_SeekInteractObjFunc.hasPass1 = false;
            s_SeekInteractObjFunc.hasPass2 = false;
            s_SeekInteractObjFunc.hasPass3 = false;
            s_SeekInteractObjFunc.nearestEnt = null;
            s_SeekInteractObjFunc.ObjDats.Clear();
            s_SeekInteractObjFunc.operQue = m_OperQue;
            
            // 先尝试可见范围内的物件
            foreach (var o in StageCtrl.Instance.SortedObjs) {
                if (!s_SeekInteractObjFunc.Func(o)) break;
            }

            // 视野范围内找不到合适的物件，再搜索视野范围外
            if (!s_SeekInteractObjFunc.hasPass3) {
                StageCtrl.Instance.GetObjOutViewRange(o => s_SeekInteractObjFunc.Func(o));
            }

            if (s_SeekInteractObjFunc.hasPass1) {
                if (!s_SeekInteractObjFunc.hasPass2) ret = AutoRet.NoSlot;
                else if (!s_SeekInteractObjFunc.hasPass3) ret = AutoRet.NoPath;
            } else {
                if (s_SeekInteractObjFunc.nearestEnt != null) {
                    operId = s_SeekInteractObjFunc.nearestEnt.operId;
                    ret = AutoRet.NoTool;
                } else {
                    ret = AutoRet.NoRes;
                }
            }

            if (s_SeekInteractObjFunc.focus != null) {
                operId = ((IEntity)s_SeekInteractObjFunc.focus).operId;
                var toolId = 0;
                if (operId > CVar.PICK_ID) {
                    DataUtil.LuaLoadConfig("load_tool", operId);
                    toolId = lua.IsTable(-1) ? (int)lua.GetNumber(-1, "pos") : -1;
                    lua.Pop(1);
                }

                if (toolId < 0) {
                    return AutoRet.NoTool;
                }

                human.SetTool(toolId);
                human.Interact(human.Tool, operId, s_SeekInteractObjFunc.focus, ACTOper.Auto);
            } 
            
            return ret;
        }

        class Lambda_SeekInteractObj
        {
            public IEntity nearestEnt; 
            public bool hasPass1;
            public bool hasPass2;
            public IObj focus;
            public bool hasPass3;
            public HashSet<int> operQue;
            public HashSet<int> ObjDats = new HashSet<int>() ;
            public PlayerView view;
            
            public bool Func(IObj o)
            {
                var ent = o as IEntity;
                var goon = false;
                if (ent == null) return true;
                if (ent.operId == CVar.PICK_ID) {
                    // 可拾取
                    goon = true;
                } else if (ent.operId > CVar.INTERACT_ID) {
                    if (nearestEnt == null) nearestEnt = ent;
                    if (operQue.Contains(ent.operId)) {
                        // 支持的交互动作
                        goon = true;
                    }
                }

                if (!goon) return true;

                hasPass1 = true;
                var dat = o.dat;
                Assert.IsTrue(dat != 0);

                if (ObjDats.Contains(dat)) {
                    // 已排除的对象
                    return true;
                }

                if (!ObjDats.Contains(-dat)) {
                    // 未处理过的对象
                    ObjDats.Add(-dat);
                    if (!view.IsTargetStakable(o)) {
                        ObjDats.Add(dat);
                        return true;
                    }
                }

                hasPass2 = true;

                if (view.IsTargetReachable(o)) {
                    focus = o;
                    hasPass3 = true;
                    return false;
                }

                return true;
            }
        }

        /// <summary>
        /// 自动寻找可交互物品
        /// </summary>
        /// <returns></returns>
        private AutoRet AutoInteractObj(out int operId)
        {
            operId = 0;

            var human = obj as Human;
            if (human == null) return AutoRet.Cancel;
            
            // 当前动作的目标是否存在
            if (!human.Content.invalid && human.Content.currTarget == null) {
                human.Attack(null, null, ACTOper.OneShot);
            }

            // 过程中有怪，优先打怪
            if (AutoAttackObj()) return AutoRet.Success;

            // 查找当前可进行的交互
            if (human.Content.idle) {
                if (human.Content.invalid) {
                    // 离开动作状态，人物表现才正常
                    if (!human.OnEvent((int)EVENT.LEAVE_ACTION)) {
                        EquipTool(human.Major);
                    }
                    return SeekInteractObj(out operId);
                } else {
                    var focusTar = human.Content.target;
                    // 定时重新选择目标(兼容路径更新后，目标可能不可抵达的情况)
                    if (!ObjectExt.IsNull(focusTar) && focusTar.view != null 
                        && human.L.frameIndex % CVar.FRAME_RATE == 0 && !IsTargetReachable(focusTar)) {
                        human.Content.Cancel();
                        return SeekInteractObj(out operId);
                    }
                }
            }

            return AutoRet.Success;
        }

        private void OnLogicPrepare()
        {
            var role = obj as Role;
            if (role == null) return;

            // 同步移动表现
            if (agent && agent.hasPath) {
                var currentFwd = Vector.R((agent.steeringTarget - transform.position).normalized);
                if (currentFwd != m_MoveFwd) {
                    m_MoveFwd = currentFwd;
                    m_SyncRemain = 0f;
                }
            }

            if (m_SyncRemain >= 0) {
                m_SyncRemain -= Time.deltaTime;
                if (m_SyncRemain < 0) {
                    var syncInterval = m_SyncInterval;
                    StageCtrl.S.objAction.SetMoveData(role, role.shiftingRate, ref syncInterval);
                    m_SyncRemain = syncInterval;
                }
            }
        }

        private void OnLogicUpdate()
        {
            if (obj is Player && obj.IsAlive()) {
                if (StageView.Instance.IsUIVisible()) {
                    Profiler.BeginSample("[UpdateFocusTarget]");
                    UpdateFocusTarget();
                    Profiler.EndSample();
                    Profiler.BeginSample("[UpdateAutoTarget]");
                    UpdateAutoTarget();
                    Profiler.EndSample();
                } else {
                    CheckFocusTarget();
                    CheckAutoTarget();
                }

                if (autoMode) {
                    var actor = (CActor)entity;
                    if (actor.actionable) {
                        // 自动模式AI
                        int operId;
                        Profiler.BeginSample("AutoInteractObj");
                        var ret = AutoInteractObj(out operId);
                        Profiler.EndSample();
                        if (ret != AutoRet.Success) {
                            SetAuto(false, ret, operId);
                        }
                    } else {
                        // 无法行动
                        SetAuto(false, AutoRet.Cancel);
                    }
                }
            }
        }

        private void OnLogicEnd()
        {
            RecycleAura(ref m_TarAura);
            RecycleAura(ref m_SelfAura);
            RecycleAura(ref m_FocusAura);
            VectorLine.Destroy(ref m_LockedLine);
        }

        public override void Tick(float deltaTime)
        {
            var position = cachedTransform.position;
            position.y += 0.55f;
			Shader.SetGlobalVector("CenterPos", new Vector4(position.x, position.y, position.z, 2.92f));
            var screenPos = StageView.Instance.mainCam.WorldToScreenPoint(position);
            Shader.SetGlobalVector("PlayerScreenPos", new Vector4(screenPos.x, screenPos.y, screenPos.z, 0f));

            var role = obj as Role;
            if (role == null) return;
            
            var currPos = StageView.World2Local(position);
            role.WarpAt(currPos);

            //玩家是否跑到场外 && 玩家跑到场景内的退出点
            StageView.Instance.DelayLeave(!Map.IsInMap(role.coord) || IsInExit(role.coord));

            if (m_Center) {
                m_Center.position = Vector3.SmoothDamp(
                    m_Center.position, position, ref m_Velocity, _SMOOTH_TIME);
            }

            if (autoTarget != null && m_TarAura) {
                UpdateTarAura(autoTarget);
            }
            if (StageCtrl.focus != null && m_FocusAura) {
                UpdateFocusAura(StageCtrl.focus);
            }

            base.Tick(deltaTime);
        }

        private bool IsInExit(Vector playerCoord)
        {
            for (int i = 0; i < StageView.M.ExitAreaShape.Length; i++) {
                if (StageView.M.ExitAreaShape[i].Contains(playerCoord))
                    return true;
            }
            return false;
        }

        /// <summary>
        /// 目标是否可达
        /// </summary>
        public bool IsTargetReachable(IObj target)
        {
            var dest = StageView.Local2World(target.coord);
            return agent.IsReachable(dest, Mathf.Max(0.5f, target.GetRadius()));
        }

        /// <summary>
        /// 背包是否有空位装下目标的掉落
        /// </summary>
        /// <param name="target"></param>
        /// <returns></returns>
        public bool IsTargetStakable(IObj target)
        {
            var lua = StageCtrl.LT.CallFunc(1, "check_stakable", target.id);
            var ret = lua.ToBoolean(-1);
            lua.Pop(1);
            return ret;
        }

        public override void Subscribe(IObj o)
        {
            base.Subscribe(o);

            m_LastPos = entity.coord;
            m_NextPos = entity.coord;
            m_MoveFwd = entity.forward;
        }

        #region 事件通知
        public override void OnCampChange(int value) { }

        public override void OnObjMoving(IEventParam param)
        {
            base.OnObjMoving(param);

            var mover = obj as IMovable;
            if (mover == null) return;

            var lastSpeed = m_LastSpeed;
            m_LastSpeed = mover.GetMovingSpeed();            
            if (Mathf.Abs(lastSpeed - m_LastSpeed) >= CVar.MOVE_SPEED_DIFF) {
                m_SyncRemain = 0;
            }

            if (Math.IsEqual(lastSpeed, 0) ^ Math.IsEqual(m_LastSpeed, 0)) {
                m_SyncRemain = 0;
                // 速度发生一定变化，或者开始移动和停止移动时立即同步
                if (Math.IsEqual(1, mover.shiftingRate)) {
                    var roleCtrl = control as RoleAnim;
                    if (roleCtrl) roleCtrl.ResetIdle(this, 0.1f);
                }                
            }
        }

        public override void OnObjTurning(IEventParam param)
        {
            base.OnObjTurning(param);

            var mover = obj as IMovable;
            if (mover == null) return;
            
            var currSpeed = mover.GetMovingSpeed();
            if (Math.IsEqual(currSpeed, 0)) {
                if (Vector.Dot(m_LastFwd, entity.forward) < 0.9f) {
                    m_LastFwd = entity.forward;
                    m_SyncRemain = 0;
                }
            }
        }

        public override void OnTargetUpdate(IObj target)
        {
            base.OnTargetUpdate(target);

            var actor = entity as IActor;
            if (actor != null) {
                var content = actor.Content;
                var action = content.action ?? content.prefab;
                StageCtrl.S.objAction.SetLookTarget(entity, content.Weapon, action, target);
            }
        }

        public override void OnActionReady(IEventParam param)
        {
            base.OnActionReady(param);

            var action = (IAction)param;
            if (action.ready > 0) {
                // 同步准备动作
                var actor = entity as IActor;
                if (actor != null) {
                    var content = actor.Content;
                    var currTar = content.currTarget as IEntity;
                    StageCtrl.S.SyncActionStart(entity, content.Weapon, action, currTar, false);
                }
            }
        }

        public override void OnActionStart(IEventParam param)
        {
            base.OnActionStart(param);

            var human = entity as Human;
            if (human == null) return;
            
            var tm = (Timer)param;
            var action = (IAction)tm.param;
            var target = ObjectExt.GetRefObj(tm.whom);
            var content = human.Content;

            var skill = action as CFG_Skill;
            if (skill != null && content.Weapon == human.Major) {
                if (hud && skill.cost > 0 && human.Major.Ammo.IsEmpty()) {
                    // 弹药耗尽了
                    hud.Add("RELOAD", Color.red);
                }
            }

            var actMode = action.cast == 0 && action.oper != ACTOper.Charged;
            if (action.ready > 0 && actMode && content.nShot == 1) {
                if (target != null) {
                    CheckHitReedbed(target, content.Weapon, action);
                    StageCtrl.S.SyncActionSuccess(entity, content.Weapon, action.id, action.type, target);                    
                } else {
                    StageCtrl.S.SyncCancelCast(entity, action.id);
                }
            } else {
                if (actMode) CheckHitReedbed(target, content.Weapon, action);
                // 瞬发则进行攻击，否则是同步动作
                StageCtrl.S.SyncActionStart(entity, content.Weapon, action, target, actMode);
            }

            if (target != null) {
                StageCtrl.SendLuaEvent("ACTION_START", obj.id, action.id, action.cast, target.id);
            } else {
                StageCtrl.SendLuaEvent("ACTION_START", obj.id, action.id, action.cast);
            }
        }

        public override void OnActionBreak(IEventParam param)
        {
            base.OnActionBreak(param);

            if (anim && anim.GetBool(AnimParams.RELEASE)) return;

            var actor = obj as IActor;
            if (actor == null) return;
            
            var tm = (Timer)param;
            var action = (IAction)tm.param;
            var target = tm.whom;

            // 同步技能主动中断
            StageCtrl.S.SyncCancelCast(entity, action.id);

            var remain = tm.beginning + action.cast - actor.L.frameIndex;
            if (target != null) {
                StageCtrl.SendLuaEvent("ACTION_BREAK", obj.id, action.id, remain, target.id);
            } else {
                StageCtrl.SendLuaEvent("ACTION_BREAK", obj.id, action.id, remain);
            }
        }

        public override void OnActionSuccess(IEventParam param)
        {
            base.OnActionSuccess(param);

            var actor = obj as IActor;
            if (actor == null) return;
            
            var content = actor.Content;

            var tm = (Timer)param;
            var action = (IAction)tm.param;
            if (action.cast > 0 || action.oper == ACTOper.Charged) {
                // 读条/蓄力技能进行攻击

                var actId = action.id;
                if (action.oper == ACTOper.Charged) {
                    actId = action.GetAdvancedId(AdvancedCond.Charge, entity.L.frameIndex - tm.beginning);
                }

                var target = ObjectExt.GetRefObj(tm.whom);
                CheckHitReedbed(target, content.Weapon, action);
                StageCtrl.S.SyncActionSuccess(entity, content.Weapon, actId, action.type, target);
            }

            StageCtrl.SendLuaEvent("ACTION_SUCCESS",
                obj.id, content.Weapon.id, action.id, action.cooldown);
        }

        public override void OnActionFinish(IEventParam param)
        {
            base.OnActionFinish(param);

            StageCtrl.SendLuaEvent("ACTION_FINISH", obj.id);
        }

        public override void OnActionStop(IEventParam param)
        {
            base.OnActionStop(param);

            var action = (IAction)param;
            if (action.oper == ACTOper.Loop) {
                StageCtrl.S.SyncStopCast(entity, action.id);
            }
        }

        public override void OnHitTarget(IEventParam param)
        {
            base.OnHitTarget(param);
    
            var actor = obj as IActor;
            if (actor == null) return;
            
            var content = actor.Content;
            
            var hitEvent = (HitEvent)param;
            var subSk = hitEvent.Fx as CFG_SubSk;

            if (subSk != null) {
                var syncHitting = subSk.Bullet != null && subSk.Bullet.HasImpact();
                
                IObj hitTarget = null;
                var targets = hitEvent.Whom as IEnumerable<IObj>;
                if (targets != null) {
                    foreach (var tar in targets) {
                        if (hitTarget == null) hitTarget = tar;
                        if (syncHitting)
                            StageCtrl.S.SyncHitTarget(entity, content.Weapon, subSk.UpDS.id, tar);
                    }
                } else {
                    hitTarget = ObjectExt.GetRefObj(hitEvent.Whom);
                    if (syncHitting)
                        StageCtrl.S.SyncHitTarget(entity, content.Weapon, subSk.UpDS.id, hitEvent.Whom);
                }

                if (StageCtrl.Settings.focus_lockOnHit && !obj.CanAttack(lockedTarget)) {
                    if (obj.CanAttack(hitTarget) && obj.camp != hitTarget.camp) {
                        lockedTarget = hitTarget;
                    }
                }
            }
        }
        
        public override void OnShiftRateChange(float value)
        {
            base.OnShiftRateChange(value);

            float syncInterval = m_SyncInterval;
            StageCtrl.S.objAction.SetMoveData(entity, value, ref syncInterval);

            if (StageCtrl.L.localMode) {
                var role = obj as Role;
                var stealth = value < 1f && role.L.InsideReedbed(role);
                if (role.stealth != stealth) {
                    role.stealth = stealth;
                    UpdateStealth(stealth);
                }
            } else {

            }
        }

        public override void OnGridChange(Vector last)
        {
            base.OnGridChange(last);
            
            var role = obj as Role;
            if (role == null) return;
            
            var stealth = role.shiftingRate < 1f && role.L.InsideReedbed(role);
            if (role.stealth != stealth) {
                if (StageCtrl.L.localMode) {
                    role.stealth = stealth;
                    UpdateStealth(stealth);
                } else {
                    if (role.stealthFrame < role.L.frameIndex) {
                        // 立即同步
                        m_SyncRemain = m_SyncInterval;
                        StageCtrl.S.SyncInoutReed(role, role.shiftingRate, ref m_SyncRemain, stealth);
                    } else {
                        Debugger.LogD("隐身冷却剩余：{0}秒", (role.stealthFrame - role.L.frameIndex) * CVar.FRAME_TIME);
                    }
                }
            }
        }

        #endregion

        private void CheckHitReedbed(IObj target, CFG_Weapon weapon, IAction action)
        {
            var hitReed = entity.GetReedbedTarget(target, weapon, action as CFG_Skill);
            if (hitReed != null) {
                var origin = target.coord;
                var dTar = target as DirectionalTar;
                if (dTar != null) origin = dTar.coord;

                foreach (ReedHit reed in hitReed) {
                    Vector nearestGrid = origin;
                    var minDistance = float.MaxValue;
                    foreach (var grid in reed.hitGrids) {
                        Debugger.Draw(new Shape2D(grid, Vector.one), Color.red, 1f);

                        //var direction = (grid - origin).normalized;
                        //if (Vector.Dot(direction, forward) < 0) continue;

                        var distance = Vector.Distance(grid, origin);
                        if (distance < minDistance) {
                            minDistance = distance;
                            nearestGrid = grid;
                        }
                    }

                    reed.pos = nearestGrid;
                    StageCtrl.S.SyncActionSuccess(entity, weapon, entity.L.G.SKILL_ID_BURN_REED, ACTType.SKILL, reed);
                    Debugger.Draw(new Shape2D(nearestGrid, 0.4f), Color.red, 1f);

                    if (StageCtrl.L.localMode) {
                        var reedObj = StageCtrl.L.FindById(reed.id) as ReedObj;
                        if (reedObj != null) {
                            var baseData = new BaseData() {
                                id = reedObj.id, camp = reedObj.camp,
                                pos = reed.pos, status = 0,
                            };
                            reedObj.InitBase(reedObj.L, baseData, reedObj.Data, false);
                        }
                    }
                }

                ((System.IDisposable)hitReed).Dispose();
            }
        }

#if UNITY_EDITOR
        protected override void OnDrawGizmosSelected()
        {
            base.OnDrawGizmosSelected();

            if (StageView.Instance) {
                var pos = StageView.Local2World(m_LastPos);
                GizmosTools.DrawCircle(pos, Quaternion.identity, 0.5f, Color.gray);
            }
        }
#endif
    }
}
