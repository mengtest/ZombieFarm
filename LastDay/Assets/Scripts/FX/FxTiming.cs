using UnityEngine;
using System.Collections;

namespace FX
{
    public class FxTiming : MonoBehavior
    {
        [SerializeField]
        private bool m_IgnoreTimeScale;

        private FxCtrl m_Ctrl;
        public bool ignoreTimeScale { get { return m_Ctrl ? m_Ctrl.ignoreGamePause : m_IgnoreTimeScale; } }

        protected float time;
        protected float deltaTime {
            get {
                return m_Ctrl ? m_Ctrl.deltaTime :
                    (m_IgnoreTimeScale ? Time.unscaledDeltaTime : Time.deltaTime);
            }
        }

        protected virtual void Awake()
        {
            m_Ctrl = GetComponentInParent<FxCtrl>();
        }

        public virtual void Reset() { }
    }
}
