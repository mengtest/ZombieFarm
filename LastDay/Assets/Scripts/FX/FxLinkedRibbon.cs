using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace FX
{
    public class FxLinkedRibbon : FxLinkedLine
    {
        [SerializeField]
        private int m_Segments;
        [SerializeField]
        private Transform m_CtrlPoint;

        private LineRenderer m_Ribbon;

        protected override void Start()
        {
            base.Start();

            if (m_Line) {
                m_Ribbon = m_Line.GetComponent<LineRenderer>();
                if (m_Ribbon) {
                    m_Ribbon.positionCount = m_Segments;
                }
            }
        }
        
        protected override void Update()
        {
            if (m_Look == null) {
                var ctrl = GetComponent(typeof(IFxCtrl)) as IFxCtrl;
                m_Look = FxBoneType.GetBone(ctrl.caster.view as IFxHolder, m_LookPoint);
                m_Root = FxTool.GetFxAnchor(ctrl.holder.view as IFxHolder, gameObject).anchor;
                return;
            }

            if (m_Look && m_Root && m_Ribbon) {
                m_Ribbon.SetPosition(0, m_Root.position);
                m_Ribbon.SetPosition(m_Segments - 1, m_Look.position);
                for (int i = 0; i < m_Segments - 1; ++ i) {
                    var pos = FxMath.CalculateQuadBezierPoint((float)i / m_Segments,
                        m_Root.position, m_CtrlPoint.position, m_Look.position);
                    m_Ribbon.SetPosition(i, pos);
                }
                m_Ribbon.SetPosition(m_Segments - 1, m_Look.position);
            }
        }

       
    }
}
