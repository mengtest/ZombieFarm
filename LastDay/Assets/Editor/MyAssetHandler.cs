using UnityEditor;
using UnityEditor.Callbacks;
using System.Collections;
using System.IO;

public class MyAssetHandler
{
    [OnOpenAsset(1)]
    public static bool AssetHandler_Step1(int instanceID, int line)
    {
        var path = AssetDatabase.GetAssetPath(instanceID);
        var ext = Path.GetExtension(path).ToLower();
        switch (ext) {
            case ".bytes": 
            case ".shader":
            case ".cginc":
                return Handle_dot_bytes(path);
            default: break;
        }
        // did not handle the open
        return false; 
    }

    #if UNITY_EDITOR_WIN
    private static string sublimePath = "D:/Program Files/Sublime Text 3/sublime_text.exe";
    #elif UNITY_EDITOR_OSX
    private static string sublimePath = "/Applications/Sublime Text.app/Contents/MacOS/Sublime Text";
    #endif
    
    private static bool Handle_dot_bytes(string path)
    {
        if (File.Exists(sublimePath)) {
            System.Diagnostics.Process process = new System.Diagnostics.Process();
            System.Diagnostics.ProcessStartInfo startInfo = new System.Diagnostics.ProcessStartInfo();
            startInfo.WindowStyle = System.Diagnostics.ProcessWindowStyle.Hidden;
            startInfo.FileName = sublimePath;
            startInfo.Arguments = string.Format("\"{0}\"", path);
            process.StartInfo = startInfo;
            process.Start();
            return true;
        }

        return false;
    }
}
