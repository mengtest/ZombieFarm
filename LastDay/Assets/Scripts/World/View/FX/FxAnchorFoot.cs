//
//  FxAnchorFoot.cs
//  survive
//
//  Created by xingweizhen on 11/7/2017.
//
//

using System.Collections;
using System.Collections.Generic;
using FX;
using UnityEngine;

namespace World.View
{
    /// <summary>
    /// 特殊的特效挂载点：挂载在角色的脚掌上，用于脚步特效
    /// </summary>
    public class FxAnchorFoot : MonoBehaviour, IFxAnchor
    {
        public FxAnchor GetAnchor(IFxHolder holder)
        {
            var view = holder as EntityView;
            if(view && view.control) {
                var roleCtrl = view.control as RoleAnim;
                if (roleCtrl) {
                    var trans = roleCtrl.GetFootTrans();
                    var objPos = view.control.transform.position;
                    var offset = trans.position - objPos;
                    offset.y = 0;
                    return new FxAnchor() {
                        offset = offset,
                    };
                }
            }

            return new FxAnchor();
        }
    }
}
