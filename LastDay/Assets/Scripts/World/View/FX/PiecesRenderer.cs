using System.Collections;
using System.Collections.Generic;
using FX;
using UnityEngine;
using World.Control;

namespace World.View
{
    /// <summary>
    /// 碎裂动画特效管理：修改自身所有碎片的材质与对象的材质一致
    /// </summary>
    [RequireComponent(typeof(IFxCtrl))]
    public class PiecesRenderer : MonoBehaviour, IFxEvent
    {
        [SerializeField] private GameObject m_Root;

        [SerializeField] private float m_Fadeout = 0;

        void IFxEvent.OnFxInit()
        {
            if (m_Root == null) return;

            var fx = (IFxCtrl)GetComponent(typeof(IFxCtrl));
            if (fx.holder != null) {
                var view = fx.holder.view as IUnitView;
                if (view != null) {
                    var list = ZFrame.ListPool<Component>.Get();
                    m_Root.GetComponentsInChildren(typeof(Renderer), list);
                    var masterMat = Creator.GetMatSet(view).GetDeadFading();
                    foreach (Renderer rdr in list) {
                        rdr.sharedMaterial = masterMat;
                    }
                    ZFrame.ListPool<Component>.Release(list);
                    if (m_Fadeout > 0 && fx.autoDespwan > 0) {
                        var fadeout = Mathf.Min(fx.autoDespwan, m_Fadeout);
                        var delay = fx.autoDespwan - fadeout;
                        MEC.Timing.RunCoroutine(DoingFadeout(masterMat, delay, fadeout));
                    }
                }
            }
        }

        private static IEnumerator<float> DoingFadeout(Material mat, float delay, float duration)
        {
            var color = mat.GetColor(ShaderIDs.Color);
            color.a = 1;
            mat.SetColor(ShaderIDs.Color, color);
            yield return MEC.Timing.WaitForSeconds(delay);

            for (float time = duration; time > 0; time -= Time.deltaTime) {
                color.a = time / duration;
                mat.SetColor(ShaderIDs.Color, color);
                yield return MEC.Timing.WaitForOneFrame;
            }
            color.a = 0;
            mat.SetColor(ShaderIDs.Color, color);
        }
    }
}
