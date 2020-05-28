//
//  Player.cs
//  survive
//
//  Created by xingweizhen on 10/12/2017.
//
//

namespace World
{
    public sealed class Player : Human
    {
        public Player() : base()
        {
        }
        
        private Vector m_RoundCoord = Vector.zero;
        private Vector grid { get { return m_RoundCoord; } }

        public override Vector pos {
            get { return base.pos; }

            set {
                base.pos = value;
                var rcoord = m_RoundCoord;
                m_RoundCoord.x = (int)(coord.x + 0.5f);
                m_RoundCoord.z = (int)(coord.z + 0.5f);
                if (rcoord != m_RoundCoord) {
                    L.GridChange(this, rcoord);
                }
            }
        }
        
        public TARFilter autoTargetFilter;
        public int autoTargetAmount = 0;
        
        public override bool IsLocal()
        {
            return true;
        }

        public override bool IsNull()
        {
            return false;
        }
        
        public override void OnAction(IAction action, IObj target, ActProc proc)
        {
            base.OnAction(action, target, proc);
            switch (proc) {
                case ActProc.Start:
                    // 玩家自己在动作开始时保持移动模式为“前方”
                    // 会影响自动锁定交互目标时的判定
                    m_Towards = true;
                    break;
            }

        }
    }
}
