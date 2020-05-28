using UnityEngine;
using System.Collections;
using System.Collections.Generic;

namespace FX
{
    /// <summary>
    /// 残影特效
    /// </summary>
    public class FxTrailShadow : FxTiming
    {
        [SerializeField]
        private Transform m_Root;
        [SerializeField]
        private MeshFilter m_MeshFilter;
        [SerializeField]
        private SkinnedMeshRenderer m_Renderer;
        [SerializeField]
        private Shader m_Shader;
        [SerializeField]
        private string m_Property = "_Color";
        [SerializeField]
        private float m_Length = 0.1f;
        [SerializeField]
        private Gradient m_Gradient;
        [SerializeField]
        private float m_Interval = 0.0f;
        [SerializeField]
        private float m_Duration = 0f;
        [SerializeField]
        private float m_MinDistance = 0f;
        [SerializeField]
        private bool m_Follow = false;

        private SkinnedMeshRenderer m_AutoSkin;
        private float m_Last;
        
        private Material[] m_Materials;

        private class ShadowData {
            public MeshRenderer rdr;
            public float time;
            public MeshFilter GetFilter()
            {
                return rdr ? rdr.gameObject.NeedComponent<MeshFilter>() : null;
            }
            public ShadowData(string name)
            {
                var go = new GameObject(name);
                rdr = go.AddComponent<MeshRenderer>();
            }
        }
        private List<ShadowData> m_Shadows = new List<ShadowData>();

        private Vector3 m_PrevPos;

        protected override void Awake()
        {
            base.Awake();

            if (m_Shader == null) {
                m_Shader = Shader.Find("FX/TrailShadow");
            } else {
#if UNITY_EDITOR && !UNITY_STANDALONE
                m_Shader = Shader.Find(m_Shader.name);
#endif
            }
        }
        
        private void OnEnable()
        {
            time = 0;
            m_Last = -m_Interval;
        }

        private void OnDisable()
        {            
            Finished();
            
            if (m_AutoSkin) {
                m_AutoSkin = null;
                m_Root = null;
            }
        }

        private void Update()
        {
            if (m_MeshFilter == null && m_Renderer == null && m_AutoSkin == null) {
                var ctrl = GetComponent(typeof(IFxCtrl)) as IFxCtrl;
                if (ctrl != null && ctrl.holder != null) {
                    var view = ctrl.holder.view as ISkinView;
                    if (view != null && view.actor) {
                        m_AutoSkin = view.actor.GetComponentInChildren<SkinnedMeshRenderer>();
                        if (m_Root == null) m_Root = m_AutoSkin.transform;
                        m_PrevPos = m_Root.position;
                    }
                }
            }
            if (m_Root == null) return;
            
            float delta = deltaTime;
            if (delta > 0) {
                float curr = time;
                time += delta;
                if (time >= 0 && m_Last + m_Interval <= time) {
                    if (m_Duration == 0 || time < m_Duration) {
                        //var offset = m_Root.position - m_PrevPos;
                        if (Vector3.Distance(m_PrevPos, m_Root.position) >= m_MinDistance) {
                            BakeOneMesh();
                            m_Last = time;
                        }
                    }
                }

                for (int i = 0; i < m_Shadows.Count; ++i) {
                    var shadow = m_Shadows[i];
                    if (shadow.rdr.gameObject.activeInHierarchy) {
                        var t = (time - shadow.time) / m_Length;
                        for (int j = 0; j < shadow.rdr.materials.Length; ++j) {
                            var mat = shadow.rdr.materials[j];
                            mat.SetColor(m_Property, m_Gradient.Evaluate(t));
                        }
                        if (t >= 1f) shadow.rdr.gameObject.SetActive(false);
                    }
                }

                if (curr < m_Duration && time >= m_Duration) {
                    Finished();
                }
            }
            m_PrevPos = m_Root.position;
        }
                
        private int m_BakeIdx = 0;
        private ShadowData BakeOneMesh()
        {
            string frameName = string.Format("BakeFrame{0}", m_BakeIdx++);

            ShadowData shadow = null;
            for (int i = 0; i < m_Shadows.Count; ++i) {
                var data = m_Shadows[i];
                if (!data.rdr.gameObject.activeSelf) {
                    shadow = data;
                    shadow.rdr.gameObject.SetActive(true);
                    break;
                }
            }

            if (shadow == null) {
                shadow = new ShadowData(frameName);
                m_Shadows.Add(shadow);
            }
            shadow.time = time;

            var meshFilter = shadow.GetFilter();

            var skin = m_AutoSkin;
            if (skin == null) skin = m_Renderer;

            if (skin != null) {
                if (meshFilter.mesh == null) {
                    meshFilter.mesh = new Mesh() { name = "TrailShadow" };
                }
                skin.BakeMesh(meshFilter.mesh);
            } else {
                meshFilter.mesh = m_MeshFilter.mesh;
            }

            var rdr = shadow.rdr;
            if (m_Materials == null) {
                if (skin) {
                    rdr.materials = skin.materials;
                } else {
                    rdr.materials = m_MeshFilter.GetComponent<MeshRenderer>().materials;
                }
                for (int i = 0; i < rdr.materials.Length; ++i) {
                    var mat = rdr.materials[i];
                    mat.shader = m_Shader;
                }
                m_Materials = rdr.sharedMaterials;
            } else {
                rdr.sharedMaterials = m_Materials;
            }

            var trans = shadow.rdr.transform;
            if (m_Follow) {
                trans.SetParent(m_Root, false);
            } else {
                trans.position = m_Root.position;
                trans.rotation = m_Root.rotation;
            }
            return shadow;
        }

        public void Finished()
        {
			var maxDelay = 0f;
            for (int i = 0; i < m_Shadows.Count; ++i) {
                var shadow = m_Shadows[i];
                var delay = m_Length - (time - shadow.time);
				if (delay > maxDelay) maxDelay = delay;
                var meshFilter = shadow.GetFilter();
                if (meshFilter) {
                    Destroy(meshFilter.mesh, delay);
                    Destroy(shadow.rdr.gameObject, delay);
                }
            }
            m_Shadows.Clear();

            if (m_Materials != null) {
                for (int i = 0; i < m_Materials.Length; ++i) {
					Destroy(m_Materials[i], maxDelay);
				}
				m_Materials = null;
            }

            this.enabled = false;
        }
    }
}