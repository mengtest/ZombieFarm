using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Resources;
using JetBrains.Annotations;
using UnityEngine;
using UnityEditor;
using TinyJSON;
using Vectrosity;
using World.Control;
using ILuaState = System.IntPtr;

namespace ZFrame.SheetViewer
{
    public struct SheetField
    {
        public readonly string Key;
        public readonly string Name;
        public readonly string Desc;
        public SheetField(Variant jo)
        {
            Key = jo["key"];
            Name = jo.ConvTo("name", Key);
            Desc = jo.ConvTo("desc", string.Empty);
        }
    }

    public class LocField
    {
        public bool loaded;
        public readonly string FileName, Index;
        public readonly string Key, Name;
        public readonly List<SheetField> Fields;

        public LocField(string fileName, Variant joLoc, ProxyObject joFields)
        {
            FileName = joLoc["file"] ?? fileName;
            Index = joLoc["index"];
            Key = joLoc["key"];
            Name = joLoc["name"];

            var field = joFields != null ? joFields[FileName] as ProxyArray : null;
            if (field != null) {
                Fields = new List<SheetField>();
                foreach (var jo in field) {
                    Fields.Add(new SheetField(jo));
                }
            }
        }
    }

    public class SheetData
    {
        private static readonly Dictionary<string, Variant> ChangedField = new Dictionary<string, Variant>();
        private static readonly List<string> TempKeys = new List<string>();
        private static readonly char[] KeySeparator = { '|' };

        private static string GetNewKey(string key)
        {
            return '*' + key;
        }

        private static bool IsNewKey(string key)
        {
            return key[0] == '*';
        }

        private static Variant DrawIntegerField(string name, string desc, Variant jo, string key)
        {
            Variant ret = null;
            GUILayout.BeginHorizontal();
            int value = jo[key];
            int showValue = (int)jo.ConvTo(GetNewKey(key), value);
            var equal = showValue == value;

            GUILayout.Label(new GUIContent(name, desc), CustomEditorStyles.rightLabel, GUILayout.Width(100));
            var retValue = GUILayout.TextField(showValue.ToString(), CustomEditorStyles.boldText, GUILayout.Width(equal ? 200 : 170));

            if (!equal && GUILayout.Button("X", EditorStyles.miniButton)) {
                ret = new ProxyNumber(value);
            } else if (int.TryParse(retValue, out value) && value != showValue) {
                ret = new ProxyNumber(value);
            }

            GUILayout.EndHorizontal();

            return ret;
        }

        private static Variant DrawStringField(string name, string desc, Variant jo, string key)
        {
            Variant ret = null;
            GUILayout.BeginHorizontal();
            string value = jo[key];
            string showValue = jo[GetNewKey(key)] ?? value;
            var equal = string.CompareOrdinal(showValue, value) == 0;

            GUILayout.Label(new GUIContent(name, desc), CustomEditorStyles.rightLabel, GUILayout.Width(100));
            var retValue = GUILayout.TextField(showValue, GUILayout.Width(equal ? 200 : 170));

            if (!equal && GUILayout.Button("X", EditorStyles.miniButton)) {
                ret = new ProxyString(value);
            } else if (string.CompareOrdinal(showValue, retValue) != 0) {
                ret = new ProxyString(retValue);
            }

            GUILayout.EndHorizontal();
            return ret;
        }

        private static Variant DrawAnyField(string name, string desc, Variant jo, string key)
        {
            var value = jo[key];
            if (value is ProxyString) {
                return DrawStringField(name, desc, jo, key);
            }

            if (value is ProxyNumber) {
                return DrawIntegerField(name, desc, jo, key);
            }

            return null;
        }

        public readonly string FileName;
        public readonly string Key;
        public readonly List<SheetField> Fields;
        public readonly ProxyArray Sheet;
        public readonly List<ProxyObject> RowList = new List<ProxyObject>();
        private bool m_RowDirty;

        public SheetData(string fileName, string key, ProxyArray sheet, List<SheetField> fields)
        {
            m_RowDirty = true;
            FileName = fileName;
            Key = key;
            Sheet = sheet;
            Fields = fields;
        }

        public SheetData(string fileName, string key, ProxyArray sheet, ProxyArray fields)
            : this(fileName, key, sheet, (List<SheetField>)null)
        {
            if (fields != null) {
                Fields = new List<SheetField>();
                foreach (var jo in fields) {
                    Fields.Add(new SheetField(jo));
                }
            }
        }

        public void SetRowDirty()
        {
            m_RowDirty = true;
            RowList.Clear();
        }

        public void UpdateRow(Variant joKey)
        {
            if (m_RowDirty) {
                if (joKey is ProxyNumber) {
                    int id = joKey;
                    m_RowDirty = false;
                    var joRow = Sheet.FirstOrDefault(jo => (int)jo.ConvTo(Key, -1) == id) as ProxyObject;
                    if (joRow != null) RowList.Add(joRow);
                } else {
                    m_RowDirty = false;
                    string strKey = joKey;
                    var keys = strKey.Split(KeySeparator, StringSplitOptions.RemoveEmptyEntries);
                    foreach (var k in keys) {
                        int id;
                        if (int.TryParse(k, out id)) {
                            var joRow = Sheet.FirstOrDefault(jo => (int)jo.ConvTo(Key, -1) == id) as ProxyObject;
                            if (joRow != null) RowList.Add(joRow);
                        }
                    }
                }
            }
        }

        private void Draw(ProxyObject rowData, Dictionary<string, Variant> Values)
        {
            EditorGUILayout.Separator();
            GUILayout.Label(string.Format("{0}#{1}", FileName, rowData[Key]), CustomEditorStyles.rightLabel);
            
            foreach (var kv in rowData) {
                if (!IsNewKey(kv.Key)) TempKeys.Add(kv.Key);
            }

            if (Fields != null) {
                foreach (var field in Fields) {
                    var desc = string.IsNullOrEmpty(field.Desc) ? field.Key : field.Desc;
                    var ret = DrawAnyField(field.Name, desc, rowData, field.Key);
                    if (ret != null) ChangedField.Add(field.Key, ret);
                    TempKeys.Remove(field.Key);
                    if (Values != null && !Values.ContainsKey(field.Key)) Values.Add(field.Key, rowData[field.Key]);
                }
            }

            TempKeys.Sort();
            foreach (var key in TempKeys) {
                var ret = DrawAnyField(key, key, rowData, key);
                if (ret != null) ChangedField.Add(key, ret);
                if (Values != null && !Values.ContainsKey(key)) Values.Add(key, rowData[key]);
            }

            TempKeys.Clear();

            foreach (var kv in ChangedField) {
                var rawValue = rowData[kv.Key];
                bool equal;
                if (rawValue is ProxyNumber) {
                    equal = (int)rawValue == (int)kv.Value;
                } else if (rawValue is ProxyString) {
                    equal = string.CompareOrdinal(rawValue, kv.Value) == 0;
                } else continue;

                if (equal) {
                    rowData[GetNewKey(kv.Key)] = null;
                } else {
                    rowData[GetNewKey(kv.Key)] = kv.Value;
                }
            }

            ChangedField.Clear();
        }

        public void Draw(Variant joKey, Dictionary<string, Variant> Values)
        {
            UpdateRow(joKey);
            foreach (var joRow in RowList) Draw(joRow, Values);
        }

        public void Save()
        {
            // 更新数据
            foreach (var joRow in Sheet) {
                ChangedField.Clear();
                foreach (var kv in (ProxyObject)joRow) {
                    if (IsNewKey(kv.Key)) {
                        var key = kv.Key.Substring(1);
                        ChangedField.Add(key, kv.Value);
                    }
                }

                foreach (var kv in ChangedField) {
                    joRow[kv.Key] = kv.Value;
                }
            }
            
            var projectRoot = SystemTools.GetDirPath(Application.dataPath);
            var file = File.OpenWrite(string.Format("{0}/Essets/LuaRoot/config/{1}.lua", projectRoot, FileName));
            using (var w = new StreamWriter(file)) {
                w.Write("return {");
                foreach (var joRow in Sheet) {
                    w.Write("{");
                    foreach (var kv in (ProxyObject)joRow) {
                        if (!IsNewKey(kv.Key)) {
                            if (kv.Value is ProxyNumber) {
                                w.Write("{0}={1},", kv.Key, kv.Value);
                            } else {
                                w.Write("{0}=\"{1}\",", kv.Key, kv.Value);
                            }
                        }
                    }

                    w.Write("},\n");
                }

                w.Write('}');
            }

            file.Close();
        }
    }

    public class IndexSheetData
    {
        public readonly string Index;
        public readonly SheetData Sheet;

        public IndexSheetData(string index, SheetData sheet)
        {
            Index = index;
            Sheet = sheet;
        }
    }

    public class SheetBook
    {
        private const int DRAW_WIDTH = 300;
        private static readonly Dictionary<string, Variant> PrimaryKeys = new Dictionary<string, Variant>();
        private static Dictionary<string, SheetData> LoadedSheets = new Dictionary<string, SheetData>();

        public readonly string Key;

        public readonly LocField Loc;
        public SheetData LocSheet;
        public readonly SheetData Sheet;
        public readonly List<SheetData> Subs;
        public readonly List<IndexSheetData> Indexes;

        private static SheetData LoadSheet(ILuaState L, string key, string fileName, Variant fields)
        {
            SheetData sheet;
            if (!LoadedSheets.TryGetValue(fileName, out sheet)) {
                L.DoFile("config/" + fileName);
                var joSheet = L.ToJsonObj(-1) as ProxyArray;
                L.Pop(1);

                var field = fields != null ? fields[fileName] as ProxyArray : null;
                sheet = new SheetData(fileName, key, joSheet, field);
                LoadedSheets.Add(fileName, sheet);
            }

            return sheet;
        }
        
        public static void Save()
        {
            foreach (var kv in LoadedSheets) {
                foreach (var variant in kv.Value.Sheet) {
                    var joRow = (ProxyObject)variant;
                    foreach (var joKv in joRow) {
                        if (joKv.Key[0] == '*') goto SAVE;
                    }
                }
                continue;
                
                SAVE:
                kv.Value.Save();
                LogMgr.D("保存{0}", kv.Key);
            }
            ResetData();
        }

        private static SheetData LoadSheet(ILuaState L, string key, string fileName, List<SheetField> fields)
        {
            SheetData sheet;
            if (!LoadedSheets.TryGetValue(fileName, out sheet)) {
                L.DoFile("config/" + fileName);
                var joSheet = L.ToJsonObj(-1) as ProxyArray;
                L.Pop(1);

                sheet = new SheetData(fileName, key, joSheet, fields);
                LoadedSheets.Add(fileName, sheet);
            }

            return sheet;
        }

        private static IndexSheetData LoadIndexSheet(ILuaState L, string index, string key, string fileName, Variant fields)
        {
            var sheet = LoadSheet(L, key, fileName, fields);
            return new IndexSheetData(index, sheet);
        }

        public SheetBook(ILuaState L, Variant rule)
        {
            Key = rule["key"];

            var joFields = rule["Fields"] as ProxyObject;
            Sheet = LoadSheet(L, Key, rule["file"], joFields);

            var joLoc = rule["Loc"] as ProxyObject;
            if (joLoc != null) {
                Loc = new LocField(Sheet.FileName, joLoc, joFields);
            }

            var joSubs = rule["Subs"] as ProxyObject;
            if (joSubs != null) {
                Subs = new List<SheetData>();
                foreach (var kv in joSubs) {
                    Subs.Add(LoadSheet(L, kv.Value, kv.Key, joFields));
                }
            }

            var joIndexes = rule["Indexes"] as ProxyObject;
            if (joIndexes != null) {
                Indexes = new List<IndexSheetData>();
                foreach (var kv in joIndexes) {
                    var joIdx = kv.Value as ProxyObject;
                    if (joIdx != null) {
                        foreach (var idx in joIdx) {
                            Indexes.Add(LoadIndexSheet(L, kv.Key, idx.Value, idx.Key, joFields));
                        }
                    }
                }
            }
        }

        private Vector2 m_ScrPos;

        private void Draw(Variant joKey)
        {
            m_ScrPos = GUILayout.BeginScrollView(m_ScrPos);
            GUILayout.BeginHorizontal();
            
            GUILayout.BeginVertical(GUILayout.Width(DRAW_WIDTH));
            Sheet.Draw(joKey, PrimaryKeys);
            if (Subs != null) {
                foreach (var sheet in Subs) sheet.Draw(joKey, PrimaryKeys);
            }

            GUILayout.EndVertical();

            if (Indexes != null) {
                foreach (var sheet in Indexes) {
                    Variant jo;
                    if (PrimaryKeys.TryGetValue(sheet.Index, out jo)) {
                        GUILayout.BeginVertical(GUILayout.Width(DRAW_WIDTH));
                        sheet.Sheet.Draw(jo, null);
                        GUILayout.EndVertical();
                    }
                }
            }

            GUILayout.EndHorizontal();
            GUILayout.EndScrollView();

            PrimaryKeys.Clear();
        }

        private static Vector2 _MenuPos;
        private static int _MenuIdx = -1;
        public void DrawMenu(ILuaState L, string lang)
        {
            GUILayout.BeginHorizontal();
            _MenuPos = GUILayout.BeginScrollView(_MenuPos, GUILayout.Width(200));

            if (Loc != null && !Loc.loaded) {
                Loc.loaded = true;
                var fileName = Loc.FileName.Replace("loc", lang);
                LocSheet = LoadSheet(L, Loc.Key, fileName, Loc.Fields);
            }

            var defColor = GUI.color;
            for (int i = 0; i < Sheet.Sheet.Count; i++) {
                var ent = Sheet.Sheet[i];
                var joKey = ent[Key];
                if (joKey == null) continue;

                string keyName = joKey;
                if (LocSheet != null) {
                    LocSheet.SetRowDirty();
                    LocSheet.UpdateRow(string.IsNullOrEmpty(Loc.Index) ? joKey :  ent[Loc.Index]);
                    if (LocSheet.RowList.Count > 0) {
                        keyName = string.Format("{0}({1})", joKey, LocSheet.RowList[0][Loc.Name]);
                    }
                }

                if (_MenuIdx == i) GUI.color = Color.yellow;
                if (GUILayout.Button(keyName, CustomEditorStyles.LeftToolbar)) {
                    if (_MenuIdx != i) {
                        _MenuIdx = i;
                        m_ScrPos = Vector2.zero;
                        Sheet.SetRowDirty();
                        if (Subs != null)
                            foreach (var sheet in Subs) sheet.SetRowDirty();
                        if (Indexes != null)
                            foreach (var sheet in Indexes) sheet.Sheet.SetRowDirty();
                    }
                }

                GUI.color = defColor;
            }
            GUILayout.EndScrollView();
            if (_MenuIdx > -1) Draw(Sheet.Sheet[_MenuIdx][Key]);
            GUILayout.EndHorizontal();
        }

        public static void Reposition()
        {
            _MenuPos = Vector2.zero;
            _MenuIdx = -1;
        }

        public static void ResetData()
        {
            Reposition();
            LoadedSheets.Clear();
        }
    }
}
