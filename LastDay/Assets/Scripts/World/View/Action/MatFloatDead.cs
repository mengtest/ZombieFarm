using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace World.View
{
    public class MatFloatDead : MatPropDead<float>
    {
        protected override void SetValue(Material mat, float value)
        {
            mat.SetFloat(m_PropName, value);
        }
    }
}
