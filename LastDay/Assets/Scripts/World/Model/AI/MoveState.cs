//
//  MoveState.cs
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
    public class HFSM_MoveState : CommonState
    {
        public override int id { get { return (int)FSM_STATE.MOVE; } }
        
        public override bool Update(IFSMContext context)
        {
            base.Update(context);

            var mover = context as IMovable;
            return mover.destination != mover.coord;
        }

        public override string ToString()
        {
            return string.Format("[移动: id={0}]", id);
        }
    }
}
