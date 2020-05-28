using UnityEngine;
using System.Collections;

public class FxShakeCamera : MonoBehavior
{
	public float shakeDelay;
	public float shakeOffset;
	public float shakeDuration;
    float time;
    float deltaTime { get { return Time.deltaTime; } }
    float m_shakeOffset;
    bool shaking = false;
    static Transform target;
    static Vector3 tarOriginPosition;

    void OnEnable()
    {
        time = 0;
        shaking = false;
        var mainCam = Camera.main;
        if (mainCam) {
            target = mainCam.transform;
            tarOriginPosition = target.localPosition;
        }
    }

    void OnDisable()
    {
        if (shaking) {
            shaking = false;
            if (target) target.localPosition = tarOriginPosition;
        }
    }

    void Start()
    {
        m_shakeOffset = shakeOffset / 3;
    }

    void Update()
    {
        float curr = time;
        time += deltaTime;
        // shakeDelay可以等于0
        if (curr <= shakeDelay && time > shakeDelay) {
            shaking = true;
        }

        float shakeFinish = shakeDelay + shakeDuration;
        if (curr <= shakeFinish && time > shakeFinish) {
            shaking = false;
            if (target) target.localPosition = tarOriginPosition;
        }

        if (deltaTime > 0) {
            if (shaking && target) {
                target.localPosition = tarOriginPosition + Random.onUnitSphere * m_shakeOffset;
            }
        }
    }

    //void Shake()
    //{
    //    shaking = true;
    //    iTween.ShakePosition(Camera.main.gameObject, iTween.Hash(
    //                "amount", new Vector3(shakeOffset, shakeOffset, 0)
    //                , "time", shakeDuration
    //                //, "oncomplete", "OnShakeComplete"
    //                , "ignoretimescale", false                    
    //                ));
    //}
}
