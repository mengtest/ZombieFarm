using UnityEngine;
using System.Collections;

namespace FX
{
    public class FxMultiTimer : FxTiming
    {

        [System.Serializable]
        public class TimeObject
        {
            public GameObject target;
            public float born;
            public float dead;
        }

        public TimeObject[] Targets;
        public bool selfReset = false;

        void OnEnable()
        {
            if (selfReset) Reset();
        }

        // Update is called once per frame
        void Update()
        {
            float curr = time;
            time += deltaTime;

            for (int i = 0; i < Targets.Length; ++i) {
                var tg = Targets[i];
                // born可以等于零
                if (curr <= tg.born && time > tg.born) {
                    OnFxBorn(tg.target);
                }
                // dead必须大于零
                if (curr < tg.dead && time >= tg.dead) {
                    OnFxDead(tg.target);
                }
            }
        }

        void OnFxBorn(GameObject target)
        {
            if (target != null) target.SetActive(true);
        }

        void OnFxDead(GameObject target)
        {
            if (target != null) target.SetActive(false);
        }

        public override void Reset()
        {
            time = 0f;
            for (int i = 0; i < Targets.Length; ++i) {
                OnFxDead(Targets[i].target);
            }
        }
    }
}
