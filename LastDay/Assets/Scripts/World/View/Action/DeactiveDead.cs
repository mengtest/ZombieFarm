//
//  DeactiveDead.cs
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
    public class DeactiveDead : MonoBehaviour, IDeadAction, IPoolable
    {
        [SerializeField]
        private GameObject[] m_DeactiveObjs;

        public void InitAction(IEntity entity)
        {
            foreach (var go in m_DeactiveObjs) if (go) go.SetActive(entity.IsAlive());
        }

        public void ShowAction(IEntity entity, ref DisplayValue Val)
        {
            foreach (var go in m_DeactiveObjs) if (go) go.SetActive(false);
        }
        
        void IPoolable.OnRecycle()
        {
            foreach (var go in m_DeactiveObjs) if (go) go.SetActive(true);
        }

        void IPoolable.OnRestart()
        {
            
        }
    }
}

