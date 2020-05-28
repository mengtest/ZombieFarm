//
//  AffixView.cs
//  survive
//
//  Created by xingweizhen on 11/1/2017.
//
//

using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using MEC;
    
namespace World.View
{
    public class AffixView : MonoBehaviour
    {
        [SerializeField]
        private Animator m_Anim;

        [SerializeField]
        private Renderer m_Skin;
        public Renderer skin {
            get {
                if (m_Skin == null) {
                    m_Skin = GetComponentInChildren(typeof(Renderer)) as Renderer;
                }
                return m_Skin;
            }
        }
        
        public void OnActionStart(IEntity entity, IAction Action)
        {
            if (m_Anim) {
                m_Anim.ResetTrigger(AnimParams.BREAK);
                m_Anim.ResetTrigger(AnimParams.STOP);
                m_Anim.SetBool(AnimParams.RELEASE, false);

                var motion = Action.motion;
                var startIdx = motion.IndexOf('_');
                var endIdx = motion.LastIndexOf('_');
                if (startIdx >= 0 && startIdx < endIdx) {
                    motion = motion.Substring(startIdx + 1, endIdx - startIdx - 1);
                    m_Anim.Play(motion);
                }
            }
        }

        public void OnActionSuccess(IEntity entity, IAction Action)
        {
            if (m_Anim) {
                if (Action.oper == ACTOper.Charged) {
                    m_Anim.SetBool(AnimParams.RELEASE, true);
                }
            }
        }

        public void OnActionStop(IEntity entity, IAction Action)
        {
            if (m_Anim) {
                m_Anim.SetTrigger(AnimParams.STOP);
            }
        }

        public void OnActionBreak(IEntity entity)
        {
            if (m_Anim) {
                if (!m_Anim.GetBool(AnimParams.RELEASE)) {
                    m_Anim.SetTrigger(AnimParams.BREAK);
                }
            }
        }

        private IEnumerator<float> ShowAffix(float delay)
        {
            transform.localScale = Vector3.zero;
            yield return Timing.WaitForSeconds(delay);
            
            if (transform) {
                transform.localScale = Vector3.one;
            }
        }

        public void OnAttach()
        {
            var cld = GetComponent(typeof(Collider)) as Collider;
            if (cld) cld.enabled = false;

            var rigidbody = GetComponent(typeof(Rigidbody)) as Rigidbody;
            if (rigidbody) rigidbody.isKinematic = true;
        }

        public void DelayShow(float delay)
        {
            if (delay > 0) {
                Timing.RunCoroutine(ShowAffix(delay));
            }
        }

        public void OnDetach()
        {
            var cld = GetComponent(typeof(Collider)) as Collider;
            if (cld) cld.enabled = true;

            var rigidbody = GetComponent(typeof(Rigidbody)) as Rigidbody;
            if (rigidbody) rigidbody.isKinematic = false;
        }
    }
}
