//
//  ConfigData.cs
//  survive
//
//  Created by xingweizhen on 10/14/2017.
//
//

using System.Collections;
using System.Collections.Generic;

namespace World
{
    public delegate T DataLoader<T>(int id);
    
    public static class TARSet
    {
        public const int SELF = 1;
        public const int ALLY = 2;
        public const int HARM = 4;
        public const int NEUTRAL = 8;

        public static bool IsSet(this IObj self, IObj target, int set)
        {
            if (target.camp > 0) {
                if (self.id == target.id) return (set & SELF) != 0;
                if (self.camp == target.camp) return (set & ALLY) != 0;
                return (set & HARM) != 0;
            }

            return false;
        }
    }
    
    /// <summary>
    /// 目标类型
    /// </summary>
    public enum TARType { None, Unit, Ground, Direction, }

    /// <summary>
    /// 范围类型
    /// </summary>
    public enum RangeType { None, Single, Circle, Sector, Rectangle, Annulus, SectorAnnulus, }

    /// <summary>
    /// 弹道类型
    /// </summary>
    public enum BulletMode { _, Normal, Bounce }

    /// <summary>
    /// 命中结果
    /// SEP前面的是自身结果，后面的是目标结果
    /// </summary>
    public enum HitResult { None, Hit, Miss, Lost, Absorb, SEP, Dodge, Resist, Immune, }

    /// <summary>
    /// 触发进阶动作的条件
    /// </summary>
    public enum AdvancedCond { NONE, Charge, onHpPercent, inHpPercent, onHp, inHp, }

    public enum ATTR : uint
    {
        /// <summary>
        /// 武器模式
        /// </summary>
        [Description("武器类型")]
        pose,

        /// <summary>
        /// 生命值上限
        /// </summary>
        [Description("生命上限")]
        Hp,
        
        /// <summary>
        /// 攻击力
        /// </summary>
        [Description("攻击")]
        Atk,

        /// <summary>
        /// 防御力
        /// </summary>
        [Description("防御")]
        Def,

        /// <summary>
        /// 移动速度
        /// </summary>
        [Description("移动速度")]
        Move,
        
        /// <summary>
        /// 转向速度
        /// </summary>
        [Description("转向速度")]
        Turn,

        /// <summary>
        /// 攻击速度
        /// </summary>
        [Description("攻击速度")]
        Fast,

        /// <summary>
        /// 潜行速度
        /// </summary>
        [Description("潜行速度")]
        Sneak,

        [Description("清洁度等级 ")]
        Smell,

        /// <summary>
        /// 警戒范围
        /// </summary>
        [Description("警戒距离(日)")]
        dayAlert,
        [Description("视觉距离(日)")]
        daySightRad,
        [Description("视觉角度(日)")]
        daySightAngle,

        [Description("警戒距离(夜)")]
        nightAlert,
        [Description("视觉距离(夜)")]
        nightSightRad,
        [Description("视觉角度(夜)")]
        nightSightAngle,

        [Description("增加视野")]
        visionAdd,
        [Description("替换视野")]
        visionReplace,

        _END_,
    }
    
    /// <summary>
    /// 战斗属性
    /// </summary>
    public class CFG_Attr
    {
        public class Changed : IEventParam
        {
            public int attr { get; private set; }
            public float oldValue { get; private set; }
            public float newValue { get; private set; }

            private Changed() { }
            private static Changed S = new Changed();
            public static Changed Apply(int attr, float oldValue, float newValue)
            {
                S.attr = attr;
                S.oldValue = oldValue;
                S.newValue = newValue;
                return S;
            }
        }

        private static readonly string[] AttrNames;
        static CFG_Attr()
        {
            AttrNames = new string[(int)ATTR._END_];
            for (int i = 0; i < (int)ATTR._END_; ++i) {
                var attr = (ATTR)i;
                AttrNames[i] = attr.ToString().ToLower();
            }
        }
        public static bool Name2Attr(string name, out int attr)
        {
            attr = -1;
            for (int i = 0; i < AttrNames.Length; ++i) {
                if (string.Compare(name, AttrNames[i], System.StringComparison.OrdinalIgnoreCase) == 0) {
                    attr = i;
                    return true;
                }
            }

            return false;
        }

        private float[] m_Array;

        public float this[int a] {
            get {
                return a >= 0 && a < m_Array.Length ? m_Array[a] : float.NaN;
            }
            set {
                if (a >= 0 && a < m_Array.Length) {
                    m_Array[a] = value;
                }
            }
        }

        public float this[ATTR a] {
            get { return m_Array[(int)a]; }
            set { m_Array[(int)a] = value; }
        }

        public float this[string name] {
            get {
                int a;
                if (Name2Attr(name, out a)) {
                    return m_Array[a];
                }
                return float.NaN;
            }
            set {
                int a;
                if (Name2Attr(name, out a)) {
                    m_Array[a] = value;
                }
            }
        }

        public void Clear()
        {
            for (int i = 0; i < (int)ATTR._END_; ++i) {
                m_Array[i] = 0;
            }
        }

        public void CopyFrom(CFG_Attr attrs)
        {
            for (int i = 0; i < (int)ATTR._END_; ++i) {
                m_Array[i] = attrs[i];
            }
        }

        public CFG_Attr()
        {
            m_Array = new float[(int)ATTR._END_];
        }

        public CFG_Attr(CFG_Attr Attr) : this()
        {
            CopyFrom(Attr);
        }

        public static CFG_Attr Temp = new CFG_Attr();
    }

    public class CFG_Target
    {
        public RangeType rangeType { get; private set; }
        public int tarSet { get; private set; }
        public TARFilter tarFilter { get; private set; }
        public int tarLimit { get; private set; }
        public int[] Params { get; private set; }
        public float range { get { return Params[0] * CVar.LENGTH_RATE; } }
        public float radius { get { return Params[0] * CVar.LENGTH_RATE; } }
        public float length { get { return Params[0] * CVar.LENGTH_RATE; } }
        public float width { get { return Params[1] * CVar.LENGTH_RATE; } }
        public float angle { get { return Params[1]; } }
        public float outerRadius { get { return Params[1] * CVar.LENGTH_RATE; } }
        public float rot { get { return (Params.Length > 2) ? Params[2] : 0; } }
        public float far { get { return (Params.Length > 3) ? Params[3] * CVar.LENGTH_RATE: 0; } }
        public float offset { get { return (Params.Length > 4) ? Params[4] * CVar.LENGTH_RATE : 0; } }

        public CFG_Target() { }
        public CFG_Target(RangeType rangeType, int tarSet, int tarLimit, TARFilter tarFilter, int[] Params)
        {
            this.rangeType = rangeType;
            this.tarSet = tarSet;
            this.tarLimit = tarLimit;
            this.tarFilter = tarFilter;
            this.Params = Params;
        }
        public CFG_Target(CFG_Target Dup)
        {
            Reset(Dup);
            Params = new int[Dup.Params.Length];
            System.Array.Copy(Dup.Params, Params, Params.Length);
        }

        public void Adjust(Vector forward, ref Vector center, ref Vector direction)
        {
            if (rangeType == RangeType.Single || rangeType == RangeType.Sector || rangeType == RangeType.Rectangle) {
                center += forward * far;
                center += Vector.RotateOffset(forward, 90) * offset;

                direction = Vector.RotateOffset(direction, rot);
            }
        }

        public void Reset(CFG_Target Dup)
        {
            rangeType = Dup.rangeType;
            tarSet = Dup.tarSet;
            tarFilter = Dup.tarFilter;
            tarLimit = Dup.tarLimit;
        }

        public void SetParams(params int[] Args)
        {
            Params = Args;
        }

        public override string ToString()
        {
            return string.Format("[DS_Target:{0},{1},{2},{3}]", rangeType, tarSet, tarFilter, tarLimit);
        }

        private static CFG_Target s_Temp = new CFG_Target();
        public static CFG_Target Temp(CFG_Target Dup)
        {
            s_Temp.Reset(Dup);
            s_Temp.Params = Dup.Params;
            return s_Temp;
        }
    }

    public class CFG_Bullet
    {
        public struct Form
        {
            public BulletMode mode;
            public float sizeA, sizeB;
            public int speed;
            public int tarLimit;
            public string fx, sfx;
            public int[] Params;
        }

        public readonly BulletMode mode;
        public readonly float sizA, sizB;
        public readonly int speed;
        public readonly int tarLimit;
        public readonly string fx;
        public readonly string sfx;
        public readonly int[] Params;
        public int bounceCount { get { return Params != null && Params.Length > 0 ? Params[0] : 0; } }
        public float bounceRange { get { return Params != null && Params.Length > 1 ? Params[1] : 0; } }

        public bool HasImpact()
        {
            return sizA > 0 || sizB > 0;
        }

        public CFG_Bullet(Form form)
        {
            mode = form.mode;
            sizA = form.sizeA; sizB = form.sizeB;            
            speed = form.speed;
            tarLimit = form.tarLimit;
            fx = form.fx; sfx = form.sfx;
            Params = form.Params;
        }
    };

    public class HitEvent : IEventParam
    {
        public IObj Who { get; private set; }
        public IObj Whom { get; private set; }
        public IHitData Fx { get; private set; }
        public HitResult hit { get; private set; }

        private HitEvent() { }

        private static HitEvent S = new HitEvent();
        public static HitEvent Apply(IObj Who, IObj Whom, IHitData Fx, HitResult hit)
        {
            S.Who = Who;
            S.Whom = Whom;
            S.Fx = Fx;
            S.hit = hit;
            return S;
        }

    }

    public class CFG_SubSk : ITimerParam, IHitData
    {
        public static System.Func<int, CFG_Skill, CFG_SubSk> Creator;

        public struct Form
        {
            public TARType tarType;
            public int cost;
            public int delay;
            public bool live;
            public string fxH;
            public string sfxH;

            public int interval, freq;
            public FxView holdFx;
        }
        
        public CFG_Skill UpDS;
        public bool primary { get; private set; }
        public int skillId { get { return UpDS != null ? UpDS.id : 0; } }
        public float power { get { return UpDS != null ? UpDS.power : 0; } }

        /// <summary>
        /// 是否需要施法者活着才能生效
        /// </summary>
        public bool live { get; private set; }

        private readonly int m_ID;
        public int id { get { return m_ID; } }
        public readonly string name;
                
        public readonly int cost;

        /// <summary>
        /// 触发间隔
        /// </summary>
        public readonly int interval;
        /// <summary>
        /// 触发次数
        /// </summary>
        public readonly int freq;

        public readonly TARType tarType;
        public readonly CFG_Target Target;

        public IAction Action { get { return UpDS; } }

        private readonly string m_HitFx;
        public string fxH { get { return m_HitFx; } }

        private readonly string m_HitSfx;
        public string sfxH { get { return m_HitSfx; } }

        //public int mpMe;
        //public int mpTar;

        public readonly int delay;
        public readonly CFG_Bullet Bullet;
        public readonly List<CFG_Effect> Effs;
                
        public bool IsEnd()
        {
            if (UpDS == null) return true;

            return UpDS.IsEnd();
        }
        
        public CFG_SubSk()
        {
            primary = false;
        }

        public CFG_SubSk(CFG_Skill Skill, int id, Form form, CFG_Target Target, CFG_Bullet Bullet)
        {
            this.UpDS = Skill;
            this.name = Skill.name;
			primary = Skill.Subs.Count == 0;

            m_ID = id;
            tarType = form.tarType;
            cost = form.cost;
            delay = form.delay;
            interval = form.interval;
            freq = form.freq;
            live = form.live;
            m_HitFx = form.fxH; m_HitSfx = form.sfxH;

            this.Target = Target;
            this.Bullet = Bullet;

            Effs = new List<CFG_Effect>();
        }

        public CFG_SubSk(CFG_SubSk _Sub)
        {
            UpDS = _Sub.UpDS;
            m_ID = _Sub.id;
            name = _Sub.name;
            Target = new CFG_Target();
            Effs = new List<CFG_Effect>();
        }

        public void AddEffect(CFG_Effect Eff)
        {
            Eff.UpDS = this;
            Effs.Add(Eff);
        }

        public void GetTarCfg(out TARType tarType, out CFG_Target target)
        {
            if (UpDS != null && this.tarType == TARType.None) {
                tarType = UpDS.tarType;
                target = UpDS.Target;
            } else {
                tarType = this.tarType;
                target = this.Target;
            }
        }
        
        public override string ToString()
        {
            return string.Format("<color=yellow>[{0}({1})+{2}]</color>", name, id, power);
        }
    }

    public abstract class CFG_Action : ICastData
    {
        private static ConfigLib<IAction> _Lib;
        public static void SetLib(ConfigLib<IAction> Lib)
        {
            _Lib = Lib;
        }
        public static IAction Load(int id)
        {
            return id > 0 ? _Lib.Get(id) : null;
        }
        
        public struct Advanced
        {
            public AdvancedCond cond;
            public float value;
            public int skill;
        }
        
        public struct FormAct
        {
            public ACTMode mode;
            public ACTOper oper;
            public string action;
            public int ready, cast, post;
            public float minRange, maxRange;
            public FxView startFx, successFx;
        }

        private readonly int m_ID;
        public int id { get { return m_ID; } }

        public readonly string name;

        private readonly ACTMode m_Mode;
        public ACTMode mode { get { return m_Mode; } }
        
        private readonly ACTType m_Type;
        public ACTType type { get { return m_Type; } }
        
        private readonly ACTOper m_Oper;
        public ACTOper oper { get { return m_Oper; } }

        public virtual bool allowNullTar {  get { return false; } }
        public virtual int blockLevel {  get { return 1; } }

        protected int m_Ready;
        /// <summary>
        /// 准备
        /// </summary>
        public virtual int ready { get { return m_Ready; } }

        protected int m_Cast;
        /// <summary>
        /// 前摇
        /// </summary>
        public virtual int cast { get { return m_Cast; } }

        protected int m_Post;
        /// <summary>
        /// 总时间
        /// </summary>
        public virtual int post { get { return m_Post; } }
        

        private readonly float m_MinRange, m_MaxRange;
        public float minRange { get { return m_MinRange; } }
        public float maxRange {  get { return m_MaxRange; } }

        private readonly FxView m_StartFx;
        public FxView startFx { get { return m_StartFx; } }

        private readonly FxView m_SuccessFx;
        public FxView successFx { get { return m_SuccessFx; } }

        public string motion { get; protected set; }
        
        private readonly List<Advanced> m_AdvancedList;
        public int GetAdvancedId(AdvancedCond cond, int value)
        {
            if (m_AdvancedList != null) {
                for (int i = m_AdvancedList.Count - 1; i >= 0; --i) {
                    switch (m_AdvancedList[i].cond) {
                        case AdvancedCond.Charge:
                            if (value >= m_AdvancedList[i].value) return m_AdvancedList[i].skill;
                            break;
                    }
                }
            }

            return id;
        }

        public int GetAdvancedId(AdvancedCond cond, VarData data)
        {
            if (m_AdvancedList != null) {
                var value = data.GetValue();
                var rate = data.GetRate();
                for (int i = m_AdvancedList.Count - 1; i >= 0; --i) {
                    switch (m_AdvancedList[i].cond) {
                        case AdvancedCond.onHpPercent:
                            if (rate >= m_AdvancedList[i].value) return m_AdvancedList[i].skill;
                            break;
                        case AdvancedCond.inHpPercent:
                            if (rate <= m_AdvancedList[i].value) return m_AdvancedList[i].skill;
                            break;
                        case AdvancedCond.onHp:
                            if (value >= m_AdvancedList[i].value) return m_AdvancedList[i].skill;
                            break;
                        case AdvancedCond.inHp:
                            if (value <= m_AdvancedList[i].value) return m_AdvancedList[i].skill;
                            break;

                    }
                }
            }

            return id;
        }

        public CFG_Action(int id, string name, ACTType type, FormAct Fa, List<Advanced> advancedList)
        {
            m_ID = id;
            this.name = name;
            m_Mode = Fa.mode;
            m_Oper = Fa.oper;
            m_Type = type;
            m_Ready = Fa.ready;
            m_Cast = Fa.cast;
            m_Post = Fa.post < m_Cast ? m_Cast + 1 : Fa.post;
            m_MinRange = Fa.minRange;// > CVar.MIN_RNG ? Fa.minRange : CVar.MIN_RNG;
            m_MaxRange = Fa.maxRange;

            motion = Fa.action;
            m_StartFx = Fa.startFx;
            m_SuccessFx = Fa.successFx;
            
            m_AdvancedList = advancedList;
        }
        
        public override string ToString()
        {
            return string.Format("{0}#{1}", name, id);
        }
    }

    public class FxBundle
    {
        private string m_FxBundle, m_SfxBank;
        public string fxBundle { get { return m_FxBundle; } }
        public string sfxBank { get { return m_SfxBank; } }

        public void SetBundle(string fxBundle, string sfxBank)
        {
            this.m_FxBundle = fxBundle;
            this.m_SfxBank = sfxBank;
        }
    }
    
    public struct BaseData
    {
        public int id, dat;
        public int camp;
        public long master;
        public Vector pos;
        public int status;

        public BaseData(IObj obj)
        {
            id = obj.id;
            dat = obj.dat;
            camp = obj.camp;
            master = obj.master;
            pos = obj.pos;
            status = 0;
        }
    }

    public struct EntityData
    {
        public Vector size;
        public Vector forward;
        public int operLimit, operId;
        public bool obstacle;
        public int blockLevel;
        public int layer;
        public bool offensive;
        public int deadType, deadValue;

        public EntityData(XObject xObj)
        {
            size = xObj.size;
            forward = xObj.forward;
            operLimit = xObj.operLimit;
            operId = xObj.operId;
            obstacle = xObj.obstacle;
            blockLevel = xObj.blockLevel;
            layer = xObj.layer;
            offensive = xObj.offensive;
            deadType = xObj.deadType;
            deadValue = xObj.deadValue;
        }
    }

    public class ObjData : FxBundle
    {
        public int bodyMat;
        public int gender;
        public readonly Dictionary<string, string> Extends;
        public readonly Dictionary<string, float> Numbers;

        public string GetExtend(string extKey)
        {
            string fxPath = null;
            if (Extends != null) {
                Extends.TryGetValue(extKey, out fxPath);
            }
            return fxPath;
        }

        public float GetNumber(string extKey, float def = 0f)
        {
            float number = def;
            if (Numbers != null) {
                if (!Numbers.TryGetValue(extKey, out number)) number = def;
            }
            return number;
        }

        public void SetExtend(string extKey, string value)
        {   
            if (Extends.ContainsKey(extKey)) {
                if (!string.IsNullOrEmpty(value)) {
                    Extends[extKey] = value;
                } else {
                    Extends.Remove(extKey);
                }
            } else {
                if (!string.IsNullOrEmpty(value)) {
                    Extends.Add(extKey, value);
                }
            }
        }

        public ObjData(int bodyMat, int gender, string fxBundle, string sfxBank, 
            Dictionary<string, string> objFxes, Dictionary<string, float> objNumbers)
        {
            this.bodyMat = bodyMat;
            this.gender = gender;
            SetBundle(fxBundle, sfxBank);

            Extends = new Dictionary<string, string>();
            if (objFxes != null) {
                foreach (var kv in objFxes) Extends.Add(kv.Key, kv.Value);
            }

            Numbers = new Dictionary<string, float>();
            if (objNumbers != null) {
                foreach (var kv in objNumbers) Numbers.Add(kv.Key, kv.Value);
            }
        }

        public static ObjData Empty = new ObjData(0, 0, null, null, null, null);
    }

}
