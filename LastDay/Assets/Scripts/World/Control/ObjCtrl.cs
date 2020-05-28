//
//  ObjCtrl.cs
//  survive
//
//  Created by xingweizhen on 10/13/2017.
//
//

using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;
using MEC;

namespace World.Control
{
    using View;

    public static class ObjCtrl
    {
        public static void StopAutoPlay()
        {
            if (StageCtrl.P != null) {
                var view = StageCtrl.P.view as PlayerView;
                if (view) view.SetAuto(false, PlayerView.AutoRet.Cancel);
            }
        }

        public static void Move(this IMovable self, Vector3 direction, bool towards)
        {
            var Actor = self as CActor;
            if (Actor != null && !Actor.actionable) return;

            if (self == StageCtrl.P) {
                StopAutoPlay();
            }

            if (towards) {
                var magnitude = direction.magnitude;

                var euler = StageView.Instance.mainCam.transform.eulerAngles;
                var rot = Quaternion.Euler(0, euler.y, 0);
                direction = rot * direction;
                var forward = StageView.FwdWorld2Local(direction.normalized);

                // 降低速度精度
                var ratePrecision = CVar.MOVE_SPEED_DIFF;
                var rate = Mathf.Round(magnitude / ratePrecision) * ratePrecision;

                // 降低方向精度
                //var anglePrecision = 360f / 32;
                //var angle = Vector3.SignedAngle(direction, Vector3.forward, Vector3.up);
                //var clampAngle = Mathf.Round(angle / anglePrecision) * anglePrecision;
                //direction = Quaternion.Euler(0, -clampAngle, 0) * Vector3.forward;

                self.DoMove(forward, rate, true);
            } else {
                self.DoMove(direction, 1f, false);
            }
        }

        public static void Stay(this IMovable self, bool forced)
        {
            if (self == StageCtrl.P) {
                if (forced) {
                    StopAutoPlay();
                } else {
                    var view = StageCtrl.P.view as PlayerView;
                    if (view && view.autoMode) return;
                }
            }

            if (!ObjectExt.IsNull(self) && self.IsAlive()) {
                if (!self.autoMove) {
                    // 从控制移动中停步时会稍微倒退
                    var mono = self.view as MonoBehaviour;
                    if (mono) {
                        self.WarpAt(StageView.World2Local(mono.transform.position));
                    }
                }

                self.OnFSMEvent(EVENT.LEAVE_MOVE);
            }
        }

        public static void Stop(this IActor self, bool stopAuto)
        {
            if (stopAuto && self == StageCtrl.P) {
                StopAutoPlay();
            }

            self.Content.Uninit();
            self.OnEvent((int)EVENT.LEAVE_MOVE);
            if (self.Content.idle) {
                self.Content.Finish();
            }
        }
        
        public static void Interact(this IActor self, CFG_Weapon Tool, int actionId, IObj target, 
            ACTOper oper = ACTOper.Auto, int interactTime = 0)
        {
            var action = CFG_Action.Load(actionId);
            if (action == null) {
                LogMgr.W("Interact action is NULL!");
            } else {
                if (action.type == ACTType.OPEN) {
                    ((CFG_Opening)action).SetCastTime(interactTime);
                }
                oper = oper == ACTOper.Auto ? action.oper : oper;
                self.DoAction(Tool, action, target, oper);
            }
        }

        public static void Attack(this IActor self, IAction Action, IObj target, ACTOper oper = ACTOper.Loop)
        {
            var human = self as Human;

            if (Action != null && self.Content.idle) {
                var hView = self.view as HumanView;
                if (hView) {
                    if (!self.HasAction(Action.id)) {
                        hView.DetachAffix(HumanView.AFFIX_RHAND);
                        hView.DetachAffix(HumanView.AFFIX_LHAND);
                        hView.SetPose(0);
                    } else {
                        hView.SetPose((int)human.Major.attrs[ATTR.pose]);
                    }
                }
            }
            self.DoAction(human != null ? human.Major : null, Action, target, oper);
        }

        public static void DetatchFx(this IObj self)
        {
            var list = FX.FxInst.FindFxesOn(self);
            foreach (var fx in list) {
                if (fx.IsFollow) {
                    if (fx.IsFading) {
                        var mono = fx as MonoBehaviour;
                        mono.transform.SetParent(FX.FxTool.FxRoot, true);
                    } else {
                        fx.Stop(true);
                    }
                }
            }
            FX.FxTool.ReleasePool(list);
        }

        private static IEnumerator<float> FadeSkin(EntityView self, float duration, GameObject root)
        {
            var skins = ZFrame.ListPool<Component>.Get();
            self.GetSkins(skins);

            var delay = self.recycleDelay;
            delay -= duration;
            if (delay > 0) {
                yield return Timing.WaitForSeconds(delay);
            }

            var ent = self.obj as IEntity;
            if (ent != null && ent.operId == CVar.PICK_ID) {
                // 此处特殊处理，操作类型为拾取时，不会有死亡消失，从地图中移除即认为是死亡
                self.OnObjDead();
            } else {
                var matSet = Creator.GetMatSet(self, root);
                if (matSet != null) {
                    var roleMat = matSet.GetDeadFading();
                    yield return Timing.WaitUntilDone(ObjViewExt.FadingView(skins, 1, 0, duration, roleMat));
                }
            }

            if (self) self.FinishDestroy(root);
            ZFrame.ListPool<Component>.Release(skins);
        }
        
        private static void FinishDestroy(this EntityView self, GameObject root)
        {
            if (self.obj == null || !self.obj.IsAlive() || self.obj.IsNull()) {
                self.UnloadHud();
            }

            if (root) {
                if (self.obj != null) self.obj.DetatchFx();
                GoTools.DestroyScenely(root);
            } else {
                GoTools.DestroyScenely(self.gameObject);
            }
        }

        public const float FADING_DURA = 1f;
        public static void DestroyView(this EntityView self, float duration, GameObject root = null)
        {
            if (self && self.skin) {
                if (root) {
                    root.transform.SetParent(self.transform.parent, true);
                }

                if (duration > 0) {
                    Timing.RunCoroutine(FadeSkin(self, duration, root));
                } else {
                    self.FinishDestroy(root);
                }
            }
        }

        public static void InitDeadActions(this EntityView self)
        {
            if (self.root) {
                var list = ZFrame.ListPool<Component>.Get();
                self.root.GetComponents(typeof(IDeadAction), list);
                foreach (IDeadAction act in list) act.InitAction(self.entity);
                ZFrame.ListPool<Component>.Release(list);
            }
        }

        public static void ShowHurtActions(this EntityView self, ref VarChange Inf)
        {
            if (self.root) {
                var living = self.obj as ILiving;
                if (living != null) {
                    var list = ZFrame.ListPool<Component>.Get();
                    self.root.GetComponents(typeof(IHurtAction), list);
                    foreach (IHurtAction act in list) act.ShowAction(living, ref Inf);
                    ZFrame.ListPool<Component>.Release(list);
                }
            }
        }

        public static void ShowDeadActions(this EntityView self, ref DisplayValue Val)
        {
            if (self.root && self.entity != null) {
                var list = ZFrame.ListPool<Component>.Get();
                self.root.GetComponents(typeof(IDeadAction), list);
                foreach (IDeadAction act in list) act.ShowAction(self.entity, ref Val);
                ZFrame.ListPool<Component>.Release(list);
            }
        }

        public static void ShowDeadPose(this IObj obj, Animator anim, int fix = 0)
        {
            // 死亡pose
            if (anim) {
                var state = AnimState.DEADS[(obj.id + fix) % AnimState.DEADS.Length];
                if (anim.HasState(AnimState.BASE_LAYER, AnimState.BASE_EMPTY)) {
                    anim.Play(AnimState.BASE_EMPTY, AnimState.BASE_LAYER);
                }
                if (anim.HasState(AnimState.CONFINE_LAYER, state)) {
                    anim.Play(state, AnimState.CONFINE_LAYER);
                }
            }
        }

        public static Transform CreateFootAura(string auraName)
        {
            var go = GoTools.AddChild(StageView.Instance.gameObject, 
                string.Format("FX/Common/{0}", auraName), true);
            return go != null ? go.transform : null;
        }

        public static void InitFootAura(Transform aura, float radius, Color color)
        {
            if (aura) {
                var prj = aura.GetComponentInChildren(typeof(Projector)) as Projector;
                prj.orthographicSize = radius;
                //prj.material.color = color;
            }
        }
    }
}

