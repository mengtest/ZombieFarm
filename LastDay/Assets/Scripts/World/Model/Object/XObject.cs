//
//  XObject.cs
//  survive
//
//  Created by xingweizhen on 10/16/2017.
//
//

using System.Collections.Generic;
using World.Control;

namespace World
{
    /// <summary>
    /// 世界中的对象基类
    /// </summary>
    public class XObject : IObj
    {
        public XObject()
        {
            m_Camp = -1;
        }

        public Stage L { get; protected set; }

        public virtual int id { get; protected set; }
        public int vid { get { return id; } }

        public int dat { get; private set; }

        private int m_Camp;
        public virtual int camp {
            get { return m_Camp; }
            set {
                if (m_Camp != value) {
                    m_Camp = value;
                    L.CampChange(this, value);
                }
            }
        }

        private long m_Master;
        public virtual long master {
            get { return m_Master; }
            set { m_Master = value; }
        }

        private int m_Status;
        public int status {
            get { return m_Status; }
            private set {
                if (m_Status != value) {
                    m_Status = value;
                    L.StatusChange(this, value);
                }
            }
        }

        public IObjView view { get; set; }
        public float Dist { get; set; }

        protected int m_Ref;

        public CFG_Attr originalAttrs { get; protected set; }
        public CFG_Attr currentAttrs { get; protected set; }

        public ObjData Data { get; private set; }

        private Vector m_Coord;
        public virtual Vector coord { get { return m_Coord; } }
        public Vector point { get { return m_Coord; } }

        private Vector m_Pos;

        public virtual Vector pos {
            get { return m_Pos; }
            set {
                if (m_Pos != value) {
                    m_Pos = value;
                    m_Coord = this.UpdateCoord();
                    L.PositionChange(this);
                }
            }
        }

        /// <summary>
        /// 完全遮挡
        /// </summary>
        private int m_BlockLevel = -1;
        public int blockLevel {
            get { return m_BlockLevel; }
            private set {
                if (m_BlockLevel != value) {
                    if (m_BlockLevel < 0) {
                        m_BlockLevel = value;
                    } else {
                        m_BlockLevel = value;
                        L.ChangeBlock(this, value);
                    }
                }
            }
        }

        private int m_Disappear;
        public int disappear {
            get { return m_Disappear; }
            private set {
                if (m_Disappear != value) {
                    m_Disappear = value;
                    if (value >= 0) {
                        View.Debugger.LogD("{0}将会在F={1}秒后消失", this,
                            (value - L.frameIndex) * CVar.FRAME_TIME);
                    }
                }
            }
        }

        protected bool m_Offensive = false;
        public bool offensive { get { return m_Offensive; } }

        public int deadType { get; protected set; }
        public int deadValue { get; protected set; }
        public void SetDeath(int type, int value)
        {
            deadType = type;
            deadValue = value;
        }

        public void InitBase(Stage L, BaseData data, ObjData Data, bool reset)
        {
            this.L = L;
            id = data.id;
            dat = data.dat;
            camp = data.camp;
            master = data.master;
            pos = data.pos;
            status = data.status;
            this.Data = Data;

            if (reset) m_Ref = 1;
        }

        private Vector m_Size;
        public Vector size {
            get { return m_Size; }
            set {
                m_Size = value;
                m_Coord = this.UpdateCoord();
            }
        }

        private Vector m_Forward;
        public Vector forward {
            get { return m_Forward; }
            set {
                var newFwd = Vector.R(value);
                if (m_Forward != newFwd) {
                    m_Forward = newFwd;
                    m_Coord = this.UpdateCoord();
                }
            }
        }

        /// <summary>
        /// 交互限制：0表示无限制，1表示同阵营限制，2表示只有拥有者才能交互
        /// </summary>
        public int operLimit {
            get { return m_OperLimit; }
            private set {
                if (m_OperLimit != value) {
                    m_OperLimit = value;
                    L.OperChange(this, value, operId);
                }
            }
        }
        private int m_OperLimit;

        /// <summary>
        /// 交互类型：小于100的为特殊类型
        /// </summary>
        public int operId {
            get { return m_OperId; }
            private set {
                if (m_OperId != value) {
                    m_OperId = value;
                    L.OperChange(this, operLimit, value);
                }
            }
        }
        private int m_OperId;

        public bool obstacle { get; private set; }

        public int layer { get; private set; }

        public void InitEntity(EntityData entData, int disappear)
        {
            operLimit = entData.operLimit;
            operId = entData.operId;
            obstacle = entData.obstacle;
            layer = entData.layer;
            blockLevel = entData.blockLevel;
            m_Offensive = entData.offensive;
            this.disappear = disappear;
            deadType = entData.deadType;
            deadValue = entData.deadValue;

            size = entData.size;
            forward = entData.forward;
        }

        public virtual void Destroy()
        {
            if (disappear > 0) {
                disappear = L.frameIndex;
            } else {
                disappear = 0;
                m_Ref = 0;
            }
        }

        public virtual bool IsNull()
        {
            return (disappear > 0 && disappear < L.frameIndex) || m_Ref == 0;
        }

        public virtual bool IsAlive() { return true; }

        public virtual bool IsLocal() { return false; }

        public virtual bool IsVisible(IObj by) { return true; }
        
        public virtual bool IsSelectable(IObj by) { return !IsNull(); }

        protected virtual void OnAttrChanged(int attrId, float oldValue, float newValue) { }

        public virtual float GetAttr(ATTR attr)
        {
            return 0f;
        }

        public virtual float GetRawAttr(ATTR attr)
        {
            return 0f;
        }

        public void SetAttr(int attr, float newValue)
        {
            var oldValue = currentAttrs[attr];
            if (!Math.IsEqual(oldValue, newValue)) {
                currentAttrs[attr] = newValue;
                OnAttrChanged(attr, oldValue, newValue);
                L.AttrChanged(this, CFG_Attr.Changed.Apply(attr, oldValue, newValue));
            }
        }

        public void SetAttr(string name, float value)
        {
            int attr;
            if (CFG_Attr.Name2Attr(name, out attr)) {
                SetAttr(attr, value);
            }
        }

        public override string ToString()
        {
            return string.Format("[{0}|#{1}({2})<{3}>]", camp, id, dat, GetType().Name);
        }

        public IGrid Grid { get; set; }
    }
}
