using System.Collections;
using System.Collections.Generic;

namespace World
{
    public class Pet : Role
    {
        public override bool IsLocal() { return true; }

        protected override void InitFSM()
        {
            // 视为本地对象，但是使用远端的ai
            this.AddHFSMState(L.G.REMOTE);
            fsm.Startup(L.G.REMOTE);
        }

        public override bool IsSelectable(IObj by)
        {
            return false;
        }
    }
}
