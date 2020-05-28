using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace World.View
{
    using Control;

    public class DayNightView : MonoSingleton<DayNightView>
    {
        public enum EDayNight
        {
            None = 0,
            Day = 1,
            Night = 2,
        }

        public static int DayTIME = 3600, NightTIME = 3600;

        private float m_SetProgress = 0.5f;
        public float setProgress {
            get { return m_SetProgress; }
            set {
                if (m_SetProgress != value) {
                    m_SetProgress = value;
                    if (!enabled) {
                        ShowLight(value);
                    }
                }
            }
        }

        private float m_Vision;
        public float overrideVision;
        [Description("地图视野")]
        public float vision {
            get { return Mathf.Max(overrideVision, m_Vision); }
        }

        [SerializeField]
        private int m_Cycle = 3600 * 3;

        [SerializeField]
        private Gradient m_LightColor;
        [SerializeField]
        private AnimationCurve m_LightIntensity;
        [SerializeField]
        private AnimationCurve m_ShadowStrength;
        [SerializeField]
        private AnimationCurve m_LightAngle;

        [SerializeField, Range(0, 30)] private int m_Accuracy = 1;

        [SerializeField]
        private float m_Morning = 0, m_Dusk = 0.5f;

        [Description("太阳")]
        private Light m_MainLight;
        [Description("日期")]
        private System.DateTime m_Start;
        [Description("起始")]
        private float m_Seconds;

        private float m_DayS, m_DayE;

        private float m_Time;
        private Vector3 m_LightEuler;

        [SerializeField]
        private AnimationCurve m_DayNight;

        [SerializeField]
        private Gradient m_PointColor;

        private EDayNight m_emDayNight = EDayNight.None;
        public EDayNight dayNight { get { return m_emDayNight; } }

        public event System.Action<float> onValueChanged;

        private void Init()
        {
            m_Vision = 0;
            if (DayTIME == 0) {
                m_DayNight = AnimationCurve.Linear(0, 0, 1, 1);
                enabled = false;
                ShowLight(0.5f);
            } else if (NightTIME == 0) {
                m_DayNight = AnimationCurve.Linear(0, 0, 1, 1);
                enabled = false;
                ShowLight(0.08f);
            } else {
                enabled = true;

                if (m_Cycle == 0) {
                    m_Cycle = DayTIME + NightTIME;

                    var mid = (m_Morning + m_Dusk) / 2f;
                    var halfDay = DayTIME / 2f / m_Cycle;
                    m_DayS = mid - halfDay;
                    m_DayE = mid + halfDay;

                    m_DayNight = new AnimationCurve();
                    m_DayNight.AddKey(new Keyframe(0, 0));
                    m_DayNight.AddKey(new Keyframe(m_DayS, m_Morning));
                    m_DayNight.AddKey(new Keyframe(m_DayE, m_Dusk));
                    m_DayNight.AddKey(new Keyframe(1, 1));
                } else {
                    m_DayNight = AnimationCurve.Linear(0, 0, 1, 1);
                }

                var lua = LuaComponent.lua;
                lua.GetGlobal("os", "date2secs");
                lua.Func(1);
                var secs = lua.ToInteger(-1);
                lua.Pop(1);

                m_Start = new System.DateTime(1970, 1, 1, 8, 0, 0);
                m_Start = m_Start.AddSeconds(secs);

                m_Seconds = (m_Start.Hour * 3600 + m_Start.Minute * 60 + m_Start.Second) % m_Cycle;
                m_Time = Time.realtimeSinceStartup;
            }
        }

        protected override void Awaking()
        {
            base.Awaking();
            var go = GameObject.FindGameObjectWithTag(TAGS.MainLight);
            if (go) m_MainLight = go.GetComponent(typeof(Light)) as Light;

            if (m_MainLight != null) {
                m_LightEuler = m_MainLight.transform.eulerAngles;
            }

            m_Vision = -1;
            enabled = false;
        }

        // Update is called once per frame
        private void Update()
        {
            var realTime = Time.realtimeSinceStartup;
            var passTime = realTime - m_Time;
            if (m_Seconds + passTime > m_Cycle) {
                m_Time = realTime;
                m_Seconds = 0;
            }
            ShowLight((m_Seconds + passTime) / m_Cycle);
        }

        private void ShowLight(float progress)
        {
            if (m_MainLight) {
                progress = m_DayNight.Evaluate(progress);

                m_MainLight.color = m_LightColor.Evaluate(progress);
                m_MainLight.intensity = Mathf.Round(m_LightIntensity.Evaluate(progress) * 10) / 10;
                m_MainLight.shadowStrength = Mathf.Round(m_ShadowStrength.Evaluate(progress) * 10) / 10;

                var angle = Math.Round(m_LightAngle.Evaluate(progress), m_Accuracy);
                m_MainLight.transform.eulerAngles = new Vector3(angle, m_LightEuler.y, m_LightEuler.z);
                m_MainLight.transform.Rotate(Vector3.up, Math.Round(360 * progress, m_Accuracy), Space.World);

                if (onValueChanged != null) onValueChanged.Invoke(progress);
            }

            Shader.SetGlobalColor("CenterColor", m_PointColor.Evaluate(progress));

            EDayNight curDayNight = (progress < m_DayS || progress > m_DayE) ? EDayNight.Night : EDayNight.Day;
            if (m_Vision < 0 || curDayNight != m_emDayNight) {
                m_emDayNight = curDayNight;
                StageEnv stageEnv = StageCtrl.Instance.currEnv;
                if (stageEnv != null) {
                    m_Vision = m_emDayNight == EDayNight.Night ? stageEnv.nightVision : stageEnv.dayVision;
                }
                StageCtrl.SendLuaEvent("DayNightAlternate", (int)m_emDayNight);
            }
        }

        public void SetFixTime(float fixedTime)
        {
            if(m_Vision < 0) {
                Init();
            }

            enabled = StageCtrl.DayNight;
            if (fixedTime > 0) {
                enabled = false;
                ShowLight(fixedTime);
            }
        }
    }
}
