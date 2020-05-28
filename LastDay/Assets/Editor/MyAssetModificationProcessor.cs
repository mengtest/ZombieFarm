using UnityEditor;
using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class MyAssetModificationProcessor : UnityEditor.AssetModificationProcessor
{
    [InitializeOnLoadMethod]
    private static void StartInitializeOnLoadMethod()
    {
        PrefabUtility.prefabInstanceUpdated = delegate (GameObject instance) {
            //prefab保存的路径
            var prefab = PrefabUtility.GetCorrespondingObjectFromSource(instance) as GameObject;
            var path = AssetDatabase.GetAssetPath(prefab);
            foreach (var kv in s_PrefabHandlers) {
                if (path.Contains(kv.Key)) {
                    kv.Value.Invoke(prefab, instance);
                }
            }
        };
    }

    /// <summary>
    /// 当保存场景或者.asset文件时触发此方法
    /// </summary>
    private static string[] OnWillSaveAssets(string[] paths)
    {
        foreach (string path in paths) {
            if (path.OrdinalEndsWith(".unity")) {
                var lib = Object.FindObjectOfType(typeof(ZFrame.Asset.ObjectLibrary)) as ZFrame.Asset.ObjectLibrary;
                if (lib != null) {
                    // 更新缓存用了描边材质的Renderer
                    lib.Clear();
                    foreach (var obj in Object.FindObjectsOfType<Renderer>()) {
                        var mat = obj.sharedMaterial;
                        if (mat && mat.shader.name.Contains(World.View.MaterialSet.OUTLINE)) {
                            lib.Set(obj);
                        }
                    }
                }
            }

            //var assetPath = path;
            //if (assetPath.EndsWith(".meta")) {
            //    assetPath = assetPath.Substring(0, assetPath.Length - 5);
            //}
            //var obj = AssetDatabase.LoadMainAssetAtPath(assetPath);
            //var lbs = AssetDatabase.GetLabels(obj);
            //foreach (var lb in lbs) LogMgr.D(lb);
        }
        return paths;
    }

    private static Dictionary<string, System.Action<GameObject, GameObject>> s_PrefabHandlers
        = new Dictionary<string, System.Action<GameObject, GameObject>>() {
        { "Assets/RefAssets/OBO/Weapon", OnWeaponPrefabUpdated },
        { "Assets/RefAssets/CATEGORY/FX", OnFxPrefabUpdated },
        { "Assets/RefAssets/BUNDLE/UI", OnUIPrefabUpdated },
    };

    private static void OnWeaponPrefabUpdated(GameObject prefab, GameObject instance)
    {
        var rdrs = prefab.GetComponentsInChildren<Renderer>();
        foreach (var rdr in rdrs) {
            rdr.lightProbeUsage = UnityEngine.Rendering.LightProbeUsage.Off;
            rdr.reflectionProbeUsage = UnityEngine.Rendering.ReflectionProbeUsage.Off;
        }
    }

    private static void OnFxPrefabUpdated(GameObject prefab, GameObject instance)
    {
        var rdrs = prefab.GetComponentsInChildren<Renderer>();
        foreach (var rdr in rdrs) {
            if (rdr.name.EndsWith("_SHADOW")) {
                rdr.shadowCastingMode = UnityEngine.Rendering.ShadowCastingMode.On;
            } else {
                rdr.shadowCastingMode = UnityEngine.Rendering.ShadowCastingMode.Off;
            }
            rdr.receiveShadows = false;
            rdr.lightProbeUsage = UnityEngine.Rendering.LightProbeUsage.Off;
            rdr.reflectionProbeUsage = UnityEngine.Rendering.ReflectionProbeUsage.Off;
        }
    }

    private static void OnUIPrefabUpdated(GameObject prefab, GameObject instance)
    {
        var sps = prefab.GetComponentsInChildren<ZFrame.UGUI.UISprite>(true);
        foreach (var sp in sps) {
            if (!string.IsNullOrEmpty(sp.atlasName)) {
                if (sp.sprite) {
                    sp.sprite = null;
                    //using (var so = new SerializedObject(sp)) {
                    //    so.FindProperty("m_Sprite").objectReferenceValue = null;
                    //    so.ApplyModifiedPropertiesWithoutUndo();
                    //}
                }
            }
        }

        var texes = prefab.GetComponentsInChildren<ZFrame.UGUI.UITexture>(true);
        foreach (var tex in texes) {
            if (!string.IsNullOrEmpty(tex.texPath)) {
                if (tex.texture) tex.texture = null;
            }
        }

        var lbs = prefab.GetComponentsInChildren<ZFrame.UGUI.ILabel>(true);
        foreach (var lb in lbs) {
            var tmpLb = lb as ZFrame.UGUI.UIText;
            if (tmpLb && tmpLb.font != null) {
                var path = AssetDatabase.GetAssetPath(tmpLb.font);
                var ai = AssetImporter.GetAtPath(path);
                if (string.IsNullOrEmpty(ai.assetBundleName)) {
                    Debug.LogWarningFormat("字体资源{0}未标志为AssetBundle", path);
                    continue;
                }

                var abName = SystemTools.TrimPathExtension(ai.assetBundleName);
                using (var so = new SerializedObject(tmpLb)) {
                    var tmpText = (TMPro.TextMeshProUGUI)tmpLb;
                    var fontMat = tmpText.fontSharedMaterial;
                    var matName = string.CompareOrdinal(fontMat.name, tmpLb.font.material.name) != 0
                        ? fontMat.name
                        : string.Empty;
                    so.FindProperty("m_FontName").stringValue = string.Format("{0}/{1}", abName, matName);
                    so.ApplyModifiedPropertiesWithoutUndo();
                }
            }
            
            if (lb.localized && string.IsNullOrEmpty(lb.rawText)) {
                var mono = (Component)lb;
                Debug.LogWarningFormat("{0}/{1}标志为本地化，但是没有提供本地化键值。", 
                    prefab.name, mono.GetHierarchy(prefab.transform));
            }
        }
    }
}
