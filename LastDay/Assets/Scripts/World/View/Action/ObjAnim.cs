using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;

namespace World.View
{
    public class ObjAnim : MonoBehavior, IPoolable
    {
        public enum Obstacle
        {
            None, Circle, Rect,
        }
        
        [SerializeField]
        private Animator m_Anim;
        public Animator anim { get { return m_Anim; } }

        [SerializeField] private Transform m_Head;
        [SerializeField] private Transform m_Body;
        [SerializeField] private Transform m_Foot;
        [SerializeField] private Transform m_Fire;

        public Transform head { get { return m_Head; } }
        public Transform body { get { return m_Body; } }
        public Transform foot { get { return m_Foot; } }
        public Transform fire { get { return m_Fire; } }

        [SerializeField] private Obstacle m_Obstacle = Obstacle.None;
        public Obstacle obstacle { get { return m_Obstacle; } }

        [SerializeField, NamedProperty("头顶高度")]
        protected float m_Height = 2f;
        public float height { get { return m_Height; } }
        
        [Description("View")]
        protected EntityView m_View;

        protected virtual void Awake()
        {
            if (m_Anim == null) {
                m_Anim = GetComponentInChildren(typeof(Animator)) as Animator;                
            }
        }

        protected virtual void Start()
        {
        }

        protected virtual void OnEnable()
        {
            if (m_Anim) {
                m_Anim.enabled = true;
                anim.Rebind();
                anim.ResetParamaters();
                anim.PlayInitState(AnimState.INIT);
            }
        }

        protected virtual void OnDisable()
        {
            if (m_Anim) {
                m_Anim.enabled = false;
            }
        }

        protected virtual void OnRecycle()
        {
            m_View = null;
        }

        public virtual void SetView(EntityView view)
        {
            m_View = view;
        }
        
        void IPoolable.OnRestart()
        {
            enabled = true;
            Start();            
        }

        void IPoolable.OnRecycle()
        {
            enabled = false;
            OnRecycle();
            
            transform.SetParent(StageView.Instance.transform);
            transform.localPosition = new Vector3(0, -999, 0);
        }

#if UNITY_EDITOR
        protected virtual void OnDrawGizmosSelected()
        {
            Gizmos.DrawCube(transform.position + Vector3.up * m_Height, new Vector3(0.8f, 0.2f, 0.05f));
        }
#endif
    }
}
