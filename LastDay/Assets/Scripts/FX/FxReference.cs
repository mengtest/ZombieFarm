using UnityEngine;
using System.Collections;
using ZFrame.Asset;

namespace FX
{
    /// <summary>
    /// 特效引用配置，动态加载避免打包重复
    /// </summary>
    public class FxReference : FxObj
    {
        public string refenrence;
        public override IFxCtrl fxCtrl {
            get {
                GameObject prefab = null;
#if UNITY_EDITOR
                if (AssetsMgr.Instance == null) {
                    var path = "FX/" + refenrence + ".prefab";
                    prefab = UnityEditor.AssetDatabase.LoadAssetAtPath(path, typeof(GameObject)) as GameObject;
                    return prefab ? prefab.GetComponent(typeof(IFxCtrl)) as IFxCtrl : null; ;
                }
#endif
                prefab = FxTool.Get("FX/" + refenrence);
                return prefab ? prefab.GetComponent(typeof(IFxCtrl)) as IFxCtrl : null;
            }
        }
    }
}

