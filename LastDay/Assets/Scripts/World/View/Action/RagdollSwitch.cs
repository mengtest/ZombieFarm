//
//  RagdollSwitch.cs
//  survive
//
//  Created by xingweizhen on 10/26/2017.
//
//

using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using MEC;

namespace World.View
{
    public class RagdollSwitch : MonoBehaviour, IDeadAction, IPoolable
    {
        [SerializeField, NamedProperty("持续时间")]
        protected float m_Duration = 5f;

        [System.Serializable]
        public class CharacterJointCfg
        {
            [SerializeField]
            private GameObject m_Go;
            public GameObject go { get { return m_Go; } }

            [SerializeField]
            private Rigidbody connectedBody;
            [SerializeField]
            private Vector3 anchor;
            [SerializeField]
            private Vector3 axis;
            [SerializeField]
            private bool autoConfigureConnectedAnchor;
            [SerializeField]
            private Vector3 connectedAnchor;
            [SerializeField]
            private Vector3 swingAxis;
            [SerializeField]
            private SoftJointLimitSpring twistLimitSpring;
            [SerializeField]
            private SoftJointLimit lowTwistLimit;
            [SerializeField]
            private SoftJointLimit highTwistLimit;
            [SerializeField]
            private SoftJointLimit swing1Limit;
            [SerializeField]
            private SoftJointLimit swing2Limit;
            [SerializeField]
            private bool enableProjection;
            [SerializeField]
            private float projectionDistance;
            [SerializeField]
            private float projectionAngle;
            [SerializeField]
            private float breakForce;
            [SerializeField]
            private float breakTorque;
            [SerializeField]
            private bool enableCollision;
            [SerializeField]
            private bool enablePreprocessing;
            [SerializeField]
            private float massScale;
            [SerializeField]
            private float connectedMassScale;

            public CharacterJointCfg(CharacterJoint joint)
            {
                m_Go = joint.gameObject;

                connectedBody = joint.connectedBody;
                anchor = joint.anchor;
                axis = joint.axis;
                autoConfigureConnectedAnchor = joint.autoConfigureConnectedAnchor;
                connectedAnchor = joint.connectedAnchor;
                swingAxis = joint.swingAxis;
                twistLimitSpring = joint.twistLimitSpring;
                lowTwistLimit = joint.lowTwistLimit;
                highTwistLimit = joint.highTwistLimit;
                swing1Limit = joint.swing1Limit;
                swing2Limit = joint.swing2Limit;
                enableProjection = joint.enableProjection;
                projectionDistance = joint.projectionDistance;
                projectionAngle = joint.projectionAngle;
                breakForce = joint.breakForce;
                breakTorque = joint.breakTorque;
                enableCollision = joint.enableCollision;
                enablePreprocessing = joint.enablePreprocessing;
                massScale = joint.massScale;
                connectedMassScale = joint.connectedMassScale;
            }

            public void Reset(CharacterJoint joint)
            {
                joint.connectedBody = connectedBody.isKinematic ? null : connectedBody;
                joint.anchor = anchor;
                joint.axis = axis;
                joint.autoConfigureConnectedAnchor = autoConfigureConnectedAnchor;
                joint.connectedAnchor = connectedAnchor;
                joint.swingAxis = swingAxis;
                joint.twistLimitSpring = twistLimitSpring;
                joint.lowTwistLimit = lowTwistLimit;
                joint.highTwistLimit = highTwistLimit;
                joint.swing1Limit = swing1Limit;
                joint.swing2Limit = swing2Limit;
                joint.enableProjection = enableProjection;
                joint.projectionDistance = projectionDistance;
                joint.projectionAngle = projectionAngle;
                joint.breakForce = breakForce;
                joint.breakTorque = breakTorque;
                joint.enableCollision = enableCollision;
                joint.enablePreprocessing = enablePreprocessing;
                joint.massScale = massScale;
                joint.connectedMassScale = connectedMassScale;
            }
        }

        private List<Rigidbody> m_Rigidbodies;
        private List<CharacterJoint> m_Joints;
        private List<CharacterJointCfg> m_JointCfgs;
        protected Vector3 m_Force;

        protected virtual void Awake()
        {
            m_Rigidbodies = new List<Rigidbody>();
            GetComponentsInChildren(m_Rigidbodies);

            m_Joints = new List<CharacterJoint>();
            GetComponentsInChildren(m_Joints);
            m_JointCfgs = new List<CharacterJointCfg>();
            foreach (var joint in m_Joints) {
                m_JointCfgs.Add(new CharacterJointCfg(joint));
                Destroy(joint);
            }
        }

        protected virtual void Start()
        {
            m_Force = Vector3.zero;
        }
                
        protected virtual bool HasBone(Transform bone)
        {
            return bone.localScale != Vector3.zero;
        }

        private void EnableRagdoll()
        {
            foreach (var rigid in m_Rigidbodies) {
                var hasBone = HasBone(rigid.transform);
                rigid.isKinematic = !hasBone;
                var cld = rigid.GetComponent(typeof(Collider)) as Collider;
                if (cld) cld.enabled = hasBone;
            }

            foreach (var cfg in m_JointCfgs) {
                if (HasBone(cfg.go.transform)) {
                    var joint = cfg.go.AddComponent(typeof(CharacterJoint)) as CharacterJoint;
                    cfg.Reset(joint);
                    m_Joints.Add(joint);
                }
            }
        }

        private void DisableRagdoll()
        {
            foreach (var rigid in m_Rigidbodies) {
                rigid.isKinematic = true;
                var cld = rigid.GetComponent(typeof(Collider)) as Collider;
                if (cld) cld.enabled = false;
            }
            foreach (var joint in m_Joints) {
                Destroy(joint);
            }
            m_Joints.Clear();
        }

        protected virtual void FinishRagdoll()
        {
            DisableRagdoll();
        }

        private IEnumerator<float> FinishRagdoll(Vector3 force, float delay)
        {
            yield return Timing.WaitForOneFrame;
            gameObject.SetEnable(typeof(Animator), false);

            EnableRagdoll();

#if RAGDOLL_ENABLE_FORCE
            force += m_Force;
            if (force != Vector3.zero) {
                float maxY = float.MinValue, minY = float.MaxValue;
                foreach (var rigid in m_Rigidbodies) {
                    var pos = rigid.transform.position;
                    if (pos.y > maxY) maxY = pos.y;
                    if (pos.y < minY) minY = pos.y;
                }

                var range = maxY - minY;
                foreach (var rigid in m_Rigidbodies) {
                    if (!rigid.isKinematic) {
                        var y = rigid.transform.position.y - minY;
                        var power = y / range;
                        rigid.AddForce(force * power, ForceMode.Impulse);
                    }
                }
            }
#endif

            yield return Timing.WaitForSeconds(delay - Control.ObjCtrl.FADING_DURA);

            if (this) FinishRagdoll();
        }
        
        protected void ShowRagdoll(IEntity entity, IObj source, float power)
        {
            Vector3 force = Vector3.zero;
            if (source != null) {
                var direction = StageView.Local2World(entity.coord) - StageView.Local2World(source.pos);
                force = direction.normalized * power;
            } else {
                force = StageView.FwdLocal2World(entity.forward) * -1;
            }

            Timing.RunCoroutine(FinishRagdoll(force, m_Duration));
        }

        public virtual void InitAction(IEntity entity)
        {
            gameObject.SetEnable(typeof(Animator), true);
            DisableRagdoll();
        }

        public virtual void ShowAction(IEntity entity, ref DisplayValue Val)
        {
            if (Val.valid) {
                var view = entity.view as EntityView;
                if (view != null) view.recycleDelay += m_Duration;

                view.recycleDelay += m_Duration;
                ShowRagdoll(entity, Val.source, Val.force);
            }
        }

        public virtual void OnRestart()
        {
            Start();
        }

        public virtual void OnRecycle()
        {
            DisableRagdoll();
        }
    }
}
