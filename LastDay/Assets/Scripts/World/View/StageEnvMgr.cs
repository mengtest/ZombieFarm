using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace World.View
{
    using Control;

    public class StageEnv: IDataFromLua
    {
        public int weight;
        public float dayVision, nightVision;
        public string fx, fog;
        
        public void InitFromLua(System.IntPtr lua, int index)
        {
            weight = lua.GetValue(I2V.ToInteger, index, "weight");

            lua.GetField(index, "Env");
            {   
                dayVision = lua.GetNumber(-1, "dayVision");
                nightVision = lua.GetNumber(-1, "nightVision");
                fx = lua.GetString(-1, "fx");
                fog = lua.GetString(-1, "fog");
            }
            lua.Pop(1);
        }

        public override string ToString()
        {
            return string.Format("[{0}:{1}]", fx, weight);
        }
    }

    public class StageEnvMgr : IDataFromLua
    {
        private System.Random m_EnvRan;

        /// <summary>
        /// 环境更新间隔
        /// </summary>
        private int m_EnvDuration;
        public readonly List<StageEnv> EnvWeights = new List<StageEnv>();

        public StageEnv currEnv { get; private set; }

        private IEnumerator NextUpdate(float delay)
        {
            LogMgr.D("---> 【进入】天气循环 <---");
            var realTime = Time.realtimeSinceStartup + delay;

            for (; ; ) {
                while (StageCtrl.L != null && Time.realtimeSinceStartup < realTime) {
                    yield return null;
                }
                if (StageCtrl.L == null) break;

                UpdateEnv();
                WeatherView.LoadWeather(currEnv.fx);

                realTime = Time.realtimeSinceStartup + m_EnvDuration;
            }
            LogMgr.D("---> 【退出】天气循环 <---");
        }

        public void Clear()
        {
            EnvWeights.Clear();
        }

        public void InitFromLua(System.IntPtr lua, int index)
        {
            EnvWeights.Clear();
            
            m_EnvDuration = (int)lua.GetNumber(index, "envDura");
            
            lua.GetField(index, "EnvWeights");
            if (lua.IsTable(-1)) {
                lua.PushNil();
                while (lua.Next(-2)) {
                    var env = new StageEnv();
                    env.InitFromLua(lua, -1);
                    EnvWeights.Add(env);
                    lua.Pop(1);
                }
            }
            lua.Pop(1);

            currEnv = EnvWeights.Count > 0 ? EnvWeights[0] : null;

            lua.GetGlobal("os", "date2secs");
            lua.Func(-1);
            var secs = lua.ToInteger(-1);
            lua.Pop(1);

            if (m_EnvDuration > 0) {
                // TODO
                m_EnvRan = new System.Random(0);
                UpdateEnv(secs % 86400);

                WeatherView.LoadWeather(currEnv.fx);
                if (EnvWeights.Count > 1) {
                    StageCtrl.Instance.StartCoroutine(NextUpdate(secs % m_EnvDuration));
                }
            }
        }

        private void UpdateEnv(int secs = -1)
        {
            if (secs < 0) {
                var totalWeight = 0;
                foreach (var env in EnvWeights) totalWeight += env.weight;
                var currWeight = m_EnvRan.Next(totalWeight);

                var calcWeight = 0;
                foreach (var env in EnvWeights) {
                    calcWeight += env.weight;
                    if (calcWeight >= currWeight) {
                        currEnv = env;
                        break;
                    }
                }
            } else {
                for (int i = secs; i > 0; i -= m_EnvDuration) UpdateEnv();
            }
        }

    }
}
