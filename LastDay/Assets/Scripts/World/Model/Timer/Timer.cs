using System.Collections;
using System.Collections.Generic;
using UnityEngine.Assertions;

namespace World
{
    public delegate void TimerAction(Timer tm);
    public delegate bool TimerHandler(Timer tm, int n);

    public interface ITimer
    {
        IObj ID { get; }

        int beginning { get; }
        int duration { get; }
        int value { get; }
        bool expire { get; }

        string tag { get; }

        void Update(int frameIndex);
    }

    public interface ITimerParam
    {

    }

    public class Timer : ITimer, System.IComparable<ITimer>, IEventParam
    {
        public IObj ID { get; internal set; }
        public IObj who { get; protected set; }
        public IObj whom { get; protected set; }
        public int duration { get; protected set; }
        public int interval { get; protected set; }
        public int beginning { get; protected set; }
        /// <summary>
        /// 定时器已失效
        /// </summary>
        public bool expire { get; protected set; }
        public string tag { get; protected set; }

        /// <summary>
        /// 正式计数前的延迟
        /// </summary>
        public int delay { get; protected set; }

        public string unique { get; protected set; }
        public ITimerParam param { get; protected set; }
        public int arg { get; protected set; }
        public int value { get; set; }


        protected TimerHandler OnUpdate;
        protected TimerHandler OnFinish;
        protected TimerHandler OnBreak;

        protected System.Action<bool, object> m_OnRecycle;
        protected object m_RecycleObj;
        public object recycleObj { get { return m_RecycleObj; } }

        public Timer()
        {

        }

        public static void Reset(Timer tm)
        {
            tm.ID = null;
            tm.who = null;
            tm.whom = null;

            tm.tag = null;
            tm.unique = null;
            tm.param = null;
            tm.arg = 0;
            tm.value = 0;
            tm.OnUpdate = null;
            tm.OnFinish = null;
            tm.OnBreak = null;
        }

        public override string ToString()
        {
            if (ID != null) {
                return string.Format("[{0}]{1}->{2}|{3}/{4}:{5}<{6}>",
                    tag + "-" + unique, who, whom, ID.L.frameIndex - beginning, duration, interval, param);
            }

            return base.ToString();
        }

        public Timer Init(IObj who, IObj whom, int duration, int interval, int delay)
        {
            Assert.IsNotNull(who);
            if (duration < 1) duration = 1;

            this.who = who;
            this.whom = whom;
            this.interval = interval > 0 ? interval : duration;
            this.duration = duration;

            beginning = ID.L.frameIndex + delay;
            expire = false;

            return this;
        }

        public Timer SetParam(ITimerParam param)
        {
            this.param = param;
            return this;
        }

        public bool IsParam(System.Type paramType)
        {
            return paramType == null ||
                param != null && paramType.IsAssignableFrom(param.GetType());
        }

        public Timer SetIdentify(string tag, string unique)
        {
            this.tag = tag;
            this.unique = unique;
            return this;
        }

        public Timer SetEvent(TimerHandler onUpdate, TimerHandler onFinish, TimerHandler onBreak)
        {
            this.OnUpdate = onUpdate;
            this.OnFinish = onFinish;
            this.OnBreak = onBreak;
            return this;
        }

        public Timer SetTarget(IObj whom)
        {
            this.whom = whom;
            return this;
        }

        public Timer SetValue(int value)
        {
            this.value = value;
            return this;
        }

        public Timer SetRecycle(System.Action<bool, object> onRecycle, object param)
        {
            m_OnRecycle = onRecycle;
            m_RecycleObj = param;
            return this;
        }

        public void Update(int frameIndex)
        {
            if (expire) return;

            int passFrame = frameIndex - beginning;
            if (passFrame > 0 && passFrame % interval == 0) {
                if (OnUpdate != null) {
                    if (!OnUpdate.Invoke(this, passFrame / interval)) {
                        Break();
                    }
                }
            }
            if (passFrame >= duration) {
                Finish();
            }
        }

        public void Finish()
        {
            if (!expire) {
                Recycle(false);
                if (OnFinish != null) OnFinish.Invoke(this, 0);
            }

        }

        public void Break()
        {
            if (!expire) {
                Recycle(true);
                if (OnBreak != null) OnBreak.Invoke(this, 0);
            }

        }

        public void Cancel()
        {
            Recycle(false);
        }

        public void Recycle(bool interrupt, bool expire = true)
        {
            this.expire = expire;
            if (m_OnRecycle != null) {
                m_OnRecycle.Invoke(interrupt, m_RecycleObj);
                m_OnRecycle = null;
                m_RecycleObj = null;
            }
        }

        int System.IComparable<ITimer>.CompareTo(ITimer other)
        {
            var xLast = beginning + duration;
            var yLast = other.beginning + other.duration;
            if (xLast == yLast) return value - other.value;
            return xLast - yLast;
        }

        /// <summary>
        /// 前摇定时器唯一标识
        /// </summary>
        public static string GenPreCasting(int skillId, int objId)
        {
            return string.Format("ready#{0}@{1}", skillId, objId);
        }

        /// <summary>
        /// 施法完成唯一标识
        /// </summary>
        public static string GenCasting(int skillId, int objId)
        {
            return string.Format("cast#{0}@{1}", skillId, objId);
        }

        /// <summary>
        /// 后摇定时器唯一标识
        /// </summary>
        public static string GenPosting(int skillId, int objId)
        {
            return string.Format("casted#{0}@{1}", skillId, objId);
        }

        public static string GenHolding(int subId, int objId)
        {
            return string.Format("hold#{0}@{1}", subId, objId);
        }

        public static string GenEffecting(int effId, int objId, int n)
        {
            return string.Format("effect#{0}@{1}x{2}", effId, objId, n);
        }
    }

    public static class TTags
    {
        public const string NONE = "none";
        public const string CAST = "cast";
        public const string POST = "cast";
        public const string HOLD = "cast";
        public const string AURA = "aura";
        public const string DOT = "dot";
        public const string KNOCK = "KONCK";
    }
}
