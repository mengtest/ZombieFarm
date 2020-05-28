using UnityEngine;
using UnityEngine.Assertions;
using System.Collections;

namespace World.View
{
    using FX;
    public class MissileView : ObjView
    {
        [SerializeField]
        private FXPoint m_ToPoint;
        [SerializeField]
        private bool m_KeepHeight;

        private IMissileCurve m_Curve;

        #region 弹道飞行轨迹
        public Vector3 srcPos { get; private set; }
        public Vector3 dstPos { get { return m_Target ? m_Target.position : m_Pos; } }
        private Vector3 m_Pos;
        private Transform m_Target;
        #endregion

        private int m_ReachedCount;

        private Missile m_Missile;
        public override IObj obj { get { return m_Missile; } }
        
        private void Awake()
        {
            m_Curve = GetComponent(typeof(IMissileCurve)) as IMissileCurve;
        }

        public override void Subscribe(IObj o)
        {
            if (m_Missile == null) m_Missile = o as Missile;

            m_Missile.Launch += OnLaunch;
            m_Missile.Flying += OnFlying;
            m_Missile.Reached += OnReached;
            m_Missile.Destrut += OnDestrut;

            m_Missile.view = this;
            m_ReachedCount = 0;
        }

        public override void Unsubscribe()
        {
            if (m_Missile != null && m_Missile.view != null) {
                m_Missile.Launch -= OnLaunch;
                m_Missile.Flying -= OnFlying;
                m_Missile.Reached -= OnReached;
                m_Missile.Destrut -= OnDestrut;

                if (this.Equals(m_Missile.view)) {
                    m_Missile.view = null;
                }
            }
        }
        
        //public override void DestroySelf(float delay = 0)
        //{
        //    var fx = GetComponent<FxCtrl>();
        //    if (fx) {
        //        fx.Stop(delay == 0);
        //    } else {
        //        FxTool.DestroyPooled(gameObject);
        //    }
        //}

        private void OnLaunch(Missile obj, float t)
        {
            var trans = m_ReachedCount == 0 ?
                FxTool.GetFxAnchor(obj.launchUnit.view as IFxHolder, gameObject).anchor :
                FxBoneType.GetBone(obj.launchUnit.view as IFxHolder, m_ToPoint);

            if (trans) {
                srcPos = trans.position;
            } else {
                srcPos = cachedTransform.position;
            }
            m_Pos = StageView.Local2World(obj.targetPoint.coord);
            if (m_ToPoint != FXPoint.Foot) m_Pos.y = srcPos.y;

            m_Target = FxBoneType.GetBone(obj.targetPoint.view as IFxHolder, m_ToPoint);

            cachedTransform.position = srcPos;
            cachedTransform.forward = (dstPos - srcPos).normalized;

            OnFlying(obj, t);
        }

        private void OnFlying(Missile obj, float t)
        {
            var prev = cachedTransform.position;
            var dst = dstPos;
            if (m_KeepHeight) {
                dst.y = srcPos.y;
            }
            var curr = m_Curve == null ? Vector3.Lerp(srcPos, dst, t) : m_Curve.Evaluate(t);
            cachedTransform.position = curr;
            if (curr != prev) {
                cachedTransform.forward = (curr - prev).normalized;
            }
        }

        private void OnReached(Missile obj, float t)
        {
            m_ReachedCount += 1;
        }

        public void OnDestrut(Missile obj, float t)
        {
            if (m_Missile != null) {
                Unsubscribe();
                m_Missile = null;
                var fx = GetComponent<FxCtrl>();
                if (fx) {
                    fx.Stop(false);
                } else {
                    FxTool.DestroyPooled(gameObject);
                }
            }
        }
    }
}
