using UnityEngine;
using UnityEngine.UI;
using System.Collections;
using System.Collections.Generic;

namespace ZFrame.UGUI
{
    public class LogViewer : MonoSingleton<LogViewer>
    {
        // 顺序不能变
        private static readonly string[] ColorFmt = {
            "<color=#FF0000><i>{0:D3}$</i> {1}\n{2}</color>", // Error
		    "<color=#FF00FF><i>{0:D3}$</i> {1}\n{2}</color>", // Assert
		    "<color=#FFFF00><i>{0:D3}$</i> {1}</color>", // Warning
		    "<i>{0:D3}$</i> {1}", // Log
		    "<color=#FF00FF><i>{0:D3}$</i> {1}\n{2}</color>", //Exception
        };

        public GameObject root;
        public int Kcapacity = 8;

        private ScrollRect scrollRect;
        private System.Text.StringBuilder logBuilder;
        private Text m_LogContent;
        private int counting;
        private int hasUpdate;

        private GameObject entText;
        private List<GameObject> listText = new List<GameObject>();

        protected override void Awaking()
        {
            Application.logMessageReceived += logMessageReceived;

            scrollRect = GetComponentInChildren<ScrollRect>();
            logBuilder = new System.Text.StringBuilder(1024 * Kcapacity);
            counting = 0;
            hasUpdate = 0;

            entText = scrollRect.content.GetChild(0).gameObject;
            entText.SetActive(false);
            GameObject newText = GoTools.NewChild(scrollRect.content.gameObject, entText);
            newText.name = "entText1";
            newText.SetActive(true);
            m_LogContent = newText.GetComponent<Text>();
            listText.Add(newText);
        }

        private void Start()
        {
            ((Dropdown)GetComponentInChildren(typeof(Dropdown))).value = (int)LogMgr.logLevel;
            root.SetActive(false);
        }

        private void OnDestroy()
        {
            Application.logMessageReceived -= logMessageReceived;
        }

        private void ShowContent()
        {
            root.SetActive(true);
            hasUpdate = 1;
        }

        private bool multiTouched = false;
        private Vector2 m_TouchBegan, m_TouchEnd;
        /// <summary>
        /// 手势：三个手指同时向下或向上滑动
        /// </summary>
        private void processTouch()
        {
            if (multiTouched) {
                if (Input.touchCount > 0) {
                    var touch = Input.GetTouch(0);
                    if (touch.phase == TouchPhase.Ended) {
                        m_TouchEnd = touch.position;
                    }
                } else {
                    var vector = m_TouchEnd - m_TouchBegan;
                    var distance = vector.magnitude;
                    if (distance > 100) {
                        var dot = Vector3.Dot(Vector3.up, vector.normalized);
                        if (dot < -0.8f) {
                            ShowContent();
                        } else if (dot > 0.8f) {
                            root.SetActive(false);
                        }
                    }
                    multiTouched = false;
                }
            } else if (Input.touchCount == 3) {
                multiTouched = true;
                m_TouchBegan = Input.GetTouch(0).position;
            }
        }

        private void LateUpdate()
        {
            if (hasUpdate > 0 && root.activeSelf) {
                m_LogContent.text = logBuilder.ToString();
            }
            if (hasUpdate == 0) {
                scrollRect.verticalNormalizedPosition = 0;
            }

            hasUpdate -= 1;

#if UNITY_EDITOR || UNITY_STANDALONE
            if (Input.GetKeyUp(KeyCode.Tab)) {
                if (root.activeSelf) {
                    root.SetActive(false);
                } else {
                    ShowContent();
                }
            }
            processTouch();
#elif UNITY_IOS || UNITY_ANDROID
            processTouch();
#endif
        }

        private void logMessageReceived(string condition, string stackTrace, LogType logType)
        {
            counting += 1;
            string toAppend = null;
            switch (logType) {
                case LogType.Log:
                case LogType.Warning:
                    toAppend = string.Format(ColorFmt[(int)logType], counting, condition);
                    break;
                case LogType.Assert:
                case LogType.Error:
                case LogType.Exception:
                    toAppend = string.Format(ColorFmt[(int)logType], counting, condition, stackTrace);
                    break;
                default:
                    return;
            }
            var logLength = logBuilder.Length + toAppend.Length;
            if (logLength >= logBuilder.Capacity) {
                m_LogContent.text = m_LogContent.text.Remove(m_LogContent.text.Length - 1);
                logBuilder = new System.Text.StringBuilder(Kcapacity * 1024);
                GameObject newText = GoTools.NewChild(scrollRect.content.gameObject, entText);
                newText.name = "entText" + (listText.Count + 1);
                newText.SetActive(true);
                m_LogContent = newText.GetComponent<Text>();
                listText.Add(newText);
            }
            logBuilder.AppendLine(toAppend);
            hasUpdate = 1;
        }

        public void OnLogLevelChanged(int logLevel)
        {
            LogMgr.Instance.SetLevel((LogMgr.LogLevel)logLevel);
        }

        public void OnCmdLineLineClick()
        {
            UIManager.Instance.SendKey(KeyCode.F1);
        }
    }
}
