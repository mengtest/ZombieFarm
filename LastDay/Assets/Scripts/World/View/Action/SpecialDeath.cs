using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using FX;
using ZFrame;

namespace World.View
{
    public class SpecialDeath : RagdollSwitch, ILateTick
    {
        [SerializeField, NamedProperty("头部（爆头）")]
        protected Transform m_Head;

        protected readonly List<Transform> m_HiddenBones = new List<Transform>();

        protected virtual void ShowBroken(IEntity entity, ref DisplayValue Val)
        {

        }

        protected virtual void ShowDeath(IEntity entity, ref DisplayValue Val)
        {
            Val.overrideFx = true;

            var deadType = (DeadType)Val.value;
            string fxName = null;
            switch (deadType) {
                case DeadType.HeadShot:
                    if (m_Head) m_HiddenBones.Add(m_Head);
                    fxName = "common/dead_headshot";
                    break;
                case DeadType.WaistCut:
                    // 不支持
                    break;
                case DeadType.Burning:
                    fxName = "common/dead_burn";
                    break;
                case DeadType.ElectricShock:
                    fxName = "common/dead_electrical";
                    break;
                case DeadType.Smash:
                    fxName = "common/dead_crush";
                    break;
                case DeadType.None:
                    fxName = entity.Data.GetExtend("deadFx");
                    if (!string.IsNullOrEmpty(fxName)) {
                        fxName += "_none";
                    }
                    break;
                default: break;
            }

            var caster = Val.source;
            if (caster != null && !string.IsNullOrEmpty(fxName)) {
                caster.PlayFx(entity, fxName);
            }
        }

        bool ITickBase.ignoreTimeScale { get { return true; } }

        public virtual void LateTick(float deltaTime)
        {
            for (int i = 0; i < m_HiddenBones.Count; ++i) {
                m_HiddenBones[i].localScale = Vector3.zero;
            }
        }

        public override void ShowAction(IEntity entity, ref DisplayValue Val)
        {
            Debugger.LogD("{0}死亡：类型={1}, 数值={2}", entity, Val.type, Val.value);
            if (Val.type == 1) {
                // 肢解死亡
                ShowBroken(entity, ref Val);
            } else {
                // 普通/特殊死亡
                ShowDeath(entity, ref Val);
            }

            base.ShowAction(entity, ref Val);

            if (m_HiddenBones.Count > 0) {
                TickManager.Add(this);
            }
        }

        public override void OnRecycle()
        {
            base.OnRecycle();

            TickManager.Remove(this);
            m_HiddenBones.Clear();
        }
        
        private void OnDestroy()
        {
            TickManager.Remove(this);
        }
    }
}
