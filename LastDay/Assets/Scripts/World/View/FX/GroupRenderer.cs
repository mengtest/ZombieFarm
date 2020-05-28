using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace World.View
{
    /// <summary>
    /// 把多个网格的渲染材质统一为一个。属于初始化功能
    /// </summary>
    public class GroupRenderer : MonoBehaviour, IInitRender
    {
        public void InitRender()
        {
            var list = ZFrame.ListPool<Component>.Get();
            gameObject.GetComponentsInChildren(typeof(Renderer), list);
            if (list.Count > 1) {
                var mats = (list[0] as Renderer).sharedMaterials;
                for (int i = 1; i < list.Count; ++i) {
                    (list[i] as Renderer).sharedMaterials = mats;
                }
            }
            ZFrame.ListPool<Component>.Release(list);
        }

        private void Start()
        {
            if (transform.parent == null) {
                InitRender();
            }
        }
    }
}
