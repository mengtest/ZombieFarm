using System.Collections;
using System.Collections.Generic;

namespace ZFrame.HFSM
{
    public class HFSM
    {
        public event System.Action<BaseState, BaseState> StateTransform;

        private IFSMContext m_Context;
        private BaseState m_Root;
        
        public bool activated { get { return m_Root != null; } }

        public bool debug;
        private void Log(string fmt, params object[] args)
        {
            if (debug) {
                UnityEngine.Debug.LogFormat("{0} {1}", m_Context.ToString(), string.Format(fmt, args));
            }
        }

        public override string ToString()
        {
            var strbld = new System.Text.StringBuilder();
            foreach (var state in m_Stack) {
                strbld.Append(state).Append("|");
            }
            return strbld.ToString();
        }

        public HFSM(IFSMContext context)
        {
            m_Context = context;
        }

        private class Transition
        {
            public readonly BaseState source, destina;
            public readonly TransType type;
            public readonly StateTransfer transfer;

            public Transition(BaseState src, BaseState dst, TransType type, StateTransfer transfer)
            {
                source = src;
                destina = dst;
                this.type = type;
                this.transfer = transfer;
            }
        }

        private Dictionary<BaseState, Dictionary<int, Transition>> m_States = new Dictionary<BaseState, Dictionary<int, Transition>>();        
        private Stack<BaseState> m_Stack = new Stack<BaseState>();
        
        public void AddState(BaseState state)
        {
            if (!m_States.ContainsKey(state)) {
                m_States.Add(state, new Dictionary<int, Transition>());
            }
        }

        public void AddEvent(int eventId, BaseState src, BaseState dst, TransType type, StateTransfer transfer = null)
        {
            m_States[src].Add(eventId, new Transition(src, dst, type, transfer));
        }

        /// <summary>
        /// 进入当前状态
        /// </summary>
        private void EnterState(BaseState prev, BaseState curr)
        {
            Log("Trans:{0}->{1}", prev, curr);
            if (StateTransform != null) StateTransform.Invoke(prev, curr);
            curr.Enter(m_Context);
        }

        /// <summary>
        /// 触发事件，进入新状态
        /// </summary>
        private bool OnEvent(int eventId)
        {
            var source = GetCurrentState();
            var dict = m_States[source];
            Transition trans;
            if (dict.TryGetValue(eventId, out trans)) {
                // 目标状态和当前状态相同，忽略转换过程
                if (trans.destina != null && trans.destina.id == source.id) return true;

                source.Exit(m_Context);
                var destina = trans.destina;
                switch (trans.type) {
                    case TransType.POP:
                        m_Stack.Pop();
                        goto case TransType.SET;
                    case TransType.SET:
                        m_Stack.Pop();
                        if (destina != null) m_Stack.Push(destina);
                        break;
                    case TransType.PUSH:
                        if (destina != null) {
                            m_Stack.Push(destina);
                        } else {
                            LogMgr.E("错误的状态转换设置：PUSH的目标状态不能为空！");
                        }
                        break;
                    default: break;
                }

                if (destina == null) {
                    destina = GetCurrentState();
                }

                if (trans.transfer != null) {
                    trans.transfer(m_Context, source, destina);
                }

                EnterState(source, destina);
                return true;
            }
            return false;
        }
        
        /// <summary>
        /// 离开当前状态，进入默认状态（如果没有，则进入上一层状态）
        /// </summary>
        public void Exit()
        {
            var current = GetCurrentState();
            if (current != m_Root) {
                if (!OnEvent(0)) {
                    current.Exit(m_Context);
                    m_Stack.Pop();
                    EnterState(current, GetCurrentState());
                }
            }
        }

        public bool TransState(int eventId)
        {
            if (m_Stack.Count > 0) {
                if (OnEvent(eventId)) return true;
            } else {
                Log("状态机尚未启动");
            }
            return false;
        }

        public BaseState GetCurrentState()
        {
            return m_Stack.Peek();
        }

        public void Startup(BaseState state)
        {
            m_Root = state;
            m_Stack.Push(state);
        }

        public bool Update()
        {
            var current = GetCurrentState();
            return current.Update(m_Context);
        }

    }
}
