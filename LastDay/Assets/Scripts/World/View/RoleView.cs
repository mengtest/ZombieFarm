//
//  ObjView.cs
//  survive
//
//  Created by xingweizhen on 10/13/2017.
//
//

using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;

namespace World.View
{
    using Control;

    [DisallowMultipleComponent]
    public class RoleView : EntityView
    {
        public const int INTERACT_MASK = 1 << 31;

        public Vector3 forward;

        protected NavMeshAgent m_Agent;
        public override NavMeshAgent agent {
            get {
                if (m_Agent == null) {
                    m_Agent = GetComponent(typeof(NavMeshAgent)) as NavMeshAgent;
                }
                return m_Agent;
            }
        }
        protected Vector3 m_CacheDestina;

        public override void SetAction(ObjAnim ctrl, NWObjAction nwAction)
        {
            base.SetAction(ctrl, nwAction);

            if (agent) agent.enabled = true;
        }

        protected bool DetectMovingObstacle(IMovable mover, ref Vector dest)
        {
            var ret = false;
            var moveFwd = (dest - mover.coord).normalized;
            // 移动单位阻挡判定
            var radius = mover.GetRadius();
            var coord = mover.coord;
            foreach (var o in StageCtrl.Instance.SortedObjs) {
                if (mover.Equals(o)) continue;
                
                var role = o as Role;
                if (!ObjectExt.IsAlive(role) || !role.obstacle) continue;

                var distance = Vector.Distance(o.coord, coord);
                var roleRadius = radius + role.GetRadius();
                if (distance > roleRadius) break;

                var ocoord = o.coord;
                var dot = Vector.Dot(moveFwd, (ocoord - coord).normalized);
                if (Math.IsEqual(dot, 1f)) {
                    Vector fwd = Quaternion.Euler(0, 90, 0) * moveFwd;                    
                    dest = mover.coord + fwd * roleRadius;
                    ret = true;
                    break;
                }

                if (dot > 0f) {
                    // 移动方向和目标方向小于90度则需要调整移动位置
                    var vec = coord + moveFwd * distance - ocoord;
                    moveFwd = vec.normalized;
                    dest = ocoord + moveFwd * roleRadius;
                    ret = true;
                }
            }

            return ret;
        }

        protected void SetDestination(Vector3 dest)
        {
            if (agent.enabled) {
                if (enabled) {
                    agent.destination = dest;
                } else {
                    agent.Warp(dest);
                }
            } else {
                cachedTransform.position = dest;
            }
        }

        protected void LocalObjMoving(IMovable mover, ref Vector3 dest)
        {
            var pos = StageView.Local2World(mover.coord);
            var viewPos = cachedTransform.position;
            var distance = Vector3.Distance(viewPos, pos);
            if (distance > 2f) {
                m_Agent.Warp(pos);
                return;
            }

            NavMeshHit hit;
            if (!mover.autoMove) {
                if (m_Agent.Raycast(dest, out hit)) {                    
                    var edgePos = hit.position;
                    var dist = Vector3.Distance(edgePos, viewPos);
                    if (dist > 1f) {
                        dest = edgePos;
                    } else {
                        var moveForward = (dest - viewPos).normalized;
                        // 修正目的地，以免自动寻路目标归到另外一侧
                        dest = edgePos + moveForward * m_Agent.radius / 2;
                        if (NavMesh.FindClosestEdge(dest, out hit, m_Agent.areaMask)) {
                            var direction = (hit.position - edgePos).normalized;
                            dest = edgePos + direction;
                            if (NavMesh.Raycast(hit.position, dest, out hit, m_Agent.areaMask)) {
                                dest = hit.position;
                            }
                        }
                    }
                } else {
                    var localDest = StageView.World2Local(dest);
                    if (DetectMovingObstacle(mover, ref localDest)) {
                        dest = StageView.Local2World(localDest);
                    }
                }
            } else {
                // 自动寻路
                if (!NavMesh.SamplePosition(dest, out hit, 0.1f, m_Agent.areaMask)) {
                    dest = dest + (pos - dest).normalized * 0.1f;
                }
            }
            //DetectMovingObstacle(mover, ref dest);
        }

        protected void RemoteObjMoving(IMovable mover, ref Vector3 dest)
        {
            //m_Agent.autoBraking = false;

            var pos = StageView.Local2World(mover.coord);
            var direction = cachedTransform.position - pos;
            var offset = direction.magnitude;
            if (offset > CVar.SYNC_DIST) {
                m_Agent.Warp(pos);
                m_Agent.destination = pos;
            } else if (offset > 1f) {
                var forward = StageView.FwdLocal2World(mover.forward);
                if (Vector3.Dot(forward, direction.normalized) < 0) {
                    m_Agent.speed *= 1.1f;
                }
            }
        }

        #region EVENT HANDLER

        //public override void OnCampChange(int value)
        //{
        //    base.OnCampChange(value);
        //    if (value == StageCtrl.P.camp) {
        //        gameObject.SetEnable(typeof(StageFOWStalker), false);
        //        ((MonoBehaviour)gameObject.NeedComponent(typeof(StageFOWExplorer))).enabled = true;
        //    } else {
        //        ((MonoBehaviour)gameObject.NeedComponent(typeof(StageFOWStalker))).enabled = true;
        //        gameObject.SetEnable(typeof(StageFOWExplorer), false);
        //    }
        //}

        //public override void OnObjTurning(IEventParam param)
        //{
        //    if (!entity.IsLocal() && agent && !agent.autoBraking) {
        //        agent.autoBraking = true;
        //    }

        //    base.OnObjTurning(param);
        //}


        private bool IsPathDirty()
        {
            var n = agent.path.GetCornersNonAlloc(NavMeshTools.PathCorners);
            return n < 1 || agent.remainingDistance <= agent.stoppingDistance;
        }

        public override void OnObjMoving(IEventParam param)
        {
            var mover = (IMovable)obj;
            var movingSpeed = mover.GetMovingSpeed();

            if (skin && skin.enabled && m_Agent && m_Agent.enabled) {
                m_Agent.speed = movingSpeed;
                                                
                var dest = StageView.Local2World(mover.destination);
                
                if (mover.IsLocal()) {
                    LocalObjMoving(mover, ref dest);
                } else {
                    if (movingSpeed == 0) {
                        m_Agent.speed = mover.GetShiftingSpeed();
                    }
                    RemoteObjMoving(mover, ref dest);
                }

                if (mover.autoMove && IsPathDirty()) {
                    m_Agent.ResetPath();
                    m_CacheDestina = cachedTransform.position;
                }

                if (m_CacheDestina != dest) {                    
                    m_CacheDestina = dest;

                    if (!enabled) m_Agent.Warp(dest);
                    m_Agent.destination = dest;
                }
            } else {
                var pos = StageView.Local2World(mover.coord);
                cachedTransform.position = pos;
            }
        }
        
        #endregion

        protected override void Start()
        {
            base.Start();

            if (agent) {
                agent.updateRotation = false;
                agent.speed = 0;
            }
        }

        public override void Subscribe(IObj o)
        {
            base.Subscribe(o);

            m_CacheDestina = StageView.Local2World(o.coord);

            if (!((IEntity)o).IsLocal()) {
                this.SetFOWStatus<StageFOWStalker>(true);
            }
        }

        protected override void UpdateFoward(float deltaTime)
        {
            var role = obj as Role;
            if (role != null && !role.autoMove && role.GetMovingSpeed() > 0) {
                cachedTransform.forward = Vector3.RotateTowards(
                    cachedTransform.forward, forward, role.GetAngularSpeed() * deltaTime, 1f);   
            } else {
                base.UpdateFoward(deltaTime);
            }
        }

        protected override void OnRecycle()
        {
            base.OnRecycle();

            if (m_Agent) m_Agent.enabled = false;
        }
        
#if UNITY_EDITOR
        protected override void OnDrawGizmosSelected()
        {
            var mover = obj as IMovable;
            if (mover != null) {
                GizmosTools.DrawCircle(StageView.Local2World(mover.destination),
                    Quaternion.identity, 0.5f, Color.green);
                if (mover.IsLocal()) {
                    if (mover.autoMove && agent.hasPath) {
                        var defColor = Gizmos.color;
                        Gizmos.color = Color.green;
                        var curr = transform.position;
                        foreach (var next in agent.path.corners) {
                            Gizmos.DrawLine(curr, next);
                            curr = next;
                        }

                        Gizmos.color = defColor;
                    }
                }
            }
        }
#endif

    }
}
