using System.Collections;
using System.Collections.Generic;

namespace World
{
    using TimerPool = ZFrame.Pool<Timer>;
    using GroupPool = ZFrame.Pool<TimerGroup>;
    using TimerListPool = ZFrame.ListPool<Timer>;    

    public class TimerManager
    {
        public static List<Timer> GetPool()
        {
            return TimerListPool.Get();
        }

        public static void ReleasePool(List<Timer> list)
        {
            TimerListPool.Release(list);
        }

#if UNITY_EDITOR
        private int MaxTimerCount;
#endif

        private TimerPool m_Pool = new TimerPool(null, Timer.Reset);
        private GroupPool m_GroupPool = new GroupPool(TimerGroup.Init, TimerGroup.Reset);
        public void Recycle(ITimer timer)
        {
            var tm = timer as Timer;
            if (tm != null) {
                m_Pool.Release(tm);
            } else {
                m_GroupPool.Release(timer as TimerGroup);
            }
        }

        private List<ITimer> m_Timers = new List<ITimer>();
        private List<ITimer> m_Temp = new List<ITimer>();
        
        private int Manager(List<ITimer> list, IObj ID, string tag, string unique, TimerAction action)
        {
            int amount = 0;
            for (int i = 0; i < list.Count; ++i) {
                if (list[i].expire) continue;

                var tm = list[i] as Timer;
                if (tm != null) {
                    ActionOf(tm, ID, tag, unique, action, ref amount);
                } else {
                    foreach (var t in list[i] as TimerGroup) {
                        ActionOf(t, ID, tag, unique, action, ref amount);
                    }
                }
            }
            return amount;
        }

        private int ManagerOn(List<ITimer> list, IObj Whom, string tag, string unique, TimerAction action)
        {
            int amount = 0;
            for (int i = 0; i < list.Count; ++i) {
                if (list[i].expire) continue;

                var tm = list[i] as Timer;
                if (tm != null) {
                    ActionOn(tm, Whom, tag, unique, action, ref amount);
                } else {
                    foreach (var t in list[i] as TimerGroup) {
                        ActionOn(t, Whom, tag, unique, action, ref amount);
                    }
                }
            }
            return amount;
        }

        /// <summary>
        /// 创建一个定时器
        /// </summary>
        public Timer Get(IObj ID)
        {
            var tm = m_Pool.Get();
            tm.ID = ID;
            return tm;
        }

        /// <summary>
        /// 新增一个定时器
        /// </summary>
        public Timer New(IObj ID)
        {
            var tm = Get(ID);
            m_Temp.Add(tm);
            return tm;
        }

        /// <summary>
        /// 新增一个定时器组
        /// </summary>
        public TimerGroup NewGroup(IObj ID)
        {
            var grp = m_GroupPool.Get();
            grp.ID = ID;
            m_Temp.Add(grp);
            return grp;
        }

        public Timer Find(string unique)
        {
            return MatchTimer(m_Timers, unique) ?? MatchTimer(m_Temp, unique);
        }

        public void Update(int frameIndex)
        {
            for (int i = 0; i < m_Temp.Count;) {
                var tm = m_Temp[i];
                m_Temp.RemoveAt(i);

                if (tm.expire) {
                    Recycle(tm);
                } else {
                    m_Timers.Add(tm);
                }
            }
#if UNITY_EDITOR
            var count = m_Timers.Count;
            if (MaxTimerCount < count) {
                MaxTimerCount = count;
                LogMgr.D("最大定时器数量：{0}", MaxTimerCount);
            }
#endif

            for (int i = 0; i < m_Timers.Count; ) {
                var tm = m_Timers[i];
                tm.Update(frameIndex);
                if (tm.expire) {
                    m_Timers.RemoveAt(i);
                    Recycle(tm);
                } else i += 1;
            }
        }

        public void Reset()
        {
            m_Timers.Clear();
            m_Temp.Clear();
        }

        public int CountOf(IObj ID, string tag, string unique)
        {
            return Manager(m_Timers, ID, tag, unique, null)
                + Manager(m_Temp, ID, tag, unique, null);
        }
        
        public int CountOn(IObj Whom, string tag, string unique)
        {
            return ManagerOn(m_Timers, Whom, tag, unique, null)
                + ManagerOn(m_Timers, Whom, tag, unique, null);
        }

        /// <summary>
        /// 自定义消息处理
        /// </summary>
        /// <returns></returns>
        public int ManagerAll(IObj ID, string tag, string unique, TimerAction action)
        {
            return Manager(m_Timers, ID, tag, unique, action)
               + Manager(m_Temp, ID, tag, unique, action);
        }

        public int FinishOf(IObj ID, string tag, string unique)
        {
            return Manager(m_Timers, ID, tag, unique, FinishTimer)
                + Manager(m_Temp, ID, tag, unique, FinishTimer);
        }

        public int FinishOn(IObj Whom, string tag, string unique)
        {
            return ManagerOn(m_Timers, Whom, tag, unique, FinishTimer)
                + ManagerOn(m_Timers, Whom, tag, unique, FinishTimer);
        }

        public int BreakOf(IObj ID, string tag, string unique)
        {
            return Manager(m_Timers, ID, tag, unique, BreakTimer)
                + Manager(m_Temp, ID, tag, unique, BreakTimer);
        }

        public int BreakOn(IObj Whom, string tag, string unique)
        {
            return ManagerOn(m_Timers, Whom, tag, unique, BreakTimer)
                + ManagerOn(m_Timers, Whom, tag, unique, BreakTimer);
        }

        public int CancelOf(IObj ID, string tag, string unique)
        {
            return Manager(m_Timers, ID, tag, unique, CancelTimer)
                + Manager(m_Temp, ID, tag, unique, CancelTimer);
        }
        
        public int CancelOn(IObj Whom, string tag, string unique)
        {
            return ManagerOn(m_Timers, Whom, tag, unique, CancelTimer)
                + ManagerOn(m_Timers, Whom, tag, unique, CancelTimer);
        }

        /// <summary>
        /// 获取在目标身上的定时器
        /// </summary>
        public void GetTimersOn(IObj Whom, System.Type paramType, List<Timer> list)
        {
            MatchTimerOn(m_Timers, Whom, paramType, list);
            MatchTimerOn(m_Temp, Whom, paramType, list);
        }

        /// <summary>
        /// 获取目标持有的定时器
        /// </summary>
        public void GetTimersOf(IObj ID, System.Type paramType, List<Timer> list)
        {
            MatchTimerOf(m_Timers, ID, paramType, list);
            MatchTimerOf(m_Temp, ID, paramType, list);
        }
        
        #region Inner Timer Action
        public static readonly TimerAction FinishTimer = new TimerAction(__FinishTimer);
        private static void __FinishTimer(Timer tm)
        {
            tm.Finish();
        }

        public static readonly TimerAction BreakTimer = new TimerAction(__BreakTimer);
        private static void __BreakTimer(Timer tm)
        {
            tm.Break();
        }

        public static readonly TimerAction CancelTimer = new TimerAction(__CancelTimer);
        private static void __CancelTimer(Timer tm)
        {
            tm.Cancel();
        }
        #endregion

        private static Timer MatchTimer(List<ITimer> list, string unique)
        {
            for (int i = list.Count - 1; i >= 0; --i) {
                if (list[i].expire) continue;

                var tm = list[i] as Timer;
                if (tm != null) {
                    if (tm.unique == unique) return tm;
                } else {
                    foreach (var t in list[i] as TimerGroup) {
                        if (t.unique == unique) return tm;
                    }
                }
            }

            return null;
        }

        private static void MatchTimerOn(List<ITimer> timers, IObj whom, System.Type paramType, List<Timer> list)
        {
            for (int i = 0; i < timers.Count; ++i) {
                if (timers[i].expire) continue;

                var grp = timers[i] as TimerGroup;
                if (grp != null) {                    
                    grp.MatchParamOn(whom, paramType, list);
                } else {
                    var tm = timers[i] as Timer;
                    if (whom == null || tm.whom == whom) {
                        if (tm.IsParam(paramType)) list.Add(tm);
                    }
                }
            }
        }

        private static void MatchTimerOf(List<ITimer> timers, IObj ID, System.Type paramType, List<Timer> list)
        {
            for (int i = 0; i < timers.Count; ++i) {
                if (timers[i].expire) continue;

                var grp = timers[i] as TimerGroup;
                if (grp != null) {
                    grp.MatchParamOf(ID, paramType, list);
                } else {
                    var tm = timers[i] as Timer;
                    if (tm.ID == ID && tm.IsParam(paramType)) {
                        list.Add(tm);
                    }
                }
            }
        }

        private static void ActionOf(Timer tm, IObj ID, string tag, string unique, TimerAction action, ref int amount)
        {
            if (ID != null && ID != tm.ID) return;
            if (tag != null && tag != tm.tag) return;
            if (unique != null && unique != tm.unique) return;

            if (action != null) action.Invoke(tm);
            amount += 1;
        }


        private static void ActionOn(Timer tm, IObj Whom, string tag, string unique, TimerAction action, ref int amount)
        {
            if (Whom != null && Whom != tm.whom) return;
            if (tag != null && tag != tm.tag) return;
            if (unique != null && unique != tm.unique) return;

            if (action != null) action.Invoke(tm);
            amount += 1;
        }
    }

}
