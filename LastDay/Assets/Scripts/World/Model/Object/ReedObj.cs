using System.Collections;
using System.Collections.Generic;

namespace World
{
    public class ReedObj : XObject
    {
        public int group { get; private set; }

        public void InitReedbed(int group)
        {
            this.group = group;
        }
        
        public override bool IsAlive()
        {
            return true;
        }

        public override bool IsNull()
        {
            return false;
        }

        public override bool IsSelectable(IObj by)
        {
            return false;
        }
    }
}
