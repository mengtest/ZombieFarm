using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using ZFrame.UGUI;

namespace World.View
{
    public class UnitPlateHud : AutoPooled, IPoolable
    {
        void IPoolable.OnRestart()
        {
            this.enabled = true;
            ((RectTransform)transform).anchoredPosition3D = Vector3.zero;
            Start();
        }

        void IPoolable.OnRecycle()
        {
            ((RectTransform)transform).anchoredPosition3D = Vector3.back * 9999;
            gameObject.SetEnable(typeof(UIFollowTarget), false);
            this.enabled = false;
        }
    }
}
