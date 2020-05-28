using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace World.View
{
    public class StageFOWStalker : FogOfWarStalker, IFOWStatus
    {
        public bool active { get; set; }

        protected override void SetVisible(bool visible)
        {
            var view = GetComponent(typeof(EntityView)) as EntityView;
            if (view == null && view.obj == null) return;
            var role = view ? view.obj as Role : null;
            if (ObjectExt.IsNull(role)) return;

            role.visible = visible;
            if (!role.stealth) {
                if (view.control) {
                    if (visible) {
                        UnityEngine.Profiling.Profiler.BeginSample("Stalker Enter");
                        MiniMap.Instance.Enter(role);
                        view.FadeView(0, 1, REQUEST_DURA);
                        UnityEngine.Profiling.Profiler.EndSample();
                    } else {
                        UnityEngine.Profiling.Profiler.BeginSample("Stalker Exit");
                        MiniMap.Instance.Exit(role);
                        view.FadeView(1, 0, REQUEST_DURA);
                        UnityEngine.Profiling.Profiler.EndSample();
                    }
                }

                UnityEngine.Profiling.Profiler.BeginSample("Stalker Event");
                Control.StageCtrl.SendLuaEvent("VISIBLE_CHANGED", role.id, visible ? 1 : 0);
                UnityEngine.Profiling.Profiler.EndSample();
            }
        }
    }
}
