//
//  ObjSync.cs
//  survive
//
//  Created by xingweizhen on 10/30/2017.
//
//

using System.Collections;
using System.Collections.Generic;
using System.Diagnostics;
using UnityEngine;
using clientlib.net;
using ZFrame;
using ZFrame.NetEngine;

namespace World.Control
{
    public sealed class StageSync : MonoBehavior
    {
        private static float m_Time;
        private static long m_Timestamp;
        public static long delay;

        private static long m_LocalTimestamp;
        public static long timestamp {
            get { return m_LocalTimestamp; }
            set {
                m_Timestamp = value;
                m_Time = Time.realtimeSinceStartup;
                delay = 0;
                UpdateTimestamp();
            }
        }

        /// <summary>
        /// 每帧更新
        /// </summary>
        private static void UpdateTimestamp()
        {
            var time = Time.realtimeSinceStartup - m_Time;
            m_LocalTimestamp = m_Timestamp + Mathf.FloorToInt(time * 1000);
        }

        [SerializeField, NamedProperty("日志输出")]
        private bool m_Debug;
        public bool debug { get { return m_Debug; } set { m_Debug = value; } }

        [SerializeField, NamedProperty("统计时长")]
        private float m_CounterDura = 1f;

        private int m_SendCount, m_RecvCount;

        private int SUB_CS_OBJ_PICKUP, SUB_CS_OBJ_COLLECT;
        private int ROLE_SKILL_FIRE;
        public int ROLE_INTO_REED { get; private set; }
        public int ROLE_OUT_REED { get; private set; }

        private BattleMsg m_SyncAction, m_ObjAttack, m_ObjHited, m_TriggerAction;
        public BattleMsg syncAction { get { return m_SyncAction; } }
        public BattleMsg objAttack { get { return m_ObjAttack; } }

        private List<BattleMsg> m_MsgList;

        public readonly NWObjAction objAction = new NWObjAction();
        public readonly NWObjHited objHited = new NWObjHited();

        private TcpClientHandler m_Cli;
        public TcpClientHandler cli { get { return m_Cli; } }

        private NetMsgHandler m_Handler;

        private void Awake()
        {
            m_MsgList = new List<BattleMsg>();
            m_Handler = new NetMsgHandler(UnpackBattle);

            var lua = ZFrame.LuaScriptMgr.Instance.L;

            lua.GetGlobal(LuaComponent.PKG, "network/msgdef");
            SUB_CS_OBJ_PICKUP = (int)lua.GetNumber(-1, "SUB_BATTLE.CS.OBJ_PICKUP");
            SUB_CS_OBJ_COLLECT = (int)lua.GetNumber(-1, "SUB_BATTLE.CS.OBJ_COLLECT");
            ROLE_SKILL_FIRE = (int)lua.GetNumber(-1, "BATTLE.CS.ROLE_SKILL_FIRE");
            ROLE_INTO_REED = (int)lua.GetNumber(-1, "BATTLE.CS.ROLE_INTO_REED");
            ROLE_OUT_REED = (int)lua.GetNumber(-1, "BATTLE.CS.ROLE_OUT_REED");

            var CS_OBJ_GEAR_TRIGGER = (int)lua.GetNumber(-1, "SUB_BATTLE.CS.OBJ_GEAR_TRIGGER");

            var CS_SYNC_ROLE_ACTION = (int)lua.GetNumber(-1, "BATTLE.CS.SYNC_ROLE_ACTION");
            var CS_ATTACK_OBJ = (int)lua.GetNumber(-1, "BATTLE.CS.ATTACK_OBJ");
            var CS_OBJ_HITED = (int)lua.GetNumber(-1, "BATTLE.CS.OBJ_HITED");
            var SC_SYNC_OBJ_ACTION = (int)lua.GetNumber(-1, "BATTLE.SC.SYNC_OBJ_ACTION");
            //var SUB_SC_EXCHANGE_OBJ = (int)lua.GetFloatValue(-1, "SUB_BATTLE.SC.EXCHANGE_OBJ");
            var SC_ATTACK_OBJ = (int)lua.GetNumber(-1, "BATTLE.SC.ATTACK_OBJ");
            var SC_OBJ_HITED = (int)lua.GetNumber(-1, "BATTLE.SC.OBJ_HITED");
            var SC_SYNC_OBJ_HITED = (int)lua.GetNumber(-1, "BATTLE.SC.SYNC_OBJ_HITED");
            var SC_ROLE_SKILL_FIRE = (int)lua.GetNumber(-1, "BATTLE.SC.ROLE_SKILL_FIRE");

            lua.Pop(1);

            // 发送
            m_SyncAction = new BattleMsg(CS_SYNC_ROLE_ACTION, new NWObjSync(objAction));
            m_ObjAttack = new BattleMsg(CS_ATTACK_OBJ, new NWObjAttack(objAction));
            m_ObjHited = new BattleMsg(CS_OBJ_HITED, objHited);
            m_TriggerAction = new BattleMsg(CS_OBJ_GEAR_TRIGGER, new NWObjTrigger(objAction));

            // 接收
            TrackMsg(m_Handler, CS_SYNC_ROLE_ACTION, m_SyncAction.nmObj);
            TrackMsg(m_Handler, SC_ATTACK_OBJ, m_ObjAttack.nmObj);
            TrackMsg(m_Handler, SC_SYNC_OBJ_ACTION, objAction);
            TrackMsg(m_Handler, SUB_CS_OBJ_PICKUP, objAction);
            TrackMsg(m_Handler, SC_SYNC_OBJ_HITED, new NWObjStat());
            TrackMsg(m_Handler, SC_OBJ_HITED, objHited);
            TrackMsg(m_Handler, SC_ROLE_SKILL_FIRE, m_ObjAttack.nmObj);
        }

        private void TrackMsg(NetMsgHandler handler, int msgId, IFullMsg msg)
        {
            handler.Track(msgId);
            m_MsgList.Add(new BattleMsg(msgId, msg));
        }

        private void Update()
        {
            UpdateTimestamp();

#if UNITY_EDITOR || UNITY_STANDALONE
            BattleMsg.UpdateSendRecvCounter(m_CounterDura, out m_SendCount, out m_RecvCount);
#endif
        }

        private void UnpackBattle(TcpClientHandler cli, INetMsg nm)
        {
            foreach (var msg in m_MsgList) {
                if (msg.TryRead(nm)) {
                    LogMgr.I("{0} <-- {1}({2})", cli, nm.type, ((NetMsg)nm).readSize);
                    break;
                }
            }
        }

        public void Begin()
        {
            var lua = LuaScriptMgr.Instance.L;
            lua.GetGlobal("NW", "get_tcp");
            var b = lua.BeginPCall();
            lua.ExecPCall(0, 1, b);
            m_Cli = lua.ToUserData(-1) as TcpClientHandler;
            lua.Pop(1);

            m_Cli.AddExtHandler("BATTLE", m_Handler);

            StageCtrl.L.localMode = !m_Cli.IsConnected;
#if UNITY_EDITOR || UNITY_STANDALONE
            UIManager.Instance.RegDrawGUI(OnDrawGUI);
#endif
        }

        public void End()
        {
            m_SyncAction.nmObj.Clear();
            m_ObjAttack.nmObj.Clear();
            m_ObjHited.nmObj.Clear();
            m_TriggerAction.nmObj.Clear();

            if (m_Cli) {
                m_Cli.DelExtHandler("BATTLE");
            }
#if UNITY_EDITOR || UNITY_STANDALONE
            UIManager.Instance.UnregDrawGUI(OnDrawGUI);
#endif
        }

        #region 立即同步
        public void SyncHited(IObj atker, IConfig cfg, IEntity target)
        {
            objHited.SetHited(atker, cfg, target);
            m_ObjHited.Send(m_Cli, timestamp);
        }

        /// <summary>
        /// 移动<->停止切换时要立即同步
        /// </summary>
        public void SyncMoving(IEntity self, float shiftingRate, ref float interval)
        {
            objAction.SetMoveData(self, shiftingRate, ref interval);
            m_SyncAction.Send(cli, timestamp);
        }

        /// <summary>
        /// 进出草丛时要立即同步
        /// </summary>
        public void SyncInoutReed(IEntity self, float shiftingRate, ref float interval, bool stealth)
        {
            objAction.SetMoveData(self, shiftingRate, ref interval);
            if (stealth) {
                m_SyncAction.Send(cli, ROLE_INTO_REED, timestamp);
            } else {
                m_SyncAction.Send(cli, ROLE_OUT_REED, timestamp);
            }
        }

        public void SyncActionStart(IEntity caster, CFG_Weapon weapon, IAction action, IObj target, bool actMode)
        {
            objAction.SetStartCast(caster, weapon, action, target, actMode);
            DoSyncAction();
        }

        public void SyncActionSuccess(IEntity caster, CFG_Weapon weapon, int action, ACTType type, IObj target)
        {
            objAction.SetCastSuccess(caster, weapon, action, type, target);
            DoSyncAction();
        }

        public void SyncHitTarget(IEntity caster, CFG_Weapon weapon, int action, IObj target)
        {
            objAction.SetHitTarget(caster, weapon, action, target);
            DoSyncAction();
        }

        public void SyncCancelCast(IEntity caster, int action)
        {
            objAction.SetCancelCast(caster, action);
            DoSyncAction();
        }

        public void SyncStopCast(IEntity caster, int action)
        {
            objAction.SetStopCast(caster, action);
            DoSyncAction();
        }
        #endregion
        
        private void DoSyncAction()
        {
            // 消息发送后内容会清空，在发送面同步到lua
            switch (objAction.status) {
                case ObjAction.Open:                        
                    SyncToLua(objAction, "open_package");
                    break;
                case ObjAction.Func:
                    SyncToLua(objAction, "sync_action");
                    break;
            }

            if (objAction.Acting) {
                switch (objAction.status) {
                    case ObjAction.Pick:
                        m_SyncAction.Send(m_Cli, SUB_CS_OBJ_PICKUP, timestamp);
                        break;
                    case ObjAction.Gahter:
                        m_SyncAction.Send(m_Cli, SUB_CS_OBJ_COLLECT, timestamp);
                        break;
                    case ObjAction.Trigger:
                        m_TriggerAction.Send(m_Cli, timestamp);
                        break;
                    case ObjAction.Sync:
                    case ObjAction.Open:                        
                    case ObjAction.Func:
                        m_SyncAction.Send(m_Cli, timestamp);
                        break;                            
                    default:
                        if (objAction.targetId < 0) {
                            // 表示空放技能
                            m_ObjAttack.Send(m_Cli, ROLE_SKILL_FIRE, timestamp);
                        } else {
                            m_ObjAttack.Send(m_Cli, timestamp);
                        }
                        break;
                }
            } else {
                m_SyncAction.Send(m_Cli, timestamp);
            }
        }

        public void Sync()
        {
            if (objAction.IsDirty()) DoSyncAction();
        }

        public static void SyncToLua(NWObjAction objAction, string syncName)
        {
            var lua = StageCtrl.LT.PushField(syncName);
            var b = lua.BeginPCall();
            lua.PushInteger(objAction.action);
            lua.PushInteger(objAction.targetId);
            lua.ExecPCall(2, 0, b);
        }
        
#if UNITY_EDITOR || UNITY_STANDALONE
        private void OnDrawGUI()
        {
            GUILayout.Label(string.Format("最近{0}秒内处理消息数：{1}/{2}(接收/发送)", 
                m_CounterDura, m_SendCount, m_RecvCount));
        }
#endif
        
    }
}
