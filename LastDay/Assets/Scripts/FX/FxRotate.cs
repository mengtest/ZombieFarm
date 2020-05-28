using UnityEngine;
using UnityEngine.Serialization;
using System.Collections;

namespace FX
{
    public class FxRotate : FxAnimate
    {
        [SerializeField]
        [FormerlySerializedAs("axis")]
        private Vector3 m_Axis = Vector3.up;
        [SerializeField]
        private bool m_Global;

        private Quaternion m_Prev;

        private void Start()
        {
            m_Prev = transform.rotation;
        }

        protected override void OnUpdate(float delta)
        {
            if (m_Global) {
                transform.rotation = m_Prev;
                transform.RotateAround(transform.position, m_Axis, m_Speed * delta);
                m_Prev = transform.rotation;
            } else {
                transform.RotateAround(transform.position, m_Axis, m_Speed * delta);
            }
        }
    }
}