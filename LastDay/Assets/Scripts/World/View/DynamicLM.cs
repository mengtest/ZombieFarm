using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace World.View
{
    [RequireComponent(typeof(Renderer))]
    public class DynamicLM : MonoBehaviour
    {
        [SerializeField]
        private int m_LMIndex;

        [SerializeField]
        private Vector4 m_LMScaleOffset;

        [SerializeField]
        private int m_RTIndex;

        [SerializeField]
        private Vector4 m_RTScaleOffset;

        private void OnEnable()
        {
            LoadLMSettings();
        }

        [System.Diagnostics.Conditional(LogMgr.UNITY_EDITOR)]
        [ContextMenu("保存LightingMap信息")]
        private void SaveLMSettings()
        {
            Renderer rdr = GetComponent(typeof(Renderer)) as Renderer;
            m_LMIndex = rdr.lightmapIndex;
            m_LMScaleOffset = rdr.lightmapScaleOffset;

            m_RTIndex = rdr.realtimeLightmapIndex;
            m_RTScaleOffset = rdr.realtimeLightmapScaleOffset;
        }
        
        [ContextMenu("加载LightingMap信息")]
        private void LoadLMSettings()
        {
            Renderer rdr = GetComponent(typeof(Renderer)) as Renderer;
            rdr.lightmapIndex = m_LMIndex;
            rdr.lightmapScaleOffset = m_LMScaleOffset;

            rdr.realtimeLightmapIndex = m_RTIndex;
            rdr.realtimeLightmapScaleOffset = m_RTScaleOffset;
        }
    }
}
