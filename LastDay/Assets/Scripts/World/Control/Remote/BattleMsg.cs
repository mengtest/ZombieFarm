using System.Collections;
using System.Collections.Generic;
using System.Diagnostics;
using UnityEngine;
using clientlib.net;
using ZFrame.NetEngine;

namespace World.Control
{
    public interface IMsgObj
    {        
        void Read(INetMsg nm);
        void Write(INetMsg nm);
    }

    public interface IFullMsg : IMsgObj
    {
        bool IsDirty();
        void Clear();
    }

    public static class NWMsgExt
    {
        public static IEnumerator<T> ReadN<T>(this T self, INetMsg nm) where T : IMsgObj, new()
        {
            var n = nm.readU32();
            for (int i = 0; i < n; ++i) {
                self.Read(nm);
                yield return self;
            }
        }
    }

    
    public class BattleMsg
    {
        private static Queue<float> _SendQue = new Queue<float>();
        private static Queue<float> _RecvQue = new Queue<float>();
        private static long m_RemoteTime, m_Delay;
        public static void Log(string fmt, params object[] args)
        {
            if (StageCtrl.S.debug) {
                var tag = string.Format("[{0}|{1}]{2}", StageSync.timestamp, m_RemoteTime, fmt);
                LogMgr.D(tag, args);
            }
        }

        public static void UpdateSendRecvCounter(float dura, out int nSend, out int nRecv)
        {
            var lasttime = Time.realtimeSinceStartup - dura;
            while (_SendQue.Count > 0 && _SendQue.Peek() < lasttime) {
                _SendQue.Dequeue();
            }
            while (_RecvQue.Count > 0 && _RecvQue.Peek() < lasttime) {
                _RecvQue.Dequeue();
            }
            
            nSend = _SendQue.Count;
            nRecv = _RecvQue.Count;
        }

        [Conditional(LogMgr.UNITY_EDITOR), Conditional(LogMgr.UNITY_STANDALONE)]
        private static void LogNetMsgSent(INetMsg nm, IFullMsg msg)
        {
            _SendQue.Enqueue(Time.realtimeSinceStartup);
            
            var lua = ZFrame.LuaScriptMgr.Instance.L;
            lua.GetGlobal(LuaComponent.PKG, "network/msgdef", "get_msg_name");
            lua.Func(1, nm.type);
            var name = lua.ToString(-1);
            lua.Pop(1);

            Log("发送了：{0}={1}", name, msg.ToString());
        }

        [Conditional(LogMgr.UNITY_EDITOR), Conditional(LogMgr.UNITY_STANDALONE)]
        public static void LogNetMsgRecv(INetMsg nm, IFullMsg msg)
        {
            _RecvQue.Enqueue(Time.realtimeSinceStartup);
            
            var lua = ZFrame.LuaScriptMgr.Instance.L;
            lua.GetGlobal(LuaComponent.PKG, "network/msgdef", "get_msg_name");
            lua.Func(1, nm.type);
            var name = lua.ToString(-1);
            lua.Pop(1);

            Log("接收到：{0}={1}", name, msg.ToString());
        }

        public readonly int id;
        public readonly IFullMsg nmObj;

        public BattleMsg(int id, IFullMsg nmObj)
        {
            this.id = id;
            this.nmObj = nmObj;
        }

        public bool TryRead(INetMsg nm)
        {
            if (nm.type == id) {
                m_RemoteTime = nm.readU64();
                nmObj.Read(nm);
                LogNetMsgRecv(nm, nmObj);

                nmObj.Clear();

                var delay = m_RemoteTime - StageSync.timestamp;
                StageSync.delay = delay - m_Delay;
                m_Delay = delay;
                //ObjSync.timestamp = m_RemoteTime;
                return true;
            }
            return false;
        }

        public void Send(TcpClientHandler cli, long timestamp)
        {
            var nm = NetMsg.createMsg(id);
            nm.writeU64(timestamp);
            nmObj.Write(nm);
            LogNetMsgSent(nm, nmObj);
            nmObj.Clear();
            cli.Send(nm);
        }

        public void Send(TcpClientHandler cli, int id, long timestamp)
        {
            var nm = NetMsg.createMsg(id);
            nm.writeU64(timestamp);
            nmObj.Write(nm);
            LogNetMsgSent(nm, nmObj);
            nmObj.Clear();
            cli.Send(nm);
        }
    }
    
    /// <summary>
    /// 客户端发送：
    ///     拾取物件：Pick(20)
    ///     瞬发动作：StartCast(10)->  [HitTargets(13)]
    ///     读条动作：StartCast(10)->  [CancelCast(11)|CastSuccess(12)]->  [HitTarget(13)]
    /// 客户端接收：
    ///     瞬发动作：StartCast(10)
    ///     读条动作：StartCast(10)->  [CancelCast(11)|CastSuccess(12)]
    /// </summary>
    public enum ObjAction
    {
        NONE = 0,
        Stand = 1, Move = 2, Sneak = 3, SneakMove = 4, Urinate = 5, Reload = 6, Locate = 7,
        StartCast = 10, CancelCast = 11, CastSuccess = 12, HitTarget = 13, NewTarget = 14, NullTar = 15, StopCast = 16,
        Sync = 19,
        Pick = 20, Gahter = 21, Open = 22, Trigger = 23, Func = 24,
    }

    public enum AffixType
    {
        None, PosData, TarData,
    }

    public struct NWVector : IMsgObj
    {
        public Vector coord;
        public Vector forward;
        public bool hasForward { get; private set; }

        public NWVector(Vector coord, float angle) : this()
        {
            this.coord = coord;
            hasForward = angle >= 0;
            forward = hasForward ? Quaternion.Euler(0, angle, 0) * Vector3.forward : Vector3.forward;
        }

        public void Write(INetMsg nm)
        {
            nm.writeU32(coord.ix).writeU32(coord.iz);
            var angle = Vector3.SignedAngle(Vector3.forward, forward, Vector3.up);
            if (angle < 0) angle += 360;
            nm.writeU32(Mathf.RoundToInt(angle));
        }

        public void Read(INetMsg nm)
        {
            coord = new Vector(nm.readU32() * CVar.LENGTH_RATE, 0f, nm.readU32() * CVar.LENGTH_RATE);
            var angle = nm.readU32();
            hasForward = angle >= 0;
            if (hasForward) {
                forward = Quaternion.Euler(0, angle, 0) * Vector3.forward;
            }
        }

        public override string ToString()
        {
            var angle = Vector3.SignedAngle(Vector3.forward, forward, Vector3.up);
            if (angle < 0) angle += 360;
            return string.Format("[{0}|{1}]", coord.ToXZ(), Mathf.RoundToInt(angle));
        }
    }

    public struct NWHpChange : IMsgObj
    {
        public int id { get; private set; }
        public int hp { get; private set; }

        public void Read(INetMsg nm)
        {
            id = nm.readU32();
            hp = nm.readU32();
        }

        public void Write(INetMsg nm)
        {
            throw new System.NotImplementedException();
        }
    }

    public struct NWBuffChange : IMsgObj
    {
        public int id { get; private set; }
        public int buffId { get; private set; }
        public int disappear { get; private set; }

        public void Read(INetMsg nm)
        {
            id = nm.readU32();
            buffId = nm.readU32();
            disappear = StageCtrl.Timestamp2Frame(nm.readU64());
            
        }

        public void Write(INetMsg nm)
        {
            throw new System.NotImplementedException();
        }
    }

    public struct NWDeadDisplay : IMsgObj
    {
        public int id { get; private set; }
        public int type { get; private set; }
        public int value { get; private set; }

        public void Read(INetMsg nm)
        {
            id = nm.readU32();
            type = nm.readU32();
            value = nm.readU32();
        }

        public void Write(INetMsg nm)
        {
            throw new System.NotImplementedException();
        }
    }
}
