using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using ZFrame;

namespace FX
{
    public class FxFadingBody : FxTiming
    {
        public float delay = 0;
        public float duration = 0.5f;
        public float fadeOut = 0.25f;
        public float fadeIn = 0.25f;
        public Shader fadeShader;
        public Color fadeColor;

        protected float postBegin;
        [Description("对象")]
        protected ISkinView view;
        protected virtual List<Renderer> m_Target { get { return null; } }

        private float passTime { get { return time - delay; } }

        protected void SetAlpha(float alpha)
        {
            var c = fadeColor;
            c.a = alpha;
            view.ChangeColor(c, m_Target);
        }
        
        protected virtual void PrepFade(float t)
        {
            if (t == 0) view.ChangeShader(fadeShader, m_Target);

            SetAlpha(Mathf.Lerp(0.5f, 0f, t));

            if (t == 1) {
                view.HideView(0);
            }
        }

        protected virtual void PostFade(float t)
        {
            if (t == 0) { 
                view.ShowView(0);
            }

            SetAlpha(Mathf.Lerp(0, 0.5f, t));

            if (t == 1) {
                view.ResetSkin();    
            }
        }

        protected virtual void Prepare()
        {   
            view = (GetComponent(typeof(IFxCtrl)) as IFxCtrl).holder.view as ISkinView;
        }

        protected virtual void Update()
        {
            if (view == null) {
                Prepare();
                time = 0;
                postBegin = duration - fadeIn;
                return;
            }

            if (deltaTime > 0) {
                float preTime = time;
                float prePass = passTime;
                time += deltaTime;
                if (time > delay + duration) {
                    // 已超过时间
                    enabled = false;
                } else if (time > delay) {                    
                    if (preTime <= delay) {
                        PrepFade(0);
                    }
                    float pass = passTime;
                    if (pass <= fadeOut) {                        
                        PrepFade(pass / fadeOut);
                    } else if (prePass <= fadeOut) {
                        PrepFade(1);
                    } else if (pass >= postBegin) {
                        if (prePass < postBegin) {
                            PostFade(0);
                        }
                        float fadeTmp = pass - postBegin;
                        PostFade(fadeTmp / fadeIn);                        
                    } else if (pass > duration && prePass < duration) {
                        PostFade(1);
                    }
                }
            }
        }
        
        protected virtual void OnRecycle()
        {
            if (view != null) {
                if (!view.IsNull()) {
                    view.ShowView(0);
                    view.ResetSkin(m_Target);
                }
                view = null;
            }
        }

        private void OnDestroy()
        {
            OnRecycle();
        }

    }
}
