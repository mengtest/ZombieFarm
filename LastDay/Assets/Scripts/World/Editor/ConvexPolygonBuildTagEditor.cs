using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

namespace World.View
{
    [CustomEditor(typeof(ConvexPolygonBuildTag), true)]
    public class ConvexPolygonBuildTagEditor : Editor
    {
        private void OnSceneGUI()
        {
            var defMatrix = Handles.matrix;
            var defColor = Handles.color;

            var self = target as ConvexPolygonBuildTag;

            if (self.points.Length > 2) {
                Handles.matrix = self.transform.localToWorldMatrix;

                for (int i = 0; i < self.points.Length; ++i) {
                    var point = self.points[i];

                    var n = (i + 1) % self.points.Length;
                    Handles.color = Color.cyan;
                    Handles.DrawDottedLine(point, self.points[n], 10f);

                    Handles.color = Color.yellow;
                    var siz = HandleUtility.GetHandleSize(point) * 0.2f;
                    EditorGUI.BeginChangeCheck();
                    point = Handles.FreeMoveHandle(point, Quaternion.identity, siz, Vector3.one, Handles.CubeHandleCap);
                    if (EditorGUI.EndChangeCheck()) {
                        Undo.RecordObject(self, "Reed:Modify" + i);
                        point.x = Mathf.Round(point.x * 100f) / 100f;
                        point.z = Mathf.Round(point.z * 100f) / 100f;
                        point.y = 0;
                        self.points[i] = point;
                    }

                    Handles.Label(point, i.ToString());
                }
            }

            Handles.color = defColor;
            Handles.matrix = defMatrix;
        }
    }
}
