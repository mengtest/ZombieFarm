//
//  Living.cs
//  survive
//
//  Created by xingweizhen on 10/12/2017.
//
//

using ZFrame.HFSM;

namespace World
{
    public class Living : XObject, ILiving, IFSMContext
    {
        public Living() : base()
        {
            fsm = new HFSM(this);
            fsm.StateTransform += OnHFSMStateTransform;

            m_Health = new VarData();
        }

        private VarData m_Health;
        public VarData Health { get { return m_Health; } }
                
        public void InitLiving(CFG_Attr original, CFG_Attr current)
        {
            originalAttrs = original;
            currentAttrs = current;
            Health.Set((int)original[ATTR.Hp], (int)current[ATTR.Hp]);
        }

        public override bool IsAlive()
        {
            return !Health.IsNull();
        }

        public override bool IsNull()
        {
            if (disappear < 0) {
                return !IsAlive();
            } else {
                return base.IsNull();
            }
        }

        public virtual void Kill()
        {
            Health.Set(0, -1);
        }

        public override float GetAttr(ATTR attr)
        {
            return currentAttrs[attr];
        }

        public override float GetRawAttr(ATTR attr)
        {
            return originalAttrs[attr];
        }
        
        protected override void OnAttrChanged(int attrId, float oldValue, float newValue)
        {
            base.OnAttrChanged(attrId, oldValue, newValue);

            var attr = (ATTR)attrId;
            if (attr == ATTR.Hp) {
                Health.Set(Health.GetValue(), (int)currentAttrs[ATTR.Hp]);                
            }
        }

        public virtual int ChangeHp(VarChange inf)
        {
            int changed = 0;
            if (m_Ref == 0) {
                inf.value = -Health.GetValue();
            }
            changed = Health.Add(ref inf);
            L.HealthChanged(this, inf);
            return changed;
        }
        
        public HFSM fsm { get; private set; }

        protected virtual void OnHFSMStateTransform(BaseState src, BaseState dst)
        {
            L.FSMTransition(this, FSMTransition.Apply(src, dst));
        }
        
        public virtual bool OnEvent(int eventId)
        {
            return fsm.TransState(eventId);
        }
    }
}
