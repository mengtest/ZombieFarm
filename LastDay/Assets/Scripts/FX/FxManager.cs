//
//  FxManager.cs
//  survive
//
//  Created by xingweizhen on 11/3/2017.
//
//

using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using ZFrame;
using ZFrame.Asset;

using IUnit = World.IObj;
using Timer = World.Timer;

namespace FX
{
    public class FxManager : MonoSingleton<FxManager>
    {
        private class FxPlayer
        {
            public IUnit self, target;
            public Timer timer;
            public string fx, sfx;
            public FXPoint point;

            public FxPlayer Apply(IUnit self, IUnit target, Timer timer, string fx, string sfx, FXPoint point)
            {
                this.self = self; this.target = target;
                this.timer = timer;
                this.fx = fx; this.sfx = sfx;
                this.point = point;

                return this;
            }

            public void Play()
            {
                if (timer == null || !timer.expire) {
                    self.PlayFxOnTarget(target, timer, fx, sfx, point);
                }
            }

            public static void OnRelease(FxPlayer p)
            {
                p.self = null;
                p.target = null;
                p.timer = null;
            }
        }

        private class Task
        {
            public string bundleName;
            public List<FxPlayer> players = new List<FxPlayer>();

            public void Add(FxPlayer player)
            {
                players.Add(player);
            }

            public void Complete()
            {
                foreach (var p in players) p.Play();
            }
        }

        private Pool<Task> m_TaskPool;
        private Pool<FxPlayer> m_PlayerPool;

        private List<Task> m_Tasks = new List<Task>();

        protected override void Awaking()
        {
            base.Awaking();

            m_PlayerPool = new Pool<FxPlayer>(null, FxPlayer.OnRelease);
            m_TaskPool = new Pool<Task>(null, (task) => {
                task.Complete();
                m_Tasks.Remove(task);
                foreach (var p in task.players) {
                    m_PlayerPool.Release(p);
                }
                task.players.Clear();
            });

            OnFxAssetLoaded = new DelegateObjectLoaded(__FxAssetLoaded);
        }

        public void Schedule(IUnit self, IUnit target, Timer tm, string fxName, string sfxName, FXPoint point)
        {
            var fxPath = "FX/" + fxName;

            var player = m_PlayerPool.Get();
            string bundlerName, assetName;
            AssetLoader.GetAssetpath(fxPath, out bundlerName, out assetName);

            Task task = null;
            foreach (var t in m_Tasks) {
                if (t.bundleName == bundlerName) {
                    task = t; break;
                }
            }

            if (task == null) {
                task = m_TaskPool.Get();
                task.bundleName = bundlerName;
                AssetsMgr.A.LoadAsync(null, fxPath, LoadMethod.Cache, OnFxAssetLoaded, task);
            }
            task.Add(player.Apply(self, target, tm, fxName, sfxName, point));
        }

        private DelegateObjectLoaded OnFxAssetLoaded;
        private void __FxAssetLoaded(string a, object o, object p)
        {
            m_TaskPool.Release(p as Task);
        }

    }
}
