//
//  ObjView.cs
//  survive
//
//  Created by xingweizhen on 10/13/2017.
//
//

using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;
using FMODUnity;
using FX;
using ZFrame.UGUI;
using MEC;
using ZFrame;

namespace World.View
{
    using Control;

    [DisallowMultipleComponent]
    public class EntityView : ObjView, IUnitView, IRenderView, IFxHolder, IPoolable, ITickable
    {
        public const float STEALTH_ALPHA = 0.5f;
        public const float STEALTH_DURA = 0.5f;

        /// <summary>
        /// 应该被回收的延迟
        /// </summary>
        public float recycleDelay;
        
        public IEntity entity { get; protected set; }
        public override IObj obj { get { return entity; } }

        public ObjAnim control { get; protected set; }

        public override bool alwaysView {
            get { return CompareTag(TAGS.AlwaysView) || (control && control.CompareTag(TAGS.AlwaysView)); }
        }

        private DisplayValue m_DisplayDeath = new DisplayValue();
        public void SetDeadDisplay(IObj source, int type, int value)
        {
            m_DisplayDeath.Init(source, type, value);
        }

        [System.NonSerialized, Description("加载状态")]
        public bool loading;

        protected ISkinProperty m_SkinProp;
        private GameObject m_Root;
        public GameObject root {
            get { return m_Root; }
            set {
                m_Root = value;
                if(value != null) {
                    m_SkinProp = value.GetComponent(typeof(ISkinProperty)) as ISkinProperty;
                }
            }
        }        

        public Animator anim { get { return control ? control.anim : null; } }
        public virtual NavMeshAgent agent { get { return null; } }
        
        private HUDText m_Hud;
        public HUDText hud {
            get {
                if (m_Hud == null) {
                    if (IsVisible()) {
                        var go = GoTools.AddChild(StageView.Instance.HudRoot.gameObject, "UI/HUDText", true);
                        m_Hud = (HUDText)go.GetComponent(typeof(HUDText));
                        m_Hud.Follow(bodyPoint);
                    }
                }
                return m_Hud;
            }
        }

        public void UnloadHud()
        {
            if (m_Hud != null) {
                GoTools.DestroyScenely(m_Hud.gameObject);
                m_Hud = null;
            }
        }

        /// <summary>
        /// 单个模型名称（仅用于拥有独立的模型资源的对象）
        /// </summary>
        public string model {
            get {
                var xObj = obj as XObject;
                return xObj != null ? xObj.Data.GetExtend("model") : null;
            }
        }
        public virtual bool IsCombineView() { return false; }

        public override bool IsVisible()
        {
            return root != null && m_Skin && m_Skin.enabled;
        }

        public virtual void SetAction(ObjAnim ctrl, NWObjAction nwAction)
        {
            var dirty = !ctrl.Equals(control);

            ctrl.SetView(this);
            this.control = ctrl;
            this.enabled = true;

            recycleDelay = 0f;
            SetShadowMode(skin);

            if (obj != null) {
                var xObj = obj as XObject;
                if (xObj != null) {
                    if (root != null) {
                        root.transform.localScale = Vector3.one * xObj.Data.GetNumber("modelScale", 1f);
                    }
                }

                var Inf = new VarChange(0, null, obj, obj);                
                if (obj.IsAlive()) {
                    ctrl.enabled = true;
                    this.InitDeadActions();
                    m_DisplayDeath.Init(null, 0, 0);
                    this.ShowHurtActions(ref Inf);
                } else if (dirty) {
                    ctrl.enabled = true;
                    this.InitDeadActions();
                    if (xObj != null) {
                        m_DisplayDeath.Reset(xObj.deadType, xObj.deadValue);
                    } else {
                        m_DisplayDeath.Reset();
                    }
                    this.ShowDeadActions(ref m_DisplayDeath);

                    // 死亡pose
                    obj.ShowDeadPose(ctrl.anim);
                }

                // 调整HUD的位置
                var vol = obj as IVolume;
                if (vol != null) {
                    var goHud = transform.Find("HUD");
                    if (goHud) {
                        var povit = ObjectExt.CalcPovit(vol.size);
                        goHud.localPosition = new Vector3(povit.x, ctrl.height, povit.z);
                    }
                }

                var alpha = 1f;
                var role = obj as Role;
                if (role != null) {
                    if (role.stealth || !role.visible) {
                        var isAlly = role.camp == StageCtrl.P.camp;
                        alpha = isAlly ? STEALTH_ALPHA : 0f;
                    }
                }
                if (alpha < 1) {
                    FadeView(0, alpha, 0);
                } else {
                    this.SetViewEnable(true);
                }
                InitObstacle();

                if (xObj != null) OnStatusChange(xObj.status);

                if (dirty) {
                    UnityEngine.Profiling.Profiler.BeginSample("VIEW_LOAD");
                    StageCtrl.SendLuaEvent("VIEW_LOAD", obj.id, alpha);
                    UnityEngine.Profiling.Profiler.EndSample();
                }
            } else {
                ctrl.enabled = true;
            }
        }

        #region IFxHolder
        public virtual Transform headPoint { get { return control ? control.head : cachedTransform; } }
        public virtual Transform bodyPoint { get { return control ? control.body : cachedTransform; } }
        public virtual Transform footPoint { get { return control ? control.foot : cachedTransform; } }
        private Transform m_Fire;
        public virtual Transform firePoint {
            get {
                if (m_Fire == null) return control ? control.fire : cachedTransform;
                return m_Fire;
            }
            set { m_Fire = value; }
        }

        private Transform m_Top;
        public virtual Transform topPoint {
            get {
                if (m_Top == null) {
                    m_Top = transform.Find("HUD");
                    if (m_Top == null) m_Top = headPoint;
                }
                return m_Top;
            }
        }

        public virtual bool visible { get { return true; } }

        #endregion

        #region IRenderView
        [SerializeField]
        protected Renderer m_Skin;
        public virtual Renderer skin {
            get {
                if (m_Skin == null) {
                    m_Skin = GetComponentInChildren(typeof(Renderer)) as Renderer;
                }
                return m_Skin;
            }
            set { m_Skin = value; }
        }

        public virtual void GetSkins(List<Component> skins)
        {
            if (m_SkinProp == null) {
                if (skin) skins.Add(skin);
            } else {
                m_SkinProp.GetSkins(skins);
            }
        }

        public virtual bool IsDress(DressType dress)
        {
            return false;
        }

        public virtual void SetDress(DressType dress)
        {

        }

        private CoroutineHandle m_Coro;
        public void FadeView(float from, float to, float duration)
        {
            if (control && skin) {
                Timing.KillCoroutines(m_Coro);
                var materialSet = Creator.GetMatSet(this);
                var fadeMat = materialSet.GetFade();
                if (duration > 0) {
                    m_Coro = Timing.RunCoroutine(this.FadingView(from, to, duration, fadeMat));
                } else {
                    this.SetViewAlpha(to, to < 1 ? fadeMat : materialSet.GetNorm());
                }
            }
        }

        protected void SetShadowMode(Renderer rdr)
        {
            if (rdr == null) return;

            rdr.receiveShadows = obj != null;
        }
        
        public void UpdateStealth(bool stealth)
        {
            var role = obj as Role;
            if (role != null) {
                var isAlly = entity.camp == StageCtrl.P.camp;
                if (stealth) {
                    var stealthAlpha = isAlly ? STEALTH_ALPHA : 0f;
                    FadeView(1, stealthAlpha, STEALTH_DURA);
                    if (!isAlly && role.visible) MiniMap.Instance.Enter(obj);
                    StageCtrl.SendLuaEvent("VISIBLE_CHANGED", role.id, stealthAlpha);
                } else {
                    FadeView(isAlly ? STEALTH_ALPHA : 0f, 1, STEALTH_DURA);
                    if (!isAlly && role.visible) MiniMap.Instance.Exit(obj);
                    StageCtrl.SendLuaEvent("VISIBLE_CHANGED", role.id, 1);
                }
            }
        }   
        #endregion

        protected void StopAutoFire(ICastData Fx, bool detach)
        {
            if (Fx == null) return;

            var successFx = Fx.successFx;
            if (!string.IsNullOrEmpty(successFx.sfx)) {
                var sfxName = FxTool.ClampSfxName(this, successFx.sfx);
                var emitter = FMODMgr.Find(sfxName, FxTool.FxRoot);
                if (emitter != null) {
                    if (detach) emitter.gameObject.Attach(null);
                    emitter.SetParam("autoFire", 0f);
                }
            }
        }

        #region EVENT HANDLER

        public virtual void OnHealthChanged(VarChange Inf)
        {
            if (entity != null) {
                // HUD Health Changed
                if (hud && entity.IsSelectable(Inf.maker) && Inf.display != 0) {
                    var color = Inf.display < 0 ? Color.red : Color.green;
                    hud.Add(Inf.display, color);
                }

                // Act Health Changed
                if (Inf.change < 0) {
                    this.ShowHurtActions(ref Inf);

                    var hurtSfx = entity.Data.GetExtend("hurtSfx");
                    if (!string.IsNullOrEmpty(hurtSfx)) {
                        var emitter = entity.PlaySfx(entity, hurtSfx, FXPoint.Head) as FMODAudioEmitter;
                        if (emitter != null) {
                            emitter.SetParam("health", (float)Inf.value / Inf.limit);
                            emitter.SetGender(entity);
                        }
                    }

                    // 飙血系统
                    var Skill = Inf.action as CFG_Skill;
                    if (Skill != null) {
                        var Hurt = StageView.Instance.GetHurtData(Skill.hurt);
                        if (Hurt != null) {
                            var emitter = entity.PlaySfx(entity, Hurt.sfx, FXPoint.Head) as FMODAudioEmitter;
                            if (emitter) emitter.SetParam("showType", entity.Data.bodyMat);

                            var fx = Hurt.GetFx(entity.Data.bodyMat);
                            if (!string.IsNullOrEmpty(fx)) {
                                var caster = Inf.maker ?? entity;
                                caster.PlayFx(entity, fx);
                            }
                            m_DisplayDeath.force = Hurt.force;
                        }
                        m_DisplayDeath.hurt = Hurt;
                    }

                    if (!entity.IsAlive()) {
                        // 本地模拟各种死法表现                        
                        if (entity.L.localMode && Inf.action != null) {                            
                            int type = 0;
                            int value = 0;
                            if (Inf.action.ready > 0 && Inf.action.cast == 0) {
                                // 爆头
                                type = 2; value = (int)DeadType.HeadShot;
                            } else if (Inf.action.maxRange < 1.5f) {
                                // 各种肢解
                                type = 1;
                                value = Random.Range(0, 32);
                            } else {
                                // 腰斩
                                type = 2; value = (int)DeadType.WaistCut;
                            }
                            m_DisplayDeath.Init(StageCtrl.P, type, value);
                        }                        
                    }
                }
            }
        }

        public virtual void OnDuraChanged(DuraChange Inf)
        {
            if (hud) {
                if (Inf.change > 0 && Inf.ammo > 0) {
                    hud.Add(string.Format("+{0} Ammo", Inf.change), Color.yellow);
                }
            }
        }

        public virtual void OnFSMTransition(IEventParam param)
        {
           
        }

        public virtual void OnSwapWeapon(IEventParam param)
        {
           
        }

        public virtual void OnObjTurning(IEventParam param)
        {
           //cachedTransform.forward = StageView.FwdLocal2World(entity.forward);
        }

        public virtual void OnTargetUpdate(IObj target)
        {

        }

        public virtual void OnObjMoving(IEventParam param)
        {
            
        }

        public virtual void OnActionReady(IEventParam param)
        {
        }

        public virtual void OnActionStart(IEventParam param)
        {
            var tm = param as Timer;
            var Action = tm.param as IAction;

            if (anim != null) {
                anim.ResetTrigger(AnimParams.BREAK);
                anim.ResetTrigger(AnimParams.POST);
                anim.SetBool(AnimParams.RELEASE, false);
                anim.CrossFadeInFixedTime(Action.motion, 0.1f, -1, 0f);
            }
            
            var Target = ObjectExt.GetRefObj(tm.whom);
            entity.PlayFxOnStartCast(Target, tm.param as ICastData);
        }

        public virtual void OnActionSuccess(IEventParam param)
        {
            var tm = (Timer)param;
            var action = (IAction)tm.param;

            if (anim) {
                if (action.oper == ACTOper.Charged) {
                    anim.SetBool(AnimParams.RELEASE, true);
                }
            }

            if (tm.whom != null) {
                cachedTransform.forward = StageView.FwdLocal2World(entity.forward);
                
                if (action.oper == ACTOper.Charged) {
                    var changed = action.GetAdvancedId(AdvancedCond.Charge, entity.L.frameIndex - tm.beginning);
                    if (changed != action.id) action = CFG_Action.Load(changed);
                }

                // 特效
                entity.PlayFxOnCastSuccess(ObjectExt.GetRefObj(tm.whom), action as ICastData);
            }
        }

        public virtual void OnActionFinish(IEventParam param)
        {
            if (anim) {
                anim.SetTrigger(AnimParams.POST);
            }

            var actor = obj as IActor;
            if (actor != null) {
                var acting = actor.Content.prefab != null;
                if (!acting) {
                    var tm = param as Timer;
                    StopAutoFire(tm.param as ICastData, true);
                }
            } else {
                LogMgr.W("Call OnActionFinish On {0}", obj);
            }
        }

        public virtual void OnActionBreak(IEventParam param)
        {
            var tm = param as Timer;
            StopAutoFire(tm.param as ICastData, true);
            if (anim) {
                if (!anim.GetBool(AnimParams.RELEASE)) {
                    anim.SetTrigger(AnimParams.BREAK);
                }
            }
        }

        public virtual void OnActionStop(IEventParam param)
        {
            StopAutoFire(param as ICastData, false);
        }

        public virtual void OnHitTarget(IEventParam param)
        {
            var hitEvent = param as HitEvent;
            var Target = ObjectExt.GetRefObj(hitEvent.Whom);

            if (Target != null && Target.id != 0 && Target.view == null) {
                // View丢失，重新寻找
                Target = StageCtrl.L.FindById(Target.id);
            }
            entity.PlayFxOnHitTarget(Target, hitEvent.Fx);
        }

        public virtual void OnBeingHit(IEventParam param)
        {

        }

        public virtual void OnEffecting(IEventParam param)
        {
            var EffEvent = param as SimpleBuff.Effecting;
            if (EffEvent != null) {
                var tm = entity.L.tmMgr.Find(EffEvent.timerUnique);
                entity.PlayFxOnTarget(entity, tm, EffEvent.Eff.fx);

                if (entity.IsLocal()) {
                    var duration = CVar.F2S(tm.beginning + tm.duration - entity.L.frameIndex);
                    StageCtrl.SendLuaEvent("EFFECTING", EffEvent.who, EffEvent.whom, EffEvent.Eff.id, duration);
                }
            }
        }

        public virtual void OnFireMissile(IEventParam param)
        {
            var missile = param as Missile;
            var list = FxTool.GetPool();
            entity.PlayFx(entity, missile.Sub.Bullet.fx, list);
            foreach (var fx in list) {
                var fxC = fx as MonoBehaviour;
                if (fxC) {
                    var msView = fxC.GetComponent(typeof(MissileView)) as MissileView;
                    if (msView) {
                        msView.Attach(FxTool.FxRoot, true);
                        msView.Subscribe(missile);
                        break;
                    }
                }
            }
        }

        public virtual void OnAttrChanged(IEventParam param)
        {
           
        }

        public virtual void OnObjDead()
        {
            this.ShowDeadActions(ref m_DisplayDeath);

            if (!m_DisplayDeath.overrideFx) {
                var deadFx = entity.Data.GetExtend("deadFx");
                if (!string.IsNullOrEmpty(deadFx)) {
                    entity.PlayFxOnTarget(entity, null, deadFx, null, FXPoint.Head);
                }
            }
            //死亡音效
            var deadSfx = entity.Data.GetExtend("deadSfx");
            if (!string.IsNullOrEmpty(deadSfx)) {
                var emitter = entity.PlaySfx(entity, deadSfx, FXPoint.Head) as FMODAudioEmitter;
                emitter.SetParam("deadType", m_DisplayDeath.type);
                emitter.SetParam("deadSpecialType", m_DisplayDeath.value);
            }
            this.SetFOWStatus<StageFOWExplorer>(false);
            this.SetFOWStatus<StageFOWStalker>(false);

            var role = obj as Role;
            if (role != null) {
                role.visible = true;
                FadeView(0, 1, 0);
            } 

            gameObject.SetEnable(typeof(NavMeshObstacle), false);
            StageView.Instance.RemoveNavMeshBuild(this);            
        }

        public virtual void OnObjLeave()
        {
            gameObject.SetEnable(typeof(NavMeshObstacle), false);
            StageView.Instance.RemoveNavMeshBuild(this);
            Destruct(ObjCtrl.FADING_DURA);
        }

        public virtual void OnShiftRateChange(float value)
        {
            if (anim) {
                anim.SetBool(AnimParams.SNEAK, value < 1);
            }
        }

        public virtual void OnOperChange(int limit, int value)
        {

        }

        public virtual void OnCampChange(int value)
        {

        }

        public override void OnStatusChange(int value)
        {
            if (control != null) {
                var list = ZFrame.ListPool<Component>.Get();
                control.GetComponents(typeof(IStatusAnim), list);
                foreach (IStatusAnim anim in list) anim.OnStatusChanged(value);
                ZFrame.ListPool<Component>.Release(list);
            }
        }

        public virtual void OnGridChange(Vector last)
        {
           
        }

        #endregion

        public override void Subscribe(IObj o)
        {
            var lastEnt = entity;
            entity = o as IEntity;
            if (entity.view != null && !Equals(entity.view)) {
                entity.view.Destruct(0f);
            }

            entity.view = this;

            var pos = StageView.Local2World(entity.pos);

            if (lastEnt != null) {
                if (Equals(lastEnt.view)) {
                    Debugger.Uninit(lastEnt);
                }
            } else {
                if (agent) {
                    agent.Warp(pos);
                } else {
                    cachedTransform.position = pos;
                }
                cachedTransform.forward = StageView.FwdLocal2World(entity.forward);
            }

            OnOperChange(entity.operLimit, entity.operId);

            Debugger.Init(entity);
        }

        public override void Unsubscribe()
        {
            if (obj != null) {
                Debugger.Uninit(entity);

                if (Equals(obj.view)) {
                    obj.view = null;
                }
                entity = null;
            }
        }

        public override void Destruct(float delay)
        {
            this.DestroyView(delay);
        }

        public override void UnloadView()
        {
            if (obj != null) {
                FxInst.Stop(obj, false);
                StageCtrl.SendLuaEvent("VIEW_UNLOAD", obj.id);
                obj.DetatchFx();
            }

            UnloadHud();
            this.SetViewEnable(false);
            m_Skin = null;
            GoTools.DestroyPooledScenely(root);

            root = null;
            control = null;
            m_SkinProp = null;            
            enabled = false;
        }

        protected virtual void UpdateFoward(float deltaTime)
        {
            UnityEngine.Profiling.Profiler.BeginSample("UpdateFoward");
            var turner = obj as ITurnable;
            if (turner != null) {
                var forward = StageView.FwdLocal2World(turner.forward);
                if (turner.forward != turner.turnForward) {
                    if (forward != cachedTransform.forward) {
                        cachedTransform.forward = Vector3.RotateTowards(
                            cachedTransform.forward, forward, turner.GetAngularSpeed() * deltaTime, 1f);
                    }
                } else {
                    cachedTransform.forward = forward;
                }
            }
            UnityEngine.Profiling.Profiler.EndSample();
        }

        private void InitObstacle()
        {
            if (control.obstacle == ObjAnim.Obstacle.None || entity == null || entity is Role || !entity.obstacle) {
                gameObject.SetEnable(typeof(NavMeshObstacle), false);
                return;
            }

            var ent = (IEntity)obj;
            var entSize = ent.size;
            var shape = ObjAnim.Obstacle.Rect;
            if (Math.IsEqual(entSize.x, entSize.z)) {
                shape = control.obstacle;
            }

            switch (shape) {
                case ObjAnim.Obstacle.Circle: {
                    var obstacle = (NavMeshObstacle)gameObject.NeedComponent(typeof(NavMeshObstacle));
                    obstacle.enabled = true;
                    obstacle.carving = true;
                    obstacle.shape = NavMeshObstacleShape.Capsule;
                    obstacle.height = 1f;
                    obstacle.center = Vector3.zero;

                    var correct = NavMesh.GetSettingsByID(0).agentRadius + 0.01f;
                    obstacle.radius = Mathf.Max(0.1f, obj.GetRadius() - correct);
                    break;
                }
                case ObjAnim.Obstacle.Rect: {
                    var obstacle = (NavMeshObstacle)gameObject.NeedComponent(typeof(NavMeshObstacle));
                    obstacle.enabled = true;
                    obstacle.carving = true;
                    obstacle.shape = NavMeshObstacleShape.Box;

                    var agentRadius = NavMesh.GetSettingsByID(0).agentRadius;
                    float sizex = entSize.x, sizez = entSize.z;
                    if (sizex > 0 && sizez > 0) {
                        var correct = agentRadius * 2f + 0.01f;
                        obstacle.size = new Vector3(
                            Mathf.Max(0.1f, sizex - correct), 1,
                            Mathf.Max(0.1f, sizez - correct));
                    } else {
                        obstacle.size = new Vector3(Mathf.Max(agentRadius, sizex), 1, Mathf.Max(agentRadius, sizez));
                    }

                    obstacle.center = ObjectExt.CalcPovit(ent.size);
                    break;
                }
                default:
                    UnityEngine.Assertions.Assert.IsFalse(true);
                    break;
            }
        }

        protected virtual void OnRecycle()
        {
            this.SetFOWStatus<StageFOWStalker>(false);
            this.SetFOWStatus<StageFOWExplorer>(false);
            
            if (m_Skin != null) {
                var skinned = m_Skin as SkinnedMeshRenderer;
                if (skinned && skinned.sharedMesh &&
                    skinned.sharedMesh.name.Contains(SkinnedMeshCombiner.COMBINED)) {
                    Destroy(skinned.sharedMesh);
                }
            }
            
            UnloadView();
            Unsubscribe();
            loading = false;
            
            transform.localPosition = new Vector3(0, -999, 0);
        }

        // Use this for initialization
        protected virtual void Start()
        {
            
        }

        bool ITickBase.ignoreTimeScale { get { return false; } }
        
        // Update is called once per frame
        public virtual void Tick(float deltaTime)
        {
            if (control) {
                UpdateFoward(deltaTime);

                Debugger.Update(entity);
                if (updateDebug) UpdateDebug();
            }
        }

        protected virtual void OnEnable()
        {
            this.SetFOWStatus<StageFOWExplorer>();
            this.SetFOWStatus<StageFOWStalker>();
            TickManager.Add(this);
        }

        protected virtual void OnDisable()
        {
            gameObject.SetEnable(typeof(StageFOWExplorer), false);
            gameObject.SetEnable(typeof(StageFOWStalker), false);
            TickManager.Remove(this);
        }
        
        private void UpdateDebug()
        {
            if (entity != null) {
                var trans = StageView.Instance.PlateRoot.Find(string.Format("HUD#{0}/lbDebug", entity.id));
                var lb = trans ? trans.GetComponent(typeof(ILabel)) as ILabel : null;
                if (lb != null) {
                    var strbld = new System.Text.StringBuilder();
                   
                    var angles = Mathf.Round(Vector3.SignedAngle(Vector3.forward, entity.forward, Vector3.up));
                    if (angles < 0) angles += 360;
                    strbld.AppendFormat("<mark=#FF000040>{0}</mark>", entity.coord.ToXZ())
                          .AppendFormat(" <mark=#00FF0040>{0}</mark>", angles);
                    
                    if (agent != null) {
                        strbld.AppendFormat(" <mark=#0000FF40>{0:F2}m/s</mark>", agent.speed);
                    }

                    lb.text = strbld.ToString();
                }
            }
        }


        void IPoolable.OnRestart()
        {
            enabled = true;
            Start();
        }

        void IPoolable.OnRecycle()
        {
            enabled = false;
            OnRecycle();

            if (gameObject.layer == LAYERS.iOverUI) {
                gameObject.SetEnable(typeof(FollowUITarget), false);
                transform.SetParent(transform.parent.parent);
            }
        }

#if UNITY_EDITOR
        protected virtual void OnDrawGizmosSelected()
        {
           
        }
#endif

    }
}
