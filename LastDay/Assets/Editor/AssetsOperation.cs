using UnityEngine;
using UnityEngine.UI;
using UnityEditor;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Reflection;
using ZFrame.Asset;

#pragma warning disable 0219,0414
public class AssetsOperation
{
    [MenuItem("Assets/测试")]
    static void TestSomething()
    {
        /*
		System.DateTime origin = new System.DateTime(1970, 1, 1, 8, 0, 0);
        var tick = System.DateTime.Now.Ticks - origin.Ticks;
        Debug.Log(tick);
        var span = new System.TimeSpan(tick);
        Debug.Log(span.TotalSeconds);
        //*/
        /*
        string data = System.IO.File.ReadAllText(UniLua.LuaRoot.Path + "/framework/clock.lua");
        byte[] encData = System.Text.Encoding.UTF8.GetBytes(data);
        CLZF2.Encrypt(encData, encData.Length);
        LogMgr.D(System.Text.Encoding.UTF8.GetString(encData));
        CLZF2.Decrypt(encData, encData.Length);
        LogMgr.D(System.Text.Encoding.UTF8.GetString(encData));
		//*/

        // 批量替换怪物的材质，保存了其Alpha贴图。
        /*
        foreach (var prefab in Selection.gameObjects) {
            var mat = AssetDatabase.LoadAssetAtPath<Material>(
                string.Format("Assets/RefAssets/Models/Skin/{0}/{0}.mat", prefab.name));
            if (mat) {
                prefab.GetComponentInChildren<Renderer>().sharedMaterial = mat;
            } else {
                LogMgr.D("{0} 没有对应材质。", prefab.name);
            }
        }
        AssetDatabase.Refresh();
        //*/
    }

    [MenuItem("Assets/查找定义了Update的脚本")]
    private static void FindMonoBehaviorWithUpdate()
    {
        var monoType = typeof(MonoBehaviour);
        var assemblies = System.AppDomain.CurrentDomain.GetAssemblies();
        foreach (var assembly in assemblies) {
            var assembleName = assembly.FullName;
            if (assembleName.Contains("Editor") || assembleName.Contains("UnityEngine")) continue;
            
            
            if (assembleName.StartsWith("Assembly-CSharp")) {
                foreach (var type in assembly.GetTypes().Where(type => type.IsSubclassOf(monoType))) {
                    foreach (var method in type.GetMethods((BindingFlags)(-1))) {
                        if (method.Name == "Update") {
                            LogMgr.D("{0}:Update", type.FullName);
                            break;
                        }
                    }
                }
            }
        }
        
    }

    /*
     [MenuItem("Assets/导出FMOD音效列表")]
    private static void ExportFMODEvents()
    {
        var fmodCache = AssetDatabase.LoadAssetAtPath<FMODUnity.EventCache>("Assets/FMODStudioCache.asset");

        var file = File.CreateText("fmodcache.csv");
        file.Write("BANKS,EVENT,Panning,Oneshot,Length,Streaming,Distance,Params");
        file.WriteLine();

        foreach (var evt in fmodCache.EditorEvents) {
            var strbld = new System.Text.StringBuilder();

            // banks
            strbld.Append('"');
            for (int i = 0; i < evt.Banks.Count; ++i) {
                if (i > 0) strbld.Append(',');
                strbld.Append(evt.Banks[i].Name);
            }
            strbld.Append('"').Append(',');
            strbld
                .Append(evt.Path).Append(',')
                .Append(evt.Is3D ? "3D" : "2D").Append(',')
                .Append(evt.IsOneShot).Append(',')
                .Append(evt.Length).Append(',')
                .Append(evt.IsStream).Append(',')
                .AppendFormat("{0}~{1}", evt.MinDistance, evt.MaxDistance).Append(',');

            // params
            for (int i = 0; i < evt.Parameters.Count; ++i) {
                var param = evt.Parameters[i];
                if (i > 0) strbld.Append(';');
                strbld.AppendFormat("{0}({1}~{2}:{3})", param.Name, param.Min, param.Max, param.Default);
            }
            file.Write(strbld.ToString());
            file.WriteLine();
        }
        file.Close();
    }

         
         */

    private static string GetAssetsRoot(string path)
    {
        return string.Format("Assets/{0}/{1}", AssetBundleLoader.DIR_ASSETS, path);
    }

    /// <summary>
    /// 目录下的资源以各自的名称独立命名
    /// </summary>
    private static void markSingleAssetName(
        string rootDir,
        string group,
        string pattern,
        SearchOption searchOption = SearchOption.TopDirectoryOnly,
        System.Func<string, bool> filter = null)
    {
        var files = Directory.GetFiles(rootDir, pattern, searchOption);
        foreach (var assetPath in files) {
            if (filter == null || filter.Invoke(assetPath)) {
                var ai = AssetImporter.GetAtPath(assetPath);
                if (ai) {
                    string assetName = Path.GetFileNameWithoutExtension(assetPath).Replace('.', '-');

                    assetName = assetName.Replace('~', '.');
                    string abName = string.Format("{0}/{1}", group, assetName).ToLower();
                    ai.assetBundleName = abName;
                    AssetPacker.Log("设置了资源名称: {0} -> {1}", ai.assetPath, abName);
                }
            }
        }
    }

    /// <summary>
    /// 将目录下的资源以目录名命名
    /// </summary>
    private static void markPackedAssetName(
        string rootPath,
        string abName,
        string pattern,
        SearchOption searchOption = SearchOption.TopDirectoryOnly)
    {
        var files = Directory.GetFiles(rootPath, pattern, searchOption);
        abName = abName.Replace('~', '.');
        int count = 0;
        foreach (var assetPath in files) {
            var ai = AssetImporter.GetAtPath(assetPath);
            if (ai) {
                ai.assetBundleName = abName;
                count += 1;
            }
        }
        AssetPacker.Log("设置了资源名称: {0} -> {1}。共{2}个资源", rootPath, abName, count);
    }

    /// <summary>
    /// 将根目录下子目录的资源以子目录名命名。
    /// </summary>
    /// <param name="rootPath">根目录</param>
    /// <param name="pattern">筛选规则</param>
    /// <param name="group">组名</param>
    private static void markMultipleAssetName(string rootPath, string group, string pattern)
    {
        var dirs = Directory.GetDirectories(rootPath);
        foreach (var d in dirs) {
            var dName = Path.GetFileNameWithoutExtension(d);
            var abName = string.Format("{0}/{1}", group, dName).ToLower();
            markPackedAssetName(d, abName, pattern);
        }
    }

    [MenuItem("Assets/资源/自动标志资源(AssetBundle Name)")]
    static void AutoMarkAssetBundle()
    {
        // 独立资源
        var dirs = Directory.GetDirectories(GetAssetsRoot("OBO"));
        foreach (var d in dirs) {
            var dName = Path.GetFileNameWithoutExtension(d);
            markSingleAssetName(d, dName, "*");
        }

        // 分类资源
        dirs = Directory.GetDirectories(GetAssetsRoot("CATEGORY"));
        foreach( var d in dirs) {
            var dName = Path.GetFileNameWithoutExtension(d);
            foreach (var d2 in Directory.GetDirectories(d)) {
                var d2Name = Path.GetFileNameWithoutExtension(d2);
                var abName = string.Format("{0}/{1}", dName, d2Name).ToLower();
                markPackedAssetName(d2, abName, "*");
            }
        }

        // 多资源包
        dirs = Directory.GetDirectories(GetAssetsRoot("BUNDLE"));
        foreach (var d in dirs) {
            var dName = Path.GetFileNameWithoutExtension(d);
            var abName = string.Format("{0}", dName).ToLower();
            markPackedAssetName(d, abName, "*", SearchOption.AllDirectories);
        }

        // FMOD资源
        markSingleAssetName(GetAssetsRoot("FMOD"), "fmod", "*");

        // 场景依赖
        dirs = Directory.GetDirectories("Assets/Scenes");
        foreach (var d in dirs) {
            var subdirs = Directory.GetDirectories(d);
            var dname = Path.GetFileName(d);
            foreach (var sd in subdirs) {
                var sdname = Path.GetFileName(sd);
                if (sdname == "prefabs" || sdname == "terrain_tx") {
                    var ai = AssetImporter.GetAtPath(sd);
                    if (ai != null) ai.assetBundleName = "scenes/" + dname;
                }
            }
        }

        // 战斗场景
        markSingleAssetName("Assets/Scenes", "scenes", "*.unity", SearchOption.AllDirectories, (path) => {
            var dir = Path.GetFileName(Path.GetDirectoryName(path));
            return dir.StartsWith("stage_");
        });

    }

    [MenuItem("Assets/资源/删除废弃的资源包")]
    public static void RemoveUnusedAssest()
    {
        AssetDatabase.RemoveUnusedAssetBundleNames();
        if (!Directory.Exists(AssetBundleLoader.streamingRootPath)) return;

        var list = new List<string>(AssetDatabase.GetAllAssetBundleNames());
        DirectoryInfo dir = new DirectoryInfo(AssetBundleLoader.streamingRootPath);
        FileInfo[] files = dir.GetFiles("*", SearchOption.AllDirectories);
        var index = AssetBundleLoader.streamingRootPath.Length + 1;
        var listDel = new List<string>();
        foreach (var f in files) {
            if (f.Name[0] == '.' ||
                f.Name == AssetBundleLoader.FILE_LIST || 
                f.Name == AssetBundleLoader.ASSETBUNDLE_FOLDER ||
                f.Extension == ".manifest" ||
                f.Name == "md5") continue;

            var abName = f.FullName.Substring(index).Replace('\\', '/');
            if (list.Contains(abName)) continue;

            f.Delete();
            listDel.Add(f.FullName);

            AssetPacker.Log("删除废弃的资源包: {0}", abName);
        }
        foreach (var path in listDel) File.Delete(path + ".manifest");

        // Remove empty directories
        var dirList = new List<string>();
        for (int i = 0; i < list.Count; ++i) {
            string root = Path.GetDirectoryName(list[i]);
            for (; !string.IsNullOrEmpty(root); root = Path.GetDirectoryName(root)) {
                if (!dirList.Contains(root)) {
                    dirList.Add(root);
                }
            }
        }

        var subs = dir.GetDirectories("*", SearchOption.AllDirectories);
        foreach (var d in subs) {
            var abRoot = d.FullName.Substring(index).Replace('\\', '/');
            if (dirList.Contains(abRoot)) continue;

            d.Delete(true);
            AssetPacker.Log("删除空的资源目录: {0}", abRoot);
        }

        AssetPacker.Log("共删除{0}个废弃的资源包", listDel.Count);
    }

    [MenuItem("Assets/资源/查看资源类型")]
    private static void CheckAssetType()
    {
        Object obj = Selection.activeObject;
        LogMgr.Log(obj);
    }

    private static void DelSurplusAnimator(GameObject prefab)
    {
        var go = Object.Instantiate(prefab);
        go.name = prefab.name;

        var animators = go.GetComponentsInChildren<Animator>(true);
        if (animators.Length != 0) {
            bool dirty = false;
            foreach (var a in animators) {
                var controll = a.runtimeAnimatorController;
                if (!controll) {
                    dirty = true;
                    Object.DestroyImmediate(a);
                }
            }

            if (dirty) {
                AssetDatabase.SaveAssets();
                PrefabUtility.ReplacePrefab(go, prefab, ReplacePrefabOptions.ReplaceNameBased);
                LogMgr.D("存在无效的动画，预设替换: {0}", prefab.name);
            }
        }

        Object.DestroyImmediate(go);
        AssetDatabase.SaveAssets();
    }

    private static string OptimizeAnimator(Animator animator, Dictionary<AnimationClip, List<Animator>> toOptimize)
    {
        var controll = animator.runtimeAnimatorController;
        var nClip = controll ? controll.animationClips.Length : 0;
        if (nClip == 1) {
            var clip = controll.animationClips[0];

            List<Animator> list;
            if (!toOptimize.TryGetValue(clip, out list)) {
                list = new List<Animator>();
                toOptimize.Add(clip, list);
            }
            list.Add(animator);

            return null;
        }

        return string.Format(" >> {0}包含{1}个动画帧", animator.transform.GetHierarchy(), nClip);
    }

    private static GameObject OptimizeAnimator(GameObject prefab, Dictionary<AnimationClip, List<Animator>> toOptimize)
    {
        DelSurplusAnimator(prefab);

        var go = Object.Instantiate(prefab);
        go.name = prefab.name;
        var animators = go.GetComponentsInChildren<Animator>(true);
        if (animators.Length == 0) {
            AssetPacker.Log("无需优化{0}", AssetDatabase.GetAssetPath(prefab));
            goto EXIT;
        }

        var dirty = false;
        foreach (var a in animators) {
            var err = OptimizeAnimator(a, toOptimize);
            if (err != null) {
                AssetPacker.Log(err);
            }
            dirty = err == null || dirty;
        }

        if (!dirty) {
            AssetPacker.Log("无法优化{0}", AssetDatabase.GetAssetPath(prefab));
        } else {
            return go;
        }

    EXIT:
        Object.DestroyImmediate(go);
        return null;
    }

    [MenuItem("Assets/资源/优化动画状态机")]
    private static void Animator2Animation()
    {
        Dictionary<AnimationClip, List<Animator>> toOptimize = new Dictionary<AnimationClip, List<Animator>>();
        Dictionary<GameObject, GameObject> toReplace = new Dictionary<GameObject, GameObject>();
        var gameObjects = Selection.gameObjects;
        foreach (var prefab in gameObjects) {
            var go = OptimizeAnimator(prefab, toOptimize);
            if (go) {
                toReplace.Add(prefab, go);
            }
        }

        var strbld = new System.Text.StringBuilder();
        foreach (var kv in toOptimize) {
            var clip = kv.Key;
            var list = kv.Value;
            var loop = clip.isLooping;

            clip.legacy = true;
            clip.wrapMode = loop ? WrapMode.Loop : WrapMode.Default;
            var setting = AnimationUtility.GetAnimationClipSettings(clip);
            AnimationUtility.SetAnimationClipSettings(clip, setting);

            strbld.Remove(0, strbld.Length);
            foreach (var ani in list) {
                var go = ani.gameObject;
                Object.DestroyImmediate(ani);
                var anim = go.NeedComponent<Animation>();
                anim.clip = clip;
                strbld.AppendLine().AppendFormat("  >>{0}", go.transform.GetHierarchy());
            }
            AssetPacker.Log("优化{0} 用于： {1}", AssetDatabase.GetAssetPath(clip), strbld.ToString());
        }

        foreach (var kv in toReplace) {
            var prefab = kv.Key;
            var go = kv.Value;
            AssetPacker.Log("替换{0}", AssetDatabase.GetAssetPath(prefab));
            PrefabUtility.ReplacePrefab(go, prefab, ReplacePrefabOptions.ReplaceNameBased);
            Object.DestroyImmediate(go);
        }

        AssetDatabase.SaveAssets();
    }

}
