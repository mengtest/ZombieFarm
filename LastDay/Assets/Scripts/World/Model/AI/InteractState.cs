//
//  GatherState.cs
//  survive
//
//  Created by xingweizhen on 11/3/2017.
//
//

namespace World
{
    public class HFSM_InteractState : HFSM_ActionState
    {
        public override int id { get { return (int)FSM_STATE.INTERACT; } }

        public override string ToString()
        {
            return string.Format("[采集: id={0}]", id);
        }
    }
}
