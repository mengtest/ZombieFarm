using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Serialization;

namespace FX
{
    public abstract class FxAnimate : FxTiming
    {
        [SerializeField]
        [FormerlySerializedAs("speed")]
        protected float m_Speed = 1f;

        protected abstract void OnUpdate(float delta);

        private void Update()
        {
            var delta = deltaTime;
            if (delta > 0) {
                time += delta * m_Speed;
                OnUpdate(delta);
            }
        }

        protected virtual void OnDisable()
        {
            time = 0;
        }
    }
}