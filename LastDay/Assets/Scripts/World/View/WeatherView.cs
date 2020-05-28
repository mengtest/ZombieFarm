using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using FX;

namespace World.View
{
    public class WeatherView : MonoSingleton<WeatherView>
    {
        [SerializeField]
        private int m_Square = 3;

        [SerializeField]
        private Vector2 m_Grid = Vector2.one;

        [Description("当前环境")]
        public StageEnv currEnv { get { return Control.StageCtrl.Instance.currEnv; } }

        //[Description("环境列表")]
        //public List<StageEnv> envList { get { return Control.StageCtrl.Instance.envMgr.EnvWeights; } }

        private List<FxCtrl> m_Fxes;

        public static void LoadWeather(string weatherPath)
        {
            if (Instance) {
                if (!string.IsNullOrEmpty(weatherPath)) {
                    weatherPath = "fx/weather/" + weatherPath;
                    AssetsMgr.A.LoadAsync(typeof(GameObject), weatherPath,
                        ZFrame.Asset.LoadMethod.Default, Instance.OnWeatherLoaded);
                } else {
                    Instance.OnWeatherLoaded(null, null, null);
                }
            }
        }

        private void OnWeatherLoaded(string a, object o, object p)
        {
            if (m_Fxes != null) {
                foreach (var fx in m_Fxes) if (fx) fx.Stop(false);
                m_Fxes.Clear();
            }

            var prefab = o as GameObject;
            if (prefab) {
                if (m_Fxes == null) m_Fxes = new List<FxCtrl>(m_Square * m_Square);
                var center = StageView.Instance.camCenter.position;
                Vector3 offset = Vector3.zero;
                CalcOffset(out offset.x, out offset.z);
                var start = center - offset;
                GameObject fxGo = null;
                for (int i = 0; i < m_Square; ++i) {
                    for (int j = 0; j < m_Square; ++j) {
                        var go = GoTools.AddChild(gameObject, prefab, true);
                        go.name = string.Format("x{0}y{1}", i, j);
                        go.transform.position = start + new Vector3(m_Grid.x * i, 0, m_Grid.y * j);
                        m_Fxes.Add(go.GetComponent(typeof(FxCtrl)) as FxCtrl);
                        if (fxGo == null) fxGo = go;
                    }
                }

                if (fxGo != null) {
                    var list = ZFrame.ListPool<Component>.Get();
                    fxGo.GetComponents(typeof(IFxEvent), list);
                    foreach (IFxEvent evt in list) evt.OnFxInit();
                    ZFrame.ListPool<Component>.Release(list);
                }
            }
        }

        private void CalcOffset(out float x, out float y)
        {
            var offsetMulti = m_Square / 2f;
            x = m_Grid.x * offsetMulti;
            y = m_Grid.y * offsetMulti;
        }

        protected override void Awaking()
        {
            base.Awaking();

            if (currEnv != null) LoadWeather(currEnv.fx);
        }

        private void Update()
        {
            if (m_Fxes == null || m_Fxes.Count == 0) return;

            var center = StageView.Instance.camCenter.position;
            Vector2 offset = Vector2.zero;
            CalcOffset(out offset.x, out offset.y);

            foreach (var fx in m_Fxes) {
                if (fx == null) continue;

                var oldPos = fx.transform.position;

                var xOff = oldPos.x - center.x;
                var xOffAbs = Mathf.Abs(xOff);
                var newX = oldPos.x;
                if (xOffAbs > offset.x) {
                    newX = oldPos.x - m_Grid.x * m_Square * (xOff / xOffAbs);
                }

                var zOff = oldPos.z - center.z;
                var zOffAbs = Mathf.Abs(zOff);
                var newZ = oldPos.z;
                if (zOffAbs > offset.y) {
                    newZ = oldPos.z - m_Grid.y * m_Square * (zOff / zOffAbs);
                }

                if (newX != oldPos.x || newZ != oldPos.z) {
                    var newPos = new Vector3(newX, oldPos.y, newZ);
                    fx.transform.position = newPos;
                }
            }
        }
    }
}
