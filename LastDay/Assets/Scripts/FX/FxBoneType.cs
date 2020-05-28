using UnityEngine;
using System.Collections;

namespace FX
{
    public class FxBoneType : MonoBehaviour, IFxAnchor
    {
        [SerializeField]
        private FXPoint point;
        [SerializeField]
        private Vector3 m_Offset;
        [SerializeField]
        private bool m_Forward = true;

		public FxAnchor GetAnchor(IFxHolder holder)
        {
            Transform ret = null;
			bool forward = m_Forward;
			if (point == FXPoint.Screen) {
				var go = GameObject.FindWithTag("FXCamera");
				ret = go ? go.transform : null;
			} else {
                ret = GetBone(holder, point);
                if (point == FXPoint.Weapon) forward = false;                
            }
			return new FxAnchor() { anchor = ret, offset = m_Offset, forward = forward };
        }

        public static Transform GetBone(IFxHolder holder, FXPoint point)
        {
            Transform ret = null;
            if (holder != null) {
                switch (point) {
                    case FXPoint.Weapon: ret = holder.firePoint; break;
                    case FXPoint.Body: ret = holder.bodyPoint; break;
                    case FXPoint.Foot: ret = holder.footPoint; break;
                    case FXPoint.Head: ret = holder.headPoint; break;
                    case FXPoint.Top: ret = holder.topPoint; break;
                    default: break;
                }
            }
            return ret;
        }
    }
}

