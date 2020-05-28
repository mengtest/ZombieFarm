//
//  FMODAudioPlayer.cs
//  survive
//
//  Created by xingweizhen on 10/21/2017.
//
//

using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using ZFrame.Asset;

namespace FMODUnity
{
    public class FMODAudioPlayer : FMODAudioEmitter
    {
        [SerializeField]
        private string m_Bank = null;
        
        protected override void Update()
        {
            if (AssetsMgr.A && FMODMgr.Instance && FMODMgr.Instance.ready) {
                enabled = false;
                AssetsMgr.A.LoadAsync(null, string.Format("fmod/{0}/", m_Bank),
                    LoadMethod.Default, OnFMODBankLoaded, this);
            }
        }

        private static DelegateObjectLoaded OnFMODBankLoaded = new DelegateObjectLoaded(__FMODBankLoaded);
        private static void __FMODBankLoaded(string a, object o, object p)
        {
            var player = p as FMODAudioPlayer;
            player.Init(player.current).Play();
        }
    }
}
