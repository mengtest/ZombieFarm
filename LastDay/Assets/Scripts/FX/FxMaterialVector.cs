using UnityEngine;
using System.Collections;

namespace FX
{
    public class FxMaterialVector : FxMaterial
    {
        [SerializeField]
        private Vector4 m_From = Vector4.zero, m_To = Vector4.zero;
        
        protected override void OnUpdate(float delta)
        {
            var c = Vector4.Lerp(m_From, m_To, m_Curve.Evaluate(time));
            m_Rdr.material.SetVector(m_NameID, c);
        }
    }
}
