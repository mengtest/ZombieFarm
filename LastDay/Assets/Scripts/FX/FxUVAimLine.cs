using UnityEngine;
using System.Collections;
using FMOD.Studio;

namespace FX
{
    public class FxUVAimLine : MonoBehavior
    {
        public Transform target;
        public Vector2 scrollSpeed = Vector2.up;
        public bool ignoreTimescale;

        private float m_Time;
        private Renderer m_Rdr;

        private void OnEnable()
        {
            m_Time = 0;
            if (target == null) target = transform;
            if (target) m_Rdr = target.GetComponent(typeof(Renderer)) as Renderer;
        }

        // Update is called once per frame
        private void Update()
        {
            if (m_Rdr) {
                m_Rdr.material.mainTextureOffset = scrollSpeed * m_Time;
            }

            m_Time += ignoreTimescale ? Time.unscaledDeltaTime : Time.deltaTime;
        }

    }
}
