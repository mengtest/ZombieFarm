using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using UnityEditorInternal;

namespace World.View
{
    [CustomEditor(typeof(BodyBroken)), CanEditMultipleObjects]
    public class BodyBrokenEditor : Editor
    {
        private static readonly string[] _BROKEN_JOINTS = {
            "头部", "左手臂", "右手臂", "左腿", "右腿",
        };

        private ReorderableList m_SkinsList, m_BrokenJointsList, m_PartsList, m_AffixesList;
        private SerializedProperty m_Skins, m_BrokenJoints, m_Parts, m_Affixes;

        private void OnEnable()
        {
            m_Skins = serializedObject.FindProperty("m_Skins");
            m_SkinsList = new ReorderableList(serializedObject, m_Skins, false, true, true, true) {
                elementHeight = EditorGUIUtility.singleLineHeight + 2,
                drawHeaderCallback = (rect) => EditorGUI.LabelField(rect, "独立部位（被截断时显示）"),
                drawElementCallback = (rect, index, isActive, isFocused) => {
                    var element = m_Skins.GetArrayElementAtIndex(index);

                    rect.y += 1;
                    rect.height = EditorGUIUtility.singleLineHeight;

                    if (index < _BROKEN_JOINTS.Length) {
                        EditorGUI.PropertyField(rect, element, new GUIContent(_BROKEN_JOINTS[index]));
                    } else {
                        EditorGUI.PropertyField(rect, element, new GUIContent("部位" + index));
                    }
                }
            };

            m_Affixes = serializedObject.FindProperty("m_Affixes");
            m_AffixesList = new ReorderableList(serializedObject, m_Affixes, false, true, true, true) {
                elementHeight = EditorGUIUtility.singleLineHeight + 2,
                drawHeaderCallback = (rect) => EditorGUI.LabelField(rect, "附加部位（被肢解时掉落）"),
                drawElementCallback = (rect, index, isActive, isFocused) => {
                    var element = m_Affixes.GetArrayElementAtIndex(index);

                    rect.y += 1;
                    rect.height = EditorGUIUtility.singleLineHeight;

                    EditorGUI.PropertyField(rect, element, new GUIContent("附件" + index));
                }
            };

            m_BrokenJoints = serializedObject.FindProperty("m_BrokenJoints");
            m_BrokenJointsList = new ReorderableList(serializedObject, m_BrokenJoints, false, true, true, true) {
                elementHeight = EditorGUIUtility.singleLineHeight + 2,
                drawHeaderCallback = (rect) => EditorGUI.LabelField(rect, "断肢节点（被截断时隐藏）"),
                drawElementCallback = (rect, index, isActive, isFocused) => {
                    var element = m_BrokenJoints.GetArrayElementAtIndex(index);

                    rect.y += 1;
                    rect.height = EditorGUIUtility.singleLineHeight;

                    if (index < _BROKEN_JOINTS.Length) {
                        EditorGUI.PropertyField(rect, element, new GUIContent(_BROKEN_JOINTS[index]));
                    } else {
                        EditorGUI.PropertyField(rect, element, new GUIContent("附件" + (index + 1 - _BROKEN_JOINTS.Length)));
                    }
                }
            };

            m_Parts = serializedObject.FindProperty("m_Parts");
            m_PartsList = new ReorderableList(serializedObject, m_Parts, false, true, false, false) {
                elementHeight = EditorGUIUtility.singleLineHeight + 2,
                drawHeaderCallback = (rect) => EditorGUI.LabelField(rect, "合并部位与骨骼信息"),
                drawElementCallback = (rect, index, isActive, isFocused) => {
                    var element = m_Parts.GetArrayElementAtIndex(index);

                    rect.y += 1;
                    rect.height = EditorGUIUtility.singleLineHeight;

                    EditorGUI.BeginDisabledGroup(true);
                    EditorGUI.PropertyField(rect, element.FindPropertyRelative("mesh"),
                        new GUIContent(string.Format("骨骼数={0}", element.FindPropertyRelative("bones").arraySize)));

                    EditorGUI.EndDisabledGroup();
                }
            };
        }

        public override void OnInspectorGUI()
        {
            base.OnInspectorGUI();

            var self = target as BodyBroken;

            EditorGUILayout.Separator();
            m_BrokenJointsList.DoLayoutList();
            m_SkinsList.DoLayoutList();
            m_AffixesList.DoLayoutList();

            var options = new string[m_Parts.arraySize];
            for (int i = 0; i < m_Parts.arraySize; ++i) {
                var elm = m_Parts.GetArrayElementAtIndex(i);
                if (elm != null) {
                    var mesh = elm.FindPropertyRelative("mesh").objectReferenceValue;
                    options[i] = mesh ? mesh.name : "(NULL)";
                } else {
                    options[i] = "(NULL)";
                }
            }

            EditorGUILayout.Separator();
            var smr = EditorGUILayout.ObjectField("拖入添加部位", null, typeof(SkinnedMeshRenderer), true) as SkinnedMeshRenderer;
            if (smr) {
                self.AddPart(smr);
            }
            m_PartsList.DoLayoutList();

            var upperMask = serializedObject.FindProperty("m_UpperMask");
            upperMask.intValue = EditorGUILayout.MaskField("上半身部位", upperMask.intValue, options);

            serializedObject.ApplyModifiedProperties();

        }
    }
}
