using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using FX;

namespace World.View
{
    public class FxSelectByGender : MonoBehaviour, IFxCfg
    {
        [SerializeField]
        private int m_Level;

        [SerializeField, NamedProperty("男性特效")]
        private FxObj m_MaleFx;

        [SerializeField, NamedProperty("女性特效")]
        private FxObj m_FemaleFx;

        IFxCtrl IFxCfg.Get(int i, object holder)
        {
            var xObj = holder as XObject;
            if (xObj != null && i == 0) {
                if (xObj.Data.gender == 2 && m_FemaleFx) {
                    return m_FemaleFx.fxCtrl;
                } else if (m_MaleFx) {
                    return m_MaleFx.fxCtrl;
                }
            }
            return null;
        }
        
        public int level { get { return m_Level; } }

#if UNITY_EDITOR
        public string FxChecking()
        {
            if (m_MaleFx == null || m_FemaleFx == null) {
                return string.Format("组内特效配置异常：MaleFx={0}；FemaleFx={1}", m_MaleFx, m_FemaleFx);
            }

            return null;
        }
#endif
    }
}

