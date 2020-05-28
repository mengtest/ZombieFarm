using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace ASL.FogOfWar
{
    /// <summary>
    /// 战争迷雾屏幕特效渲染器
    /// </summary>
    internal class FOWRenderer
    {

        private Material m_EffectMaterial;
        private Material m_BlurMaterial;
        private Color m_FogColor;

        /// <summary>
        /// 世界空间到迷雾投影空间矩阵
        /// </summary>
        private Matrix4x4 m_WorldToProjector;

        private int m_BlurInteration;

        public event System.Action<Texture, Material> onFogTexUpdated;


        public FOWRenderer(Material effect, Shader blurShader, Vector3 position, float xSize, float zSize, Color fogColor, float blurOffset, int blurInteration)
        {
            m_EffectMaterial = effect;
            m_FogColor = fogColor;

            if (blurShader && blurInteration > 0 && blurOffset > 0)
            {
                m_BlurMaterial = new Material(blurShader);
                m_BlurMaterial.SetFloat("_Offset", blurOffset);
            }
            
            m_BlurInteration = blurInteration;
        }

        public void UpdateBlurParams(Color fogColor, float blurOffset, int blurInteration)
        {
            m_FogColor = fogColor;
            m_BlurInteration = blurInteration;
        }

        private RenderTexture rt;
        /// <summary>
        /// 渲染战争迷雾
        /// </summary>
        /// <param name="camera"></param>
        /// <param name="src"></param>
        /// <param name="dst"></param>
        public void RenderFogOfWar(Camera camera, Texture2D fogTexture)
        {
            if (m_BlurMaterial && fogTexture && fogTexture.filterMode != FilterMode.Point)
            {
                //RenderTexture rt = RenderTexture.GetTemporary(fogTexture.width, fogTexture.height, 0);
                RenderTexture.ReleaseTemporary(rt);
                rt = RenderTexture.GetTemporary(fogTexture.width, fogTexture.height, 0);
                Graphics.Blit(fogTexture, rt, m_BlurMaterial);
                for (int i = 0; i <= m_BlurInteration; i++)
                {
                    RenderTexture rt2 = RenderTexture.GetTemporary(fogTexture.width / 2, fogTexture.height / 2, 0);
                    Graphics.Blit(rt, rt2, m_BlurMaterial);
                    RenderTexture.ReleaseTemporary(rt);
                    rt = rt2;
                }

                if (onFogTexUpdated != null) onFogTexUpdated.Invoke(rt, m_BlurMaterial);

                m_EffectMaterial.SetTexture("_MainTex", rt);
                m_EffectMaterial.SetColor("_FogColor", m_FogColor);

            }
            else
            {
                if (onFogTexUpdated != null) onFogTexUpdated.Invoke(fogTexture, null);
            }
        }

        /// <summary>
        /// 设置当前迷雾和上一次更新的迷雾的插值
        /// </summary>
        /// <param name="fade"></param>
        public void SetFogFade(float fade)
        {
            m_EffectMaterial.SetFloat("_MixValue", fade);
        }

        public void Release()
        {
            if (m_BlurMaterial)
                Object.Destroy(m_BlurMaterial);
            m_EffectMaterial = null;
            m_BlurMaterial = null;
            if(rt != null)
                RenderTexture.ReleaseTemporary(rt);
        }
    }
}