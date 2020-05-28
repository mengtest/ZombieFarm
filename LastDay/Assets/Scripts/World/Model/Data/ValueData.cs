using clientlib.utils;
using System.Collections.Generic;

namespace World
{
    /// <summary>
    /// 生命值变化数据
    /// </summary>
    public struct VarChange
    {
        public int change { get; private set; }
        public int value, limit, display;
        public IObj maker { get; private set; }
        public IPosition source { get; private set; }
        public IAction action { get; private set; }        

        public VarChange(int change, IAction action, IObj maker, IPosition source = null) : this()
        {
            this.change = change;
            this.display = change;
            this.action = action;
            this.maker = maker;
            this.source = source ?? maker;
            value = 0; limit = 0;
        }
    }

    public struct DuraChange
    {
        public int pos, dat, dura, ammo;
        public int change { get; private set; }

        public DuraChange(int pos, int dat, int dura, int ammo, int change) : this()
        {
            this.change = change;
            this.pos = pos;
            this.dat = dat;
            this.dura = dura;
            this.ammo = ammo;
        }
    }

    /// <summary>
    /// 单位资源数据（可变化）
    /// </summary>
    public sealed class VarData
    {
        private readonly WInt32 m_Value, m_Limit;
        public int cache { get; private set; }
        public VarData()
        {
            m_Value = new WInt32();
            m_Limit = new WInt32();
        }

        public bool IsNull() { return m_Value.value == 0; }
        public int GetValue() { return m_Value.value; }
        public int GetLimit() { return m_Limit.value; }
        public float GetRate() { return (float)m_Value.value / m_Limit.value; }

        public void SetCache(int cache)
        {
            this.cache = cache;
        }

        public void Set(int value, int limit)
        {
            if (limit >= 0) {
                m_Limit.value = limit;
            }

            if (value >= 0) {
                if (value > limit) value = limit;
                m_Value.value = value;
            }
            cache = value;
        }

        public void SetLimit(int limit)
        {
            if (limit > 0) {
                m_Limit.value = limit;
            }
        }

        public int Add(int add, out int final)
        {
            var limit = m_Limit.value;
            var value = m_Value.value;

            final = value + add;
            if (final < 0) final = 0;
            if (final > limit) final = limit;
            m_Value.value = final;
            return final - value;
        }

        public int Add(ref VarChange inf)
        {
            var limit = m_Limit.value;
            var value = m_Value.value;

            var final = value + inf.change;
            if (final < 0) final = 0;
            if (final > limit) final = limit;
            m_Value.value = final;
            inf.value = final;
            inf.limit = limit;
            return final - value;
        }

        public bool IsEmpty()
        {
            return GetLimit() > 0 && GetValue() == 0;
        }
    }

    /// <summary>
    /// 动作状态
    /// </summary>
    public sealed class ActionContent
    {
        public IActor actor { get; private set; }
        private ActionContent() { }
        public ActionContent(IActor actor)
        {
            this.actor = actor;
            if (actor.IsLocal()) {
                m_NextFrames = new Dictionary<int, int>();
            }
        }
        public int gcdFrame { get; private set; }

        /// <summary>
        /// 动作就绪帧，达到此帧才能执行动作。
        /// </summary>
        private int m_ReadyFrame;

        /// <summary>
        /// 下一次动作帧，达到此帧才能执行下一个动作（冷却）
        /// </summary>
        private readonly Dictionary<int, int> m_NextFrames;

        /// <summary>
        /// 即将执行的动作
        /// </summary>
        private IAction m_WillCast;

        /// <summary>
        /// 执行中的动作
        /// </summary>
        private IAction m_Casting;

        /// <summary>
        /// 使用到道具
        /// </summary>
        public CFG_Weapon Weapon { get; private set; }

        /// <summary>
        /// 预设的动作
        /// </summary>
        public IAction prefab { get; private set; }
        public ACTOper oper { get; private set; }
        public int totalShot { get; private set; }
        public int nShot { get; private set; }

        /// <summary>
        /// 当前目标
        /// </summary>
        public IObj currTarget;

        /// <summary>
        /// 预设的目标
        /// </summary>
        private IObj m_SetTarget;

        /// <summary>
        /// 待机中，可以执行下一个动作
        /// </summary>
        public bool idle { get { return m_Casting == null; } }

        /// <summary>
        /// 动作还未成功(前摇前）
        /// </summary>
        public bool busy { get { return m_Casting != null && m_WillCast != null; } }

        /// <summary>
        /// 动作状态无效了
        /// </summary>
        public bool invalid { get { return prefab == null && m_WillCast == null; } }

        /// <summary>
        /// 当前或者缓存的动作
        /// </summary>
        public IAction action { get { return m_Casting ?? m_WillCast; } }
        public IObj target {
            get { return ObjectExt.Valid(ref currTarget) ?? ObjectExt.Valid(ref m_SetTarget); }
        }

        private int m_WeaponDat = -1;

        public void Uninit(ACTOper oper = ACTOper.OneShot)
        {
            // 施法中被反初始化，说明被打断，打断时仅在缓存动作与被打断动作一样时才执行反初始化
            if (m_Casting == null || prefab == m_Casting) {
                Init(null, null, null, oper);
            }
            if (idle) {
                m_WillCast = null;
                currTarget = null;
            }
        }
        
        public void Init(CFG_Weapon Weapon, IAction NewAction, IObj target = null, ACTOper oper = ACTOper.OneShot)
        {
            View.Debugger.LogI("AC Init: {0}, {1}, {2}, {3}", Weapon, NewAction, target, oper);

            this.oper = oper;

            if (NewAction != null) {
                this.Weapon = Weapon;
                var weaponDat = Weapon != null ? Weapon.dat : -1;
                if (m_WeaponDat != weaponDat) {
                    // 武器发生变化时，也要重置预备时间
                    UnsetReady();
                    m_WeaponDat = weaponDat;
                }
                
                m_SetTarget = target;
                if (actor.IsLocal()) {
                    if (m_SetTarget == null) {
                        m_SetTarget = NewAction.TargetFor(actor);
                    } else {
                        currTarget = m_SetTarget;
                    }
                }
            }
            
            if (prefab != NewAction) {
                if (prefab != null) {
                    actor.L.ActionStop(actor, prefab);
                }
                prefab = NewAction;
            }
        }

        public void Prepare()
        {
            if (Weapon != null && Weapon.Dura.IsEmpty()) {
                // 无效的动作初始化
                m_WillCast = null;
                currTarget = null;
                return;
            }

            // 即将进行的动作为空，或者动作已经变化，重置即将进行的动作
            if (m_WillCast == null || (prefab != null && m_WillCast != prefab)) {
                m_WillCast = prefab;
            }

            if (m_WillCast != null) {
                if (!actor.CanVisible(m_SetTarget)) {
                    m_SetTarget = null;
                }

                var newTarget = target;
                if (actor.IsLocal()) {
                    if (newTarget is NullTarget) {
                        var reTar = m_WillCast.TargetFor(actor);
                        if (reTar != null) newTarget = reTar;
                    } else if (!actor.CanVisible(newTarget)) {
                        newTarget = m_WillCast.TargetFor(actor);
                    }
                }

                currTarget = newTarget;
            }
        }

        public void SetCDFrame(int frame)
        {
            gcdFrame = frame;
        }

        public bool IsCooldown(IObj self)
        {
            return gcdFrame == 0 || gcdFrame <= self.L.frameIndex;
        }

        /// <summary>
        /// 设置就绪帧：仅首次设置有效
        /// </summary>
        public bool SetReady(int frame)
        {
            if (m_ReadyFrame == 0) {
                m_ReadyFrame = frame;
                return true;
            }
            return false;
        }

        /// <summary>
        /// 重置就绪帧：仅在离开攻击模式后才重置该值。
        /// </summary>
        public void UnsetReady()
        {
            m_ReadyFrame = 0;
            nShot = 0;
        }

        public bool IsCooling(int actionId = -1)
        {
            if (!actor.IsLocal()) return false;

            if (actionId == -1 && m_WillCast != null) actionId = m_WillCast.id;

            if (actionId > 0) {
                int nextFrame;
                if (m_NextFrames.TryGetValue(actionId, out nextFrame)) {
                    return nextFrame > actor.L.frameIndex;
                }
            }

            return false;
        }

        /// <summary>
        /// 动作是否准备就绪
        /// </summary>
        public bool IsReady()
        {
            var frameIndex = actor.L.frameIndex;
            return m_ReadyFrame > 0 && m_ReadyFrame <= frameIndex;
        }

        public IAction Start(IAction Action = null)
        {
            if (Action == null) {
                nShot += 1;
                totalShot += 1;
                m_Casting = m_WillCast;
            } else {
                m_Casting = Action;
            }

            return m_Casting;
        }

        public void Success()
        {
            if (m_Casting != null) {
                if (actor.IsLocal()) {
                    var nextFrame = actor.L.frameIndex + m_Casting.cooldown;
                    if (m_NextFrames.ContainsKey(m_Casting.id)) {
                        m_NextFrames[m_Casting.id] = nextFrame;
                    } else {
                        m_NextFrames.Add(m_Casting.id, nextFrame);
                    }
                }
            }
            m_WillCast = null;
        }

        public void Finish()
        {
            if (prefab == null) {
                Weapon = null;
                currTarget = null;
                oper = ACTOper.Auto;
            } else {
                if (prefab != m_Casting || ObjectExt.IsNull(currTarget) || !currTarget.IsAlive()) {
                    currTarget = null;
                }
            }
            if (ObjectExt.IsNull(m_SetTarget) || !m_SetTarget.IsAlive()) {
                m_SetTarget = null;
            }

            m_Casting = null;
            m_WillCast = null;
        }

        public void Cancel()
        {
            Uninit();
            m_WillCast = null;
            oper = ACTOper.Auto;
        }

        public void Reset()
        {
            if (prefab != null) {
                actor.L.ActionStop(actor, prefab);
            }

            m_Casting = null;
            m_WillCast = null;
            m_SetTarget = null;
            m_ReadyFrame = 0;
            gcdFrame = 0;
            nShot = 0; totalShot = 0;
            oper = ACTOper.Auto;

            Weapon = null;
            prefab = null;
            currTarget = null;

            if (m_NextFrames != null) {
                m_NextFrames.Clear();
            }
        }

        public override string ToString()
        {
            return string.Format("动作：{0}；目标：{1}", m_Casting ?? m_WillCast, target);
        }
    }

}
