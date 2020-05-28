using System.Collections;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using TinyJSON;
using UnityEngine;
using UnityEditor;
using World;
using XLua;
using ILuaState = System.IntPtr;

namespace ZFrame.SheetViewer
{
    public class SheetWindow : EditorWindow
    {
        [MenuItem("Custom/配置表...")]
        private static void Open()
        {
            GetWindow(typeof(SheetWindow), false, "配置表(SheetWindow)");
        }

        private LuaEnv m_Env;
        private ILuaState L { get { return m_Env.L; } }

        private ProxyArray _joRule;
        private Dictionary<string, SheetBook> m_DB = new Dictionary<string, SheetBook>();
        
        private string m_Lang = "cn", _Lang;

        private SheetBook GetSheetBook(Variant jo)
        {
            SheetBook book;
            var name = jo["name"];
            if (!m_DB.TryGetValue(jo["name"], out book)) {
                book = new SheetBook(L, jo);
                m_DB.Add(name, book);
            }

            return book;
        }

        private void Refresh()
        {
            var buffer = System.IO.File.ReadAllBytes("Assets/Editor/ConfigRule/main.lua");
            L.DoBuffer(buffer, "main");
            _joRule = L.ToJsonObj(-1) as ProxyArray;

            L.Pop(1);

            m_DB.Clear();
            m_MenuIdx = -1;
            m_MenuPos = Vector2.zero;
            SheetBook.ResetData();
        }

        private void Awake()
        {
            _Lang = m_Lang;

            m_Env = new LuaEnv();
            m_Env.AddLoader(ChunkAPI.__Loader);

            L.GetGlobal("_G");
            L.SetDict("loadfile", StaticLuaCallbacks.loadfile);
            L.SetDict("dofile", StaticLuaCallbacks.dofile);
            L.Pop(1);

            try {
                Refresh();
            } catch (System.Exception e) {
                Debug.LogError(e);
            }

        }

        private void OnGUI()
        {
            GUILayout.BeginVertical();
            DrawHeader();
            DrawLoc();
            EditorGUILayout.Separator();
            DrawContent();
            GUILayout.EndVertical();
        }

        private void OnDestroy()
        {
            m_Env.Dispose();
        }

        private void DrawHeader()
        {
            GUILayout.BeginHorizontal();
            if (GUILayout.Button("刷新", GUILayout.Width(60))) {
                Refresh();
            }
            if (GUILayout.Button("保存", GUILayout.Width(60))) {
                SheetBook.Save();
            }
            
            GUILayout.EndHorizontal();
        }

        private void DrawLoc()
        {
            GUILayout.BeginHorizontal();
            _Lang = GUILayout.TextField(_Lang, GUILayout.Width(60));
            if (string.CompareOrdinal(_Lang, m_Lang) != 0) {
                if (GUILayout.Button("OK", EditorStyles.miniButton, GUILayout.ExpandWidth(false))) {
                    m_Lang = _Lang;
                }
            }
            GUILayout.EndHorizontal();
        }

        private void DrawContent()
        {
            GUILayout.BeginHorizontal();
            DrawDataMenu();
            DrawSheetBook();
            GUILayout.EndHorizontal();
        }

        private Vector2 m_MenuPos;
        private int m_MenuIdx = -1;
        private void DrawDataMenu()
        {
            m_MenuPos = GUILayout.BeginScrollView(m_MenuPos, GUILayout.Width(60));
            var defColor = GUI.color;
            for (int i = 0; i < _joRule.Count; i++) {
                var rule = _joRule[i];
                var name = rule.ConvTo("name", (string)null);
                if (name != null) {
                    if (m_MenuIdx == i) GUI.color = Color.yellow;
                    if (GUILayout.Button(name, CustomEditorStyles.LeftToolbar)) {
                        if (m_MenuIdx != i) {
                            m_MenuIdx = i;
                            SheetBook.Reposition();
                        }
                    }

                    GUI.color = defColor;
                }
            }
            GUILayout.EndScrollView();
        }

        private void DrawSheetBook()
        {
            if (m_MenuIdx != -1) {
                GetSheetBook(_joRule[m_MenuIdx]).DrawMenu(L, m_Lang);
            }
        }

    }
}
