//
//  IShape.cs
//  survive
//
//  Created by xingweizhen on 10/16/2017.
//
//

using Dest.Math;

namespace World
{
    using UnityEngine;

    public enum ShapeType
    {
        None, Segment, AAB, Box, Circle, Sector, Annulus
    }

    public interface IShape
    {
        ShapeType type { get; }
        bool Contains(Vector point);
        bool Intersect(IShape shape);
    }

    public struct SegmentShape : IShape
    {
        public ShapeType type { get { return ShapeType.Segment; } }

        private Segment2 m_Shape;
        public Segment2 shape { get { return m_Shape; } }

        public SegmentShape(Vector coord, Vector forward, Vector size)
        {
            Vector2 direction = forward;
            float extents = size.z / 2;
            if (Math.IsEqual(extents, 0)) {
                direction = direction.Perp();
                extents = size.x / 2;
            }
            m_Shape = new Segment2(coord, direction, extents);
        }

        public SegmentShape(Segment2 segment)
        {
            m_Shape = segment;
        }

        bool IShape.Contains(Vector point)
        {
            return Math.IsEqual(m_Shape.DistanceTo(point), 0f);
        }

        bool IShape.Intersect(IShape shape)
        {
            switch (shape.type) {
                case ShapeType.Segment: {
                        var segment = ((SegmentShape)shape).shape;
                        return Intersection.TestSegment2Segment2(ref m_Shape, ref segment);
                    }
                case ShapeType.AAB : {
                        var aab = ((AABShape)shape).shape;
                        return Intersection.TestSegment2AAB2(ref m_Shape, ref aab);
                    }
                case ShapeType.Box: {
                        var box = ((RectShape)shape).shape;
                        return Intersection.TestSegment2Box2(ref m_Shape, ref box);
                    }
                case ShapeType.Circle: {
                        var circle = ((CircleShape)shape).shape;
                        return Intersection.TestSegment2Circle2(ref m_Shape, ref circle);
                    }
                case ShapeType.Sector: {
                        IShape self = this;
                        return ((SectorShape)shape).Intersect(self);
                    }
                default: return false;
            }
        }
    }

    public struct AABShape : IShape
    {
        public ShapeType type { get { return ShapeType.AAB; } }

        private AAB2 m_Shape;
        public AAB2 shape { get { return m_Shape; } }

        public AABShape(Vector coord, Vector size)
        {
            var extents = size / 2;
            m_Shape = new AAB2(coord - extents, coord + extents);
        }

        public bool Contains(Vector point)
        {
            return m_Shape.Contains(point);
        }

        public bool Intersect(IShape shape)
        {
            switch (shape.type) {
                case ShapeType.Segment: {
                        var segment = ((SegmentShape)shape).shape;
                        return Intersection.TestSegment2AAB2(ref segment, ref m_Shape);
                    }
                case ShapeType.AAB: {
                        var box = ((AABShape)shape).shape;
                        return Intersection.TestAAB2AAB2(ref m_Shape, ref box);
                    }
                case ShapeType.Box: {
                        var box = ((RectShape)shape).shape;
                        var selfBox = new Box2(m_Shape);
                        return Intersection.TestBox2Box2(ref selfBox, ref box);
                    }
                case ShapeType.Circle: {
                        var circle = ((CircleShape)shape).shape;
                        return Intersection.TestAAB2Circle2(ref m_Shape, ref circle);
                    }
                case ShapeType.Sector : {
                        IShape self = this;
                        return ((SectorShape)shape).Intersect(self);
                    }
                default: return false;
            }
        }
    }

    public struct RectShape : IShape
    {
        public ShapeType type { get { return ShapeType.Box; } }

        private Box2 m_Shape;
        public Box2 shape { get { return m_Shape; } }

        public RectShape(Vector coord, Vector forward, Vector size)
        {
            Vector2 axis0 = forward;
            var extents = (Vector2)size / 2;
            m_Shape = new Box2(coord, axis0.Perp(), axis0, extents);
        }

        bool IShape.Contains(Vector point)
        {
            return m_Shape.Contains(point);
        }

        bool IShape.Intersect(IShape shape)
        {
            switch (shape.type) {
                case ShapeType.Segment: {
                        var segment = ((SegmentShape)shape).shape;
                        return Intersection.TestSegment2Box2(ref segment, ref m_Shape);
                    }
                case ShapeType.AAB : {
                        var box = new Box2(((AABShape)shape).shape);
                        return Intersection.TestBox2Box2(ref m_Shape, ref box);
                    }
                case ShapeType.Box: {
                        var box = ((RectShape)shape).shape;
                        return Intersection.TestBox2Box2(ref m_Shape, ref box);
                    }
                case ShapeType.Circle: {
                        var circle = ((CircleShape)shape).shape;
                        return Intersection.TestBox2Circle2(ref m_Shape, ref circle);
                    }
                case ShapeType.Sector: {
                        IShape self = this;
                        return ((SectorShape)shape).Intersect(self);
                    }
                default: return false;
            }
        }
    }
    
    public struct CircleShape : IShape
    {
        public ShapeType type { get { return ShapeType.Circle; } }

        private Circle2 m_Shape;
        public Circle2 shape { get { return m_Shape; } }

        public CircleShape(Vector coord, float radius)
        {
            m_Shape = new Circle2(coord, radius);
        }

        public CircleShape(Circle2 circle)
        {
            m_Shape = circle;
        }

        public bool Contains(Vector point)
        {
            return m_Shape.Contains(point);
        }

        public bool Intersect(IShape shape)
        {
            switch (shape.type) {
                case ShapeType.Segment: {
                        var segment = ((SegmentShape)shape).shape;
                        return Intersection.TestSegment2Circle2(ref segment, ref m_Shape);
                    }
                case ShapeType.AAB: {
                        var aab = ((AABShape)shape).shape;
                        return Intersection.TestAAB2Circle2(ref aab, ref m_Shape);
                    }
                case ShapeType.Box: {
                        var box = ((RectShape)shape).shape;
                        return Intersection.TestBox2Circle2(ref box, ref m_Shape);
                    }
                case ShapeType.Circle: {
                        var circle = ((CircleShape)shape).shape;
                        return Intersection.TestCircle2Circle2(ref m_Shape, ref circle);
                    }
                case ShapeType.Sector: {
                        IShape self = this;
                        return ((SectorShape)shape).Intersect(self);
                    }
                default: return false;
            }
        }
    }

    public struct SectorShape : IShape
    {
        public ShapeType type { get { return ShapeType.Sector; } }

        private Circle2 m_Circle;
        public Circle2 shape { get { return m_Circle; } }

        private Vector m_Forward;
        public Vector forward { get { return m_Forward; } }

        public float angle { get; private set; }
        private float m_Dot;
        private Vector m_EdgeA, m_EdgeB;

        public SectorShape(Vector center, float radius, Vector forward, float angle) : this()
        {
            m_Circle = new Circle2(center, radius);
            m_Forward = forward;
            this.angle = angle;
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

        public bool Contains(Vector point)
        {
            if (!m_Circle.Contains(point)) return false;

            var direction = ((Vector2)point - m_Circle.Center).normalized;
            return Vector2.Dot(direction, m_Forward) >= m_Dot;
        }


        public bool Intersect(IShape shape)
        {
            IShape segmentA = new SegmentShape(new Segment2(m_Circle.Center, m_EdgeA));
            if (segmentA.Intersect(shape)) return true;

            IShape segmentB = new SegmentShape(new Segment2(m_Circle.Center, m_EdgeB));
            if (segmentB.Intersect(shape)) return true;

            Vector center;
            switch (shape.type) {
                case ShapeType.AAB : {
                        var box = ((AABShape)shape).shape;
                        center = (box.Min + box.Max) / 2f;
                        break;
                    }
                case ShapeType.Box: {
                        var box = ((RectShape)shape).shape;
                        center = box.Center;
                        break;
                    }
                case ShapeType.Circle: {
                        center = ((CircleShape)shape).shape.Center;
                        break;
                    }
                default: return false;
            }

            IShape circle = new CircleShape(m_Circle);
            var direction = ((Vector2)center - m_Circle.Center).normalized;
            return Vector2.Dot(direction, m_Forward) >= m_Dot && 
                (m_Circle.Contains(center) || circle.Intersect(shape));
        }

    }

    /*
    public struct PolygonShape : IShape
    {
        public ShapeType type { get { return ShapeType.Sector; } }

        private Vector mV0, mV1, mV2, mV3;
        public Vector v0 { get { return mV0; } }
        public Vector v1 { get { return mV1; } }
        public Vector v2 { get { return mV2; } }
        public Vector v3 { get { return mV3; } }
        
        public PolygonShape(Vector v0, Vector v1, Vector v2, Vector v3)
        {
            
            this.mV0 = v0;
            this.mV1 = v1;
            this.mV2 = v2;
            this.mV3 = v3;
        }

        public bool Contains(Vector point)
        {
            return Math.IsPointInPolygon(point, mV0, mV1, mV2, mV3);
        }

        public bool Intersect(IShape shape)
        {
            switch (shape.type) {
                case ShapeType.Segment: {
                        var segment = ((SegmentShape)shape).shape;
                        Intersection.TestSegment2ConvexPolygon2(ref segment, ref m_S
                    }
                case ShapeType.AABB : {
                        var box = new Box2(((AABBShape)shape).shape);
                        return Math.IsSectorBoxIntr(mV0, mV1, mV2, mV3, ref box);
                    }
                case ShapeType.Box: {
                        var box = ((RectShape)shape).shape;
                        return Math.IsSectorBoxIntr(mV0, mV1, mV2, mV3, ref box);
                    }
                case ShapeType.Circle: {
                        var circle = ((CircleShape)shape).shape;
                        return Math.IsSectorCircleIntr(mV0, mV1, mV2, mV3, ref circle);
                    }
                case ShapeType.Sector: {
                        return ((SectorShape)shape).Intersect(this);
                    }
                default: return false;
            }
        }
    }
    //*/

}
