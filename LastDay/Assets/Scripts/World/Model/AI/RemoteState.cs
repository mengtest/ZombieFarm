using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using ZFrame.HFSM;

namespace World
{
    public class HFSM_RemoteState : BaseState
    {
        public override int id { get { return (int)FSM_STATE.REMOTE; } }

        public override string ToString()
        {
            return string.Format("[远端: id={0}]", id);
        }

        //private void UpdateForward(ITurnable turner, IObj target)
        //{
        //    if (target != null && target.id != 0 && target.id != turner.id) {
        //        var lookForward = (target.coord - turner.coord).normalized;
        //        turner.turnForward = lookForward;
        //    }
        //}

        //public override bool Update(IFSMContext context)
        //{
        //    var actor = context as IActor;
        //    var turner = context as ITurnable;

        //    var Content = actor.Content;
            
        //    if (turner != null) {
        //        if (Content.busy) {
        //            UpdateForward(turner, Content.currTarget);
        //        } else {
        //            UpdateForward(turner, null);
        //        }
        //    }
            
        //    return true;
        //}

        private static void CastAction(IActor bObj, bool instanly)
        {
            var action = bObj.Content.Start();
            var target = bObj.Content.currTarget;
            if (target != null) {
                action.ClampTarget(bObj, ref target);
                bObj.Content.currTarget = target;
            }
            
            Timer castTm = null;
            if (instanly) {
                castTm = bObj.NewTimer(bObj, target, action.cast).SetParam(action)
                   .SetEvent(null, TimerEvents.OnActionSuccess, null)
                   .SetIdentify(TTags.CAST, Timer.GenCasting(action.id, bObj.id));

                bObj.NewTimer(bObj, bObj, action.post).SetParam(action)
                    .SetEvent(null, TimerEvents.OnActionFinish, TimerEvents.OnActionBreak)
                    .SetIdentify(TTags.POST, Timer.GenPosting(action.id, bObj.id));

                if (bObj.Content.oper == ACTOper.OneShot) {
                    bObj.Content.Uninit();
                }
            } else {
                castTm = bObj.NewTimer(bObj, target, int.MaxValue, 1).SetParam(action)
                    .SetEvent(TimerEvents.OnActionWating, null, TimerEvents.OnActionWaitStop)
                    .SetIdentify(TTags.CAST, Timer.GenCasting(action.id, bObj.id));
            }

            action.OnStart(bObj);
            bObj.OnAction(action, target, ActProc.Start);
            bObj.L.ActionStart(bObj, castTm);
        }

        public static void PrepareAction(IActor bObj, CFG_Weapon Weapon, IAction Action, IObj Target, bool instanly)
        {
            var oper = bObj.Content.oper;
            if (oper == ACTOper.Cancelled) {
                oper = ACTOper.OneShot;
            } else {
                oper = Action.oper;
            }

            bObj.Content.Init(Weapon, Action, Target, oper);
            bObj.Content.Prepare();
            bObj.L.ActionReady(bObj, Action);

            CastAction(bObj, instanly);
        }
    }
}
