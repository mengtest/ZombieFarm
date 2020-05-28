using UnityEngine;
using System.Collections;

namespace FX
{
    public class FxScaling : FxAnimate
    {
        [SerializeField]
        private Vector3 m_Size = Vector3.one;
        [SerializeField]
        protected AnimationCurve m_Curve = AnimationCurve.Linear(0, 0, 1, 1);

        protected override void OnUpdate(float delta)
        {
            transform.localScale = m_Size * m_Curve.Evaluate(time);
        }        
    }
}
