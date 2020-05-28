//
//  ViewDefine.cs
//  survive
//
//  Created by xingweizhen on 10/17/2017.
//
//

using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;

namespace World.View
{
    [System.Flags]
    public enum DressType
    {
        Head = 1, Body = 2, Legs = 4, Feet = 8,
    }

    /// <summary>
    /// Attach to <ObjAnim>
    /// </summary>
    public interface ISkinProperty
    {
        void GetSkins(List<Component> skins);
    }
    
    public interface IRenderView : IObjView, ISkinProperty
    {
        Renderer skin { get; set; }

        bool IsDress(DressType dress);
        void SetDress(DressType dress);
        void FadeView(float from, float to, float duration);
    }

    public interface IUnitView : IObjView
    {
        GameObject root { get; set; }
        Animator anim { get; }
        NavMeshAgent agent { get; }
        HUDText hud { get; }

        void SetAction(ObjAnim ctrl, Control.NWObjAction nwAction);
    }

    /// <summary>
    /// Attach to <ObjAnim>
    /// </summary>
    public interface IHurtAction
    {
        void ShowAction(ILiving living, ref VarChange Ch);
    }

    /// <summary>
    /// Attach to <ObjAnim>
    /// </summary>
    public interface IDeadAction
    {
        void InitAction(IEntity entity);
        void ShowAction(IEntity entity, ref DisplayValue Val);
    }

    /// <summary>
    /// Attach to <ObjAnim>
    /// </summary>
    public interface IInitRender
    {
        void InitRender();
    }

    /// <summary>
    /// Attach to <ObjAnim>
    /// </summary>
    public interface ISkinMaterial
    {
        MaterialSet materialSet { get; }
    }

    public interface IStatusAnim
    {
        void OnStatusChanged(int status);
    }
    
    /// <summary>
    /// 受创表现
    /// </summary>
    public class HurtData
    {
        public readonly int id;
        public string sfx;
        public readonly List<string> Fxes;
        public float force;

        public HurtData(int id)
        {
            this.id = id;
            this.Fxes = new List<string>();
        }

        public string GetFx(int bodyMat)
        {
            bodyMat -= 1;
            if (bodyMat >= 0 && bodyMat < Fxes.Count) {
                return Fxes[bodyMat];
            }
            return null;
        }
    }

    public struct DisplayValue
    {
        public bool valid { get; private set; }
        public IObj source;
        public HurtData hurt;
        public int type;
        public int value;
        public float force;
        public bool overrideFx;

        public void Reset(int type = 0, int value = 0)
        {
            Init(null, type, value);
            valid = false;
        }

        public void Init(IObj source, int type, int value)
        {
            valid = true;
            this.source = source;
            this.type = type;
            this.value = value;
            overrideFx = false;
            force = 0;
        }
    }

    public enum DeadType
    {
        None = 1,
        HeadShot = 2,
        WaistCut = 3,
        Burning = 4,
        ElectricShock = 5,
        Smash = 6,
    }
}
