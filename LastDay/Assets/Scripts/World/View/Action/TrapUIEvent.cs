using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using ZFrame.UGUI;

namespace World.View
{
    public class TrapUIEvent : TrapTrigger
    {
        [SerializeField]
        private EventData m_Event = new EventData(TriggerType.None);

        protected override void OnTrapEnter(Collider other)
        {
            LuaComponent.SendUIEvent(null, this, m_Event.name, m_Event.param);
        }

        protected override void OnTrapExit(Collider other)
        {
            LuaComponent.SendUIEvent(null, this, UIEvent.Close, null);
        }
    }
}
