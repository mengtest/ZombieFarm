//
//  ActionState.cs
//  survive
//
//  Created by xingweizhen on 10/20/2017.
//
//

using System.Collections;
using System.Collections.Generic;
using ZFrame.HFSM;

namespace World
{
    public class HFSM_ActionState : CommonState
    {
        public override int id { get { return (int)FSM_STATE.ACTION; } }

        public override string ToString()
        {
            return string.Format("[战斗: id={0}]", id);
        }

        public override void Enter(IFSMContext context)
        {
            var actor = context as IActor;
            if (actor != null) actor.Content.UnsetReady();
        }

        protected override void WaitForNearer(IMovable mover, IObj target, float range)
        {
            mover.MoveTo(target.coord, 1);
        }

        protected override void WaitForFarther(IMovable mover, IObj target, float range)
        {
            Vector selfPos = mover.coord;
            Vector tarPos = target.coord;
            var forward = tarPos != selfPos ?
                Vector.Forward(tarPos, selfPos) : mover.forward * -1;

            var vol = target as IVolume;
            if (vol != null) {
                range += Math.Max(vol.size.x, vol.size.z) / 2;
            }

            mover.MoveTo(tarPos + forward * range, 1);
        }

        protected override void WaitForTargetForward(ITurnable turner, IObj target)
        {
            turner.turnForward = turner.CalcForward(target);
        }
    }
}