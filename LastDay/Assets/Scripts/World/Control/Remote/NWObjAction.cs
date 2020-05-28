using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;
using clientlib.net;

namespace World.Control
{
    using View;
    public class NWObjAction : IFullMsg, IDataFromLua
    {
        public bool Acting;

        public IEntity Obj { get; private set; }
        public ObjAction status { get; private set; }
        private NWVector vSelf;

        public CFG_Weapon Weapon { get; private set; }

        public int action { get; private set; }
        public void SetAction(int newAction) { action = newAction; }
        public IAction GetAction() { return action >= 0 ? CFG_Action.Load(action) : null; }
        public IObj GetTarget()
        {
            IObj ret = null;
            if (affix == AffixType.TarData) {
                ret = targetId != 0 ?
                    StageCtrl.L.FindById(targetId, true) : new LocateObj(vNext.coord, StageCtrl.L);
                if (ret == null) {
                    Debugger.LogW("对象不存在{0}={1}", targetId, ret);
                }
            }
            else {
                ret = new LocateObj(vNext.coord, StageCtrl.L);
            }

            return ret;
        }

        private AffixType affix;
        public NWVector vNext;
        private int param;
        public int targetId { get { return param; } private set { param = value; } }
        public float moveSpeed {
            get { return param * CVar.LENGTH_RATE; }
            private set { param = (int)(value / CVar.LENGTH_RATE); }
        }

        public override string ToString()
        {
            if (Acting) {
                return string.Format("{0}{1} ACT:{2}#{3}|{4}:{5}+{6}",
                    Obj, vSelf, status, action, affix, vNext, param);
            } else {
                return string.Format("{0}{1} SYNC:{2}#{3}|{4}:{5}+{6}",
                    Obj, vSelf, status, action, affix, vNext, param);
            }
        }

        public bool IsDirty()
        {
            return status != ObjAction.NONE;
        }

        public void Clear()
        {
            // 清空数据
            Acting = false;
            Obj = null;
            status = ObjAction.NONE;
            Weapon = null;
            action = 0;
            affix = 0;
        }

        public void Write(INetMsg nm)
        {
            var istate = (int)status;

            var Actor = Obj as IActor;
            if (Actor != null && Actor.IsLocal()) {
                Actor.state = istate;
            }
            
            nm.writeU32(Obj != null ? Obj.id : 0).writeU32(istate);
            vSelf.Write(nm);

            nm.writeU32((int)affix);

            if (status >= ObjAction.StartCast && status < ObjAction.Pick) {
                nm.writeU32(action);
            }

            if (affix > AffixType.None) {
                vNext.Write(nm);
                nm.writeU32(param < 0 ? 0 : param);
            }
        }

        void IMsgObj.Read(INetMsg nm)
        {
            ReadData(nm);
            SyncObj();
        }

        public void ReadData(INetMsg nm)
        {
            var objId = nm.readU32();
            Obj = StageCtrl.L.FindById(objId) as IEntity;

            status = (ObjAction)nm.readU32();
            vSelf.Read(nm);

            affix = (AffixType)nm.readU32();
            if (status >= ObjAction.StartCast && status < ObjAction.Pick) {
                action = nm.readU32();
            } else {
                action = 0;
            }

            if (affix > AffixType.None) {
                vNext.Read(nm);
                param = nm.readU32();
            } else {
                param = 0;
            }

            if (Obj != null && Obj.IsLocal()) return;
            
            var actor = Obj as IActor;
            if (actor != null) actor.state = (int)status;

            var mover = Obj as IMovable;
            if (mover != null) mover.moveTarget = vSelf.coord;

            var turner = Obj as ITurnable;
            if (turner != null) turner.turnForward = vSelf.forward;
        }

        public CFG_Weapon TryLoadTool(int dat)
        {
            var human = Obj as Human;
            if (human != null && !human.IsLocal()) {
                // 加载工具
                CFG_Weapon Tool = human.Major;
                if (human.Major.dat != dat) {
                    Tool = human.Tool;
                    if (Tool.dat != dat) {
                        Tool.LoadData(-dat);
                    }
                }
                var view = human.view as HumanView;
                if (view) view.EquipTool(Tool);

                return Tool;
            }
            return null;
        }

        public void SyncObj(IObj Self = null, ObjAction overrideStatus = ObjAction.NONE)
        {
            if (Self == null) Self = Obj;
            if (overrideStatus == ObjAction.NONE) overrideStatus = this.status;

            // 同步
            switch (overrideStatus) {
                case ObjAction.Stand: StopMove(Self as IMovable, false); break;
                case ObjAction.Move: SyncMove(Self as IMovable, false); break;
                case ObjAction.Sneak: StopMove(Self as IMovable, true); break;
                case ObjAction.SneakMove: SyncMove(Self as IMovable, true); break;
                case ObjAction.Locate: SyncLocate(Self as IMovable); break;
                case ObjAction.Sync: Acting = true; goto case ObjAction.StartCast;
                case ObjAction.StartCast: SyncStartCast(Self as IActor); break;
                case ObjAction.CancelCast: SyncCancelCast(Self as IActor); break;
                case ObjAction.CastSuccess: SyncCastSuccess(Self as IActor, GetAction(), GetTarget()); break;
                case ObjAction.NewTarget: SyncNewTarget(Self as IActor, GetTarget()); break;
                case ObjAction.Func:
                case ObjAction.StopCast: SyncStopCast(Self as IActor); break;
                case ObjAction.Pick: if (action == 0) action = CVar.PICK_ID; SyncInteract(Self as IActor); break;
                case ObjAction.Open: if (action == 0) action = CVar.OPEN_ID; SyncInteract(Self as IActor); break;

                default: break;
            }
        }

        private void StopMove(IMovable mover, bool sneak)
        {
            if (mover != null && !mover.IsLocal()) {
                mover.shiftingRate = sneak ? mover.GetAttr(ATTR.Sneak) / mover.GetAttr(ATTR.Move) : 1f;
                if (Vector.Distance(mover.coord, vSelf.coord) > CVar.SYNC_DIST) {
                    // 路程超过某个阈值则立即归位
                    SyncPosition(mover);
                } else {
                    mover.pos = mover.moveTarget;
                    mover.StopMoving();
                }
            }
        }

        private void SyncMove(IMovable mover, bool sneak)
        {
            if (mover != null && !mover.IsLocal()) {
                var lastSpeed = mover.GetMovingSpeed();
                mover.shiftingRate = sneak ? mover.GetAttr(ATTR.Sneak) / mover.GetAttr(ATTR.Move) : 1f;
                
                var speed = moveSpeed;
                if (StageView.Instance != null && lastSpeed == 0) {
                    var hView = mover.view as HumanView;
                    if (hView && hView.control) ((RoleAnim)hView.control).ResetIdle(hView, 0.1f);
                }

                // 计算位置误差
                if (Vector.Distance(mover.coord, vSelf.coord) > CVar.SYNC_DIST) {
                    // 路程超过某个阈值则立即归位
                    SyncPosition(mover);
                }
                var localOffset = Vector.Distance(vNext.coord, mover.coord);
                var remoteOffset = Vector.Distance(vNext.coord, vSelf.coord);
                var time = remoteOffset / speed;
                if (!vNext.hasForward) {
                    // 移动路径不是最后一段，增加200ms的延迟，移动表现更顺畅
                    time += 0.2f;
                }

                var forward = (vNext.coord - vSelf.coord).normalized;
                var turner = Obj as ITurnable;
                if (vNext.hasForward) {
                    mover.moveTarget = vNext.coord;
                    if (turner != null) turner.turnForward = vNext.forward;
                } else {
                    mover.moveTarget = vNext.coord + forward;
                    if (turner != null) turner.turnForward = forward;
                }

                mover.MoveTo(mover.moveTarget, speed / mover.GetShiftingSpeed());

                if (time > 0) {
                    Debugger.DrawLine(Color.blue, time, vSelf.coord, vNext.coord);

                    // 预警速度异常
                    var localSpeed = localOffset / time;
                    if (localSpeed > speed * 2) {
                        Debugger.LogW("{0}@{1}的移动速度异常={2}m/s({3}->{4}|{5}m/s)",
                            mover, mover.coord, localSpeed, vSelf.coord, vNext.coord, speed);
                    }
                }
            }
        }

        private void SyncPosition(IMovable mover)
        {   
            mover.pos = mover.moveTarget;
            mover.StopMoving();

            if (StageView.Instance != null) {
                var mono = mover.view as RoleView;
                var pos = StageView.Local2World(mover.moveTarget);
                if (mono && mono.agent) {
                    mono.agent.Warp(pos);
                    if (mono.agent.enabled) mono.agent.destination = pos;
                }
                else {
                    var com = mover.view as Component;
                    if (com) com.transform.position = pos;
                }
            }
        }

        private void SyncLocate(IMovable mover)
        {
            SyncPosition(mover);
            if (mover.IsLocal()) {
                mover.OnFSMEvent(EVENT.LEAVE_ACTION);
            }
        }

        private void CheckBeingHit(IActor actor, IAction Action)
        {
            // 检查自己施放被范围技能命中
            var skill = Action as CFG_Skill;
            if (skill == null) return;
            var hitTarget = GetTarget();
            if (hitTarget == null) return;
            if (!ObjectExt.IsAlive(StageCtrl.P)) return;
            
            skill.ClampTarget(actor, ref hitTarget);
            var shape = new Shape2D(StageCtrl.P);
            foreach (var subSk in skill.Subs) {
                TARType tarType;
                CFG_Target cfgTarget;
                subSk.GetTarCfg(out tarType, out cfgTarget);
                if (cfgTarget.rangeType != RangeType.Single && actor.IsSet(StageCtrl.P, cfgTarget.tarSet)) {
                    if (subSk.delay > 0) {
                        StageCtrl.P.NewTimer(actor, hitTarget, subSk.delay)
                            .SetParam(subSk).SetEvent(OnObjBeingHit, null, null);
                    } else {
                        var hitArea = TargetAlg.GetHitArea(actor, hitTarget, cfgTarget);
                        if (hitArea.Intersect(ref shape)) {
                            StageCtrl.S.SyncHited(actor, subSk, StageCtrl.P);
                        }
                        Debugger.Draw(ref hitArea, Color.blue, 1f);
                    }
                }
            }
        }

        private void SyncStartCast(IActor actor)
        {
            if (actor != null) {
                var Action = GetAction();
                if (!actor.IsLocal()) {
                    if (Vector.Distance(actor.coord, vSelf.coord) > CVar.SYNC_DIST) {
                        // 位置偏差超过某个阈值发出警告
                        LogMgr.W("{0}攻击时位置异常：远端：{1}，本地{2}", actor, actor.coord, vSelf.coord);
                    }

                    var Skill = Action as CFG_Skill;
                    
                    IObj Target = null;
                    if (Skill == null || Skill.Target.rangeType == RangeType.Single) {
                        Target = GetTarget();
                    } else {
                        Target = new LocateObj(vNext.coord, StageCtrl.L);
                    }

                    // 完成前一个动作定时器
                    actor.FinishAction();

                    var human = actor as Human;
                    var Weapon = human != null ? human.Major : null;
                    HFSM_RemoteState.PrepareAction(actor, Weapon, Action, Target, Acting);

                    if (Action.mode != ACTMode.FreeMove) {
                        var mover = actor as IMovable;
                        if (mover != null) mover.StopMoving();
                    }

                }
                if (Acting) CheckBeingHit(actor, Action);
            }
        }

        private void SyncCancelCast(IActor actor)
        {
            if (actor != null && !actor.IsLocal()) {
                // 动作失败（其它情况？）
                actor.BreakAction();
            }
        }

        private void SyncStopCast(IActor actor)
        {
            if (actor != null && !actor.IsLocal()) {
                // 动作停止
                actor.Content.Uninit(ACTOper.Cancelled);
            }
        }

        private void SyncCastSuccess(IActor actor, IAction Action, IObj Target)
        {
            if (actor != null) {
                if (!actor.IsLocal()) {
                    if (Vector.Distance(actor.coord, vSelf.coord) > CVar.SYNC_DIST) {
                        // 位置偏差超过某个阈值发出警告
                        LogMgr.W("{0}攻击时位置异常：远端：{1}，本地{2}", actor, actor.coord, vSelf.coord);
                    }

                    // 动作成功
                    actor.Attack(null, null);
                    actor.NewTimer(actor, Target, 0).SetParam(Action)
                        .SetEvent(TimerEvents.OnActionSuccess, null, null);
                }
                if (Acting) CheckBeingHit(actor, Action);
            }
        }

        private void SyncNewTarget(IActor actor, IObj target)
        {
            if (actor != null && !actor.IsLocal()) {
                actor.Content.currTarget = target;
            }
        }

        private void SyncInteract(IActor actor)
        {
            if (actor != null && !actor.IsLocal()) {
                var tool = TryLoadTool(0);
                HFSM_RemoteState.PrepareAction(actor, tool, GetAction(), GetTarget(), true);
            }
        }
        
        private void SetSefPos(IEntity obj)
        {
            var turner = obj as ITurnable;
            vSelf = new NWVector() {
                coord = obj.coord, forward = turner != null ? turner.turnForward : obj.forward,
            };
        }

        public void SetMoveData(IEntity self, float shiftingRate, ref float interval)
        {
            if (Acting || status > ObjAction.Reload) return;

            var mover = self as IMovable;
            if (mover == null) return;
            
            Acting = false;
            Obj = self;

            var speed = mover.GetMovingSpeed();
            if (Math.IsEqual(shiftingRate, 1)) {
                status = speed > 0 ? ObjAction.Move : ObjAction.Stand;
            } else {
                status = speed > 0 ? ObjAction.SneakMove : ObjAction.Sneak;
            }
            SetSefPos(self);

            affix = speed > 0 ? AffixType.PosData : AffixType.None;
            action = 0;

            var selfCoord = self.coord;
            if (mover.destination != selfCoord) {
                var lookForward = (mover.destination - selfCoord).normalized;
                var nextCoord = selfCoord + lookForward * speed * interval;
                Map.ClampInside(selfCoord, ref nextCoord);
                
                var view = mover.view as IUnitView;
                if (view != null && view.agent) {
                    nextCoord = StageView.World2Local(view.agent.steeringTarget);

                    var target = StageView.Local2World(nextCoord);
                    NavMeshHit hit;
                    var source = StageView.Local2World(selfCoord);
                    if (NavMesh.Raycast(source, target, out hit, view.agent.areaMask)) {
                        var hitCoord = StageView.World2Local(hit.position);
                        if (Vector.Distance(hitCoord, selfCoord) > 1f) {
                            nextCoord = hitCoord;
                        }
                    }
                    interval = Vector.Distance(nextCoord, selfCoord) / speed;
                }
                vNext = new NWVector() {
                    coord = nextCoord, forward = lookForward,
                };
            } else {
                vNext = vSelf;
            }
            moveSpeed = speed;
        }
        
        private void SetCast(CFG_Weapon Weapon, int action, IObj target)
        {
            SetSefPos(Obj);
            this.Weapon = Weapon;
            this.action = action;
            if (target != null) {
                affix = AffixType.TarData;
                var vec = target as IVector;
                var dTar = target as DirectionalTar;
                vNext = new NWVector() {
                    coord = dTar == null ? target.coord : dTar.pos,
                    forward = vec != null ? vec.forward : Vector.zero,
                };
                targetId = target.id;
            } else {
                affix = AffixType.None;
                targetId = 0;
                // 目标为空则强制为同步动作
                Acting = false;
            }
        }

        private void SetActionStatus(ACTType type, IObj target, ObjAction objAction)
        {
            if (type == ACTType.SKILL) {
                status = objAction;
            } else {
                if (Acting) {
                    switch (type) {
                        //case ACTType.GATHER: state = ObjState.Gahter; break;
                        case ACTType.PICK: status = ObjAction.Pick; break;
                        case ACTType.OPEN: status = ObjAction.Open; break;
                        case ACTType.TRIG: status = ObjAction.Trigger; break;
                        case ACTType.SYNC: status = ObjAction.Sync; break;
                        case ACTType.FUNC: status = ObjAction.Func; break;
                        default: status = objAction; break;
                    }
                } else {
                    status = ObjAction.StartCast;
                }
            }
        }

        /// <summary>
        /// 同步开始动作。
        /// </summary>
        /// <param name="caster">动作发起者</param>
        /// <param name="action">动作数据</param>
        /// <param name="target">作用目标</param>
        public void SetStartCast(IEntity caster, CFG_Weapon Weapon, IAction Action, IObj target, bool actMode)
        {
            if (Acting && !actMode) return;

            Acting = actMode;
            Obj = caster;
            SetActionStatus(Action.type, target, ObjAction.StartCast);
            SetCast(Weapon, Action.id, target);
        }

        public void SetLookTarget(IEntity caster, CFG_Weapon Weapon, IAction Action, IObj target)
        {
            Acting = false;
            Obj = caster;
            status = ObjAction.NewTarget;
            SetCast(Weapon, Action.id, target);
        }

        /// <summary>
        /// 同步动作成功（读条动作、蓄力动作）
        /// </summary>
        /// <param name="caster">动作发起者</param>
        /// <param name="action">动作数据</param>
        /// <param name="target">作用目标</param>
        public void SetCastSuccess(IEntity caster, CFG_Weapon Weapon, int action, ACTType type, IObj target)
        {
            Acting = true;
            Obj = caster;

            SetActionStatus(type, target, ObjAction.CastSuccess);
            SetCast(Weapon, action, target);
        }

        /// <summary>
        /// 同步弹道命中了目标
        /// </summary>
        /// <param name="caster">动作发起者</param>
        /// <param name="action">动作数据</param>
        /// <param name="target">命中目标</param>
        public void SetHitTarget(IEntity caster, CFG_Weapon Weapon, int action, IObj target)
        {
            Acting = true;
            Obj = caster;
            status = ObjAction.HitTarget;
            SetCast(Weapon, action, target);
        }

        /// <summary>
        /// 同步动作取消（蓄力动作）
        /// </summary>
        /// <param name="caster">动作发起者</param>
        /// <param name="action">动作数据</param>
        public void SetCancelCast(IEntity caster, int action)
        {
            if (Acting) return;

            Acting = true;
            Obj = caster;
            status = ObjAction.CancelCast;
            SetCast(null, action, null);
        }

        /// <summary>
        /// 同步动作停止（可循环动作）
        /// </summary>
        /// <param name="caster">动作发起者</param>
        /// <param name="action">动作数据</param>
        public void SetStopCast(IEntity caster, int action)
        {
            if (Acting) return;

            Acting = true;
            Obj = caster;
            status = ObjAction.StopCast;
            SetCast(null, action, null);
        }

        private static readonly TimerHandler OnObjBeingHit = (tm, n) => {
            var subSk = (CFG_SubSk)tm.param;
            TARType tarType;
            CFG_Target cfgTarget;
            subSk.GetTarCfg(out tarType, out cfgTarget);
            var hitArea = TargetAlg.GetHitArea(tm.who, tm.whom, cfgTarget);
            if (hitArea.Intersect(StageCtrl.P)) {
                StageCtrl.S.SyncHited(tm.who, subSk, StageCtrl.P);
            }

            Debugger.Draw(ref hitArea, Color.blue, 1f);
            return true;
        };

        void IDataFromLua.InitFromLua(System.IntPtr lua, int index)
        {
            //var objId = nm.readU32();
            //Obj = StageCtrl.L.FindById(objId) as IEntity;

            status = (ObjAction)lua.GetEnum(index, "state", ObjAction.Stand);

            lua.GetField(index, "Self");
            vSelf = new NWVector(lua.GetValue(I2V.ToVector2, -1, "coord"), lua.GetNumber(-1, "angle"));
            lua.Pop(1);

            affix = (AffixType)lua.GetEnum(index, "addData", AffixType.None);
            if (status >= ObjAction.StartCast && status < ObjAction.Pick) {
                action = (int)lua.GetNumber(index, "skill");
            } else {
                action = 0;
            }

            if (affix > AffixType.None) {
                lua.GetField(index, "Next");
                vNext = new NWVector(lua.GetValue(I2V.ToVector2, -1, "coord"), lua.GetNumber(-1, "angle"));
                lua.Pop(1);
                param = (int)lua.GetNumber(index, "param");
            } else {
                param = 0;
            }
        }
    }
}
