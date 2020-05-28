//
//  TimerEvents.cs
//  survive
//
//  Created by xingweizhen on 10/19/2017.
//
//

namespace World
{
    public static class TimerEvents
    {
        /// <summary>
        /// 动作成功
        /// </summary>
        public static readonly TimerHandler OnActionSuccess = (tm, n) => {
            var actor = (IActor)tm.who;
            var action = (IAction)tm.param;

            if (action.cast > 0 && tm.whom != null) {
                var newTar = tm.who.Raycast(tm.whom, action);
                if (newTar != null) {
                    tm.SetTarget(newTar);
                } else {
                    return false;
                }
            }
            
            actor.Content.Success();
            actor.OnAction(action, tm.whom, ActProc.Success);
            actor.L.ActionSuccess(actor, tm);

            action.OnSuccess(actor, tm.whom);
            return true;
        };

        /// <summary>
        /// 动作完成了
        /// </summary>
        public static readonly TimerHandler OnActionFinish = (tm, n) => {
            var actor = (IActor)tm.who;
            var action = (IAction)tm.param;
            
            actor.Content.Finish();
            actor.OnAction(action, tm.whom, ActProc.Finish);
            tm.who.L.ActionFinish(tm.who, tm);

            action.OnFinish(actor, tm.whom);
            return true;
        };

        /// <summary>
        /// 动作被中断
        /// </summary>
        public static readonly TimerHandler OnActionBreak = (tm, n) => {
            var actor = (IActor)tm.who;
            var action = (IAction)tm.param;
            
            actor.Content.Uninit();
            actor.Content.Finish();
            actor.OnAction(action, tm.whom, ActProc.Break);
            tm.who.L.ActionBreak(tm.who, tm);
            return true;
        };

        /// <summary>
        /// 动作蓄力中
        /// </summary>
        public static readonly TimerHandler OnActionCharging = (tm, n) => {
            var actor = (IActor)tm.who;
            var action = (IAction)tm.param;

            // 蓄力中...
            if (actor.Content.prefab != null) return true;
            
            // 已停止蓄力
            var frameIndex = actor.L.frameIndex;
            if (tm.value == 0) {
                var target = ObjectExt.GetRefObj(tm.whom);
                if (target == null) return false;
                
                // 蓄力时间未达到前摇，中断
                if (tm.beginning + action.cast > frameIndex) return false;
                
                tm.Recycle(false, false);
                if (OnActionSuccess(tm, n) && tm.whom != null) {
                    // 施法成功后设置后摇时间
                    tm.SetValue(frameIndex + (action.post - action.cast));
                    return true;
                }
                
                // 施法失败，中断
                return false;
            }

            // 等待后摇结束
            if (tm.value > frameIndex) return true;
            
            // 达到了后摇时间，动作结束
            tm.SetValue(-1);
            return false;
        };

        public static readonly TimerHandler OnActionCharged = (tm, n) => {
            if (tm.value < 0) {
                // 后摇已完成
                OnActionFinish(tm, n);
            } else {
                OnActionBreak(tm, n);
            }

            return true;
        };

        /// <summary>
        /// 动作等待中
        /// </summary>
        public static readonly TimerHandler OnActionWating = (tm, n) => {
            var actor = (IActor)tm.who;
            var action = (IAction)tm.param;

            var content = actor.Content;
            if (content.prefab == null) {
                var frameIndex = actor.L.frameIndex;
                if (tm.value == 0) {
                    tm.Recycle(false, false);
                    tm.SetValue(frameIndex + (action.post - action.cast));
                } else if (tm.value <= frameIndex) {
                    tm.SetValue(-1);
                    return false;
                }
            }

            return true;
        };

        public static readonly TimerHandler OnActionWaitStop = (tm, n) => {
            if (tm.value < 0) {
                // 后摇已完成
                OnActionFinish(tm, n);
            } else {
                OnActionBreak(tm, n);
            }

            return true;
        };
    }
}
