using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using UnityEditor;

namespace World
{
    using View;

    public class ResCheckWindow : EditorWindow
    {
        [MenuItem("Custom/资源规范检查...")]
        private static void OpenWindow()
        {
            GetWindowWithRect(typeof(ResCheckWindow), new Rect(0, 0, 220, 600), false, "规范检查");
        }

        private GUIContent m_UnitOverview = new GUIContent("检查对象", "检查所有Units下面的预制体");

        private void OnGUI()
        {
            GUILayout.Label(this.GetType().Name);

            if (GUILayout.Button(m_UnitOverview)) {
                CHK_UnitOverview();
            }
        }

        private static void CHK_UnitOverview(GameObject prefab, GameObject go)
        {
            var goname = go.name;

            var rdr = go.GetComponentInChildren(typeof(Renderer)) as Renderer;
            if (rdr == null) {
                Debug.LogErrorFormat(prefab, "对象缺少Renderer @ {0}", goname);
            }

            var objAnim = go.GetComponent(typeof(ObjAnim));
            if (objAnim == null && rdr && go != rdr.gameObject) {
                Debug.LogErrorFormat(prefab, "对象预设缺少<ObjAnim> @ {0}", goname);
            }

            var anim = go.GetComponentInChildren(typeof(Animator)) as Animator;
            if (anim == null) {
                if (rdr is SkinnedMeshRenderer)
                    Debug.LogWarningFormat(prefab, "对象无动画，却使用了蒙皮网格 @ {0}", goname);
            } else {
                if (anim.runtimeAnimatorController == null) {
                    Debug.LogWarningFormat(prefab, "对象有动画状态机，但控制器<AnimatorController>为空 @ {0}", goname);
                }
            }
        }

        private static void CHK_UnitOverview()
        {
            var paths = System.IO.Directory.GetFiles(string.Format("Assets/{0}/OBO/Units", AssetPacker.DIR_ASSETS),
                "*.prefab");
            foreach (var path in paths) {
                var o = AssetDatabase.LoadAssetAtPath<GameObject>(path);
                if (o == null) continue;

                var go = Instantiate(o);
                go.name = o.name;

                var rdr = go.GetComponentInChildren(typeof(Renderer)) as Renderer;
                if (rdr == null) {
                    Debug.LogErrorFormat(o, "对象缺少Renderer @ {0}", o.name);
                }

                var multi = go.GetComponent(typeof(MultiView)) as MultiView;
                if (multi != null) {
                    foreach (Transform trans in multi.transform) {
                        CHK_UnitOverview(o, trans.gameObject);
                    }
                } else {
                    CHK_UnitOverview(o, go);
                }

                DestroyImmediate(go);
            }
        }

        [MenuItem("Custom/刷新Shader集")]
        private static void RefreshShaderList()
        {
            const string BUNDLE = "shaders";
            const string BUNDLE_PREFAB = "Assets/Shaders/Shaders.prefab";
            
            HashSet<Shader> set = new HashSet<Shader>();

            Dictionary<string, List<string>> trackShaders = new Dictionary<string, List<string>>();

            foreach (var path in AssetDatabase.GetAssetPathsFromAssetBundle(BUNDLE)) {
                AssetImporter.GetAtPath(path).assetBundleName = null;
            }
            
            var abs = AssetDatabase.GetAllAssetBundleNames();
            foreach (var ab in abs) {
                if (ab == BUNDLE) continue;
                var deps = AssetDatabase.GetAssetPathsFromAssetBundle(ab);
                List<string> list = new List<string>();
                foreach (var path in AssetDatabase.GetDependencies(deps)
                    .Where(k => k.OrdinalIgnoreCaseEndsWith(".shader"))) {
                    var shader = AssetDatabase.LoadAssetAtPath<Shader>(path);
                    if (shader) {
                        set.Add(shader);
                        list.Add(shader.name);
                        AssetImporter.GetAtPath(path).assetBundleName = BUNDLE;
                    }
                }

                if (list.Count > 0)
                    trackShaders.Add(ab, list);
            }

            var obj = AssetDatabase.LoadAssetAtPath<GameObject>(BUNDLE_PREFAB);
            var shaders = obj.GetComponent<Shaders>();
            shaders.ShaderList.Clear();
            shaders.ShaderList.AddRange(set);
            shaders.ShaderList.Sort((a, b) => string.CompareOrdinal(a.name, b.name));
            
            AssetImporter.GetAtPath(BUNDLE_PREFAB).assetBundleName = BUNDLE;
            
            AssetDatabase.SaveAssets();

            System.IO.File.WriteAllText("Temp/shaders.txt", TinyJSON.JSON.Dump(trackShaders));
        }
    }
}
