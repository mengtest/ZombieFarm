using UnityEditor;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using World.View;
using TextEditor = UnityEditor.UI.TextEditor;

namespace ZFrame.UGUI
{
    [CustomEditor(typeof(UILabel))]
    [CanEditMultipleObjects]
    public class UILabelEditor : TextEditor
    {
        private static string[] m_LocKeys;
        //private static List<string> m_Results = new List<string>();
        private List<string> m_AutoKeys = new List<string>();

        private SerializedProperty textFormat, localize, omit, m_RawText, m_Text, m_bNoBreakSpace;

        protected override void OnEnable()
        {
            if (m_LocKeys == null) {
                m_LocKeys = UILabel.LOC.GetKeys();
            }

            m_AutoKeys.Clear();

            base.OnEnable();
            omit = serializedObject.FindProperty("omit");
            textFormat = serializedObject.FindProperty("textFormat");
            localize = serializedObject.FindProperty("m_Localized");
            m_RawText = serializedObject.FindProperty("m_RawText");
            m_Text = serializedObject.FindProperty("m_Text");
            m_bNoBreakSpace = serializedObject.FindProperty("m_bNoBreakSpace");
        }

        public override void OnInspectorGUI()
        {
            var self = (UILabel)target;
            var cachedFont = self.font;
            var locText = m_Text.stringValue;
            
            base.OnInspectorGUI();
            
            EditorGUILayout.Separator();
            EditorGUILayout.LabelField("Extern Properties", EditorStyles.boldLabel);
            EditorGUILayout.PropertyField(m_bNoBreakSpace);
            EditorGUILayout.PropertyField(omit);
            EditorGUILayout.PropertyField(textFormat);
            EditorGUILayout.PropertyField(localize);

            if (localize.boolValue) {
                if (locText != m_Text.stringValue) m_AutoKeys.Clear();
                if (m_AutoKeys.Count == 0 && !m_AutoKeys.Contains(m_Text.stringValue)) {
                    using (var itor = UILabel.LOC.Find(self.text, UGUITools.settings.defaultLang)) {
                        while (itor.MoveNext()) m_AutoKeys.Add(itor.Current);
                    }
                }

                EditorGUILayout.PropertyField(m_RawText);
                if (m_AutoKeys.Count > 0 && !m_AutoKeys.Contains(m_RawText.stringValue)) {
                    EditorGUI.indentLevel++;
                    EditorGUILayout.LabelField("已存在的键");
                    foreach (var key in m_AutoKeys) {
                        EditorGUILayout.BeginHorizontal();
                        EditorGUILayout.LabelField(key);
                        if (GUILayout.Button("*", EditorStyles.miniButton, GUILayout.ExpandWidth(false))) {
                            m_RawText.stringValue = key;
                        }
                        EditorGUILayout.EndHorizontal();
                    }
                    EditorGUI.indentLevel--;
                }
            }

//            var rawText = m_RawText.stringValue;
//            if (!string.IsNullOrEmpty(rawText) && rawText != search) {
//                var lowerSearch = rawText.ToLower();
//                var strbld = new System.Text.StringBuilder();
//                m_Results.Clear();
//                var defLang = UGUITools.settings.defaultLang;
//                using (var itor = UILabel.LOC.GetIterator(defLang)) {
//                    while (itor.MoveNext()) {
//                        string key = itor.Current.key, value = itor.Current.value;
//                        var lowerK = key.ToLower();
//                        var lowerV = value.ToLower();
//                        if (lowerK.Contains(lowerSearch) || lowerV.Contains(lowerSearch)) {
//                            var line = string.Format("{0}|{1}", key, value);
//                            line.re
//                            strbld.Append()
//                        }
//                    }
//                }
//                foreach (var k in m_LocKeys) {
//                    var lower = k.ToLower();
//                    if (lower.Contains(lowerSearch)) {
//                        m_Results.Add(string.Format("{0}|{1}", k, loc.Get(k, defLang)));
//                        if (m_Results.Count > 5) {
//                            m_Results.Add("...");
//                            break;
//                        }
//                    }
//                }
            //}
            //foreach (var result in m_Results) EditorGUILayout.LabelField(result);
            
            serializedObject.ApplyModifiedProperties();

            if (cachedFont != self.font) {
                UGUITools.lastSelectedFont = self.font;
            }
        }
    }
}
