using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using System.IO;

// warning CS0168: 声明了变量，但从未使用
// warning CS0219: 给变量赋值，但从未使用
#pragma warning disable 0168, 0219, 0414 
public class HeroCtrl : MonoBehaviour
{
#if UNITY_EDITOR
    const int WIDTH = 180, HEIGHT = 25, INTERVAL = 26;

    public string HeroRoot = "Resources/Heroes";
    public string FxRoot = "Resources/FX";


    delegate int DelegateDrawElm<T>(string sub, T elm, int i);

    GameObject goHero = null;
    string defaultClip = null;

    GameObject goFx = null, goChecked = null;
    string fxDelay = "0", fxFilter = "";

    int aniMode = 0;
    string[] strMode = new string[] { "Once", "Loop" };

    int tabSelected = 0;
    string[] strMenus = new string[] { "Heroes", "FX" };

    Vector2 scrollPosition = Vector2.zero;
    string checkedHero, checkedFX, checkedClip;

    float shakeOffset = 0f;
    float shakeDura = 0f;

    string fxSaveName = "";

    Dictionary<string, Dictionary<string, GameObject>> dictHeroes = new Dictionary<string, Dictionary<string, GameObject>>();
    Dictionary<string, Dictionary<string, GameObject>> dictFX = new Dictionary<string, Dictionary<string, GameObject>>();
    Dictionary<string, GameObject> dictCommonFx;

    class GUIScrollView<T>
    {
        public Dictionary<string, T> dictMenu;
        public Rect rectView;
        public Vector2 scroll;
        public DelegateDrawElm<T> onDraw;

        public GUIScrollView()
        {
            scroll = Vector2.zero;
            dictMenu = new Dictionary<string, T>();
        }
    }

    GUIScrollView<string> ViewHeroes = new GUIScrollView<string>();
    GUIScrollView<GameObject> ViewActions = new GUIScrollView<GameObject>();
    GUIScrollView<GameObject> ViewFXs = new GUIScrollView<GameObject>();

    List<GameObject> loadResources(string dir)
    {
        List<GameObject> list = new List<GameObject>();
        Object[] objs = Resources.LoadAll(dir);
        foreach (Object o in objs) {
            if (o is GameObject) {
                list.Add(o as GameObject);
            }
        }
        return list;
    }

    Dictionary<string, GameObject> loadAssets(string dir, string sub)
    {
        Dictionary<string, GameObject> dict = new Dictionary<string, GameObject>();
        string subDir = Path.Combine(dir, sub);
        string fullDir = Path.Combine(Application.dataPath, subDir);
        if (Directory.Exists(fullDir)) {
            string[] files = Directory.GetFiles(fullDir);
            foreach (string file in files) {
                string fileName = file.Substring(fullDir.Length + 1);
                string path = Path.Combine(Path.Combine("Assets", subDir), fileName);
                GameObject go = UnityEditor.AssetDatabase.LoadAssetAtPath<GameObject>(path);
                if (go != null) {
                    dict.Add(sub + "/" + go.name, go);
                }
            }
        }
        return dict;
    }

    // Use this for initialization
    void Start()
    {
        string fullPath = Path.Combine(Application.dataPath, HeroRoot);
        string[] dirs = System.IO.Directory.GetFiles(fullPath, "*.prefab");
        foreach (string dir in dirs) {
            string fName = Path.GetFileNameWithoutExtension(dir); //dir.Substring(fullPath.Length + 1);
            dictHeroes.Add(fName, null);
            dictFX.Add(fName, null);
            ViewHeroes.dictMenu.Add(fName, fName);
        }
        ViewHeroes.rectView = new Rect(0, 25, WIDTH, Screen.height);
        ViewHeroes.onDraw = OnDrawHero;

        ViewFXs.rectView = new Rect(0, 25, WIDTH, Screen.height);
        ViewFXs.onDraw = OnDrawFX;

        ViewActions.rectView = new Rect(Screen.width - WIDTH, INTERVAL, WIDTH, 400);
        ViewActions.onDraw = OnDrawAnimation;

        dictCommonFx = loadAssets(FxRoot, "_common");
    }

    int OnDrawHero(string sub, string heroName, int i)
    {
        GUI.color = heroName == checkedHero ? Color.yellow : Color.white;
        if (GUI.Button(new Rect(0, i * INTERVAL, WIDTH, HEIGHT), heroName)) {
            checkedHero = heroName;
            fxFilter = heroName;
            goChecked = null;

            // Show FX
            tabSelected = 1;
            if (dictFX[heroName] == null) {
                Dictionary<string, GameObject> dict = loadAssets(FxRoot, heroName);
                foreach (KeyValuePair<string, GameObject> kv in dictCommonFx) {
                    dict.Add(kv.Key, kv.Value);
                }
                dictFX[heroName] = dict;
            }
            ViewFXs.dictMenu = dictFX[heroName];

            // Show Actions
            if (dictHeroes[heroName] == null) {
                dictHeroes[heroName] = loadAssets(HeroRoot, heroName);
            }
            ViewActions.dictMenu = dictHeroes[heroName];
        }
        return i + 1;
    }

    Dictionary<string, bool> dictFxToggle = new Dictionary<string, bool>();
    List<GameObject> listCheckedFx = new List<GameObject>();
    int OnDrawFX(string sub, GameObject go, int i)
    {
        string fullName = sub + "/" + go.name;
        bool value;
        if (!dictFxToggle.TryGetValue(fullName, out value)) {
            value = false;
            dictFxToggle.Add(fullName, value);
        }
        //GUI.color = sub == checkedFX ? Color.yellow : Color.white;
        value = GUI.Toggle(new Rect(0, i * INTERVAL, WIDTH, HEIGHT), value, go.name);
        dictFxToggle[fullName] = value;
        if (value) {
            if (!listCheckedFx.Contains(go)) {
                listCheckedFx.Add(go);
            }
        } else {
            listCheckedFx.Remove(go);
        }
        return i + 1;
    }

    int OnDrawAnimation(string sub, GameObject go, int i)
    {
        GUI.color = sub == checkedClip ? Color.yellow : Color.white;
        if (GUI.Button(new Rect(0, i * INTERVAL, WIDTH, HEIGHT), go.name)) {
            checkedClip = sub;

            if (go.GetComponent<Animation>() && go.GetComponent<Animation>().clip) {
                WrapMode wrapMode = (WrapMode)System.Enum.Parse(typeof(WrapMode), strMode[aniMode]);
                go.GetComponent<Animation>().clip.wrapMode = wrapMode;
            }

            if (goHero != null) {
                Destroy(goHero);
            }

            goHero = GameObject.Instantiate(go) as GameObject;
            Transform trans = goHero.transform;
            trans.parent = transform;
            trans.localPosition = Vector3.zero;
            trans.localScale = Vector3.one;
            goHero.layer = gameObject.layer;

            if (goHero.GetComponent<Animation>() && goHero.GetComponent<Animation>().clip) {
                goHero.GetComponent<Animation>().Play(go.GetComponent<Animation>().clip.name);
            }
            // Play checked Fx
            float delay = 0;
            float.TryParse(fxDelay, out delay);
            if (listCheckedFx.Count > 1) {
                for (int n = 0; n < listCheckedFx.Count; ++n) {
                    StartCoroutine(CreateFX(listCheckedFx[n], n * delay));
                }
            } else {
                StartCoroutine(CreateFX(listCheckedFx[0], delay));
            }
            foreach (GameObject g in listCreatedFx) {
                Destroy(g);
            }
            listCreatedFx.Clear();
        }
        return i + 1;
    }

    List<GameObject> listCreatedFx = new List<GameObject>();
    IEnumerator CreateFX(GameObject fx, float delay)
    {
        yield return new WaitForSeconds(delay);

        GameObject goFx = GameObject.Instantiate(fx) as GameObject;
        goFx.name = fx.name;
        Transform trans = goFx.transform;
        trans.parent = transform.parent;
        trans.localPosition = Vector3.zero;
        trans.localScale = Vector3.one;
        goFx.layer = gameObject.layer;

        foreach (KeyValuePair<string, GameObject> kv in dictFX[checkedHero]) {
            if (kv.Value == fx) {
                fxSaveName = kv.Key;
                break;
            }
        }


        listCreatedFx.Add(goFx);
    }

    void DrawScrollView<T>(GUIScrollView<T> view)
    {
        view.scroll = GUI.BeginScrollView(view.rectView, view.scroll, new Rect(0, 0, WIDTH, INTERVAL * view.dictMenu.Count));
        int n = 0;
        foreach (KeyValuePair<string, T> kv in view.dictMenu) {
            n = view.onDraw(kv.Key, kv.Value, n);
        }
        GUI.EndScrollView();
    }

    void OnGUI()
    {
        GUI.color = Color.white;

        // Animation Play Delay
        GUI.Label(new Rect(Screen.width - 240, 0, 40, 25), "Delay");
        fxDelay = GUI.TextField(new Rect(Screen.width - 200, 0, 80, 25), fxDelay);
        //fxFilter = GUI.TextField(new Rect(125, 0, 80, 25), fxFilter);

        GUI.BeginGroup(new Rect(Screen.width - 360, Screen.height - 40, 360, 45));
        // Fx Save Name
        GUI.Label(new Rect(10, 10, 60, 25), "Name");
        fxSaveName = GUI.TextField(new Rect(70, 10, 200, 25), fxSaveName);
        // Fx Save Button
        if (GUI.Button(new Rect(270, 10, 90, 25), "Save FX")) {
            if (goFx != null) {
#if UNITY_EDITOR
                GameObject goSave = UnityEditor.PrefabUtility.CreatePrefab("Assets/" + FxRoot + "/" + fxSaveName + ".prefab", goFx);
                if (ViewFXs.dictMenu.ContainsKey(fxSaveName)) {
                    ViewFXs.dictMenu[fxSaveName] = goSave;
                } else {
                    ViewFXs.dictMenu.Add(fxSaveName, goSave);
                }
#endif
            }
        }
        GUI.EndGroup();

        tabSelected = GUI.SelectionGrid(new Rect(0, 0, strMenus.Length * 60, 25), tabSelected, strMenus, strMenus.Length);
        aniMode = GUI.SelectionGrid(new Rect(Screen.width - strMode.Length * 60, 0, strMenus.Length * 60, 25), aniMode, strMode, strMode.Length);

        // FX List - View
        System.Text.StringBuilder strbld = new System.Text.StringBuilder("选择的特效：");
        foreach (GameObject go in listCheckedFx) {
            strbld.Append(go.name).Append("->");
        }
        strbld.Append("|");
        GUI.Label(new Rect(300, 0, 500, 25), strbld.ToString());

        // HeroList
        switch (tabSelected) {
            case 0: {
                    DrawScrollView(ViewHeroes);
                    dictFxToggle.Clear();
                    listCheckedFx.Clear();
                }
                break;
            case 1: DrawScrollView(ViewFXs); break;
        }
        DrawScrollView(ViewActions);

    }
#endif
}
