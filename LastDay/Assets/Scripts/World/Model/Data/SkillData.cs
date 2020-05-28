using System.Collections;
using System.Collections.Generic;

namespace World
{
    /// <summary>
    /// 攻击技能
    /// </summary>
    public class CFG_Skill : CFG_Action, IAction
    {
        public struct FormSkill
        {
            public int blockLevel;
            public int cooldown;
            public int cost;
            public int delay;
            public int[] SubIds;
            public string[] acts;
            public int hurt;
            public int alertRange;
        }

        public struct FormTarget
        {
            public bool allowNullTar;
            public int tarSet;
            public TARType tarType;
            public CFG_Target Target;
        }

        public readonly int comboId;
        private CFG_Skill m_Combo;
        public CFG_Skill Combo {
            get {
                if (comboId != 0 && m_Combo == null) {
                    m_Combo = Load(comboId) as CFG_Skill;
                    m_Combo.rootId = id;
                    m_Combo.power = power;
                }
                return m_Combo;
            }
        }
        public bool IsCombo { get { return rootId != id; } }

        /// <summary>
        /// 如果是连招，这代表连招前置的技能ID
        /// </summary>
        public int rootId { get; private set; }

        private readonly bool m_AllowNullTar;
        public override bool allowNullTar { get { return m_AllowNullTar; } }

        private readonly int m_BlockLevel;
        public override int blockLevel { get { return m_BlockLevel; } }

        public readonly int cost;

        private readonly int m_Cooldown;
        public int cooldown { get { return m_Cooldown; } }

        private readonly int m_Delay;
        public int delay { get { return m_Delay; } }

        private int m_Speed;
        public int speed { get { return m_Speed; } }

        private readonly int m_Hurt;
        public int hurt { get { return m_Hurt; } }

        private readonly int m_AlertRange;
        public int alertRange {  get { return m_AlertRange; } }
        
        //public int level;
        public float power;

        public readonly string[] acts;

        /// <summary>
        /// 真正的施法目标
        /// </summary>        
        public readonly int tarSet;
        public readonly TARType tarType;
        public readonly CFG_Target Target;

        private readonly int[] m_SubIds;
        private List<CFG_SubSk> m_Subs;
        public List<CFG_SubSk> Subs {
            get {
                if (m_Subs == null) {
                    m_Subs = new List<CFG_SubSk>(m_SubIds.Length);
                    for (int i = 0; i < m_SubIds.Length; ++i) {
                        var subSk = CFG_SubSk.Creator.Invoke(m_SubIds[i], this);
                        if (subSk != null) {
                            m_Subs.Add(subSk);
                            if (subSk.Bullet != null && !subSk.Bullet.HasImpact()) {
                                // 非碰撞型弹道在计算伤害表现时需要计算速度，延迟表现
                                m_Speed = subSk.Bullet.speed;
                            }
                        }
                    }
                }
                return m_Subs;
            }
        }

        /// <summary>
        /// Global Cooldown
        /// </summary>
        //public int gcd;        

        public CFG_Skill(int id, string name, ACTType type, int comboId,
            FormAct Fa, FormSkill Fs, FormTarget Ft, List<Advanced> advancedList)
            : base(id, name, type, Fa, advancedList)
        {
            this.comboId = comboId;

            cost = Fs.cost;
            m_BlockLevel = Fs.blockLevel;
            m_Cooldown = Fs.cooldown;
            m_Delay = Fs.delay;
            m_Hurt = Fs.hurt;
            m_AlertRange = Fs.alertRange;
            m_SubIds = Fs.SubIds;
            acts = Fs.acts;

            m_AllowNullTar = Ft.allowNullTar;
            tarSet = Ft.tarSet;
            tarType = Ft.tarType;
            Target = Ft.Target;
        }

        public bool UsableFor(IActor bObj)
        {
            var human = bObj as Human;
            if (human != null && human.Content.Weapon == human.Major) {
                var mpLimit = human.Major.Dura.GetLimit();
                if (mpLimit > 0) {
                    var mp = human.Major.Dura.GetValue();
                    if (cost > mp) return false;

                    var ammoLimit = human.Major.Ammo.GetLimit();
                    if (ammoLimit > 0) {
                        var ammo = human.Major.Ammo.GetValue();
                        return cost <= ammo;
                    }
                }
            }

            return true;
        }

        public IObj TargetFor(IActor bObj)
        {
            var entity = bObj as IEntity;
            
            var target = bObj.FindSuitableTarget(Target.tarFilter, Target.tarSet, alertRange);
            if (target == null && entity != null) {
                var hitRange = maxRange - bObj.GetRadius();
                if (tarType == TARType.Direction || tarType == TARType.Ground) {
                    target = new LocateObj(entity.coord + entity.forward * hitRange, entity.L);
                } else if (allowNullTar) {
                    target = new NullTarget(entity.coord + entity.forward * hitRange, entity.L);
                }
            }

#if UNITY_EDITOR
            if (bObj.Content.currTarget == null || bObj.Content.currTarget != target) {
                View.Debugger.Draw(new Shape2D(bObj.coord, alertRange), UnityEngine.Color.yellow, 1f);
            }
#endif

            return target;
        }

        public void ClampTarget(IActor bObj, ref IObj target)
        {
            if (tarType == TARType.Unit) {
                // 单位类：施法开始时就确认命中目标
                if (tarSet == TARSet.SELF) target = bObj;
                target = bObj.GetUnitTargets(target, this);
            } else if (tarType == TARType.Direction) {
                Vector srcGrid = bObj.coord;
                var Vol = bObj as IVolume;
                var forward = srcGrid == target.coord ? Vol.forward : (target.coord - srcGrid).normalized;
                target = new DirectionalTar(srcGrid, srcGrid + forward * Target.range, target.L);
            } else {
                // 位置类：先保存位置，施法完成时再确认命中目标
                if (!(target is LocateObj)) {
                    target = new LocateObj(target.coord, target.L);
                }
            }
        }

        /// <summary>
        ///  是终结技
        /// </summary>
        public bool IsEnd()
        {
            return Combo == null;
        }

        public override string ToString()
        {
            string strCombo = "";
            if (m_Combo != null) {
                strCombo = "->" + m_Combo.ToString();
            } else if (comboId != 0) {
                strCombo = "->[" + comboId + "]";
            }
            return string.Format("[{0}#{1} +{2}]{3}", name, id, power, strCombo);
        }

        public void OnStart(IActor bObj)
        {
            if (acts.Length > 1) {
                var index = (bObj.Content.totalShot - 1) % acts.Length;
                motion = acts[index];
            } else if (acts.Length > 0) {
                motion = acts[0];
            } else {
                motion = null;
            }
        }

        public void OnSuccess(IObj Who, IObj Whom)
        {
            Whom = ObjectExt.GetRefObj(Whom);
            if (Whom != null) {
                // 在子技能生效处再扣除耐久
                //if (Who.L.localMode) {
                //    var actor = Who as IActor;
                //    if (actor != null && ObjectExt.IsAlive(Whom) && this.cost != 0) {
                //        actor.ChangeDura(new DuraChange(-this.cost, CVar.EQUIP_BAG, CVar.MAJOR_POS));
                //    }
                //}

                var tmGrp = Who.L.tmMgr.NewGroup(Who);
                for (int i = 0; i < Subs.Count; ++i) {
                    var Sub = Subs[i];
                    Timer tm;
                    LaunchSubsk(Who, Whom, Sub, out tm);
                    if (tm != null) {
                        tmGrp.AddTimer(tm);
                    }
                }
            }
        }

        public void OnFinish(IObj Who, IObj Whom)
        {

        }

        private static void LaunchSubsk(IObj Who, IObj target, CFG_SubSk Sub, out Timer timer)
        {
            timer = null;
            if (Sub.live && !Who.IsAlive()) return;

            int loop = Sub.freq, interval = Sub.interval, delay = Sub.delay + Sub.UpDS.delay;
            if (delay == 0) {
                // 无延迟，立即生效一次
                SubSkHit(Who, target, Sub, 0);
                loop -= 1;
                if (loop == 0) {
                    // 目标已经不需要保持，释放掉
                    var obj = target as System.IDisposable;
                    if (obj != null) obj.Dispose();
                    return;
                }
            }

            var tag = Sub.freq > 1 ? TTags.HOLD : string.Empty;

            // 有剩余次数或需要延迟，由定时器管理
            timer = Who.L.tmMgr.Get(Who).Init(Who, target, interval * loop, interval, delay)
                .SetParam(Sub).SetEvent(null, OnSubSkHit, null)
                .SetIdentify(tag, Timer.GenHolding(Sub.id, Who.id));
        }

        /// <summary>
        /// 技能命中
        /// </summary>
        public static readonly TimerHandler OnSubSkHit = __OnSubSkHit;
        private static bool __OnSubSkHit(Timer tm, int n)
        {
            SubSkHit(tm.who, tm.whom, tm.param as CFG_SubSk, n);
            return true;
        }
        private static void SubSkHit(IObj Who, IObj target, CFG_SubSk Sub, int n)
        {
            if (Sub.live && !Who.IsAlive()) return;

            if (Who.L.localMode && n == 0) {
                var human = Who as Human;
                if (human != null && human.Content.Weapon != null && Sub.primary && Sub.UpDS.cost != 0) {
                    human.ChangeDura(human.Major, -Sub.UpDS.cost);
                }
            }

            if (Sub.Bullet == null) {
                HittingTarget(Who, target, Sub);
            } else {
                Missile.Fire(Who, target, Sub);
            }

            if (Who.L.localMode) {
                var human = Who as Human;
                if (human != null && Sub.cost != 0) {
                    human.ChangeDura(human.Major, -Sub.cost);
                }
            }
        }

        public static void HittingTarget(IObj Who, IObj target, CFG_SubSk Sub)
        {
            // 对位置造成效果
            CFG_Effect.ExecEffect(Who, target, Sub.Effs, true, false);
            
            if (Sub.tarType != TARType.None || target.id == 0) {
                // 需要重新选择目标
                target = Who.GetTargetGroup(target, Sub);
            }
            
            Who.L.HitTarget(Who, HitEvent.Apply(Who, target, Sub, HitResult.Hit));
            var Targets = target as IEnumerable<IObj>;
            if (Targets != null) {
                foreach (var obj in Targets) {
                    var result = ExecHitting(Who, obj, Sub);
                    if (obj != null) {
                        obj.L.BeingHit(obj, HitEvent.Apply(Who, obj, Sub, result));
                    }
                }
            } else {
                var result = ExecHitting(Who, target, Sub);
                if (target != null) {
                    target.L.BeingHit(target, HitEvent.Apply(Who, target, Sub, result));
                }
            }
        }

        private static HitResult ExecHitting(IObj Who, IObj target, CFG_SubSk Sub)
        {
            //if (!Whom.IsAlive()) {
            //    Who.T("{0}已经死亡，{1}的{2}施放失败。", Whom, Who, Sub);
            //    return HitResult.None;
            //}

            var hitResult = HitResult.None;
            bool dodge = false; // 强制闪避
            bool miss = false;  // 强制丢失

            if (dodge) {
                // 强制闪避
                hitResult = HitResult.Dodge;
                //Whom.T("{0}闪避了{1}的{2}。", Whom, Who, Sub);
            } else {
                if (!miss) {
                    string strImmune = null;
                    if (CheckImmuneSkill(Who, target)) {
                        strImmune = "(技能免疫)";
                    }

                    bool hitRet = true;// atker.ChkHiting(Whom as IAttacker);
                    if (strImmune == null || Who.camp == target.camp) {
                        hitResult = CFG_Effect.ExecEffect(Who, target, Sub.Effs, hitRet);
                    } else {
                        hitResult = HitResult.Immune;
                        //Whom.T("{0}免疫了{1}的{2}{3}。", Whom, Who, Sub, strImmune);
                    }

                    if (hitResult == HitResult.Hit) {
                        // 普攻 - 法球效果
                        CheckOrbAttack(Who, target);
                        // 普攻 - 受击闪避
                        CountingDodgeOnHit(Who, target);
                    } else {
                        //if (Sub.Effs.Count > 0 && strImmune == null) {
                        //    Who.T("{0}的{1}没有命中{2}。({3})", Who, Sub, Whom, CVar.GetHitText(hitResult));
                        //}
                    }
                } else {
                    hitResult = HitResult.Miss;
                    //Who.T("{0}的{1}对{2}失手了。(致盲)", Who, Sub, Whom);
                }
                //MOBASnalyse.Hit(Who, Sub.UpDS.id, 1);
            }
            return hitResult;
        }

        /// <summary>
        /// 法球效果：每隔n次普攻触发一次额外效果
        /// </summary>
        private static void CheckOrbAttack(IObj Who, IObj Whom)
        {
            //var list = Who.GetTimersOn(typeof(CountOnHitEffect));
            //for (int i = 0; i < list.Count; ++i) {
            //    var tm = list[i];
            //    var Eff = tm.param as CountOnHitEffect;
            //    tm.value -= 1;
            //    if (tm.value == 0) {
            //        tm.value = Eff.amount;
            //        Eff.OnHit(Who, Whom);
            //    }
            //}
            //TimerManager.ReleasePool(list);
        }

        /// <summary>
        /// 闪避效果：计数
        /// </summary>
        private static void CountingDodgeOnHit(IObj Who, IObj Whom)
        {
            //var list = Whom.FindTimersOn(typeof(DodgeOnHitEffect));
            //for (int i = 0; i < list.Count; ++i) {
            //    list[i].value -= 1;
            //}

            //TimerManager.ReleasePool(list);
        }

        /// <summary>
        /// 免疫技能：免疫n次技能效果
        /// </summary>
        private static bool CheckImmuneSkill(IObj Who, IObj Whom)
        {
            bool immune = false;
            //var list = Whom.GetTimersOn(typeof(ImmuneSkillEffect));
            //for (int i = 0; i < list.Count; ++i) {
            //    var tm = list[i];
            //    if (tm.value > 0) {
            //        tm.value -= 1;
            //        immune = true;
            //        if (tm.value == 0) {
            //            tm.Finish();
            //        }
            //        break;
            //    }
            //}

            //TimerManager.ReleasePool(list);
            return immune;
        }
    }
}
