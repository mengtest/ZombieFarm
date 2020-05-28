using UnityEngine;
using System.Collections;

namespace FX
{
    public class FxBoneName : MonoBehaviour, IFxAnchor
    {
        [SerializeField]
        private FXPoint m_Root;

        [SerializeField]
        private string m_Bone;

		public FxAnchor GetAnchor(IFxHolder holder)
        {
            var root = FxBoneType.GetBone(holder, m_Root);
            if (root == null) {
                var mono = holder as MonoBehavior;
                if (mono) root = mono.transform;
            }

            var ret = root ? root.FindByName(m_Bone) : holder.bodyPoint;
            return new FxAnchor() { anchor = ret, offset = Vector3.zero };
        }
    }
}

