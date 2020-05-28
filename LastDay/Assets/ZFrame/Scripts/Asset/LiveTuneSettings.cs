using Unity.LiveTune;
using UnityEngine;
using World.View;
using ZFrame.Asset;

namespace ZFrame.Asset
{
    public abstract class LiveTuneSettings
    {
        public bool stroke = true;
        public int resolution = 720;
        public int texture = 0;
        public int shadowQuality = 0;
        public int animationQuality = 1;
        public int frameRate = 30;
        public int maxModelCount = 30;
        
        //public void Apply()
        //{
        //    QualitySettings.masterTextureLimit = texture;
        //    QualitySettings.shadowResolution = (ShadowResolution)shadowQuality;
        //    QualitySettings.blendWeights = (BlendWeights)animationQuality;
        //    Application.targetFrameRate = frameRate;
        //    var width = (int)((Screen.width / (float)Screen.height) * resolution);
        //    Screen.SetResolution(width, resolution, true);
        //    if (StageView.Assets != null)
        //        StageView.Assets.SetOutline(stroke);
        //}

        private bool init = false;

        void GotSettings(string settingsJson, bool isBaseline, string segmentName)
        {
            //Debug.LogFormat("got settings,settingsJson: {0} isBaseline: {1} segmentName: {2}", settingsJson, isBaseline, segmentName);
            //Instance = JsonUtility.FromJson<GameSettings>(settingsJson);
            //Instance.init = true;
            //Instance.Apply();
            init = true;
            ApplySettings(settingsJson, isBaseline, segmentName);
        }

        protected abstract string defaultSettings { get; }
        protected abstract void ApplySettings(string settingsJson, bool isBaseline, string segmentName);

        public void GetSettings()
        {
            if (!init) {
                LiveTune.Init(VersionMgr.AppVersion.version, // build id
                    true, // use persistent path
                    defaultSettings, // defaults in case of network error the first time
                    ApplySettings, //callback
#if DEVELOPMENT_BUILD
                LiveTune.Endpoint.Sandbox
#else
                LiveTune.Endpoint.Production
#endif
                ); // what endpoint to use
            }
        }
    }
}