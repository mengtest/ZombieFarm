//
//  Actor.cs
//  survive
//
//  Created by xingweizhen on 10/12/2017.
//
//

using System.Collections.Generic;
using ZFrame.HFSM;

namespace World
{
    public class CActor : TurnObj, IActor
    {
        public ActionContent Content { get; protected set; }
        public List<int> actionIds { get; private set; }
        public int actionIndex { get; protected set; }

        public int state { get; set; }

        protected int m_ConfineN;

        public int nConfine {
            get { return IsLocal() ? m_ConfineN : 0; }
            set {
                if (m_ConfineN != value) {
                    if (value == 0) {
                        OnLeaveConfine();
                    } else if (m_ConfineN == 0) {
                        OnEnterConfine();
                    }

                    m_ConfineN = value;
                }
            }
        }

        public bool actionable {
            get { return nConfine == 0; }
        }

        public CActor() : base()
        {
            Content = new ActionContent(this);
            actionIds = new List<int>();

        }

        public void InitActor(int state)
        {
            this.state = state;
            this.nConfine = 0;
            this.actionIndex = 1;
        }

        protected virtual void InitFSM()
        {
            if (IsLocal()) {
                this.AddHFSMState(L.G.IDLE);
                this.AddHFSMState(L.G.ACTION);

                this.AddHFSMEvent(EVENT.ENTER_ACTION, L.G.IDLE, L.G.ACTION, TransType.PUSH);
                this.AddHFSMEvent(EVENT.LEAVE_ACTION, L.G.ACTION, null, TransType.SET);
                this.AddHFSMEvent(EVENT.BREAK_ACTION, L.G.ACTION, null, TransType.SET, OnActionBreak);

                fsm.Startup(L.G.IDLE);
            } else {
                this.AddHFSMState(L.G.REMOTE);
                fsm.Startup(L.G.REMOTE);
            }
        }

        protected virtual void OnEnterConfine()
        {
            this.BreakAction();
        }

        protected virtual void OnLeaveConfine() { }

        public IAction IGetAction(int index)
        {
            if (index < 0) {
                index = actionIndex;
            }

            if (index >= 0 && index < actionIds.Count) {
                var id = actionIds[index];
                return CFG_Action.Load(id);
            }

            return null;
        }

        public void SelectAction(int index)
        {
            actionIndex = index;
        }

        public bool HasAction(int actionId)
        {
            foreach (var id in actionIds) {
                if (id == actionId) return true;
            }

            return false;
        }

        protected override void UpdateForward()
        {
            if (actionable) {
                base.UpdateForward();
            }
        }

        public virtual void OnStart()
        {
            InitFSM();
        }

        public virtual void OnUpdate()
        {
            UpdateForward();
            if (!fsm.Update()) {
                fsm.Exit();
            }
        }

        public virtual void OnStop()
        {
            if (fsm.activated) fsm.Exit();
            L.tmMgr.BreakOf(this, TTags.CAST, null);
            Content.Reset();
        }

        public override bool OnEvent(int eventId)
        {
            if (eventId == (int)EVENT.ENTER_ACTION) {
                if (!Content.IsCooldown(this)) return false;
            }

            return base.OnEvent(eventId);
        }

        public virtual void OnAction(IAction action, IObj target, ActProc proc)
        {
            switch (proc) {
                case ActProc.Success:
                    var fwd = this.CalcForward(target);
                    if (fwd != Vector.zero) {
                        turnForward = fwd;
                        forward = m_LookForward;                        
                    }
                    break;
            }
        }


        protected static readonly StateTransfer OnActionBreak = (context, src, dst) => {
            (context as IActor).BreakAction();
        };
}
}
