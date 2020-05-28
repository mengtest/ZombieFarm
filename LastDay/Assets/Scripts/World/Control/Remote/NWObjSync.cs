using System.Collections;
using System.Collections.Generic;
using clientlib.net;
using UnityEngine;

namespace World.Control
{
    using View;

    public class NWObjSync : IFullMsg
    {
        protected NWObjAction m_Action;
        public NWObjSync(NWObjAction Action)
        {
            m_Action = Action ?? new NWObjAction();
        }

        public override string ToString()
        {
            return m_Action.ToString();
        }

        public bool IsDirty()
        {
            return m_Action.IsDirty();
        }

        public void Clear()
        {
            m_Action.Clear();
        }

        public virtual void Write(INetMsg nm)
        {
            m_Action.Write(nm);
            // 以下为客户端自定义同步数据
            nm.writeU32(m_Action.Weapon != null ? m_Action.Weapon.dat : 0);
            //nm.writeU32(m_Action.status > ObjAction.Pick ? m_Action.action : 0);
        }

        public virtual void Read(INetMsg nm)
        {
            m_Action.Acting = false;
            m_Action.ReadData(nm);
            var dat = nm.readU32(); if (dat > 0) m_Action.TryLoadTool(dat);
            //var action = nm.readU32(); if (action > 0) m_Action.SetAction(action);

            m_Action.SyncObj();
        }
    }
}
