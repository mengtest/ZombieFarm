using UnityEngine;
using System.Collections;

namespace FX
{
    public class FxAudioCtrl : FxInst, IFxCtrl, IFxCfg
    {
        public override  bool IsFollow { get { return false; } }
                
        public override float autoDespwan {
            get {
                return cachedAud.clip ? 
                    (cachedAud.loop ? 0f : cachedAud.clip.length) : 
                    0.1f;
            }
        }

        AudioSource mAud;
        public AudioSource cachedAud {
            get {
                if (mAud == null) {
                    mAud = gameObject.NeedComponent<AudioSource>();
                }
                return mAud;
            }
        }

        public void Play(AudioClip clip, float volume, bool loop)
        {
            cachedAud.clip = clip;
            cachedAud.volume = volume;
            cachedAud.loop = loop;
            time = 0;

            cachedAud.Play();
        }

        public override float Stop(bool instanly)
        {
            if (instanly) {
                cachedAud.Stop();
            }
            return 0f;
        }
        
        protected override void Update()
        {
            base.Update();

            if (s_Paused && !ignoreGamePause) return;

            var delta = deltaTime;
            if (delta == 0) return;

            time += delta;

            if (cachedAud.clip == null || (!AudioListener.pause && !cachedAud.isPlaying)) {
                base.Stop(true);
            }
        }
    }
}
