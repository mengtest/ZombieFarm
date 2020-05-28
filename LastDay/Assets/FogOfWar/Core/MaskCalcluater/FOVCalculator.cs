using UnityEngine;
using System.Collections;
using System.Collections.Generic;

namespace ASL.FogOfWar
{
    /// <summary>
    /// FOV蒙版计算器
    /// </summary>
    internal abstract class FOVCalculator : MaskCalcluatorBase
    {
        protected List<FOWMapPos> m_PosList;

        protected List<int> m_Arrives;

        public FOVCalculator()
        {
            m_PosList = new List<FOWMapPos>();
            m_Arrives = new List<int>();
        }
                
        protected sealed override void RealtimeCalculate(FOWFieldData field, FOWMap map)
        {
            Vector3 worldPosition = field.position;
            float radiusSq = field.radiusSquare;

            int x = Mathf.FloorToInt((worldPosition.x - map.beginPosition.x) * map.invDeltaX);
            int z = Mathf.FloorToInt((worldPosition.z - map.beginPosition.z) * map.invDeltaZ);

            //if (x < 0 || x >= map.texWidth)
            //    return;
            //if (z < 0 || z >= map.texHeight)
            //    return;
            //if (map.mapData.IsObstacle(x, z, x, z)) {
            //    return;
            //}

            m_PosList.Clear();
            m_Arrives.Clear();

            m_PosList.Add(new FOWMapPos(x, z));
            m_Arrives.Add(map.ToIndex(x, z));
            map.maskTexture.SetAsVisible(x, z);

            while (m_PosList.Count > 0) {
                var root = m_PosList[0];
                m_PosList.RemoveAt(0);
                if (map.mapData.IsObstacle(root.x, root.y, x, z)) {
                    if (PreRayCast(map, root, x, z)) {
                        int index = map.ToIndex(root.x, root.y);
                        if (!m_Arrives.Contains(index))
                            m_Arrives.Add(index);
                        map.maskTexture.SetAsVisible(root.x, root.y);
                    } else
                        RayCast(map, root, x, z, field);
                    continue;
                }
                SetVisibleAtPosition(map, root.x - 1, root.y, x, z, radiusSq);
                SetVisibleAtPosition(map, root.x, root.y - 1, x, z, radiusSq);
                SetVisibleAtPosition(map, root.x + 1, root.y, x, z, radiusSq);
                SetVisibleAtPosition(map, root.x, root.y + 1, x, z, radiusSq);
            }
        }

        public override void Release()
        {
            m_PosList.Clear();
            m_PosList = null;
            m_Arrives.Clear();
            m_Arrives = null;
        }

        private bool PreRayCast(FOWMap map, FOWMapPos pos, int centX, int centZ)
        {
            float k = ((float)(pos.y - centZ)) / (pos.x - centX);
            if (k < -0.414f && k >= -2.414f) {
                return !IsVisible(map, pos.x + 1, pos.y + 1, centX, centZ) && !IsVisible(map, pos.x - 1, pos.y - 1, centX, centZ);
            } else if (k < -2.414f || k >= 2.414f) {
                return !IsVisible(map, pos.x + 1, pos.y, centX, centZ) && !IsVisible(map, pos.x - 1, pos.y, centX, centZ);
            } else if (k < 2.414f && k >= 0.414f) {
                return !IsVisible(map, pos.x + 1, pos.y - 1, centX, centZ) && !IsVisible(map, pos.x - 1, pos.y + 1, centX, centZ);
            } else {
                return !IsVisible(map, pos.x, pos.y + 1, centX, centZ) && !IsVisible(map, pos.x, pos.y - 1, centX, centZ);
            }
        }

        private bool IsVisible(FOWMap map, int x, int y, int centX, int centY)
        {
            return map.Contains(x, y) && !map.mapData.IsObstacle(x, y, centX, centY);
        }

        protected abstract void RayCast(FOWMap map, FOWMapPos pos, int centX, int centZ,
            FOWFieldData field);

        private void SetVisibleAtPosition(FOWMap map, int x, int z, int centX, int centZ, float radiusSq)
        {
            if (!map.Contains(x, z)) return;

            int hori = x - centX, vert = z - centZ;
            var horiSq = hori * hori * map.deltaXSq;
            var vertSq = vert * vert * map.deltaZSq;

            if (horiSq + vertSq > radiusSq)
                return;
            int index = map.ToIndex(x, z);
            if (m_Arrives.Contains(index))
                return;
            m_Arrives.Add(index);

            // 优先处理障碍格子
            if (map.mapData.IsObstacle(x, z, centX, centZ)) {
                m_PosList.Insert(0, new FOWMapPos(x, z));
            } else {
                m_PosList.Add(new FOWMapPos(x, z));
            }

            byte value = 15;
            if (hori != 0 && vert != 0) {
                var xOff = hori > 0 ? 1 : -1;
                var zOff = vert > 0 ? 1 : -1;
                var xRet = !IsInRange(map, x + xOff, z, centX, centZ, radiusSq);
                var yRet = !IsInRange(map, x, z + zOff, centX, centZ, radiusSq);
                if (xRet) value &= (byte)(xOff < 0 ? ~5 : ~10);
                if (yRet) value &= (byte)(zOff < 0 ? ~3 : ~12);
            }
            map.maskTexture.SetAsVisible(x, z, value);
        }

        protected void SetInvisibleLine(FOWMap map, int beginx, int beginy, int endx, int endy, int centX, int centZ, float rsq)
        {
            int dx = Mathf.Abs(endx - beginx);
            int dy = Mathf.Abs(endy - beginy);
            //int x, y;
            int step = ((endy < beginy && endx >= beginx) || (endy >= beginy && endx < beginx)) ? -1 : 1;
            int p, twod, twodm;
            int pv1, pv2, to;
            int x, y;
            if (dy < dx) {
                p = 2 * dy - dx;
                twod = 2 * dy;
                twodm = 2 * (dy - dx);
                if (beginx > endx) {
                    pv1 = endx;
                    pv2 = endy;
                    endx = beginx;
                } else {
                    pv1 = beginx;
                    pv2 = beginy;
                }
                to = endx;
            } else {
                p = 2 * dx - dy;
                twod = 2 * dx;
                twodm = 2 * (dx - dy);
                if (beginy > endy) {
                    pv2 = endx;
                    pv1 = endy;
                    endy = beginy;
                } else {
                    pv2 = beginx;
                    pv1 = beginy;
                }
                to = endy;
            }
            if (dy < dx) {
                x = pv1;
                y = pv2;
            } else {
                x = pv2;
                y = pv1;
            }
            SetInvisibleAtPosition(map, x, y);
            while (pv1 < to) {
                pv1++;
                if (p < 0)
                    p += twod;
                else {
                    pv2 += step;
                    p += twodm;
                }

                if (dy < dx) {
                    x = pv1;
                    y = pv2;
                } else {
                    x = pv2;
                    y = pv1;
                }
                if (!IsInRange(map, x, y, centX, centZ, rsq)) {
                    return;
                }
                SetInvisibleAtPosition(map, x, y);
            }

        }
        
        protected bool IsInRange(FOWMap map, int x, int z, int centX, int centZ, float radiusSq)
        {
            int hori = x - centX, vert = z -centZ;
            var horiSq = hori * hori * map.deltaXSq;
            var vertSq = vert * vert * map.deltaZSq;

            return horiSq + vertSq <= radiusSq;
        }

        protected void SetInvisibleAtPosition(FOWMap map, int x, int z)
        {
            int index = map.ToIndex(x, z);
            if (m_Arrives.Contains(index) == false) {
                m_Arrives.Add(index);
            }
        }
    }
}