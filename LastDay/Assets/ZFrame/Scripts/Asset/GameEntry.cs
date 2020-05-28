using UnityEngine;
using UnityEngine.SceneManagement;
using System.Collections;

public class GameEntry : MonoBehaviour
{
    // Use this for initialization
    void Start()
    {
        if (AssetsMgr.Instance == null) {
            InitEntry();
        }
        
        //GameSettings.Instance.GetSettings();
    }

    public static void InitEntry()
    {
        var obj = Resources.Load("AssetsMgr");
        GoTools.NewChild(null, obj as GameObject);
    }
}
