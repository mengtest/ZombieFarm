//
//  Effects.cs
//  survive
//
//  Created by xingweizhen on 10/19/2017.
//
//

using System.Collections.Generic;
#if ULUA
using NoExport = NoToLuaAttribute;
#else
using NoExport = XLua.BlackListAttribute;
#endif
using Assert = UnityEngine.Assertions.Assert;

namespace World
{
#region 多重效果

    public interface IEffectGrp
    {
        int Count { get; }
        CFG_Effect this[int i] { get; }
    }

    public class MultiEffect : IEffectGrp
    {
        public int Count { get { return m_Effs.Count; } }
        public CFG_Effect this[int i] { get { return m_Effs[i]; } }

        private List<CFG_Effect> m_Effs;
        public MultiEffect()
        {
            m_Effs = new List<CFG_Effect>();
        }

        public void AddEffect(CFG_Effect Eff)
        {
            m_Effs.Add(Eff);
        }
    }
#endregion


#region 效果基类
    public abstract class CFG_Effect : ITimerParam, IEffectGrp
    {
        public class Effecting : IEventParam
        {
            public IObj Who { get; private set; }
            public IObj Whom { get; private set; }
            public CFG_Effect Eff { get; private set; }
            public HitResult hit { get; private set; }

            private Effecting() { }
            private static Effecting S = new Effecting();
            public static Effecting Apply(IObj Who, IObj Whom, CFG_Effect Eff, HitResult hit)
            {
                S.Who = Who;
                S.Whom = Whom;
                S.Eff = Eff;
                S.hit = hit;
                return S;
            }
        }

        [NoExport]
        public static readonly string[] DMGType = { "", "物理", "魔法", "所有" };

        [NoExport]
        public CFG_SubSk UpDS;
        public int skillId { get { return UpDS != null ? UpDS.id : 0; } }
        public float power { get { return UpDS != null ? UpDS.power : 0; } }

        public int id;
        [NoExport]
        public string func;
        [NoExport]
        public string fxH;
        [NoExport]
        public int duration;
        [NoExport]
        public bool hitChk;
        public virtual bool targetIsUnit { get { return true; } }

        [NoExport]
        public CFG_Effect()
        {
            fxH = null;
            duration = 0;
        }

        [NoExport]
        public int Count { get { return 1; } }
        [NoExport]
        public CFG_Effect this[int i] { get { return this; } }

        [NoExport]
        public CFG_Effect(CFG_Effect Eff)
        {
            UpDS = Eff.UpDS;
            id = Eff.id;
            duration = Eff.duration;
            fxH = Eff.fxH;
            hitChk = Eff.hitChk;
        }

        [NoExport]
        public CFG_Effect(CFG_SubSk Sub, int id, string func)
        {
            UpDS = Sub;
            this.id = id;
            this.func = func;
        }

        protected abstract HitResult Execute(IObj Who, IObj Whom);

        [NoExport]
        public virtual void InitWithTimer(Timer tm, int arg)
        {
        }

        public override string ToString()
        {
            return string.Format("<color=yellow>[<{0}>#{1}]</color>", func, id);
        }

        [NoExport]
        public static System.Func<int, CFG_SubSk, IEffectGrp> Load;

        [NoExport]
        public static HitResult ExecEffect(IObj Who, IObj Whom, CFG_Effect Eff, bool hitRet)
        {
            //if (!Whom.IsSelectable(Who)) {
            //    Who.T("{0}的{1}无法攻击{2}。", Who, Eff, Whom);
            //    return HitResult.None;
            //}

            if (Eff.hitChk && !hitRet) {
                Whom.L.Effecting(Whom, Effecting.Apply(Who, Whom, Eff, HitResult.Dodge));
                return HitResult.Dodge;
            }

            var ret = Eff.Execute(Who, Whom);
            Whom.L.Effecting(Whom, Effecting.Apply(Who, Whom, Eff, ret));

            return ret;
        }

        /// <summary>
        /// 对单位造成效果
        /// </summary>
        [NoExport]
        public static HitResult ExecEffect(IObj Who, IObj Whom, IEnumerable<CFG_Effect> Effs, bool hitRet, bool targetIsUnit = true)
        {
            if (targetIsUnit) {
                Assert.IsNotNull(Whom.L);

                var hitResult = HitResult.None;
                using (var itor = Effs.GetEnumerator()) {
                    while (itor.MoveNext()) {
                        var Eff = itor.Current;
                        if (Eff.targetIsUnit) {
                            if (ExecEffect(Who, Whom, Eff, hitRet) == HitResult.Hit) {
                                hitResult = HitResult.Hit;
                            }
                        } else {
                            hitResult = HitResult.Hit;
                        }
                    }
                }
                return hitResult;
            } else {
                using (var itor = Effs.GetEnumerator()) {
                    while (itor.MoveNext()) {
                        var Eff = itor.Current;
                        if (!Eff.targetIsUnit) {
                            ExecEffect(Who, Whom, Eff, hitRet);
                        }
                    }
                }
                return HitResult.Hit;
            }
        }

        [NoExport]
        public virtual string GetTimerUnique(IObj Who, IObj Whom)
        {
            return null;
        }
    }
#endregion

    public class DamageEffect : CFG_Effect
    {
        public readonly int unitMask;
        public readonly int dmgType;
        
        public DamageEffect(CFG_SubSk Sub, int id, string func, int unitMask, int dmgType)
            : base(Sub, id, func)
        {
            this.unitMask = unitMask;
            this.dmgType = dmgType;
        }

        protected override HitResult Execute(IObj Who, IObj Whom)
        {
            if (Who.L.localMode) {
                var living = Whom as ILiving;
                if (living != null) {
                    var change = -living.Health.GetLimit() / 4;
                    living.ChangeHp(new VarChange(change, UpDS.UpDS, Who));
                }
            }

            return HitResult.Hit;
        }
    }

    public class DirectDamage : CFG_Effect
    {
        public DirectDamage(CFG_SubSk Sub, int id, string func)
            : base(Sub, id, func)
        {

        }

        protected override HitResult Execute(IObj Who, IObj Whom)
        {
            if (Who.L.localMode) {
                var living = Whom as ILiving;
                if (living != null) {
                    var change = -living.Health.GetLimit() / 4;
                    living.ChangeHp(new VarChange(change, UpDS.UpDS, Who));
                }
            }

            return HitResult.Hit;
        }
    }

    public class ReloadEffect : CFG_Effect
    {
        public enum Mode { Value = 1, Percent, LimitPercent, }
        public readonly Mode mode;
        public readonly int value;

        public ReloadEffect(CFG_SubSk Sub, int id, string func, int mode, int value)
            : base(Sub, id, func)
        {
            this.mode = (Mode)mode;
            this.value = value;
        }

        protected override HitResult Execute(IObj Who, IObj Whom)
        {
            if (!Who.L.localMode) return HitResult.Hit;

            var human = Whom as Human;
            if (human != null) {
                var Equip = human.Major;
                var reloadValue = 0;
                switch (mode) {
                    case Mode.Value: reloadValue = value; break;
                    case Mode.Percent:
                        reloadValue = (int)(Equip.Dura.GetLimit() * (value / 1000f)); break;
                    case Mode.LimitPercent:
                        var limit = (int)(Equip.Dura.GetLimit() * (value / 1000f));
                        reloadValue = limit - Equip.Ammo.GetValue();
                        if (reloadValue < 0) reloadValue = 0;
                        break;
                    default: break;
                }
                if (reloadValue > 0) {
                    human.ChangeDura(Equip, reloadValue);
                }
            }

            return HitResult.Hit;
        }
    }

    public class SimpleBuff : IConfig, ITimerParam
    {
        public class Effecting : IEventParam
        {
            public int who { get; private set; }
            public int whom { get; private set; }
            public SimpleBuff Eff { get; private set; }
            public string timerUnique { get; private set; }

            private Effecting() { }
            private static Effecting S = new Effecting();
            public static Effecting Apply(int who, int whom, SimpleBuff Eff, string timerUnique)
            {
                S.who = who;
                S.whom = whom;
                S.Eff = Eff;
                S.timerUnique = timerUnique;
                return S;
            }
        }

        private static ConfigLib<SimpleBuff> _Lib;
        public static void SetLib(ConfigLib<SimpleBuff> Lib)
        {
            _Lib = Lib;
        }
        public static SimpleBuff Load(int id)
        {
            return id > 0 ? _Lib.Get(id) : null;
        }

        private readonly int m_Id;
        public int id { get { return m_Id; } }
        public readonly string fx;
        public readonly List<string> Funcs;
        public SimpleBuff(int id, string fx)
        {
            this.m_Id = id;
            this.fx = fx;
            Funcs = new List<string>();
        }

        public string Execute(IObj Who, IObj Whom, ref int duration)
        {
            int n = 0;
            foreach (var func in Funcs) {
                switch (func) {
                    case "stun": {
                            var Actor = Whom as CActor;
                            if (Actor != null) {
                                Actor.nConfine += 1;
                                n = Actor.nConfine;
                            } else duration = 0;
                            break;
                        }
                    default: if (Whom == null) duration = 0; break;
                }
            }

            if (duration > 0) {
                var timerUnique = Timer.GenEffecting(id, Whom.id, n);
                Whom.NewTimer(Whom, Whom, duration).SetParam(this)
                    .SetEvent(null, OnBuffFinish, null).SetIdentify(null, timerUnique);
                return timerUnique;
            }

            return null;
        }

        private static bool OnBuffFinish(Timer tm, int n)
        {
            var Buff = tm.param as SimpleBuff;
            foreach (var func in Buff.Funcs) {
                switch (func) {
                    case "stun": {
                            var Actor = tm.whom as CActor;
                            Actor.nConfine -= 1;
                            break;
                        }
                    default: break;
                }
            }

            return true;
        }
    }
}
