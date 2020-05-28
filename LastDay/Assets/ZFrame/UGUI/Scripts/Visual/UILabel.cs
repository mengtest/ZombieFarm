using UnityEngine;
using System.Collections;
using NoToLua = XLua.BlackListAttribute;

namespace ZFrame.UGUI
{
    using Asset;
    using Tween;

    public delegate void TextChanged(string newText);

    public interface ILabel
    {
        event TextChanged onTextChanged;
        string rawText { get; }
        string text { get; set; }
        bool localized { get; set; }
    }

    //[XLua.CSharpCallLua]
    public class UILabel : UnityEngine.UI.Text, ITweenable, ILabel
    {
        private const string OMIT_STR = "...";

        private string m_Lang;

        private static Localization _Localization;
        [NoToLua]
        public static Localization LOC {
            get {
#if UNITY_EDITOR
                var defLang = UGUITools.settings.defaultLang;
                if (!Application.isPlaying && (_Localization == null || _Localization.currentLang != defLang)) {
                    _Localization = (Localization)AssetLoader.EditorLoadAsset(typeof(Localization), 
                        UGUITools.settings.locAssetPath);
                    _Localization.Reset();
                    _Localization.currentLang = defLang;
                }
#endif
                return _Localization;
            }
            set { _Localization = value; }
        }

        public event TextChanged onTextChanged;

        public bool omit;
        private string m_OmitText;
        public bool omited { get { return !string.IsNullOrEmpty(m_OmitText); } }

        [SerializeField]
        private bool m_Localized;
        public bool localized { get { return m_Localized; } set { m_Localized = value; } }

        [SerializeField]
        private bool m_bNoBreakSpace = false;

        private string ReplaceBreakSpace(string str)
        {
            if (m_bNoBreakSpace) {
                str = str.Replace(" ", "\u00A0");
            }
            return str;
        }

        private void UpdateOmit()
        {
            m_Text = ReplaceBreakSpace(m_Text);
            m_OmitText = null;
            if (omit) {
                var settings = GetGenerationSettings(Vector2.zero);
                var generator = cachedTextGeneratorForLayout;
                var width = generator.GetPreferredWidth(m_Text, settings) / pixelsPerUnit;
                var rectWidth = rectTransform.rect.width;
                if (width > rectWidth) {
                    var omitWidth = generator.GetPreferredWidth(OMIT_STR, settings) / pixelsPerUnit;
                    var clampWidth = rectWidth - omitWidth;

                    var length = m_Text.Length - 1;
                    for (int i = length; i > 0; --i) {
                        var omitText = m_Text.Substring(0, i);
                        var testWidth = generator.GetPreferredWidth(omitText, settings) / pixelsPerUnit;
                        if (testWidth <= clampWidth) {
                            m_OmitText = omitText + OMIT_STR;
                            return;
                        }
                    }
                    m_OmitText = OMIT_STR;
                    return;
                }

                settings = GetGenerationSettings(new Vector2(GetPixelAdjustedRect().size.x, 0.0f));
                var height = generator.GetPreferredHeight(m_Text, settings) / pixelsPerUnit;
                var rectHeight = rectTransform.rect.height;
                if (height > rectHeight) {
                    var omitText = m_Text;
                    for (; ; ) {
                        var idx = omitText.LastIndexOf('\n');
                        if (idx < 0) break;
                        omitText = omitText.Substring(0, idx);
                        var omitHeight = generator.GetPreferredHeight(omitText, settings) / pixelsPerUnit;
                        if (omitHeight <= rectHeight) {
                            break;
                        }
                    }
                    m_OmitText = omitText;
                }
            }
        }

        private void UpdateLoc()
        {
            var getText = m_RawText;
            if (localized) {
#if UNITY_EDITOR
                if (!Application.isPlaying) {
                    return;
                }
#endif
                if (LOC) {
                    var txt = LOC.Get(getText);
                    if (txt != null) {
                        getText = txt;
                    } else {
                        if (Application.isPlaying) {
                            LogMgr.W("本地化获取失败：Lang = {0}, Key = {1} @ {2}",
                                LOC.currentLang, m_Text, rectTransform.GetHierarchy(null));
                        }
                    }
                }
            }

            base.text = getText;
        }

        public override string text {
            get { return !string.IsNullOrEmpty(m_OmitText) ? m_OmitText :m_Text; }
            set {
                if (m_RawText != value) {
                    m_RawText = value;
                    UpdateLoc();
                    UpdateOmit();
                    if (onTextChanged != null) {
                        onTextChanged.Invoke(m_RawText);
                    }
                }
            }
        }

        [SerializeField]
        private string m_RawText;
        public string rawText { get { return m_RawText; } }

        public string textFormat = "{0}";
        public void SetFormatArgs(params object[] args)
        {
            text = string.Format(textFormat, args);
        }
        public void UpdateNumber(float value)
        {
            SetFormatArgs(value);
        }

        public ZTweener Tween(object from, object to, float duration)
        {
            ZTweener tw = null;
            var s = to as string;
            if (s != null) {
                tw = this.TweenString(s, duration);
                if (from != null) {
                    text = (string)from;
                    tw.StartFrom(text);
                }
            }
            if (to is Color) {
                tw = this.TweenColor((Color)to, duration);
                if (from is Color) {
                    color = (Color)from;
                    tw.StartFrom(color);
                }
            }
            if (to is float) {
                tw = this.TweenAlpha((float)to, duration);
                if (from is float) {
                    var a = (float)from;
                    color = new Color(color.r, color.g, color.b, a);
                    tw.StartFrom(a);
                }
            }
            if (tw != null) tw.SetTag(this);
            return tw;
        }

        protected override void Awake()
        {
            base.Awake();

            if (!localized) m_RawText = m_Text;
        }

        protected override void Start()
        {
#if UNITY_EDITOR
            UGUITools.AutoUIRoot(this);
#endif
            base.Start();
        }

        protected void InitText()
        {
            if (localized && LOC && m_Lang != LOC.currentLang) {
                m_Lang = LOC.currentLang;
                UpdateLoc();
                UpdateOmit();
            }
        }

        protected override void OnEnable()
        {
            base.OnEnable();
            InitText();
        }

        protected override void OnCanvasHierarchyChanged()
        {
            if (isActiveAndEnabled) {
                InitText();
            }

            base.OnCanvasHierarchyChanged();
        }

        protected override void OnRectTransformDimensionsChange()
        {
            base.OnRectTransformDimensionsChange();

            UpdateOmit();
        }

//#if UNITY_EDITOR
//        protected override void OnValidate()
//        {
//            base.OnValidate();
//
//            if (!Application.isPlaying) {
//                if (!string.IsNullOrEmpty(m_RawText)) {
//                    UpdateLoc();
//                    UpdateOmit();
//                }
//            }
//        }
//#endif
    }
}
