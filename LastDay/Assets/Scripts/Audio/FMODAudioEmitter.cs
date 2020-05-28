//
//  FMODAudioEmitter.cs
//  survive
//
//  Created by xingweizhen on 10/23/2017.
//
//

using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using FMOD.Studio;
using FX;

namespace FMODUnity
{
    public class FMODAudioEmitter : FxInst, IFxCfg
    {
        [SerializeField, HideInInspector]
        private bool m_OverrideAtten;

        [SerializeField, HideInInspector]
        private float m_MinDistance;

        [SerializeField, HideInInspector]
        private float m_MaxDistance;

        [SerializeField, HideInInspector]
        [EventRef]
        private string m_EventName;

        public string current { get { return m_EventName; } protected set { m_EventName = value; } }

        public override bool IsFollow { get { return true; } }

        protected float m_AutoDespwan = -1;
        public override float autoDespwan { get { return m_AutoDespwan; } }
        
        private EventDescription m_EventDesc;
        private EventInstance m_EventInst;

        public FMODAudioEmitter Init(string eventName)
        {
            time = 0;
            StopPlaying(true);

            if (eventName != current) {
                if (m_EventDesc.isValid()) {
                    m_EventDesc.clearHandle();
                }
                current = eventName;
            }

            if (!m_EventDesc.isValid()) {
                try {
                    m_EventDesc = RuntimeManager.GetEventDescription(eventName);
                } catch (System.Exception e) {
                    Debug.LogWarning(e);
                    return this;
                }
            }

            bool is3D;
            m_EventDesc.is3D(out is3D);

            bool isOneshot;
            m_EventDesc.isOneshot(out isOneshot);

            int length;
            m_EventDesc.getLength(out length);

            m_AutoDespwan = isOneshot ? length / 1000f + .5f : -1;

            m_EventDesc.createInstance(out m_EventInst);

            // Only want to update if we need to set 3D attributes
            if (is3D) {
                var rigidBody = GetComponent<Rigidbody>();
                var transform = GetComponent<Transform>();
                m_EventInst.set3DAttributes(RuntimeUtils.To3DAttributes(gameObject, rigidBody));
                FMODMgr.AttachInstance(m_EventInst, transform, rigidBody);

                if (m_OverrideAtten) {
                    m_EventInst.setProperty(EVENT_PROPERTY.MINIMUM_DISTANCE, m_MinDistance);
                    m_EventInst.setProperty(EVENT_PROPERTY.MAXIMUM_DISTANCE, m_MaxDistance);
                } else {
                    m_EventInst.getProperty(EVENT_PROPERTY.MINIMUM_DISTANCE, out m_MinDistance);
                    m_EventInst.getProperty(EVENT_PROPERTY.MAXIMUM_DISTANCE, out m_MaxDistance);
                }
            }

            if (current == FMODMgr.SNAPSHOT_indoor) {
                FMODMgr.Instance.InDoor = true;
            }
            return this;
        }

        public bool GetParam(string name, out float value)
        {
            var finalValue = 0f;
            value = 0f;
            if (m_EventInst.isValid()) {
                return m_EventInst.getParameterByName(name, out value, out finalValue) == FMOD.RESULT.OK;
            }
            return false;
        }

        public bool GetParam(PARAMETER_ID index, out float param)
        {
            return m_EventInst.getParameterByID(index, out param) == FMOD.RESULT.OK;
        }

        public bool GetState(out PLAYBACK_STATE playbackState)
        {
            FMOD.RESULT ret = FMOD.RESULT.ERR_INVALID_HANDLE;
            playbackState = PLAYBACK_STATE.PLAYING;
            if (m_EventInst.isValid()) {
                ret = m_EventInst.getPlaybackState(out playbackState); ;
            }
            return ret == FMOD.RESULT.OK;
        }

        public bool SetParam(string name, float value)
        {
            if (m_EventInst.isValid()) {
                return m_EventInst.setParameterByName(name, value) == FMOD.RESULT.OK;
            }
            return false;
        }
        
        public void SetAtten(bool overrideAtten, float min = 0, float max = 0)
        {
            m_OverrideAtten = overrideAtten;
            if (overrideAtten) {
                m_MinDistance = min;
                m_MaxDistance = max;
                m_EventInst.setProperty(EVENT_PROPERTY.MINIMUM_DISTANCE, m_MinDistance);
                m_EventInst.setProperty(EVENT_PROPERTY.MAXIMUM_DISTANCE, m_MaxDistance);
            }
        }

        public void Play()
        {
            if (m_EventInst.isValid()) {
                var ret = m_EventInst.start();
                if (ret != FMOD.RESULT.OK) LogMgr.W("FMOD {0} start: {1}", m_EventName, ret);
            }
        }

        protected void StopPlaying(bool instanly)
        {
            if (m_EventInst.isValid()) {
                bool oneShot;
                m_EventDesc.isOneshot(out oneShot);
                if (instanly || !oneShot) {
                    FMODMgr.DetachInstance(m_EventInst);
                    m_EventInst.stop(FMOD.Studio.STOP_MODE.ALLOWFADEOUT);//ALLOWFADEOUT
                    m_EventInst.release();
                    m_EventInst.clearHandle();

                    if (FMODMgr.Instance && current == FMODMgr.SNAPSHOT_indoor) {
                        FMODMgr.Instance.InDoor = false;
                    }
                }
            }
        }

        public override float Stop(bool instanly)
        {
            StopPlaying(instanly);
            enabled = false;
            return 0;
        }

        public bool IsPlaying()
        {
            if (m_EventInst.isValid()) {
                PLAYBACK_STATE playbackState;
                m_EventInst.getPlaybackState(out playbackState);
                return (playbackState != PLAYBACK_STATE.STOPPED);
            }
            return false;
        }

        protected override void Start()
        {
            RuntimeUtils.EnforceLibraryOrder();

            base.Start();
        }

        protected override void OnDisable()
        {
            base.OnDisable();

            if (holder == null) {
                StopPlaying(true);
            }
        }

        protected override void OnRecycle()
        {
            Stop(false);

            base.OnRecycle();
        }

        protected override void OnDestroy()
        {
            Stop(true);
        }
    }
}
