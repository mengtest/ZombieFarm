using System.Collections;
using System.Collections.Generic;
using clientlib.net;
using UnityEngine;

namespace World.Control
{
    public class NWObjAttack : NWObjSync
    {
        public NWObjAttack(NWObjAction Action) : base(Action) { }

        public override void Write(INetMsg nm)
        {
            var human = m_Action.Obj as Human;
            var Weapon = m_Action.Weapon;
            if (human != null && Weapon != null) {
                nm.writeU32(Weapon.bag)
                  .writeU32(Weapon.idx)
                  .writeU32(Weapon.dat);
            } else {
                nm.writeU32(0).writeU32(0).writeU32(0);
            }
            m_Action.Write(nm);
            
            if (m_Action.targetId >= 0) {
                m_Action.vNext.Write(nm);
            }
        }

        public override void Read(INetMsg nm)
        {
            /*var bag =*/ nm.readU32();
            /*var pos =*/ nm.readU32();
            var dat = nm.readU32();

            m_Action.Acting = true;
            m_Action.ReadData(nm);

            if (m_Action.status == ObjAction.StartCast) {
                m_Action.TryLoadTool(dat);
            }

            m_Action.SyncObj();

            NWObjStat.ReadDataChange(nm, m_Action.Obj, m_Action.GetAction());
        }
        
    }
}
