using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace FX
{
    [RequireComponent(typeof(FxInst))]
    public class SfxPlayer : MonoBehaviour
    {
        [SerializeField]
        private AudioClip m_Clip;
        [SerializeField]
        private bool m_Loop;
        [SerializeField]
        private float m_Delay;

        private IEnumerator Play(float delay)
        {
            var fx = GetComponent<FxInst>();
            while (delay > 0) {
                delay -= fx.deltaTime;
                yield return null;
            }

            //var sfx = AudioMgr.Instance.PlaySfx(m_Clip, m_Loop);
            //if (sfx) {
            //    Transform parent = null;
            //    if (fx.holder != null && fx.holder.view != null) {
            //        parent = (fx.holder.view as Component).transform;
            //    }
            //    sfx.transform.SetParent(parent, false);
            //}
        }

        private void OnEnable()
        {
            StartCoroutine(Play(m_Delay));
        }
    }
}