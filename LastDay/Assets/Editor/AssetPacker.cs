using UnityEngine;
using UnityEditor;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Text;
using ZFrame.Asset;
//using Assets.Editor.Utils;
using TinyJSON;

public static class AssetPacker
{
    private const string OTHERS = "Others";
    
    public enum AssetTarget
    {
        Standalone = BuildTargetGroup.Standalone,
        iOS = BuildTargetGroup.iOS,
        Android = BuildTargetGroup.Android,
    }

    public static string EditorStreamingAssetsPath {
        get {
            string streamingPath = AssetBundleLoader.streamingRootPath;
            if (!Directory.Exists(streamingPath)) {
                SystemTools.NeedDirectory(streamingPath);
            }
            return streamingPath;
        }
    }

    public static string EditorPersistentAssetsPath {
        get {
            string persistentPath = AssetBundleLoader.bundleRootPath;
            if (!Directory.Exists(persistentPath)) {
                SystemTools.NeedDirectory(persistentPath);
            }
            return persistentPath;
        }
    }

    public static string EditorDownloadAssetsPath {
        get {
            string downloadPath = AssetBundleLoader.CombinePath(
                AssetBundleLoader.streamingAssetsPath, AssetBundleLoader.DOWNLOAD_FOLDER);
            if (!Directory.Exists(downloadPath)) {
                SystemTools.NeedDirectory(downloadPath);
            }
            return downloadPath;
        }
    }

    private static string m_StreamingAssetsPath {
        get {
            return string.Format("{0}/{1}",
                Application.streamingAssetsPath, AssetBundleLoader.ASSETBUNDLE_FOLDER);
        }
    }
    public static string StreamingAssetsPath {
        get {
            string path = m_StreamingAssetsPath;
            if (!Directory.Exists(path)) {
                SystemTools.NeedDirectory(path);
            }
            return path;
        }
    }

    public static AssetTarget assetTarget = 0;
    public static BuildTarget buildTarget = 0;
    public static bool splitAssets = false;

    public static string DIR_ASSETS { get { return AssetBundleLoader.DIR_ASSETS; } }

    public static void Log(string fmt, params object[] Args)
    {
        Debug.LogFormat("<color=blue><b>[PACK] " + fmt + "</b></color>", Args);
    }

    /// <summary>
    /// 压缩和打包Lua脚本/配置
    /// </summary>
    public static void EncryptLua()
    {
        CLZF2.Decrypt(null, 260769);
        CLZF2.Decrypt(new byte[1], 3);

        string CodeRoot = Path.Combine(Application.dataPath, "LuaCodes");
        string scriptDir = Path.Combine(CodeRoot, "Script");
        string configDir = Path.Combine(CodeRoot, "Config");
        if (!Directory.Exists(scriptDir)) {
            SystemTools.NeedDirectory(scriptDir);
            AssetDatabase.Refresh();
        }
        var ai = AssetImporter.GetAtPath("Assets/LuaCodes/Script");
        ai.assetBundleName = "lua/script";

        if (!Directory.Exists(configDir)) {
            SystemTools.NeedDirectory(configDir);
            AssetDatabase.Refresh();
        }
        ai = AssetImporter.GetAtPath("Assets/LuaCodes/Config");
        ai.assetBundleName = "lua/config";

        var scripts = new DirectoryInfo(scriptDir).GetFiles("*.bytes");
        var configs = new DirectoryInfo(configDir).GetFiles("*.bytes");
        var listExists = new List<string>();
        foreach (var f in scripts) listExists.Add("Script/" + f.Name);
        foreach (var f in configs) listExists.Add("Config/" + f.Name);

        DirectoryInfo dirLua = new DirectoryInfo(ChunkAPI.GetFilePath(""));
        FileInfo[] files = dirLua.GetFiles("*.lua", SearchOption.AllDirectories);
        int startIndex = dirLua.FullName.Length + 1;
        var nFiles = 0;
        foreach (FileInfo f in files) {
            string fullName = f.FullName.Substring(startIndex).Replace('/', '%').Replace('\\', '%');
            if (fullName.StartsWith("debug")) continue;
            string fileName = fullName.Remove(fullName.Length - 4) + ".bytes";

            string[] lines = File.ReadAllLines(f.FullName);
            // 以"--"开头的注释以换行符代替
            List<string> liLine = new List<string>();
            foreach (var l in lines) {
                string ltim = l.Trim();
                if (ltim.StartsWith("--") && !ltim.StartsWith("--[[") && !ltim.StartsWith("--]]")) {
                    liLine.Add("\n");
                } else {
                    liLine.Add(l + "\n");
                }
            }
            string codes = string.Concat(liLine.ToArray());
            byte[] nbytes = System.Text.Encoding.UTF8.GetBytes(codes);
            if (nbytes.Length > 0) {
                nbytes = CLZF2.DllCompress(nbytes);
                CLZF2.Encrypt(nbytes, nbytes.Length);
            } else {
                Debug.LogWarning("Compress Lua: " + fileName + " is empty!");
            }

            string path;
            if (fileName.StartsWith("config")) {
                listExists.Remove("Config/" + fileName);
                path = Path.Combine(configDir, fileName);
            } else {
                listExists.Remove("Script/" + fileName);
                path = Path.Combine(scriptDir, fileName);
            }
            if (File.Exists(path)) {
                using (var file = File.OpenWrite(path)) {
                    file.Seek(0, SeekOrigin.Begin);
                    file.Write(nbytes, 0, nbytes.Length);
                    file.SetLength(nbytes.Length);
                }
            } else {
                File.WriteAllBytes(path, nbytes);
            }
            nFiles++;
        }
        foreach (var n in listExists) {
            var path = Path.Combine(CodeRoot, n);
            File.Delete(path);
            Log("Delete: {0}", n);
        }
        Log("Compress {0} files success. => {1}", nFiles, CodeRoot);
    }

    private static bool HasAssetInBuild(List<AssetBundleBuild> list, string abName)
    {
        foreach (var abb in list) {
            if (abb.assetBundleName == abName) return true;
        }

        return false;
    }

    public static void GetPackAssetNames(out List<string> inAssets, out List<string> dlAssets)
    {
        inAssets = new List<string>();
        dlAssets = new List<string>();

        if (splitAssets) {
            // 尝试读取内部资源配置
            var jsonObj = GetSubAssets("major");
            if (jsonObj != null) {
                foreach (var jo in jsonObj) {
                    ProxyArray joArray = jo.Value as ProxyArray;
                    foreach (var name in joArray) {
                        inAssets.Add(name);
                    }
                }
            }

            // 尝试读取下载资源配置
            jsonObj = GetSubAssets("minor");
            if (jsonObj != null) {
                foreach (var jo in jsonObj) {
                    int minLevel = (int)jo.Value.ConvTo("minLevel", 0);
                    ProxyArray joArray = null;
                    if (minLevel > 0) {
                        joArray = jo.Value["Assets"] as ProxyArray;
                    } else {
                        joArray = jo.Value as ProxyArray;
                    }
                    foreach (var name in joArray) {
                        dlAssets.Add(name);
                    }
                }
            }
        }

        var AllAssetBundles = AssetDatabase.GetAllAssetBundleNames();
        if (inAssets.Count == 0) {
            foreach (var name in AllAssetBundles) {
                if (!dlAssets.Contains(name)) {
                    inAssets.Add(name);
                }
            }
        } else {
            // 把未管理的资源加入需下载资源
            foreach (var name in AllAssetBundles) {
                if (!inAssets.Contains(name) && !dlAssets.Contains(name)) {
                    dlAssets.Add(name);
                }
            }
        }
    }

    public static void PackAssets()
    {
        AssetDatabase.RemoveUnusedAssetBundleNames();
        
        AssetDatabase.Refresh();

        // 打包内部资源 - ChunkBasedCompression
        BuildPipeline.BuildAssetBundles(EditorStreamingAssetsPath,
            BuildAssetBundleOptions.ChunkBasedCompression, buildTarget);
                
        if (splitAssets) {
            // 额外打包下载资源 - UncompressedAssetBundle
            BuildPipeline.BuildAssetBundles(EditorDownloadAssetsPath,
                BuildAssetBundleOptions.UncompressedAssetBundle, buildTarget);
        }

        // 更新资源版本号
        // VersionMgr.SaveAssetVersion(GitTools.getVerInfo());
        AssetDatabase.Refresh();

        Log("BuildAssetBundles success. => {0}", EditorStreamingAssetsPath);
    }

    public const string MINOR_PATH = "Issets/MinorAssets";

    private static void PackMinorAssets(DirectoryInfo dir, string name, IEnumerable joArray)
    {
        var list = new List<FileInfo>();
        foreach (var ab in joArray) {
            list.Add(new FileInfo(Path.Combine(dir.FullName, (string)ab)));
        }
        if (list.Count > 0) {
            ZFrame.Bundle.Pack(dir, list, Path.Combine(MINOR_PATH, name));
        }
    }

    public static ProxyObject GetSubAssets(string assetPack)
    {
        var path = string.Format("Assets/Editor/{0}assets_{1}.txt", assetPack, buildTarget);
        if (File.Exists(path)) {
            var asset = AssetDatabase.LoadAssetAtPath(path, typeof(TextAsset)) as TextAsset;
            return JSON.Load(asset.text) as ProxyObject;
        }

        return null;
    }

    /// <summary>
    /// 生成次要资源包
    /// </summary>
    public static void GenMinorAssets()
    {
        var split = splitAssets;
        splitAssets = true;
        List<string> inAssets, dlAssets;
        GetPackAssetNames(out inAssets, out dlAssets);
        splitAssets = split;

        if (dlAssets.Count == 0) {
            Log("没有下载资源需要生成");
            return;
        }
        var rootDir = new DirectoryInfo(EditorDownloadAssetsPath);

        var jsonObj = GetSubAssets("minor");
        if (jsonObj != null) {
            foreach (var jo in jsonObj) {
                int minLevel = (int)jo.Value.ConvTo("minLevel", 0);
                if (minLevel > 0) {
                    var array = jo.Value["Assets"] as ProxyArray;
                    PackMinorAssets(rootDir, jo.Key, array);
                    foreach (var name in array) dlAssets.Remove(name);
                } else {
                    var array = jo.Value as ProxyArray;
                    PackMinorAssets(rootDir, jo.Key, array);
                    foreach (var name in array) dlAssets.Remove(name);
                }
            }
        }

        if (dlAssets.Count > 0) {
            PackMinorAssets(rootDir, OTHERS, dlAssets);
        }
    }

    private static readonly HashSet<string> IgnoreInFilelist = new HashSet<string> {
        "AssetBundles", "md5", "filelist",
    };

    private static IEnumerator<FileInfo> ForEachAssetBundle()
    {
        DirectoryInfo dir = new DirectoryInfo(EditorStreamingAssetsPath);
        FileInfo[] files = dir.GetFiles("*", SearchOption.AllDirectories);
        
        for (int i = 0; i < files.Length; ++i) {
            var file = files[i];
            // 忽略无关文件
            if (file.Name[0] == '.' || file.Extension == ".manifest") continue;
            if (IgnoreInFilelist.Contains(file.Name)) continue;
            
            yield return file;
        }
    }

    public static void GenFileList()
    {
        var ver = VersionMgr.AssetVersion;

        ResInf resInf = new ResInf {
            Downloads = new Dictionary<string, DownloadInf>()
        };
        resInf.version = ver.version;
        resInf.timeCreated = ver.timeCreated;
        resInf.whoCreated = ver.whoCreated;

        ResInf majorInf = null;
        List<string> inAssets = null, dlAssets = null;
        if (splitAssets) {
            majorInf = new ResInf {
                Downloads = new Dictionary<string, DownloadInf>()
            };
            majorInf.version = ver.version;
            majorInf.timeCreated = ver.timeCreated;
            majorInf.whoCreated = ver.whoCreated;
            GetPackAssetNames(out inAssets, out dlAssets);
        }

        int startIdx = EditorStreamingAssetsPath.Length;
        using (var itor = ForEachAssetBundle()) {
            while (itor.MoveNext()) {
                var file = itor.Current;
                string md5 = CMD5.MD5File(file.FullName);
                long siz = file.Length;
                string assetName = file.FullName.Substring(startIdx).Replace("\\", "/").Substring(1);
                var assetInf = new AssetInf() { siz = siz, md5 = md5 };
                resInf.Assets.Add(assetName, assetInf);
                if (majorInf != null && inAssets.Contains(assetName)) {
                    majorInf.Assets.Add(assetName, assetInf);
                }
            }
        }
        
        // 保存lua脚本的md5
        File.WriteAllText(EditorStreamingAssetsPath + "/md5", resInf.Assets["lua/script"].md5);

        if (majorInf != null) {
            var jsonObj = GetSubAssets("minor");
            if (jsonObj != null) {
                foreach (var jo in jsonObj) {
                    int minLevel = (int)jo.Value.ConvTo("minLevel", 0);
                    if (minLevel > 0) {
                        string fileName = jo.Key;
                        var fileInfo = new FileInfo(Path.Combine(MINOR_PATH, fileName));
                        var maxLevel = (int)jo.Value.ConvTo("maxLevel", minLevel);
                        majorInf.Downloads.Add(fileName,
                            new DownloadInf() { siz = fileInfo.Length, minLevel = minLevel, maxLevel = maxLevel });
                    }
                }
            }

            var othersPath = Path.Combine(MINOR_PATH, OTHERS);
            if (File.Exists(othersPath)) {
                var fileInfo = new FileInfo(othersPath);
                majorInf.Downloads.Add(OTHERS, new DownloadInf() { siz = fileInfo.Length, minLevel = 0, maxLevel = 0 });
            }
        }

        var filelist = AssetBundleLoader.FILE_LIST;

        string savedPath = EditorStreamingAssetsPath + "/" + filelist;
        if (File.Exists(savedPath)) {
            var prevPath = AssetBundleLoader.streamingAssetsPath + "/" + filelist;
            ResInf oldInf;
            ResInf diffInf = new ResInf() { version = resInf.version, };
            JSON.MakeInto(JSON.Load(File.ReadAllText(savedPath)), out oldInf);
            if (oldInf.version == resInf.version) {
                if (File.Exists(prevPath)) {
                    JSON.MakeInto(JSON.Load(File.ReadAllText(savedPath)), out oldInf);
                }
            }

            if (oldInf.version != resInf.version) {                
                // 备份一个上个版本的
                File.Copy(savedPath, prevPath, true);

                foreach (var kv in resInf.Assets) {
                    AssetInf oldAsset;
                    if (oldInf.Assets.TryGetValue(kv.Key, out oldAsset)) {
                        if (string.Compare(kv.Value.md5, oldAsset.md5, System.StringComparison.OrdinalIgnoreCase) == 0) continue;
                    }

                    // 记录不同的
                    diffInf.Assets.Add(kv.Key, kv.Value);
                }
            }
            if (diffInf.Assets.Count > 0) {
                var patchPath = AssetBundleLoader.streamingAssetsPath + "/Patch" + diffInf.version;
                SystemTools.NeedDirectory(patchPath);
                File.WriteAllText(patchPath + "/" + filelist, JSON.Dump(diffInf, true));
                foreach (var kv in diffInf.Assets) {
                    var assetPath = patchPath + "/" + kv.Key;
                    SystemTools.NeedDirectory(Path.GetDirectoryName(assetPath));
                    File.Copy(EditorStreamingAssetsPath + "/" + kv.Key, assetPath, true);
                }
            }
        }

        var totalContent = JSON.Dump(resInf, true);
        var insideContent = majorInf != null ? JSON.Dump(majorInf, true) : totalContent;
        
        File.WriteAllText(savedPath, totalContent);
        Log("Generate {0} success. => {1}", AssetBundleLoader.FILE_LIST, savedPath);

        File.Copy(EditorStreamingAssetsPath + "/md5", StreamingAssetsPath + "/md5", true);
        File.WriteAllText(StreamingAssetsPath + "/" + filelist, insideContent);
        Log("Update {0} success. => {1}/{2}", filelist, StreamingAssetsPath, filelist);
    }

    public static void GenFileListCSV()
    {
        var strbld = new StringBuilder("PATH,SIZE");
        strbld.AppendLine();
        int startIdx = EditorStreamingAssetsPath.Length;
        using (var itor = ForEachAssetBundle()) {
            while (itor.MoveNext()) {
                var file = itor.Current;
                
                long siz = file.Length;
                var fullName = file.FullName;
                if (startIdx < fullName.Length) {
                    string path = fullName.Substring(startIdx).Replace("\\", "/").Substring(1);
                    strbld.AppendFormat("{0},{1}\n", path, siz);
                } else {
                    LogMgr.W("Invalid path: {0}", fullName);
                }
            }
        }

        var savePath = AssetBundleLoader.streamingAssetsPath + "/filelist.csv";
        File.WriteAllText(savePath, strbld.ToString());
        EditorUtility.RevealInFinder(savePath);
    }
    
    public static void UpdateFileList()
    {
        GenFileList();
        AssetDatabase.Refresh();
    }

    public static void ClearStreamingAssets()
    {
        var path = m_StreamingAssetsPath;
        if (Directory.Exists(path)) {
            Directory.Delete(path, true);
        }
    }

    public static void ClearEditorStreamingAssets()
    {
        var path = AssetBundleLoader.streamingRootPath;
        if (Directory.Exists(path)) {
            Directory.Delete(path, true);
        }
    }

    public static void ClearEditorPersistentAssets()
    {
        var path = AssetBundleLoader.bundleRootPath;
        if (Directory.Exists(path)) {
            Directory.Delete(path, true);
        }
    }
}
