using UnityEngine;
using UnityEditor;
using UnityEditor.UI;
using System.Collections;

namespace ZFrame.UGUI
{
    using Asset;
    [CustomEditor(typeof(UITexture)), CanEditMultipleObjects]
    public class UITextureEditor : RawImageEditor
    {
        private SerializedProperty m_TexPath;

        protected override void OnEnable()
        {
            base.OnEnable();

            m_TexPath = serializedObject.FindProperty("m_TexPath");
        }

        public override void OnInspectorGUI()
        {
            var self = target as UITexture;
            var tex = self.texture;

            base.OnInspectorGUI();

            EditorGUILayout.PropertyField(serializedObject.FindProperty("m_Type"), new GUIContent("Image Type"));

            if (tex != self.texture) {
                if (self.texture) {
                    var ti = AssetImporter.GetAtPath(AssetDatabase.GetAssetPath(self.texture)) as TextureImporter;
                    if (string.IsNullOrEmpty(ti.assetBundleName)) {
                        m_TexPath.stringValue = null;
                    } else {
                        var assetPath = string.Concat(ti.assetBundleName, "/", self.texture.name);
                        m_TexPath.stringValue = assetPath;
                    }
                } else {
                    m_TexPath.stringValue = null;
                }
            }
            
            EditorGUI.BeginDisabledGroup(true);
            EditorGUILayout.PropertyField(m_TexPath);
            EditorGUI.EndDisabledGroup();

            serializedObject.ApplyModifiedProperties();
        }
    }
}
