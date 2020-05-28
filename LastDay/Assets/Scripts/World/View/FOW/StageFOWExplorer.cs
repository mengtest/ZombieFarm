using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace World.View
{
    public class StageFOWExplorer : FogOfWarExplorer, IFOWStatus
    {
        public bool active { get; set; }

        [SerializeField]
        private float m_RadiusFix = 0.5f;

        private IObj m_Obj;

        private Vector3 m_Pos;
        private Vector m_RoundCoord;
        private void SetCoord(Vector coord)
        {
            m_RoundCoord = coord;
            m_Pos = StageView.Local2World(m_RoundCoord);
        }

        private float CalcRadius()
        {
            var clientVision = Control.StageCtrl.clientVision;
            if (clientVision > 0) return clientVision;

            return m_Radius + m_RadiusFix;
        }

        public override float GetRadius()
        {
            return CalcRadius() * FogOfWarEffect.Instance.zoom;
        }

        protected override Vector3 GetPos()
        {
            return m_Pos + Vector3.one * FogOfWarEffect.Instance.extend;
        }

        public override void Tick(float deltaTime)
        {
            if (m_Obj == null) {
                m_Pos = transform.position;
                var view = GetComponent(typeof(IObjView)) as IObjView;
                if (view != null) {
                    m_Obj = view.obj;
                    SetCoord(m_Obj.coord);
                }
            } else {
                var zoom = FogOfWarEffect.Instance.zoom;
                var coord = m_Obj.coord;
                coord.x = (int)(coord.x * zoom + 0.5);
                coord.z = (int)(coord.z * zoom + 0.5);
                if (coord != m_RoundCoord) {
                    SetCoord(coord);
                }
            }

            base.Tick(deltaTime);
        }

        protected override void OnDisable()
        {
            base.OnDisable();
            m_Obj = null;
        }
    }
}
