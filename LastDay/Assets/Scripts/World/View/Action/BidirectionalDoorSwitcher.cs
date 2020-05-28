using System.Collections;
using System.Collections.Generic;
using FMODUnity;
using UnityEngine;
using ZFrame.Tween;
using ZFrame.UGUI;

namespace World.View
{
    public class BidirectionalDoorSwitcher : TrapTrigger
    {
        [SerializeField]private GameObject m_Trap;

        private EntityView m_View;
        private FadeGroup m_direction = FadeGroup.In;

        private ZTweener m_EnterTw, m_ExitTw;

        protected bool Authorizing(GameObject go)
        {
            var self = gameObject.GetComponentInParent(typeof(IObj)) as IObj;
            var tar = go.GetComponentInParent(typeof(IObj)) as IObj;
            if (self != null && tar != null) {
                return self.camp == 0 || tar.camp == 0 || self.camp == tar.camp;
            }

            return true;
        }

        protected override void OnTrapEnter(Collider other)
        {
            if (m_EnterTw != null && m_EnterTw.IsTweening()) return;
            
            if (!Authorizing(other.gameObject)) return;
            
            Vector3 offsetPos = other.transform.position - transform.position;
            Vector3 cross = Vector3.Cross(transform.forward, offsetPos.normalized);

            if (cross.y < 0) {
                m_direction = FadeGroup.In;
            } else {
                m_direction = FadeGroup.Out;
            }

            m_EnterTw = FadeTool.DOFade(m_Trap, m_direction, false, true);
            PlayTrapEnterSFX();
        }

        protected override void OnTrapExit(Collider other)
        {
            if (m_ExitTw != null && m_ExitTw.IsTweening()) return;

            if (!Authorizing(other.gameObject)) return;

            m_ExitTw = FadeTool.DOFade(m_Trap, m_direction, false, false);
            PlayTrapExitSFX();
        }

        private void InitEntityView()
        {
            m_View = transform.GetComponentInParent<EntityView>();
        }

        private void PlayTrapEnterSFX()
        {
            if (m_View == null) {
                InitEntityView();
            }
            var footstep = m_View.entity.Data.GetExtend("footstep");
            if (!string.IsNullOrEmpty(footstep)) {
                var emitter = FMODMgr.Play(footstep, transform.parent);
                emitter.SetParam("doorOpen", 1);

                var bodyMat = m_View.entity.Data.bodyMat;
                
                if (bodyMat> 0)
                    emitter.SetParam("showType", bodyMat);
            }
        }

        private void PlayTrapExitSFX()
        {
            if (m_View == null) {
                InitEntityView();
            }
            var footstep = m_View.entity.Data.GetExtend("footstep");
            if (!string.IsNullOrEmpty(footstep)) {
                var emitter = FMODMgr.Play(footstep, transform.parent);
                emitter.SetParam("doorOpen", 0);

                var bodyMat = m_View.entity.Data.bodyMat;

                if (bodyMat > 0)
                    emitter.SetParam("showType", bodyMat);
            }
        }

        private void OnDisable()
        {
            m_EnterTw = null;
            m_ExitTw = null;
            m_View = null;
        }
    }
}
