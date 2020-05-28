using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

namespace World
{
    [CustomEditor(typeof(MapData))]
    public class MapDataEditor : Editor
    {
        public override void OnInspectorGUI()
        {
            var map = target as MapData;
            var asset = EditorGUILayout.ObjectField("导入", null, typeof(TextAsset), false);
            if (asset != null) {
                map.ReadFromCSV(new System.IO.StringReader(asset.ToString()));
            }
            
            EditorGUILayout.LabelField("大小", string.Format("{0}x{1}", map.width, map.height));
            
            serializedObject.ApplyModifiedProperties();
        }
    }
}
