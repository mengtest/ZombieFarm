using System.Collections;
using System.Collections.Generic;
using clientlib.net;
using UnityEngine;

namespace World.Control
{
    public class NWObjTrigger : NWObjSync
    {
        public NWObjTrigger(NWObjAction Action) : base(Action) { }

        public override void Read(INetMsg nm)
        {

        }

        public override void Write(INetMsg nm)
        {
            m_Action.Write(nm);
            var xObj = m_Action.GetTarget() as XObject;
            if (xObj != null) {
                nm.writeU32(xObj.status);
            } else {
                nm.writeU32(0);
            }
            nm.writeString(string.Empty);
        }

    }
}
