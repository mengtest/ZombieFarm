using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace World.View
{
    [RequireComponent(typeof(ObjAnim))]
    public class StatusAction : MonoBehaviour, IStatusAnim
    {
        [System.Serializable]
        struct ValueAction
        {
            public int value;
            public string action;
        }

        [SerializeField]
        private string m_Default;

        [SerializeField]
        private ValueAction[] m_Values;

        public void OnStatusChanged(int status)
        {
            var ctrl = (ObjAnim)GetComponent(typeof(ObjAnim));
            if(ctrl.anim) {
                for (int i = 0; i < m_Values.Length; ++i) {
                    if (m_Values[i].value == status) {
                        ctrl.anim.Play(m_Values[i].action);
                        return;
                    }
                }
                ctrl.anim.Play(m_Default);
            }
        }
    }
}
