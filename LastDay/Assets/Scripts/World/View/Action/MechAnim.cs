using System.Collections;
using System.Collections.Generic;
using FMODUnity;
using UnityEngine;

namespace World.View
{
    public class MechAnim : ObjAnim, IStatusAnim
    {
        [System.Serializable]
        public struct MechStatus
        {
            public int status;
            public GameObject go;
        }

        [SerializeField]
        private MechStatus[] m_Status;

        public void OnStatusChanged(int status)
        {
            foreach (var mech in m_Status) {
                mech.go.SetActive(mech.status == status);
            }
            PlaySFX(status);
        }
        
        public override void SetView(EntityView view)
        {
            base.SetView(view);
            if (m_View == null) return;

            var xObj = m_View.obj as XObject;
            var status = xObj != null ? xObj.status : 0;
            OnStatusChanged(status);
        }

        private void PlaySFX(int status)
        {
            if (m_View == null) return;

            var footstep = m_View.entity.Data.GetExtend("footstep");
            if (!string.IsNullOrEmpty(footstep)) {
                var emitter = FMODMgr.Play(footstep, transform.parent);
                emitter.SetParam("doorOpen", status);
            }
        }
    }
}
