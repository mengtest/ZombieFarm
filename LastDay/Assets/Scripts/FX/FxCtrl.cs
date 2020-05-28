using UnityEngine;
using UnityEngine.Assertions;
using UnityEngine.Serialization;
using System.Collections;
using System.Collections.Generic;
using World;
using ZFrame.UGUI;
//using PigeonCoopToolkit.Effects.Trails;

namespace FX
{
    public class FxCtrl : FxInst, IFxCfg
    {
        /// <summary>
        /// 全局特效质量等级配置
        /// </summary>
        public static int GLevel = int.MaxValue;

        /// <summary>
        /// 直接删除一个对象以及其子对象上的所有特效（方便）
        /// </summary>
        public static void DestroyFxesOn(GameObject go)
        {
            var list = ZFrame.ListPool<Component>.Get();
            go.GetComponentsInChildren(typeof(FxCtrl), list, true);
            foreach (var fx in list) Destroy(fx.gameObject);
            ZFrame.ListPool<Component>.Release(list);
        }
        
        [Description("所有模型")]
        private List<Renderer> meshes = new List<Renderer>();
        public List<Renderer> Meshes { get { return meshes; } }

        [Description("所有粒子")]
        private List<ParticleSystem> particles = new List<ParticleSystem>();
        public List<ParticleSystem> Particles { get { return particles; } }

        [Description("所有动画帧")]
        private List<Animation> animations = new List<Animation>();
        public List<Animation> Animations { get { return animations; } }

        [Description("所有动画机")]
        private List<Animator> animators = new List<Animator>();
        public List<Animator> Animators { get { return animators; } }

        [Description("所有缓动效果")]
        private List<Fading> m_Fadings = new List<Fading>();
        public List<Fading> fadings { get { return fadings; } }
        
        [Description("系统拖尾")]
        private List<TrailRenderer> unityTrails = new List<TrailRenderer>();
        public List<TrailRenderer> UnityTrails { get { return unityTrails; } }

        [Description("所有时钟")]
        private List<FxTiming> timings = new List<FxTiming>();
        public List<FxTiming> Timings { get { return timings; } }

        [FormerlySerializedAs("followObject"), SerializeField]
        private bool m_Follow = true;

        [FormerlySerializedAs("fadeOut"), SerializeField]
        private bool m_Fading = true;

        [FormerlySerializedAs("pooled"), SerializeField]
        private bool m_Pooled = true;

        [FormerlySerializedAs("autoDespwan"), SerializeField]
        protected float m_AutoDespwan = 0;

        [SerializeField]
        protected Transform[] m_SubFxes;

        public override bool IsFollow { get { return m_Follow; } }

        public override bool IsFading { get { return m_Fading; } }

        public override bool IsPooled { get { return m_Pooled; } set { m_Pooled = value; } }

        public override float autoDespwan { get { return m_AutoDespwan; } }

        private System.Action m_Action;
        private System.Action Updating;

        public override IObj holder {
            get { return base.holder; }
            set {
                base.holder = value;
                if(value != null) {
                    if (m_SubFxes != null && m_SubFxes.Length > 0) {
                        foreach (var sub in m_SubFxes) {
                            var anchor = FxTool.GetFxAnchor(value.view as IFxHolder, sub.gameObject);
                            if (anchor.anchor) {
                                sub.Attach(anchor.anchor, false);
                            }
                        }
                    }
                }
            }
        }

        private void TrimFxLevel()
        {
            var level = 0;
            var trans = cachedTransform.GetChild(0);
            while (trans != null & trans.childCount > 0) {
                trans = trans.GetChild(0);                
                level += 1;
                if (level > GLevel) {
                    trans.gameObject.SetActive(false);
                    break;
                }
                trans.gameObject.SetActive(true);
            }
        }

        protected override void Awake()
        {
            base.Awake();
            Updating = __Updating;
            CachedObjects();

#if UNITY_EDITOR
            Assert.IsNull(gameObject.GetComponent(typeof(FxChecker)),
                string.Format("{0}不应该挂载<FxChecker>！", prefab.name));
#endif
        }

        protected override void Start()
        {
            base.Start();

            SetEnable(true);
            if (gameObject.layer == LAYERS.Invisible) {
                SetVisible(false);
            }

            UpdateIgnoreTimeScale();
            Reset();

#if UNITY_EDITOR
            if (Application.isPlaying) {
                gameObject.NeedComponent(typeof(FxChecker));
            }
#endif
        }
        
        protected override void OnDisable()
        {
            if (unityTrails != null) {
                for (int i = 0; i < unityTrails.Count; ++i) {
                    unityTrails[i].Clear();
                }
            }

            base.OnDisable();
        }

        private void __Updating()
        {
            if (s_Paused && !ignoreGamePause) return;

            var delta = deltaTime;
            if (delta == 0) return;

            float curr = time;
            time += delta;
            if (ignoreTimeScale) {
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
            }

            ChkAutoDespwan(curr);
        }

        /// <summary>
        /// TODO: 对模型走的淡出效果
        /// </summary>
        private void Fading()
        {
            time -= deltaTime;
            //for (int i = 0; i < meshes.Count; ++i) {
            //    var mat = meshes[i].material;
            //    var colorName = "_Color";
            //    if (mat.HasProperty("_TintColor")) {
            //        colorName = "_TintColor";
            //    }
            //    var c = mat.GetColor(colorName);
            //    c.a = time;
            //    mat.SetColor(colorName, c);
            //}
        }

        protected override void Update()
        {
            m_Action.Invoke();
        }

        public void UpdateIgnoreTimeScale()
        {
            for (int i = animators.Count - 1; i >= 0; --i) {
                var ani = animators[i];
                if (ani.runtimeAnimatorController) {
                    animators[i].updateMode = IsUpdate() ? AnimatorUpdateMode.UnscaledTime : AnimatorUpdateMode.Normal;
                } else {
                    LogMgr.E("多余的动作控制器（缺少状态机）:{0}", ani.GetHierarchy());
                    Destroy(ani);
                    animators.RemoveAt(i);
                }
            }
        }

        public void Hide()
        {
            if (meshes != null) {
                for (int i = 0; i < meshes.Count; ++i) {
                    meshes[i].enabled = false;
                }
            }
        }

        public override void SetVisible(bool visible)
        {
            var layer = visible ? LAYERS.iFX : LAYERS.iInvisible;
            gameObject.layer = layer;
            for (int i = 0; i < particles.Count; ++i) {
                particles[i].gameObject.layer = layer;
            }
            for (int i = 0; i < unityTrails.Count; ++i) {
                unityTrails[i].gameObject.layer = layer;
            }

            for (int i = 0; i < meshes.Count; ++i) {
                meshes[i].gameObject.layer = layer;
            }
        }

        public override void Reset()
        {
            time = 0;
            m_Action = Updating;

            // 重置粒子的开始时间
            for (int i = 0; i < particles.Count; ++i) {
                ParticleSystem p = particles[i];
                p.Clear();
                p.Play();
                p.time = 0f;
            }
            for (int i = 0; i < animations.Count; ++i) animations[i].Play();
            for (int i = 0; i < animators.Count; ++i) animators[i].Rebind();    
            for (int i = 0; i < unityTrails.Count; ++i) unityTrails[i].Clear();
            for (int i = 0; i < timings.Count; ++i) timings[i].Reset();
        }

        public float Fade()
        {
            float delay = 0f;
            if (IsFading) {
                for (int i = 0; i < particles.Count; ++i) {
                    ParticleSystem p = particles[i];
                    if (p.main.loop && delay < p.main.duration) {
                        delay = p.main.duration;
                    }
                    p.Stop();
                }
                foreach (var trail in unityTrails) {
                    trail.enabled = false;
                }
                for (int i = 0; i < timings.Count; ++i) {
                    var t = timings[i];
                    t.enabled = false;
                }
            }
            Hide();
            //time = 1f;
            //m_Action = Fading;
            return delay;
        }

        public override float Stop(bool instanly)
        {
            if (!this) return 0f;

            float delay = 0;
            if (instanly) {
                Hide();
            } else {
                delay = Fade();
            }
            ObjectPoolManager.DestroyPooledScenely(gameObject, delay);
            return delay;
        }

        protected override void OnRecycle()
        {
            base.OnRecycle();
            SetEnable(false);

            if (cachedTransform) {
                foreach (var sub in m_SubFxes) {
                    if (sub) {
                        sub.SetParent(cachedTransform, false);
                    } else {
                        LogMgr.W("{0}的子特效丢失。", this.name);
                    }
                }
            }
        }

        protected void SetEnable(bool enable)
        {
            for (int i = 0; i < animations.Count; ++i) {
                animations[i].enabled = enable;
            }
            for (int i = 0; i < m_Fadings.Count; ++i) {
                m_Fadings[i].enabled = enable;
            }
            for (int i = 0; i < animators.Count; ++i) {
                animators[i].enabled = enable;
            }
            for (int i = 0; i < particles.Count; ++i) {
                particles[i].Pause(!enable);
            }
            for (int i = 0; i < meshes.Count; ++i) {
                meshes[i].enabled = enable;
            }
            for (int i = 0; i < unityTrails.Count; ++i) {
                unityTrails[i].enabled = enable;
            }
            for (int i = 0; i < timings.Count; ++i) {
                timings[i].enabled = enable;
            }
        }

        public override void OnPauseGame()
        {
            if (!ignoreGamePause) {
                SetEnable(false);
            }
        }

        public override void OnResumeGame()
        {
            if (!ignoreGamePause) {
                SetEnable(true);
            }
        }

        [ContextMenu("缓存对象")]
        public void CachedObjects()
        {
            GetComponentsInChildren(true, meshes);
            GetComponentsInChildren(true, particles);
            GetComponentsInChildren(true, animations);
            GetComponentsInChildren(true, animators);
            GetComponentsInChildren(true, m_Fadings);
            GetComponentsInChildren(true, unityTrails);
            GetComponentsInChildren(true, timings);

            Fade();
        }
    }
}
