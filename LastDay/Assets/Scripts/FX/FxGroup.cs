using UnityEngine;
using System.Collections;
using System.Collections.Generic;

namespace FX
{
    public sealed class FxGroup : MonoBehaviour, IFxCfg
    {
        [SerializeField]
        private int m_Level = 0;
        public int level { get { return m_Level; } }
        public List<FxObj> ctrls;


        int IFxCfg.level { get { return m_Level; } }
        IFxCtrl IFxCfg.Get(int i, object holder)
        {
            if (ctrls != null && i >= 0 && i < ctrls.Count) {
                var ctrl = ctrls[i];
                if (ctrl) return ctrl.fxCtrl;
            }
            return null;
        }

#if UNITY_EDITOR
        public string FxChecking()
        {
            if (ctrls == null || ctrls.Count == 0) {
                return "组内不存在有效的特效配置";
            }

            for (int i = 0; i < ctrls.Count; ++i) {
                if (ctrls[i] == null) {
                    return string.Format("组内第{0}个特效为空。", i);
                }
            }

            return null;
        }
#endif
    }
}
