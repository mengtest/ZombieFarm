using UnityEngine;
using System.Collections;
using System.Collections.Generic;
//using PigeonCoopToolkit.Effects.Trails;

namespace FX
{
    public class FxUICtrl : MonoBehavior, IViewable
    {
        public bool ignoreTimeScale = false;
        public float autoDespwan = 0;
        [SerializeField]
        private bool m_AutoRecycle = false;
        //[SerializeField]
        //private bool m_RecycleOnDisable = false;

        //public RenderQueueModifier.RenderType renderType = RenderQueueModifier.RenderType.FRONT;
        float time;

        [Description("所有模型")]
        private List<MeshRenderer> meshes = new List<MeshRenderer>();
        [Description("所有粒子")]
        private List<ParticleSystem> particles = new List<ParticleSystem>();
        [Description("所有动画帧")]
        private List<Animation> animations = new List<Animation>();
        [Description("所有动画机")]
        private List<Animator> animators = new List<Animator>();
        //[Description("所有拖尾")]
        //private List<TrailRenderer_Base> betterTrails = new List<TrailRenderer_Base>();
        [Description("系统拖尾")]
        private List<TrailRenderer> unityTrails = new List<TrailRenderer>();
        [Description("所有时钟")]
        private List<FxTiming> timings = new List<FxTiming>();

        public List<ParticleSystem> allParticles { get { return particles; } }

        //private UIPanel m_Root;

        private void Awake()
        {
            CachedObjects();
        }

        private void UpdateIgnoreTimeScale()
        {
            for (int i = animators.Count - 1; i >= 0; --i) {
                var ani = animators[i];
                if (ani.runtimeAnimatorController) {
                    animators[i].updateMode = ignoreTimeScale ? AnimatorUpdateMode.UnscaledTime : AnimatorUpdateMode.Normal;
                } else {
                    LogMgr.E("多余的动作控制器（缺少状态机）:{0}/{1}", name, ani.GetHierarchy(transform));
                    Destroy(ani);
                }
            }

            //for (int i = 0; i < betterTrails.Count; ++i) {
            //    betterTrails[i].ignoreTimeScale = ignoreTimeScale;
            //}
        }

        // Use this for initialization
        private void Start()
        {
            UpdateIgnoreTimeScale();

            Reset();
            //RenderQueueModifier rdrQm = gameObject.NeedComponent<RenderQueueModifier>();
            //if (cachedTransform.parent) {
            //    if (rdrQm.m_target == null) {
            //        rdrQm.m_target = cachedTransform.parent.GetComponent<UIWidget>();
            //    }
            //    rdrQm.m_type = renderType;
            //    rdrQm.DoModify();
            //} else {
            //    LogMgr.E(string.Format("没有把UI特效{0}挂在一个GameObject下面", this));
            //    Destroy(gameObject);
            //}

            OnTransformParentChanged();
        }

        // Update is called once per frame
        private void Update()
        {
            float curr = time;
            if (ignoreTimeScale) {
                var delta = Time.unscaledDeltaTime;
                time += delta;
                if (GTime.IsPaused()) {
                    // 手动发射粒子
                    for (int i = 0; i < particles.Count; ++i) {
                        ParticleSystem p = particles[i];
                        p.Simulate(delta, true, false);
                    }
                    // 手动采样动画
                    for (int i = 0; i < animations.Count; ++i) {
                        Animation ani = animations[i];
                        if (ani.enabled) {
                            foreach (AnimationState state in ani) {
                                if (ani.IsPlaying(state.name)) {
                                    state.time += delta;
                                }
                            }
                            ani.Sample();
                        }
                    }
                } else {
                    for (int i = 0; i < particles.Count; ++i) {
                        ParticleSystem p = particles[i];
                        if (p.isPaused) p.Play(true);
                    }
                }
            } else {
                time += Time.deltaTime;
            }

            if (curr < autoDespwan && time >= autoDespwan) {
                Destroy(gameObject);
            }
        }

        private void OnTransformParentChanged()
        {
            var lc = GetComponentInParent<LuaComponent>();
            if (lc) {
                //var panel = lc.GetComponent<UIPanel>();
                //if (panel != m_Root) {
                //    if (m_Root) {
                //        var l = m_Root.GetComponent<LuaComponent>();
                //        if (l) l.Recycle -= OnUIRecycle;
                //        m_Root.onAlphaChanging -= OnAlphaChanging;
                //    }
                //    lc.Recycle += OnUIRecycle;
                //    m_Root = panel;
                //    m_Root.onAlphaChanging += OnAlphaChanging;
                //    SetVisible(m_Root.alpha > 0);
                //}
            }
        }

        private void OnAlphaChanging(float from, float to)
        {
            if (from != 0 && to == 0) {
                SetVisible(false);
            } else if (from != 1 && to == 1) {
                SetVisible(true);
            }
        }

        private void OnDisable()
        {
            //if (betterTrails != null) {
            //    for (int i = 0; i < betterTrails.Count; ++i) {
            //        betterTrails[i].ClearSystem(false);
            //    }
            //}

            if (unityTrails != null) {
                for (int i = 0; i < unityTrails.Count; ++i) {
                    unityTrails[i].Clear();
                }
            }

            //if (m_RecycleOnDisable || m_AutoRecycle && m_Root == null) {
            //    Destroy(gameObject);
            //}
        }

        private void OnUIRecycle(LuaComponent lc)
        {
            if (m_AutoRecycle) {
                Destroy(gameObject);
            }
        }

        private void OnRecycle()
        {
            //if (m_Root) {
            //    var lc = m_Root.GetComponent<LuaComponent>();
            //    if (lc) lc.Recycle -= OnUIRecycle;

            //    m_Root.onAlphaChanging -= OnAlphaChanging;
            //    m_Root = null;
            //}
        }

        private void OnDestroy()
        {
            OnRecycle();
        }

        public void SetVisible(bool visible)
        {
            var layer = visible ? LAYERS.UI : LAYERS.Invisible;
            if (particles != null) {
                for (int i = 0; i < particles.Count; ++i) {
                    particles[i].gameObject.layer = layer;
                }
            }
            //if (betterTrails != null) {
            //    for (int i = 0; i < betterTrails.Count; ++i) {
            //        betterTrails[i].gameObject.layer = layer;
            //    }
            //}
            if (unityTrails != null) {
                for (int i = 0; i < unityTrails.Count; ++i) {
                    unityTrails[i].gameObject.layer = layer;
                }
            }
            if (meshes != null) {
                for (int i = 0; i < meshes.Count; ++i) {
                    meshes[i].gameObject.layer = layer;
                }
            }
        }

        void IViewable.ShowView(float fadeTime)
        {
            SetVisible(true);
        }

        void IViewable.HideView(float fadeTime)
        {
            SetVisible(false);
        }

        public void Reset()
        {
            time = 0;
            // 重置粒子的开始时间
            if (particles != null) {
                for (int i = 0; i < particles.Count; ++i) {
                    ParticleSystem p = particles[i];
                    p.Clear();
                    p.Play();
                    p.time = 0f;
                }
            }
            //if (betterTrails != null) {
            //    for (int i = 0; i < betterTrails.Count; ++i) {
            //        betterTrails[i].Emit = true;
            //    }
            //}
            if (unityTrails != null) {
                for (int i = 0; i < unityTrails.Count; ++i) {
                    unityTrails[i].enabled = true;
                }
            }
            if (meshes != null) {
                for (int i = 0; i < meshes.Count; ++i) {
                    meshes[i].enabled = true;
                }
            }
            if (timings != null) {
                for (int i = 0; i < timings.Count; ++i) {
                    var t = timings[i];
                    t.enabled = true;
                    t.Reset();
                }
            }
        }

        public void CachedObjects()
        {
            GetComponentsInChildren(true, meshes);
            GetComponentsInChildren(true, particles);
            GetComponentsInChildren(true, animations);
            GetComponentsInChildren(true, animators);
            //GetComponentsInChildren(true, betterTrails);
            GetComponentsInChildren(true, unityTrails);
            GetComponentsInChildren(true, timings);
        }
    }
}
