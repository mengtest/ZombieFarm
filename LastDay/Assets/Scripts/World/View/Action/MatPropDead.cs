using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace World.View
{
    public abstract class MatPropDead<T> : MonoBehaviour, IDeadAction
    {
        [SerializeField]
        protected string m_PropName;

        [SerializeField]
        protected T m_Value;

        protected abstract void SetValue(Material mat, T value);

        void IDeadAction.InitAction(IEntity entity)
        {

        }

        void IDeadAction.ShowAction(IEntity entity, ref DisplayValue Val)
        {
            var view = GetComponentInParent(typeof(IRenderView)) as IRenderView;
            if (view != null && view.skin) {
                foreach (var mat in view.skin.materials) {
                    SetValue(mat, m_Value);
                }
            }
        }
    }
}
