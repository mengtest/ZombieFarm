using System.Collections;
using System.Collections.Generic;
using FMODUnity;
using UnityEngine;
using ZFrame.Tween;
using ZFrame.UGUI;

namespace World.View
{
    public class TrapSwitcher : TrapTrigger
    {
        [SerializeField]
        private GameObject m_Trap;

        private EntityView m_View;

        protected override void OnTrapEnter(Collider other)
        {
            ZTweener tw = FadeTool.DOFade(m_Trap, false, true);
            PlayTrapEnterSFX();
        }

        protected override void OnTrapExit(Collider other)
        {
            FadeTool.DOFade(m_Trap, false, false);
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

                if (bodyMat > 0)
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
    }
}
