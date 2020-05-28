using UnityEngine;
using System.Collections;

namespace FX
{
    public class FxMaterialScale : FxMaterial
    {
        [SerializeField]
        private Vector2 m_From = Vector2.one, m_To = Vector2.zero;
        
        protected override void OnUpdate(float delta)
        {
            var v = Vector2.Lerp(m_From, m_To, m_Curve.Evaluate(time));
            m_Rdr.material.SetTextureScale(m_Property, v);
        }

        protected override string m_DefProperty { get { return "_MainTex"; } }
    }
}
