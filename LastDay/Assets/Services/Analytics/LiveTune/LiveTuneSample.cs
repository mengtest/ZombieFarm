using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Unity.LiveTune;

[System.Serializable]
class MySettings
{
    public float particlesRate;

    public MySettings()
    {
        this.particlesRate = 100.0f;
    }
}

public class LiveTuneSample : MonoBehaviour
{
    public GameObject testParticleSystem;

    // Use this for initialization
    void Start()
    {
        var defaults = new MySettings();
        LiveTune.Init("1",  // build id
                      true, // use persistent path
                      defaults, // defaults in case of network error the first time
                      GotSettings, //callback
                      LiveTune.Endpoint.Sandbox); // what endpoint to use
    }

    void GotSettings(string settingsJson, bool isBaseline, string segmentName)
    {
        // do nothing if this is a baseline device
        if (isBaseline) return;

        Debug.LogFormat("got new settings: {0}", segmentName);
        // deserialize settings
        var settings = JsonUtility.FromJson<MySettings>(settingsJson);

        var ps = testParticleSystem.GetComponent<ParticleSystem>();
#if UNITY_5_5_OR_NEWER
        var em = ps.emission;
        em.rateOverTime = settings.particlesRate;
#endif
    }
}
