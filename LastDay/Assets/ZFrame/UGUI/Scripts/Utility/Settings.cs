using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace ZFrame.UGUI
{
    public class Settings : ScriptableObject
    {
        [SerializeField] private Vector2 m_DefRes;
        public Vector2 defRes { get { return m_DefRes; } }

        [SerializeField] private string m_UIBundlePath;
        public string uiBundlePath { get { return m_UIBundlePath; } }
        
        [SerializeField] private string m_AtlasRoot = "atlas/";
        public string atlasRoot { get { return m_AtlasRoot; } }
        
        [SerializeField] private float m_LongpressTime = 0.5f;
        public float longpressTime { get { return m_LongpressTime; } }

        [SerializeField] private string m_LocAssetPath;
        public string locAssetPath { get { return m_LocAssetPath; } }

        [SerializeField] private string m_DefLang = "cn";
        public string defaultLang { get { return m_DefLang; } }

    }
}
