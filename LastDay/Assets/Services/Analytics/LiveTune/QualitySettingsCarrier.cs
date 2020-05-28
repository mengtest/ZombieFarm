using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Unity.LiveTune {

    // keep this as an immutable object
    [System.Serializable]
    public class QualitySettingsCarrier
    {
        public AnisotropicFiltering qs_anisotropicFiltering;
        public int qs_antiAliasing;
        public float qs_lodBias;
        public int qs_maximumLODLevel;
        public int qs_maxQueuedFrames;
        public int qs_particleRaycastBudget;
        public bool qs_realtimeReflectionProbes;
#if UNITY_2017_1_OR_NEWER
        //https://unity3d.com/unity/whats-new/unity-2017.1.0
        //Light modes: Added QualitySettings.shadowmaskMode
        public float qs_resolutionScalingFixedDPIFactor;
        public ShadowmaskMode qs_shadowmaskMode;
#endif
        public int qs_shadowCascades;
        public float qs_shadowDistance;
        public float qs_shadowNearPlaneOffset;
        public ShadowProjection qs_shadowProjection;
#if UNITY_5_4_OR_NEWER
        //https://unity3d.com/unity/whats-new/unity-5.4.0
        //Graphics: Added Light.customShadowResolution and QualitySetting.shadowResolution to scripting API 
        //to make it possible to adjust the shadow mapping quality in code at run time on a per-light basis.
        public ShadowResolution qs_shadowResolution;
#endif
#if UNITY_5_5_OR_NEWER
        //https://unity3d.com/unity/whats-new/unity-5.5.0
        //Graphics: Added QualitySettings.shadows and QualitySettings.softParticles to the scripting API. (805056)
        public ShadowQuality qs_shadows;
        public bool qs_softParticles;
#endif
        public bool qs_softVegetation;
        public int qs_vSyncCount;
        
        public QualitySettingsCarrier()
        {
            Reset();
        }
        
        /// <summary>
        ///   Reset current settings to mimic current values of QualitySettings
        /// </summary>
        public void Reset()
        {
            qs_anisotropicFiltering = QualitySettings.anisotropicFiltering;
            qs_antiAliasing = QualitySettings.antiAliasing;
            qs_lodBias = QualitySettings.lodBias;
            qs_maximumLODLevel = QualitySettings.maximumLODLevel;
            qs_maxQueuedFrames = QualitySettings.maxQueuedFrames;
            qs_particleRaycastBudget = QualitySettings.particleRaycastBudget;
            qs_realtimeReflectionProbes = QualitySettings.realtimeReflectionProbes;
#if UNITY_2017_1_OR_NEWER
            qs_resolutionScalingFixedDPIFactor = QualitySettings.resolutionScalingFixedDPIFactor;
            qs_shadowmaskMode = QualitySettings.shadowmaskMode;
#endif
            qs_shadowCascades = QualitySettings.shadowCascades;
            qs_shadowDistance = QualitySettings.shadowDistance;
            qs_shadowNearPlaneOffset = QualitySettings.shadowNearPlaneOffset;
            qs_shadowProjection = QualitySettings.shadowProjection;
#if UNITY_5_4_OR_NEWER
            qs_shadowResolution = QualitySettings.shadowResolution;
#endif
#if UNITY_5_5_OR_NEWER
            qs_shadows = QualitySettings.shadows;
            qs_softParticles = QualitySettings.softParticles;
#endif
            qs_softVegetation = QualitySettings.softVegetation;
            qs_vSyncCount = QualitySettings.vSyncCount;
        }

        /// <summary>
        ///   Apply current QualitySettings
        /// </summary>
         public static void Apply(string qs_settingsJson)
        {    
            var carrier = new QualitySettingsCarrier();
            JsonUtility.FromJsonOverwrite(qs_settingsJson, carrier);
            
            QualitySettings.anisotropicFiltering = carrier.qs_anisotropicFiltering;
            QualitySettings.antiAliasing = carrier.qs_antiAliasing;
            QualitySettings.lodBias = carrier.qs_lodBias;
            QualitySettings.maximumLODLevel = carrier.qs_maximumLODLevel;
            QualitySettings.maxQueuedFrames = carrier.qs_maxQueuedFrames;
            QualitySettings.particleRaycastBudget = carrier.qs_particleRaycastBudget;
            QualitySettings.realtimeReflectionProbes = carrier.qs_realtimeReflectionProbes;
#if UNITY_2017_1_OR_NEWER
            QualitySettings.resolutionScalingFixedDPIFactor = carrier.qs_resolutionScalingFixedDPIFactor;
            QualitySettings.shadowmaskMode = carrier.qs_shadowmaskMode;
#endif
            QualitySettings.shadowCascades = carrier.qs_shadowCascades;
            QualitySettings.shadowDistance = carrier.qs_shadowDistance;
            QualitySettings.shadowNearPlaneOffset = carrier.qs_shadowNearPlaneOffset;
            QualitySettings.shadowProjection = carrier.qs_shadowProjection;
#if UNITY_5_4_OR_NEWER
            QualitySettings.shadowResolution = carrier.qs_shadowResolution;
#endif
#if UNITY_5_5_OR_NEWER
            QualitySettings.shadows = carrier.qs_shadows;
            QualitySettings.softParticles = carrier.qs_softParticles;
#endif
            QualitySettings.softVegetation = carrier.qs_softVegetation;
            QualitySettings.vSyncCount = carrier.qs_vSyncCount;
        }
    }
}
