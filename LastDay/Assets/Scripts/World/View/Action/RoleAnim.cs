//
//  RoleAnim.cs
//  survive
//
//  Created by xingweizhen on 10/14/2017.
//
//

using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;
using FMODUnity;
using FX;
using ZFrame;

namespace World.View
{
    public class RoleAnim : ObjAnim, ITickable
    {
        private const float SPEED_LIMIT = 0.1f;
        private const float SPEED_ZERO = 0.01f;
        private const float SPEED_THRESHOLD_FX = 1.5f;

        [SerializeField]
        private float m_NormSpeed = 1f;
        [SerializeField]
        private float m_SneakSpeed = 0.5f;

        [SerializeField]
        private Transform[] m_Feet;

        private int m_Step;

        public Transform GetFootTrans()
        {
            if (m_Feet != null) {
                var footIndex = m_Step - 1;
                return footIndex < m_Feet.Length ? m_Feet[footIndex] : transform;
            }
            return transform;
        }

        #region Animation Events
        private void PlayFootstepSFX()
        {
            if (!enabled) return;

            var smoothRate = anim.GetFloat(AnimParams.SMOOTH_SPEED);
            if (m_View.obj != null && smoothRate > SPEED_ZERO) {
                NavMeshHit hit;
                var trans = GetFootTrans();
                var surface = 0;
                string footFx = null;
                if (NavMesh.SamplePosition(trans.position, out hit, 1f, NavMesh.AllAreas)) {
                    UpdateFootstep(hit.position);
                    switch (hit.mask) {
                        case NavMask.GRASS:
                            surface = 1;
                            footFx = "Move/Move_Grass";
                            break;
                        case NavMask.ROCK: surface = 2; break;
                        case NavMask.METAL: surface = 3; break;
                        case NavMask.WOOD: surface = 4; break;
                        case NavMask.WATER:
                            surface = 5;
                            footFx = "Move/Move_Water";
                            break;
                        default: break;
                    }
                }

                var mover = m_View.entity as IMovable;
                if (mover != null) {
                    var shiftingRate = mover.shiftingRate;
                    var footstep = m_View.entity.Data.GetExtend("footstep");
                    if (!string.IsNullOrEmpty(footstep)) {
                        var emitter = FMODMgr.Play(footstep, transform.parent);
                        emitter.SetParam("footspeed", smoothRate * shiftingRate);
                        emitter.SetParam("surface", surface);
                        emitter.SetParam("shoes", m_View.IsDress(DressType.Feet) ? 1 : 0);
                        emitter.SetGender(mover);
                    }

                    var fullSpeed = shiftingRate < 1f ? m_SneakSpeed : m_NormSpeed;
                    if (fullSpeed * smoothRate / mover.shiftingRate > SPEED_THRESHOLD_FX) {
                        m_View.obj.PlayFx(m_View.entity, footFx);
                    }
                }
            }
        }

        private void OnNormalStep(int step)
        {
            if (m_Step != step) {
                m_Step = step;
                PlayFootstepSFX();
            }
        }

        private void OnSneakStep(int step)
        {
            m_Step = step;
            PlayFootstepSFX();
        }

        #endregion

        public override void SetView(EntityView view)
        {
            base.SetView(view);
            if (m_View == null) return;

            m_LastPos = cachedTransform.position;
            anim.SetFloat(AnimParams.SMOOTH_SPEED, 0);
        }

        public void ResetIdle(HumanView view, float duration)
        {
            if (!enabled) return;

            var mover = view.obj as IMovable;
            var pose = view.pose;
            if (pose < 0) return;

            var speed = mover != null ? mover.GetMovingSpeed() : 0f;
            var shiftingRate = mover != null ? mover.shiftingRate : 1f;
            var normalizedTime = anim.GetCurrentAnimatorStateInfo(0).normalizedTime;

            int stateNameHash = 0;
            if (shiftingRate < 1) {
                if (speed > 0) {
                    anim.GetStateHash(IdleState.sneak, pose, out stateNameHash);
                } else {
                    anim.GetStateHash(IdleState.stealth, pose, out stateNameHash);
                }
            } else {
                anim.GetStateHash(IdleState.normal, pose, out stateNameHash);
            }

            if (duration > 0) {
                anim.CrossFadeInFixedTime(stateNameHash, duration, 0, normalizedTime);
            } else {
                anim.Play(stateNameHash, 0, normalizedTime);
            }

        }

        public float CalcFadeTime()
        {
            if (anim) {
                var state = anim.GetStateInfo(0);
                if (state.tagHash != AnimTags.IDLE) return 0.1f;

                state = anim.GetStateInfo(1);
                if (state.tagHash != AnimTags.IDLE) return 0.1f;

                state = anim.GetStateInfo(2);
                if (state.tagHash != AnimTags.IDLE) return 0.1f;
            }
            return 0;
        }

        public void Rewind()
        {
            var view = m_View as HumanView;
            if (view && enabled && anim != null) {
                ResetIdle(view, CalcFadeTime());
            }
        }

        protected override void Start()
        {
            base.Start();

            m_Step = int.MaxValue;
            UpdateFootstep(GetFootTrans().position);

            m_Velocity = 0f;
        }

        protected override void OnEnable()
        {
            base.OnEnable();
            TickManager.Add(this);
        }

        protected override void OnDisable()
        {
            base.OnDisable();
            TickManager.Remove(this);
        }

        private float CalcOrderSpeed(IMovable mover)
        {
            var shiftingRate = mover.shiftingRate;
            var movingSpeed = mover.GetMovingSpeed();
            return movingSpeed / (shiftingRate < 1f ? m_SneakSpeed : m_NormSpeed);
        }

        private Vector3 m_LastPos;

        private float CalcRealSpeed(IMovable mover, Vector3 currPos, float delta)
        {
            var offset = currPos - m_LastPos;
            if (offset == Vector3.zero) return 0f;

            var shiftingRate = mover.shiftingRate;
            var movingSpeed = offset.magnitude / delta;
            return movingSpeed / (shiftingRate < 1f ? m_SneakSpeed : m_NormSpeed);
        }

        private float m_Velocity;
        public void Tick(float delta)
        {
            var currPos = cachedTransform.position;
            if (m_View) {
                var mover = m_View.obj as IMovable;
                if (mover != null && anim && anim.enabled) {
                    var shiftingRate = mover.shiftingRate;
                    if (shiftingRate > 0) {
                        var speed = mover.IsLocal() ? CalcOrderSpeed(mover) : CalcRealSpeed(mover, currPos, delta);

                        var smoothSpeed = anim.GetFloat(AnimParams.SMOOTH_SPEED);
                        smoothSpeed = Mathf.SmoothDamp(smoothSpeed, speed, ref m_Velocity, SPEED_LIMIT);
                        anim.SetFloat(AnimParams.SPEED, speed);
                        anim.SetFloat(AnimParams.SMOOTH_SPEED, smoothSpeed);

                    }
                }
            }

            m_LastPos = currPos;
        }
        
        bool ITickBase.ignoreTimeScale {
            get { return false; }
        }

        private Vector3 m_Footstep;
        [System.Diagnostics.Conditional("UNITY_EDITOR")]
        private void UpdateFootstep(Vector3 pos)
        {
            m_Footstep = pos;
        }

#if UNITY_EDITOR
        protected override void OnDrawGizmosSelected()
        {
            base.OnDrawGizmosSelected();
            GizmosTools.DrawCircle(m_Footstep, Quaternion.identity, 0.1f, Color.green);
        }
#endif
    }
}
