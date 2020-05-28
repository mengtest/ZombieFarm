using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Dest.Math;

namespace World
{
	public static class Distances
	{
		public static float DistanceTo(this Vector self, ref Shape2D shape)
		{
			float distance;

			UnityEngine.Profiling.Profiler.BeginSample("DistanceTo");
			Vector2 point = self;
			switch (shape.type) {
				case ShapeType.AAB:
					var aab = shape.aab;
					distance = Distance.Point2AAB2(ref point, ref aab);
					break;
				case ShapeType.Box:
					var box = shape.box;
					distance = Distance.Point2Box2(ref point, ref box);
					break;
				case ShapeType.Circle:
					var circle = shape.circle;
					distance = Distance.Point2Circle2(ref point, ref circle);
					break;
				case ShapeType.Segment:
					var segment = shape.segment;
					distance = Distance.Point2Segment2(ref point, ref segment);
					break;
				default:
					distance = Vector.Distance(self, shape.GetCenter(self));
					break;
			}

			UnityEngine.Profiling.Profiler.EndSample();

			return distance;
		}

		public static float DistanceTo(this Vector self, Shape2D shape)
		{
			return self.DistanceTo(ref shape);
		}

		private static Circle2 _tmpCircle2 = new Circle2();
		private static Segment2 _tmpSegment2 = new Segment2();
		private static Box2 _tmpBox2 = new Box2();

		public static float DistanceTo(this Vector self, IObj obj)
		{
			if (obj == null) return 0;

			var vol = obj as IVolume;
			Vector2 vec = self;
			
			var dist = (self - obj.coord).magnitude;

			if (vol != null) {
				var siz = vol.size;
				if (Math.IsEqual(siz.x, siz.z)) {
					_tmpCircle2.Center = vol.point;
					_tmpCircle2.Radius = siz.x * 0.5f;
					return Distance.Point2Circle2(ref vec, ref _tmpCircle2);
				}

				if (Math.IsEqual(siz.x, 0) || Math.IsEqual(siz.z, 0)) {
					var size = vol.size;
					Vector2 direction = vol.forward;
					float extents = size.z * 0.5f;
					if (Math.IsEqual(extents, 0)) {
						direction = direction.Perp();
						extents = size.x * 0.5f;
					}

					_tmpSegment2.SetCenterDirectionExtent(vol.point, direction, extents);
					return Distance.Point2Segment2(ref vec, ref _tmpSegment2);
				}

				Vector2 axis0 = vol.forward;
				_tmpBox2.Center = vol.point;
				_tmpBox2.Axis0 = axis0.Perp();
				_tmpBox2.Axis1 = axis0;
				_tmpBox2.Extents = vol.size * 0.5f;
				return Distance.Point2Box2(ref vec, ref _tmpBox2);
			} else {
				return dist;
			}
		}

	}

}