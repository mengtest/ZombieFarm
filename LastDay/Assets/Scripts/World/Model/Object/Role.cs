//
//  Role.cs
//  survive
//
//  Created by xingweizhen on 10/12/2017.
//
//

using ZFrame.HFSM;

namespace World
{
    public class Role : CActor, IMovable
    {
        protected bool m_Towards;
        protected float m_MovingRate;
        protected Vector m_MovingPos;
        protected Vector m_MoveTarget;

        public Vector moveTarget {
            get { return m_MoveTarget; }
            set { m_MoveTarget = value; }
        }

        protected Vector m_MoveForward;

        public override Vector turnForward {
            get {
                if (m_MoveForward != Vector.zero)
                    return m_MoveForward;

                return base.turnForward;
            }
            set { base.turnForward = value; }
        }

        private float m_ShiftRate;

        /// <summary>
        /// 速度比例
        /// </summary>
        public virtual float shiftingRate {
            get { return m_ShiftRate; }
            set {
                if (!Math.IsEqual(value, m_ShiftRate)) {
                    if (value < 1f) {
                        OnEvent((int)EVENT.LEAVE_ACTION);
                    }

                    L.ShiftRateChange(this, value);

                    // 数值变化发生在后。使姿态切换发生在移动模式切换之前
                    m_ShiftRate = value;
                }
            }
        }

        private bool m_Stealth;

        /// <summary>
        /// 潜行状态（在草丛中）
        /// </summary>
        public bool stealth {
            get { return m_Stealth; }
            set { m_Stealth = value; }
        }

        /// <summary>
        /// 记录可潜行的间隔
        /// </summary>
        public int stealthFrame;

        /// <summary>
        /// 本地可见状态（不在战争迷雾中）
        /// </summary>
        public bool visible;

        protected Vector m_Destina;

        public Vector destination {
            get { return m_Destina; }
        }

        public bool autoMove {
            get { return !m_Towards; }
        }

        public Role() : base() { }

        public void InitRole()
        {
            m_Towards = IsLocal();
            m_MovingRate = 0;
            m_MovingPos = pos;
            m_Destina = pos;
            moveTarget = pos;
            shiftingRate = 1f;
            visible = true;
        }

        protected override void OnEnterConfine()
        {
            base.OnEnterConfine();
            StopMoving();
        }

        protected override void OnAttrChanged(int attrId, float oldValue, float newValue)
        {
            base.OnAttrChanged(attrId, oldValue, newValue);

            var attr = (ATTR)attrId;
            if (attr == ATTR.Move || attr == ATTR.Sneak) {
                var sneak = GetAttr(ATTR.Sneak);
                if (sneak > 0 && shiftingRate < 1f) {
                    shiftingRate = sneak / GetAttr(ATTR.Move);
                } else {
                    shiftingRate = 1f;
                }
            }
        }

        public override bool IsVisible(IObj by)
        {
            return visible && (!stealth || by.camp == camp);
        }

        public override bool IsSelectable(IObj by)
        {
            return visible && !stealth && base.IsSelectable(by);
        }

        public virtual float GetShiftingSpeed()
        {
            return currentAttrs[ATTR.Move] * shiftingRate;
        }

        public virtual float GetMovingSpeed()
        {
            return GetShiftingSpeed() * m_MovingRate;
        }

        public virtual void WarpAt(Vector newPos)
        {
            m_MoveForward = Vector.R((newPos - pos).normalized);
            if (autoMove && m_MoveForward != Vector.zero) {
                m_LookForward = m_MoveForward;
            }
            pos = newPos;
        }

        public virtual void MoveTo(Vector pos, float rate)
        {
            m_Towards = false;
            m_MovingPos = pos;
            if (rate > 0) m_MovingRate = rate;
        }

        public virtual void MoveTowards(Vector direction, float rate)
        {
            if (direction != Vector.zero) {
                if (OnEvent((int)EVENT.ENTER_MOVE)) {
                    m_Towards = true;
                    m_MovingRate = rate;
                    m_MovingPos = direction.normalized;
                    turnForward = m_MovingPos;
                }
            }
        }

        public virtual void StopMoving()
        {
            //m_Towards = false;            
            m_MovingRate = 0;
            m_MovingPos = pos;
            m_Destina = m_MovingPos;
            m_MoveForward = Vector.zero;
            moveTarget = pos;
            L.ObjMoving(this, null);
        }

        protected virtual void UpdatePosition()
        {
            if (m_Towards) {
                m_Destina = m_MovingRate > 0 ? pos + m_MovingPos * CVar.FWD_DIST : pos;
            } else {
                m_Destina = m_MovingPos;
            }

            if (IsLocal()) {
                if (m_Destina != pos) {
                    L.ObjMoving(this, null);
                } else if (m_MovingRate > 0) {
                    // 已到达目标，自动停止移动
                    StopMoving();
                }
            } else {
                if (m_Destina != pos) {
                    var movingSpeed = GetMovingSpeed();
                    if (movingSpeed > 0) {
                        var newPos = Vector.MoveTowards(pos, m_Destina, movingSpeed * CVar.FRAME_TIME);
                        m_MoveForward = (newPos - pos).normalized;
                        pos = newPos;
                        L.ObjMoving(this, null);
                    }
                } else {
                    m_MoveForward = Vector.zero;
                }
            }
        }

        public override void OnUpdate()
        {
            UpdatePosition();
            base.OnUpdate();
        }

        public override void OnStop()
        {
            base.OnStop();
            StopMoving();
        }

        public override void OnAction(IAction action, IObj target, ActProc proc)
        {
            base.OnAction(action, target, proc);
            switch (proc) {
                case ActProc.Start:
                    shiftingRate = 1f;
                    //if (action.mode == ACTMode.FreeMove) {
                    //    currentAttrs[ATTR.Move] = originalAttrs[ATTR.Move] / 2f;
                    //}
                    break;
                case ActProc.Finish:
                case ActProc.Break:
                    //if (action.mode == ACTMode.FreeMove) {
                    //    currentAttrs[ATTR.Move] = originalAttrs[ATTR.Move];
                    //}
                    break;
            }
        }

        public override bool OnEvent(int eventId)
        {
            if (eventId < (int)EVENT.LEAVING) {
                if (!this.IsBreakable()) return false;
            }

            return base.OnEvent(eventId);
        }

        protected override void InitFSM()
        {
            if (IsLocal()) {
                this.AddHFSMState(L.G.IDLE);
                this.AddHFSMState(L.G.MOVE);
                this.AddHFSMState(L.G.SEEK);
                this.AddHFSMState(L.G.ACTION);
                this.AddHFSMState(L.G.INTERACT);

                // -IDLE State
                this.AddHFSMEvent(EVENT.ENTER_MOVE, L.G.IDLE, L.G.MOVE, TransType.PUSH, OnEnterMove);
                this.AddHFSMEvent(EVENT.ENTER_ACTION, L.G.IDLE, L.G.ACTION, TransType.PUSH);
                this.AddHFSMEvent(EVENT.ENTER_GATHER, L.G.IDLE, L.G.INTERACT, TransType.PUSH);

                // --MOVE State
                this.AddHFSMEvent(EVENT.ENTER_MOVE, L.G.MOVE, L.G.MOVE, TransType.SET);
                this.AddHFSMEvent(EVENT.ENTER_ACTION, L.G.MOVE, L.G.ACTION, TransType.SET);
                this.AddHFSMEvent(EVENT.ENTER_GATHER, L.G.MOVE, L.G.INTERACT, TransType.SET);

                // --Action State
                this.AddHFSMEvent(EVENT.ENTER_MOVE, L.G.ACTION, L.G.MOVE, TransType.SET, OnEnterMove);
                this.AddHFSMEvent(EVENT.ENTER_GATHER, L.G.ACTION, L.G.INTERACT, TransType.SET, OnActionBreak);
                this.AddHFSMEvent(EVENT.ENTER_ACTION, L.G.ACTION, L.G.ACTION, TransType.SET);
                this.AddHFSMEvent(EVENT.ENTER_SEEK, L.G.ACTION, L.G.SEEK, TransType.PUSH);

                this.AddHFSMEvent(EVENT.ENTER_MOVE, L.G.INTERACT, L.G.MOVE, TransType.SET, OnEnterMove);
                this.AddHFSMEvent(EVENT.ENTER_ACTION, L.G.INTERACT, L.G.ACTION, TransType.SET, OnActionBreak);
                this.AddHFSMEvent(EVENT.ENTER_GATHER, L.G.INTERACT, L.G.INTERACT, TransType.SET);
                this.AddHFSMEvent(EVENT.ENTER_SEEK, L.G.INTERACT, L.G.SEEK, TransType.PUSH);

                this.AddHFSMEvent(EVENT.ENTER_MOVE, L.G.SEEK, L.G.MOVE, TransType.POP);
                this.AddHFSMEvent(EVENT.LEAVE_ACTION, L.G.SEEK, null, TransType.POP);

                this.AddHFSMEvent(EVENT.LEAVE_MOVE, L.G.MOVE, null, TransType.SET);
                this.AddHFSMEvent(EVENT.LEAVE_ACTION, L.G.ACTION, null, TransType.SET);
                this.AddHFSMEvent(EVENT.LEAVE_ACTION, L.G.INTERACT, null, TransType.SET);
                this.AddHFSMEvent(EVENT.BREAK_ACTION, L.G.ACTION, null, TransType.SET, OnActionBreak);
                this.AddHFSMEvent(EVENT.BREAK_ACTION, L.G.INTERACT, null, TransType.SET, OnActionBreak);

                fsm.Startup(L.G.IDLE);
            } else {
                base.InitFSM();
            }
        }

        protected static readonly StateTransfer OnEnterMove = (context, src, dst) => {
            var actor = (IActor)context;
            var action = actor.Content.action;
            if (action != null) {
                if (action.mode != ACTMode.FreeMove) {
                    actor.BreakAction();
                }
            }

            if (actor.Content.prefab != null && actor.Content.prefab.mode != ACTMode.FreeMove) {
                actor.Content.Uninit();
            }
        };
    }
}
