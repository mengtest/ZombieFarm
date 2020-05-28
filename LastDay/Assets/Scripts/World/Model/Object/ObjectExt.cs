//
//  ObjectExt.cs
//  survive
//
//  Created by xingweizhen on 10/19/2017.
//
//

using System.Collections.Generic;
using ZFrame.HFSM;

namespace World
{
    public static class ObjectExt
    {
        public static bool IsEqual(IObj a, IObj b)
        {
            VirtualObj vObjA = a as VirtualObj, vObjB = b as VirtualObj;
            if (vObjA != null && vObjB != null) {
                return vObjA.Equals(vObjB);
            }

            return a == b;
        }

        public static bool IsNull(IObj obj)
        {
            return obj == null || obj.IsNull();
        }

        public static bool IsAlive(IObj obj)
        {
            return obj != null && obj.IsAlive();
        }

        public static bool IsActing(this IObj obj)
        {
            var bObj = obj as IActor;
            return bObj != null && !bObj.Content.idle;
        }

        public static IObj Valid(ref IObj obj)
        {
            if (IsNull(obj)) obj = null;
            return obj;
        }
        
        public static Vector CalcPovit(Vector size)
        {
            if (Math.IsEqual(size.x, size.z)) {
                return Vector.zero;
            }

            Vector offset;
            if (size.x > size.z) {
                offset = new Vector(0, 0, (size.x - size.z) / 2);
            } else {
                offset = new Vector((size.z - size.x) / 2, 0, 0);
            }
            return offset;
        }

        public static Vector UpdateCoord(this XObject self)
        {
            var povit = CalcPovit(self.size);
            var offset = Vector.RotateOffset(povit, self.forward);
            return self.pos + offset;
        }

        public static Vector CalcForward(this IEntity self, IObj target)
        {
            if (target == null) return self.forward;
            var dTar = target as DirectionalTar;
            if (dTar != null) {
                return dTar.pos - self.coord;
            }

            return target.coord - self.coord;
        }

        public static bool OnFSMEvent(this IObj self, EVENT evt)
        {
            var context = self as IFSMContext;
            return context != null && context.OnEvent((int)evt);
        }

        public static FSM_STATE GetFSMState(this IObj self)
        {
            var context = self as IFSMContext;
            if (context != null && context.fsm.activated)
                return (FSM_STATE)context.fsm.GetCurrentState().id;

            return FSM_STATE.IDLE;
        }

        public static float CalcRadius(this IVolume self)
        {
            var size = self.size;
            if (Math.IsEqual(size.x, size.z)) return size.x / 2;

            return (size.x + size.z) / 4;
        }

        public static float GetRadius(this IObj self)
        {
            var vol = self as IVolume;
            return vol != null ? vol.CalcRadius() : 0;
        }

        public static IObj GetRefObj(IObj self)
        {
            var refTar = self as IRefObj;
            if (refTar != null) self = refTar.target;
            return self;
        }

        public static int Ranging(this IObj self, IObj target, IAction action)
        {
            var distance = self.coord.DistanceTo(target);
            if (distance > action.maxRange) return 1;

            var ent = target as IEntity;
            if (ent != null && ent.operId > 0) {
                // 在距离内，目标可交互时判断遮挡
                Vector hitPos;
                var block = self.L.Raycast(self.coord, target, action.blockLevel, out hitPos);
                if (block != null) {
                    return 1;
                }
            }

            if (action.minRange > 0 && distance < action.minRange) return -1;

            return 0;
        }

        public static bool IsFaceTo(this IEntity self, IObj pos, IAction action)
        {
            if (self.coord != pos.coord) {
                // 有准备时间的瞬发技能需要完全面对目标才执行动作，其他情况只需要正面对着目标。
                var dot = action.ready > 0 && action.cast == 0 ? CVar.DOT_FORWARD_COMPLETELY : CVar.DOT_FORWARD;
                return Vector.Dot(self.forward, Vector.Forward(self.coord, pos.coord)) > dot;
            }
            return true;
        }

        public static bool CanVisible(this IObj self, IObj target)
        {
            return target != null && !target.IsNull() && target.IsVisible(self);
        }

        public static bool CanSelect(this IObj self, IObj target)
        {
            return target != null && target.IsAlive() && target.IsSelectable(self);
        }

        public static bool CanAttack(this IObj self, IObj target)
        {
            return self.CanSelect(target);
        }

        public static bool CanInteract(this IObj self, IEntity target)
        {
            return !IsNull(target) 
                && (target.operId > 0)
                && (target.camp == 0 || target.camp == CVar.NPC_CAMP || target.camp == self.camp || !target.IsAlive());
        }

        public static IObj GetTargetGroup(this IObj self, IObj target, CFG_SubSk subSk)
        {
            IObj ret;
            var list = self.GetHittingTargets(target, subSk.Target);
            if (list.Count == 1) {
                ret = list[0];
                TargetAlg.ReleasePool(list);
            } else {
                ret = new TargetGroup(list, target.coord, self.L);
            }
            return ret;
        }

        public static void ChangeDura(this Human self, CFG_Weapon item, int change)
        {
            item.ChangeDura(change);
            var dura = item.Dura.GetValue();
            var ammo = item.Ammo.GetValue();
            self.L.DuraChanged(self, new DuraChange(item.id, item.dat, dura, ammo, change));
        }

        public static void DoMove(this IMovable self, Vector direction, float rate, bool towards)
        {
            if (self != null && self.IsAlive()) {
                if (towards) {
                    self.MoveTowards(direction, rate);
                } else {
                    if (self.OnFSMEvent(EVENT.ENTER_MOVE)) {
                        self.MoveTo(direction, 1);
                    }
                }
            }
        }

        /// <summary>
        /// 是否可主动中断动作
        /// </summary>
        public static bool IsBreakable(this IActor self, IAction newAction = null)
        {
            if (!self.Content.idle) {
                var action = self.Content.action;
                if (newAction != action) {
                    if (action.mode == ACTMode.Fin2Move) return false;
                    if (action.mode == ACTMode.Suc2Move && self.Content.busy) return false;
                }
            }

            return true;
        }

        public static void DoAction(this IActor self, CFG_Weapon weapon, IAction action, IObj target, ACTOper oper = ACTOper.Loop)
        {
            if (self != null && self.IsAlive()) {
                if (action != null && self.IsLocal()) {
                    if (!self.IsBreakable(action)) return;

                    var currentState = self.fsm.activated ?
                        (FSM_STATE)self.fsm.GetCurrentState().id : FSM_STATE.IDLE;
                    var actionState = action is CFG_Skill ? FSM_STATE.ACTION : FSM_STATE.INTERACT;
                    if (action.mode != ACTMode.FreeMove) {
                        // 目标状态变化才需要做转换，同状态下不应该失败。
                        if (currentState != actionState) {
                            if (actionState == FSM_STATE.ACTION) {
                                if (!self.OnEvent((int)EVENT.ENTER_ACTION)) return;
                            } else {
                                if (!self.OnEvent((int)EVENT.ENTER_GATHER)) return;
                            }
                        }
                    } else {
                        //if (!self.Content.idle) return;

                        if (currentState != actionState) {
                            // 可移动中做的动作，要退出不一致的状态。
                            self.OnEvent((int)EVENT.LEAVE_ACTION);
                        }
                    }
                }
                // 放到后面来，以免｛ACTION->GATHER｝或｛GATHER->ACTION｝过程中重置该值
                self.Content.Init(weapon, action, target, oper);
            }
        }

        public static bool BreakAction(this IActor self)
        {
            if (self.BreakTimerOf(TTags.CAST, null) == 0) {
                self.Content.Uninit();
                self.Content.Finish();
                return true;
            }
            return false;
        }

        public static void FinishAction(this IActor self)
        {
            self.L.tmMgr.FinishOf(self, TTags.CAST, null);
        }

        /// <summary>
        /// 计算到目标之间的阻挡。
        /// </summary>
        public static IObj Raycast(this IObj who, IObj whom, IAction action)
        {
            Vector hitPos;
            var block = who.L.Raycast(who.coord, whom, action.blockLevel, out hitPos);
            if (block != null) {
                if (whom is LocateObj) {
                    whom.pos = hitPos;
                } else if (action.allowNullTar) {
                    whom = new NullTarget(hitPos, who.L);
                } else {
                    // 视线被遮挡
                    whom = null;
                }
            }

            return whom;
        }

        public static void AddHFSMState(this IFSMContext self, BaseState state)
        {
            self.fsm.AddState(state);
        }

        public static void AddHFSMEvent(this IFSMContext self, EVENT evt, BaseState src, BaseState dst, TransType type, StateTransfer transfer = null)
        {
            self.fsm.AddEvent((int)evt, src, dst, type, transfer);
        }

        public static bool GetAdvancedIdOfHealth(this ILiving self, IAction action, AdvancedCond cond, ref int advId)
        {
            advId = action.GetAdvancedId(cond, self.Health);
            return advId != action.id;
        }
    }
}
