using UnityEngine;
using UnityEngine.UI;
using UnityEngine.Events;
using UnityEngine.EventSystems;
using System.Collections;
using System.Collections.Generic;

namespace ZFrame.UGUI
{
    public class UIEventTrigger : UISelectable, IEventSender, IStateTransTarget,
        IPointerEnterHandler,
        IPointerExitHandler,
        IPointerDownHandler,
        IPointerUpHandler,
        IPointerClickHandler,
        IInitializePotentialDragHandler,
        IBeginDragHandler,
        IDragHandler,
        IEndDragHandler,
        IDropHandler,
        IScrollHandler,
        IUpdateSelectedHandler,
        ISelectHandler,
        IDeselectHandler,
        IMoveHandler,
        ISubmitHandler,
        ICancelHandler
    {
        [SerializeField]
        protected Graphic m_TragetGraphic;

        public Graphic targetGraphic { get { return m_TragetGraphic; } }

        private bool m_EligibleForClick;

        [SerializeField, HideInInspector]
        protected List<EventData> m_Events = new List<EventData>();

        private UIWindow __Wnd;
        protected UIWindow Wnd {
            get {
                if (__Wnd == null) {
                    __Wnd = GetComponentInParent(typeof(UIWindow)) as UIWindow;
                }
                return __Wnd;
            }
        }
        
        IEnumerator<EventData> IEnumerable<EventData>.GetEnumerator()
        {
            for (int i = 0; i < m_Events.Count; ++i) {
                yield return m_Events[i];
            }
        }

        IEnumerator IEnumerable.GetEnumerator()
        {
            for (int i = 0; i < m_Events.Count; ++i) {
                yield return m_Events[i];
            }
        }
        
        protected override void OnTransformParentChanged()
        {
            base.OnTransformParentChanged();
            __Wnd = null;
        }

        private ScrollRect m_Scroll;
        private bool m_Scrolling;
        protected bool CheckScrolling(PointerEventData eventData)
        {
            if (m_Scroll != null) {
                var delta = eventData.delta;
                float absX = Mathf.Abs(delta.x), absY = Mathf.Abs(delta.y);

                if (m_Scroll.vertical && absX < absY && m_Scroll.content.rect.height > m_Scroll.viewport.rect.height
                    || m_Scroll.horizontal && absX > absY && m_Scroll.content.rect.width > m_Scroll.viewport.rect.width) {
                    return true;
                }
            }

            return false;
        }

        protected override void Start()
        {
            base.Start();
            m_Scroll = GetComponentInParent(typeof(ScrollRect)) as ScrollRect;
            m_Scrolling = false;
        }

        public void SetEvent(TriggerType id, UIEvent eventName, string param)
        {
            EventData Event = null;
            for (int i = 0; i < m_Events.Count; ++i) {
                Event = m_Events[i];
                if (Event.type == id) break;
            }

            if (Event == null) {
                Event = new EventData(id) {
                    name = eventName, param = param,
                };
            } else {
                Event.name = eventName;
                Event.param = param;
            }
        }

        public virtual void Execute(TriggerType id, object data)
        {
#if UNITY_EDITOR || UNITY_STANDALONE
            var eventData = data as PointerEventData;
            if (eventData != null && eventData.pointerId != PointerInputModule.kMouseLeftId) return;
#endif
            for (int i = 0; i < m_Events.Count; ++i) {
                var Event = m_Events[i];
                if (Event.type == id) {
                    Wnd.SendEvent(this, Event.name, Event.param, data);
                    break;
                }
            }
        }

        public virtual void OnPointerEnter(PointerEventData eventData)
        {
            if (!IsInteractable()) return;

            Execute(TriggerType.PointerEnter, eventData);
        }

        public virtual void OnPointerExit(PointerEventData eventData)
        {
            if (!IsInteractable()) return;

            Execute(TriggerType.PointerExit, eventData);
        }

        public virtual void OnDrag(PointerEventData eventData)
        {
            if (!IsInteractable()) return;

            if (m_Scrolling) {
                m_Scroll.OnDrag(eventData);
            } else {
                Execute(TriggerType.Drag, eventData);
            }
        }

        public virtual void OnDrop(PointerEventData eventData)
        {
            if (!IsInteractable()) return;

            Execute(TriggerType.Drop, eventData);
        }

        public virtual void OnPointerDown(PointerEventData eventData)
        {
            if (!IsInteractable()) return;

            m_EligibleForClick = true;
            Execute(TriggerType.PointerDown, eventData);
        }

        public virtual void OnPointerUp(PointerEventData eventData)
        {
            if (!IsInteractable()) return;

            Execute(TriggerType.PointerUp, eventData);
        }

        public virtual void OnPointerClick(PointerEventData eventData)
        {
            if (!IsInteractable()) return;

            if (m_EligibleForClick) {
                Execute(TriggerType.PointerClick, eventData);
            }
        }

        public virtual void OnSelect(BaseEventData eventData)
        {
            if (!IsInteractable()) return;

            Execute(TriggerType.Select, eventData);
        }

        public virtual void OnDeselect(BaseEventData eventData)
        {
            if (!IsInteractable()) return;

            Execute(TriggerType.Deselect, eventData);
        }

        public virtual void OnScroll(PointerEventData eventData)
        {
            if (!IsInteractable()) return;

            if (m_Scroll) m_Scroll.OnScroll(eventData);
            Execute(TriggerType.Scroll, eventData);
        }

        public virtual void OnMove(AxisEventData eventData)
        {
            if (!IsInteractable()) return;

            Execute(TriggerType.Move, eventData);
        }

        public virtual void OnUpdateSelected(BaseEventData eventData)
        {
            if (!IsInteractable()) return;

            Execute(TriggerType.UpdateSelected, eventData);
        }

        public virtual void OnInitializePotentialDrag(PointerEventData eventData)
        {
            if (!IsInteractable()) return;

            if (m_Scroll) m_Scroll.OnInitializePotentialDrag(eventData);
            Execute(TriggerType.InitializePotentialDrag, eventData);
        }

        public virtual void OnBeginDrag(PointerEventData eventData)
        {
            if (!IsInteractable()) return;

            m_EligibleForClick = false;
            
            m_Scrolling = CheckScrolling(eventData);
            if (m_Scrolling) {
                m_Scroll.OnBeginDrag(eventData);
            } else {
                Execute(TriggerType.BeginDrag, eventData);
            }
        }

        public virtual void OnEndDrag(PointerEventData eventData)
        {
            if (!IsInteractable()) return;

            if (m_Scrolling) {
                m_Scroll.OnEndDrag(eventData);
            } else {
                Execute(TriggerType.EndDrag, eventData);
            }
        }

        public virtual void OnSubmit(BaseEventData eventData)
        {
            if (!IsInteractable()) return;

            Execute(TriggerType.Submit, eventData);
        }

        public virtual void OnCancel(BaseEventData eventData)
        {
            if (!IsInteractable()) return;

            Execute(TriggerType.Cancel, eventData);
        }
    }
}
