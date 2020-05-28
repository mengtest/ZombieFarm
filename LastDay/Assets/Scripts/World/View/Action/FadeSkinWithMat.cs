using System.Collections;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using UnityEngine;
using World.Control;

namespace World.View
{
    public class FadeSkinWithMat : FadeSkin
    {
        [SerializeField]
        private Material m_FadeMat;

        private Material m_RawMat;
        private MaterialSet m_MaterialSet;
        
        public override MaterialSet materialSet {
            get { return m_MaterialSet; }
        }

        private void Awake()
        {
            m_MaterialSet = StageView.Assets.GetMaterialSet(m_FadeMat);
        }
    }
}
