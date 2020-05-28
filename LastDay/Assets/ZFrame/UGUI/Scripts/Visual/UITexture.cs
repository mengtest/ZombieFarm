using UnityEngine;
using UnityEngine.UI;
using System.Collections;

namespace ZFrame.UGUI
{
    using Asset;
    using Tween;

    public class UITexture : RawImage, ITweenable
    {
        public static Texture LoadTexture(string path, bool warnIfMissing)
        {
#if UNITY_EDITOR
            if (AssetsMgr.A == null) {
                string bundleName, assetName;
                AssetLoader.GetAssetpath(path, out bundleName, out assetName);
                var paths = UnityEditor.AssetDatabase.GetAssetPathsFromAssetBundleAndAssetName(bundleName, assetName);
                return UnityEditor.AssetDatabase.LoadAssetAtPath<Texture>(paths[0]);
            }
#endif
            return AssetsMgr.A.Load(typeof(Texture), path, warnIfMissing) as Texture;
        }

        [SerializeField, HideInInspector]
        private string m_TexPath;
        public string texPath { get { return m_TexPath; } }

        [SerializeField]
        private Image.Type m_Type;
        public Image.Type type {
            get { return m_Type; }
            set {
                m_Type = value;
            }
        }

        public bool grayscale {
            get { return material == UGUITools.ToggleGrayscale(material, true); }
            set { material = UGUITools.ToggleGrayscale(material, value); }
        }

        private static DelegateObjectLoaded OnTextureLoaded = (string a, object o, object param) => {
            var uiTex = (UITexture)param;
            uiTex.texture = o as Texture;
            uiTex.SetVerticesDirty();
            uiTex.SetMaterialDirty();

            if (uiTex.texture == null) {
                LogMgr.W("Load <Texture> Fail! path = \"{0}\"", a);
            }
        };

        public void SetTexture(string path)
        {
            if (!string.IsNullOrEmpty(path)) {
                var tex = LoadTexture(path, false);
                if (tex == null) {
                    AssetsMgr.A.LoadAsync(typeof(Texture), path, LoadMethod.Cache, OnTextureLoaded, this);
                } else {
                    OnTextureLoaded(path, tex, this);
                }
            } else {
                texture = null;
            }
        }

        protected void ImageTypeChanged()
        {
            if (texture == null) return;

            switch (type) {
                case Image.Type.Tiled: {
                        var uv = uvRect;
                        Vector2 size = rectTransform.rect.size;
                        uv.size = new Vector2(size.x / texture.width, size.y / texture.height);
                        uvRect = uv;
                    }
                    break;
                case Image.Type.Simple:
                    // 不会修改uvRect
                    break;
                default:
                    LogMgr.W("{0} is not support for UITexture.", type);
                    break;
            }
        }

        protected override void Awake()
        {
            base.Awake();
            enabled = true;
        }

        protected override void Start()
        {
#if UNITY_EDITOR
            UGUITools.AutoUIRoot(this);
#endif
            base.Start();
        }

        private void ResetTexture()
        {
            if (texture == null && !string.IsNullOrEmpty(m_TexPath)) {
                SetTexture(m_TexPath);
            }
        }

        protected override void OnEnable()
        {
            base.OnEnable();
            ResetTexture();
        }

        protected override void OnRectTransformDimensionsChange()
        {
            base.OnRectTransformDimensionsChange();
            ImageTypeChanged();
        }

        protected override void OnPopulateMesh(VertexHelper toFill)
        {
            if (texture) {
                base.OnPopulateMesh(toFill);
            } else {
                toFill.Clear();
            }
        }

        protected override void OnCanvasHierarchyChanged()
        {
            if (isActiveAndEnabled && canvas && canvas.enabled) {
                ResetTexture();
            }
            base.OnCanvasHierarchyChanged();
        }

        private Vector2 GetUVOffset() { return uvRect.position; }
        private void SetUVOffset(Vector2 position)
        {
            var uv = uvRect;
            uv.position = position;
            uvRect = uv;
        }

        public ZTweener Tween(object from, object to, float duration)
        {
            ZTweener tw = null;
            if (to is Color) {
                tw = this.TweenColor((Color)to, duration);
                if (from is Color) {
                    tw.StartFrom((Color)from);
                }
            } else if (to is float) {
                tw = this.TweenAlpha((float)to, duration);
                if (from is float) {
                    var fromColor = color;
                    fromColor.a = (float)from;
                    color = fromColor;
                    tw.StartFrom(color);
                }
            } else if (to is Vector2) {
                tw = this.Tween(GetUVOffset, SetUVOffset, (Vector2)to, duration);
                if (from is Vector2) {
                    tw.StartFrom((Vector2)from);
                }
            } else if (to is Vector4) {
            }
            if (tw != null) tw.SetTag(this);
            return tw;
        }

#if UNITY_EDITOR
        protected override void OnValidate()
        {
            base.OnValidate();
            ImageTypeChanged();
        }
#endif

    }

}
