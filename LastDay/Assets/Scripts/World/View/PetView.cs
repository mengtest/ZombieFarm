using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace World.View
{
    using Control;

    public class PetView : RoleView
    {
        private const int MOVING_UPDATE_INTERVAL = 3;

        /// <summary>
        /// 与主人的距离超过该值就开始追赶
        /// </summary>
        [SerializeField, Range(2f, 5f)]//, NamedProperty("开始跟随距离")]
        private float m_StartFollow = 3f;

        /// <summary>
        ///  与主人的距离超过该值就保持同样的速度
        /// </summary>
        [SerializeField, Range(1f, 3f)]//, NamedProperty("重置跟随距离")]
        private float m_ResetFollow = 1f;

        /// <summary>
        /// 与主人的距离超过该值就直接传送
        /// </summary>
        [SerializeField]
        private float m_TeleportRange = 5f;
        
        public Role parent { get; private set; }

        private float m_FollowRate, m_RateTime;

        /// <summary>
        /// 表现所需数据：气味预警
        /// </summary>
        [Description("嗅觉提醒范围")]
        private float m_SmellWarnAlert;
        [Description("嗅觉警告范围")]
        private float m_SmellErrorAlert;

        private const int SMELL_WARN_LEVEL = 2;
        private const int SMELL_ERROR_LEVEL = 1;

        /// <summary>
        /// 下次激活预警时间
        /// </summary>
        private float m_NextAlertTime;

        public override void Subscribe(IObj o)
        {
            base.Subscribe(o);
            
            // 获取数据
            var lua = StageCtrl.LoadLuaData("get_obj", o.id);
            // 确定自己跟随的主人
            var parentId = lua.GetValue(I2V.ToInteger, -1, "parent");
            lua.Pop(1);

            // 获取预警范围（TODO：只有具有敏锐属性的才有）
            StageCtrl.LoadLuaData("get_obj", parentId);
            lua.GetField(-1, "Base");
            {
                m_SmellWarnAlert = lua.GetNumber(-1, "smellWarnAlert");
                m_SmellErrorAlert = lua.GetNumber(-1, "smellErrorAlert");
                lua.Pop(1);
            }
            lua.Pop(1);

            parent = StageCtrl.L.FindById(parentId) as Role;
            if (parent != null) agent.InitAgentDoor(parent.camp);
            
            var timeRemain = StageSync.timestamp % obj.L.G.PET_SMELLING_ALERT_FREQ;
            m_NextAlertTime = Time.realtimeSinceStartup + timeRemain;

            if (parentId == StageCtrl.P.id) {
                gameObject.SetEnable(typeof(StageFOWStalker), false);
                //((MonoBehaviour)gameObject.NeedComponent(typeof(StageFOWExplorer))).enabled = true;
            } else {
                ((MonoBehaviour)gameObject.NeedComponent(typeof(StageFOWStalker))).enabled = true;
                //gameObject.SetEnable(typeof(StageFOWExplorer), false);
            }
        }

        public override void OnCampChange(int value)
        {
            // 宠物的阵营变化对表现无影响
        }

        private void UpdateMoving()
        {
            var role = (Role)obj;
            var position = cachedTransform.position;
            var currPos = StageView.World2Local(position);
            role.WarpAt(currPos);

            Vector targetPos = role.coord;
            float humanSpeed = parent.GetMovingSpeed();
            var destina = parent.coord;
            if (agent.hasPath) {
                targetPos = StageView.World2Local(agent.steeringTarget);
                destina = parent.coord + Vector.RotateOffset(new Vector(1, 0, 0), parent.forward);
                if (!agent.CalculatePath(StageView.Local2World(destina), NavMeshTools.TmpPath)) {
                    destina = parent.coord + Vector.RotateOffset(new Vector(-1, 0, 0), parent.forward);
                }
            } else if (Vector.Distance(targetPos, destina) > m_TeleportRange) {
                // 距离过远又无路径，直接归位
                role.WarpAt(destina + Vector.RotateOffset(new Vector(1, 0, 0), parent.forward));
            }

            // 同步移动表现
            var currentFwd = (targetPos - currPos).normalized;
            if (currentFwd != Vector.zero) {
                // 移动中面朝移动方向
                role.turnForward = currentFwd;
            } else {
                // 保持方向
                role.turnForward = role.forward;
            }

            if (!role.Content.idle) return;

            // 更新移动目标
            var distance = Vector.Distance(role.coord, destina);
            if (distance > m_StartFollow) {
                // 追赶
                m_FollowRate = 1;
                role.MoveTo(destina, m_FollowRate);
                m_RateTime = 1f;
            } else if (distance > m_ResetFollow && m_FollowRate > 0) {
                // 比肩
                if (humanSpeed > 0) {
                    m_FollowRate = humanSpeed / role.GetAttr(ATTR.Move);
                }
                role.MoveTo(destina, m_FollowRate);
                m_RateTime = 1f;
            } else {
                // 慢慢停下
                if (m_RateTime > 0f) {
                    var rate = ZFrame.Tween.ZTween.easeInQuad(0, m_FollowRate, m_RateTime);
                    role.MoveTo(destina, rate);
                    m_RateTime -= CVar.FRAME_TIME * MOVING_UPDATE_INTERVAL;
                } else {
                    if (humanSpeed == 0) m_FollowRate = 0;
                    role.StopMoving();
                }
            }
        }

        private void UpdateSmellAlert()
        {
            var role = (Role)obj;

            foreach (var o in StageCtrl.Instance.SortedObjs) {
                var human = o as Human;
                if (human == null || human.camp == parent.camp) continue;

                var distance = Vector.Distance(parent.coord, human.coord);
                if (distance > m_SmellErrorAlert) break;

                var smellLevel = (int)human.GetAttr(ATTR.Smell);
                if (smellLevel <= SMELL_ERROR_LEVEL 
                    || (smellLevel <= SMELL_WARN_LEVEL && distance <= m_SmellWarnAlert)) {
                    // 预警目标
                    role.StopMoving();
                    HFSM_RemoteState.PrepareAction(role, null, role.IGetAction(0), human, true);
                    break;
                }
            }
        }

        public override void Tick(float deltaTime)
        {
            if (parent != null) {
                if (parent.IsNull()) {
                    obj.Destroy();
                    return;
                }

                if (StageSync.timestamp % MOVING_UPDATE_INTERVAL == obj.id % MOVING_UPDATE_INTERVAL) {
                    UpdateMoving();
                }

                if (m_SmellErrorAlert > 0) {
                    var realtime = Time.realtimeSinceStartup;
                    var timePass = realtime - m_NextAlertTime;
                    if (timePass > 0) {
                        m_NextAlertTime = realtime + obj.L.G.PET_SMELLING_ALERT_FREQ;
                        if (timePass < 1) {
                            UpdateSmellAlert();
                        } // 时间警告太长也不会触发预警
                    }
                }
            }

            base.Tick(deltaTime);
        }
    }
}
