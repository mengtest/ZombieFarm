//
//  FxEmpty.cs
//  survive
//
//  Created by xingweizhen on 11/6/2017.
//
//

using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace FX
{
    public sealed class FxEmpty : FxInst, IFxCfg
    {
        [SerializeField]
        private bool m_Follow;
        [SerializeField]
        private bool m_Pooled = true;
        [SerializeField]
        private float m_AutoDespwan;

        public override bool IsFollow { get { return m_Follow; } }
        public override bool IsPooled { get { return m_Pooled; } }
        public override float autoDespwan { get { return m_AutoDespwan; } }
        
    }
}
