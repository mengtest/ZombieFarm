using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace World.View
{
    using Control;

    public interface IFOWStatus
    {
        bool active { get; set; }
    }

    public class StageFOWData : MonoBehaviour, ASL.FogOfWar.IFOWMapData
    {
        private const byte EDGE_R = 1;
        private const byte EDGE_D = 2;
        private const byte EDGE_L = 4;
        private const byte EDGE_U = 8;
        private const byte EDGE_VERT = EDGE_U | EDGE_D;
        private const byte EDGE_HORI = EDGE_L | EDGE_R;

        public int width { get; private set; }
        public int height { get; private set; }
        private byte[][] m_MapData;

        public byte this[int i, int j] { get { return m_MapData[i][j]; } }

        public bool isPregeneration { get { return false; } }

        [SerializeField]
        private Renderer m_BlockMap;

        private void Awake()
        {
#if UNITY_EDITOR
            m_BlockMap.material = new Material(Shader.Find("Particles/Additive"));
#endif
        }

        private void OnDestroy()
        {

        }

        [System.Diagnostics.Conditional(LogMgr.UNITY_EDITOR)]
        private void SetMaskPixel(int x, int y, Color color, int multi = 0)
        {
            var tex = m_BlockMap.material.mainTexture as Texture2D;
            if (multi == 0) {
                tex.SetPixel(x, y, color);
            } else {
                var c = tex.GetPixel(x, y);
                if (multi > 0) {
                    tex.SetPixel(x, y, c + color);
                } else {
                    tex.SetPixel(x, y, c - color);
                }
            }
        }

        [System.Diagnostics.Conditional(LogMgr.UNITY_EDITOR)]
        private void ApplyMaskTex()
        {
            var tex = m_BlockMap.material.mainTexture as Texture2D;
            tex.Apply();
        }

        private void SetCoord(int x, int y, byte value)
        {
            if (x < 0 || x >= width || y < 0 || y >= height) return;

            m_MapData[x][y] = value;
        }

        private void BitOrCoord(int x, int y, byte value)
        {
            if (x < 0 || x >= width || y < 0 || y >= height) return;

            m_MapData[x][y] |= value;
        }

        private void BitAndCoord(int x, int y, byte value)
        {
            if (x < 0 || x >= width || y < 0 || y >= height) return;

            unchecked {
                m_MapData[x][y] &= (byte)~value;
            }
        }

        public bool IsObstacle(int i, int j, int centX, int centY)
        {
            var zoom = FogOfWarEffect.Instance.zoom;
            var extend = FogOfWarEffect.Instance.extend;

            i /= zoom; j /= zoom; centX /= zoom; centY /= zoom;
            if (i == centX && j == centY) return false;

            i -= extend; j -= extend; centX -= extend; centY -= extend;
            if (i < 0 || i >= width || j < 0 || j >= height) return false;
            
            var value = m_MapData[i][j];
            if (value == 0) return false;
            if (value == 15) return true;

            return (value & EDGE_L) != 0 && centX < i
                || (value & EDGE_R) != 0 && centX > i
                || (value & EDGE_U) != 0 && centY < j
                || (value & EDGE_D) != 0 && centY > j;
        }

        public void GenerateMapData(float beginx, float beginy, float deltax, float deltay, float heightRange)
        {
            throw new System.NotImplementedException();
        }

        public void Init(Vector2 size)
        {
            width = (int)size.x;
            height = (int)size.y;

            m_BlockMap.gameObject.SetActive(false);
#if UNITY_EDITOR
            Destroy(m_BlockMap.material.mainTexture);
            m_BlockMap.transform.localScale = new Vector3(width, height, 1);
            m_BlockMap.transform.localPosition = new Vector3(width / 2, 0, height / 2);
            m_BlockMap.material.mainTexture = new Texture2D(width, height, TextureFormat.RGB24, false) {
                filterMode = FilterMode.Point, wrapMode = TextureWrapMode.Clamp,
            };
            for (int i = 0; i < width; ++i) {
                for (int j = 0; j < height; ++j) {
                    SetMaskPixel(i, j, Color.black);
                }
            }
#endif

            m_MapData = new byte[width][];
            for (int i = 0; i < width; ++i) m_MapData[i] = new byte[height];

            foreach (var vol in StageCtrl.L.blocks) BlockChanged(vol, vol.blockLevel);

            ApplyMaskTex();
        }

        public void SetVolumeBlock(IVolume vol, bool blocked)
        {
            FogOfWarEffect.SetFieldDataDirty();
            FogOfWarEffect.SetDirty();
            
            var center = vol.point;
            var size = vol.size;

            float w = size.x, h = size.z;
            if (Mathf.Abs(vol.forward.z) < 1e-6) {
                w = size.z; h = size.x;
            }

            if (w == 0) {
                var radius = h / 2;
                var x1 = (int)(center.x - 0.5f);
                var x2 = (int)(center.x + 0.5f);
                var _y = -1;
                for (float i = -radius; i <= radius; ++i) {
                    var py = center.z + i;
                    var y = i < 0 ? Mathf.CeilToInt(py) : Mathf.FloorToInt(py);
                    if (y == _y) continue;
                    _y = y;

                    if (blocked) {
                        BitOrCoord(x1, y, EDGE_R);
                        BitOrCoord(x2, y, EDGE_L);

                        SetMaskPixel(x1, y, Color.blue, 1);
                        SetMaskPixel(x2, y, Color.blue, 1);
                    } else {
                        BitAndCoord(x1, y, EDGE_R);
                        BitAndCoord(x2, y, EDGE_L);

                        SetMaskPixel(x1, y, Color.blue, -1);
                        SetMaskPixel(x2, y, Color.blue, -1);
                    }
                }
            } else if (h == 0) {
                var radius = w / 2;
                var y1 = (int)(center.z - 0.5f);
                var y2 = (int)(center.z + 0.5f);
                var _x = -1;
                for (float i = -radius; i <= radius; ++i) {
                    var px = center.x + i;
                    var x = i < 0 ? Mathf.CeilToInt(px) : Mathf.FloorToInt(px);
                    if (x == _x) continue;
                    _x = x;

                    if (blocked) {
                        BitOrCoord(x, y1, EDGE_D);
                        BitOrCoord(x, y2, EDGE_U);

                        SetMaskPixel(x, y1, Color.green, 1);
                        SetMaskPixel(x, y2, Color.green, 1);
                    } else {
                        BitAndCoord(x, y1, EDGE_D);
                        BitAndCoord(x, y2, EDGE_U);

                        SetMaskPixel(x, y1, Color.green, -1);
                        SetMaskPixel(x, y2, Color.green, -1);
                    }
                }
            } else {
                var start = center - new Vector((w / 2), 0, h / 2);
                start += (Vector)StageView.Instance.origin;
                for (int i = 0; i < (int)w; ++i) {
                    for (int j = 0; j < (int)h; ++j) {
                        var pos = start + new Vector(i, 0, j);
                        int x = (int)pos.x, y = (int)pos.z;
                        if (x >= 0 && x < width && y >= 0 && y < height) {
                            if (blocked) {
                                SetCoord(x, y, 15);
                                SetMaskPixel(x, y, Color.white);
                            }
                        }
                    }
                }
            }
        }
        
        public void BlockChanged(IVolume vol, int blockLevel)
        {
            SetVolumeBlock(vol, blockLevel == CVar.FULL_BLOCK);
        }

    }
}

