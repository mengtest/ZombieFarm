using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System.IO;

namespace World.View
{
    [CustomEditor(typeof(SkinAtlas))]
    public class SkinAtlasEditor : Editor
    {
        private SerializedProperty m_SkinTex;

        [System.Serializable]
        private struct Frame { public int x, y, w, h; }
        [System.Serializable]
        private struct Size { public int w, h; }
        [System.Serializable]
        private struct FrameData
        {
            public string filename;
            public Frame frame, spriteSourceSize;
            public Size sourceSize;
            public bool rotated, trimmed;
        }
        [System.Serializable]
        private struct MetaData {
            public Size size;
        }
        [System.Serializable]
        private class FrameList
        {
            public List<FrameData> frames;
            public MetaData meta;
        }

        private void OnEnable()
        {
            m_SkinTex = serializedObject.FindProperty("m_SkinTex");
        }

        public override void OnInspectorGUI()
        {
            DrawDefaultInspector();
            var atlas = (SkinAtlas)target;

            var json = EditorGUILayout.ObjectField("Drag Json Array", null, typeof(TextAsset), false) as TextAsset;
            if (json != null) {
                var spList = JsonUtility.FromJson(json.text, typeof(FrameList)) as FrameList;
                atlas.Skins.Clear();
                float width = spList.meta.size.h;
                float height = spList.meta.size.w;
                foreach (var elm in spList.frames) {
                    var name = Path.GetFileNameWithoutExtension(elm.filename);
                    var frame = elm.frame;
                    float x = frame.x / width, y = frame.y / height;
                    float w = frame.w / width, h = frame.h / height;
                    atlas.Skins.Add(new SkinAtlas.SkinTex(name, new Rect(
                        x, 1 - y - h,
                        w, h)));
                }
            }
            EditorGUILayout.PropertyField(m_SkinTex);            
            //EditorGUILayout.PropertyField(m_List, true);

            //for (int i = 0; i < m_List.arraySize; ++i) {
            //    var elm = m_List.GetArrayElementAtIndex(i);
            //    EditorGUILayout.PropertyField(elm, true);
            //}

            serializedObject.ApplyModifiedProperties();
        }
    }

}
