using System.Collections;
using System.Collections.Generic;

namespace World
{
    using MissilePool = ZFrame.Pool<Missile>;

    public class Missile : IObj, IBehavior, IEventParam
    {
        private static MissilePool m_Pool = new MissilePool(null, (ms) => {
            ms.Flying = null;
            ms.Reached = null;

            ms.L = null;
            ms.view = null;
        });

        public static Missile Get(Stage L)
        {
            Missile ms = m_Pool.Get();
            ms.L = L;
            L.Join(ms);
            return ms;
        }

        public static void Release(Missile missile)
        {
            missile.m_Hits.Clear();
            m_Pool.Release(missile);
        }

        public Stage L { get; protected set; }

        public int id { get { return 0; } }
        public int dat { get { return 0; } }
        public int camp { get { return 0; } }
        public long master { get { return 0; } }

        public IObjView view { get; set; }
        public float Dist { get; set; }

        public Vector pos { get { return m_CurrPos; } set { m_CurrPos = value; } }

        public Vector coord { get { return m_CurrPos; } }

        #region 事件管理
        public delegate void MissileHandler(Missile self, float t);
        public event MissileHandler Launch, Flying, Reached, Destrut;

        public void OnFlying()
        {
            if (Flying != null) Flying(this, m_Fly);
        }
        public void OnReached()
        {
            if (Reached != null) Reached(this, m_Fly);
        }
        #endregion

        // 发射者
        public IObj Who;
        // 发射点
        public IObj launchPoint = new LocateObj(new Vector(0f, 0f, 0f), null);
        // 命中点
        public IObj targetPoint;
        // 打击目标
        public IObj castTarget;
        public CFG_SubSk Sub { get; protected set; }
        // 已经过
        public float fGen { get; protected set; }
        // 总时间
        public int nTotal { get; protected set; }

        public IObj launchUnit {
            get { return m_Count == Sub.Bullet.bounceCount ? Who : launchPoint; }
        }

        protected float m_Fly;
        public int alive { get { return m_Fly < 0 ? 0 : 1; } }

        private Vector m_PrevPos;
        private Vector m_CurrPos;

        private List<IObj> m_Hits = new List<IObj>();

        private int m_Count;

        private void Restart()
        {
            var srcPos = launchPoint.coord;
            var dstPos = targetPoint.coord;
            var distance = Vector.Distance(srcPos, dstPos);
            fGen = 0f;
            nTotal = System.Math.Max(1, CVar.S2F(distance / Sub.Bullet.speed));
            m_Fly = 0f;

            m_PrevPos = srcPos;
            m_CurrPos = srcPos;

            if (Launch != null) Launch(this, m_Fly);
        }

        private void OnSubskHitTarget(IObj tar)
        {
            if (Sub.tarType == TARType.None) {
                CFG_Skill.HittingTarget(Who, Who.GetTargetGroup(tar, Sub), Sub);
            } else {
                CFG_Skill.HittingTarget(Who, tar, Sub);
            }
        }
        
        /// <summary>
        /// 检查子弹是否撞击到目标
        /// </summary>
        private void OnImpacted(Vector prevPos, Vector currPos, float t)
        {
            if (currPos == prevPos) return;

            var liTargets = TargetAlg.GetPool();
            var width = UnityEngine.Mathf.Lerp(Sub.Bullet.sizA, Sub.Bullet.sizB, t);
            var dist = currPos - prevPos;
            var fwd = dist.normalized;
            var length = dist.magnitude + 0.5f; // 误差半个格子；
            var center = prevPos + fwd * (length / 2);
            
            TARType tarType;
            CFG_Target cfgTarget;
            Sub.GetTarCfg(out tarType, out cfgTarget);
            Who.GetUnitsInRect(cfgTarget.tarSet, center, fwd, length, width, liTargets);
            Who.TrimTargets(liTargets, Sub.Bullet.tarLimit, false);

            for (int i = 0; i < liTargets.Count; ++i) {
                var tar = liTargets[i];
                if (m_Hits.Contains(tar)) continue;

                OnSubskHitTarget(tar);
                m_Hits.Add(tar);
                if (Sub.Bullet.tarLimit > 0 && m_Hits.Count == Sub.Bullet.tarLimit) {
                    Destroy();
                    break;
                }
            }
            TargetAlg.ReleasePool(liTargets);
        }

        /// <summary>
        /// 子弹抵达目标
        /// </summary>
        private void OnReachTarget()
        {
            OnReached();
            OnSubskHitTarget(castTarget);
            if (Sub.Bullet.mode == BulletMode.Bounce) {
                OnBouncing();
            }
        }

        /// <summary>
        /// 子弹反弹
        /// </summary>
        private void OnBouncing()
        {
            if (m_Count <= 0) return;

            m_Hits.Add(castTarget);
            IObj nextTar = null;

            var list = TargetAlg.GetPool();
            Who.GetUnitsNearby(castTarget, castTarget.camp, Sub.Bullet.bounceRange, list, false);
            if (list.Count > 0) {
                var temp = TargetAlg.GetPool();
                temp.AddRange(list);
                for (int i = 0; i < m_Hits.Count; ++i) {
                    list.Remove(m_Hits[i]);
                }
                if (list.Count == 0) {
                    nextTar = temp[Who.L.G.NextInt(temp.Count)];
                    m_Hits.Clear();
                } else if (list.Count == 1) {
                    nextTar = list[0];
                } else {
                    nextTar = list[Who.L.G.NextInt(list.Count)];
                }
                TargetAlg.ReleasePool(temp);
            }
            TargetAlg.ReleasePool(list);

            if (nextTar == null) return;

            m_Count -= 1;
            launchPoint.pos = castTarget.coord;
            castTarget = nextTar;
            targetPoint = nextTar;

            Restart();
        }

        public bool IsAlive()
        {
            return m_Fly >= 0f;
        }

        public bool IsNull()
        {
            return !IsAlive();
        }

        public void Destroy()
        {
            m_Fly = -1f;
        }

        public bool IsVisible(IObj by) { return true; }
        
        public bool IsSelectable(IObj by) { return false; }

        public bool IsLocal()
        {
            throw new System.NotImplementedException();
        }

        public void OnStart()
        {

        }

        public void OnUpdate()
        {
            // 注释此处：施法者死后，弹道继续生效
            //if (!Who.IsAlive()) {
            //    KillBehavior();
            //    return;
            //}

            fGen += 1;
            m_Fly = fGen / nTotal;

            if (Sub != null) {
                var t = m_Fly;

                if (!Sub.live || Who.IsAlive()) {
                    // 子弹飞行，接近目标中
                    var nextPos = Vector.Lerp(launchPoint.coord, targetPoint.coord, t);
                    m_CurrPos = nextPos;
                    OnFlying();

                    if (m_Fly > 1f || !targetPoint.IsAlive() || targetPoint.IsNull()) {
                        m_Fly = -1f;
                    }

                    // 检查碰撞
                    if (Sub.Bullet.HasImpact()) {
                        OnImpacted(m_PrevPos, m_CurrPos, t);
                    } else {
                        // 无碰撞的弹道
                        if (m_Fly == -1f) {
                            OnReachTarget();
                        }
                    }
                } else {
                    Destroy();
                }
            }

            m_PrevPos = m_CurrPos;
        }

        public void OnStop()
        {
            if (Destrut != null) Destrut(this, m_Fly);
            Release(this);
        }

        public void Init(IObj Who, IObj target, CFG_SubSk Sub)
        {
            this.Sub = Sub;

            if (Sub.Bullet.mode == BulletMode.Bounce) {
                m_Count = Sub.Bullet.bounceCount;
            } else {
                m_Count = 0;
            }

            this.Who = Who;
            this.castTarget = target;

            Vector srcPos, direction;

            var dTar = target as DirectionalTar;
            if (dTar != null) {
                srcPos = dTar.coord; direction = (dTar.pos - srcPos).normalized;
            } else {
                srcPos = Who.coord; direction = (target.coord - srcPos).normalized;
            }

            // 方向类型的子弹，修正其命中目标
            TARType tarType;
            CFG_Target cfgTarget;
            Sub.GetTarCfg(out tarType, out cfgTarget);
            cfgTarget.Adjust(direction, ref srcPos, ref direction);

            launchPoint.pos = srcPos;
            if (tarType == TARType.Direction) {
                targetPoint = new LocateObj(srcPos + direction * cfgTarget.range, Who.L);
                if (!(castTarget is LocateObj)) {
                    castTarget = new LocateObj(target.coord, target.L);
                }
            } else if (tarType == TARType.Unit) {
                targetPoint = target;
            } else {
                targetPoint = new LocateObj(srcPos, Who.L);
            }

            m_Hits.Clear();

            Who.L.FireMissile(Who, this);

            Restart();
        }

        public override string ToString()
        {
            return string.Format("[弹道:<{0}({1})> - <{2}>]", launchPoint, Who, targetPoint);
        }

        private static void SingleFire(IObj Who, IObj Target, CFG_SubSk Sub)
        {
            var ms = Get(Who.L);
            ms.Init(Who, Target, Sub);
        }

        private static void MultiFire(IObj Who, IEnumerable<IObj> Targets, CFG_SubSk Subsk)
        {
            using (var itor = Targets.GetEnumerator()) {
                while (itor.MoveNext()) {
                    SingleFire(Who, itor.Current, Subsk);
                }
            }
        }

        public static void Fire(IObj Who, IObj Target, CFG_SubSk Subsk)
        {
            var list = Target as IEnumerable<IObj>;
            if (list == null) {
                SingleFire(Who, Target, Subsk);
            } else {
                MultiFire(Who, list, Subsk);
            }
        }

        public IGrid Grid { get; set; }
    }
}
