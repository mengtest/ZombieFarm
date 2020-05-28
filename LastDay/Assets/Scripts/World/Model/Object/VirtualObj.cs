//
//  VirtualObj.cs
//  survive
//
//  Created by xingweizhen on 10/19/2017.
//
//

using System.Collections;
using System.Collections.Generic;
using Dest.Math;

namespace World
{
    public interface IRefObj : IObj
    {
        IObj target { get; }
    }

    public abstract class VirtualObj : IObj
    {
        public virtual int id { get { return 0; } }
        public virtual int dat { get { return 0; } }
        public virtual int camp { get { return 0; } }
        public virtual long master { get { return 0; } }
        public virtual IObjView view { get { return null; } set { } }
        public float Dist { get; set; }
        public Stage L { get; private set; }
        public abstract Vector pos { get; set; }
        public virtual Vector coord { get { return pos; } }

        public VirtualObj(Stage L)
        {
            this.L = L;
        }

        public virtual bool IsAlive() { return true; }

        public virtual bool IsNull() { return false; }

        public virtual  bool IsVisible(IObj by) { return true; }
        
        public virtual bool IsSelectable(IObj by) { return false; }

        public void Destroy() { }

        public override bool Equals(object obj)
        {
            var o = obj as IObj;
            if (o  != null && o.GetType() == GetType()) {
                return o.pos == pos;
            }

            return base.Equals(obj);
        }

        public override int GetHashCode()
        {
            return 991532785 + pos.GetHashCode();
        }

        public static bool operator ==(VirtualObj obj1, VirtualObj obj2)
        {
            return EqualityComparer<VirtualObj>.Default.Equals(obj1, obj2);
        }

        public static bool operator !=(VirtualObj obj1, VirtualObj obj2)
        {
            return !(obj1 == obj2);
        }

        public IGrid Grid { get; set; }
    }

    public sealed class BlockObj : IVolume
    {
        public int vid { get { return 0; } }
        public Vector point { get; private set; }
        public Vector forward { get; set; }
        public Vector size { get; set; }
        public int blockLevel { get; private set; }

        public BlockObj(Vector point, Vector size, Vector forward, int block)
        {
            this.point = point;
            this.size = size;
            this.forward = forward;
            this.blockLevel = block;
        }
    }

    public sealed class Reedbed
    {
        public int id { get; private set; }
        private List<Polygon2> m_Polygons;
        public Reedbed(int id)
        {
            this.id = id;
            m_Polygons = new List<Polygon2>();
        }

        public void AddArea(Polygon2 polygon)
        {
            m_Polygons.Add(polygon);
        }

        public bool Contains(IObj obj)
        {
            var point = obj.coord;
            point.x = (int)(point.x + 0.5f);
            point.z = (int)(point.z + 0.5f);
            foreach (var polygon in m_Polygons) {
                if (polygon.ContainsConvexCCW(point)) {
                    return true;
                }
            }
            return false;
        }

        public bool Intersect(ref Shape2D shape, List<Vector> list)
        {
            foreach (var polygon in m_Polygons) {
                float xMin, xMax, yMin, yMax;
                polygon.GetBound(out xMin, out xMax, out yMin, out yMax);

                for (int i = (int)(xMin + 0.5f); i < xMax; ++i) {
                    for (int j = (int)(yMin + 0.5f); j < yMax; ++j) {
                        if (i >= 0 && j >= 0 && i < Map.size.x && j < Map.size.z) {
                            var point = new Vector(i, j);
                            if (polygon.ContainsConvexCCW(point)) {
                                var aab = new Shape2D(point, Vector.one);
                                if (shape.Intersect(ref aab)) {
                                    list.Add(point);
                                }
                            }
                        }
                    }
                }
            }

            return list.Count > 0;
        }
    }

    public class LocateObj : VirtualObj
    {
        protected Vector m_Pos;
        public override Vector pos { get { return m_Pos; } set { m_Pos = value; } }

        public LocateObj(Vector coord, Stage L) : base(L)
        {
            m_Pos = coord;
        }

        public override string ToString()
        {
            return string.Format("[POS:{0}]", coord);
        }
    }

    public sealed class ReedHit : LocateObj
    {
        private int m_Id;
        public override int id { get { return m_Id; } }
        public Reedbed reedbed { get; private set; }
        public List<Vector> hitGrids { get; private set; }
        public ReedHit(Stage L, Reedbed reedbed, List<Vector> grids) : base(Vector.zero, L)
        {
            m_Id = reedbed.id;
            hitGrids = new List<Vector>(grids);
        }
    }

    public class NullTarget : LocateObj
    {
        public override int id { get { return -1; } }
        public NullTarget(Vector coord, Stage L) : base(coord, L)
        {

        }

        public override string ToString()
        {
            return string.Format("[NIL:{0}]", coord);
        }
    }

    /// <summary>
    /// 表示一种玩家视线不可见的目标
    /// </summary>
    public class StealthTarget : LocateObj
    {
        public StealthTarget(Vector coord, Stage L) : base(coord, L) { }

    }

    public class TargetGroup : LocateObj, IEnumerable<IObj>, System.IDisposable
    {
        public List<IObj> objs { get; private set; }
        public TargetGroup(List<IObj> objs, Vector coord, Stage L) : base(coord, L)
        {
            this.objs = objs;
        }

        public override string ToString()
        {
            return string.Format("[POS:{0}, OBJS:{1}]", pos, objs.Count);
        }

        public IEnumerator<IObj> GetEnumerator()
        {
            foreach (var obj in objs) yield return obj;
        }

        IEnumerator IEnumerable.GetEnumerator()
        {
            return GetEnumerator();
        }

        #region IDisposable Support
        private bool disposedValue = false; // 要检测冗余调用

        protected virtual void Dispose(bool disposing)
        {
            if (!disposedValue) {
                if (disposing) {
                    // TODO: 释放托管状态(托管对象)。
                }

                // TODO: 释放未托管的资源(未托管的对象)并在以下内容中替代终结器。
                // TODO: 将大型字段设置为 null。
                TargetAlg.ReleasePool(objs);

                disposedValue = true;
            }
        }

        // TODO: 仅当以上 Dispose(bool disposing) 拥有用于释放未托管资源的代码时才替代终结器。
        ~TargetGroup()
        {
            // 请勿更改此代码。将清理代码放入以上 Dispose(bool disposing) 中。
            Dispose(false);
        }

        // 添加此代码以正确实现可处置模式。
        void System.IDisposable.Dispose()
        {
            // 请勿更改此代码。将清理代码放入以上 Dispose(bool disposing) 中。
            Dispose(true);
            // TODO: 如果在以上内容中替代了终结器，则取消注释以下行。
            System.GC.SuppressFinalize(this);
        }
        #endregion
    }

    public class DirectionalTar : LocateObj
    {
        private Vector m_EndPoint;
        public Vector point { get { return m_Pos; } }
        public override Vector coord { get { return m_Pos; } }
        public override Vector pos { get { return m_EndPoint; } set { m_EndPoint = value; } }

        public DirectionalTar(Vector coord, Vector endpoint, Stage L) : base(coord, L)
        {
            m_EndPoint = endpoint;
        }

        public override string ToString()
        {
            return string.Format("[D:{0}->{1}]", coord, m_EndPoint);
        }
    }

    public class SkillTarget : VirtualObj, IRefObj
    {
        private IActor m_Self;
        private CFG_Skill m_Skill;
        private IObj m_Target;
        public IObj target { get { return m_Target; } }

        public SkillTarget(IActor Self, CFG_Skill Skill, IObj Target) : base(Self.L)
        {
            m_Self = Self;
            m_Skill = Skill;
            m_Target = Target;
        }

        public override int id { get { return m_Target != null ? m_Target.id : m_Self.id; } }
        public override int camp { get { return m_Target != null ? m_Target.camp : 0; } }
        public override IObjView view {
            get { return m_Target != null ? m_Target.view : null; }
            set { if (m_Target != null) m_Target.view = value; }
        }

        public override Vector pos {
            get { return m_Target != null ? m_Target.pos : m_Self.pos; }
            set { if (m_Target != null) m_Target.pos = value; }
        }
        public override Vector coord {
            get {
                return m_Target != null ? m_Target.coord : m_Self.coord;
            }
        }

        public override bool IsAlive()
        {
            return m_Target == null || m_Target.IsAlive();
        }

        public override bool IsNull()
        {
            return m_Target != null && m_Target.IsNull();
        }

        public override bool IsSelectable(IObj by)
        {
            if (m_Target != null) return m_Target.IsSelectable(by);

            return true;
        }

        public void UpdateTarget()
        {
            var cacheTar = m_Target;
            var range = m_Skill.maxRange;

            if (m_Self.CanAttack(cacheTar)) {
                var distance = m_Self.coord.DistanceTo(m_Target);
                if (distance > range) cacheTar = null;
            } else {
                cacheTar = null;
            }

            if (cacheTar == null) {
                var skTar = m_Skill.Target;
                cacheTar = m_Self.FindSuitableTarget(skTar.tarFilter, skTar.tarSet, range);
                var vec = m_Self as IVector;
                if (cacheTar == null && m_Skill.allowNullTar && vec != null) {
                    if (m_Target != null && m_Target.id == 0) {
                        cacheTar = m_Target;
                        cacheTar.pos = m_Self.coord + vec.forward * range;
                    } else {
                        cacheTar = new NullTarget(m_Self.coord + vec.forward * range, m_Self.L);
                    }
                }
            }
            
            if (!ObjectExt.IsEqual(m_Target, cacheTar)) {
                m_Target = cacheTar;
                m_Self.L.TargetUpdate(m_Self, m_Target);
            }
        }

        public override string ToString()
        {
            return string.Format("SKT[{0}]", m_Target);
        }
    }
}
