using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace World.Control
{
    [System.Obsolete("用图集方案代替动态合并贴图")]
    public static class CombinedSkin
    {
        const int PACK_SIZ = 1024, TEX_SIZ = 256;        
        private static readonly int[] TEX_SIZES = { 256, 512, 512, 256, 128, 64, };
       
        private static readonly Texture2D[] _DefSkinTexes = new Texture2D[TEX_SIZES.Length];
        private static Texture2D GetDefSkinTex(int index)
        {
            var tex = _DefSkinTexes[index];
            if (tex == null) {
                var size = TEX_SIZES[index];
                tex = new Texture2D(size, size, TextureFormat.RGB24, false) {
                    filterMode = FilterMode.Bilinear,
                    wrapMode = TextureWrapMode.Clamp,
                    name = string.Format("def_skin_{0}x{0}", size),

                };
                var newColors = new Color[tex.width * tex.height];
                for (var i = 0; i < newColors.Length; ++i) newColors[i] = Color.black;
                tex.SetPixels(newColors);
                tex.Apply();
                _DefSkinTexes[index] = tex;
            }

            return tex;
        }

        private static readonly Texture2D[] _DefAlphaTexes = new Texture2D[TEX_SIZES.Length];
        private static Texture2D GetDefAlphaTex(int index)
        {
            var tex = _DefAlphaTexes[index];
            if (tex == null) {
                var size = TEX_SIZES[index];
                tex = new Texture2D(size, size, TextureFormat.RGB24, false) {
                    filterMode = FilterMode.Bilinear,
                    wrapMode = TextureWrapMode.Clamp,
                    name = string.Format("def_alpha_{0}x{0}", size),
                };
                var newColors = new Color[tex.width * tex.height];
                for (var i = 0; i < newColors.Length; ++i) newColors[i] = Color.white;
                tex.SetPixels(newColors);
                tex.Apply();
                _DefAlphaTexes[index] = tex;
            }

            return tex;
        }

        private class SkinGroup : System.IComparable<SkinGroup>
        {
            private int m_TexId;
            private readonly int[] m_Hashes = new int[TEX_SIZES.Length];
            public Rect[] uvs;
            public Texture2D tex;

            public int CompareTo(SkinGroup other)
            {
                var ret = m_TexId - other.m_TexId;
                if (ret != 0) return ret;

                for (int i = 0; i < m_Hashes.Length; ++i) {
                    ret = m_Hashes[i] - other.m_Hashes[i];
                    if (ret != 0) return ret;
                }

                return 0;
            }

            public void Update(int texId, Texture2D[] subTexes, bool execute)
            {
                m_TexId = texId;
                for (int i = 0; i < m_Hashes.Length; ++i) {
                    var tex = i < subTexes.Length ? subTexes[i] : null;
                    m_Hashes[i] = tex != null ? tex.GetHashCode() : 0;
                }

                if (execute) {
                    tex = new Texture2D(TEX_SIZ, TEX_SIZ) {
                        wrapMode = TextureWrapMode.Clamp,
                    };
                    uvs = tex.PackTextures(subTexes, 0, PACK_SIZ);
                    // 缩放
                    TextureScale.Bilinear(tex, TEX_SIZ, TEX_SIZ);
                }
            }

            public static SkinGroup Temp = new SkinGroup();
        }

        private static readonly List<SkinGroup> _CachedGrps = new List<SkinGroup>();

        private static Rect[] PackAndResize(Material mat, int texId, Texture2D[] subTexes)
        {
            SkinGroup.Temp.Update(texId, subTexes, false);
            SkinGroup Pack = null;
            for (int i = 0; i < _CachedGrps.Count; ++i) {
                if (_CachedGrps[i].CompareTo(SkinGroup.Temp) == 0) {
                    Pack = _CachedGrps[i];
                    _CachedGrps.RemoveAt(i);
                    break;
                }
            }

            if (Pack == null) {
                if (_CachedGrps.Count == 8) {
                    Pack = _CachedGrps[0];
                    Object.Destroy(Pack.tex);
                    Pack.tex = null;
                    _CachedGrps.RemoveAt(0);
                } else {
                    Pack = new SkinGroup();
                }
            }
            if (Pack.tex == null) {
                Pack.Update(texId, subTexes, true);   
            }
            _CachedGrps.Add(Pack);

            mat.SetTexture(texId, Pack.tex);

            return Pack.uvs;
        }

        private static readonly Texture2D[] _TempTexes = new Texture2D[TEX_SIZES.Length];
        public static Rect[] Combine(SkinnedMeshRenderer smr, List<Material> mats)
        {
            if (smr.sharedMaterial == null) {
                smr.material = new Material(Creator.objL.Get("RoleMat3rd") as Material);
            }

            var texes = _TempTexes;
            for (int i = 0; i < mats.Count; i++) {
                texes[i] = mats[i].GetTexture(ShaderIDs.MainTex) as Texture2D;
            }
            texes[texes.Length - 1] = GetDefSkinTex(texes.Length - 1);
            var uvs = PackAndResize(smr.material, ShaderIDs.MainTex, texes);

            var needSkin = false;
            for (int i = 0; i < mats.Count; i++) {
                var mTex = mats[i].GetTexture(ShaderIDs.MainTex) as Texture2D;
                texes[i] = mats[i].GetTexture(ShaderIDs.SkinTex) as Texture2D;
                if (texes[i] == null) {
                    texes[i] = GetDefSkinTex(i);
                } else if (texes[i] != mTex) {
                    needSkin = true;
                }
            }
            if (needSkin) {
                texes[texes.Length - 1] = GetDefSkinTex(texes.Length - 1);
                PackAndResize(smr.material, ShaderIDs.SkinTex, texes);
            } else {
                smr.material.SetTexture(ShaderIDs.SkinTex, null);
            }

            var needAlpha = false;
            for (int i = 0; i < mats.Count; i++) {
                texes[i] = mats[i].GetTexture(ShaderIDs.AlphaTex) as Texture2D;
                if (texes[i] == null) {
                    texes[i] = GetDefAlphaTex(i);
                } else {
                    needAlpha = true;
                }
            }
            if (needAlpha) {
                texes[texes.Length - 1] = GetDefAlphaTex(texes.Length - 1);
                PackAndResize(smr.material, ShaderIDs.AlphaTex, texes);
            } else {
                smr.material.SetTexture(ShaderIDs.AlphaTex, null);
            }

            for (int i = 0; i < texes.Length; ++i) {
                texes[i] = null;
            }

            return uvs;
        }

        public static void Uncache()
        {
            foreach (var grp in _CachedGrps) {
                Object.Destroy(grp.tex);
            }
            _CachedGrps.Clear();
        }
    }
}