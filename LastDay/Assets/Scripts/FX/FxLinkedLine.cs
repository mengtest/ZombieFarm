using UnityEngine;
using System.Collections;

namespace FX
{
    /// <summary>
    /// 此特效应挂在目标身上
    /// </summary>
    [RequireComponent(typeof(IFxCtrl))]
    public class FxLinkedLine : MonoBehavior
    {
        [SerializeField]
        protected Transform m_Line;
        [SerializeField]
        protected FXPoint m_LookPoint;
        
        [SerializeField]
        protected Transform m_Look, m_Root;

        protected virtual void Start()
        {
            if (World.View.StageView.Instance) {
                m_Look = null;
                m_Root = null;
            }
        }
        
        protected virtual void Update()
        {
            if (m_Look == null) {
                var ctrl = GetComponent(typeof(IFxCtrl)) as IFxCtrl;
                m_Look = FxBoneType.GetBone(ctrl.caster.view as IFxHolder, m_LookPoint);
                m_Root = FxTool.GetFxAnchor(ctrl.holder.view as IFxHolder, gameObject).anchor;
                return;
            }

            if (m_Look && m_Root) {
                m_Line.LookAt(m_Look);
                m_Line.localScale = new Vector3(1, 1, Vector3.Distance(m_Look.position, m_Root.position));
            }
        }

        private void OnDisable()
        {
            m_Look = null;
            m_Root = null;
        }
    }
}
