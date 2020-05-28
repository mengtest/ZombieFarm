using UnityEngine;
using System.Collections;

namespace FX
{
    public class FxMissileCtrl : FxCtrl
    {
        public FXPoint toPoint = FXPoint.Foot;
        public AnimationCurve missileCurve;
        public bool turnToTarget = false;
        public bool randomDirection = false;
        public Vector3 direction = Vector3.up;

        protected override void Start()
        {
            base.Start();
            if (randomDirection) {
                float magnitude = direction.magnitude;
                direction = Random.onUnitSphere * magnitude;
            }
            direction.z = 0;
        }
    }
}
