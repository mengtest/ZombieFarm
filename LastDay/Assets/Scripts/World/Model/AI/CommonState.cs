//
//  CommonState.cs
//  survive
//
//  Created by xingweizhen on 11/6/2017.
//
//

using System.Collections;
using System.Collections.Generic;
using ZFrame.HFSM;

namespace World
{
    public abstract class CommonState : BaseState
    {
        protected virtual void WaitForNearer(IMovable mover, IObj target, float range) { }
        protected virtual void WaitForFarther(IMovable mover, IObj target, float range) { }
        protected virtual void WaitForTargetForward(ITurnable turner, IObj target) { }

        public override bool Update(IFSMContext context)
        {
            var actor = context as IActor;
            var turner = context as ITurnable;
            var mover = context as IMovable;

            var Content = actor.Content;

            // 动作进行中
            if (!Content.idle) {
                var currTarget = Content.currTarget;
                var skillTar = currTarget as SkillTarget;
                if (skillTar != null) {
                    skillTar.UpdateTarget();
                    currTarget = skillTar.target;
                }

                if (turner != null) {
                    if (currTarget != null && !actor.Equals(currTarget)) {
                        turner.turnForward = turner.CalcForward(currTarget);
                    }
                }

                return true;
            }

            // 无动作
            if (Content.invalid) {
                return true;
            }
            
            Content.Prepare();
            var action = Content.action;
            if (action == null) return true;

            var target = Content.currTarget;
            if (target != null && target.id != actor.id) {
                // 在做动作前判断距离
                if (mover != null) {
                    var midRange = (action.maxRange + action.minRange) / 2;

                    var ranging = mover.Ranging(target, action);
                    if (ranging < 0) {
                        // 等待远离目标
                        WaitForFarther(mover, target, midRange);
                        Content.UnsetReady();
                        if (Content.prefab != null) {
                            actor.L.ActionStop(actor, Content.prefab);
                        }
                        return true;
                    }

                    if (ranging > 0) {
                        // 等待靠近目标
                        WaitForNearer(mover, target, midRange);
                        Content.UnsetReady();
                        if (Content.prefab != null) {
                            actor.L.ActionStop(actor, Content.prefab);
                        }
                        return true;
                    }

                    if (mover.GetMovingSpeed() > 0) {
                        mover.StopMoving();
                    }
                    SetActionReady(context);
                }

                if (turner != null) {
                    WaitForTargetForward(turner, target);
                    if (!turner.IsFaceTo(target, action)) return true;
                }
            } else {
                if (mover != null && action.mode != ACTMode.FreeMove && mover.GetMovingSpeed() > 0) {
                    mover.StopMoving();
                }
                SetActionReady(context);
            }

            if (Content.IsReady()) {
                if (!Content.IsCooling()) {
                    CastAction(actor);
                } else if (action.oper != ACTOper.Loop) {
                    // 非循环操作的技能未就绪时应立即被取消
                    Content.Cancel();
                }
            }

            return true;
        }

        protected static void CastAction(IActor bObj)
        {
            var action = bObj.Content.Start();
            var usable = action.UsableFor(bObj);
            if (!usable) {
                // 更换为装填技能
                var Reload = bObj.IGetAction(0);
                if(Reload != null) {
                    bObj.L.ActionStop(bObj, action);

                    usable = true;
                    action = bObj.Content.Start(Reload);
                    bObj.Content.currTarget = action.TargetFor(bObj);
                } else {
                    bObj.Content.currTarget = null;
                }
            }

            var target = bObj.Content.currTarget;
            if (target != null) {
                action.ClampTarget(bObj, ref target);
                var skill = action as CFG_Skill;
                if (skill != null) {
                    if (action.oper == ACTOper.Charged && (target == null || target.id != 0 || target is NullTarget)) {
                        // 蓄力中持续更新目标
                        target = new SkillTarget(bObj, skill, target);
                    }
                }
                bObj.Content.currTarget = target;

                var living = target as ILiving;
                if (living != null) {
                    var advId = action.id;
                    if (living.GetAdvancedIdOfHealth(action, AdvancedCond.onHpPercent, ref advId)
                        || living.GetAdvancedIdOfHealth(action, AdvancedCond.inHpPercent, ref advId)
                        || living.GetAdvancedIdOfHealth(action, AdvancedCond.onHp, ref advId)
                        || living.GetAdvancedIdOfHealth(action, AdvancedCond.inHp, ref advId)) {
                        action = CFG_Action.Load(advId);
                    }
                }
            }

            Timer castTm = null;
            if (action.oper == ACTOper.Charged) {
                // 蓄力类动作
                castTm = bObj.NewTimer(bObj, target, int.MaxValue, 1).SetParam(action)
                    .SetEvent(TimerEvents.OnActionCharging, null, TimerEvents.OnActionCharged)
                    .SetIdentify(TTags.CAST, Timer.GenCasting(action.id, bObj.id));
            } else {
                if (action.cast == 0 && target != null) {
                    // 瞬发的技能，立即判断是否有阻挡
                    target = bObj.Raycast(target, action);
                }

                // 正常动作
                castTm = bObj.NewTimer(bObj, target, action.cast).SetParam(action)
                    .SetEvent(null, TimerEvents.OnActionSuccess, null)
                    .SetIdentify(TTags.CAST, Timer.GenCasting(action.id, bObj.id));

                bObj.NewTimer(bObj, target, action.post).SetParam(action)
                    .SetEvent(null, TimerEvents.OnActionFinish, TimerEvents.OnActionBreak)
                    .SetIdentify(TTags.POST, Timer.GenPosting(action.id, bObj.id));
            }

            action.OnStart(bObj);
            bObj.OnAction(action, target, ActProc.Start);
            bObj.L.ActionStart(bObj, castTm);

            if (bObj.Content.oper == ACTOper.OneShot || !usable) {
                bObj.Content.Uninit();
            }

            if (action.oper != ACTOper.Charged && action.cast == 0) {
                // 瞬发的技能立即结束
                castTm.Finish();
            }
        }

        protected static void SetActionReady(IFSMContext context)
        {
            var behavior = (IActor)context;
            var content = behavior.Content;
            var skill = content.action;
            if (content.SetReady(behavior.L.frameIndex + skill.ready)) {
                behavior.L.ActionReady(behavior, skill);
            }
        }
    }
}
