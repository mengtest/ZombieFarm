//
//  HUDText.cs
//  survive
//
//  Created by xingweizhen on 10/27/2017.
//
//

using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using ZFrame.UGUI;
using ZFrame;

namespace World.View
{
    public class HUDText : MonoBehaviour, ITickable
    {
        private const int NUM_STRINGS = 1000;
        private static string[] _PositiveNums = new string[NUM_STRINGS];
        private static string[] _NegativeNums = new string[NUM_STRINGS];

        public static string GetNumString(int num)
        {
            string[] array = num > 0 ? _PositiveNums : _NegativeNums;
            var abs = Mathf.Abs(num);
            if (abs < NUM_STRINGS) {
                var ret = array[abs];
                if (ret == null) {
                    ret = num.ToString();
                    array[abs] = ret;
                }
                return ret;
            }

            return num.ToString();
        }

        public class Entity
        {
            public UIText label;
            public float duration;
            public float time;
            public AnimationCurve alphaCurve, scaleCurve;

            public void Update(float delta)
            {
                var rate = time / duration;
                label.alpha = alphaCurve.Evaluate(rate);
                label.transform.localScale = Vector3.one * scaleCurve.Evaluate(rate);
                var norm = label.rectTransform.anchoredPosition.normalized * CVar.FRAME_RATE;
                label.rectTransform.anchoredPosition += norm * delta;
                time += delta;
            }
        }
        private static Pool<Entity> EntityPool = new Pool<Entity>(null, OnEntityRelease);

        [SerializeField]
        private Transform m_Root;

        [SerializeField]
        private UIText m_Label;

        [SerializeField]
        private float m_Duration = 0.3f;

        [SerializeField]
        private float m_OriginalOffset = 50;

        private List<Entity> m_Actives;

        private ObjPool<UIText> m_Pool;

        private void Awake()
        {
            m_Actives = new List<Entity>();
            m_Pool = new ObjPool<UIText>(m_Label, OnGetLabel, OnReleaseLabel);
            m_Label.SetVisible(false);
            
            enabled = false;
        }

        bool ITickBase.ignoreTimeScale {
            get { return true; }
        }
        
        void ITickable.Tick(float delta)
        {
            for (int i = 0; i < m_Actives.Count;) {
                var entity = m_Actives[i];
                if (entity.time > m_Duration) {
                    Release(entity);
                    m_Actives.RemoveAt(i);
                    if (m_Actives.Count == 0) enabled = false;
                    continue;
                }

                entity.Update(delta);
                ++i;
            }
        }

        private void OnEnable()
        {
            TickManager.Add(this);
            gameObject.SetEnable(typeof(UIFollowTarget), true);
        }

        private void OnDisable()
        {
            for (int i = 0; i < m_Actives.Count; ++i) {
                Release(m_Actives[i]);
            }
            m_Actives.Clear();
            
            TickManager.Remove(this);
            gameObject.SetEnable(typeof(UIFollowTarget), false);
        }

        public void Follow(Transform follow)
        {
            UIFollowTarget.Follow(gameObject, follow).enabled = m_Actives.Count > 0;
        }

        public void Add(int num, Color color)
        {
            var entity = Get();
            entity.alphaCurve = StageView.curveL.GetCurve("Hud Number Alpha");
            entity.scaleCurve = StageView.curveL.GetCurve("Hud Number Scale");

            entity.label.text = GetNumString(num);
            entity.label.color = color;
            entity.label.rectTransform.anchoredPosition = Random.insideUnitCircle * m_OriginalOffset;
            entity.Update(0);
        }

        public void Add(string text, Color color)
        {
            var entity = Get();
            entity.alphaCurve = StageView.curveL.GetCurve("Hud Number Alpha");
            entity.scaleCurve = StageView.curveL.GetCurve("Hud Text Scale");

            entity.label.text = text;
            entity.label.color = color;
            entity.label.rectTransform.anchoredPosition = Random.insideUnitCircle * m_OriginalOffset;
            entity.Update(0);
        }

        private Entity Get()
        {
            var entity = EntityPool.Get();
            entity.label = m_Pool.Get();
            entity.label.Attach(m_Label.transform.parent);
            entity.time = 0;
            entity.duration = m_Duration;
            
            if (m_Actives.Count == 0) enabled = true;
            m_Actives.Add(entity);
            return entity;
        }

        private void Release(Entity entity)
        {
            m_Pool.Release(entity.label);
            EntityPool.Release(entity);
        }
        
        private static void OnEntityRelease(Entity entity)
        {
            entity.label = null;
            entity.alphaCurve = null;
            entity.scaleCurve = null;
        }

        private static System.Action<UIText> OnGetLabel = label => { label.SetVisible(true); };

        private static System.Action<UIText> OnReleaseLabel = label => { label.SetVisible(false); };
    }
}
