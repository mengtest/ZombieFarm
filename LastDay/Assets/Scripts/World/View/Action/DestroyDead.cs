//
//  DestroyDead.cs
//  survive
//
//  Created by xingweizhen on 11/7/2017.
//
//

using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace World.View
{
    public class DestroyDead : MonoBehaviour, IDeadAction
    {
        public void InitAction(IEntity entity)
        {
        }

        public void ShowAction(IEntity entity, ref DisplayValue Val)
        {
            GoTools.DestroyScenely(gameObject);

            var view = entity.view as MonoBehaviour;
            if (view) {
                GoTools.DestroyScenely(view.gameObject);
            }
        }
    }
}
