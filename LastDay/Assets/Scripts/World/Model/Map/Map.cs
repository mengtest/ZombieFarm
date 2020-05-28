//
//  Map.cs
//  survive
//
//  Created by xingweizhen on 10/16/2017.
//
//

using System.Collections.Generic;
using Dest.Math;

namespace World
{
    public static class Map
    {
        public static IShape ToShape(this IVolume self)
        {
            var siz = self.size;
            if(Math.IsEqual(siz.x, siz.z)) {
                return new CircleShape(self.point, siz.x / 2);
            }

            if (Math.IsEqual(siz.x, 0) || Math.IsEqual(siz.z, 0)) {
                return new SegmentShape(self.point, self.forward, siz);
            }

            return new RectShape(self.point, self.forward, siz);
        }

        public static Segment2 ToSegment(Vector src, Vector dst)
        {
            return new Segment2(src, dst);
        }

        public static bool IsBlock(ref Segment2 self, IVolume block, out Vector hit)
        {
            hit = Vector.zero;
            var shape = new Shape2D(block);
            switch (shape.type) {
                case ShapeType.Segment: {
                        var segment = shape.segment;
                        View.Debugger.DrawLine(UnityEngine.Color.yellow, 1, segment.P0, segment.P1);
                        Segment2Segment2Intr intr;
                        if (Intersection.FindSegment2Segment2(ref self, ref segment, out intr)) {
                            hit = new Vector(intr.Point0.x, 0, intr.Point0.y);
                            return true;
                        }
                        break;
                    }
                case ShapeType.Box : {
                        var box = shape.box;
                        var extents = box.Extents;
                        extents.x -= 0.01f; extents.y -= 0.01f;
                        box.Extents = extents;
                        View.Debugger.DrawRect(UnityEngine.Color.yellow, 1, box);
                        Segment2Box2Intr intr;
                        if (Intersection.FindSegment2Box2(ref self, ref box, out intr)) {
                            hit = new Vector(intr.Point0.x, 0, intr.Point0.y);
                            return true;
                        }
                        break;
                    }
                case ShapeType.Circle : {
                        var circle = shape.circle;
                        circle.Radius -= 0.01f;
                        View.Debugger.DrawCircle(UnityEngine.Color.yellow, 1, circle.Center, circle.Radius);
                        Segment2Circle2Intr intr;
                        if (Intersection.FindSegment2Circle2(ref self, ref circle, out intr)) {
                            hit = new Vector(intr.Point0.x, 0, intr.Point0.y);
                            return true;
                        }
                        break;
                    }
                default : break; 
            }

            return false;
        }

        public static bool IsBlock(Vector src, Vector dst, IVolume block, out Vector hit)
        {
            var segment2 = ToSegment(src, dst);
            return IsBlock(ref segment2, block, out hit);
        }

        //public static bool IsOverlap(this IEntity self)
        //{
        //    if (self != null) {
        //        var shape = self.ToShape();
        //        foreach (var obj in self.L) {
        //            var entity = obj as IEntity;
        //            if (entity != null && entity != self) {
        //                var tarShape = entity.ToShape();
        //                if (shape.Intersect(tarShape)) return true;
        //            }
        //        }
        //    }

        //    return false;
        //}

        public static Vector size = new Vector(50f, 0f, 50f);

        public static bool IsInside(Vector coord)
        {
            Vector min = Vector.zero, max = size;
            return coord.x >= min.x && coord.x <= max.x && coord.z >= min.z && coord.z <= max.z;
        }

        public static bool IsInMap(Vector coord)
        {
            Vector half = Vector3ex.One / 2f;
            Vector min = half, max = size - Vector.one - half;
            return coord.x >= min.x && coord.x <= max.x && coord.z >= min.z && coord.z <= max.z;
        }

        public static void ClampInside(Vector start, ref Vector end)
        {
            Vector min = Vector.zero, max = size;
            if (start != end) {
                var box = new AAB2(min, max);
                var segment = new Segment2(start, end);
                Segment2AAB2Intr intr;
                if (Intersection.FindSegment2AAB2(ref segment, ref box, out intr)) {
                    var point = intr.Quantity == 2 ? intr.Point1 : intr.Point0;
                    end.x = point.x;
                    end.z = point.y;
                }
            }

            if (end.x < min.x) end.x = min.x;
            if (end.x > max.x) end.x = max.x;
            if (end.z < min.z) end.z = min.z;
            if (end.z > max.z) end.z = max.z;
        }
    }
}