using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;
using TMPro;

namespace ZFrame.UGUI
{
    [RequireComponent(typeof(TextMeshProUGUI))]
    public sealed class UILink : UIEventTrigger
    {
        private TextMeshProUGUI m_Label;

        protected override void OnEnable()
        {
            base.OnEnable();

            m_Label = GetComponent(typeof(TextMeshProUGUI)) as TextMeshProUGUI;
        }
        
        private int FindLink()
        {
            if (m_Label) {
                var canvas = m_Label.canvas;
                var cam = canvas.renderMode != RenderMode.ScreenSpaceOverlay ? canvas.worldCamera : null;
                return TMP_TextUtilities.FindIntersectingLink(m_Label, Input.mousePosition, cam);
            }
            return -1;
        }

        public override void Execute(TriggerType id, object data)
        {
            var link = FindLink();
            if (link < 0) return;

            var linkId = m_Label.textInfo.linkInfo[link].GetLinkID();
            foreach (var Event in m_Events) {
                if (Event.type == id) {
                    Wnd.SendEvent(this, Event.name, Event.param, linkId);
                    break;
                }
            }

        }
    }
}
