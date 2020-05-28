using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Dest.Math;


namespace World
{
    public struct Shape2D
    {
        public ShapeType type { get; private set; }
        
        private Segment2 m_Segment;
        public Segment2 segment { get { return m_Segment; } }

        private Box2 m_Box;
        public Box2 box { get { return m_Box; } }

        private AAB2 m_AAB;
        public AAB2 aab { get { return m_AAB; } }

        private Circle2 m_Circle;
        public Circle2 circle { get { return m_Circle; } }

        public Circle2 m_InnerCircle;
        public Circle2 innerCircle { get { return m_InnerCircle; } }

        /// <summary>
        /// 扇形参数
        /// </summary>
        private Vector m_EdgeA, m_EdgeB;
        private Vector m_Forward;
        private float m_Angle, m_Dot;

        public Vector forward { get { return m_Forward; } }
        public float angle { get { return m_Angle; } }

        public Vector GetCenter(Vector center)
        {
            switch (type) {
                case ShapeType.Circle:
                case ShapeType.Sector:
                    return m_Circle.Center;
                default:
                    return center;
            }
        }

        /// <summary>
        /// 圆形
        /// </summary>
        /// <param name="center"></param>
        /// <param name="radius"></param>
        public Shape2D(Vector center, float radius)
        {
            this = new Shape2D();

            type = ShapeType.Circle;
            m_Circle = new Circle2(center, radius);
        }

        /// <summary>
        /// AAB矩形
        /// </summary>
        /// <param name="coord"></param>
        /// <param name="size"></param>
        public Shape2D(Vector coord, Vector size)
        {
            this = new Shape2D();

            type = ShapeType.AAB;
            var extents = size / 2;
            m_AAB = new AAB2(coord - extents, coord + extents);
        }

        /// <summary>
        /// 任意矩形
        /// </summary>
        /// <param name="coord"></param>
        /// <param name="forward"></param>
        /// <param name="size"></param>
        public Shape2D(Vector coord, Vector forward, Vector size)
        {
            this = new Shape2D();

            type = ShapeType.Box;
            Vector2 axis0 = forward;
            var extents = (Vector2)size / 2;
            m_Box = new Box2(coord, axis0.Perp(), axis0, extents);
        }

        /// <summary>
        /// 扇形
        /// </summary>
        /// <param name="center"></param>
        /// <param name="radius"></param>
        /// <param name="forward"></param>
        /// <param name="angle"></param>
        public Shape2D(Vector center, float radius, Vector forward, float angle)
        {
            this = new Shape2D();

            type = ShapeType.Sector;
            m_Circle = new Circle2(center, radius);

            m_Forward = forward;
            m_Angle = angle;
            m_Dot = Mathf.Cos(angle * Math.Deg2Rad / 2);

            var project = Vector.one;
            if (Math.IsEqual(forward.z, 0)) {
                project.x = 0;
            } else {
                project.z = -forward.x / forward.z;
            }
            project.y = 0;
            project.Normalize();
            float tanA = (float)System.Math.Tan((angle / 2) * Math.Deg2Rad);
            var vl = project * tanA;
            var leftD = (forward + vl).normalized * radius;
            var rightD = (forward - vl).normalized * radius;

            m_EdgeA = center + leftD;
            m_EdgeB = center + rightD;
        }

        /// <summary>
        /// 环形
        /// </summary>
        /// <param name="center"></param>
        /// <param name="innerRadius"></param>
        /// <param name="outerRadius"></param>
        public Shape2D(Vector center, float innerRadius, float outerRadius)
        {
            this = new Shape2D();

            type = ShapeType.Annulus;
            m_Circle = new Circle2(center, outerRadius);
            m_InnerCircle = new Circle2(center, innerRadius);
        }

        public Shape2D(IVolume Vol)
        {
            this = new Shape2D();

            var siz = Vol.size;
            if (Math.IsEqual(siz.x, siz.z)) {
                this.m_Circle = new Circle2(Vol.point, siz.x / 2);
                this.type = ShapeType.Circle;
                return;
            }

            if (Math.IsEqual(siz.x, 0) || Math.IsEqual(siz.z, 0)) {
                var size = Vol.size;
                Vector2 direction = Vol.forward;
                float extents = size.z / 2;
                if (Math.IsEqual(extents, 0)) {
                    direction = direction.Perp();
                    extents = size.x / 2;
                }
                this.m_Segment = new Segment2(Vol.point, direction, extents);
                this.type = ShapeType.Segment;
                return;
            }


            Vector2 axis0 = Vol.forward;
            this.m_Box = new Box2(Vol.point, axis0.Perp(), axis0, Vol.size / 2);
            this.type = ShapeType.Box;
        }

        public bool Contains(Vector point)
        {
            switch (type) {
                case ShapeType.Segment:
                    return Math.IsEqual(m_Segment.DistanceTo(point), 0f);
                case ShapeType.AAB:
                    return m_AAB.Contains(point);
                case ShapeType.Box:
                    return m_Box.Contains(point);
                case ShapeType.Circle:
                    return m_Circle.Contains(point);
                case ShapeType.Sector:
                    if (!m_Circle.Contains(point)) return false;
                    var direction = ((Vector2)point - m_Circle.Center).normalized;
                    return Vector2.Dot(direction, m_Forward) >= m_Dot;
                case ShapeType.Annulus:
                    return m_Circle.Contains(point) && !m_InnerCircle.Contains(point);
                default: return false;
            }
        }

        public bool Intersect(ref Segment2 segment)
        {
            switch (type) {
                case ShapeType.Segment:
                    return Intersection.TestSegment2Segment2(ref m_Segment, ref segment);
                case ShapeType.AAB:
                    return Intersection.TestSegment2AAB2(ref segment, ref m_AAB);
                case ShapeType.Box:
                    return Intersection.TestSegment2Box2(ref segment, ref m_Box);
                case ShapeType.Circle:
                    return Intersection.TestSegment2Circle2(ref segment, ref m_Circle);
                case ShapeType.Sector:
                    var shape = new Shape2D() { type = ShapeType.Segment, m_Segment = segment };
                    return SectorIntersect(ref shape);
                case ShapeType.Annulus:
                    return TestSegment2Annulus2(ref segment, ref m_InnerCircle, ref m_Circle);
                default: return false;
            }
        }


        public bool Intersect(ref AAB2 aab)
        {
            switch (type) {
                case ShapeType.Segment:
                    return Intersection.TestSegment2AAB2(ref m_Segment, ref aab);
                case ShapeType.AAB:
                    return Intersection.TestAAB2AAB2(ref m_AAB, ref aab);
                case ShapeType.Box:
                    var _box = new Box2(aab);
                    return Intersection.TestBox2Box2(ref m_Box, ref _box);
                case ShapeType.Circle:
                    return Intersection.TestAAB2Circle2(ref aab, ref m_Circle);
                case ShapeType.Sector:
                    var shape = new Shape2D() { type = ShapeType.AAB, m_AAB = aab };
                    return SectorIntersect(ref shape);
                case ShapeType.Annulus:
                    return TestAAB2Annulus2(ref aab, ref m_InnerCircle, ref m_Circle);
                default: return false;
            }
        }

        public bool Intersect(ref Box2 box)
        {
            switch (type) {
                case ShapeType.Segment:
                    return Intersection.TestSegment2Box2(ref m_Segment, ref box);
                case ShapeType.AAB:
                    var _box = new Box2(m_AAB);
                    return Intersection.TestBox2Box2(ref _box, ref box);
                case ShapeType.Box:
                    return Intersection.TestBox2Box2(ref m_Box, ref box);
                case ShapeType.Circle:
                    return Intersection.TestBox2Circle2(ref box, ref m_Circle);
                case ShapeType.Sector:
                    var shape = new Shape2D() { type = ShapeType.Box, m_Box = box };
                    return SectorIntersect(ref shape);
                case ShapeType.Annulus:
                    return TestBox2Annulus2(ref box, ref m_InnerCircle, ref m_Circle);
                default: return false;
            }
        }

        public bool Intersect(ref Circle2 circle)
        {
            switch (type) {
                case ShapeType.Segment:
                    return Intersection.TestSegment2Circle2(ref m_Segment, ref circle);
                case ShapeType.AAB:
                    return Intersection.TestAAB2Circle2(ref m_AAB, ref circle);
                case ShapeType.Box:
                    return Intersection.TestBox2Circle2(ref m_Box, ref circle);
                case ShapeType.Circle:
                    return Intersection.TestCircle2Circle2(ref m_Circle, ref circle);
                case ShapeType.Sector:
                    var shape = new Shape2D() { type = ShapeType.Circle, m_Circle = circle };
                    return SectorIntersect(ref shape);
                case ShapeType.Annulus:
                    return TestCircle2Annulus2(ref circle, ref m_InnerCircle, ref m_Circle);
                default: return false;
            }
        }

        public bool Intersect(ref Circle2 innerCircle, ref Circle2 outerCircle)
        {
            switch (type) {
                case ShapeType.Segment:
                    return TestSegment2Annulus2(ref m_Segment, ref innerCircle, ref outerCircle);
                case ShapeType.AAB: 
                        return TestAAB2Annulus2(ref m_AAB, ref innerCircle, ref outerCircle);
                case ShapeType.Box:
                    return TestBox2Annulus2(ref m_Box, ref innerCircle, ref outerCircle);
                case ShapeType.Circle:
                    return TestCircle2Annulus2(ref m_Circle, ref innerCircle, ref outerCircle);
                case ShapeType.Sector:
                    // 不存在的相交判定
                    return false;
                default: return false;
            }
        }
        
        public bool SectorIntersect(ref Shape2D shape)
        {
            var segmentA = new Segment2(m_Circle.Center, m_EdgeA);
            if (shape.Intersect(ref segmentA)) return true;

            var segmentB = new Segment2(m_Circle.Center, m_EdgeB);
            if (shape.Intersect(ref segmentB)) return true;

            Vector center;
            switch (shape.type) {
                case ShapeType.AAB: {
                        var box = shape.m_AAB;
                        center = (box.Min + box.Max) / 2f;
                        break;
                    }
                case ShapeType.Box: {
                        var box = shape.m_Box;
                        center = box.Center;
                        break;
                    }
                case ShapeType.Circle: {
                        center = shape.m_Circle.Center;
                        break;
                    }
                default:
                    // 不支持扇形和扇形相交判定
                    return false;
            }
            
            var direction = ((Vector2)center - m_Circle.Center).normalized;
            return Vector2.Dot(direction, m_Forward) >= m_Dot &&
                (m_Circle.Contains(center) || shape.Intersect(ref m_Circle));
        }

        public bool Intersect(ref Shape2D shape)
        {
            switch (shape.type) {
                case ShapeType.Segment:
                    return Intersect(ref shape.m_Segment);
                case ShapeType.AAB:
                    return Intersect(ref shape.m_AAB);
                case ShapeType.Box:
                    return Intersect(ref shape.m_Box);
                case ShapeType.Circle:
                    return Intersect(ref shape.m_Circle);
                case ShapeType.Sector:
                    return shape.SectorIntersect(ref this);
                case ShapeType.Annulus:
                    return shape.Intersect(ref shape.m_InnerCircle, ref shape.m_Circle);
                default: return false;
            }
        }

        public bool Intersect(IVolume Vol)
        {
            var shape = new Shape2D(Vol);
            switch (shape.type) {
                case ShapeType.Segment:
                    return Intersect(ref shape.m_Segment);
                case ShapeType.AAB:
                    return Intersect(ref shape.m_AAB);
                case ShapeType.Box:
                    return Intersect(ref shape.m_Box);
                case ShapeType.Circle:
                    return Intersect(ref shape.m_Circle);
                case ShapeType.Sector:
                    return shape.SectorIntersect(ref this);
                case ShapeType.Annulus:
                    return shape.Intersect(ref shape.m_InnerCircle, ref shape.m_Circle);
                default: return false;
            }
        }

        public string ToDesc()
        {
            switch (type) {
                case ShapeType.Segment:
                    return m_Segment.ToString();
                case ShapeType.AAB:
                    return m_AAB.ToString();
                case ShapeType.Box:
                    return m_Box.ToString();
                case ShapeType.Circle:
                    return m_Circle.ToString();
                case ShapeType.Sector:
                    return string.Format("[Center: {0} Radius: {1} Forward: {2} Angle: {3}]", 
                        m_Circle.Center, m_Circle.Radius, m_Forward, m_Angle); 
                default: return string.Empty;
            }
        }
        
        public override string ToString()
        {
            return string.Format("{0}:{1}", type, ToDesc());
        }

        private static bool TestSegment2Annulus2(ref Segment2 segment, ref Circle2 innerCircle, ref Circle2 outerCircle)
        {
            if (innerCircle.Contains(segment.P0) && innerCircle.Contains(segment.P1)) return false;
            return Intersection.TestSegment2Circle2(ref segment, ref outerCircle);
        }

        private static bool TestAAB2Annulus2(ref AAB2 aab, ref Circle2 innerCircle, ref Circle2 outerCircle)
        {
            Vector2 v0, v1, v2, v3;
            aab.CalcVertices(out v0, out v1, out v2, out v3);
            if (innerCircle.Contains(v0) && innerCircle.Contains(v1) &&
                innerCircle.Contains(v2) && innerCircle.Contains(v3)) return false;

            return Intersection.TestAAB2Circle2(ref aab, ref outerCircle);
        }

        private static bool TestBox2Annulus2(ref Box2 box, ref Circle2 innerCircle, ref Circle2 outerCircle)
        {
            Vector2 v0, v1, v2, v3;
            box.CalcVertices(out v0, out v1, out v2, out v3);
            if (innerCircle.Contains(v0) && innerCircle.Contains(v1) &&
               innerCircle.Contains(v2) && innerCircle.Contains(v3)) return false;

            return Intersection.TestBox2Circle2(ref box, ref outerCircle);
        }

        private static bool TestCircle2Annulus2(ref Circle2 circle, ref Circle2 innerCircle, ref Circle2 outerCircle)
        {
            if (Vector2.Distance(circle.Center, innerCircle.Center) < innerCircle.Radius - circle.Radius)
                return false;
            return Intersection.TestCircle2Circle2(ref circle, ref outerCircle);
        }
    }    
}
