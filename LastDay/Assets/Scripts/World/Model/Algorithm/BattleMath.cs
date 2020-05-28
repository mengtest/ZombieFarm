using System.Collections;
using Dest.Math;
using UnityEngine;

namespace World
{
    public static class Math
    {
		public const float PI = 3.141593f;
		public const float Deg2Rad = 0.0174532924F;
		public const float Rad2Deg = 57.29578F;

        public static float Max(float a, float b)
        {
            return a > b ? a : b;
        }
        
        public static float Round(float value, int round = 1)
        {
            if (round < 1) return value;
            
            return Mathf.Round(value / round) * round;
        }

        public struct Point2
        {
            public float x, y;
            public Point2(float x, float y)
            {
                this.x = x; this.y = y;
            }

            public static implicit operator Point2(Vector vector)
            {
                return new Point2(vector.x, vector.z);
            }
        }

        public struct Line2D
        {
            public Point2 p1, p2;
            public Line2D(Point2 p1, Point2 p2)
            {
                this.p1 = p1; this.p2 = p2;
            }
        }

        public static bool IsEqual(float a, float b)
        {
            return System.Math.Abs(a - b) < float.Epsilon;
        }

		/// <summary>
		/// 求两个直线交点
		/// </summary>
		public static bool GetLineCross(Line2D L1, Line2D L2, out Vector Cross)
		{
			Cross = new Vector(-1, -1);
			//y = a * x + b;
			if (!IsEqual(L1.p1.x, L1.p2.x)) {
				var a1 = (L1.p1.y - L1.p2.y) / (L1.p1.x - L1.p2.x);
				var b1 = L1.p1.y - a1 * (L1.p1.x);

				if (!IsEqual(L2.p1.x, L2.p2.x)) {
					var a2 = (L2.p1.y - L2.p2.y) / (L2.p1.x - L2.p2.x);
					var b2 = L2.p1.y - a2 * (L2.p1.x);

					if (IsEqual(a2, a1)) {
						return false;
					} else {
						Cross.x = (b1 - b2) / (a2 - a1);
					}
				} else {
					Cross.x = L2.p1.x;
				}
				Cross.y = a1 * Cross.x + b1;
			} else {
				if (IsEqual(L2.p1.x, L2.p2.x)) return false;
				Cross.x = L1.p1.x;
				var a2 = (L2.p1.y - L2.p2.y) / (L2.p1.x - L2.p2.x);
				var b2 = L2.p1.y - a2 * (L2.p1.x);
				Cross.y = a2 * Cross.x + b2;
			}
			return true;
		}
        
        /// <summary>
        /// 判断一个点是否在多边形内，点在所有边的同一侧
        /// </summary>
        public static bool IsPointInPolygon(Point2 P, params Point2[] V)
        {
            float[] r = new float[V.Length];
            for (int i = 0; i < r.Length; ++i) {
                var A = V[i];
                var B = i < r.Length - 1 ? V[i + 1] : V[0];
                r[i] = (A.x - P.x) * (B.y - P.y) - (A.y - P.y) * (B.x - P.x);
            }

            float s = r[0];
            for (int i = 1; i < r.Length; ++i) {
				if (IsEqual(r[i], 0)) continue;
                if (s * r[i] < 0) return false;
                s = r[i];
            }
            return true;
        }

        /// <summary>
        /// 判断一个点是否在一个矩形内
        /// </summary>
        public static bool IsPointInRect(Point2 point, Point2 P1, Point2 P3)
        {
            var P2 = new Point2(P1.x, P3.y);
            var P4 = new Point2(P3.x, P1.y);

            return IsPointInPolygon(point, P1, P2, P3, P4);
        }

        /// <summary>
        /// 判定矩形和圆是否和有重叠
        /// </summary>
        public static bool IsRectCircleIntr(Box2 box, Vector point, float radius)
        {
            if (radius > 0) {
                var circle = new Circle2(point, radius);
                return Intersection.TestBox2Circle2(ref box, ref circle);
            } else {
                return box.Contains(point);
            }
        }

        public static bool IsPointInSector(Circle2 circle, Vector forward, float dot, Vector point)
        {
            if (circle.Contains(point)) {
                var center = new Vector(circle.Center.x, circle.Center.y);
                var direction = (point - center).normalized;
                return Vector.Dot(forward, direction) >= dot;
            }
            return false;
        }

        /// <summary>
        /// 判定扇形（其实是近似多边形）和圆是否重叠
        /// </summary>
        public static bool IsSectorCircleIntr(Vector v0, Vector v1, Vector v2, Vector v3, ref Circle2 circle)
        {
            // 圆心在内部，必定重叠
            var center = new Point2(circle.Center.x, circle.Center.y);
            if (IsPointInPolygon(center, v0, v1, v2, v3)) return true;

            if (circle.Radius > 0) {
                // 依次判定每条边是否和圆相交
                var line0 = new Segment2(v0, v1);
                var line1 = new Segment2(v1, v2);
                var line2 = new Segment2(v2, v3);
                var line3 = new Segment2(v3, v0);

                return Intersection.TestSegment2Circle2(ref line0, ref circle)
                    || Intersection.TestSegment2Circle2(ref line1, ref circle)
                    || Intersection.TestSegment2Circle2(ref line2, ref circle)
                    || Intersection.TestSegment2Circle2(ref line3, ref circle);
            }
            
            return false;
        }

        /// <summary>
        /// 判定扇形（其实是近似多边形）和矩形是否重叠
        /// </summary>
        public static bool IsSectorBoxIntr(Vector v0, Vector v1, Vector v2, Vector v3, ref Box2 box)
        {
            // 圆心在内部，必定重叠
            var center = new Point2(box.Center.x, box.Center.y);
            if (IsPointInPolygon(center, v0, v1, v2, v3)) return true;

            // 依次判定每条边是否和矩形相交
            var line0 = new Segment2(v0, v1);
            var line1 = new Segment2(v1, v2);
            var line2 = new Segment2(v2, v3);
            var line3 = new Segment2(v3, v0);

            return Intersection.TestSegment2Box2(ref line0, ref box)
                || Intersection.TestSegment2Box2(ref line1, ref box)
                || Intersection.TestSegment2Box2(ref line2, ref box)
                || Intersection.TestSegment2Box2(ref line3, ref box);
        }

        public static void GetBound(this Polygon2 self, out float xMin, out float xMax, out float yMin, out float yMax)
        {
            xMin = float.MaxValue; yMin = float.MaxValue;
            xMax = float.MinValue; yMax = float.MinValue;
            for (int i = 0; i < self.Vertices.Length; ++i) {
                var p = self.Vertices[i];
                if (xMin > p.x) xMin = p.x;
                if (xMax < p.x) xMax = p.x;
                if (yMin > p.y) yMin = p.y;
                if (yMax < p.y) yMax = p.y;
            }
        }
    }
}
