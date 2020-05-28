//
//  FMODAudioPlayer.cs
//  survive
//
//  Created by xingweizhen on 10/21/2017.
//
//

using System.Collections;
using System.Collections.Generic;
using FX;
using UnityEngine;
using ZFrame.Asset;

namespace FMODUnity
{
    [RequireComponent(typeof(FxInst))]
    public class FMODSfxPlayer : MonoBehaviour, IFxEvent, IPoolable
    {
        [SerializeField, EventRef]
        private string m_EventName = null;

        private FMODAudioEmitter m_Emitter;

        void IFxEvent.OnFxInit()
        {
            m_Emitter = FMODMgr.Instance.GetEmitter(transform).Init(m_EventName);
            if (m_Emitter) {
                var fxC = GetComponent(typeof(IFxCtrl)) as IFxCtrl;
                if (fxC != null) {
                    m_Emitter.SetGender(fxC.holder);
                }
                m_Emitter.Play();
            }
        }

        void IPoolable.OnRecycle()
        {
            if (m_Emitter) m_Emitter.Stop(false);
        }

        void IPoolable.OnRestart()
        {

        }
    }
}
