using System.Collections;
using System.Collections.Generic;
using System.Linq;
using TMPro;
using UnityEngine;

namespace ZFrame
{
    public interface ITickBase
    {
        string name { get; }
        bool ignoreTimeScale { get; }
    }

    public interface ITickable : ITickBase
    {
        void Tick(float deltaTime);
    }

    public interface ILateTick : ITickBase
    {
        void LateTick(float deltaTime);
    }

    public interface IFixedTick : ITickBase
    {
        void FixedTick(float deltaTime);
    }

    public class TickManager : MonoSingleton<TickManager>
    {
        #region Update

        [Description("UpdateTicks")]
        private readonly List<ITickable> m_UpdateTicks = new List<ITickable>();

        [Description("LateUpdateTicks")]
        private readonly List<ILateTick> m_LateUpdateTicks = new List<ILateTick>();

        [Description("FixedUpdateTicks")]
        private readonly List<IFixedTick> m_FixedUpdateTicks = new List<IFixedTick>();

        private void Update()
        {
            var deltaTime = Time.deltaTime;
            var unscaledDeltaTime = Time.unscaledDeltaTime;
            for (int i = 0; i < m_UpdateTicks.Count; ++i) {
                var tick = m_UpdateTicks[i];
                UnityEngine.Profiling.Profiler.BeginSample(tick.name + ".Tick");
                tick.Tick(tick.ignoreTimeScale ? unscaledDeltaTime : deltaTime);
                UnityEngine.Profiling.Profiler.EndSample();
            }
        }

        private void LateUpdate()
        {
            var deltaTime = Time.deltaTime;
            var unscaledDeltaTime = Time.unscaledDeltaTime;
            for (int i = 0; i < m_LateUpdateTicks.Count; ++i) {
                var tick = m_LateUpdateTicks[i];
                UnityEngine.Profiling.Profiler.BeginSample(tick.name + ".LateTick");
                tick.LateTick(tick.ignoreTimeScale ? unscaledDeltaTime : deltaTime);
                UnityEngine.Profiling.Profiler.EndSample();
            }
        }

        private void FixedUpdate()
        {
            var deltaTime = Time.deltaTime;
            var unscaledDeltaTime = Time.unscaledDeltaTime;
            for (int i = 0; i < m_FixedUpdateTicks.Count; ++i) {
                var tick = m_FixedUpdateTicks[i];
                UnityEngine.Profiling.Profiler.BeginSample(tick.name + ".FixedTick");
                tick.FixedTick(tick.ignoreTimeScale ? unscaledDeltaTime : deltaTime);
                UnityEngine.Profiling.Profiler.EndSample();
            }
        }

        public static void Add(ITickBase tick)
        {
            if (Instance == null) return;

            var norm = tick as ITickable;
            if (norm != null && !Instance.m_UpdateTicks.Contains(norm)) Instance.m_UpdateTicks.Add(norm);

            var late = tick as ILateTick;
            if (late != null && !Instance.m_LateUpdateTicks.Contains(late)) Instance.m_LateUpdateTicks.Add(late);

            var @fixed = tick as IFixedTick;
            if (@fixed != null && !Instance.m_FixedUpdateTicks.Contains(@fixed)) Instance.m_FixedUpdateTicks.Add(@fixed);
        }

        public static void Remove(ITickBase tick)
        {
            if (Instance == null) return;

            var norm = tick as ITickable;
            if (norm != null) Instance.m_UpdateTicks.Remove(norm);

            var late = tick as ILateTick;
            if (late != null) Instance.m_LateUpdateTicks.Remove(late);

            var @fixed = tick as IFixedTick;
            if (@fixed != null) Instance.m_FixedUpdateTicks.Remove(@fixed);
        }

        #endregion
    }
}
