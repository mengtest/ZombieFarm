using UnityEngine;
using System.Collections;

namespace FX
{
    public class FxMaterialFloat : FxMaterial
    {
        [SerializeField]
        private float m_From = 0f, m_To = 1f;
        
        protected override void OnUpdate(float delta)
        {
            var f = Mathf.Lerp(m_From, m_To, m_Curve.Evaluate(time));
            m_Rdr.material.SetFloat(m_NameID, f);
        }
    }
}
