using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace World
{
    public class ClosedArea
    {
        public struct Point
        {
            public float x, y;
            public Point(float x, float y) { this.x = x; this.y = y; }

            public override bool Equals(object obj)
            {
                if (obj is Point) {
                    var p = (Point)obj;
                    return p.x == x && p.y == y;
                }
                return false;
            }

            public override int GetHashCode()
            {
                var hashCode = 1502939027;
                hashCode = hashCode * -1521134295 + x.GetHashCode();
                hashCode = hashCode * -1521134295 + y.GetHashCode();
                return hashCode;
            }

            public static bool operator ==(Point point1, Point point2)
            {
                return point1.Equals(point2);
            }

            public static bool operator !=(Point point1, Point point2)
            {
                return !(point1 == point2);
            }
        }
        
        // 线段
        public interface ISegment
        {
            Point p1 { get; }
            Point p2 { get; }
        }

        public interface IAreaData
        {
            // 迭代所有的线段
            IEnumerator<ISegment> GetAllSegments();
        }

        private List<ISegment> m_List = new List<ISegment>();
        private Dictionary<Point, int> m_Counts = new Dictionary<Point, int>();
        private Dictionary<Point, List<ISegment>> points = new Dictionary<Point, List<ISegment>>();

        public void StartCalculate(IAreaData areaData)
        {
            using (var itor = areaData.GetAllSegments()) {
                while (itor.MoveNext()) {
                    var seg = itor.Current;
                    m_List.Add(seg);
                    var p1 = seg.p1;
                    if (m_Counts.ContainsKey(p1)) {
                        m_Counts[p1] += 1;
                    } else {
                        m_Counts.Add(p1, 1);
                    }

                    var p2 = seg.p2;
                    if (m_Counts.ContainsKey(p2)) {
                        m_Counts[p2] += 1;
                    } else {
                        m_Counts.Add(p2, 1);
                    }
                }
            }

            // 移除孤立线段（起点或者终点是“孤立”的，即没有和其他任何线段连接）        
            for (int i = m_List.Count - 1; i >= 0; --i) {
                var seg = m_List[i];
                if (m_Counts[seg.p1] == 1 || m_Counts[seg.p2] == 1) {
                    m_List.RemoveAt(i);
                }
            }
            m_Counts.Clear();

            // 生成图结构
            foreach (var seg in m_List) {
                var p1 = seg.p1;
                if (points.ContainsKey(p1)) {
                    points[p1].Add(seg);
                } else {
                    points.Add(p1, new List<ISegment>() { seg });
                }

                var p2 = seg.p2;
                if (points.ContainsKey(p2)) {
                    points[p2].Add(seg);
                } else {
                    points.Add(p2, new List<ISegment>() { seg } );
                }
            }
            m_List.Clear();

            // 合并线段（一个点有且只有两个连接线段，则这两个连接线段可以合并）
            foreach (var kv in points) {
                if (kv.Value.Count == 2) {

                }
            }

            // 顺时针寻找封闭区域

        }
    }

}
