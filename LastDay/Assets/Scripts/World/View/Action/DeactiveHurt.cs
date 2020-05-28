using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace World.View
{
    public class DeactiveHurt : MonoBehaviour, IHurtAction
    {
        [SerializeField][Range(0, 1)]
        private float m_HealthRate;

        [SerializeField]
        private Transform m_Target;

        void IHurtAction.ShowAction(ILiving living, ref VarChange Ch)
        {
            if (m_Target) m_Target.gameObject.SetActive(living.Health.GetRate() > m_HealthRate);
        }

        private void LateUpdate()
        {
            if (m_Target && !m_Target.gameObject.activeSelf) {
                m_Target.localScale = Vector3.zero;
            }
        }
    }
}
