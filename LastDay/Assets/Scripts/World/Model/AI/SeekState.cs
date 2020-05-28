using System.Collections;
using System.Collections.Generic;
using ZFrame.HFSM;

namespace World
{
    public class HFSM_SeekState : BaseState
    {
        public override int id { get { return (int)FSM_STATE.SEEK; } }

        public override string ToString()
        {
            return string.Format("[寻找: id={0}]", id);
        }

        protected void WaitForNearer(IMovable mover, IObj target, float range)
        {
            var forward = (mover.coord - target.coord).normalized;
            mover.MoveTo(target.coord + forward * 0.1f, 1);
        }

        protected void WaitForFarther(IMovable mover, IObj target, float range)
        {
            Vector selfPos = mover.coord;
            Vector tarPos = target.coord;
            var forward = tarPos != selfPos ?
                Vector.Forward(tarPos, selfPos) : mover.forward * -1;

            range += target.GetRadius();

            mover.MoveTo(tarPos + forward * range, 1);
        }

        public override bool Update(IFSMContext context)
        {
            var actor = context as IActor;
            var mover = context as IMovable;

            var Content = actor.Content;

            Content.Prepare();
            var action = Content.action;
            var target = Content.currTarget;

            if (target != null && target.id != actor.id) {
                // 在做动作前判断距离
                if (mover != null) {
                    var midRange = (action.maxRange + action.minRange) / 2;

                    var ranging = mover.Ranging(target, action);

                    // 已抵达位置
                    if (ranging == 0) return false;

                    if (ranging < 0) {
                        // 等待远离目标
                        WaitForFarther(mover, target, midRange);
                    } else if (ranging > 0) {
                        // 等待靠近目标
                        WaitForNearer(mover, target, midRange);
                    }
                }
            } else {
                // 目标为空
                return false;
            }

            // 继续寻找
            return true;
        }
    }
}
