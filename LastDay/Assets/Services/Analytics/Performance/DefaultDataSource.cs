using UnityEngine;
#if UNITY_5_5_OR_NEWER
using UnityEngine.Profiling;
#endif

namespace Unity.Performance
{
	public class DefaultDataSource : IDataSource
	{
		public float unscaledDeltaTimeSeconds { get { return Time.unscaledDeltaTime; } }

		public float realtimeSinceStartup { get { return Time.realtimeSinceStartup; } }

		public int frameCount { get { return Time.frameCount; } }

		public long memoryAllocated { 
			get {
#if UNITY_5_6_OR_NEWER
				return Profiler.GetTotalAllocatedMemoryLong ();
#else
				return (long)Profiler.GetTotalAllocatedMemory ();
#endif
			}
		}
	}
}
