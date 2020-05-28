using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace World.View
{
    [CreateAssetMenu(menuName = "资源库/皮肤图集")]
    public class SkinAtlas : ScriptableObject
    {
        /// <summary>
        /// 漏出头发的头盔，后缀标志
        /// </summary>
        public const string HairTAG = "_H";

        [System.Serializable]
        public class SkinTex
        {
            public string name;
            public Rect uv;
            public bool subhair;
            public SkinTex(string name, Rect uv)
            {
                if (name.OrdinalEndsWith(HairTAG)) {
                    name = name.Substring(0, name.Length - HairTAG.Length);
                    subhair = true;
                } else {
                    subhair = false;
                }

                this.name = name;
                this.uv = uv;
            }
        }

        [SerializeField, HideInInspector]
        private Texture2D m_SkinTex;
        public Texture2D skinTex { get { return m_SkinTex; } }

        [SerializeField]
        private List<SkinTex> m_List;
        public List<SkinTex> Skins { get { return m_List; } }

        public bool FindSkinUV(string name, out Rect uv, out bool subhair)
        {
            uv = Rect.zero;
            subhair = false;
            foreach (var elm in m_List) {
                if (string.CompareOrdinal(elm.name, name) == 0) {
                    uv = elm.uv;
                    subhair = elm.subhair;
                    return true;
                }
            }
            return false;
        }
    }
}
