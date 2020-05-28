using UnityEngine;
using UnityEngine.Serialization;
using System.Collections;

namespace FX
{
    public class FxPosition : FxAnimate
    {
        protected override void OnUpdate(float delta)
        {
            transform.Translate(Vector3.forward * m_Speed * delta);
        }
    }
}