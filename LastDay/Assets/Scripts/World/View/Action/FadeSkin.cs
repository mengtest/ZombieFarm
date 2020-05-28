using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using ZFrame;

namespace World.View
{
    [RequireComponent(typeof(ObjAnim))]
    public abstract class FadeSkin : MonoBehaviour, ISkinMaterial
    {           
        public abstract MaterialSet materialSet { get; }
    }
}
