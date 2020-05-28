//
//  GVar.cs
//  survive
//
//  Created by xingweizhen on 10/19/2017.
//
//

namespace World
{
    public class GVar
    {
        public readonly HFSM_IdleState IDLE = new HFSM_IdleState();
        public readonly HFSM_MoveState MOVE = new HFSM_MoveState();
        public readonly HFSM_SeekState SEEK = new HFSM_SeekState();
        public readonly HFSM_ActionState ACTION = new HFSM_ActionState();
        public readonly HFSM_InteractState INTERACT = new HFSM_InteractState();
        public readonly HFSM_RemoteState REMOTE = new HFSM_RemoteState();

        private System.Random m_Ran;

        public GVar(int seed)
        {
            m_Ran = new System.Random(seed);
        }

        public int NextInt(int max)
        {
            return m_Ran.Next(max);
        }

        /// <summary>
        /// 可以燃烧芦苇丛的技能标志
        /// </summary>
        public int SKILL_ID_BURN_REED;

        /// <summary>
        /// 宠物嗅觉激活间隔
        /// </summary>
        public int PET_SMELLING_ALERT_FREQ;
    }
}
