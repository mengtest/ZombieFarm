using UnityEngine;
using System.Collections;

namespace FX
{
    /// <summary>
    /// 提供一个真正的特效控制器
    /// </summary>    
    public abstract class FxObj : MonoBehavior
    {
        public abstract IFxCtrl fxCtrl { get; }

        public override string ToString()
        {
            return string.Format("[FX:{0}]", this.name);
        }
    }
}
