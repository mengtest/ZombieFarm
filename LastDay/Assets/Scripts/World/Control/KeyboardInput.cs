//
//  KeyboardInput.cs
//  survive
//
//  Created by xingweizhen on 10/17/2017.
//
//

using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.EventSystems;
using ZFrame;
using ZFrame.UGUI;

namespace World.Control
{
    using View;

    public class KeyboardInput : MonoSingleton<KeyboardInput>
    {
        private Vector3 m_Direction;
        private Vector3[] m_Vectors = new Vector3[4];
        private bool m_MoveDirty;
        private UIWindow m_Wnd;
        
        private void OnEnable()
        {
            m_Direction = Vector3.zero;
            m_MoveDirty = false;
        }

        private void Awake()
        {
            StageView.L.onActionBreak += OnActionDone;
            StageView.L.onActionSuccess += OnActionDone;
            StageView.L.onActionFinish += OnActionDone;
        }

        private void Start()
        {
            m_Wnd = UIWindow.FindByName("FRMExplore");

        }

        private void OnDestroy()
        {
            if (StageView.L != null) {
                StageView.L.onActionBreak -= OnActionDone;
                StageView.L.onActionSuccess -= OnActionDone;
                StageView.L.onActionFinish -= OnActionDone;
            }
        }

        private void OnActionDone(IObj obj, IEventParam param)
        {
            if (Equals(obj, StageCtrl.P)) {
                if (m_Direction != Vector3.zero) {
                    StageCtrl.P.Move(m_Direction, true);
                }
            }
        }

        private void OnMoveInput()
        {
            var direction = m_Direction;
            if (Input.GetKeyDown(KeyCode.W)) {
                m_Vectors[0] = Vector3.forward;
                m_Vectors[2] = Vector3.zero;
                m_MoveDirty = true;
            }
            if (Input.GetKeyDown(KeyCode.A)) {
                m_Vectors[1] = Vector3.left;
                m_Vectors[3] = Vector3.zero;
                m_MoveDirty = true;
            }
            if (Input.GetKeyDown(KeyCode.S)) {
                m_Vectors[2] = Vector3.back;
                m_Vectors[0] = Vector3.zero;
                m_MoveDirty = true;
            }
            if (Input.GetKeyDown(KeyCode.D)) {
                m_Vectors[3] = Vector3.right;
                m_Vectors[1] = Vector3.zero;
                m_MoveDirty = true;
            }

            // Up
            if (Input.GetKeyUp(KeyCode.W)) {
                m_Vectors[0] = Vector3.zero;
                m_MoveDirty = true;
            }
            if (Input.GetKeyUp(KeyCode.A)) {
                m_Vectors[1] = Vector3.zero;
                m_MoveDirty = true;
            }
            if (Input.GetKeyUp(KeyCode.S)) {
                m_Vectors[2] = Vector3.zero;
                m_MoveDirty = true;
            }
            if (Input.GetKeyUp(KeyCode.D)) {
                m_Vectors[3] = Vector3.zero;
                m_MoveDirty = true;
            }

            if (m_MoveDirty) {
                m_MoveDirty = false;

                m_Direction = Vector3.zero;
                foreach (var v in m_Vectors) {
                    m_Direction += v;
                }

                if (m_Direction != Vector3.zero) {
                    m_Direction.Normalize();
                }

                if (m_Direction != direction && StageCtrl.P != null) {
                    if (m_Direction != Vector3.zero) {
                        var view = StageCtrl.P.view as RoleView;
                        if (view != null) {
                            var euler = StageView.Instance.mainCam.transform.eulerAngles;
                            var rot = Quaternion.Euler(0, euler.y, 0);
                            view.forward = rot * m_Direction;
                        }

                        StageCtrl.P.Move(m_Direction, true);
                    } else {
                        StageCtrl.P.Stay(true);
                    }
                }
            }
        }

        private void ClickButton(string btnPath)
        {
            var btn = m_Wnd.transform.Find(btnPath).GetComponent(typeof(UIButton)) as UIButton;
            if (btn && btn.isActiveAndEnabled && btn.IsInteractable()) {
                btn.gameObject.SendMessage("OnEventTrigger", new PointerEventData(EventSystem.current));
            }
        }

        private void SendEvent(string evtPath, TriggerType triggerId)
        {
            var evt = m_Wnd.transform.Find(evtPath).GetComponent(typeof(UIEventTrigger)) as UIEventTrigger;
            if (evt.isActiveAndEnabled && evt.interactable) {
                evt.Execute(triggerId, null);
            }
        }

        private void OnActionInput()
        {
            if (Input.GetKeyUp(KeyCode.L)) {
                var tgl = m_Wnd.transform.Find("tglSneak").GetComponent(typeof(UIToggle)) as UIToggle;
                if (tgl.IsInteractable()) {
                    tgl.value = !tgl.value;
                    m_MoveDirty = true;
                }
            } else if (Input.GetKeyDown(KeyCode.K)) {
                SendEvent("SubMajor", TriggerType.PointerDown);
            } else if (Input.GetKeyUp(KeyCode.K)) {
                SendEvent("SubMajor", TriggerType.PointerUp);
            } else if (Input.GetKeyDown(KeyCode.J)) {
                SendEvent("SubMinor", TriggerType.PointerDown);
            } else if (Input.GetKeyUp(KeyCode.J)) {
                SendEvent("SubMinor", TriggerType.PointerUp);
            } else if (Input.GetKeyUp(KeyCode.U)) {
                SendEvent("SubLPocket", TriggerType.PointerClick);
            } else if (Input.GetKeyUp(KeyCode.I)) {
                SendEvent("SubRPocket", TriggerType.PointerClick);
            } else if (Input.GetKeyUp(KeyCode.Q) || Input.GetKeyUp(KeyCode.O)) {
                ClickButton("SubSwitch");
            } else if (Input.GetKeyUp(KeyCode.R)) {
                ClickButton("SubReload");
            } else if (Input.GetKeyUp(KeyCode.M)) {
                MiniMap.Instance.ToggleMapScale();
            //} else if (Input.GetKeyUp(KeyCode.Z)) {
            //    ClickButton("SubFuncs/btnMall");            
            //} else if (Input.GetKeyUp(KeyCode.C)) {
            //    ClickButton("SubFuncs/btnCraft");
            //} else if (Input.GetKeyUp(KeyCode.V)) {
            //    ClickButton("SubFuncs/btnRole");
            }

        }

        private void Update()
        {
            if (!StageView.Instance.IsUIVisible()) return;

            var selected = EventSystem.current.currentSelectedGameObject;
            if (selected && selected.activeInHierarchy) {
                if (selected.GetComponent(typeof(UIInputField)) || 
                    selected.GetComponent(typeof(InputField))) {
                    return;
                }
            }
                
            OnMoveInput();
            OnActionInput();
        }
    }
}
