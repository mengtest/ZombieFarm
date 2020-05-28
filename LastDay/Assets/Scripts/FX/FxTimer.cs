using UnityEngine;
using System.Collections;

namespace FX
{
    public class FxTimer : FxTiming
    {

        public GameObject target;
        public float born;
        public float dead;
        public bool selfReset = false;
        void OnEnable()
        {
            if (selfReset) Reset();
        }

        void Update()
        {
            if (time == 0) {
                Reset();
            }
            float curr = time;
            time += deltaTime;
            // born可以等于零
            if (curr <= born && time > born) {
                OnFxBorn();
            }
            // dead必须大于零
            if (curr < dead && time >= dead) {
                OnFxDead();
            }
        }

        void OnFxBorn()
        {
            if (target != null) target.SetActive(true);
        }

        void OnFxDead()
        {
            if (target != null) target.SetActive(false);
        }

        public override void Reset()
        {
            time = 0;
            if (target && born > 0) {
                target.SetActive(false);
            }
        }

    }
}
