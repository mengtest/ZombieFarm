//
//  ObjView.cs
//  survive
//
//  Created by xingweizhen on 10/13/2017.
//
//

using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;
using FMODUnity;
using FX;
using ZFrame.UGUI;

namespace World.View
{
    using Control;

    [DisallowMultipleComponent]
    public class HumanView : RoleView
    {
        public const int AFFIX_RHAND = 0;
        public const int AFFIX_LHAND = 1;

        [SerializeField]
        private Transform[] m_Props;

        public int pose { get; private set; }

        private int m_ToolDat;

        public void SetPose(int value, bool ignoreActing = false)
        {
            if (pose == value) return;
            pose = value;
            if (!ignoreActing && obj != null && obj.IsActing()) {
                var tmp = StageView.Instance.GetTmpData(obj, true);
                tmp.rewind = true;
            } else {
                RewindPose();
            }
        }

        public void RewindPose()
        {
            var roleCtrl = control as RoleAnim;
            if (roleCtrl) {
                roleCtrl.Rewind();
            }
        }

        public override void SetAction(ObjAnim ctrl, NWObjAction nwAction)
        {
            base.SetAction(ctrl, nwAction);

            var roleCtrl = control as RoleAnim;
            if (roleCtrl == null) return;

            if (obj == null) {
                roleCtrl.Rewind();
                return;
            }

            // 初始化姿态
            var mover = obj as IMovable;
            if (mover != null) {
                if (roleCtrl.anim) {
                    roleCtrl.anim.SetBool(AnimParams.SNEAK, mover.shiftingRate < 1);
                }
                StageCtrl.SendLuaEvent("SHIFT_RATE_CHANGE", mover.id, mover.shiftingRate);
            }

            if (obj.IsActing()) {
                var action = ((IActor)obj).Content.action;
                // 播放acting动作
                anim.CrossFadeInFixedTime(action.motion, 0.1f, -1, 0f);
                return;
            }

            var actor = obj as IActor;
            if (actor != null && !actor.IsLocal()) {
                switch (nwAction.status) {
                    case ObjAction.StartCast:
                    case ObjAction.NewTarget:
                        nwAction.SyncObj(obj, ObjAction.StartCast);
                        break;
                    case ObjAction.Open:
                        nwAction.SyncObj(obj);
                        break;
                    case ObjAction.CastSuccess:
                    case ObjAction.StopCast:
                        int stateHash;
                        if (anim.GetStateHash(IdleState.attackidle, pose, out stateHash)) {
                            anim.CrossFadeInFixedTime(stateHash, 0.1f);
                        } else {
                            goto default;
                        }
                        break;
                    default:
                        roleCtrl.Rewind();
                        break;
                }
            } else {
                roleCtrl.Rewind();
            }
        }

        public override bool IsCombineView() { return true; }

        #region IRenderView
        public override void GetSkins(List<Component> skins)
        {
            if (m_SkinProp == null) {
                if (skin) skins.Add(skin);
                foreach (var affix in m_Affixes) {
                    if (affix.skin) skins.Add(affix.skin);
                }
            } else {
                m_SkinProp.GetSkins(skins);
            }
        }

        protected DressType m_Dressing;
        public DressType dressing { get { return m_Dressing; } }
        public override bool IsDress(DressType dress)
        {
            return (m_Dressing & dress) != 0;
        }

        public override void SetDress(DressType dress)
        {
            m_Dressing = dress;
        }
        
        #endregion

        private readonly List<AffixView> m_Affixes = new List<AffixView>();
        public List<AffixView> Affixes {  get { return m_Affixes; } }

        private readonly Dictionary<int, string> m_AffixesData = new Dictionary<int, string>();
        public string DetachAffix(int index)
        {
            var affixName = string.Format("AFFIX-{0}", index);
            if (m_Props != null && m_Props.Length > index) {
                var trans = m_Props[index].Find(affixName);
                if (trans) {
                    var affix = trans.GetComponentInChildren(typeof(AffixView)) as AffixView;
                    if (affix) {
                        m_Affixes.Remove(affix);
                    }

                    ObjectPoolManager.DestroyPooledScenely(trans.gameObject);
                }
            }
            return affixName;
        }

        public void AttachAffix(GameObject prefab, int index, string path)
        {
            if (index >= m_Props.Length) return;

            var affixName = DetachAffix(index);
            if (m_AffixesData[index] == path && prefab) {
                var go = ObjectPoolManager.AddChildScenely(m_Props[index].gameObject, prefab);
                go.name = affixName;
                go.SetLayerRecursively(gameObject.layer);

                var affix = go.GetComponentInChildren(typeof(AffixView)) as AffixView;
                if (affix) {
                    var color = skin.GetColor(ShaderIDs.Color);
                    var props = MaterialPropertyTool.Begin(affix.skin);
                    props.TryCopyTexture(ShaderIDs.MainTex, affix.skin.sharedMaterial);
                    if (color != Color.clear) props.SetColor(ShaderIDs.Color, color);
                    MaterialPropertyTool.Finish();

                    if (obj != null) {
                        Creator.InitObjSkin(this, affix.skin,
                            (this is PlayerView) ? StageView.Assets.SelfMats : StageView.Assets.HumanMats);
                    } else {
                        Creator.InitObjSkin(affix.skin, Creator.objL.Get("HumanMat UI") as Material, 1f);
                    }

                    SetShadowMode(affix.skin);
                    m_Affixes.Add(affix);
                    affix.OnAttach();

                    var roleCtrl = control as RoleAnim;
                    affix.DelayShow(roleCtrl ? roleCtrl.CalcFadeTime() : 0f);
                    affix.skin.enabled = skin.enabled;

                    StageCtrl.SendLuaEvent("AFFIX_LOAD", obj != null ? obj.id : 0, affix);
                }
            }

            if (index == AFFIX_RHAND || index == AFFIX_LHAND) {
                this.UpdateFirePoint();
            }
        }
        
        public void SetAffixActive(int index, bool active)
        {
            if (index < m_Props.Length) {
                var prop = m_Props[index];
                if (prop) prop.gameObject.SetActive(active);
            }
        }

        public void LoadObjAffix(string path, int hand)
        {
            if (m_AffixesData.ContainsKey(hand)) {
                m_AffixesData[hand] = path;
            } else {
                m_AffixesData.Add(hand, path);
            }

            var attach = Creator.AffixAttachPool.Get();
            Creator.LoadObjAffix(path, attach.Apply(this, hand));
        }

        public void AttachTool(CFG_Weapon tool)
        {
            DetachAffix(AFFIX_RHAND);
            DetachAffix(AFFIX_LHAND);

            m_ToolDat = tool.dat;
            if (!string.IsNullOrEmpty(tool.model)) {
                var path = string.Format("Weapon/{0}/{0}", tool.model);
                LoadObjAffix(path, tool.hand);
            }
        }

        public void EquipTool(CFG_Weapon tool, bool ignoreActing = false)
        {
            if (tool == null) return;

            SetPose((int)tool.attrs[ATTR.pose], ignoreActing);

            if (m_ToolDat != tool.dat) {
                if (ignoreActing || !obj.IsActing()) {
                    AttachTool(tool);
                } else {
                    StageView.Instance.GetTmpData(obj, true).major = true;
                }
            }
        }
        
        #region EVENT HANDLER
        
        public override void OnObjMoving(IEventParam param)
        {
            var human = (Human)obj;
            if (human.GetMovingSpeed() > 0) {
                if (human.Content.action == null) {
                    EquipTool(human.Major);
                } else {
                    EquipTool(human.Content.Weapon);
                }
            }

            base.OnObjMoving(param);

            //if (!human.IsLocal() && human.GetMovingSpeed() == 0) {
            //    var status = (ObjAction)human.state;
            //    if (status <= ObjAction.SneakMove) {
            //        var roleCtrl = control as RoleAnim;
            //        if (roleCtrl) roleCtrl.ResetIdle(this, 0.1f);
            //    }
            //}
        }

        public override void OnFSMTransition(IEventParam param)
        {
            base.OnFSMTransition(param);
            var transition = (FSMTransition)param;
            var fromState = (FSM_STATE)transition.src.id;
            var toState = (FSM_STATE)transition.dst.id;

            if (toState == FSM_STATE.MOVE) {
                var roleCtrl = control as RoleAnim;
                if (roleCtrl) roleCtrl.ResetIdle(this, 0.1f);
            }
        }

        public override void OnSwapWeapon(IEventParam param)
        {
            var human = obj as Human;
            if (human != null) {
                // 强制还原姿势
                pose = -1;
                EquipTool(human.Major);
            }
        }

        public override void OnDuraChanged(DuraChange Inf)
        {
            base.OnDuraChanged(Inf);

            // 当前持有工具已损坏，立即移除掉
            var human = (Human)obj;
            if (human.IsLocal() && Inf.dura == 0 && (Inf.pos == CVar.MAJOR_POS || Inf.pos == human.Tool.id)) {
                DetachAffix(AFFIX_RHAND);
                DetachAffix(AFFIX_LHAND);
                m_ToolDat = 0;
                SetPose(0);
            }
        }

        public override void OnStatusChange(int value)
        {
            base.OnStatusChange(value);

            var human = obj as Human;
            if (human != null) {
                var stealth = value == 2;
                if (human.stealth != stealth) {
                    human.stealth = stealth;
                    UpdateStealth(stealth);
                }
            }
        }

        public override void OnActionReady(IEventParam param)
        {
            var human = (Human)obj;
            if (human.IsLocal()) {
                EquipTool(human.Content.Weapon);
            }

            var action = (IAction)param;

            if (anim && action is CFG_Skill && action.mode != ACTMode.FreeMove) {
                var ready = Mathf.Max(0.1f, CVar.F2S(action.ready));
                int stateHash;
                if (anim.GetStateHash(IdleState.attackidle, pose, out stateHash)) {
                    anim.CrossFadeInFixedTime(stateHash, ready);
                }
            }
        }

        public override void OnActionStart(IEventParam param)
        {
            var human = (Human)obj;
            if (human.IsLocal()) {
                EquipTool(human.Content.Weapon, true);
            }
            
            base.OnActionStart(param);

            var tm = (Timer)param;
            var action = (IAction)tm.param;
            foreach (var affix in m_Affixes) affix.OnActionStart(entity, action);
            
            if (string.IsNullOrEmpty(action.motion)) {
                int stateHash;
                if (anim.GetStateHash(IdleState.normal, pose, out stateHash)) {
                    anim.CrossFadeInFixedTime(stateHash, 0.1f);
                }
            }
        }

        public override void OnActionSuccess(IEventParam param)
        {
            base.OnActionSuccess(param);
            
            var tm = (Timer)param;
            var action = (IAction)tm.param;
            foreach (var affix in m_Affixes) affix.OnActionSuccess(entity, action);
        }

        public override void OnActionFinish(IEventParam param)
        {
            base.OnActionFinish(param);

            var tm = (Timer)param;
            var action = (IAction)tm.param;

            var actor = (IActor)obj;
            var acting = actor.Content.prefab != null;
            if (!acting) {
                foreach (var affix in m_Affixes) affix.OnActionStop(entity, action);
            }
        }

        public override void OnActionStop(IEventParam param)
        {
            base.OnActionStop(param);
            
            var action = (IAction)param;
            foreach (var affix in m_Affixes) affix.OnActionStop(entity, action);
        }

        public override void OnActionBreak(IEventParam param)
        {
            base.OnActionBreak(param);

            pose = -1;
            EquipTool(((Human)obj).Major);

            foreach (var affix in m_Affixes) affix.OnActionBreak(entity);
        }
        
        //public override void OnAttrChanged(IEventParam param)
        //{
        //    var Change = param as CFG_Attr.Changed;
        //    if (Change.attr == (int)ATTR.pose) {
        //        ResetAutoPose();
        //    }
        //}

        public override void OnObjDead()
        {
            base.OnObjDead();

            foreach (var affix in m_Affixes) {
                affix.OnDetach();
            }
        }

        #endregion

        public override void Subscribe(IObj o)
        {
            base.Subscribe(o);
            agent.InitAgentDoor(o.camp);
        }

        public override void UnloadView()
        {
            if (control) {
                control.enabled = false;
                control = null;
            }

            if (obj != null) {
                StageCtrl.SendLuaEvent("VIEW_UNLOAD", obj.id);
            }
        }

        protected override void OnRecycle()
        {
            // Human类的root不能被回收
            root = null;

            m_ToolDat = 0;
            foreach (var affix in m_Affixes) {
                GoTools.DestroyScenely(affix.gameObject);
            }
            m_Affixes.Clear();

            base.OnRecycle();
        }

        protected override void OnEnable()
        {
            base.OnEnable();
            this.SetViewEnable(true);
            
        }

        protected override void OnDisable()
        {
            base.OnDisable();
            this.SetViewEnable(false);
        }
    }
}
