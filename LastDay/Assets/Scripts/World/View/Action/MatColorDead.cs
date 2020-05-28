using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace World.View
{
    public class MatColorDead : MatPropDead<Color>
    {
        protected override void SetValue(Material mat, Color value)
        {
            mat.SetColor(m_PropName, value);
        }
    }
}
