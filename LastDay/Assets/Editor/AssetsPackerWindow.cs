using UnityEngine;
using UnityEditor;
using UnityEditor.Callbacks;
#if UNITY_IOS
using UnityEditor.iOS.Xcode;
#endif
using System.IO;
using System.Collections;
using System.Collections.Generic;
using UnityEditor.SceneManagement;
using ZFrame.Asset;

public class AssetsPackerWindow : EditorWindow
{
    [System.Flags]
    private enum PackSymbol
    {
        SHOW_FPS = 1,
        XWZ_DEBUG = 2,
        RELEASE = 4,
    }

    private const string DEF_SYMBLE = "FMOD";

    [MenuItem("Custom/资源打包...")]
    static void OpenWindow()
    {
        GetWindowWithRect(typeof(AssetsPackerWindow), new Rect(0, 0, 220, 600), false, "资源打包");
    }

    private Vector2 BtnSizeLV1 = new Vector2(140, 50);
    private Vector2 BtnSizeSq = new Vector2(50, 50);
    private Vector2 BtnSizeLV2 = new Vector2(180, 30);
    private Vector2 BtnSizeLV3 = new Vector2(100, 25);

    private const int LEFT = 10;
    private const int BigBtnWidth = 200;
    private const int BigBtnHeight = 50;

    private const int btn_width = 60;
    private const int btn_height = 20;

    private static void PackAssets()
    {
        AssetPacker.EncryptLua();
        AssetPacker.PackAssets();
    }
    
    public static void UpdateAssets()
    {
        var srcDir = AssetPacker.EditorStreamingAssetsPath;
        var dstDir = AssetPacker.StreamingAssetsPath;

        AssetPacker.Log("Copying {0} -> {1}", srcDir, dstDir);

        AssetPacker.ClearStreamingAssets();
        AssetPacker.GenFileList();

        List<string> inAssets, dlAssets;
        AssetPacker.GetPackAssetNames(out inAssets, out dlAssets);

        var startIdx = AssetPacker.EditorStreamingAssetsPath.Length + 1;
        SystemTools.CopyDirectory(srcDir, dstDir, "*", (path) => {
            // 忽略无关文件
            if (path[0] == '.' || path.EndsWith(".manifest")) return true;

            var name = path.Substring(startIdx).Replace('\\', '/');
            if (inAssets.Count > 0) {
                return !inAssets.Contains(name);
            }

            // 忽略次要资源包            
            return dlAssets.Contains(name);
        });
        var manifest = AssetBundleLoader.ASSETBUNDLE_FOLDER;
        File.Copy(Path.Combine(srcDir, manifest), Path.Combine(dstDir, manifest), true);

        //AssetPacker.ClearEditorPersistentAssets();

        AssetDatabase.Refresh();

        AssetPacker.Log("Copying Done");
    }
    
    private static BuildTargetGroup GetBuildTargetGroup()
    {
        return (BuildTargetGroup)AssetPacker.assetTarget;
    }

    private static void GetFolderAndExt(out string folderName, out string extName)
    {
        folderName = null;
        extName = null;

        switch (AssetPacker.buildTarget) {
            case BuildTarget.StandaloneWindows:
            case BuildTarget.StandaloneWindows64:
                folderName = "windows";
                extName = ".exe";
                break;
            case BuildTarget.StandaloneOSX:
                folderName = "mac";
                extName = ".app";
                break;
            case BuildTarget.iOS:
                folderName = "xcodeproj";
                extName = "";
                break;
            case BuildTarget.Android:
                folderName = "android";
                extName = ".apk";
                break;
            default:
                AssetPacker.Log("暂不支持该平台: {0}", AssetPacker.buildTarget);
                return;
        }
    }

    private static string GetPackSymbols(BuildTargetGroup buildTargetGroup)
    {
        var defineSymbol = PlayerSettings.GetScriptingDefineSymbolsForGroup(buildTargetGroup);
        var symbolArray = defineSymbol.Split(new[] {';'}, System.StringSplitOptions.RemoveEmptyEntries);
        var listSymbol = new List<string>(symbolArray);
        var symbols = System.Enum.GetValues(typeof(PackSymbol));
        for (int i = 0; i < symbols.Length; ++i) {
            var value = symbols.GetValue(i).ToString();
            if (((int)m_Symbol & (1 << i)) != 0) {
                if (!listSymbol.Contains(value)) {
                    listSymbol.Add(value);
                }
            } else {
                listSymbol.Remove(value);
            }
        }

        return string.Join(";", listSymbol.ToArray());
    }

    private static void UpdateVersionCode()
    {
#if !DEVELOPMENT_BUILD && UNITY_ANDROID
        // 非开发版才会自动增加VersionCode
        var code = PlayerSettings.Android.bundleVersionCode;
        code >>= 8;
        var build = code & 0xFF;
        code >>= 8;
        var minor = code & 0xFF;
        code >>= 8;
        var major = code & 0xFF;
        
        var ver = new System.Version(PlayerSettings.bundleVersion);
        if (ver.Major == major && ver.Minor == minor && ver.Build == build) {
            PlayerSettings.Android.bundleVersionCode += 1;
        } else {
            code = (ver.Major << 24) + (ver.Minor << 16) + (ver.Build << 8);
            PlayerSettings.Android.bundleVersionCode = code;
        }
        
        AssetDatabase.SaveAssets();
#endif
    }

    private static void BuildApp()
    {
        string folderName, extName;
        GetFolderAndExt(out folderName, out extName);

        //var verInfo = VersionMgr.LoadAppVersion();
        //VersionMgr.SaveAppVersion(GitTools.getVerInfo());
        var lastCommit = GitTools.getLastCommit();
        AssetDatabase.Refresh();

        //清空PC执行文件目录的缓存文件。
        var productRoot = Path.Combine(Path.GetFullPath(".."), "Products");
        var productPath = Path.Combine(productRoot, folderName);
        var buildPath = Path.Combine(productPath,
            string.IsNullOrEmpty(extName)
                ? Application.productName
                : string.Concat(Application.productName, "_", lastCommit, extName));

        if (Directory.Exists(productPath)) Directory.Delete(productPath, true);
        SystemTools.NeedDirectory(productPath);

        // Symbol
        var buildTargetGroup = GetBuildTargetGroup();
        PlayerSettings.SetScriptingDefineSymbolsForGroup(buildTargetGroup, GetPackSymbols(buildTargetGroup));
        PlayerSettings.MTRendering = AssetPacker.buildTarget != BuildTarget.Android;
        PlayerSettings.bundleVersion = File.ReadAllLines(ASSET_VER_PATH)[0];

        if (AssetPacker.buildTarget == BuildTarget.Android) {
            UpdateVersionCode();
            PlayerSettings.Android.keystoreName = "../tools/keystore/kingsgroup_lastday.keystore";
            PlayerSettings.Android.keyaliasPass = "kingsgroup";
            PlayerSettings.Android.keystorePass = "kingsgroup";
        }

        //开始打游戏包
        BuildPipeline.BuildPlayer(new[] {
            "Assets/Scenes/Launch.unity",
        }, buildPath, AssetPacker.buildTarget, m_Options);

#if UNITY_STANDALONE
        AssetPacker.Log("Coping Essets ...");
        SystemTools.CopyDirectory(Application.dataPath + "/../Essets", productPath + "/Essets");
        File.Copy(Application.dataPath + "/../user-settings.txt", productPath + "/user-settings.txt");
#endif

        AssetPacker.Log("Build Done: " + buildPath);
    }

    private void BuildAndroid_mono2x()
    {
        PlayerSettings.SetScriptingBackend(BuildTargetGroup.Android, ScriptingImplementation.Mono2x);
        BuildApp();
    }

    private void BuildAndroid_il2cpp()
    {
        PlayerSettings.SetScriptingBackend(BuildTargetGroup.Android, ScriptingImplementation.IL2CPP);
        BuildApp();
    }

    private static void RevealInFinder()
    {
        string folderName, extName;
        GetFolderAndExt(out folderName, out extName);

        string productRoot = Path.Combine(Path.GetFullPath(".."), "Products");
        string productPath = Path.Combine(productRoot, folderName);
        if (Directory.Exists(productPath)) {
            EditorUtility.RevealInFinder(productPath);
        } else {
            EditorUtility.RevealInFinder(productRoot);
        }
    }

    private static void PackAndBuild()
    {
        AssetsOperation.RemoveUnusedAssest();
        AssetsPackerWindow.PackAssets();
        AssetsPackerWindow.UpdateAssets();
        AssetsPackerWindow.BuildApp();
    }

    private static void AutoBuild()
    {
        var executeMethod = "AssetsPackerWindow.AutoBuild";
        List<string> args = null;
        foreach (var arg in System.Environment.GetCommandLineArgs()) {
            if (args != null) {
                args.Add(arg);
            } else if (string.CompareOrdinal(arg, executeMethod) == 0) {
                args = new List<string>();
            }
        }

        if (args != null) {
            if (args.Count > 0) {
                // args[0]: platform
                switch (args[0]) {
                    case "android":
                        AssetPacker.assetTarget = AssetPacker.AssetTarget.Android;
                        AssetPacker.buildTarget = BuildTarget.Android;
                        break;
                    case "windows":
                        AssetPacker.assetTarget = AssetPacker.AssetTarget.Standalone;
                        AssetPacker.buildTarget = BuildTarget.StandaloneWindows64;
                        break;
                    case "ios":
                        AssetPacker.assetTarget = AssetPacker.AssetTarget.iOS;
                        AssetPacker.buildTarget = BuildTarget.iOS;
                        break;
                    default:
                        Debug.LogErrorFormat("Unsupport BuildTarget: {0}.", args[0]);
                        return;
                }

                // args[1]: forced rebuild all assetbundle?
                if (args.Count > 1 && args[1] == "true") {
                    AssetPacker.ClearEditorStreamingAssets();
                }

                // args[2]: debug version?
                if (args.Count > 2 && args[2] == "true") {
                    m_Symbol |= PackSymbol.RELEASE;
                }

                // args[3]: development build?
                if (args.Count > 3) {
                    if (args[3] == "true") {
                        m_Options |= BuildOptions.Development;
                        m_Symbol |= PackSymbol.SHOW_FPS;
                    } else {
                        m_Options &= ~BuildOptions.Development;
                        m_Symbol &= ~PackSymbol.SHOW_FPS;
                    }
                }

                if (AssetPacker.buildTarget == BuildTarget.Android) {
                    // args[4]: il2cpp?
                    PlayerSettings.SetScriptingBackend(BuildTargetGroup.Android,
                        args.Count > 4 && args[4] == "il2cpp"
                            ? ScriptingImplementation.IL2CPP
                            : ScriptingImplementation.Mono2x);
                }

                if (args.Count > 5) {
                    AssetPacker.splitAssets = args[5] == "true";                    
                }
#if FMOD
                // 自动打包要先更新FMOD音频资源
                FMODUnity.EventManager.CopyToStreamingAssets();
#endif

                PackAndBuild();
            } else {
                Debug.LogErrorFormat("BuildTarget Unspecified.");
            }
        }
    }

    private void ClearAssets()
    {
        if (EditorUtility.DisplayDialog(
            "注意",
            "清空已生成的资源包缓存后，\n之后生成资源包操作将重新生成所有资源。",
            "确定", "取消")) {
            AssetPacker.ClearEditorStreamingAssets();
        }
    }

    private void EncryptLua()
    {
        AssetPacker.EncryptLua();
        AssetDatabase.Refresh();
    }

    private void VERT_Btn(ref int vertOffset, int horiOffset, Vector2 size, string title, System.Action funcPack,
        string tooltip = null)
    {
        if (funcPack != null) {
            if (GUI.Button(
                new Rect(horiOffset, vertOffset, size.x, size.y),
                new GUIContent(title, tooltip),
                CustomEditorStyles.richTextBtn)) {
                funcPack.Invoke();
            }
        }

        vertOffset += (int)size.y;
        vertOffset += 5;
    }

    private void HORI_Btn(ref int horiOffset, int vertOffset, Vector2 size, string title, System.Action funcPack,
        string tooltip = null)
    {
        if (GUI.Button(new Rect(horiOffset, vertOffset, size.x, size.y),
            new GUIContent(title, tooltip),
            CustomEditorStyles.richTextBtn)) {
            funcPack.Invoke();
        }

        horiOffset += (int)size.x;
        horiOffset += 5;
    }

    private void OnEnable()
    {
        var buildTargetGroup = GetBuildTargetGroup();

        // Init Symbol
        var defineSymbol = PlayerSettings.GetScriptingDefineSymbolsForGroup(buildTargetGroup);
        var Symbols = defineSymbol.Split(new char[] {';'}, System.StringSplitOptions.RemoveEmptyEntries);
        var listSymbol = new List<string>(Symbols);
        var symbols = System.Enum.GetValues(typeof(PackSymbol));
        var iSymbol = (int)m_Symbol;
        for (int i = 0; i < symbols.Length; ++i) {
            var value = symbols.GetValue(i).ToString();
            if (listSymbol.Contains(value)) {
                iSymbol |= 1 << i;
            }
        }

        m_Symbol = (PackSymbol)iSymbol;
    }

    private void OnGUI()
    {
        int vertOffset = 10;
        var horiOffset = 10;

        SymbleArea(ref vertOffset);

        AssetPacker.splitAssets = GUI.Toggle(new Rect(horiOffset, vertOffset, BigBtnWidth, btn_height), 
            AssetPacker.splitAssets, "分包");
        vertOffset += btn_height + 5;
        HORI_Btn(ref horiOffset, vertOffset, BtnSizeLV1, "<size=40>出包</size>", PackAndBuild);
        VERT_Btn(ref vertOffset, horiOffset, BtnSizeSq, "打开", RevealInFinder);

        horiOffset = 20;
        VERT_Btn(ref vertOffset, horiOffset, BtnSizeLV2, "<size=20>1. 删除废弃资源包</size>",
            AssetsOperation.RemoveUnusedAssest);
        VERT_Btn(ref vertOffset, horiOffset, BtnSizeLV2, "<size=20>2. 生成资源包*</size>", PackAssets,
            "先加密Lua脚本\n再打包有变化的资源");
        VERT_Btn(ref vertOffset, horiOffset, BtnSizeLV2, "<size=20>3. 更新资源包*</size>", UpdateAssets,
            "重新生成filelist文件\n然后把生成的所有资源包拷贝到StreamingAssets目录");
        if (AssetPacker.assetTarget == AssetPacker.AssetTarget.Android) {
            var btnSize = new Vector2(BtnSizeLV2.x / 2, BtnSizeLV2.y);
            var offset = vertOffset;
            var appid = PlayerSettings.applicationIdentifier;
            var si = PlayerSettings.GetScriptingBackend(BuildTargetGroup.Android);
            var mono2x = si == ScriptingImplementation.Mono2x;
            var il2cpp = si == ScriptingImplementation.IL2CPP;
            VERT_Btn(ref offset, horiOffset, btnSize,
                mono2x ? "<color=yellow><b>mono2x</b></color>" : "mono2x", BuildAndroid_mono2x);
            VERT_Btn(ref vertOffset, horiOffset + (int)btnSize.x, btnSize,
                il2cpp ? "<color=yellow><b>il2cpp</b></color>" : "il2cpp", BuildAndroid_il2cpp);
        } else {
            VERT_Btn(ref vertOffset, 20, BtnSizeLV2, "<size=20>4. 生成应用*</size>", BuildApp, "使用已生成的资源包，直接执行生成应用");
        }

        vertOffset += 10;
        GUI.Label(new Rect(0, vertOffset, BtnSizeLV2.x, BtnSizeLV2.y), "编辑器/调试专用：", CustomEditorStyles.richText);
        vertOffset += 20;

        horiOffset = 10;
        HORI_Btn(ref horiOffset, vertOffset, BtnSizeLV3, "加密Lua", EncryptLua);
        VERT_Btn(ref vertOffset, horiOffset, BtnSizeLV3, "资源打包", AssetPacker.PackAssets);

        horiOffset = 10;
        HORI_Btn(ref horiOffset, vertOffset, BtnSizeLV3, "压缩下载资源", AssetPacker.GenMinorAssets);
        VERT_Btn(ref vertOffset, horiOffset, BtnSizeLV3, "更新filelist", AssetPacker.UpdateFileList);

        horiOffset = 10;
        HORI_Btn(ref horiOffset, vertOffset, BtnSizeLV3, "生成filelist.csv", AssetPacker.GenFileListCSV);
        VERT_Btn(ref vertOffset, horiOffset, BtnSizeLV3, null, null);
        
        VERT_Btn(ref vertOffset, 20, BtnSizeLV2, "<color=red><size=20>清除资源包</size></color>", ClearAssets);

        vertOffset += 10;
        VersionArea(ref vertOffset);

        vertOffset += btn_height;
        vertOffset += 10;

        UsingAssetsArea(ref vertOffset);
    }

    private static PackSymbol m_Symbol;
    private static BuildOptions m_Options = BuildOptions.None;

    /// <summary>
    /// 打包前宏配置
    /// </summary>
    private void SymbleArea(ref int vertOffset)
    {
        if (AssetPacker.assetTarget == 0)
            AssetPacker.assetTarget = (AssetPacker.AssetTarget)EditorUserBuildSettings.selectedBuildTargetGroup;
        if (AssetPacker.buildTarget == 0)
            AssetPacker.buildTarget = EditorUserBuildSettings.activeBuildTarget;

        var pos = new Rect(LEFT, vertOffset, BigBtnWidth, btn_height);
        EditorGUI.LabelField(pos, "选择平台");
        pos.x += 80;
        pos.width -= 80;
        var assetTarget = (AssetPacker.AssetTarget)EditorGUI.EnumPopup(pos, AssetPacker.assetTarget);
        if (assetTarget != AssetPacker.assetTarget) {
            AssetPacker.assetTarget = assetTarget;
            switch (assetTarget) {
                case AssetPacker.AssetTarget.Standalone:
                    break;
                case AssetPacker.AssetTarget.iOS:
                    AssetPacker.buildTarget = BuildTarget.iOS;
                    break;
                case AssetPacker.AssetTarget.Android:
                    AssetPacker.buildTarget = BuildTarget.Android;
                    break;
                default: break;
            }
        }

        vertOffset += btn_height + 5;

        pos = new Rect(LEFT, vertOffset, BigBtnWidth, btn_height);
        EditorGUI.LabelField(pos, new GUIContent("预定义符号*", "配置是否开启各种非正式版特性"));
        pos.x += 80;
        pos.width -= 120;
        m_Symbol = (PackSymbol)EditorGUI.EnumFlagsField(pos, "", m_Symbol);
        pos.x += pos.width;
        pos.width = 40;
        EditorGUI.LabelField(pos, ((int)m_Symbol).ToString());
        vertOffset += btn_height;

        EditorGUI.BeginDisabledGroup(true);
        pos.x = LEFT;
        pos.y = vertOffset;
        pos.width = BigBtnWidth;
        EditorGUI.TextArea(pos, GetPackSymbols(GetBuildTargetGroup()));
        EditorGUI.EndDisabledGroup();
        vertOffset += btn_height + 5;

        pos = new Rect(LEFT, vertOffset, BigBtnWidth, btn_height);
        EditorGUI.LabelField(pos, "编译选项");
        pos.x += 80;
        pos.width -= 80;
        m_Options = (BuildOptions)EditorGUI.EnumFlagsField(pos, "", m_Options);

        vertOffset += btn_height + 10;
    }


    private const string APP_VER_PATH = "Assets/Resources/version.txt";
    private static string ASSET_VER_PATH = string.Format("Assets/{0}/version.txt", AssetPacker.DIR_ASSETS);
    private string m_SavedAppVer, m_SavedAssetVer;
    private string m_AppVer, m_AssetVer;
    private string m_ErrorMsg;

    private static void SaveVersion(string ver, string path)
    {
        var v = new System.Version(ver);
        var verText = File.ReadAllLines(path);
        verText[0] = v.ToString();
        File.WriteAllLines(path, verText);
    }

    private void VersionArea(ref int vertOffset)
    {
        EditorGUI.LabelField(new Rect(LEFT, vertOffset, BigBtnWidth, btn_height), "<b>版本号管理</b>",
            CustomEditorStyles.titleStyle);
        vertOffset += btn_height + 5;
        if (GUI.Button(new Rect(LEFT, vertOffset, btn_width, btn_height), "还原", EditorStyles.miniButtonLeft)) {
            m_AppVer = null;
            m_AssetVer = null;
            m_ErrorMsg = string.Empty;
        }

        if (m_AppVer == null) {
            m_AppVer = File.ReadAllLines(APP_VER_PATH)[0];
            m_SavedAppVer = m_AppVer;
        }

        if (m_AssetVer == null) {
            m_AssetVer = File.ReadAllLines(ASSET_VER_PATH)[0];
            m_SavedAssetVer = m_AssetVer;
        }

        if (GUI.Button(new Rect(LEFT + btn_width, vertOffset, btn_width, btn_height), "编译版本＋",
            EditorStyles.miniButtonMid)) {
            m_ErrorMsg = string.Empty;
            var v = new System.Version(m_SavedAppVer);
            v = new System.Version(v.Major, v.Minor, v.Build + 1, v.Revision);
            m_AppVer = v.ToString();

            v = new System.Version(m_SavedAssetVer);
            v = new System.Version(v.Major, v.Minor, v.Build + 1, v.Revision);
            m_AssetVer = v.ToString();
        }

        if (GUI.Button(new Rect(LEFT + btn_width * 2, vertOffset, btn_width + 20, btn_height), "修正版本＋",
            EditorStyles.miniButtonRight)) {
            m_ErrorMsg = string.Empty;
            var v = new System.Version(m_SavedAppVer);
            v = new System.Version(v.Major, v.Minor, v.Build, v.Revision + 1);
            m_AppVer = v.ToString();

            v = new System.Version(m_SavedAssetVer);
            v = new System.Version(v.Major, v.Minor, v.Build, v.Revision + 1);
            m_AssetVer = v.ToString();
        }

        vertOffset += btn_height + 5;
        var appFmt = m_AppVer == m_SavedAppVer ? "{0}" : "<i>{0}</i>";
        EditorGUI.LabelField(
            new Rect(LEFT, vertOffset, BigBtnWidth, btn_height),
            string.Format(appFmt, "应用版本:"), CustomEditorStyles.richText);
        m_AppVer = EditorGUI.TextField(new Rect(LEFT + 100, vertOffset, BigBtnWidth - 100, btn_height), m_AppVer);

        vertOffset += btn_height + 5;
        var assetFmt = m_AssetVer == m_SavedAssetVer ? "{0}" : "<i>{0}</i>";
        EditorGUI.LabelField(
            new Rect(LEFT, vertOffset, BigBtnWidth, btn_height),
            string.Format(assetFmt, "资源版本:"), CustomEditorStyles.richText);
        m_AssetVer = EditorGUI.TextField(new Rect(LEFT + 100, vertOffset, BigBtnWidth - 100, btn_height), m_AssetVer);

        vertOffset += btn_height + 5;
        if (GUI.Button(new Rect(LEFT, vertOffset, BigBtnWidth, btn_height), "更新")) {
            m_ErrorMsg = string.Empty;
            try {
                SaveVersion(m_AppVer, APP_VER_PATH);
                m_AppVer = null;
            } catch {
                m_ErrorMsg += "应用版本错误;";
            }

            try {
                SaveVersion(m_AssetVer, ASSET_VER_PATH);
                m_AssetVer = null;
            } catch {
                m_ErrorMsg += "资源版本错误;";
            }
        }

        vertOffset += btn_height;
        EditorGUI.LabelField(
            new Rect(LEFT, vertOffset, BigBtnWidth, btn_height),
            string.Format("<color=red>{0}</color>", m_ErrorMsg), CustomEditorStyles.richText);
    }

    private void UsingAssetsArea(ref int vertOffset)
    {
        EditorGUI.LabelField(new Rect(LEFT, vertOffset, BigBtnWidth, btn_height), "<b>运行游戏资源</b>",
            CustomEditorStyles.titleStyle);
        vertOffset += btn_height + 5;

        var prefab = AssetDatabase.LoadAssetAtPath(
            "Assets/Resources/AssetsMgr.prefab", typeof(GameObject)) as GameObject;
        var assetsMgr = prefab.GetComponent<AssetsMgr>();
        if (assetsMgr) {
            var pos = new Rect(LEFT, vertOffset, btn_width, btn_height);
            var useLua = EditorGUI.ToggleLeft(pos, "全资源", assetsMgr.useLuaAssetBundle);
            pos.x += btn_width + 5;
            var useAb = EditorGUI.ToggleLeft(pos, "美术资源", assetsMgr.useAssetBundleLoader);
            if (useLua != assetsMgr.useLuaAssetBundle || useAb != assetsMgr.useAssetBundleLoader) {
                var go = GameObject.Instantiate(prefab) as GameObject;
                var mgr = go.GetComponent<AssetsMgr>();
                mgr.useLuaAssetBundle = useLua;
                mgr.useAssetBundleLoader = useAb;
                AssetDatabase.SaveAssets();
                PrefabUtility.ReplacePrefab(go, prefab, ReplacePrefabOptions.ReplaceNameBased);
                GameObject.DestroyImmediate(go);
            }
        }
    }
  
    [PostProcessBuild(999)]
    public static void OnPostprocessBuild(BuildTarget BuildTarget, string path)
    {
#if UNITY_IOS
        if (BuildTarget == BuildTarget.iOS) {
            string projPath = PBXProject.GetPBXProjectPath(path);
            PBXProject proj = new PBXProject();
            proj.ReadFromString(File.ReadAllText(projPath));

            // 获取当前项目名字  
            string target = proj.TargetGuidByName(PBXProject.GetUnityTargetName());
            // 设置签名
            proj.SetTeamId(target, "JK9HPMVJU7");
            proj.SetBuildProperty(target, "CODE_SIGN_IDENTITY", "iPhone Distribution: DianDian Interactive USA Inc.");

            // 对所有的编译配置设置选项
            proj.SetBuildProperty(target, "ENABLE_BITCODE", "NO");
            proj.SetBuildProperty(target, "GCC_OPTIMIZATION_LEVEL", "0");

            // 添加依赖库  
            // 热云sdk
//            proj.AddFrameworkToProject(target, "Security.framework", false);  
//            proj.AddFrameworkToProject(target, "CoreTelephony.framework", false);  
//            proj.AddFrameworkToProject(target, "AdSupport.framework", false);  
//            proj.AddFrameworkToProject(target, "SystemConfiguration.framework", false); 
//            proj.AddFrameworkToProject(target, "libsqlite3.0.tbd", false);
//            proj.AddFrameworkToProject(target, "libz.tbd", false);

            // 腾讯云
            proj.AddFrameworkToProject(target, "libresolv.tbd", false);
            
            // 保存工程  
            proj.WriteToFile(projPath);

            // 修改plist  
            string plistPath = path + "/Info.plist";
            PlistDocument plist = new PlistDocument();
            plist.ReadFromString(File.ReadAllText(plistPath));
            PlistElementDict rootDict = plist.root;

            // 语音所需要的声明，iOS10必须  
            rootDict.SetString("NSContactsUsageDescription", "使用通讯录");
            rootDict.SetString("NSMicrophoneUsageDescription", "使用麦克风");

            // 保存plist  
            plist.WriteToFile(plistPath);

            /*
            // 调用XCode打包脚本
            var productPath = Path.Combine(Path.GetFullPath(".."), "Products/ios");
            var buildProcess = new System.Diagnostics.Process {
                StartInfo = {
                    FileName = "/bin/sh",
                    Arguments = string.Format("{0} {1} {2}", Application.dataPath + "/../buildios.sh", projPath,
                        productPath),
                    UseShellExecute = false,
                    RedirectStandardOutput = false
                }
            };
            buildProcess.Start();
            buildProcess.WaitForExit();
            //*/
        }
#elif UNITY_ANDROID
        string folderName, extName;
        GetFolderAndExt(out folderName, out extName);

        string productRoot = Path.Combine(Path.GetFullPath(".."), "Products");
        string productPath = Path.Combine(productRoot, folderName);
        if (PlayerSettings.GetScriptingBackend(BuildTargetGroup.Android) == ScriptingImplementation.IL2CPP) {
            var files = Directory.GetFiles(productPath);
            foreach (var f in files) {
                if (!f.EndsWith(".apk")) File.Delete(f);
            }
        }
#endif
    }
}
