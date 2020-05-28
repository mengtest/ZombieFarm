using System.IO;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using World.View;


public static class GenerateWeaponPrefab
{
    private static Animator FindAnimatorForWeapon(GameObject go)
    {
        GameObject goAni = null;
        foreach (Transform t in go.transform)
        {
            if (t.name.Substring(0, 5) == "Dummy")
            {
                goAni = t.gameObject;
                GeneratePrefabUtil.ForceToZero(goAni.transform);
                break;
            }
        }
        return goAni ? goAni.AddComponent(typeof(Animator)) as Animator : null;
    }

    private static bool ContainsWeaponAni(string fbxPath)
    {
        var animDir = Path.GetDirectoryName(fbxPath);
        string[] files = Directory.GetFiles(animDir);
        for (int i = 0; i < files.Length; i++)
        {
            string fileName = files[i];
            if (fileName.Contains("@") && !fileName.Contains(".meta"))
                return true;
        }
        return false;
    }

    private static void GenWeaponAnimatorController(string fbxPath, Animator anim)
    {
        if (anim == null)
            return;

        var overrideController = GeneratePrefabUtil.GenOverrideController(fbxPath, anim, GeneratePrefabUtil.EPrefabType.Weapon);

        GeneratePrefabUtil.SetOverrideClip(overrideController, fbxPath, "attack");
        GeneratePrefabUtil.SetOverrideClip(overrideController, fbxPath, "default");
        GeneratePrefabUtil.SetOverrideClip(overrideController, fbxPath, "hold");
        GeneratePrefabUtil.SetOverrideClip(overrideController, fbxPath, "reload");
    }

    private static void GenWeaponModel(string fbxPath, GameObject root, Animator anim)
    {
        root.AddComponent<BoxCollider>();
        root.AddComponent<Rigidbody>();
        AffixView view = root.AddComponent<AffixView>();
        if (anim)
        {
            var serializedObject = new SerializedObject(view);
            var m_Anim = serializedObject.FindProperty("m_Anim");
            m_Anim.objectReferenceValue = anim;
            serializedObject.ApplyModifiedProperties();
        }
    }


    [MenuItem("Assets/生成/武器")]
    private static void GenPrefabForWeaponModel()
    {
        var selected = Selection.activeGameObject;
        var path = AssetDatabase.GetAssetPath(selected);
        if (!path.ToLower().EndsWith(".fbx") || path.Contains("@")) return;

        GeneratePrefabUtil.ExportMaterialInFbx(path);
        var go = GeneratePrefabUtil.GenPrefabFromSelection(selected);

        GameObject.DestroyImmediate(go.GetComponent(typeof(Animator)));
        Animator anim = null;

        if (ContainsWeaponAni(path))
        {
            anim = FindAnimatorForWeapon(go);
            GenWeaponAnimatorController(path, anim);
        }

        GenWeaponModel(path, go, anim);
    }
}