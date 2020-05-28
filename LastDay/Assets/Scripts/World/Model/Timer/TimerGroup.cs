using System.Collections;
using System.Collections.Generic;

namespace World
{
    public sealed class TimerGroup : ITimer, IEnumerable<Timer>
    {
        private List<Timer> m_Timers = new List<Timer>();

        public IEnumerator<Timer> GetEnumerator()
        {
            return ((IEnumerable<Timer>)m_Timers).GetEnumerator();
        }

        IEnumerator IEnumerable.GetEnumerator()
        {
            return ((IEnumerable<Timer>)m_Timers).GetEnumerator();
        }
        
        public bool stopped { get { return m_Timers.Count == 0; } }
        
        public IObj ID { get; internal set; }

        public int beginning { get; private set; }
        public int duration { get; private set; }
        public int value { get; set; }

        public bool expire { get { return m_Timers.Count == 0; } }

        public string tag { get; private set; }

        /// <summary>
		/// 定时器异常回调
		/// </summary>
		private TimerAction onError;
        private TimerAction onCompleted;
        
        private void Stop()
        {
            if (m_Timers.Count > 0) {
                for (int i = m_Timers.Count - 1; i >= 0; --i) {
                    TimerManager.BreakTimer(m_Timers[i]);
                }
                m_Timers.Clear();
            }
        }

        private void Complete()
        {
            if (onCompleted != null) {
                //onCompleted(this, 0);
                onCompleted = null;
            }
        }

        public void Error()
        {
            Stop();
            if (onError != null) {
                //onError(this);
                onError = null;
            }
        }

        //public void Pause()
        //{
        //    for (int i = 0; i < m_Timers.Count; ++i) {
        //        var tm = m_Timers[i];
        //        if (!tm.stopped) {
        //            tm.Pause();
        //        }
        //    }
        //}

        //public void Resume()
        //{
        //    for (int i = 0; i < m_Timers.Count; ++i) {
        //        var tm = m_Timers[i];
        //        if (!tm.stopped) {
        //            tm.Resume();
        //        }
        //    }
        //}
        
        public void Update(int frameIndex)
        {
            bool complete = true;
            for (int i = 0; i < m_Timers.Count;) {
                var tm = m_Timers[i];
                tm.Update(frameIndex);
                if (tm.expire) {
                    complete = complete && tm.interval == tm.duration;
                    m_Timers.RemoveAt(i);
                    tm.ID.L.tmMgr.Recycle(tm);
                } else {
                    i += 1;
                }
            }

            if (m_Timers.Count == 0) {
                if (complete) {
                    Complete();
                } else {
                    Error();
                }
            }
        }

        public void AddTimer(Timer timer)
        {
            m_Timers.Add(timer);
            if (beginning > timer.beginning) beginning = timer.beginning;
            if (duration < timer.duration) duration = timer.duration;
        }

        public TimerGroup Regist(TimerAction onComplete, TimerAction onError)
        {
            this.onCompleted = onComplete;
            this.onError = onError;
            return this;
        }

        public TimerGroup SetTag(string tag)
        {
            this.tag = tag;
            return this;
        }
        
        public void MatchParamOf(IObj ID, System.Type paramType, List<Timer> list)
        {
            foreach (var tm in m_Timers) {
                if (tm.ID == ID && tm.IsParam(paramType)) {
                    list.Add(tm);
                }
            }
        }

        public void MatchParamOn(IObj whom, System.Type paramType, List<Timer> list)
        {
            foreach (var tm in m_Timers) {
                if (whom != null && tm.whom != whom) continue;
                if (tm.IsParam(paramType)) list.Add(tm);
            }
        }

        public override string ToString()
        {
            if (m_Timers.Count > 0) {
                var strbld = new System.Text.StringBuilder();
                for (int i = 0; i < m_Timers.Count - 1; ++i) {
                    strbld.AppendLine(m_Timers[i].ToString());
                }
                strbld.AppendLine(m_Timers[m_Timers.Count - 1].ToString());
                return strbld.ToString();
            } else {
                return string.Format("[{0}|[-]", tag);
            }
        }

        public static void Init(TimerGroup grp)
        {
            grp.beginning = int.MaxValue;
            grp.duration = 0;
        }

        public static void Reset(TimerGroup grp)
        {
            foreach (var tm in grp.m_Timers) {
                grp.ID.L.tmMgr.Recycle(tm);
            }

            grp.m_Timers.Clear();
            grp.ID = null;
            grp.tag = null;
            grp.onCompleted = null;
            grp.onError = null;
        }
    }
}
