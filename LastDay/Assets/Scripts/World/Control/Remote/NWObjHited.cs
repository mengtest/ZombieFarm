using System.Collections;
using System.Collections.Generic;
using clientlib.net;
using UnityEngine;

namespace World.Control
{
    public class NWObjHited : IFullMsg
    {
        public IObj Obj { get; private set; }
        private NWVector vSrc;
        private IConfig m_Cfg;
        private NWVector vHitPos;

        public bool IsDirty()
        {
            return Obj != null;
        }
        
        public void Clear()
        {
            Obj = null;
        }

        public void Read(INetMsg nm)
        {
            var id = nm.readU32();
            var actionId = nm.readU32();
            IAction Action = null;
            Action = CFG_Action.Load(actionId);
            /*var tarId =*/ nm.readU32();
            vHitPos.Read(nm);

            Obj = StageCtrl.L.FindById(id);
            //var Tar = StageCtrl.L.FindById(tarId);

            NWObjStat.ReadDataChange(nm, Obj, Action);
        }

        public void Write(INetMsg nm)
        {
            nm.writeU32(Obj.id);
            vSrc.Write(nm);
            nm.writeU32(m_Cfg.id);
            vHitPos.Write(nm);
        }

        public void SetHited(IObj atker, IConfig cfg, IEntity target)
        {
            Obj = atker;
            var entity = atker as IEntity;
            vSrc = new NWVector() {
                coord = atker.coord, forward = entity != null ? entity.forward : Vector.zero,
            };

            m_Cfg = cfg;
            
            vHitPos = new NWVector() {
                coord = target.coord, forward = target.forward,
            };
        }
    }
}
