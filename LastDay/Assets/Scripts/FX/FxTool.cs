using UnityEngine;
using System.Collections;
using System.Diagnostics;
using System.Collections.Generic;
using ZFrame;
using FMODUnity;
using ZFrame.Asset;
using World;
using IPosition = World.IPosition;
using IUnit = World.IObj;

namespace FX
{

    public interface IFxEnv
    {
        Vector3 Pos2World(IUnit pos);
        Vector3 Fwd2World(IUnit pos);
    }

    public static class FxTool
    {
        public static IFxEnv ENV;

        public delegate GameObject DelegatePooledAddChild(GameObject parent, GameObject prefab, int siblingIndex = -1);
        public delegate GameObject DelegateAddChild(GameObject parent, GameObject prefab = null);
        public delegate void DelegateDestroyPooled(GameObject go, float delay = 0f);

        public static DelegatePooledAddChild AddChildPooled = ObjectPoolManager.AddChildScenely;
        public static DelegateDestroyPooled DestroyPooled = ObjectPoolManager.DestroyPooledScenely;
        public static DelegateAddChild AddChild = GoTools.NewChild;
        public static Transform FxRoot { get; set; }

        public static List<IFxCtrl> GetPool()
        {
            return ListPool<IFxCtrl>.Get();
        }

        public static void ReleasePool(List<IFxCtrl> list)
        {
            ListPool<IFxCtrl>.Release(list);
        }

        public static readonly TimerHandler OnFxFinish = __OnFxFinish;
        private static bool __OnFxFinish(Timer tm, int n)
        {
            var fxList = tm.param as FxList;
            fxList.OnFinish();
            fxList.Dispose();
            return true;
        }

        public static readonly TimerHandler OnFxBreak = __OnFxBreak;
        private static bool __OnFxBreak(Timer tm, int n)
        {
            var fxList = tm.param as FxList;
            fxList.OnBreak();
            fxList.Dispose();
            return true;
        }

        public static readonly System.Action<bool, object> DisposeFxList = __DisposeFxList;
        private static void __DisposeFxList(bool interrupt, object param)
        {
            var fxList = param as FxList;
            if (interrupt) {
                fxList.OnBreak();
            } else {
                fxList.OnFinish();
            }
            fxList.Dispose();
        }

        private static bool IsFxTargetVisible(IUnit target)
        {
            // 目标为空时强制播放
            if (target == null) return true;

            return target.id == 0 || (target.view != null && target.view.IsVisible());
        }

        /// <summary>
        /// 获取特效预设
        /// </summary>
        public static GameObject Get(string fxName, bool warnIfMissing = true)
        {
            if (string.IsNullOrEmpty(fxName)) return null;

            var prefab = AssetsMgr.A.Load<GameObject>("FX/" + fxName, warnIfMissing);
            if (prefab) {
                var fx = prefab.GetComponent(typeof(IFxCfg)) as IFxCfg;
                if (fx != null) {
                    if (fx.level > FxCtrl.GLevel) {
                        return null;
                    }
                } else {
                    LogMgr.E(fxName + " is NOT an <IFxCfg>！");
                    prefab = null;
                }
            }
            return prefab;
        }

        /// <summary>
        /// 获取特效挂载点
        /// </summary>
        public static FxAnchor GetFxAnchor(IFxHolder target, GameObject fx)
        {
            var fxAnchor = fx.GetComponent(typeof(IFxAnchor)) as IFxAnchor;
            return fxAnchor != null ?
                fxAnchor.GetAnchor(target) : new FxAnchor();
        }

        public static IFxCtrl ShowFx(this IObjView self, IFxCtrl fxMain, string fxFullName, bool allowMultiple)
        {
            var prefab = fxMain.prefab;

            if (!allowMultiple) {

            }

            GameObject go = AddChildPooled(null, prefab);
            go.SetActive(true);
            go.name = fxFullName;
            var fx = go.GetComponent(typeof(IFxCtrl)) as IFxCtrl;
            fx.caster = null;
            fx.holder = null;

            var anchor = GetFxAnchor(self as IFxHolder, prefab);
            Transform parent = anchor.anchor;
            Transform trans = go.transform;
            if (parent) {
                trans.SetParent(parent, false);
                trans.localPosition += anchor.offset;
                // 屏幕特效直接返回
                //if (parent.CompareTag(TAGS.FXCamera)) {
                //    return fx;
                //}

                if (!fxMain.IsFollow) {
                    trans.SetParent(FxRoot, true);
                }
            } else {
                var pos = (self as MonoBehaviour).transform.position;
                var srcPos = new Vector3(pos.x, pos.y, pos.z);
                trans.SetParent(FxRoot);
                trans.position = srcPos + anchor.offset;
            }

            if (anchor.forward) {
                trans.forward = (self as MonoBehaviour).transform.forward;
            }

            return fx;
        }

        public static void ShowFx(this IObjView self, string fxName, string grpName = null)
        {
            if (string.IsNullOrEmpty(fxName)) return;

            var prefabFx = FxTool.Get(fxName);
            if (!prefabFx) {
                return;
            }

            var fxCfg = (IFxCfg)prefabFx.GetComponent(typeof(IFxCfg));
            var list = ListPool<IFxCtrl>.Get();
            for (int i = 0; ; ++i) {
                var fxCtrl = fxCfg.Get(i, null);
                if (fxCtrl != null) {
                    if (string.IsNullOrEmpty(grpName)) grpName = fxName;
                    var fxFullName = fxCtrl == fxCfg ? grpName : string.Format("{0}/{1}", grpName, fxCtrl.prefab.name);
                    var fx = self.ShowFx(fxCtrl, fxFullName, false);
                    if (fx != null && list != null) list.Add(fx);
                } else {
                    break;
                }
            }
#if UNITY_EDITOR
            FxTool.CheckAutoDespwan(list);
#endif
            ListPool<IFxCtrl>.Release(list);
        }

        public static void AddFx(this IUnit self, IUnit fxTarget, IFxCtrl fx, IFxHolder fxHolder, ref FxAnchor anchor)
        {
            fx.caster = self;
            fx.holder = fxTarget;

            Transform parent = anchor.anchor;
            Transform trans = fx.go.transform;
            if (parent) {
                trans.SetParent(parent);
                trans.localPosition = anchor.offset;
                trans.localScale = Vector3.one;
                trans.localRotation = Quaternion.identity;

                // 屏幕特效直接返回
                //if (parent.CompareTag(TAGS.FXCamera)) {
                //    return fx;
                //}

                if (!fx.IsFollow) {
                    trans.SetParent(FxRoot, true);
                } else {                    
                    // 挂在目标身上到特效，检测是否需要隐藏
                    var fxC = fx as FxCtrl;
                    if (fxC && fxHolder != null && !fxHolder.visible) {
                        fxC.SetVisible(false);
                    }
                }
            } else {
                var pos = ENV.Pos2World(fxTarget ?? self);
                var srcPos = new Vector3(pos.x, pos.y, pos.z);
                trans.SetParent(FxRoot);
                trans.position = srcPos + anchor.offset;
                trans.localScale = Vector3.one;
                trans.localRotation = Quaternion.identity;
            }

            if (anchor.forward) {
                if (fxTarget == null || fxTarget.coord == self.coord) {
                    // 特效朝向自己的前方
                    trans.forward = ENV.Fwd2World(self);
                } else if (fxTarget != self) {
                    // 特效朝向自己
                    var pos = ENV.Pos2World(self);
                    var lookV3 = new Vector3(pos.x, trans.position.y, pos.z);
                    trans.LookAt(lookV3);
                } else {
                    //var unit = self as Unit;
                    //if (unit != null && unit.currTarget != null && unit.currTarget.grid != self.grid) {
                    //    // 特效朝向目标
                    //    var pos = BattleMgr.Grid2World(unit.currTarget.grid);
                    //    var lookV3 = new Vector3(pos.x, trans.position.y, pos.z);
                    //    trans.LookAt(lookV3);
                    //} else {
                    //    // 特效朝向自己的前方
                    //    var obj = self as IObject;
                    //    if (obj != null && obj.view != null) {
                    //        trans.forward = (obj.view as MonoBehaviour).transform.forward;
                    //    }
                    //}
                }
            }

            fx.OnInitDone();
        }

        /// <summary>
        /// 播放指定的特效
        /// </summary>
        public static IFxCtrl AddFx(this IUnit self, IUnit fxTarget, IFxCtrl fxMain, string fxFullName, ref FxAnchor anchor)
        {
            var prefab = fxMain.prefab;

            var fxHolder = fxTarget != null ? fxTarget.view as IFxHolder : null;
            var inAnchor = anchor;
            if (inAnchor.IsNull()) {
                inAnchor = GetFxAnchor(fxHolder, prefab);
                if (inAnchor.anchor == null && fxMain.IsFollow) {
                    // 忽略找不到挂载点的跟随型特效
                    return null;
                }
            }

            var fx = fxMain.Instantiate(null, fxFullName);
            self.AddFx(fxTarget, fx, fxHolder, ref inAnchor);
            return fx;
        }

        private static void AddFx(this IUnit self, IUnit fxTarget, IFxCfg fxCfg, string fxName, ref FxAnchor anchor, List<IFxCtrl> list = null)
        {
            for (int i = 0; ; ++i) {
                var fxCtrl = fxCfg.Get(i, fxTarget);
                if (fxCtrl != null && (fxCtrl.multiple || !FxInst.HasFx(fxTarget, fxCtrl))) {
                    var fxFullName = fxCtrl == fxCfg ? fxName : string.Format("{0}/{1}", fxName, fxCtrl.prefab.name);
                    var fx = self.AddFx(fxTarget, fxCtrl, fxFullName, ref anchor);
                    if (fx != null) {
                        fx.fxName = fxName;
                        if (list != null) list.Add(fx);
                    }
                } else {
                    break;
                }
            }
        }

        private static void MakeFx(this IUnit self, IUnit fxTarget, string fxName, GameObject prefab, ref FxAnchor anchor, List<IFxCtrl> list = null)
        {
            if (!prefab) return;

            var fxCfg = prefab.GetComponent(typeof(IFxCfg)) as IFxCfg;

            self.AddFx(fxTarget, fxCfg, fxName, ref anchor, list);
        }
        
        public static void PlayFx(this IUnit self, IUnit fxTarget, string fxName, GameObject prefab, ref FxAnchor anchor, List<IFxCtrl> list = null)
        {
            if (!prefab) return;

            LogMgr.I("FX#{0}: {1}->{2}", fxName, self, fxTarget);

            if (list == null) {
#if UNITY_EDITOR
                list = GetPool();
                self.MakeFx(fxTarget, fxName, prefab, ref anchor, list);
                FxTool.CheckAutoDespwan(list);
                ListPool<IFxCtrl>.Release(list);
#else
                self.MakeFx(fxTarget, fxName, prefab, ref anchor);
#endif
            } else {
                self.MakeFx(fxTarget, fxName, prefab, ref anchor, list);
            }
        }

        public static void PlayFx(this IUnit self, IUnit fxTarget, string fxName, ref FxAnchor anchor, List<IFxCtrl> list = null)
        {
            if (!IsFxTargetVisible(fxTarget)) return;
            self.PlayFx(fxTarget, fxName, Get(fxName), ref anchor, list);
        }

        public static void PlayFx(this IUnit self, IUnit fxTarget, string fxName, List<IFxCtrl> list = null)
        {
            if (!IsFxTargetVisible(fxTarget)) return;
            self.PlayFx(fxTarget, fxName, Get(fxName), ref FxAnchor.Null, list);
        }
        
        public static string ClampSfxName(MonoBehaviour uObj, string sfxName)
        {
            var index3P = sfxName.Length - 3;
            if (sfxName.Substring(index3P) == "_3P") {
                if (uObj.CompareTag("Player")) {
                    sfxName = sfxName.Substring(0, index3P);
                }
            }
            return sfxName;
        }

        public static IFxCtrl PlaySfx(this IUnit self, IUnit hitTarget, string sfxName, FXPoint point)
        {
            if (string.IsNullOrEmpty(sfxName)) return null;

            var view = hitTarget.view as MonoBehaviour;
            if (view == null) return null;

            var acting = false;
            var actor = hitTarget as IActor;
            if (actor != null) acting = actor.Content.prefab != null;

            sfxName = ClampSfxName(view, sfxName);
            var emitter = FMODMgr.Find(sfxName, FxRoot);
            
            if (emitter == null ) {
                var viewTrans = FxBoneType.GetBone(view as IFxHolder, point);
                if (viewTrans == null) viewTrans = view.transform;

                emitter = FMODMgr.NewEmitter(FMODMgr.EVENT, sfxName, viewTrans);
                var hasParam = emitter.SetParam("autoFire", acting ? 1 : 0f);
                if (hasParam && acting) {
                    emitter.gameObject.Attach(FxRoot);
                } else {
                    emitter.gameObject.Attach(null);
                }
                emitter.Play();
            } else {
                if (acting) {
                    emitter.SetParam("autoFire", 1f);
                } else {
                    emitter.SetParam("autoFire", 0f);
                    emitter.gameObject.Attach(null);
                }
            }

            //if (emitter != null) {
            //    float autoFire;
            //    emitter.GetParam("autoFire", out autoFire);
            //    LogMgr.D("Play {0} = {1}:auto={2}", sfxName, emitter, autoFire);
            //}
            emitter.SetGender(self);
            emitter.SetParam("inDoor", FMODMgr.Instance.InDoor ? 1 : 0);

            emitter.caster = self;
            emitter.holder = hitTarget;

            return emitter;
        }

        [Conditional("UNITY_EDITOR"), Conditional("UNITY_STANDALONE")]
        public static void CheckAutoDespwan(List<IFxCtrl> list)
        {
            for (int i = 0; i < list.Count; ++i) {
                if (Math.IsEqual(list[i].autoDespwan, 0)) {
                    LogMgr.E("不会被回收的特效：{0}。\n可能是特效类型设置不正确，或者需要把AutoDespwan大于0", list[i]);
                }
            }
        }

        public static void PlayFxOnTarget(this IUnit self, IUnit target, Timer tm,
            string fxName, string sfxName = null, FXPoint point = FXPoint.Foot)
        {
            // View不可见，忽略播放
            if (!IsFxTargetVisible(target)) return;

            var prefab = Get(fxName, false);
            if (prefab || string.IsNullOrEmpty(fxName)) {
                var list = GetPool();
                var sfx = self.PlaySfx(self, sfxName, point);
                if (sfx != null) {
                    list.Add(sfx);
                }
                self.PlayFx(target, fxName, prefab, ref FxAnchor.Null, list);
                if (tm != null && list.Count > 0) {
                    var fxList = tm.recycleObj as FxList;
                    if (fxList != null) {
                        fxList.SetList(list);
                        ReleasePool(list);
                    } else {
                        tm.SetRecycle(DisposeFxList, new FxList(list, self));
                    }
                } else {
                    CheckAutoDespwan(list);
                    ReleasePool(list);
                }
            } else {
                FxManager.Instance.Schedule(self, target, tm, fxName, sfxName, point);
            }
        }

        public static string GetActionFx(this ICastData self, string fx)
        {
            if (!string.IsNullOrEmpty(fx) && fx[fx.Length - 1] == '/') {
                return fx + self.motion;
            }

            return fx;
        }

        /// <summary>
        /// 技能开始施放时特效
        /// </summary>
        public static void PlayFxOnStartCast(this IUnit self, IUnit hitTarget, ICastData Fx)
        {
            if (Fx == null) return;

            var unique = Timer.GenCasting(Fx.id, self.id);
            var tm = self.L.tmMgr.Find(unique);

            self.PlayFxOnTarget(self, tm, Fx.GetActionFx(Fx.startFx.fx), Fx.startFx.sfx);

            if (!string.IsNullOrEmpty(Fx.startFx.fxT)) {
                self.PlayFxOnTarget(hitTarget, tm, Fx.startFx.fxT);
            }
        }

        /// <summary>
        /// 技能施放成功后特效
        /// </summary>
        public static void PlayFxOnCastSuccess(this IUnit self, IUnit hitTarget, ICastData Fx)
        {
            if (Fx == null) return;

            var successFx = Fx.successFx;
            // 施法后特效 - 自身
            if (!string.IsNullOrEmpty(successFx.fx) || !string.IsNullOrEmpty(successFx.sfx)) {
                self.PlayFxOnTarget(self, null, Fx.GetActionFx(Fx.successFx.fx), successFx.sfx, FXPoint.Weapon);
            }

            // 施法后特效 - 目标
            if (!string.IsNullOrEmpty(successFx.fxT) && hitTarget != null) {
                self.PlayFxOnTarget(hitTarget, null, successFx.fxT);
            }

            //var Skill = Action as CFG_Skill;
            //if (Skill != null && Skill.hold != 0) {
            //    var holdFx = Skill.holdFx;
            //    var unique = Timer.GenHolding(Skill.id, self.id);
            //    var tm = self.L.tmMgr.Find(unique);
            //    // 引导类特效 - 自身
            //    if (!string.IsNullOrEmpty(holdFx.fx) || !string.IsNullOrEmpty(holdFx.sfx)) {
            //        self.PlayFxOnTarget(self, tm, Skill.GetActionFx(Skill.holdFx.fx), holdFx.sfx, FXPoint.Weapon);
            //    }

            //    // 引导类特效 - 目标
            //    if (!string.IsNullOrEmpty(holdFx.fxT) && hitTarget != null) {
            //        self.PlayFxOnTarget(hitTarget, tm, Skill.GetActionFx(Skill.holdFx.fxT));
            //    }
            //}
        }

        /// <summary>
        /// 子技能命中时特效
        /// </summary>
        public static void PlayFxOnHitTarget(this IUnit self, IUnit hitTarget, IHitData Hit)
        {
            self.PlayFxOnTarget(hitTarget, null, Hit.fxH, Hit.sfxH, FXPoint.Body);
        }

        /// <summary>
        /// 效果命中时特效
        /// </summary>
        public static void PlayFxOnEffecting(IUnit self, IUnit hitTarget, CFG_Effect Eff)
        {
            var unique = Eff.GetTimerUnique(self, hitTarget);
            Timer tm = string.IsNullOrEmpty(unique) ? null : self.L.tmMgr.Find(unique);
            self.PlayFxOnTarget(hitTarget, tm, Eff.fxH);
        }

        //public static void HudValue(this IHudView view, ValueInf param, int camp)
        //{
        //    var changeHp = param.iVal;
        //    if (param.absorb > 0) {
        //        view.HudHitResult(HitResult.Absorb);
        //    }

        //    if (param.crit) {
        //        if (changeHp < 0) {
        //            view.hud.NumberCrit(param.iVal, "damage" + camp + param.tag);
        //        } else if (changeHp > 0) {
        //            view.hud.NumberCrit(param.iVal, "heal");
        //        }
        //    } else {
        //        if (changeHp < 0) {
        //            view.hud.NumberNorm(param.iVal, "damage" + camp + param.tag);
        //        } else if (changeHp > 0) {
        //            view.hud.NumberNorm(param.iVal, "heal");
        //        }
        //    }
        //}

        //public static void HudHitResult(this IHudView self, HitResult hit)
        //{
        //    self.hud.TextNorm(CVar.GetHitText(hit), hit.ToString());
        //}

        //public static void HudHitResult(this IUnitTarget self, IUnitTarget target, HitResult hit)
        //{
        //    if (hit < HitResult.SEP) {
        //        var view = self.view as IHudView;
        //        if (view != null) {
        //            view.HudHitResult(hit);
        //        }
        //    } else {
        //        var view = target.view as IHudView;
        //        if (view != null) {
        //            view.HudHitResult(hit);
        //        }
        //    }
        //}

        //public static void HudText(this IHudView view, string text, string style)
        //{
        //    view.hud.TextNorm(text, style);
        //}
    }
}
