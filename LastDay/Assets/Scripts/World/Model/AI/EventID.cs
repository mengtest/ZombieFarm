
using ZFrame.HFSM;

namespace World
{
    public enum FSM_STATE
    {
        IDLE, MOVE, SEEK, ACTION, INTERACT, REMOTE,
    }

    public enum EVENT
    {
        POP,
                
        ENTER_ACTION,
        ENTER_GATHER,
        ENTER_MOVE,
        ENTER_SEEK,

        LEAVING,

        LEAVE_ACTION,
        LEAVE_MOVE,
        PASSIVE,

        BREAK_ACTION,
    }

    public sealed class FSMTransition : IEventParam
    {
        public BaseState src { get; private set; }
        public BaseState dst { get; private set; }

        private FSMTransition() { }

        private static FSMTransition S = new FSMTransition();
        public static FSMTransition Apply(BaseState src, BaseState dst)
        {
            S.src = src;
            S.dst = dst;
            return S;
        }
        
    }
}
