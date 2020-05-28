using UnityEngine;

namespace World {
    public class QualityAdjuster
    {
        public static int GetQuality()
        {
            var quality = 3;

#if UNITY_IOS
            {
                var iOSGen = UnityEngine.iOS.Device.generation;
                if (iOSGen < UnityEngine.iOS.DeviceGeneration.iPhone6)
                {
                    quality = 1;
                }
                else if(iOSGen < UnityEngine.iOS.DeviceGeneration.iPhone7)
                {
                    quality = 2;
                }
                else
                {
                    quality = 3;
                }
            }
#endif

#if UNITY_ANDROID
            {
                var ram = SystemInfo.systemMemorySize;
                // var vram = SystemInfo.graphicsMemorySize;
                var cpus = SystemInfo.processorCount;

                if (cpus > 4 && ram >= 2800)
                {
                    quality = 3;
                }
                else if (ram >= 1900)
                {
                    quality = 2;
                }
                else
                {
                    quality = 1;
                }
            }
#endif
            return quality;
        }
    }
}