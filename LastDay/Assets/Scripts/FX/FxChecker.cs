using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace FX
{
    [RequireComponent(typeof(FxCtrl))]
    public class FxChecker : MonoBehavior
    {
        private FxCtrl m_Ctrl;
        [Description("最大模型数")]
        private int nMesh;
        [Description("最大粒子数")]
        private int nParticle;
        [Description("最大插件拖尾")]
        private int nBetterTrail;
        [Description("最大系统拖尾")]
        private int nUnityTrail;

        private void Awake()
        {
            m_Ctrl = GetComponent<FxCtrl>();
        }

        private void Start()
        {
#if UNITY_EDITOR
            if (FxAnalyzer.Instance) {
                nMesh = nParticle = nBetterTrail = nUnityTrail = 0;
                var analyze = FxAnalyzer.Instance.GetAnalyze(m_Ctrl.gameObject.name);
                analyze.SetLimit(m_Ctrl.Meshes.Count,
                    m_Ctrl.Particles.Count,
                    0,// m_Ctrl.BetterTrails.Count,
                    m_Ctrl.UnityTrails.Count);
            }
#else
            Destroy(this);
#endif
        }

        private void CountBatches(IList list, ref int max)
        {
            var n = 0;
            for (int i = 0; i < list.Count; ++i) {
                var com = list[i] as Component;
                if (com && com.gameObject.activeInHierarchy) {
                    n += 1;
                }
            }
            if (max < n) max = n;
        }

        private void Update()
        {
            CountBatches(m_Ctrl.Meshes, ref nMesh);
            CountBatches(m_Ctrl.Particles, ref nParticle);
            //CountBatches(m_Ctrl.BetterTrails, ref nBetterTrail);
            CountBatches(m_Ctrl.UnityTrails, ref nUnityTrail);
        }

        private void OnDisable()
        {
#if UNITY_EDITOR
            if (FxAnalyzer.Instance) {
                var analyze = FxAnalyzer.Instance.GetAnalyze(m_Ctrl.gameObject.name);
                analyze.SetMax(nMesh, nParticle, nBetterTrail, nUnityTrail);
            }
#endif
        }
    }
}
