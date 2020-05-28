using UnityEngine;
using System.Collections;

namespace FX
{
    public class FxCurveColor : FxTiming
    {

        public string propertyName = "_Color";
        public Color fromColor, toColor;
        public AnimationCurve ColorCurve;
        public float delay;

        // Use this for initialization
        private void Start()
        {
            Reset();
        }

        // Update is called once per frame
        private void Update()
        {
            float delta = deltaTime;
            if (delta > 0) {
                if (GetComponent<Renderer>() != null && time >= 0) {
                    Color color = Color.Lerp(fromColor, toColor, ColorCurve.Evaluate(time));
                    foreach (Material mat in GetComponent<Renderer>().materials) {
                        mat.SetColor(propertyName, color);
                    }
                }
                time += delta;
            }
        }

        public override void Reset()
        {
            time = -delay;
            foreach (Material mat in GetComponent<Renderer>().materials) {
                mat.SetColor(propertyName, fromColor);
            }
        }
    }
}
