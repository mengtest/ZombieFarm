using UnityEngine;
using System.Collections;

namespace FX
{
    [RequireComponent(typeof(Renderer))]
    public abstract class FxMaterial : FxAnimate
    {
        [SerializeField]
        protected string m_Property;
        [SerializeField]
        protected AnimationCurve m_Curve = AnimationCurve.Linear(0, 0, 1, 1);

        protected int m_NameID;

        protected Renderer m_Rdr;
        
        private void Start()
        {
            m_NameID = Shader.PropertyToID(m_Property);
            m_Rdr = GetComponent<Renderer>();
            enabled = m_Rdr != null;
        }

        public override void Reset()
        {
            base.Reset();
#if UNITY_EDITOR
            if (!Application.isPlaying) {
                m_Property = m_DefProperty;
            }
#endif
        }
        
        protected virtual string m_DefProperty { get { return string.Empty; } }
    }
}
