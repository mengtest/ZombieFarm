using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using ZFrame.Tween;

namespace FX
{
    [RequireComponent(typeof(IFxCtrl))]
    public class FxMove2Target : MonoBehaviour, IFxEvent
    {
        [SerializeField]
        protected FXPoint m_ToPoint;

        [SerializeField]
        protected float m_Duration;

        void IFxEvent.OnFxInit()
        {
            StartCoroutine(Moving());
        }
                
        private IEnumerator Moving()
        {
            yield return null;

            var ctrl = GetComponent(typeof(IFxCtrl)) as IFxCtrl;
            if (ctrl.caster != null) {
                var fromPos = transform.position;
                var target = FxBoneType.GetBone(ctrl.caster.view as IFxHolder, m_ToPoint);
                if (target != null) {
                    fromPos = target.position;
                } else {
                    fromPos = FxTool.ENV.Pos2World(ctrl.caster);
                }
                transform.TweenPosition(fromPos, transform.position, m_Duration);
            }
        }
    }
}
