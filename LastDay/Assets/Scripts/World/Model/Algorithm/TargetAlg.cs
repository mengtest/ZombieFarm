using System.Collections.Generic;

namespace World
{
    using TargetListPool = ZFrame.ListPool<IObj>;

    public enum TARFilter
    {
        None = 0,
        Nearest = 1,            // 距离最近
        Farthest,           // 距离最远
        Fattest,            // 生命值最高
        Thinnest,           // 生命值最低
        HealthMost,         // 生命值比例最高        
        HealthLeast,        // 生命值比例最低
        RandomTarget       // 随机目标
    }

    public static class TargetAlg
    {
        public static List<IObj> GetPool()
        {
            return TargetListPool.Get();
        }

        public static void ReleasePool(List<IObj> list)
        {
            TargetListPool.Release(list);
        }

        public static bool IsTargetInRange(IObj target, ref IShape Range)
        {
            if (target != null) {
                var vol = target as IVolume;
                return vol != null ? Range.Intersect(vol.ToShape()) : Range.Contains(target.coord);
            }
            return true;
        }
        
        public static bool IsTargetInRange(IObj target, ref Shape2D shape)
        {
            if (target != null) {
                if (shape.Contains(target.coord)) return true;
                var vol = target as IVolume;
                return vol != null && shape.Intersect(vol);
            }
            return true;
        }
        
        public static bool IsTargetInRange(this IObj self, IObj target, float alertRange)
        {
            var shape = new Shape2D(self.coord, alertRange);
            return IsTargetInRange(target, ref shape);
        }

        /// ****************************************************************
        /// 目标寻找方法
        /// ****************************************************************
        private static IObj FindNearestTarget(IObj self, int tarSet, float range)
        {
            IObj target = null;
            var selfGrid = self.coord;
            float min = float.MaxValue;
            for (var i = 0; i < self.L.objs.Count; ++i) {
                var obj = self.L.objs[i];
                if (self.IsSet(obj, tarSet) && self.CanAttack(obj)) {
                    var val = Vector.Distance(selfGrid, obj.coord);
                    if (target == null || val < min) {
                        min = val;
                        target = obj;
                    }
                }
            }

            var area = new Shape2D(self.coord, range);
            return IsTargetInRange(target, ref area) ? target : null;
        }

        private static IObj FindFarthestTarget(IObj self, int tarSet, float range)
        {
            IObj target = null, fit = null;
            var selfGrid = self.coord;
            float max = 0f;
            var area = new Shape2D(self.coord, range);
            for (var i = 0; i < self.L.objs.Count; ++i) {
                var obj = self.L.objs[i];
                if (self.IsSet(obj, tarSet) && self.CanAttack(obj)) {
                    var val = Vector.Distance(selfGrid, obj.coord);
                    if (target == null || val > max) {
                        max = val;
                        target = obj;
                        if (IsTargetInRange(obj, ref area)) fit = target;
                    }
                }
            }

            return fit;
        }

        /// <summary>
        /// 选择范围内血量最高的目标
        /// </summary>
        private static IObj FindFattestTarget(IObj self, int tarSet, float range)
        {
            IObj target = null, fit = null;
            var selfGrid = self.coord;
            int mostHp = 0;
            float minDist = float.MaxValue;
            var area = new Shape2D(self.coord, range);
            for (var i = 0; i < self.L.objs.Count; ++i) {
                var living = self.L.objs[i] as ILiving;
                if (living != null && self.IsSet(living, tarSet) && self.CanAttack(living)) {
                    var val = Vector.Distance(selfGrid, living.coord);
                    int currHp = living.Health.GetValue();
                    if (currHp > mostHp || (currHp == mostHp && val < minDist)) {
                        mostHp = currHp;
                        minDist = val;
                        target = living;
                        if (IsTargetInRange(living, ref area)) fit = living;
                    }
                }
            }

            return fit;
        }

        /// <summary>
        /// 选择范围内血比例最高的目标
        /// </summary>
        private static IObj FindHealthMostTarget(IObj self, int tarSet, float range)
        {
            IObj target = null, fit = null;
            var selfGrid = self.coord;
            float hp = 0f;
            float minDist = float.MaxValue;
            var area = new Shape2D(self.coord, range);
            for (var i = 0; i < self.L.objs.Count; ++i) {
                var living = self.L.objs[i] as ILiving;
                if (living != null && self.IsSet(living, tarSet) && self.CanAttack(living)) {
                    var val = Vector.Distance(selfGrid, living.coord);
                    float hpp = living.Health.GetRate();
                    if (hpp > hp || (hpp == hp && val < minDist)) {
                        hp = hpp;
                        minDist = val;
                        target = living;
                        if (IsTargetInRange(living, ref area)) fit = target;
                    }
                }
            }

            return fit;
        }

        /// <summary>
        /// 选择范围内血量最少的目标
        /// </summary>
        private static IObj FindThinnestTarget(IObj self, int tarSet, float range)
        {
            IObj target = null, fit = null;
            var selfGrid = self.coord;
            int leastHp = int.MaxValue;
            float minDist = float.MaxValue;
            var area = new Shape2D(self.coord, range);
            for (var i = 0; i < self.L.objs.Count; ++i) {
                var living = self.L.objs[i] as ILiving;
                if (living != null && self.IsSet(living, tarSet) && self.CanAttack(living)) {
                    var val = Vector.Distance(selfGrid, living.coord);
                    int currHp = living.Health.GetValue();
                    if (currHp < leastHp || (currHp == leastHp && val < minDist)) {
                        leastHp = currHp;
                        minDist = val;
                        target = living;
                        if (IsTargetInRange(living, ref area)) fit = target;
                    }
                }
            }

            return fit;
        }

        /// <summary>
        /// 选择范围内血比例最少的目标
        /// </summary>
        private static IObj FindHealthLeastTarget(IObj self, int tarSet, float range)
        {
            IObj target = null, fit = null;
            var selfGrid = self.coord;
            float hp = 1f;
            float minDist = float.MaxValue;
            var area = new Shape2D(self.coord, range);
            for (var i = 0; i < self.L.objs.Count; ++i) {
                var living = self.L.objs[i] as ILiving;
                if (living != null && self.IsSet(living, tarSet) && self.CanAttack(living)) {
                    var val = Vector.Distance(selfGrid, living.coord);
                    float hpp = living.Health.GetRate();
                    if (hpp < hp || (hpp == hp && val < minDist)) {
                        hp = hpp;
                        minDist = val;
                        target = living;
                        if (IsTargetInRange(living, ref area)) fit = target;
                    }
                }
            }
            return fit;
        }

        /// <summary>
        /// 随机选择一个目标
        /// </summary>
        private static IObj FindRandomTarget(IObj self, int tarSet, float range)
        {
            IObj target = null;
            var targets = GetPool();
            var area = new Shape2D(self.coord, range);
            for (var i = 0; i < self.L.objs.Count; ++i) {
                var obj = self.L.objs[i];
                if (obj != null && self.IsSet(obj, tarSet) && self.CanAttack(obj)) {
                    if (IsTargetInRange(obj, ref area)) targets.Add(obj);
                }
            }

            if (targets.Count > 0) {
                int n = self.L.G.NextInt(targets.Count);
                target = targets[n];
            }
            ReleasePool(targets);
            return target;
        }

        public delegate IObj DelegateTarFilter(IObj self, int type, float range);
        private static readonly List<DelegateTarFilter> FilterList = new List<DelegateTarFilter> {
            FindNearestTarget,
            FindFarthestTarget,
            FindFattestTarget,
            FindThinnestTarget,
            FindHealthMostTarget,
            FindHealthLeastTarget,
            FindRandomTarget
        };

        public static IObj FindSuitableTarget(this IObj self, TARFilter tarFilter, int tarSet, float maxRange = float.MaxValue)
        {   
            var index = (int)tarFilter - 1;
            if (index >= 0 && index < FilterList.Count) {
                var filter = FilterList[index];
                return filter.Invoke(self, tarSet, maxRange);
            }

            return null;
        }

        private struct UnitNearest : IComparer<IObj>
        {
            private readonly IObj m_Self;
            public UnitNearest(IObj self)
            {
                m_Self = self;
            }

            public int Compare(IObj x, IObj y)
            {
                var xVal = Vector.Distance(m_Self.coord, x.coord);
                var yVal = Vector.Distance(m_Self.coord, y.coord);
                if (Math.IsEqual(xVal, yVal)) return 0;
                return xVal < yVal ? 1 : -1;
            }
        }

        /// <summary>
        /// 目标数量限制
        /// </summary>
        /// <param name="list">目标列表</param>
        /// <param name="cntLimit">大于0时表示最大数量，否则不限数量</param>
        /// <param name="random">值为<c>true</c>是随机选择，否则优先选离中心点近的。</param>
        public static void TrimTargets(this IObj self, List<IObj> list, int cntLimit, bool random)
        {
            var count = list.Count;
            if (random) {
                var n = count - cntLimit;
                for (int i = 0; i < n; ++i, --count) {
                    var index = self.L.G.NextInt(count);
                    list.RemoveAt(index);
                }
            } else {
                if (cntLimit > 0 && count > cntLimit) {
                    // 所有范围内的目标按照离自己的距离排序
                    list.Sort(new UnitNearest(self));
                    // 数量限制
                    list.RemoveRange(0, count - cntLimit);
                }
            }
        }

        public static void GetUnitsInShape(this IObj self, int tarSet, ref Shape2D Area, List<IObj> list)
        {
            Vector center = Area.GetCenter(self.coord);

            foreach (var tar in self.L.objs) {
                var entity = tar as IEntity;
                if (entity != null && self.IsSet(entity, tarSet) && self.CanAttack(entity)) {
                    if (Area.Intersect(entity)) {
                        Vector hitPos;
                        // 排除视线外目标
                        var block = self.L.Raycast(center, entity, CVar.FULL_BLOCK, out hitPos);
                        if (block == null) {
                            list.Add(tar);
                        }
                    }
                }
            }

            View.Debugger.Draw(ref Area, UnityEngine.Color.red, 1f);
        }

        /// <summary>
        /// 选择一个位置范围内的所有目标
        /// </summary>
        /// <param name="self">选择者</param>
        /// <param name="camp">目标的阵营</param>
        /// <param name="coord">位置中心点</param>
        /// <param name="radius">位置半径</param>
        /// <returns></returns>
		public static void GetUnitsNearGrid(this IObj self, int tarSet, Vector coord, float radius, List<IObj> list)
        {
            var circle = new Shape2D(coord, radius);
            self.GetUnitsInShape(tarSet, ref circle, list);
        }

        /// <summary>
        /// 选择一个单位范围内的所有目标
        /// </summary>
		public static void GetUnitsNearby(this IObj self, IObj Who, int camp, float radius, List<IObj> list, bool includeSelf = true)
        {
            self.GetUnitsNearGrid(camp, Who.coord, radius, list);
            if (!includeSelf) list.Remove(Who);
        }
        
        public static void GetUnitsInRect(this IObj self, int tarSet, Vector center, Vector direction, float length, float width, List<IObj> list)
        {
            direction.Normalize();
            var rectangle = new Shape2D(center, direction, new Vector(width, length));
            self.GetUnitsInShape(tarSet, ref rectangle, list);
        }

        public static IObj GetAnotherTarget(this IObj self, IObj Who, int camp, float range)
        {
            var list = GetPool();
            self.GetUnitsNearby(Who, camp, range, list, false);
            IObj ret = null;
            if (list.Count > 0) {
                ret = list[self.L.G.NextInt(list.Count)];
            }
            ReleasePool(list);
            return ret;
        }

        /// ****************************************************************
        /// 目标判定方法
        /// ****************************************************************        
        public static Shape2D GetHitArea(IObj self, IObj target, CFG_Target Target)
        {
            RangeType rangeType = Target.rangeType;
            var rot = Target.rot;
            var far = Target.far;
            var offset = Target.offset;

            switch (rangeType) {
                case RangeType.Circle: {
                        var dTar = target as DirectionalTar;
                        if (dTar == null) {
                            return new Shape2D(target.coord, Target.radius);
                        }
                        return new Shape2D(self.coord, Target.radius);
                    }                
                case RangeType.Sector: {
                        float radius = Target.radius;
                        float angle = Target.angle;
                        var selfEnt = self as IEntity;

                        Vector direction, center;
                        var dTar = target as DirectionalTar;
                        if (dTar != null) {
                            direction = (dTar.pos - dTar.coord).normalized;
                            center = dTar.coord;
                        } else {
                            direction = target.coord - self.coord;
                            if (direction == Vector.zero) {
                                if (selfEnt != null)
                                    direction = selfEnt.forward;
                            }
                            direction = direction.normalized;
                            center = target.coord;
                        }

                        var forward = direction;
                        Target.Adjust(forward, ref center, ref direction);

                        return new Shape2D(center, radius, direction, angle);
                    }
                case RangeType.Rectangle: {
                        float length = Target.length;
                        float width = Target.width; ;

                        // 方向和距离
                        var direction = target.coord - self.coord;
                        if (direction != Vector.zero) {
                            direction.Normalize();

                            // 中心点
                            var center = self.coord;
                            var forward = direction;
                            Target.Adjust(forward, ref center, ref direction);
                            center += direction * (length / 2);

                            return new Shape2D(center, direction, new Vector(width, length));
                        }
                        return new Shape2D();
                    }
                case RangeType.Annulus: {
                        var dTar = target as DirectionalTar;
                        if (dTar == null) {
                            return new Shape2D(target.coord, Target.radius, Target.outerRadius);
                        }
                        return new Shape2D(self.coord, Target.radius, Target.outerRadius);
                    }
                default: return new Shape2D();
            }
        }
        
        public static void GetTargetsInShape(IObj self, IObj target, CFG_Target Target, ref Shape2D shape, List<IObj> list)
        {
            if (shape.type != ShapeType.None) {
                self.GetUnitsInShape(Target.tarSet, ref shape, list);
                self.TrimTargets(list, Target.tarLimit, Target.tarFilter == TARFilter.RandomTarget);
            } else if (target.id > 0) {
                IObj Obj = TARSet.SELF == Target.tarSet ? self : target;
                if (Obj != null) list.Add(Obj);
            }
        }

        /// <summary>
        /// 获取目标集合
        /// </summary>
        public static List<IObj> GetHittingTargets(this IObj self, IObj target, CFG_Target Target, bool includeTarget = true)
        {            
            var shape = GetHitArea(self, target, Target);
            List<IObj> liTargets = GetPool();
            GetTargetsInShape(self, target, Target, ref shape, liTargets);
            if (!includeTarget) liTargets.Remove(target);
            return liTargets;
        }

        public static IObj GetUnitTargets(this IObj Who, IObj Whom, CFG_Skill Skill)
        {
            IObj hitTarget = Whom;
            if (Skill.tarType != TARType.Unit || Whom.id > 0) {
                var liTargets = GetHittingTargets(Who, Whom, Skill.Target);
                if (Skill.tarType == TARType.Unit && liTargets.Count == 1) {
                    hitTarget = liTargets[0];
                    ReleasePool(liTargets);
                } else {
                    hitTarget = new TargetGroup(liTargets, Whom.coord, Whom.L);
                }
            }
            return hitTarget;
        }

        public static void GetReedbedTarget(this IObj self, IObj target, CFG_Target Target, List<IObj> list)
        {
            var shape = GetHitArea(self, target, Target);
            self.L.HitReedbed(ref shape, list);
        }

        public static TargetGroup GetReedbedTarget(this IObj self, IObj Target, CFG_Weapon Weapon, CFG_Skill Skill)
        {
            if (Weapon != null && Weapon.Passive.Contains(self.L.G.SKILL_ID_BURN_REED) 
                && Skill != null && Skill.tarType != TARType.Unit) {
                var list = GetPool();
                self.GetReedbedTarget(Target, Skill.Target, list);
                if (list.Count > 0) {
                    return new TargetGroup(list, self.coord, self.L);
                }

                ReleasePool(list);
            }
            return null;
        }
    }
}
