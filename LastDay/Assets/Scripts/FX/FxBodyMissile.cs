using UnityEngine;
using System.Collections;
using Battle;

namespace FX
{
    public class FxBodyMissile : MonoBehavior
    {
        public float length = 0.5f;
        public float freq = 0.05f;
        public Shader shadowShader;
        public Color startColor = Color.white;
        public Color endColor = new Color(1, 1, 1, 0);

        GameObject body = null;
        FxTrailShadow trail;

        IEnumerator Begin(bool delay)
        {
            if (delay) yield return 1;

            trail = null;
            if (body != null) {
                Destroy(body);
            }
            //		var ball = NGUITools.FindInParents<MissileView>(gameObject);
            //		if (ball != null && ball.Who != null) {
            //			body = NGUITools.AddChild(gameObject, ball.Who.cachedAnimation.gameObject);
            //			body.SetActive(true);
            //            body.animation.Play("run");
            //			Renderer rdr = body.transform.Find(ball.Who.skin.name).GetComponent<Renderer>();
            //			rdr.material.color = startColor;
            //			trail = rdr.gameObject.AddComponent<FxTrailShadow>();
            //			trail.length = length;
            //			trail.freq = freq;
            //			trail.shadowStartColor = startColor;
            //			trail.shadowEndColor = endColor;
            //			if (shadowShader != null) {
            //				rdr.material.shader = shadowShader;
            //				trail.shadowShader = shadowShader;
            //			}
            //			trail.MakeShadow();
            //		}
        }

        void OnEnable()
        {
            if (trail == null) {
                StartCoroutine(Begin(true));
            }
        }
        void Start()
        {
            if (trail == null) {
                StartCoroutine(Begin(false));
            }
        }
        void Clean()
        {
            if (trail != null) {
                trail.Finished();
                trail = null;
            }
        }
        void OnDisable()
        {
            Clean();
        }
        void OnDestroy()
        {
            Clean();
        }
    }
}
