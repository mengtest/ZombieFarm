using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace World.View
{
    /// <summary>
    /// 修改死亡后消失的等待时间
    /// </summary>
    public class DelayedDead : MonoBehaviour, IDeadAction
    {
        [SerializeField]
        private float m_Delay = 1f;

        void IDeadAction.InitAction(IEntity entity)
        {
            
        }

        void IDeadAction.ShowAction(IEntity entity, ref DisplayValue Val)
        {
            var view = entity.view as EntityView;
            if (view != null) {
                view.recycleDelay += m_Delay;
            }
        }
    }

}
