using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace World.View
{
    [RequireComponent(typeof(Projector))]
    public class RoleProjector : MonoBehaviour
    {
        public readonly int IntensityHash = Shader.PropertyToID("_Intensity");
        
        [SerializeField]
        private AnimationCurve m_Intensity;

        [SerializeField]
        private Gradient m_LightColor;
        
        private Material m_ProjMat;

        private float m_CachedIntensity;
        private Color m_CachedColor;

        private void Awake()
        {
            var proj = GetComponent(typeof(Projector)) as Projector;
            m_ProjMat = new Material(proj.material);
            proj.material = m_ProjMat;

            m_CachedIntensity = m_ProjMat.GetFloat(IntensityHash);
            m_CachedColor = m_ProjMat.GetColor(ShaderIDs.Color);
        }

        private void OnEnable()
        {
            DayNightView.Instance.onValueChanged += OnDayNightChanged;
        }

        private void OnDisable()
        {
            DayNightView.Instance.onValueChanged -= OnDayNightChanged;
        }

        private void OnDayNightChanged(float progress)
        {
            var intensity = m_Intensity.Evaluate(progress);
            var color = m_LightColor.Evaluate(progress);

            if (m_CachedIntensity != intensity) {
                m_CachedIntensity = intensity;
                m_ProjMat.SetFloat(IntensityHash, intensity);
            }

            if (m_CachedColor != color) {
                m_CachedColor = color;
                m_ProjMat.SetColor(ShaderIDs.Color, color);
            }
        }
    }
}

