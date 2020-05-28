using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using UnityEditorInternal;
using TinyJSON;
using System.IO;

namespace World.View
{
    [CustomEditor(typeof(StageEdit)), CanEditMultipleObjects]
    public class StageEditEditor : Editor
    {
        private static int m_SelGrid = 0;
        private static int m_MaskView = 0;

        private static readonly string[] Names = { "障碍物", "空气墙", "怪物", "入口", "刷怪点", "巡逻路", "出口" };

        private SerializedProperty m_Size;

        private class DataList
        {
            public string name { get; private set; }
            public bool show { get; private set; }
            public int index;
            public SerializedProperty prop { get; private set; }
            public ReorderableList list { get; private set; }

            public DataList(SerializedObject serializedObject, string property, string name)
            {
                prop = serializedObject.FindProperty(property);
                list = new ReorderableList(serializedObject, prop, true, true, true, true);
                this.name = name;
                index = -1;
                show = true;
            }

            public void DoEditor()
            {
                show = EditorGUILayout.ToggleLeft(name, show);
                if (show) list.DoLayoutList();
            }
        }

        private DataList blocks, walls, npcs, ents, spawners, patrols, exits;
        private List<DataList> m_DataLists;
        private string[] m_DataNames;

        private void OnEnable()
        {
            SceneView.onSceneGUIDelegate += OnSceneViewGUI;
            m_Size = serializedObject.FindProperty("m_Size");

            #region 障碍物
            blocks = new DataList(serializedObject, "m_Blocks", "障碍物");
            blocks.list.elementHeight = EditorGUIUtility.singleLineHeight + 2;
            blocks.list.drawHeaderCallback = (rect) => {
                var padding = 43;
                var width = rect.width - padding - 60;
                var pos = new Rect(rect.x + padding, rect.y, width / 2 - 10, rect.height);
                EditorGUI.LabelField(pos, "坐标", EditorStyles.miniButtonMid);
                pos.x += width / 2;
                EditorGUI.LabelField(pos, "大小", EditorStyles.miniButtonMid);

                pos.x += width / 2; pos.width = 60;
                EditorGUI.LabelField(pos, "等级", EditorStyles.miniButtonMid);
            };
            blocks.list.drawElementCallback = (rect, index, isActive, isFocused) => {
                var element = blocks.prop.GetArrayElementAtIndex(index);

                rect.y += 2;
                rect.height = EditorGUIUtility.singleLineHeight;
                using (new EditorGUI.PropertyScope(rect, null, element)) {
                    var padding = 30;
                    EditorGUI.LabelField(new Rect(rect.x, rect.y, padding, rect.height), index.ToString());

                    var width = rect.width - padding - 80;
                    var pos = new Rect(rect.x + padding, rect.y, width / 4, EditorGUIUtility.singleLineHeight);
                    EditorGUI.PropertyField(pos, element.FindPropertyRelative("start.x"), GUIContent.none);

                    pos.x += width / 4;
                    EditorGUI.PropertyField(pos, element.FindPropertyRelative("start.y"), GUIContent.none);

                    pos.x += width / 4 + 10;
                    EditorGUI.PropertyField(pos, element.FindPropertyRelative("size.x"), GUIContent.none);

                    pos.x += width / 4;
                    EditorGUI.PropertyField(pos, element.FindPropertyRelative("size.y"), GUIContent.none);

                    pos.x += width / 4 + 10; pos.width = 60;
                    EditorGUI.PropertyField(pos, element.FindPropertyRelative("blockLevel"), GUIContent.none);
                }
            };
            blocks.list.onSelectCallback = (list) => {
                OnDataSelect(blocks);
            };
            #endregion

            #region 空气墙
            walls = new DataList(serializedObject, "m_Walls", "空气墙");
            walls.list.elementHeight = EditorGUIUtility.singleLineHeight + 2;
            walls.list.drawHeaderCallback = (rect) => {
                var padding = 43;
                var width = rect.width - padding - 60;
                var pos = new Rect(rect.x + padding, rect.y, width / 2 - 10, rect.height);
                EditorGUI.LabelField(pos, "起点", EditorStyles.miniButtonMid);
                pos.x += width / 2;
                EditorGUI.LabelField(pos, "终点", EditorStyles.miniButtonMid);

                pos.x += width / 2; pos.width = 60;
                EditorGUI.LabelField(pos, "等级", EditorStyles.miniButtonMid);

            };
            walls.list.drawElementCallback = (rect, index, isActive, isFocused) => {
                var element = walls.prop.GetArrayElementAtIndex(index);

                rect.y += 2;
                rect.height = EditorGUIUtility.singleLineHeight;
                using (new EditorGUI.PropertyScope(rect, null, element)) {
                    var padding = 30;
                    EditorGUI.LabelField(new Rect(rect.x, rect.y, padding, rect.height), index.ToString());

                    var width = rect.width - padding - 80;
                    var pos = new Rect(rect.x + padding, rect.y, width / 4, EditorGUIUtility.singleLineHeight);
                    EditorGUI.PropertyField(pos, element.FindPropertyRelative("start.x"), GUIContent.none);

                    pos.x += width / 4;
                    EditorGUI.PropertyField(pos, element.FindPropertyRelative("start.y"), GUIContent.none);

                    pos.x += width / 4 + 10;
                    EditorGUI.PropertyField(pos, element.FindPropertyRelative("end.x"), GUIContent.none);

                    pos.x += width / 4;
                    EditorGUI.PropertyField(pos, element.FindPropertyRelative("end.y"), GUIContent.none);

                    pos.x += width / 4 + 10; pos.width = 60;
                    EditorGUI.PropertyField(pos, element.FindPropertyRelative("blockLevel"), GUIContent.none);
                }
            };
            walls.list.onSelectCallback = (list) => {
                OnDataSelect(walls);
            };
            #endregion

            #region 怪物
            npcs = new DataList(serializedObject, "m_Npcs", "怪物");
            npcs.list.elementHeight = EditorGUIUtility.singleLineHeight + 2;
            npcs.list.drawHeaderCallback = (rect) => {
                var padding = 43;
                var width = rect.width - padding - 30;
                var pos = new Rect(rect.x + padding, rect.y, width / 2, rect.height);
                EditorGUI.LabelField(pos, "坐标", EditorStyles.miniButtonMid);
                pos.x += width / 2 + 15; pos.width = width / 4;
                EditorGUI.LabelField(pos, "角度", EditorStyles.miniButtonMid);
                pos.x += width / 4 + 15;
                EditorGUI.LabelField(pos, "编号", EditorStyles.miniButtonMid);

            };
            npcs.list.drawElementCallback = (rect, index, isActive, isFocused) => {
                var element = npcs.prop.GetArrayElementAtIndex(index);

                rect.y += 2;
                rect.height = EditorGUIUtility.singleLineHeight;
                using (new EditorGUI.PropertyScope(rect, null, element)) {
                    var padding = 30;
                    EditorGUI.LabelField(new Rect(rect.x, rect.y, padding, rect.height), index.ToString());

                    var width = rect.width - padding - 30;
                    var pos = new Rect(rect.x + padding, rect.y, width / 4, EditorGUIUtility.singleLineHeight);
                    EditorGUI.PropertyField(pos, element.FindPropertyRelative("coord.x"), GUIContent.none);
                    pos.x += width / 4;
                    EditorGUI.PropertyField(pos, element.FindPropertyRelative("coord.y"), GUIContent.none);

                    pos.x += width / 4 + 15;
                    EditorGUI.PropertyField(pos, element.FindPropertyRelative("angle"), GUIContent.none);

                    pos.x += width / 4 + 15;
                    EditorGUI.PropertyField(pos, element.FindPropertyRelative("id"), GUIContent.none);

                }
            };
            npcs.list.onSelectCallback = (list) => {
                OnDataSelect(npcs);
            };
            #endregion

            #region 入口
            ents = new DataList(serializedObject, "m_Ents", "入口");
            ents.list.elementHeight = EditorGUIUtility.singleLineHeight + 2;
            ents.list.drawHeaderCallback = (rect) => {
                var padding = 43;
                var width = rect.width - padding - 60;
                var pos = new Rect(rect.x + padding, rect.y, width / 2, rect.height);
                EditorGUI.LabelField(pos, "坐标", EditorStyles.miniButtonMid);
                pos.x += width / 2 + 15;
                EditorGUI.LabelField(pos, "参数", EditorStyles.miniButtonMid);
                pos.x += width / 2 + 15;
                pos.width = 30;
                EditorGUI.LabelField(pos, "角度", EditorStyles.miniButtonMid);

            };
            ents.list.drawElementCallback = (rect, index, isActive, isFocused) => {
                var element = ents.prop.GetArrayElementAtIndex(index);

                rect.y += 2;
                rect.height = EditorGUIUtility.singleLineHeight;
                using (new EditorGUI.PropertyScope(rect, null, element)) {
                    var padding = 30;
                    EditorGUI.LabelField(new Rect(rect.x, rect.y, padding, rect.height), index.ToString());

                    var width = rect.width - padding - 60;

                    // 中心位置
                    var pos = new Rect(rect.x + padding, rect.y, width / 4, EditorGUIUtility.singleLineHeight);
                    EditorGUI.PropertyField(pos, element.FindPropertyRelative("coord.x"), GUIContent.none);

                    pos.x += width / 4;
                    EditorGUI.PropertyField(pos, element.FindPropertyRelative("coord.y"), GUIContent.none);

                    pos.x += width / 4 + 15;
                    EditorGUI.PropertyField(pos, element.FindPropertyRelative("param.x"), GUIContent.none);

                    pos.x += width / 4;
                    EditorGUI.PropertyField(pos, element.FindPropertyRelative("param.y"), GUIContent.none);

                    pos.x += width / 4 + 15;
                    pos.width = 30;
                    EditorGUI.PropertyField(pos, element.FindPropertyRelative("angle"), GUIContent.none);
                }
            };
            ents.list.onSelectCallback = (list) => {
                OnDataSelect(ents);
            };
            #endregion

            #region 刷怪点
            spawners = new DataList(serializedObject, "m_Spawners", "刷怪点");
            spawners.list.elementHeight = (EditorGUIUtility.singleLineHeight + 2) * 3 + 2;
            spawners.list.drawHeaderCallback = (rect) => {
                var padding = 73;
                var width = rect.width - padding - 20;
                var pos = new Rect(rect.x + padding, rect.y, width / 2, rect.height);
                EditorGUI.LabelField(pos, "坐标", EditorStyles.miniButtonMid);
                pos.x += width / 2 + 20;
                EditorGUI.LabelField(pos, "参数", EditorStyles.miniButtonMid);

            };
            spawners.list.drawElementCallback = (rect, index, isActive, isFocused) => {
                var element = spawners.prop.GetArrayElementAtIndex(index);

                rect.y += 4;
                rect.height = EditorGUIUtility.singleLineHeight;
                using (new EditorGUI.PropertyScope(rect, null, element)) {
                    var padding = 30;
                    var width = rect.width - padding - 30 - 20;

                    EditorGUI.LabelField(new Rect(rect.x, rect.y, padding, rect.height), index.ToString());

                    // 刷新点数据
                    EditorGUI.LabelField(new Rect(rect.x + padding, rect.y, padding, rect.height), "刷新");

                    var pos = new Rect(rect.x + padding + 30, rect.y, width / 4, EditorGUIUtility.singleLineHeight);
                    EditorGUI.PropertyField(pos, element.FindPropertyRelative("source.coord.x"), GUIContent.none);

                    pos.x += width / 4;
                    EditorGUI.PropertyField(pos, element.FindPropertyRelative("source.coord.y"), GUIContent.none);

                    pos.x += width / 4 + 20;
                    EditorGUI.PropertyField(pos, element.FindPropertyRelative("source.param.x"), GUIContent.none);

                    pos.x += width / 4;
                    EditorGUI.PropertyField(pos, element.FindPropertyRelative("source.param.y"), GUIContent.none);

                    // 聚集点数据
                    rect.y += EditorGUIUtility.singleLineHeight + 2;
                    EditorGUI.LabelField(new Rect(rect.x + padding, rect.y, padding, rect.height), "聚集");

                    pos = new Rect(rect.x + padding + 30, rect.y, width / 4, EditorGUIUtility.singleLineHeight);
                    EditorGUI.PropertyField(pos, element.FindPropertyRelative("destina.coord.x"), GUIContent.none);

                    pos.x += width / 4;
                    EditorGUI.PropertyField(pos, element.FindPropertyRelative("destina.coord.y"), GUIContent.none);

                    pos.x += width / 4 + 20;
                    EditorGUI.PropertyField(pos, element.FindPropertyRelative("destina.param.x"), GUIContent.none);

                    pos.x += width / 4;
                    EditorGUI.PropertyField(pos, element.FindPropertyRelative("destina.param.y"), GUIContent.none);

                    // 刷怪数据
                    width = rect.width - padding - 20;
                    rect.y += EditorGUIUtility.singleLineHeight + 2;
                    pos = new Rect(rect.x + padding, rect.y, 30, EditorGUIUtility.singleLineHeight);

                    EditorGUI.LabelField(pos, "编号");
                    pos.x += 30; pos.width = width / 3 - 30;
                    EditorGUI.PropertyField(pos, element.FindPropertyRelative("id"), GUIContent.none);

                    pos.x += width / 3 - 20; pos.width = 30;
                    EditorGUI.LabelField(pos, "初始");
                    pos.x += 30; pos.width = width / 3 - 30;
                    EditorGUI.PropertyField(pos, element.FindPropertyRelative("nInit"), GUIContent.none);

                    pos.x += width / 3 - 20; pos.width = 30;
                    EditorGUI.LabelField(pos, "最小");
                    pos.x += 30; pos.width = width / 3 - 30;
                    EditorGUI.PropertyField(pos, element.FindPropertyRelative("nMin"), GUIContent.none);
                }
            };
            spawners.list.onSelectCallback = (list) => {
                OnDataSelect(spawners);
            };
            #endregion

            #region 巡逻路径
            patrols = new DataList(serializedObject, "m_PatrolPaths", "巡逻路");
            patrols.list.elementHeight = EditorGUIUtility.singleLineHeight + 2;
            patrols.list.drawHeaderCallback = (rect) => {

            };
            patrols.list.drawElementCallback = (rect, index, isActive, isFocused) => {
                var element = patrols.prop.GetArrayElementAtIndex(index);
                rect.y += 2;
                rect.height = EditorGUIUtility.singleLineHeight;
                using (new EditorGUI.PropertyScope(rect, null, element)) {
                    var totalWidth = rect.width;
                    rect.width = 10;
                    EditorGUI.LabelField(rect, "#");

                    rect.x += rect.width;
                    rect.width = totalWidth / 4 - 20;
                    EditorGUI.PropertyField(rect, element.FindPropertyRelative("id"), GUIContent.none);

                    rect.x += rect.width + 10;
                    rect.width = totalWidth / 2 - 10;
                    EditorGUI.PropertyField(rect, element.FindPropertyRelative("mode"), GUIContent.none);

                    rect.x += rect.width + 10;
                    rect.width = totalWidth / 4 - 10;
                    EditorGUI.LabelField(rect, string.Format("{0}个路点", element.FindPropertyRelative("points").arraySize));
                }
            };
            patrols.list.onSelectCallback = (list) => OnDataSelect(patrols);

            #endregion

            #region 出口
            exits = new DataList(serializedObject, "m_Exits", "出口");
            exits.list.elementHeight = EditorGUIUtility.singleLineHeight + 2;
            exits.list.drawHeaderCallback = (rect) => {
                var padding = 43;
                var width = rect.width - padding - 20;
                var pos = new Rect(rect.x + padding, rect.y, width / 2, rect.height);
                EditorGUI.LabelField(pos, "坐标", EditorStyles.miniButtonMid);
                pos.x += width / 2 + 20;
                EditorGUI.LabelField(pos, "参数", EditorStyles.miniButtonMid);

            };
            exits.list.drawElementCallback = (rect, index, isActive, isFocused) => {
                var element = exits.prop.GetArrayElementAtIndex(index);

                rect.y += 2;
                rect.height = EditorGUIUtility.singleLineHeight;
                using (new EditorGUI.PropertyScope(rect, null, element)) {
                    var padding = 30;
                    EditorGUI.LabelField(new Rect(rect.x, rect.y, padding, rect.height), index.ToString());

                    var width = rect.width - padding - 20;

                    // 中心位置
                    var pos = new Rect(rect.x + padding, rect.y, width / 4, EditorGUIUtility.singleLineHeight);
                    EditorGUI.PropertyField(pos, element.FindPropertyRelative("coord.x"), GUIContent.none);

                    pos.x += width / 4;
                    EditorGUI.PropertyField(pos, element.FindPropertyRelative("coord.y"), GUIContent.none);

                    pos.x += width / 4 + 20;
                    EditorGUI.PropertyField(pos, element.FindPropertyRelative("param.x"), GUIContent.none);

                    pos.x += width / 4;
                    EditorGUI.PropertyField(pos, element.FindPropertyRelative("param.y"), GUIContent.none);
                }
            };
            exits.list.onSelectCallback = (list) => {
                OnDataSelect(exits);
            };
            #endregion

            m_DataLists = new List<DataList> {
                blocks,
                walls,
                npcs,
                ents,
                spawners,
                patrols,
                exits
            };
            m_DataNames = new string[m_DataLists.Count];
            for (int i = 0; i < m_DataLists.Count; ++i) {
                m_DataNames[i] = m_DataLists[i].name;
            }
        }

        private void OnDisable()
        {
            SceneView.onSceneGUIDelegate -= OnSceneViewGUI;
        }

        private void OnDataSelect(DataList list)
        {
            var index = list.list.index;
            foreach (var elm in m_DataLists) {
                var i = elm == list ? index : -1;
                elm.index = i;
                elm.list.index = i;
            }

            if (SceneView.lastActiveSceneView) {
                SceneView.lastActiveSceneView.Repaint();
                //SceneView.lastActiveSceneView.LookAt(Vector.zero);
            }
        }

        private void SelectData(DataList list, int index)
        {
            for (int i = 0; i < m_DataLists.Count; ++i) {
                var elm = m_DataLists[i];
                if (elm == list) {
                    m_SelGrid = i;
                    elm.index = index;
                    elm.list.index = index;
                    Repaint();
                } else {
                    elm.index = -1;
                    elm.list.index = -1;
                }
            }
        }

        public override void OnInspectorGUI()
        {
            base.OnInspectorGUI();

            var viewDirty = false;
            var maskView = m_MaskView;
            m_MaskView = EditorGUILayout.MaskField("额外显示", maskView, Names);
            if (m_MaskView != maskView) {
                viewDirty = true;
            }
            
            var select = GUILayout.SelectionGrid(m_SelGrid, m_DataNames, 3);

            EditorGUILayout.Separator();
            if (select != m_SelGrid) {
                viewDirty = true;

                SelectData(m_DataLists[m_SelGrid], -1);
                m_SelGrid = select;
            }
            m_DataLists[m_SelGrid].list.DoLayoutList();

            serializedObject.ApplyModifiedProperties();

            if (viewDirty && SceneView.lastActiveSceneView) {
                SceneView.lastActiveSceneView.Repaint();
            }

            if (GUILayout.Button("保存到文件")) {
                GenStageData();
            }
        }

        private static Vector3[] DrawPath(Transform parent, StageEdit.PatrolPath path, Color color, bool solid)
        {
            var defColor = Handles.color;
            Handles.color = color;

            var points = path.points;
            var array = new Vector3[points.Count];
            var offset = Vector2.one / 2;
            for (int i = 0; i < points.Count; ++i) {
                var p = points[i] + offset;
                array[i] = parent.TransformPoint(new Vector3(p.x, 0, p.y));
            }

            if (array.Length > 0) {
                Handles.DrawSolidDisc(array[0], Vector3.up, 0.25f);
            }

            if (array.Length > 1) {
                if (solid) {
                    Handles.DrawAAPolyLine(3, array);
                } else {
                    Handles.DrawAAPolyLine(10, array);
                }
                if (path.mode == StageEdit.PathMode.Loopback) {
                    Handles.DrawDottedLine(array[array.Length - 1], array[0], 5f);
                }
            }

            Handles.color = defColor;
            return array;
        }

        private static void DrawDisc(Transform parent, Vector2 localPos, float radius, Color color, bool solid)
        {
            var center = parent.TransformPoint(new Vector3(localPos.x, 0, localPos.y));
            var defColor = Handles.color;
            Handles.color = color;
            if (solid) {
                Handles.DrawSolidDisc(center, Vector3.up, radius);
            } else {
                Handles.DrawWireDisc(center, Vector3.up, radius);
            }
            Handles.color = defColor;
        }

        private static void DrawRect(Transform parent, Vector2 localPos, float width, float height, Color color, bool solid)
        {
            var localCenter = new Vector3(localPos.x, 0, localPos.y);
            var vects = new Vector3[] {
                    parent.TransformPoint(localCenter + new Vector3(width, 0.1f, height)/2),
                    parent.TransformPoint(localCenter + new Vector3(width, 0.1f, -height)/2),
                    parent.TransformPoint(localCenter + new Vector3(-width, 0.1f, -height)/2),
                    parent.TransformPoint(localCenter + new Vector3(-width, 0.1f, height)/2),
                };
            if (solid) {
                Handles.DrawSolidRectangleWithOutline(vects, color, Color.clear);
            } else {
                Handles.DrawSolidRectangleWithOutline(vects, Color.clear, color);
            }
        }

        private static void DrawArea(Transform parent, StageEdit.Area area, Color color, bool solid)
        {
            color.a = solid ? 0.5f : 0.3f;

            var localPos = area.coord + new Vector2(0.5f, 0.5f);
            if (area.param.y == 0) {
                DrawDisc(parent, localPos, area.param.x, color, solid);
            } else {
                DrawRect(parent, localPos, area.param.x, area.param.y, color, solid);
            }
        }

        private bool HandleArea(string name, Transform origin, ref StageEdit.Area area, bool solid, Color color)
        {
            var stageEdit = target as StageEdit;
            var stageSiz = m_Size.vector2Value;

            var pos = origin.TransformPoint(area.coord.x + 0.5f, 0, area.coord.y + 0.5f);
            EditorGUI.BeginChangeCheck();
            pos = Handles.PositionHandle(pos, origin.rotation);
            if (EditorGUI.EndChangeCheck()) {
                Undo.RecordObject(stageEdit, "Stage:Move Area " + name);
                var offset = origin.InverseTransformPoint(pos);
                var x = Mathf.Clamp(Mathf.Floor(offset.x), 0, stageSiz.x - 1);
                var y = Mathf.Clamp(Mathf.Floor(offset.z), 0, stageSiz.y - 1);
                area.coord = new Vector2(x, y);
                return true;
            }

            if (area.param.y == 0) {
                EditorGUI.BeginChangeCheck();
                var hPos = origin.TransformPoint(area.coord.x + 0.5f + area.param.x, 0, area.coord.y + 0.5f);
                var radius = Handles.ScaleValueHandle(area.param.x, hPos, origin.rotation,
                    HandleUtility.GetHandleSize(hPos), Handles.CubeHandleCap, 1f);
                if (EditorGUI.EndChangeCheck()) {
                    Undo.RecordObject(stageEdit, "Stage:Resize Area radius " + name);
                    area.param = new Vector2(Mathf.Max(0.1f, Mathf.Floor(radius * 10) / 10), 0);
                    return true;
                }
            } else {
                EditorGUI.BeginChangeCheck();
                var hPos = origin.TransformPoint(area.coord.x + 0.5f + area.param.x / 2, 0, area.coord.y + 0.5f);
                var width = Handles.ScaleValueHandle(area.param.x, hPos, origin.rotation,
                     HandleUtility.GetHandleSize(hPos), Handles.CubeHandleCap, 1f);
                if (EditorGUI.EndChangeCheck()) {
                    Undo.RecordObject(stageEdit, "Stage:Resize Area width " + name);
                    area.param = new Vector2(Mathf.Max(0.1f, Mathf.Floor(width * 10) / 10), area.param.y);
                    return true;
                }
                EditorGUI.BeginChangeCheck();
                hPos = origin.TransformPoint(area.coord.x + 0.5f, 0, area.coord.y + 0.5f + area.param.y / 2);
                var length = Handles.ScaleValueHandle(area.param.y, hPos, origin.rotation,
                     HandleUtility.GetHandleSize(hPos), Handles.CubeHandleCap, 1f);
                if (EditorGUI.EndChangeCheck()) {
                    Undo.RecordObject(stageEdit, "Stage:Resize Area length " + name);
                    area.param = new Vector2(area.param.x, Mathf.Max(0.1f, Mathf.Floor(length * 10) / 10));
                    return true;
                }
            }

            return false;
        }

        private void HandleBlock(int i)
        {
            var stageEdit = target as StageEdit;
            var pos = stageEdit.start.position;
            var stageSiz = m_Size.vector2Value;

            var box = stageEdit.blocks[i];
            var start = box.start;
            var siz = box.size;

            var alpha = blocks.index == i ? 0.3f : 0.1f;
            DrawRect(stageEdit.start, box.start + box.size / 2, siz.x, siz.y, new Color(1, 0, 0, alpha), true);

            var boxPos = stageEdit.start.TransformPoint(siz.x / 2 + start.x, 0, siz.y / 2 + start.y);
            var boxSiz = new Vector3(siz.x, 0, siz.y);
            if (blocks.index == i) {
                EditorGUI.BeginChangeCheck();
                boxPos = Handles.PositionHandle(boxPos, stageEdit.start.rotation);
                if (EditorGUI.EndChangeCheck()) {
                    Undo.RecordObject(stageEdit, "Stage:Move Block");
                    var offset = stageEdit.start.InverseTransformPoint(boxPos);
                    var x = Mathf.Clamp(Mathf.Floor(offset.x - siz.x / 2), 0, stageSiz.x - siz.x);
                    var y = Mathf.Clamp(Mathf.Floor(offset.z - siz.y / 2), 0, stageSiz.y - siz.y);
                    box.start = new Vector2(x, y);
                    stageEdit.blocks[i] = box;
                }

                EditorGUI.BeginChangeCheck();
                var xPos = stageEdit.start.TransformPoint(start.x + siz.x, 0, start.y + siz.y / 2);
                var sizeX = Handles.ScaleValueHandle(boxSiz.x, xPos, stageEdit.start.rotation,
                    HandleUtility.GetHandleSize(xPos), Handles.CubeHandleCap, 2f);
                if (EditorGUI.EndChangeCheck()) {
                    Undo.RecordObject(stageEdit, "Stage:Scale Block X");
                    boxSiz.x = Mathf.Clamp(Mathf.Floor(sizeX), 1, stageSiz.x - start.x);
                    box.size = new Vector2(boxSiz.x, boxSiz.z);
                    stageEdit.blocks[i] = box;
                }

                EditorGUI.BeginChangeCheck();
                var zPos = stageEdit.start.TransformPoint(start.x + siz.x / 2, 0, start.y + siz.y);
                var sizeY = Handles.ScaleValueHandle(boxSiz.z, zPos, stageEdit.start.rotation,
                    HandleUtility.GetHandleSize(zPos), Handles.CubeHandleCap, 2f);
                if (EditorGUI.EndChangeCheck()) {
                    Undo.RecordObject(stageEdit, "Stage:Scale Block Y");
                    boxSiz.z = Mathf.Clamp(Mathf.Floor(sizeY), 1, stageSiz.y - start.y);
                    box.size = new Vector2(boxSiz.x, boxSiz.z);
                    stageEdit.blocks[i] = box;
                }
            } else if (Handles.Button(stageEdit.start.TransformPoint(siz.x / 2 + start.x, 0.25f, siz.y / 2 + start.y),
                stageEdit.start.rotation, 0.5f, 0.5f, Handles.CubeHandleCap)) {
                SelectData(blocks, i);
            }
        }

        private void HandleWall(int i)
        {
            var stageEdit = target as StageEdit;
            var pos = stageEdit.start.position;
            var stageSiz = m_Size.vector2Value;

            var wall = stageEdit.walls[i];
            var siz = wall.end - wall.start;
            DrawRect(stageEdit.start, (wall.start + wall.end) / 2,
                Mathf.Max(0.2f, siz.x), Mathf.Max(0.2f, siz.y), Color.black, true);

            var wallStart = new Vector3(wall.start.x, 0, wall.start.y);
            var wallEnd = new Vector3(wall.end.x, 0, wall.end.y);
            var center = (wallStart + wallEnd) / 2;

            var wallPos = stageEdit.start.TransformPoint(center);
            if (walls.index == i) {
                if (Event.current.shift) {
                    EditorGUI.BeginChangeCheck();
                    var endPos = Handles.PositionHandle(stageEdit.start.TransformPoint(wallEnd), stageEdit.start.rotation);
                    if (EditorGUI.EndChangeCheck()) {
                        Undo.RecordObject(stageEdit, "Stage:Move Wall");
                        wallEnd = stageEdit.start.InverseTransformPoint(endPos);
                        var offset = wallEnd - wallStart;
                        if (Mathf.Abs(offset.x) < Mathf.Abs(offset.z)) {
                            wall.end = new Vector2(wall.start.x, Mathf.Floor(wallEnd.z));
                        } else {
                            wall.end = new Vector2(Mathf.Floor(wallEnd.x), wall.start.y);
                        }
                        stageEdit.walls[i] = wall;
                    }
                } else {
                    EditorGUI.BeginChangeCheck();
                    wallPos = Handles.PositionHandle(wallPos, stageEdit.start.rotation);
                    if (EditorGUI.EndChangeCheck()) {
                        Undo.RecordObject(stageEdit, "Stage:Move Wall");
                        var offset = stageEdit.start.InverseTransformPoint(wallPos);
                        var x = Mathf.Clamp(Mathf.Floor(offset.x - siz.x / 2), 0, stageSiz.x - siz.x);
                        var y = Mathf.Clamp(Mathf.Floor(offset.z - siz.y / 2), 0, stageSiz.y - siz.y);
                        wall.start = new Vector2(x, y);
                        wall.end = wall.start + siz;
                        stageEdit.walls[i] = wall;
                    }
                }
            } else if (Handles.Button(wallPos + new Vector3(0, 0.25f, 0), stageEdit.start.rotation, 0.5f, 0.5f, Handles.CubeHandleCap)) {
                SelectData(walls, i);
            }
        }

        private void HandleNpc(int i)
        {
            var stageEdit = target as StageEdit;
            var pos = stageEdit.start.position;
            var stageSiz = m_Size.vector2Value;

            var npc = stageEdit.npcs[i];
            var coord = npc.coord + new Vector2(0.5f, 0.5f);

            DrawDisc(stageEdit.start, coord, 0.5f, Color.magenta, npcs.index == i);

            var npcPos = stageEdit.start.TransformPoint(coord.x, 0, coord.y);

            var defColor = Handles.color;
            Handles.color = Color.magenta;
            Handles.DrawLine(npcPos, npcPos + Quaternion.Euler(0, npc.angle, 0) * Vector3.forward);
            Handles.color = defColor;

            var npcRot = stageEdit.start.rotation * Quaternion.Euler(0, npc.angle, 0);
            if (npcs.index == i) {
                if (Event.current.shift) {
                    EditorGUI.BeginChangeCheck();
                    npcRot = Handles.RotationHandle(npcRot, npcPos);
                    if (EditorGUI.EndChangeCheck()) {
                        Undo.RecordObject(stageEdit, "Stage:Rot NPC");
                        npc.angle = Mathf.FloorToInt(npcRot.eulerAngles.y);
                        stageEdit.npcs[i] = npc;
                    }
                } else {
                    EditorGUI.BeginChangeCheck();
                    npcPos = Handles.PositionHandle(npcPos, Quaternion.identity);
                    if (EditorGUI.EndChangeCheck()) {
                        Undo.RecordObject(stageEdit, "Stage:Move NPC");
                        var offset = stageEdit.start.InverseTransformPoint(npcPos);
                        var x = Mathf.Clamp(Mathf.Floor(offset.x * CVar.LENGTH_MUL) / CVar.LENGTH_MUL, 0, stageSiz.x - 1);
                        var y = Mathf.Clamp(Mathf.Floor(offset.z * CVar.LENGTH_MUL) / CVar.LENGTH_MUL, 0, stageSiz.y - 1);
                        npc.coord = new Vector2(x, y);
                        stageEdit.npcs[i] = npc;
                    }
                }
            } else if (Handles.Button(npcPos + new Vector3(0, 0.25f, 0), Quaternion.identity, 0.5f, 0.5f, Handles.CubeHandleCap)) {
                SelectData(npcs, i);
            }
        }

        private void HandleEnt(int i)
        {
            var stageEdit = target as StageEdit;
            var start = stageEdit.start;

            var ent = stageEdit.ents[i];

            DrawArea(start, ent, Color.green, ents.index == i);

            var pos = start.TransformPoint(ent.coord.x + 0.5f, 0, ent.coord.y + 0.5f);
            var defColor = Handles.color;
            Handles.color = Color.green;
            Handles.DrawLine(pos, pos + Quaternion.Euler(0, ent.angle, 0) * Vector3.forward);
            Handles.color = defColor;

            if (ents.index == i) {
                StageEdit.Area area = ent;
                if (HandleArea("Ent", start, ref area, true, new Color(0, 1, 0, 0.1f))) {
                    ent.coord = area.coord; ent.param = area.param;
                    stageEdit.ents[i] = ent;
                }
            } else if (Handles.Button(start.TransformPoint(ent.coord.x + 0.5f, 0.25f, ent.coord.y + 0.5f),
                start.rotation, 0.5f, 0.5f, Handles.CubeHandleCap)) {
                SelectData(ents, i);
            }
        }

        private void HandleSpawner(int i)
        {
            var stageEdit = target as StageEdit;
            var start = stageEdit.start;
            var pos = start.position;
            var stageSiz = m_Size.vector2Value;

            var spawner = stageEdit.spawners[i];

            DrawArea(start, spawner.source, Color.gray, spawners.index == i);
            DrawArea(start, spawner.destina, Color.yellow, spawners.index == i);
            if (spawners.index == i) {
                if (Event.current.shift) {
                    if (HandleArea("source", stageEdit.start, ref spawner.source, false, new Color(1, 0, 0))) {
                        stageEdit.spawners[i] = spawner;
                    }
                } else {
                    if (HandleArea("destina", stageEdit.start, ref spawner.destina, true, new Color(1, 0, 0, 0.1f))) {
                        stageEdit.spawners[i] = spawner;
                    }
                }
            } else {
                if (Handles.Button(start.TransformPoint(spawner.destina.coord.x + 0.5f, 0.25f, spawner.destina.coord.y + 0.5f),
                Quaternion.identity, 0.5f, 0.5f, Handles.CubeHandleCap)) {
                    SelectData(spawners, i);
                }
            }
        }

        private void HandlePatroPath(int i)
        {
            var stageEdit = target as StageEdit;
            var stageSiz = m_Size.vector2Value;
            var path = stageEdit.patrolPaths[i];
            if (path.points == null) return;
            
            var array = DrawPath(stageEdit.start, path, Color.magenta, patrols.index != i);
            if (patrols.index == i) {
                for (int idx = 0; idx < array.Length; ++idx) {
                    EditorGUI.BeginChangeCheck();
                    var pos = Handles.PositionHandle(array[idx], Quaternion.identity);
                    if (EditorGUI.EndChangeCheck()) {
                        Undo.RecordObject(stageEdit, "Stage:Edit Path");
                        var offset = stageEdit.start.InverseTransformPoint(pos);
                        var x = Mathf.Clamp(Mathf.Floor(offset.x), 0, stageSiz.x - 1);
                        var y = Mathf.Clamp(Mathf.Floor(offset.z), 0, stageSiz.y - 1);
                        path.points[idx] = new Vector2(x, y);
                    }
                }
            } else {

            }
        }

        private void HandleExit(int i)
        {
            var stageEdit = target as StageEdit;
            var start = stageEdit.start;

            var ent = stageEdit.exits[i];

            DrawArea(start, ent, Color.green, exits.index == i);
            if (exits.index == i) {
                if (HandleArea("Exit", start, ref ent, true, new Color(0, 1, 0, 0.1f))) {
                    stageEdit.exits[i] = ent;
                }
            } else if (Handles.Button(start.TransformPoint(ent.coord.x + 0.5f, 0.25f, ent.coord.y + 0.5f),
                start.rotation, 0.5f, 0.5f, Handles.CubeHandleCap)) {
                SelectData(exits, i);
            }
        }


        private bool AllowDraw(int dataIdx)
        {
            return dataIdx == m_SelGrid || ((1 << dataIdx) & m_MaskView) != 0;
        }

        private void OnSceneGUI()
        {
            var stageEdit = target as StageEdit;
            if (!stageEdit.start) return;
            
            // 绘制障碍
            if (stageEdit.blocks != null && AllowDraw(0)) {
                for (int i = 0; i < stageEdit.blocks.Count; ++i) {
                    HandleBlock(i);
                }
            }

            // 绘制气墙
            if (stageEdit.walls != null && AllowDraw(1)) {
                for (int i = 0; i < stageEdit.walls.Count; ++i) {
                    HandleWall(i);
                }
            }

            // 绘制NPC
            if (stageEdit.npcs != null && AllowDraw(2)) {
                for (int i = 0; i < stageEdit.npcs.Count; ++i) {
                    var npc = stageEdit.npcs[i];
                    var coord = npc.coord;
                    var lbPos = stageEdit.start.TransformPoint(coord.x + 0.5f, 0, coord.y);
                    Handles.Label(lbPos, string.Format("<color=white>#{0}</color>", npc.id), CustomEditorStyles.midLabel);

                    HandleNpc(i);
                }
            }

            // 绘制入口
            if (stageEdit.ents != null && AllowDraw(3)) {
                for (int i = 0; i < stageEdit.ents.Count; ++i) {
                    HandleEnt(i);
                }
            }

            // 绘制怪点
            if (stageEdit.spawners != null && AllowDraw(4)) {
                for (int i = 0; i < stageEdit.spawners.Count; ++i) {
                    var spwaner = stageEdit.spawners[i];
                    var coord = spwaner.destina.coord;
                    var lbPos = stageEdit.start.TransformPoint(coord.x + 0.5f, 0, coord.y);
                    Handles.Label(lbPos, string.Format("<color=white>#{0}\n{1}/{2}</color>",
                        spwaner.id, spwaner.nInit, spwaner.nMin),
                        CustomEditorStyles.midLabel);

                    HandleSpawner(i);
                }
            }

            // 绘制巡逻路径
            if (stageEdit.patrolPaths != null && AllowDraw(5)) {
                for (int i = 0; i < stageEdit.patrolPaths.Count; ++i) {
                    HandlePatroPath(i);
                }
            }

            // 绘制出口
            if (stageEdit.exits != null && AllowDraw(6)) {
                for (int i = 0; i < stageEdit.exits.Count; ++i) {
                    HandleExit(i);
                }
            }
        }
        
        private const string PATH_POINT_WND = "巡逻路点";
        private static readonly int PATH_POINT_WND_ID = PATH_POINT_WND.GetHashCode();
        private static readonly Vector2 PATH_POINT_WND_SIZE = new Vector2(200, 200);
        private Vector2 m_PathPointPos;

        private void OnSceneViewGUI(SceneView view)
        {
            if (AllowDraw(5)) {

                var svRc = view.camera.pixelRect;
                #if UNITY_EDITOR_OSX
                // 暂时不知道在苹果视网膜屏上如何取得正确的屏幕大小
                svRc.width /= 2f;
                svRc.height /= 2f;
                #endif
                var wndSize = PATH_POINT_WND_SIZE;
                svRc.x = svRc.width - wndSize.x - 20;
                svRc.y = svRc.height - wndSize.y - 20;
                svRc.size = wndSize;

                // Block Mouse Event
                GUI.Button(svRc, GUIContent.none);

                svRc.y += 20;
                // PathPoint Window
                GUILayout.Window(PATH_POINT_WND_ID, svRc, DrawPathPointWindow, PATH_POINT_WND);
            }
        }

        private void DrawPathPointWindow(int id)
        {
            var stageEdit = target as StageEdit;

            m_PathPointPos = GUILayout.BeginScrollView(m_PathPointPos);
            StageEdit.PatrolPath path = new StageEdit.PatrolPath() { id = -1 } ;

            if (patrols.list.index >= 0) {
                path = stageEdit.patrolPaths[patrols.list.index];
                var nPonit = path.points != null ? path.points.Count : 0;

                for (int i = 0; i < nPonit; ++i) {
                    GUILayout.BeginHorizontal();
                    var point = path.points[i];
                    point.x = EditorGUILayout.FloatField(point.x);
                    point.y = EditorGUILayout.FloatField(point.y);
                    path.points[i] = point;

                    EditorGUI.BeginDisabledGroup(i < 1);
                    if (GUILayout.Button("▲", EditorStyles.miniButtonLeft)) {
                        path.points[i] = path.points[i - 1];
                        path.points[i - 1] = point;
                    }
                    EditorGUI.EndDisabledGroup();

                    EditorGUI.BeginDisabledGroup(i > nPonit - 2);
                    if (GUILayout.Button("▼", EditorStyles.miniButtonMid)) {
                        path.points[i] = path.points[i + 1];
                        path.points[i + 1] = point;
                    }
                    EditorGUI.EndDisabledGroup();

                    if (GUILayout.Button("+", EditorStyles.miniButtonMid)) {
                        path.points.Insert(i, path.points[i]);
                    }
                    if (GUILayout.Button("-", EditorStyles.miniButtonRight)) {
                        path.points.RemoveAt(i);
                        --i; --nPonit;
                    }
                    GUILayout.EndHorizontal();
                }
            }
            GUILayout.EndScrollView();

            if (path.id >= 0 && GUILayout.Button("添加")) {
                if (path.points.Count > 0) {
                    path.points.Add(path.points[path.points.Count - 1]);
                } else {
                    path.points.Add(Vector2.zero);
                }
            }
        }

        private void GenStageData()
        {
            var self = target as StageEdit;
            if (self.templateId == 0) {
                EditorUtility.DisplayDialog("警告", "共享的关卡配置(id == 0)无法导出！", "确定");
                return;
            }
            
            var joBlocks = new ProxyArray();
            foreach (var block in self.blocks) {
                joBlocks.Add(block.ToJsonObj());
            }
            
            var joWalls = new ProxyArray();
            foreach (var wall in self.walls) {
                joWalls.Add(wall.ToJsonObj());
            }           

            var joNpcs = new ProxyArray();
            foreach (var npc in self.npcs) {
                joNpcs.Add(npc.ToJsonObj());
            }            

            var joEnts = new ProxyArray();
            foreach (var ent in self.ents) {
                joEnts.Add(ent.ToJsonObj());
            }            

            var joSpawners = new ProxyArray();
            foreach (var spawner in self.spawners) {
                joSpawners.Add(spawner.ToJsonObj());
            }           

            var joPatrols = new ProxyArray();
            foreach (var patrol in self.patrolPaths) {
                joPatrols.Add(patrol.ToJsonObj());
            }            

            var joExits = new ProxyArray();
            foreach (var ent in self.exits) {
                joExits.Add(ent.ToJsonObj());
            }           

            var list = new List<Component>();
            self.GetComponentsInChildren(typeof(ReedEdit), list);
            var joReeds = new ProxyArray();
            foreach (ReedEdit reed in list) {
                joReeds.Add(reed.ToJsonObj());
            }

            var shared = StageEdit.Shared;
            if (shared != null) {
                var offset3d = shared.start.position - self.start.position;
                var offset = new Vector2(offset3d.x, offset3d.z);
                foreach (var block in shared.blocks) {
                    var _block = block;
                    _block.start += offset;
                    joBlocks.Add(_block.ToJsonObj());
                }

                foreach (var wall in shared.walls) {
                    var _wall = wall;
                    _wall.start += offset;
                    _wall.end += offset;
                    joWalls.Add(_wall.ToJsonObj());
                }
            }

            var joStage = new ProxyObject {
                { "m_TemplateId", new ProxyNumber(self.templateId) },
                { "m_Size", StageEdit.Vector2Json(self.size) },
                { "m_Blocks", joBlocks },
                { "m_Walls", joWalls },
                { "m_Npcs", joNpcs },
                { "m_Ents", joEnts },
                { "m_Spawners", joSpawners },
                { "m_PatrolPaths", joPatrols },
                { "m_Exits", joExits },
                { "m_Reeds", joReeds }
            };

            var rootDir = Path.Combine(Path.Combine(Application.dataPath, "Scenes"), ".StageData");
            SystemTools.NeedDirectory(rootDir);

            var filePath = Path.Combine(rootDir, string.Format("stagedata{0}.json", self.templateId));
            try {
                File.WriteAllText(filePath, joStage.ToJSONString());
                if (EditorUtility.DisplayDialog("关卡保存", string.Format("已成功保存至\n{0}", filePath), "打开目录", "取消")) {
                    EditorUtility.RevealInFinder(filePath);
                }
            } catch (System.Exception e) {
                EditorUtility.DisplayDialog("关卡保存", e.Message, "关闭");
            } 
        }
    }
}
