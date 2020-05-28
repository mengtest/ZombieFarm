using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using ZFrame;

namespace FX
{
    using World;
    using IUnitTarget = World.IObj;

    public enum FXPoint
    {
        Foot,
        Body,
        Weapon,
        Head,
        Top,
        Screen,
    };

    public interface IViewable
    {
        void ShowView(float fadeTime);
        void HideView(float fadeTime);
    }

    /// <summary>
    /// 这就是[真正的特效控制器]了
    /// </summary>
    public interface IFxCtrl : IViewable
    {
        bool IsNull();

        string fxName { get; set; }

        /// <summary>
        /// 同一个单位上该特效可以播放多个
        /// </summary>
        bool multiple { get; }
        
        GameObject prefab { get; }
        GameObject go { get; }

        Vector3 position { get; set; }

        /// <summary>
        /// 是否跟随挂载点
        /// </summary>
        bool IsFollow { get; }

        /// <summary>
        /// 消失时是否渐隐
        /// </summary>
        bool IsFading { get; }

        /// <summary>
        /// 回收时是否使用保持Active
        /// </summary>
        bool IsPooled { get; }
        
        /// <summary>
        /// 自动回收时间，0表示不自动回收
        /// </summary>
        float autoDespwan { get; }

        /// <summary>
        /// 特效携带者
        /// </summary>
        IUnitTarget holder { set; get; }

        /// <summary>
        /// 特效释放者
        /// </summary>
        IUnitTarget caster { set; get; }

        void SetVisible(bool visible);
        float Stop(bool instantly);
        void Reset();

        IFxCtrl Instantiate(GameObject parent, string fullName);
        void OnInitDone();
    }

    /// <summary>
    /// 特效事件，当特效某个阶段时可以做一些事情
    /// </summary>
    public interface IFxEvent
    {
        void OnFxInit();
    }

    /// <summary>
    /// 特效配置项：可以根据索引获取[真正的特效控制器]@IFxCtrl
    /// </summary>
	public interface IFxCfg
    {
        /// <summary>
        /// 特效优先级
        /// </summary>
        int level { get; }
        IFxCtrl Get(int i, object holder);
#if UNITY_EDITOR
        string FxChecking();
#endif
    }

    public interface IFxHolder
    {
        /// <summary>
        /// 头部位置
        /// </summary>
        Transform headPoint { get; }
        /// <summary>
        /// 身体位置
        /// </summary>
        Transform bodyPoint { get; }
        /// <summary>
        /// 地面位置
        /// </summary>
        Transform footPoint { get; }
        /// <summary>
        /// 攻击发射点
        /// </summary>
        Transform firePoint { get; set; }
        /// <summary>
        /// 头顶
        /// </summary>
        Transform topPoint { get; }
        
        bool visible { get; }
    }


    public interface IFxAnchor
    {
        FxAnchor GetAnchor(IFxHolder holder);
    }

    public struct FxAnchor
    {
        public Transform anchor;
        public Vector3 offset;
        public bool forward;

        private bool m_Nil;
        public bool IsNull() { return m_Nil; }
        public static FxAnchor Null = new FxAnchor() { m_Nil = true };
    }

    public class FxList : IEnumerable<IFxCtrl>, ITimerParam, System.IDisposable
    {
        private List<IFxCtrl> m_List;
        private IUnitTarget m_Caster;
        public FxList(List<IFxCtrl> collection, IUnitTarget caster)
        {
            m_Caster = caster;
            SetList(collection);
        }

        public void SetList(List<IFxCtrl> list)
        {
            if (m_List != null) {
                m_List.AddRange(list);
            } else {
                m_List = list;
            }
        }

        public void InitWithTimer(Timer tm, int arg)
        {
            tm.SetEvent(null, FxTool.OnFxFinish, FxTool.OnFxBreak);   
        }

		public override string ToString ()
		{
			return string.Format ("[FX*{0}]", m_List.Count);
		}

        private bool m_Disposed;

        ~FxList() { Dispose(false); }

        public void Dispose()
        {
            Dispose(true);

            System.GC.SuppressFinalize(this);
        }

        protected virtual void Dispose(bool disposing)
        {
            if (m_Disposed) return;
            if (disposing) {
                // 无托管资源
            }
            
            ListPool<IFxCtrl>.Release(m_List);
            m_Disposed = true;
        }

        public IEnumerator<IFxCtrl> GetEnumerator()
        {
            return m_List.GetEnumerator();
        }

        IEnumerator IEnumerable.GetEnumerator()
        {
            return m_List.GetEnumerator();
        }

        public void OnFinish()
        {
			for (int i = 0; i < m_List.Count; ++i) {
				var fx = m_List[i];
                if (fx.IsNull() || fx.caster != m_Caster) continue;

				if (fx.autoDespwan == 0) {
					fx.Stop(false);
				}
			}
        }

        public void OnBreak()
        {
			for (int i = 0; i < m_List.Count; ++i) {
				var fx = m_List[i];
                if (fx.IsNull() || fx.caster != m_Caster) continue;

                if (fx.autoDespwan == 0) {
					fx.Stop(false);
				} else {
					fx.Stop(true);
				}
			}
        }
    }

    public interface ISkinView : IViewable
    {
        GameObject actor { get; }

		bool IsNull();       
        void ChangeColor(Color c, List<Renderer> rdrs = null);
        void ChangeShader(Shader shader, List<Renderer> rdrs = null);
        void ResetSkin(List<Renderer> rdrs = null);
        void SetSkinLayer(int layer);
    }

    public interface IActionView : ISkinView
    {
		bool busying { get; set; }
        float PlayAction(string action, float crossfade, float hasten = 1f);
		void ResetIdle(string anim);
    }

    public interface IHudView
    {
        //MOBAHud hud { get; set; }
    }

    public interface IMissileCurve
    {
        Vector3 Evaluate(float t);
    }
}
