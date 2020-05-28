using UnityEngine;
using System.Collections;

namespace FX
{
    public class FxMaterialColor : FxMaterial
    {
        [SerializeField]
        private Color m_From = Color.white, m_To = Color.black;
        
        protected override void OnUpdate(float delta)
        {
            var c = Color.Lerp(m_From, m_To, m_Curve.Evaluate(time));
            m_Rdr.material.SetColor(m_NameID, c);
        }

        protected override string m_DefProperty { get { return "_Color"; } }
    }
}
