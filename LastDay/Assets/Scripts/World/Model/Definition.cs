using System;
using System.Collections.Generic;
using UnityEngine;
using ZFrame.HFSM;

namespace World 
{
    #region 数值
    public interface IPosition
    {
        Vector pos { get; set; }
    }
    public interface IVector
    {
        Vector point { get; }
        Vector forward { get; set; }
    }
    public interface IVolume : IVector
    {
        int vid { get; }
        int blockLevel { get; }
        Vector size { get; set; }
    }

    public interface IAttrData
    {
        float GetAttr(ATTR attr);
        float GetRawAttr(ATTR attr);
    }
    #endregion

    #region 对象
    public interface IObj : IGridBasedObj
    {
        int id { get; }
        int dat { get; }
        int camp { get; }
        long master { get; }

        /// <summary>
        /// 对象的轴心（可能与中心pos不同）
        /// </summary>
        Vector coord { get; }

        Stage L { get; }
        IObjView view { get; set; }
        float Dist { get; set; }

        /// <summary>
        /// 是否可见状态
        /// </summary>
        bool IsVisible(IObj by);
        
        /// <summary>
        /// 是否可以被攻击技能选中
        /// </summary>
        bool IsSelectable(IObj by);
        
        /// <summary>
        /// 是否活着（不存在生命值或者生命值大于0）
        /// </summary>
        bool IsAlive();
        
        void Destroy();
        bool IsNull();
    }

    public interface IEntity : IObj, IVolume, IAttrData
    {
        ObjData Data { get; }
        int operLimit { get; }
        int operId { get; }
        bool obstacle { get; }
        int layer { get; }
        bool offensive { get; }

        bool IsLocal();
    }
    
    public interface IGrid
    {
        bool Add(IGridBasedObj obj);
        bool Remove(IGridBasedObj obj);
        void GetObjInGrid<T>(List<T> result) where  T : IGridBasedObj;
        bool GetObjInGrid<T>(Func<T, bool> func) where  T : IGridBasedObj;
        int X { get; }
        int Y { get; }
    }
    
    public interface IGridBasedObj : IPosition
    {
        IGrid Grid { get; set; }
    }

    
    #endregion

    #region 能力
    public interface IBehavior : IObj
    {
        bool IsLocal();
        void OnStart();
        void OnUpdate();
        void OnStop();
    }

    public enum ActProc
    {
        Start, Success, Finish, Break,
    }

    public interface IActor : IBehavior, IAttrData, IFSMContext
    {
        /// <summary>
        /// 单位的当前动作状态
        /// </summary>
        int state { get; set; }
        
        ActionContent Content { get; }
        IAction IGetAction(int index);
        bool HasAction(int id);

        void OnAction(IAction action, IObj target, ActProc proc);
    }

    public interface ILiving : IObj
    {
        VarData Health { get; }
        int ChangeHp(VarChange inf);
        void Kill();
    }

    public interface ITurnable : IEntity
    {
        Vector turnForward { get; set; }
        float GetAngularSpeed();
    }

    public interface IMovable : IEntity
    {
        Vector destination { get; }
        Vector moveTarget { get; set; }
        float shiftingRate { get; set; }
        bool autoMove { get; }

        float GetShiftingSpeed();
        float GetMovingSpeed();

        void WarpAt(Vector pos);
        void MoveTo(Vector coord, float rate);
        void MoveTowards(Vector direction, float rate);
        void StopMoving();
    }
    #endregion

    #region 配置数据
    public enum ACTOper
    {
        Cancelled = -1,

        /// <summary>
        /// 自动判断
        /// </summary>
        Auto = 0,

        /// <summary>
        /// 可以操作连续施放
        /// </summary>
        Loop = 1,

        /// <summary>
        /// 每次操作只会施放一次
        /// </summary>
        OneShot,

        /// <summary>
        /// 需要蓄力操作，效果随释放的时间变化
        /// </summary>
        Charged,
    }

    public enum ACTMode {
        /// <summary>
        /// 常规模式，必须停下来施放，移动会打断施放中的动作
        /// </summary>
        NONE,
        /// <summary>
        /// 施放中的动作在【前摇】结束前不会被移动打断。
        /// </summary>
        Suc2Move,
        /// <summary>
        /// 施放中的动作在【后摇】结束前不会被移动打断。
        /// </summary>
        Fin2Move,
        /// <summary>
        /// 可以在移动中自由施放的动作
        /// </summary>
        FreeMove,
    }

    public enum ACTType
    {
        SKILL,  // 攻击技能
        PICK,   // 捡垃圾
        OPEN,   // 开箱子
        SYNC,   // 同步动作
        TRIG,   // 触发机关
        FUNC,   // 同步功能
    }

    public interface IConfig 
    {
        int id { get; }
    }

    public interface IAction : IConfig, ITimerParam, IEventParam
    {
        ACTType type { get; }
        ACTOper oper { get; }
        ACTMode mode { get; }
        bool allowNullTar { get; }
        int blockLevel { get; }
        int GetAdvancedId(AdvancedCond cond, int value);
        int GetAdvancedId(AdvancedCond cond, VarData data);
        int cooldown { get; }
        int ready { get; }
        int cast { get; }
        int post { get; }
        int speed { get; }
        int delay { get; }
        float minRange { get; }
        float maxRange { get; }
        string motion { get; }
        bool UsableFor(IActor bObj);
        IObj TargetFor(IActor bObj);
        void ClampTarget(IActor bObj, ref IObj target);
        void OnStart(IActor bObj);
        void OnSuccess(IObj Who, IObj Whom);
        void OnFinish(IObj Who, IObj Whom);
    }
    #endregion

    #region 状态数据
    public interface IEventParam
    {

    }
    #endregion

    #region View
    public class FxView
    {
        public readonly string fx, fxT, sfx;
        public FxView(string fx, string fxT, string sfx)
        {
            this.fx = fx;
            this.fxT = fxT;
            this.sfx = sfx;
        }
    }

    public interface ICastData : IConfig
    {
        string motion { get; }
        FxView startFx { get; }
        FxView successFx { get; }
    }

    public interface IHitData : IConfig
    {
        IAction Action { get; }
        string fxH { get; }
        string sfxH { get; }
    }

    public interface IFxBundle
    {
        string fxBundle { get; }
        string sfxBank { get; }
    }

    public interface IObjView
    {
        IObj obj { get; }
        bool IsNull();
        bool IsVisible();
        void Subscribe(IObj o);
        void Unsubscribe();
        void UnloadView();
        void Destruct(float delay);
    }
    #endregion
}
