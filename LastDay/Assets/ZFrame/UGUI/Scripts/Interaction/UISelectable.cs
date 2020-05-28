using UnityEngine;
using UnityEngine.UI;
using UnityEngine.EventSystems;
using System.Collections;

namespace ZFrame.UGUI
{
    public abstract class UISelectable : UIBehaviour
    {
        [SerializeField]
        protected Selectable m_Selectable;

        private bool m_Interactable = true;
        protected bool IsInteractable()
        {
            return m_Selectable ? m_Selectable.IsInteractable() : m_Interactable;
        }

        protected bool IsForwardable()
        {
            return m_Selectable && !m_Selectable.gameObject.Equals(gameObject) 
                && m_Selectable.IsInteractable();
        }

        public bool interactable {
            get { return IsInteractable(); }
            set {
                if (IsInteractable() == value) return;
                
                m_Interactable = value;
                if (m_Selectable) {
                    m_Selectable.interactable = value;
                }

                var state = value ? SelectingState.Normal : SelectingState.Disabled;
                this.TryStateTransition(state, true);
            }
        }

        protected override void Start()
        {
            if (!m_Selectable) m_Selectable = GetComponent<Selectable>();
        }
    }
}
