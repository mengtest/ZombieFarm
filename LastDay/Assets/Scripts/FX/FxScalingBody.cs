using UnityEngine;
using System.Collections;
using System.Collections.Generic;

namespace FX
{
    public class FxScalingBody : FxTiming
    {
        public Shader scaleShader;
        public string propertyName = "_Color";
		[SerializeField]
		private string m_Action;
        [SerializeField]
        private int m_IgnoreLayer;

        public Vector3 scaleFrom = Vector3.one;
        public Vector3 scaleTo = Vector3.one;
        public AnimationCurve scaleCurve = AnimationCurve.Linear(0, 0, 1, 1);
        public Color colorFrom = Color.white;
        public Color colorTo = new Color(1, 1, 1, 0);
        public AnimationCurve colorCurve = AnimationCurve.Linear(0, 0, 1, 1);
        public float delay = 0;

        private Transform m_Actor;
        private List<Renderer> m_Rdrs = new List<Renderer>();

        private void OnEnable()
        {
            time = 0;
        }

        private void Update()
        {
            float curr = time;
            time += deltaTime;

            if (m_Actor) {
                float curveTime = time - delay;
                Vector3 v3 = Vector3.Lerp(scaleFrom, scaleTo, scaleCurve.Evaluate(curveTime));
                m_Actor.localScale = v3;
                float t = colorCurve.Evaluate(curveTime);
                Color c = Color.Lerp(colorFrom, colorTo, t);
                for (int i = 0; i < m_Rdrs.Count; ++i) {
					var rdr = m_Rdrs[i];
					for (int j = 0; j < rdr.materials.Length; ++j) {
						rdr.materials[j].SetColor(propertyName, c);
					}
                }
                return;
            }
            
            if (curr < delay && time >= delay) {
                var view = (GetComponent(typeof(IFxCtrl)) as IFxCtrl).holder.view as ISkinView;
				if (view != null) {
	                m_Actor = GoTools.NewChild(gameObject, view.actor).transform;
                    // 删除上面可能存在的特效
                    FxCtrl.DestroyFxesOn(m_Actor.gameObject);

                    for (int i = 0; i < m_Actor.childCount; ++i) {
                        var t = m_Actor.GetChild(i);
                        var tLayer = t.gameObject.layer;
                        if ((tLayer | m_IgnoreLayer) != 0) continue;
                        var rdr = t.GetComponent<Renderer>();
                        if (rdr) {
                            m_Rdrs.Add(rdr);
                            for (int j = 0; j < rdr.materials.Length; ++j) {
                                rdr.materials[j].shader = scaleShader;
                            }
                        }
                    }

					var animtion = m_Actor.GetComponent<Animation>();
					if (animtion) {
						if (string.IsNullOrEmpty(m_Action)) {
							animtion.enabled = false;
						} else {
							animtion.Play(m_Action);
						}
					}
				}
            }
        }

        private void OnDisable()
        {
            m_Rdrs.Clear();
            if (m_Actor) {
                Destroy(m_Actor.gameObject);
                m_Actor = null;
            }
        }
    }
}
