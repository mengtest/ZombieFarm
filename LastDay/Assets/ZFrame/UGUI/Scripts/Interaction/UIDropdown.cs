using UnityEngine;
using UnityEngine.UI;
using UnityEngine.Events;
using UnityEngine.EventSystems;
using System.Collections;
using System.Collections.Generic;

namespace ZFrame.UGUI
{
    public class UIDropdown : Dropdown, IEventSender
    {
        #region 事件通知
        [SerializeField]
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

        protected void OnEventTrigger()
        {
            Wnd.SendEvent(this, m_Event.name, m_Event.param);
        }
        #endregion

        private void doValueChanged(int index)
        {
            OnEventTrigger();
        }

        protected override void Awake()
        {
            base.Awake();
            onValueChanged.AddListener(doValueChanged);
        }
    }
}
