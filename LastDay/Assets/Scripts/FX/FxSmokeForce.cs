#if false
using UnityEngine;
using System.Collections;
using PigeonCoopToolkit.Effects.Trails;

public class FxSmokeForce : MonoBehavior {

    public SmokePlume[] smokes;
    Vector3[] constForces;
	// Use this for initialization
	void Start () {
        smokes = GetComponentsInChildren<SmokePlume>();
        if (smokes != null) {
            constForces = new Vector3[smokes.Length];
            for (int i = 0; i < smokes.Length; ++i) {
                constForces[i] = smokes[i].ConstantForce;
            }
        }
	}
	
	// Update is called once per frame
	void Update () {
#if UNITY_EDITOR
        if (Time.frameCount % 10 == 0) {
#else
        if (Time.frameCount % 5 == 0) {
#endif
            if (smokes != null) {
                for (int i = 0; i < smokes.Length; ++i) {
                    var force = cachedTransform.rotation * constForces[i];
                    smokes[i].ConstantForce = force;
                }
            }
        }
	}

    void OnDisable()
    {
        if (smokes != null) {
            for (int i = 0; i < smokes.Length; ++i) {
                smokes[i].ClearSystem(true);
            }
        }
    }
}
#endif
