using UnityEngine;
using UnityEngine.UI;
using UnityEngine.Events;
using UnityEngine.EventSystems;
using System.Collections;
using System.Collections.Generic;
using NoToLua = XLua.BlackListAttribute;

namespace ZFrame.UGUI
{
    public class UIButton : Button, IEventSender, IStateTransTarget
    {
        public static UnityAction<GameObject> onButtonClick;
        public static string defaultSfx;

#if FMOD
        [FMODUnity.EventRef]
#endif
        public string clickSfx;

        #region 事件通知
        [SerializeField, HideInInspector]
        private EventData m_Event = new EventData(TriggerType.PointerClick);

        IEnumerator<EventData> IEnumerable<EventData>.GetEnumerator()
        {
            yield return m_Event;
        }

        IEnumerator IEnumerable.GetEnumerator()
        {
            yield return m_Event;
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

        protected void OnEventTrigger(BaseEventData eventData)
        {
            Wnd.SendEvent(this, m_Event.name, m_Event.param, eventData);
        }
        #endregion

        [NoToLua]
        public override void OnPointerClick(PointerEventData eventData)
        {
            if (IsActive() && IsInteractable()) {
                base.OnPointerClick(eventData);
                this.OnEventTrigger(eventData);
                if (onButtonClick != null) onButtonClick.Invoke(gameObject);

                // 点击音效
                UGUITools.PlayUISfx(clickSfx, defaultSfx);
            }
        }

        protected override void DoStateTransition(SelectionState state, bool instant)
        {
            base.DoStateTransition(state, instant);
            this.TryStateTransition((SelectingState)state, instant);
        }
        
        public void SetInteractable(bool interactable)
        {
            this.interactable = interactable;
			UGUITools.SetGrayscale(gameObject, !interactable);
        }
    }
}