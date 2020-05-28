using UnityEngine;
using UnityEngine.Events;
using System.Collections;
using System.Collections.Generic;

namespace ZFrame.UGUI
{
    using Tween;
    using UnityEngine.UI;

    public class UIScrollView : ScrollRect, ITweenable, ITweenable<float>, IEventSender
    {        
        #region 事件通知
        [SerializeField, HideInInspector, NamedProperty("滑动事件")]
        private EventData m_Event = new EventData(TriggerType.None, UIEvent.Send);
        [SerializeField, HideInInspector]
        private EventData m_BeginDrag = new EventData(TriggerType.None, UIEvent.Send);
        [SerializeField, HideInInspector]
        private EventData m_Drag = new EventData(TriggerType.None, UIEvent.Send);
        [SerializeField, HideInInspector]
        private EventData m_EndDrag = new EventData(TriggerType.None, UIEvent.Send);

        IEnumerator<EventData> IEnumerable<EventData>.GetEnumerator()
        {
            yield return m_Event;
            yield return m_BeginDrag;
            yield return m_Drag;
            yield return m_EndDrag;
        }

        IEnumerator IEnumerable.GetEnumerator()
        {
            yield return m_Event;
            yield return m_BeginDrag;
            yield return m_Drag;
            yield return m_EndDrag;
        }

        private UIWindow __Wnd;
        protected UIWindow Wnd {
            get {
                if (__Wnd == null) {
                    __Wnd = GetComponentInParent(typeof(UIWindow)) as UIWindow;
                }
                return __Wnd;
            }
        }

        protected override void OnTransformParentChanged()
        {
            base.OnTransformParentChanged();
            __Wnd = null;
        }
        
        protected void OnScrollValueChanged(Vector2 value)
        {
#if UNITY_EDITOR
            if (!Application.isPlaying) return;
#endif
            if (m_Event.IsActive()) {
                Wnd.SendEvent(this, m_Event.name, m_Event.param);
            }
        }
        #endregion

        protected override void Awake()
        {
            base.Awake();

            onValueChanged.AddListener(OnScrollValueChanged);
        }

        public override void OnBeginDrag(UnityEngine.EventSystems.PointerEventData eventData)
        {
            base.OnBeginDrag(eventData);
            m_BeginDrag.Send(this, Wnd);
        }

        public override void OnDrag(UnityEngine.EventSystems.PointerEventData eventData)
        {
            base.OnDrag(eventData);
            m_Drag.Send(this, Wnd);
        }

        public override void OnEndDrag(UnityEngine.EventSystems.PointerEventData eventData)
        {
            base.OnEndDrag(eventData);
            m_EndDrag.Send(this, Wnd);
        }

        protected override void SetContentAnchoredPosition(Vector2 position)
        {
            var offset = content.anchoredPosition - position;
            if (vertical && Mathf.Abs(offset.y) > 1e-3 || horizontal && Mathf.Abs(offset.x) > 1e-3) {
                base.SetContentAnchoredPosition(position);
            }
        }

        private void SetNormalizedPosition(Vector2 pos)
        {
            normalizedPosition = pos;
        }

        private Vector2 GetNormalizedPosition()
        {
            return normalizedPosition;
        }
        
        public ZTweener Tween(object from, object to, float duration)
        {
            ZTweener tw = null;
            if (to is Vector2) {
                tw = this.Tween(GetNormalizedPosition, SetNormalizedPosition, (Vector2)to, duration);
                if (from is Vector2) {
                    tw.StartFrom((Vector2)from);
                }
            }
            if (tw != null) tw.SetTag(this);
            return tw;
        }

        public ZTweener Tween(float to, float duration)
        {
            ZTweener tw = null;

            if (vertical) {
                var v2To = new Vector2(0, to);
                tw = this.Tween(GetNormalizedPosition, SetNormalizedPosition, v2To, duration);
            } else if (horizontal) {
                var v2To = new Vector2(to, 0);
                tw = this.Tween(GetNormalizedPosition, SetNormalizedPosition, v2To, duration);
            }

            if (tw != null) tw.SetTag(this);
            return tw;
        }

        public ZTweener Tween(float from, float to, float duration)
        {
            if (vertical) {
                verticalNormalizedPosition = from;
            } else if (horizontal) {
                horizontalNormalizedPosition = from;
            }

            return Tween(to, duration);
        }
    }
}
