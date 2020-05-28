#define USING_TMP
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEditor;
using System.Collections;
using System.Collections.Generic;
using TMPro;

// warning CS0168: 声明了变量，但从未使用
// warning CS0219: 给变量赋值，但从未使用
#pragma warning disable 0168, 0219, 0414
namespace ZFrame.UGUI
{
#if USING_TMP
    using _Label = UIText;
    using _TextAnchor = TMPro.TextAlignmentOptions;
    using _FontStyle = TMPro.FontStyles;
#else
    using _Label = UILabel;
    using _TextAnchor = TextAnchor;
    using _FontStyle = FontStyle;
#endif
    public static class UGUICreateMenu
    {
        private const string kUILayerName = "UI";
        private const float kWidth = 160f;
        private const float kThickHeight = 60f;
        private const float kThinHeight = 40f;
        private const string kStandardSpritePath = "UI/Skin/UISprite.psd";
        private const string kBackgroundSpriteResourcePath = "UI/Skin/Background.psd";
        private const string kInputFieldBackgroundPath = "UI/Skin/InputFieldBackground.psd";
        private const string kKnobPath = "UI/Skin/Knob.psd";
        private const string kCheckmarkPath = "UI/Skin/Checkmark.psd";

#if LANG_ZHCN
        private const string LANG = "cn";
        private const string LABEL = "文本";
        private const string BUTTON = "按钮";
        private const string TOGGLE = "切换";
        private const string ENTER_TEXT = "输入文本...";
#elif LANG_TWCN
        private const string LANG = "tw";
        private const string LABEL = "文本";
        private const string BUTTON = "按鈕";
        private const string TOGGLE = "切換";
        private const string ENTER_TEXT = "輸入文本...";
#else
        private const string LANG = "en";
        private const string LABEL = "Label";
        private const string BUTTON = "Button";
        private const string TOGGLE = "Toggle";
        private const string ENTER_TEXT = "Enter Text...";
#endif

        private static Vector2 s_ThickGUIElementSize = new Vector2(kWidth, kThickHeight);
        private static Vector2 s_ThinGUIElementSize = new Vector2(kWidth, kThinHeight);
        private static Vector2 s_ImageGUIElementSize = new Vector2(100f, 100f);
        private static Color s_DefaultSelectableColor = new Color(1f, 1f, 1f, 1f);
        private static Color s_PanelColor = new Color(1f, 1f, 1f, 0.392f);
        private static Color s_TextColor = Color.white;

        static RectTransform CreatUIBase(GameObject parent)
        {
            if (parent == null) parent = UGUITools.SelectedRoot(true);

            GameObject go = new GameObject("GameObject");
            go.Attach(parent ? parent.transform : null, false);
            var rectTrans = go.AddComponent<RectTransform>();
            rectTrans.anchoredPosition = Vector2.zero;
            go.AddComponent<CanvasRenderer>();
            return rectTrans;
        }

        static T CreateUIElm<T>(GameObject parent, params System.Type[] ComponentTypes) where T : MonoBehaviour
        {            
            RectTransform rect = CreatUIBase(parent);
            T c = rect.gameObject.AddComponent<T>();
            foreach (var comType in ComponentTypes) {
                rect.gameObject.AddComponent(comType);
            }
            return c;
        }

        static _Label getUILabel(GameObject parent, string name, string text)
        {
            _Label lb = CreateUIElm<_Label>(parent);
            lb.name = name;
#if USING_TMP
            lb.font = Asset.AssetLoader.EditorLoadAsset(
                typeof(TMP_FontAsset), "fonts/mainfont." + UGUITools.settings.defaultLang + '/' + "FONT") as TMP_FontAsset;
#else
            lb.font = UGUITools.lastSelectedFont;
#endif
            lb.fontSize = 24;
            lb.text = text;
            lb.color = s_TextColor;
            lb.raycastTarget = false;
            return lb;
        }

        static void setUISprite(UISprite sp, string name, string resPath, UISprite.Type spType, Color color)
        {
            sp.name = name;
            sp.sprite = AssetDatabase.GetBuiltinExtraResource<Sprite>(resPath);            
            sp.type = spType;
            sp.color = color;
            sp.enabled = sp.sprite;
            sp.raycastTarget = false;
        }

        [MenuItem("UGUI/控件/文本(_Label) &#l")]
        static void CreateUILabel()
        {
            _Label lb = getUILabel(null, "lbText", LABEL);
            lb.rectTransform.sizeDelta = s_ThinGUIElementSize;
#if USING_TMP
            lb.alignment = _TextAnchor.Center;
#else
            lb.alignment = _TextAnchor.MiddleCenter;
#endif
            lb.raycastTarget = false;
            Selection.activeGameObject = lb.gameObject;
        }

        [MenuItem("UGUI/控件/图片(Sprite) &#s")]
        static void CreateUISprite()
        {
            UISprite sp = CreateUIElm<UISprite>(null);
            sp.name = "spImage";
            sp.color = Color.white;
            sp.sprite = AssetDatabase.GetBuiltinExtraResource<Sprite>(kStandardSpritePath);
            sp.raycastTarget = false;
            sp.enabled = sp.sprite;
            Selection.activeGameObject = sp.gameObject;
        }

        [MenuItem("UGUI/控件/原始图片(Texture) &#t")]
        static void CreateUITexture()
        {
            UITexture sp = CreateUIElm<UITexture>(null);
            sp.name = "spTex";
            sp.raycastTarget = false;
            Selection.activeGameObject = sp.gameObject;
        }

        [MenuItem("UGUI/控件/按钮(Button) &#b")]
        static void CreateUIButton()
        {
            UIButton btn = CreateUIElm<UIButton>(null, typeof(UISprite));
            var sp = btn.GetComponent<UISprite>();
            setUISprite(sp, "btnButton", kStandardSpritePath, UISprite.Type.Sliced, s_DefaultSelectableColor);
            sp.raycastTarget = true;
            sp.rectTransform.sizeDelta = s_ThickGUIElementSize;
            _Label lb = getUILabel(btn.gameObject, "lbText_", BUTTON);
            lb.localized = true;
            lb.rectTransform.sizeDelta = s_ThinGUIElementSize;
#if USING_TMP
            lb.alignment = _TextAnchor.Center;
#else
            lb.alignment = _TextAnchor.MiddleCenter;
#endif
            lb.color = Color.black;

            btn.targetGraphic = sp;

            Selection.activeGameObject = btn.gameObject;
        }

        [MenuItem("UGUI/控件/切换(Toggle) &#r")]
        static void CreateUIToggle()
        {
            UIToggle tgl = CreateUIElm<UIToggle>(null);
            tgl.name = "tglToggle";
            var rectTrans = tgl.GetComponent<RectTransform>();
            rectTrans.sizeDelta = s_ThickGUIElementSize;

            UISprite spBack = CreateUIElm<UISprite>(tgl.gameObject);
            setUISprite(spBack, "spBack_", kStandardSpritePath, UISprite.Type.Sliced, s_DefaultSelectableColor);
            spBack.raycastTarget = true;
            spBack.rectTransform.anchorMin = new Vector2(0, 0.5f);
            spBack.rectTransform.anchorMax = new Vector2(0, 0.5f);
            spBack.rectTransform.sizeDelta = new Vector2(20, 20);
            spBack.rectTransform.anchoredPosition = new Vector2(10, 0);

            UISprite spChk = CreateUIElm<UISprite>(spBack.gameObject);
            setUISprite(spChk, "spChk_", kCheckmarkPath, UISprite.Type.Simple, Color.white);
            spChk.SetNativeSize();
            //spChk.rectTransform.anchorMin = new Vector2(0.5f, 0.5f);
            //spChk.rectTransform.anchorMax = new Vector2(0.5f, 0.5f);        

            _Label lb = getUILabel(tgl.gameObject, "lbText_", TOGGLE);
            lb.localized = true;
            lb.rectTransform.pivot = new Vector2(0, 0.5f);
            lb.rectTransform.anchorMin = new Vector2(0, 0.5f);
            lb.rectTransform.anchorMax = new Vector2(0, 0.5f);
            lb.rectTransform.offsetMin = new Vector2(25, 0);
            lb.rectTransform.offsetMax = new Vector2(0, 0);
            lb.rectTransform.sizeDelta = new Vector2(90, 24);
            tgl.targetGraphic = spBack;
            tgl.graphic = spChk;
            tgl.isOn = true;

            Selection.activeGameObject = tgl.gameObject;
        }

        [MenuItem("UGUI/控件/进度条(ProgressBar)")]
        static void CreateUIProgressBar()
        {
            UIProgress bar = CreateUIElm<UIProgress>(null);
            bar.name = "barProgress";
            var rectTrans = bar.GetComponent<RectTransform>();
            rectTrans.sizeDelta = new Vector2(160, 20);

            UISprite spBack = CreateUIElm<UISprite>(bar.gameObject);
            setUISprite(spBack, "spBack_", kBackgroundSpriteResourcePath, UISprite.Type.Sliced, s_DefaultSelectableColor);
            spBack.rectTransform.anchorMin = new Vector2(0, 0f);
            spBack.rectTransform.anchorMax = new Vector2(1, 1f);
            spBack.rectTransform.offsetMin = new Vector2(0, 0);
            spBack.rectTransform.offsetMax = new Vector2(0, 0);

            UISprite spFill = CreateUIElm<UISprite>(bar.gameObject);
            bar.m_CurrBar = spFill;
            setUISprite(spFill, "spFill_", kStandardSpritePath, UISprite.Type.Sliced, s_DefaultSelectableColor);
            spFill.rectTransform.offsetMin = new Vector2(0, 0);
            spFill.rectTransform.offsetMax = new Vector2(0, 0);

            Selection.activeGameObject = bar.gameObject;
        }

        [MenuItem("UGUI/控件/滑块(Slider)")]
        static void CreateUISlider()
        {
            UISlider sld = CreateUIElm<UISlider>(null);
            sld.name = "sldSlider";
            var rectTrans = sld.GetComponent<RectTransform>();
            rectTrans.sizeDelta = new Vector2(160, 20);

            UISprite spBack = CreateUIElm<UISprite>(sld.gameObject);
            sld.targetGraphic = spBack;
            setUISprite(spBack, "spBack_", kBackgroundSpriteResourcePath, UISprite.Type.Sliced, s_DefaultSelectableColor);
            spBack.raycastTarget = true;
            spBack.rectTransform.anchorMin = new Vector2(0, 0f);
            spBack.rectTransform.anchorMax = new Vector2(1, 1f);
            spBack.rectTransform.offsetMin = new Vector2(0, 0);
            spBack.rectTransform.offsetMax = new Vector2(0, 0);

            UISprite spFill = CreateUIElm<UISprite>(sld.gameObject);
            sld.fillRect = spFill.rectTransform;
            setUISprite(spFill, "spFill_", kStandardSpritePath, UISprite.Type.Sliced, s_DefaultSelectableColor);
            spFill.rectTransform.offsetMin = new Vector2(0, 0);
            spFill.rectTransform.offsetMax = new Vector2(0, 0);

            UISprite spHandle = CreateUIElm<UISprite>(sld.gameObject);
            sld.handleRect = spHandle.rectTransform;
            setUISprite(spHandle, "spHandle_", kKnobPath, UISprite.Type.Simple, s_DefaultSelectableColor);
            spHandle.rectTransform.anchoredPosition = Vector2.zero;
            spHandle.rectTransform.sizeDelta = new Vector2(20, 0);

            Selection.activeGameObject = sld.gameObject;
        }

        static UIScrollbar CreateUIScrollbar(Vector2 sizeDelta)
        {
            UIScrollbar srb = CreateUIElm<UIScrollbar>(null, typeof(UISprite));
            var rectTrans = srb.GetComponent<RectTransform>();
            rectTrans.sizeDelta = sizeDelta;

            UISprite spBack = srb.GetComponent<UISprite>();
            setUISprite(spBack, "srbScroll", kBackgroundSpriteResourcePath, UISprite.Type.Sliced, s_DefaultSelectableColor);

            UISprite spHandle = CreateUIElm<UISprite>(srb.gameObject);
            srb.handleRect = spHandle.rectTransform;
            setUISprite(spHandle, "spHandle_", kStandardSpritePath, UISprite.Type.Sliced, s_DefaultSelectableColor);
            spHandle.rectTransform.offsetMin = new Vector2(0, 0);
            spHandle.rectTransform.offsetMax = new Vector2(0, 0);
            srb.size = 0.2f;

            Selection.activeGameObject = srb.gameObject;
            return srb;
        }

        [MenuItem("UGUI/控件/滚动条(Scrollbar)/从左到右(→)")]
        static void CreateUIScrollbar_L2R()
        {
            UIScrollbar srb = CreateUIScrollbar(new Vector2(kWidth, kThinHeight));
            srb.direction = UnityEngine.UI.Scrollbar.Direction.LeftToRight;
        }

        [MenuItem("UGUI/控件/滚动条(Scrollbar)/从右到左(←)")]
        static void CreateUIScrollbar_R2L()
        {
            UIScrollbar srb = CreateUIScrollbar(new Vector2(kWidth, kThinHeight));
            srb.direction = UnityEngine.UI.Scrollbar.Direction.RightToLeft;
        }

        [MenuItem("UGUI/控件/滚动条(Scrollbar)/从下到上(↑)")]
        static void CreateUIScrollbar_B2T()
        {
            UIScrollbar srb = CreateUIScrollbar(new Vector2(kThinHeight, kWidth));
            srb.direction = UnityEngine.UI.Scrollbar.Direction.BottomToTop;
        }

        [MenuItem("UGUI/控件/滚动条(Scrollbar)/从上到下(↓)")]
        static void CreateUIScrollbar_T2B()
        {
            UIScrollbar srb = CreateUIScrollbar(new Vector2(kThinHeight, kWidth));
            srb.direction = UnityEngine.UI.Scrollbar.Direction.TopToBottom;
        }

        [MenuItem("UGUI/控件/输入框(Input)")]
        static void CreateUIInput()
        {
#if USING_TMP
            var inp = CreateUIElm<UIInputField>(null, typeof(UISprite));
            var rectTrans = inp.GetComponent<RectTransform>();
            rectTrans.sizeDelta = s_ThinGUIElementSize;

            UISprite spBack = inp.GetComponent<UISprite>();
            setUISprite(spBack, "inpInput", kInputFieldBackgroundPath, UISprite.Type.Sliced, s_DefaultSelectableColor);
            spBack.raycastTarget = true;

            var area = GoTools.CreateChild<UnityEngine.UI.RectMask2D>(rectTrans.gameObject, "Area");
            area.rectTransform.anchorMin = new Vector2(0, 0);
            area.rectTransform.anchorMax = new Vector2(1, 1);
            area.rectTransform.sizeDelta = Vector2.zero;

            _Label lbHold = getUILabel(area.gameObject, "lbHold_", ENTER_TEXT);
            lbHold.localized = true;
            inp.placeholder = lbHold;
            lbHold.rectTransform.anchorMin = new Vector2(0, 0f);
            lbHold.rectTransform.anchorMax = new Vector2(1, 1f);
            lbHold.rectTransform.sizeDelta = new Vector2(-20, -6);
            lbHold.color = Color.gray;
            lbHold.fontStyle = _FontStyle.Italic;
            lbHold.alignment = _TextAnchor.Left;

            _Label lbText = getUILabel(area.gameObject, "&lbText", "");
            inp.textComponent = lbText;
            lbText.rectTransform.anchorMin = new Vector2(0, 0f);
            lbText.rectTransform.anchorMax = new Vector2(1, 1f);
            lbText.rectTransform.sizeDelta = new Vector2(-20, -6);
            lbText.color = Color.black;
            lbText.alignment = _TextAnchor.Left;

            inp.textViewport = area.rectTransform;
            
#else
            UIInput inp = CreateUIElm<UIInput>(null, typeof(UISprite));
            var rectTrans = inp.GetComponent<RectTransform>();
            rectTrans.sizeDelta = s_ThickGUIElementSize;

            UISprite spBack = inp.GetComponent<UISprite>();
            setUISprite(spBack, "inpInput", kInputFieldBackgroundPath, UISprite.Type.Sliced, s_DefaultSelectableColor);

            _Label lbHold = getUILabel(inp.gameObject, "lbHold_", "输入文本...");
            lbHold.localize = true;
            inp.placeholder = lbHold;
            lbHold.rectTransform.anchorMin = new Vector2(0, 0f);
            lbHold.rectTransform.anchorMax = new Vector2(1, 1f);
            lbHold.rectTransform.offsetMin = new Vector2(10, 3f);
            lbHold.rectTransform.offsetMax = new Vector2(-10, -3f);
            lbHold.color = Color.gray;
            lbHold.fontStyle = _FontStyle.Italic;

            _Label lbText = getUILabel(inp.gameObject, "lbText_", "");
            inp.textComponent = lbText;
            lbText.supportRichText = false; // 输入框不支持富文本
            lbText.rectTransform.anchorMin = new Vector2(0, 0f);
            lbText.rectTransform.anchorMax = new Vector2(1, 1f);
            lbText.rectTransform.offsetMin = new Vector2(10, 3f);
            lbText.rectTransform.offsetMax = new Vector2(-10, -3f);
            lbText.color = Color.black;
#endif
            Selection.activeGameObject = inp.gameObject;
        }

        [MenuItem("UGUI/控件/滚动窗口(ScrollView)")]
        static void CreateUIScrollView()
        {
            UIScrollView view = CreateUIElm<UIScrollView>(null, typeof(UISprite), typeof(UnityEngine.UI.Mask));
            view.GetComponent<RectTransform>().sizeDelta = new Vector2(400, 400);

            UISprite spBack = view.GetComponent<UISprite>();
            setUISprite(spBack, "SubScroll", kBackgroundSpriteResourcePath, UISprite.Type.Sliced, s_PanelColor);
            spBack.raycastTarget = true;

            RectTransform rect = CreatUIBase(view.gameObject);
            rect.name = "SubContent";
            rect.anchorMin = new Vector2(0, 0f);
            rect.anchorMax = new Vector2(1, 1f);
            rect.offsetMin = new Vector2(10, 10f);
            rect.offsetMax = new Vector2(-10, -10f);
            view.content = rect;

            Selection.activeGameObject = view.gameObject;
        }

        [MenuItem("UGUI/本地化/检查")]
        public static void CheckLocConfig()
        {
            var settings = UGUITools.settings;
            if (string.IsNullOrEmpty(settings.uiBundlePath)) {
                return;
            }

            string bundleName, assetName;
            Asset.AssetLoader.GetAssetpath(settings.uiBundlePath, out bundleName, out assetName);
            var paths = AssetDatabase.GetAssetPathsFromAssetBundle(bundleName);

            var list = ListPool<Component>.Get();
            foreach (var path in paths) {
                var prefab = AssetDatabase.LoadMainAssetAtPath(path) as GameObject;
                if (prefab) {
                    var go = Object.Instantiate(prefab);
                    var dirty = false;

                    list.Clear();
                    go.GetComponentsInChildren(typeof(ILabel), list, true);
                    foreach (ILabel lb in list) {
                        var com = (Component)lb;
                        var c = com.name[com.name.Length - 1];
                        if (c == '=' || c == '_') {
                            if (!lb.localized) {
                                LogMgr.D("缺少本地化勾选：{0}/{1}", prefab.name, com.GetHierarchy(go.transform));
                            } else if (string.IsNullOrEmpty(lb.rawText)) {
                                LogMgr.W("缺少本地化键值：{0}/{1}", prefab.name, com.GetHierarchy(go.transform));
                            }
                        } else if (lb.localized) {
                            LogMgr.W("错误的本地化勾选：{0}/{1}", prefab.name, com.GetHierarchy(go.transform));
                        }
                    }

                    if (dirty) {
                        PrefabUtility.ReplacePrefab(go, prefab, ReplacePrefabOptions.ReplaceNameBased);
                        LogMgr.D("替换：{0}", prefab);
                    }
                    Object.DestroyImmediate(go);
                }
            }
            ListPool<Component>.Release(list);
        }

        [MenuItem("UGUI/本地化/更新")]
        public static void UpdateLocConfig()
        {
            var settings = UGUITools.settings;
            if (string.IsNullOrEmpty(settings.uiBundlePath) || string.IsNullOrEmpty(settings.locAssetPath)) {
                return;
            }

            var loc = Asset.AssetLoader.EditorLoadAsset(typeof(Localization),
                    settings.locAssetPath) as Localization;
            if (loc == null) {
                return;
            }
            
            loc.currentLang = settings.defaultLang;

            // 加载一次自定义文本
            var locSet = new Dictionary<string, string>();
            for (var i = 0; i < loc.customTexts.Length; ++i) {
                var custom = loc.customTexts[i];
                if (!string.IsNullOrEmpty(custom.key)) {
                    var value = loc.Get(custom.key, settings.defaultLang);
                    if (!string.IsNullOrEmpty(value)) {
                        custom.value = value;
                    }
                    if (!string.IsNullOrEmpty(custom.value)) {
                        if(locSet.ContainsKey(custom.key)) {
                            LogMgr.D("忽略重复的文本Key：Key={0}", custom.key);
                        } else {
                            locSet.Add(custom.key, custom.value);
                        }
                    } else {
                        LogMgr.D("移除空的文本Value：Key={0}", custom.key);
                    }
                } else {
                    LogMgr.D("移除空的文本Key：Value={0}", custom.value);
                }
            }

            loc.customTexts = new Localization.CustomLoc[locSet.Count];
            var n = 0;
            foreach (var kv  in locSet) {
                loc.customTexts[n++] = new Localization.CustomLoc { key = kv.Key, value = kv.Value };
            }

            var keyList = new List<string>();
            loc.Reset();
            loc.currentLang = settings.defaultLang;
            loc.MarkLocalization(keyList);

            // 记录自定义的本地化文本
            foreach (var txt in loc.customTexts) {
                loc.Set(txt.key, txt.value);
                keyList.Remove(txt.key);
            }
            LogMgr.D("自定义文本数量：{0}", loc.customTexts.Length);

            // 记录UI界面资源中的本地化文本
            string bundleName, assetName;
            Asset.AssetLoader.GetAssetpath(settings.uiBundlePath, out bundleName, out assetName);
            var paths = AssetDatabase.GetAssetPathsFromAssetBundle(bundleName);
            
            var list = ListPool<Component>.Get();
            foreach (var path in paths) {
                var prefab = AssetDatabase.LoadMainAssetAtPath(path) as GameObject;
                if (prefab) {
                    list.Clear();
                    prefab.GetComponentsInChildren(typeof(ILabel), list, true);
                    foreach (ILabel lb in list) {
                        if (!lb.localized) continue;
                        if (string.IsNullOrEmpty(lb.rawText) || string.IsNullOrEmpty(lb.text)) continue;

                        if (!loc.IsLocalized(lb.rawText)) {
                            loc.Set(lb.rawText, lb.text);
                            var com = lb as Component;
                            LogMgr.D("添加静态文本：{0} @{1}/{2}", lb.rawText, prefab.name,
                                com.transform.GetHierarchy(prefab.transform));
                        }
                        keyList.Remove(lb.rawText);
                    }
                }
            }
            ListPool<Component>.Release(list);

            foreach (var key in keyList) {
                loc.Set(key, null, true);
            }
            
            loc.SaveLocalization();
            AssetDatabase.Refresh();

            LogMgr.D("更新本地化配置完成。");
        }

        //[MenuItem("UGUI/本地化/重置key")]
        public static void ResetLocKeys()
        {
            // 记录UI界面资源中的本地化文本
            string bundleName, assetName;
            Asset.AssetLoader.GetAssetpath(UGUITools.settings.uiBundlePath, out bundleName, out assetName);
            var paths = AssetDatabase.GetAssetPathsFromAssetBundle(bundleName);
            
            var list = ListPool<Component>.Get();
            var lang = UGUITools.settings.defaultLang;
            foreach (var path in paths) {
                var prefab = AssetDatabase.LoadMainAssetAtPath(path) as GameObject;
                if (prefab == null) continue;

                var go = Object.Instantiate(prefab);
                var dirty = false;
                list.Clear();
                go.GetComponentsInChildren(typeof(UIText), list, true);
                foreach (UIText lb in list) {
                    lb.InitFont();
                    if (!lb.localized) continue;
                    var locText = lb.rawText;
                    if (string.IsNullOrEmpty(locText)) continue;
                    locText = UILabel.LOC.Get(locText, lang);
                    if (locText != null && locText != lb.text) {
                        lb.text = locText;
                        dirty = true;
                    }
                }

                if (dirty) {
                    LogMgr.D("ReplacePrefab :{0}", prefab);
                    PrefabUtility.ReplacePrefab(go, prefab, ReplacePrefabOptions.ReplaceNameBased);
                }
                Object.DestroyImmediate(go);
            }
            ListPool<Component>.Release(list);
        }
    }
}

