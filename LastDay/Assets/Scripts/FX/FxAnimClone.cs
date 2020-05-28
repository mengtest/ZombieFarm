using UnityEngine;
using System.Collections;
using System.Collections.Generic;

namespace FX
{
    public class FxAnimClone : FxFadingBody
    {
        [SerializeField]
        private bool m_CloneTarget = false;

        [SerializeField]
        private string m_ClipName = null;

        [SerializeField]
        private Vector3 m_Offset = Vector3.zero;

        [SerializeField]
        private int m_IgnoreLayer = 0;

        private GameObject m_Clone;
        private List<Renderer> m_Rdrs = new List<Renderer>();
        protected override List<Renderer> m_Target { get { return m_Rdrs; } }

        protected override void Prepare()
        {
            var fxC = GetComponent(typeof(IFxCtrl)) as IFxCtrl;
            var target = m_CloneTarget ? fxC.holder : fxC.caster;
            if (target != null) {
                view = target.view as IActionView;
                if (view != null) {
                    m_Clone = GoTools.NewChild(gameObject, view.actor);
                    // 删除上面可能存在的特效
                    FxCtrl.DestroyFxesOn(m_Clone);

                    var trans = m_Clone.transform;
                    trans.GetComponent<Animation>().Play(m_ClipName);
                    for (int i = 0; i < trans.childCount; ++i) {
                        var t = trans.GetChild(i);
                        var tLayer = t.gameObject.layer;
                        if ((tLayer | m_IgnoreLayer) != 0) continue;
                        var rdr = t.GetComponent<Renderer>();
                        if (rdr) {
                            rdr.enabled = true;
                            m_Rdrs.Add(rdr);
                        }
                    }
                    trans.localPosition = m_Offset;
                }
            }
        }

        protected override void PostFade(float t)
        {
            if (t == 0) view.ChangeShader(fadeShader, m_Rdrs);

            SetAlpha(Mathf.Lerp(0.5f, 0f, t));
            
            if (t == 1) {
                m_Clone.SetActive(false);
            }
        }

        protected override void PrepFade(float t)
        {
            if (t == 0) view.ChangeShader(fadeShader, m_Rdrs);

            SetAlpha(Mathf.Lerp(0, 0.5f, t));

            if (t == 1) {                
                m_Clone.SetActive(true);
                view.ResetSkin(m_Rdrs);
            }            
        }
        

        protected override void OnRecycle()
        {
            Destroy(m_Clone);
            m_Rdrs.Clear();
            view = null;
        }
    }
}
