//
//  Visible.cs
//  survive
//
//  Created by xingweizhen on 10/16/2017.
//
//

using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace World.View
{
    public class Visible : MonoBehaviour
    {
        private void OnBecameVisible()
        {
            var cld = GetComponentInParent(typeof(Collider)) as Collider;
            if (cld) cld.enabled = true;
        }

        private void OnBecameInvisible()
        {
            var cld = GetComponentInParent(typeof(Collider)) as Collider;
            if (cld) cld.enabled = false;
        }
    }
}
