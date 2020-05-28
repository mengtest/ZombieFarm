using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace World
{
    [CreateAssetMenu(menuName = "资源库/地图数据")]
    public class MapData : ScriptableObject
    {
        private const short INVALID_GRID = -1;

        [SerializeField, HideInInspector]
        private int m_Width, m_Height;
        public int width {  get { return m_Width; } }
        public int height { get { return m_Height; } }

        [SerializeField, HideInInspector]
        private short[] m_Data;
        public short this[int x, int y] {
            get {
                var index = y * m_Width + y;
                return index < m_Data.Length ? m_Data[index] : INVALID_GRID;
            }
        }

        public void ReadFromCSV(System.IO.StringReader reader)
        {
            var list = new List<short>();
            int value = 0;
            bool flag = false;
            int x = 0, y = 0;
            for (; ; ) {
                int code = reader.Read();
                if (code < 0) break;

                var c = (char)code;
                if (char.IsDigit(c)) {
                    flag = true;
                    value = value * 10 + (c - '0');
                } else if (c == ' ' || c == '\t') {
                    continue;
                } else {
                    // 结束组装数字
                    if (flag) {
                        list.Add((short)value);
                        value = 0;
                        y += 1;
                    }
                    if (c == '\r' || c == '\n') {
                        // 换行
                        if (flag) {
                            m_Height = y;
                            y = 0;
                            x += 1;
                        }
                    } else {

                    }
                    flag = false;
                }
            }
            m_Width = x;

            m_Data = list.ToArray();
        }

        public void BuildTexture(ref Texture2D tex, Color[] steps)
        {
            tex = new Texture2D(m_Width, m_Height, TextureFormat.RGB24, false) {
                filterMode = FilterMode.Point,
            };
            for (int i = 0; i < m_Data.Length; ++i) {
                int y = m_Height - 1 - i / m_Width, x = i % m_Width;
                var value = m_Data[i];
                var c = Color.white;
                for (int n = 0; n < steps.Length; ++n) {
                    if ((value & (1 << n)) != 0) {
                        c *= steps[n];
                    }
                }
                tex.SetPixel(x, y, c);
            }
            tex.Apply();
        }
    }

}
