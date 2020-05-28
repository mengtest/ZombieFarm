using System.IO;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;


public static class GeneratePrefabUtil
{
    public enum EPrefabType
    {
        None = 0,
        Role = 1,
        Weapon = 2,
    }

    private static readonly string[] s_OrgAnimatorPaths = {"",
        "Assets/RefAssets/CATEGORY/Shared/Animation/StdUnit.controller",
        "Assets/RefAssets/CATEGORY/Shared/Animation/Weapon.controller",
    };

    public static void ExportMaterialInFbx(string fbxPath)
    {
        ModelImporter modelImporter = (ModelImporter)AssetImporter.GetAtPath(fbxPath);
        modelImporter.materialLocation = ModelImporterMaterialLocation.External;
        AssetDatabase.ImportAsset(fbxPath);
        AssetDatabase.SaveAssets();
        AssetDatabase.Refresh();
    }

    public static GameObject GenPrefabFromSelection(GameObject selected)
    {
        var go = Object.Instantiate(selected);
        Selection.activeGameObject = go;
        go.name = selected.name;

        SkinnedMeshRenderer skin = go.GetComponentInChildren(typeof(SkinnedMeshRenderer)) as SkinnedMeshRenderer;

        if (skin)
        {
            skin.updateWhenOffscreen = false;
            skin.skinnedMotionVectors = false;

            skin.lightProbeUsage = UnityEngine.Rendering.LightProbeUsage.Off;
            skin.reflectionProbeUsage = UnityEngine.Rendering.ReflectionProbeUsage.Off;
            skin.motionVectorGenerationMode = MotionVectorGenerationMode.ForceNoMotion;

            skin.sharedMaterial.shader = Shader.Find("ME/Toon/LitA");

            var mainTex = skin.sharedMaterial.GetTexture("_MainTex");
            if (mainTex)
            {
                var texPath = AssetDatabase.GetAssetPath(mainTex);
                var ext = Path.GetExtension(texPath);
                var texObj = AssetDatabase.LoadMainAssetAtPath(texPath.Replace(ext, "_a" + ext));
                skin.sharedMaterial.SetTexture("_AlphaTex", texObj as Texture);
            }
        }
        return go;
    }

    public static AnimatorOverrideController GenOverrideController(string fbxPath, Animator anim, EPrefabType type)
    {
        var animDir = Path.GetDirectoryName(fbxPath);
        var objName = Path.GetFileNameWithoutExtension(fbxPath);
        var overridePath = fbxPath.Substring(0, fbxPath.LastIndexOf('.')) + ".overrideController";
        var overrideController = AssetDatabase.LoadAssetAtPath<AnimatorOverrideController>(overridePath);
        if (overrideController == null)
        {
            overrideController = new AnimatorOverrideController();
            AssetDatabase.CreateAsset(overrideController, overridePath);
            var controller = AssetDatabase.LoadAssetAtPath<RuntimeAnimatorController>(s_OrgAnimatorPaths[(int)type]);
            overrideController.runtimeAnimatorController = controller;
        }
        anim.runtimeAnimatorController = overrideController;
        return overrideController;
    }

    public static bool SetOverrideClip(AnimatorOverrideController overrideController,
        string fbxPath, string clipName)
    {
        var animDir = Path.GetDirectoryName(fbxPath);
        var objName = Path.GetFileNameWithoutExtension(fbxPath);

        string aniPath = string.Format("{0}/{1}@{2}.FBX", animDir, objName, clipName);
        ModelImporter modelImporter = (ModelImporter)AssetImporter.GetAtPath(aniPath);
        if (modelImporter == null)
            return false;
        modelImporter.importMaterials = false;
        AssetDatabase.ImportAsset(aniPath);
        AssetDatabase.SaveAssets();
        AssetDatabase.Refresh();

        var clip = AssetDatabase.LoadAssetAtPath<AnimationClip>(aniPath);
        overrideController[clipName] = clip;
        return clip;
    }

    public static void ForceToZero(Transform tns, bool rot2zero = true)
    {
        tns.localPosition = Vector3.zero;
        if (rot2zero)
        {
            tns.localRotation = Quaternion.Euler(Vector3.zero);
        }
    }
}
