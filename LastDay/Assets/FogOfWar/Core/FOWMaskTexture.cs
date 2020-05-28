using UnityEngine;
using System.Collections;

namespace ASL.FogOfWar
{
    /// <summary>
    /// 战争迷雾纹理类
    /// </summary>
    internal class FOWMaskTexture
    {
        private enum UpdateMark
        {
            None,
            Changed,
            EndUpdate,
        }

        /// <summary>
        /// 战争迷雾纹理：R通道叠加所有已探索区域，G通道为当前更新的可见区域，B通道为上一次更新的可见区域
        /// </summary>
        public Texture2D texture {
            get { return m_MaskTexture; }
        }

        private Texture2D m_MaskTexture;

        private byte[] m_MaskCache;
        //private byte[,] m_Visible;
        private Color[] m_ColorBuffer;

        //private bool m_IsUpdated;
        private UpdateMark m_UpdateMark;

        private int m_Width;
        private int m_Height;

        public FOWMaskTexture(int width, int height)
        {
            var zoom = FogOfWarEffect.Instance.zoom;
            m_Width = width * zoom;
            m_Height = height * zoom;
            m_MaskCache = new byte[m_Width * m_Height];
            m_ColorBuffer = new Color[m_Width * m_Height];

            m_MaskTexture = GenerateTexture();
        }

        public void SetAsVisible(int x, int y, byte cache = 15)
        {
            m_MaskCache[y * m_Width + x] = cache;
            m_UpdateMark = UpdateMark.Changed;
        }

        public void MarkAsUpdated()
        {
            if (m_UpdateMark == UpdateMark.Changed) {
                for (int i = 0; i < m_Width; i++) {
                    for (int j = 0; j < m_Height; j++) {
                        var index = j * m_Width + i;
                        var cache = m_MaskCache[index];
                        Color origin = m_ColorBuffer[index];
                        origin.r = Mathf.Clamp01(origin.r + origin.g);
                        origin.b = origin.g;
                        origin.g = cache != 0 ? 1 : 0;
                        m_ColorBuffer[index] = origin;
                        m_MaskCache[index] = 0;
                    }
                }
                m_UpdateMark = UpdateMark.EndUpdate;
            }
        }

        public bool IsVisible(int x, int y)
        {
            if (x < 0 || x >= m_Width || y < 0 || y >= m_Height)
                return false;
            return m_ColorBuffer[y * m_Width + x].g > 0.5f;
            //return m_Visible[x, y] == 1;
        }

        public bool IsDirty() { return m_UpdateMark == UpdateMark.EndUpdate; }
        public bool IsIdle() { return m_UpdateMark == UpdateMark.None; }

        public bool RefreshTexture()
        {
            UnityEngine.Profiling.Profiler.BeginSample("FOW:Apply Texture");
            m_MaskTexture.SetPixels(m_ColorBuffer);
            m_MaskTexture.Apply();
            UnityEngine.Profiling.Profiler.EndSample();

            m_UpdateMark = UpdateMark.None;
            return true;
        }

        public void Release()
        {
            if (m_MaskTexture != null)
                Object.Destroy(m_MaskTexture);
            m_MaskTexture = null;
            m_MaskCache = null;
            m_ColorBuffer = null;
            //m_Visible = null;
        }

        private Texture2D GenerateTexture()
        {
            Texture2D tex = new Texture2D(m_Width, m_Height, TextureFormat.RGB24, false) {
                wrapMode = TextureWrapMode.Clamp
            };
            for (int i = 0; i < m_ColorBuffer.Length; ++i) {
                m_ColorBuffer[i] = Color.red;
            }
            tex.SetPixels(m_ColorBuffer);
            tex.Apply();
            
            return tex;
        }
    }
}