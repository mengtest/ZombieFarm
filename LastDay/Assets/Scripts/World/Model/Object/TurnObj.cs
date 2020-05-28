using System.Collections;
using System.Collections.Generic;

namespace World
{
    public class TurnObj : LivingEntity, ITurnable
    {
        protected Vector m_LookForward;
        public virtual Vector turnForward {
            get { return m_LookForward; }
            set {
                value.y = 0;
                var newForward = Vector.R(value.normalized);
                // TODO add value changing tracker.
                m_LookForward = newForward;
                
            }
        }

        public void InitTurner()
        {
            m_LookForward = forward;
        }

        public virtual float GetAngularSpeed()
        {
            return currentAttrs[ATTR.Turn];
        }

        protected virtual void UpdateForward()
        {
            var tarFwd = turnForward;
            if (tarFwd != Vector.zero && tarFwd != forward) {
                var angularSpeed = GetAngularSpeed();
                forward = Vector.RotateTowards(forward, tarFwd, angularSpeed * CVar.FRAME_TIME, 1f);
                
                L.ObjTurning(this, null);
            }
        }
    }
}
