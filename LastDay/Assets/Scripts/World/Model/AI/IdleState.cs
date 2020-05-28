//
//  IdleState.cs
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
    public class HFSM_IdleState : CommonState
    {
        public override int id { get { return (int)FSM_STATE.IDLE; } }

        public override string ToString()
        {
            return string.Format("[站立: id={0}]", id);
        }

        public override void Enter(IFSMContext context)
        {
            var mover = context as IMovable;
            mover.StopMoving();
        }

        protected override void WaitForTargetForward(ITurnable turner, IObj target)
        {
            turner.turnForward = turner.CalcForward(target);
        }
    }

}
