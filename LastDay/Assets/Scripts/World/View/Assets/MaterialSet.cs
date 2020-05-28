using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using World.Control;
using Object = UnityEngine.Object;

namespace World.View
{
    public class MaterialSet
    {
        public const string OUTLINE = " Outline";

        /// <summary>
        /// 原始材质
        /// </summary>
        private Material m_RawMat;

        private bool m_Outline;
        private Material m_NormMat, m_FadeMat, m_GridMat;

        public MaterialSet() { }

        private string m_Name;
        public MaterialSet(string name)
        {
            m_Name = name;
        }

        public MaterialSet(Material mat)
        {
            m_Name = mat.name;
            m_RawMat = mat;
            m_Outline = mat.shader.name.Contains(OUTLINE);
        }

        private Material GetRaw()
        {
            if (m_RawMat == null) {
                if (StageView.unlit) {
                    m_RawMat = Creator.objL.Get(m_Name + " Unlit", false) as Material;
                }
                if (m_RawMat == null) {
                    m_RawMat = Creator.objL.Get(m_Name, false) as Material;
                }

                if (m_RawMat != null) {
                    m_Outline = m_RawMat.shader.name.Contains(OUTLINE);
                }
            }
            return m_RawMat;
        }

        public Material GetNorm()
        {
            if (m_NormMat == null) {
                var rawMat = GetRaw();
                m_NormMat = new Material(rawMat) { name = rawMat.name + " Norm" };
                m_NormMat.SetKeyword("TOON_SIMULATE_POINTLIT", AssetCacher.pointlit);
                SwitchShader(m_NormMat, AssetCacher.outline);
            }
            return m_NormMat;
        }

        public Material GetFade()
        {
            if (m_FadeMat == null) {
                var rawMat = GetRaw();
                m_FadeMat = new Material(rawMat) { name = rawMat.name + " Fade" };
                //m_FadeMat.renderQueue = (int)UnityEngine.Rendering.RenderQueue.AlphaTest;
                m_FadeMat.SetKeyword("TOON_SIMULATE_POINTLIT", AssetCacher.pointlit);
                m_FadeMat.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.SrcAlpha);
                m_FadeMat.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.OneMinusSrcAlpha);
                SwitchShader(m_FadeMat, AssetCacher.outline);
            }
            return m_FadeMat;
        }

        public Material GetGrid()
        {
            if (m_GridMat == null) {
                var rawMat = GetRaw();
                m_GridMat = new Material(rawMat) { name = rawMat.name + " Grid" };
                m_GridMat.SetKeyword("TOON_SIMULATE_POINTLIT", AssetCacher.pointlit);
                m_GridMat.EnableKeyword(MatKWs.TOON_TRANSPARENT);
                SwitchShader(m_GridMat, AssetCacher.outline);
            }
            return m_GridMat;
        }

        public void Clear()
        {
            Object.Destroy(m_NormMat);
            Object.Destroy(m_FadeMat);
            Object.Destroy(m_GridMat);
        }

        private void SwitchShader(Material mat, bool outline)
        {
            if (!m_Outline) return;

            var has = mat.shader.name.IndexOf(OUTLINE, System.StringComparison.Ordinal);
            if ((has > 0) ^ outline) {
                Shader newShader = outline ?
                    Creator.objL.Get(mat.shader.name + OUTLINE) as Shader :
                    Creator.objL.Get(mat.shader.name.Substring(0, has)) as Shader;
                if (newShader) {
                    var renderQueue = mat.renderQueue;
                    mat.shader = newShader;
                    mat.renderQueue = renderQueue;
                }
            }
        }
        public void SetOutline()
        {
            if (m_NormMat) SwitchShader(m_NormMat, AssetCacher.outline);
            if (m_FadeMat) SwitchShader(m_FadeMat, AssetCacher.outline);
            if (m_GridMat) SwitchShader(m_GridMat, AssetCacher.outline);
        }
        public void SetPointlit()
        {
            if (m_NormMat) m_NormMat.SetKeyword("TOON_SIMULATE_POINTLIT", AssetCacher.pointlit);
            if (m_FadeMat) m_FadeMat.SetKeyword("TOON_SIMULATE_POINTLIT", AssetCacher.pointlit);
            if (m_GridMat) m_GridMat.SetKeyword("TOON_SIMULATE_POINTLIT", AssetCacher.pointlit);
        }
    }
}