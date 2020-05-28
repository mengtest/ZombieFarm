using System.Collections;
using System.Collections.Generic;
using Dest.Math;

namespace World
{
    public class Stage
    {
        public int frameIndex { get; private set; }
        public TimerManager tmMgr { get; private set; }
        public GVar G { get; private set; }
        public long uniqueId;

        public bool localMode;

        public Stage()
        {
            objs = new List<IObj>();
            deads = new List<IObj>();
            tmMgr = new TimerManager();
            G = new GVar(0);
            frameIndex = 0;
        }

        #region 关卡：地图
        public int Width { get; private set; }
        public int Length { get; private set; }

        public IVolume Raycast(Vector src, IObj target, int blockLv, out Vector hitPos)
        {
            IVolume hitEnt = null;
            hitPos = Vector.zero;
            var dst = target.coord;

            if (src == dst) return null;

            var minDist = float.MaxValue;
            var segment2 = Map.ToSegment(src, dst);
            View.Debugger.DrawLine(UnityEngine.Color.yellow, 1, segment2.P0, segment2.P1);
            foreach (var block in m_Blocks) {
                // 忽略目标本身
                if (block.vid > 0 && block.vid == target.id) continue;
                if (block.blockLevel < blockLv) continue;

                Vector hit;
                if (Map.IsBlock(ref segment2, block, out hit)) {
                    hit += (src - dst).normalized * 0.01f;
                    var distance = Vector.Distance(hit, src);
                    if (distance < minDist) {
                        minDist = distance;
                        hitPos = hit;
                        hitEnt = block;
                    }
                }
            }

            return hitEnt;
        }

        #endregion

        #region 关卡：单位

        /// <summary>
        /// 关卡所有对象
        /// </summary>
        public List<IObj> objs { get; private set; }
        /// <summary>
        /// 即将加入场景的对象
        /// </summary>
        private List<IObj> m_Temp = new List<IObj>();

        /// <summary>
        /// 不再处理的对象
        /// </summary>
        public List<IObj> deads { get; private set; }

        #region 阻挡对象
        /// <summary>
        /// 阻隔视线的对象
        /// </summary>
        private List<IVolume> m_Blocks = new List<IVolume>();
        public List<IVolume> blocks { get { return m_Blocks; } }

        public IEnumerator<IObj> ForEachObj()
        {
            for (int i = 0; i < objs.Count; ++i) yield return objs[i];
            for (int i = 0; i < deads.Count; ++i) yield return deads[i];
        }

        public void AddBlock(IVolume block)
        {
            m_Blocks.Add(block);
            BlockChanged(block, block.blockLevel);
        }

        private void AddBlock(IObj obj)
        {
            if (obj.id == 0) return;

            RemoveBlock(obj.id);

            var Ent = obj as IEntity;
            if (Ent != null) {
                if (Ent.blockLevel > 0) {
                    m_Blocks.Add(Ent);
                    BlockChanged(Ent, Ent.blockLevel);
                }
            }
        }

        private void RemoveBlock(int id)
        {
            if (id == 0) return;

            for (int i = 0; i < m_Blocks.Count; ++i) {
                var Block = m_Blocks[i];
                if (Block.vid == id) {
                    m_Blocks.RemoveAt(i);
                    BlockChanged(Block, 0);
                    break;
                }
            }
        }
        #endregion

        #region 芦苇丛
        private List<Reedbed> m_Reedbeds = new List<Reedbed>();

        public void AddReedbed(int id, Polygon2 polygon)
        {
            Reedbed reedbed = null;
            for (int i = 0; i < m_Reedbeds.Count; ++i) {
                if (m_Reedbeds[i].id == id) {
                    reedbed = m_Reedbeds[i];
                    break;
                }
            }
            if (reedbed == null) {
                reedbed = new Reedbed(id);
                m_Reedbeds.Add(reedbed);
            }
            reedbed.AddArea(polygon);
        }

        public void RemoveReedbed(int id)
        {
            for (int i = 0; i < m_Reedbeds.Count; ++i) {
                if (m_Reedbeds[i].id == id) {
                    m_Reedbeds.RemoveAt(i);
                    break;
                }
            }
        }

        public bool InsideReedbed(IObj obj)
        {
            foreach (var reedbed in m_Reedbeds) {
                if (reedbed.Contains(obj)) return true;
            }
            return false;
        }

        public void HitReedbed(ref Shape2D shape, List<IObj> hits)
        {
            var list = new List<Vector>();
            foreach (var reedbed in m_Reedbeds) {
                list.Clear();
                if (reedbed.Intersect(ref shape, list)) {
                    hits.Add(new ReedHit(this, reedbed, list));
                }
            }
        }
        #endregion

        private bool AddObj(List<IObj> list, IObj obj)
        {
            for (int i = 0; i < list.Count; ++i) {
                if (list[i].id == obj.id) {
                    list[i] = obj;
                    return false;
                }
            }

            list.Add(obj);
            return true;
        }

        private void UpdateObjs()
        {
            for (int i = 0; i < m_Temp.Count; ++i) {
                var obj = m_Temp[i];
                if (obj.IsAlive()) {
                    if (AddObj(objs, obj)) {
                        var bObj = obj as IBehavior;
                        if (bObj != null) bObj.OnStart();
                    }
                    AddBlock(obj);
                } else {
                    AddObj(deads, obj);
                }
            }
            m_Temp.Clear();
        }

        public void Join(IObj obj)
        {
            if (AddObj(m_Temp, obj)) {
                ObjBorn(obj);
            }

            RemoveDead(obj.id);
        }

        public void RemoveDead(int id)
        {
            for (int i = 0; i < deads.Count; ++i) {
                if (deads[i].id == id) {
                    deads.RemoveAt(i);
                    break;
                }
            }
        }

        public IObj FindById(int id, bool includeDeadObj = false)
        {
            for (int i = 0; i < objs.Count; ++i) if (objs[i].id == id) return objs[i];
            for (int i = 0; i < m_Temp.Count; ++i) if (m_Temp[i].id == id) return m_Temp[i];

            if (includeDeadObj)
                for (int i = 0; i < deads.Count; ++i) if (deads[i].id == id) return deads[i];

            return null;
        }

        public void UpdateLogic()
        {
            UpdateObjs();

            for (int i = 0; i < objs.Count;) {
                var obj = objs[i];

                var bObj = obj as IBehavior;
                if (bObj != null) {
                    bObj.OnUpdate();
                    if (!bObj.IsAlive()) {
                        bObj.OnStop();
                        goto OBJ_DEAD;
                    }
                } else {
                    if (!obj.IsAlive()) goto OBJ_DEAD;
                }

                if (obj.IsNull()) {
                    if (bObj != null) bObj.OnStop();
                    // 没有死亡就被移除
                    ObjLeave(obj);
                    objs.RemoveAt(i);
                } else {
                    i += 1;
                }
                continue;

            OBJ_DEAD:
                ObjDead(obj);
                objs.RemoveAt(i);
            }

            for (int i = 0; i < deads.Count;) {
                var obj = deads[i];
                if (obj.IsNull()) {
                    // 死亡后被移除
                    ObjLeave(obj);
                    deads.RemoveAt(i);
                } else {
                    i += 1;
                }
            }

            tmMgr.Update(frameIndex);
            frameIndex += 1;
        }

        #endregion

        #region 关卡：事件
        public event System.Action<IObj, IEventParam> onFSMTransition;
        public event System.Action<IObj, IEventParam> onSwapWeapon;
        public event System.Action<IObj, IEventParam> onObjMoving, onObjTurning;
        public event System.Action<IObj, IObj> onTargetUpdate;
        public event System.Action<IObj, IEventParam> onActionReady, onActionStart, onActionSuccess, onActionFinish, onActionBreak, onActionStop;
        public event System.Action<IObj, IEventParam> onHitTarget, onBeingHit, onEffecting, onFireMissile;
        public event System.Action<IObj, IEventParam> onAttrChanged;
        public event System.Action<IObj> onObjBorn, onObjDead, onObjLeave;
        public event System.Action<IObj, float> onShiftRateChange;
        public event System.Action<IObj, int, int> onOperChange;
        public event System.Action<IObj, int> onStatusChange, onCampChange;
        public event System.Action<IObj, Vector> onGridChange;
        public event System.Action<IObj, VarChange> onHealthChanged;
        public event System.Action<IObj, DuraChange> onDuraChanged;
        public event System.Action<IVolume, int> onBlockChanged;
        public event System.Action<IObj> onPositionChange;

        public void FSMTransition(IObj obj, IEventParam param) { if (onFSMTransition != null) onFSMTransition.Invoke(obj, param); }

        public void SwapWeapon(IObj obj, IEventParam param)
        {
            if (obj.GetFSMState() == FSM_STATE.ACTION) {
                obj.OnFSMEvent(EVENT.LEAVE_ACTION);
            }

            var bObj = obj as CActor;
            var NewWeapon = param as CFG_Weapon;
            // 当前动作的武器是新武器时才切换技能
            if (bObj != null && bObj.Content.prefab != null && bObj.Content.Weapon == NewWeapon) {
                var Action = bObj.IGetAction(-1);
                if (Action != null) {
                    bObj.Content.Init(NewWeapon, Action, null, Action.oper);
                } else {
                    LogMgr.E("武器{0}没有主技能！", NewWeapon);
                }
            } else {
                bObj.Content.Uninit();
                bObj.Content.UnsetReady();
            }
            if (onSwapWeapon != null) onSwapWeapon.Invoke(obj, param);
        }

        public void ObjMoving(IObj obj, IEventParam param) { if (onObjMoving != null) onObjMoving.Invoke(obj, param); }
        public void ObjTurning(IObj obj, IEventParam param) { if (onObjTurning != null) onObjTurning.Invoke(obj, param); }
        public void TargetUpdate(IObj obj, IObj target) { if (onTargetUpdate != null) onTargetUpdate.Invoke(obj, target); }
        public void ActionReady(IObj obj, IEventParam param) { if (onActionReady != null) onActionReady.Invoke(obj, param); }
        public void ActionStart(IObj obj, IEventParam param) { if (onActionStart != null) onActionStart.Invoke(obj, param); }
        public void ActionSuccess(IObj obj, IEventParam param) { if (onActionSuccess != null) onActionSuccess.Invoke(obj, param); }
        public void ActionFinish(IObj obj, IEventParam param) { if (onActionFinish != null) onActionFinish.Invoke(obj, param); }
        public void ActionBreak(IObj obj, IEventParam param) { if (onActionBreak != null) onActionBreak.Invoke(obj, param); }
        public void ActionStop(IObj obj, IEventParam param) { if (onActionStop != null) onActionStop.Invoke(obj, param); }

        public void HitTarget(IObj obj, IEventParam param) { if (onHitTarget != null) onHitTarget.Invoke(obj, param); }
        public void BeingHit(IObj obj, IEventParam param) { if (onBeingHit != null) onBeingHit.Invoke(obj, param); }
        public void Effecting(IObj obj, IEventParam param) { if (onEffecting != null) onEffecting.Invoke(obj, param); }
        public void FireMissile(IObj obj, IEventParam param) { if (onFireMissile != null) onFireMissile.Invoke(obj, param); }

        public void AttrChanged(IObj obj, IEventParam param) { if (onAttrChanged != null) onAttrChanged.Invoke(obj, param); }

        private void ObjBorn(IObj obj) { if (onObjBorn != null) onObjBorn.Invoke(obj); }

        private void ObjDead(IObj obj)
        {
            if (onObjDead != null) onObjDead.Invoke(obj);
            deads.Add(obj);
            RemoveBlock(obj.id);
        }

        private void ObjLeave(IObj obj)
        {
            if (onObjLeave != null) onObjLeave.Invoke(obj);
            RemoveBlock(obj.id);

#if UNITY_EDITOR
            if (obj.id != 0) {
                View.Debugger.LogD("从地图内移除：{0}", obj);
            }
#endif
        }

        public void ShiftRateChange(IObj obj, float value) { if (onShiftRateChange != null) onShiftRateChange.Invoke(obj, value); }
        public void OperChange(IObj obj, int limit, int value) { if (onOperChange != null) onOperChange.Invoke(obj, limit, value); }
        public void StatusChange(IObj obj, int value) { if (onStatusChange != null) onStatusChange.Invoke(obj, value); }
        public void CampChange(IObj obj, int value) { if (onCampChange != null) onCampChange.Invoke(obj, value); }
        public void GridChange(IObj obj, Vector last) { if (onGridChange != null) onGridChange.Invoke(obj, last); }
        public void PositionChange(IObj obj) { if (onPositionChange != null) onPositionChange.Invoke(obj); }
        
        public void HealthChanged(IObj obj, VarChange change)
        {
            if (change.change > 0 && change.value == change.change) {
                // 死而复活
                AddObj(m_Temp, obj);
                RemoveDead(obj.id);
            }
            if (onHealthChanged != null) onHealthChanged.Invoke(obj, change);
        }
        public void DuraChanged(IObj obj, DuraChange change)
        {
            var human = obj as Human;
            if (human != null && human.IsLocal() 
                && change.dura == 0 && (change.pos == CVar.MAJOR_POS || change.pos == human.Tool.id)) {
                human.OnFSMEvent(EVENT.LEAVE_ACTION);
            }
            if (onDuraChanged != null) onDuraChanged.Invoke(obj, change);
        }

        public void BlockChanged(IVolume vol, int blockLevel) { if (onBlockChanged != null) onBlockChanged.Invoke(vol, blockLevel); }
        #endregion

        public void ChangeBlock(IObj obj, int value)
        {
            if (value > 0) {
                AddBlock(obj);
            } else {
                RemoveBlock(obj.id);
            }
        }
    }
}
