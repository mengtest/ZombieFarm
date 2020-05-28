using UnityEngine;
using System.Collections;

namespace FX
{
    public class FxTimerLoop : FxTiming
    {

        public GameObject target;

        public float born;
        public float dead;

        public float delay = 0;
        public bool loop = false;

        void OnEnable()
        {
            Reset();
        }

        // Use this for initialization
        void Start()
        {
            born += delay;
            dead += delay;
        }

        void Update()
        {
            if (target == null)
                return;

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

            if (loop && time >= dead && time > born) {
                Reset();
            }
        }

        void OnFxBorn()
        {
            target.SetActive(true);
        }

        void OnFxDead()
        {
            target.SetActive(false);
        }

        public override void Reset()
        {
            time = 0f;
            if (target && born > 0) {
                target.SetActive(false);
            }
        }

    }
}
