﻿using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using TinyJSON;

namespace ZFrame.UGUI
{
    [CreateAssetMenu(menuName = "UGUI/本地化文件")]
    public class Localization : ScriptableObject
    {
        public const char SEP = ',';
        
        [SerializeField]
        [UnityEngine.Serialization.FormerlySerializedAs("localizeText")]
        [NamedProperty("导出文件")]
        private TextAsset m_LocalizeText;
#if UNITY_EDITOR
        [System.Serializable]
        public struct CustomLoc
        {
            public string key, value;
            public override string ToString()
            {
                return string.Format("[{0}={1}]", key, value);
            }
        }

        [SerializeField]
        private CustomLoc[] m_CustomTexts;
        public CustomLoc[] customTexts { get { return m_CustomTexts; } set { m_CustomTexts = value; } }
        
        public IEnumerator<CustomLoc> GetIterator(string lang)
        {
            var langIdx = FindLangIndex(lang);
            foreach (var kv in m_Dict) {
                yield return new CustomLoc {key = kv.Key, value = kv.Value[langIdx]};
            }
        }
#endif

        private string[] m_Langs;
        private Dictionary<string, string[]> m_Dict;
        
        public string[] GetKeys()
        {
            return m_Dict.Keys.ToArray();
        }

        private int m_CurrentLang;
        public string currentLang {
            get { return m_Langs[m_CurrentLang]; }
            set {
                var lang = value;
                if (m_Dict == null) {
                    m_Dict = new Dictionary<string, string[]>();
                    // 加载本地化文本
                    if (m_LocalizeText) {
                        LoadLocalization(m_LocalizeText.text, out m_Langs, m_Dict);
                    } else {
                        LogMgr.W("本地化设置失败：本地化文本不存在");
                        return;
                    }
                }

                for (int i = 0; i < m_Langs.Length; ++i) {
                    if (string.Compare(lang, m_Langs[i], true) == 0) {
                        m_CurrentLang = i;
                        return;
                    }
                }

                LogMgr.W("不存在该本地化配置：{0}", lang);
            }
        }

        public void Reset()
        {
            m_Langs = null;
            m_Dict = null;
        }

        public int FindLangIndex(string lang)
        {
            for (int i = 0; i < m_Langs.Length; ++i) {
                if (string.Compare(lang, m_Langs[i], true) == 0) {
                    return i;
                }
            }
            return -1;
        }

        /// <summary>
        /// 获取本地化文本，如果不存在则返回null值
        /// </summary>
        public string Get(string key)
        {
            if (m_Dict == null) {
                LogMgr.W("本地化配置未初始化。");
                return key;
            }

            string[] values;
            if (m_Dict.TryGetValue(key, out values)) {
                if (values.Length > m_CurrentLang) {
                    return values[m_CurrentLang];
                }
            }

            return null;
        }

        public string Get(string key, int lang)
        {
            if (m_Dict == null) {
                LogMgr.W("本地化配置未初始化。");
                return key;
            }

            string[] values;
            if (m_Dict.TryGetValue(key, out values)) {
                if (values.Length > lang) {
                    return values[lang];
                }
            }

            return null;
        }

        public string Get(string key, string lang)
        {
            if (m_Dict == null) {
                LogMgr.W("本地化配置未初始化。");
                return key;
            }

            var langIdx = -1;
            for (int i = 0; i < m_Langs.Length; ++i) {
                if (m_Langs[i] == lang) {
                    langIdx = i;
                    break;
                }
            }

            if (langIdx < 0) return null;
            
            string[] values;
            if (m_Dict.TryGetValue(key, out values)) {
                return values[langIdx];
            }

            return null;
        }

        public IEnumerator<string> Find(string value, string lang)
        {
            var langIdx = FindLangIndex(lang);
            foreach (var kv in m_Dict) {
                var loc = kv.Value[langIdx];
                if (string.CompareOrdinal(value, loc) == 0) yield return kv.Key;
            }
        }

        /// <summary>
        /// 设置或者更改一个本地化配置
        /// </summary>
        public void Set(string key, string value, bool forceSet = false)
        {
            if (m_Dict == null) {
                LogMgr.W("本地化配置未初始化。");
                return;
            }

            if (m_CurrentLang < m_Langs.Length) {

                string[] values;
                m_Dict.TryGetValue(key, out values);

                if (values == null) {
                    values = new string[m_Langs.Length];
                    m_Dict[key] = values;

                    values[0] = key;
                }
                for (int i = 1; i < m_Langs.Length; ++i) {
                    if (i == m_CurrentLang) {
                        if (forceSet || string.IsNullOrEmpty(values[i])) {
                            values[i] = value;
                        }
                    } else if (string.IsNullOrEmpty(values[i])) {
                        values[i] = "xxx";
                    }
                }
            }
        }

        /// <summary>
        /// 判断一个key是否被本地化
        /// </summary>
        public bool IsLocalized(string key)
        {
            if (m_Dict == null) {
                LogMgr.W("本地化配置未初始化。");
                return false;
            }

            string[] values;
            if (m_Dict.TryGetValue(key, out values)) {
                if (values.Length > m_CurrentLang) {
                    return true;
                }
            }

            return false;
        }

        public static string[] SplitCsvLine(string line)
        {
            return (from System.Text.RegularExpressions.Match m in System.Text.RegularExpressions.Regex.Matches(line,
                    @"(((?<x>(?=[,\r\n]+))|""(?<x>([^""]|"""")+)""|(?<x>[^,\r\n]+)),?)", 
                    System.Text.RegularExpressions.RegexOptions.ExplicitCapture)
                select m.Groups[1].Value).ToArray();
        }
        
        /// <summary>
        /// 加载本地化数据
        /// </summary>
        public static void LoadLocalization(string text, out string[] langs, Dictionary<string, string[]> dict)
        {
            text = text.Trim();
            using (System.IO.StringReader reader = new System.IO.StringReader(text)) {
                // 表头
                var header = reader.ReadLine();
                if(string.IsNullOrEmpty(header)) {
                    header = string.Format("KEY{0}cn{0}en", SEP);
                }

                langs = SplitCsvLine(header);

                for (;;) {
                    var line = reader.ReadLine();
                    if (line == null) break;

                    var values = SplitCsvLine(line);
                    if (values.Length > 0) {
                        for (int i = 0; i < values.Length; i++) {
                            values[i] = values[i].Replace("\\n", "\n");
                        }
                        if (values.Length < langs.Length) {
                            System.Array.Resize(ref values, langs.Length);
                        }

                        try {
                            dict.Add(values[0], values);
                        } catch (System.Exception) {
                            LogMgr.E("LoadLocalization ERROR:{0}", JSON.Dump(values));
                            throw;
                        }
                    }
                }
            }
        }

#if UNITY_EDITOR

        public void MarkLocalization(List<string> keys)
        {
            keys.AddRange(m_Dict.Keys);
        }

        public void SaveLocalization()
        {
            var path = UnityEditor.AssetDatabase.GetAssetPath(m_LocalizeText);
            var list = new List<string>();

            var strbld = new System.Text.StringBuilder();
            foreach (var values in m_Dict.Values) {
                if (string.IsNullOrEmpty(values[m_CurrentLang])) {
                    LogMgr.D("移除：{0}", values[0]);
                    continue;
                }

                for (int i = 0; i < values.Length; ++i) {
                    var value = values[i].Replace("\r", string.Empty).Replace("\n", "\\n");
                    if (i > 0) strbld.Append(SEP);
                    if (value.Contains(',')) {
                        value = value.Replace("\"", "\"\"");
                        strbld.AppendFormat("\"{0}\"", value);
                    } else {
                        strbld.Append(value);
                    }
                }
                list.Add(strbld.ToString());
                strbld.Remove(0, strbld.Length);
            }
            list.Sort(string.CompareOrdinal);

            using (var stream = new System.IO.StreamWriter(path)) {
                stream.Write("KEY");
                for (int i = 1; i < m_Langs.Length; ++i) {
                    stream.Write(SEP + m_Langs[i]);
                }
                stream.WriteLine();
                foreach (var line in list) {
                    stream.Write(line);
                    stream.WriteLine();
                }
            }
        }
#endif
    }
}

