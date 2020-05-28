using UnityEngine;
using UnityEditor;
using System.Collections;
using System.Collections.Generic;
using System.IO;

using DelegateModelImport = System.Action<UnityEditor.ModelImporter>;
using DelegateTextureImport = System.Action<UnityEditor.TextureImporter, string>;
using DelegateAudioImport = System.Action<UnityEditor.AudioImporter>;

public class MyAssetPostprocessor : AssetPostprocessor
{
    #region 模型处理
    private static void PreprocessDefaultModel(ModelImporter mi)
    {
        var assetName = Path.GetFileNameWithoutExtension(mi.assetPath);
        var hasAnimation = assetName.Contains("@");
       
        mi.importAnimation = hasAnimation;
        if (hasAnimation) {
            mi.animationCompression = mi.animationType == ModelImporterAnimationType.Legacy ?
                ModelImporterAnimationCompression.KeyframeReductionAndCompression :
                ModelImporterAnimationCompression.Optimal;
        }
        //mi.importMaterials = !hasAnimation;
        //mi.materialLocation = ModelImporterMaterialLocation.External;
        
        mi.isReadable = assetName.OrdinalIgnoreCaseEndsWith("_rw");
        mi.optimizeMesh = true;
        mi.importBlendShapes = false;
        mi.addCollider = false;
        mi.keepQuads = false;
        mi.weldVertices = true;
        mi.importVisibility = true;
        mi.importCameras = false;
        mi.importLights = false;
        mi.swapUVChannels = false;
    }

    private static void PreprocessUnitModel(ModelImporter mi)
    {
        
    }

    private static void PreprocessSceneModel(ModelImporter mi)
    {
        if (!mi.importAnimation) {
            mi.animationType = ModelImporterAnimationType.None;
        }
    }

    private static void PreprocessSkinModel(ModelImporter mi)
    {

    }
    
    private static void PreprocessFxModel(ModelImporter mi)
    {
        mi.importMaterials = false;
    }

    private static void PreprocessHumanModel(ModelImporter mi)
    {
        mi.animationType = ModelImporterAnimationType.Generic;
        mi.isReadable = true;
    }

    private static readonly Dictionary<string, DelegateModelImport> ModelPrepAction = new Dictionary<string, DelegateModelImport> {
        { "Assets/Artwork/Models", PreprocessUnitModel },
        { "Assets/RefAssets/CATEGORY/FX", PreprocessFxModel },
        { "Assets/RefAssets/OBO/Hair", PreprocessHumanModel },
        { "Assets/RefAssets/OBO/Head", PreprocessHumanModel },
        { "Assets/RefAssets/OBO/Body", PreprocessHumanModel },
        { "Assets/RefAssets/OBO/Legs", PreprocessHumanModel },
        { "Assets/RefAssets/OBO/Feet", PreprocessHumanModel },
        { "Assets/RefAssets/OBO/RArms", PreprocessHumanModel },
        { "Assets/RefAssets/OBO/RBackpack", PreprocessHumanModel },
        { "Assets/RefAssets/OBO/RBody", PreprocessHumanModel },
        { "Assets/RefAssets/OBO/RTrack", PreprocessHumanModel },
        { "Assets/Scenes", PreprocessSceneModel },
    };

    /// <summary>
    /// 预载入模型设置
    /// </summary>
    private void OnPreprocessModel()
    {
        var mi = assetImporter as ModelImporter;
        
        var obj = AssetDatabase.LoadMainAssetAtPath(mi.assetPath);
        var lbs = AssetDatabase.GetLabels(obj);
        foreach (var lb in lbs) {
            if (string.CompareOrdinal(lb, "Manual") == 0) return;
        }

        PreprocessDefaultModel(mi);
        
        foreach (var lb in lbs) {
            switch (lb) {
                case "Readable": mi.isReadable = true; break;
                case "CompressMesh": mi.meshCompression = ModelImporterMeshCompression.High; break;
                default: break;
            }
        }

        foreach (var kv in ModelPrepAction) {
            if (assetPath.Contains(kv.Key)) {
                kv.Value.Invoke(assetImporter as ModelImporter);
                break;
            }
        }
    }

    private static void PostprocessUnitModel(ModelImporter mi)
    {
        // Post Animatoions
        var clips = mi.clipAnimations;
        if (clips == null || clips.Length == 0) clips = mi.defaultClipAnimations;
        var Chars = new char[] { '@', '_' };
        foreach (var clip in clips) {
            var name = clip.name;
            var index = name.LastIndexOfAny(Chars);
            if (index > 0) {
                name = name.Substring(index + 1);
            }
            switch (name) {
                case "idle":
                case "run":
                case "walk":
                case "sneak":
                case "sneakidle":
                case "attackidle":
                    clip.loopTime = true;
                    clip.loopPose = true;
                    clip.loop = true;
                    clip.wrapMode = WrapMode.Loop;
                    break;
                default: break;
            }
        }
        mi.clipAnimations = clips;
    }

    private static readonly Dictionary<string, DelegateModelImport> ModelPostAction = new Dictionary<string, DelegateModelImport> {
        { "Assets/Artwork/Models", PostprocessUnitModel },
    };

    /// <summary>
    /// 模型已加载设置
    /// </summary>
    private void OnPostprocessModel(GameObject root)
    {
        foreach (var kv in ModelPostAction) {
            if (assetPath.Contains(kv.Key)) {
                kv.Value.Invoke(assetImporter as ModelImporter);
                break;
            }
        }
    }

    #endregion

    #region 材质处理

    private static void OnUnitMaterialPost(AssetImporter ai, Material mat)
    {
        mat.shader = Shader.Find("ME/Toon/LitA Outline");
    }

    private static readonly Dictionary<string, System.Action<AssetImporter, Material>> 
        MatPostAction = new Dictionary<string, System.Action<AssetImporter, Material>> {
            { "Assets/Artwork/Models", OnUnitMaterialPost },
            { "RefAssets/OBO/Body", OnUnitMaterialPost },
            { "RefAssets/OBO/Feet", OnUnitMaterialPost },
            { "RefAssets/OBO/Head", OnUnitMaterialPost },
            { "RefAssets/OBO/Legs", OnUnitMaterialPost },
            { "RefAssets/OBO/RArms", OnUnitMaterialPost },
            { "RefAssets/OBO/RBackpack", OnUnitMaterialPost },
            { "RefAssets/OBO/RBody", OnUnitMaterialPost },
            { "RefAssets/OBO/RTrack", OnUnitMaterialPost },
    };
    
    private void OnPostprocessMaterial(Material material)
    {
        foreach (var kv in MatPostAction) {
            if (assetPath.Contains(kv.Key)) {
                kv.Value.Invoke(assetImporter, material);
                break;
            }
        }
    }

    #endregion
    
    #region 图片处理
    private static void ClampTextureSize(TextureImporter self, int size)
    {
        if (self.maxTextureSize > size) {
            self.maxTextureSize = size;
        }
    }

    private static void PreprocessUITexture(TextureImporter ti, string folder)
    {
        ti.textureType = TextureImporterType.Sprite;
        ti.mipmapEnabled = false;
        ti.textureCompression = TextureImporterCompression.Uncompressed;
        ClampTextureSize(ti, 1024);

        //ti.spritePackingTag = folder;
    }
    private static void PreprocessRawTexture(TextureImporter ti, string folder)
    {
        ti.textureType = TextureImporterType.Sprite;
        ti.mipmapEnabled = false;
        //ti.textureFormat = TextureImporterFormat.AutomaticTruecolor;
        ClampTextureSize(ti, 2048);

        ti.spritePackingTag = "";
    }

    private static void PreprocessRoleTexture(TextureImporter ti, string folder)
    {
        ti.textureType = TextureImporterType.Default;
        ti.wrapMode = TextureWrapMode.Clamp;
        ti.filterMode = FilterMode.Bilinear;
        ti.isReadable = false;
        ti.alphaSource = TextureImporterAlphaSource.FromInput;
        ti.alphaIsTransparency = true;
        ti.mipmapEnabled = false;
        ti.textureCompression = TextureImporterCompression.Compressed;
        ti.compressionQuality = 100;
    }

    private static void PreprocessRoleBodyTexture(TextureImporter ti, string folder)
    {
        PreprocessRoleTexture(ti, folder);
        ti.maxTextureSize = 512;
    }

    private static void PreprocessRoleFeetTexture(TextureImporter ti, string folder)
    {
        PreprocessRoleTexture(ti, folder);
        ti.maxTextureSize = 256;
    }

    private static void PreprocessRoleHeadTexture(TextureImporter ti, string folder)
    {
        PreprocessRoleTexture(ti, folder);
        ti.maxTextureSize = 256;
    }

    private static void PreprocessRoleHairTexture(TextureImporter ti, string folder)
    {
        PreprocessRoleTexture(ti, folder);
        ti.maxTextureSize = 128;
    }

    private static void PreprocessRoleLegsTexture(TextureImporter ti, string folder)
    {
        PreprocessRoleTexture(ti, folder);
        ti.maxTextureSize = 512;
    }

    private static void PreprocessModelTexture(TextureImporter ti, string folder)
    {
        ti.textureType = TextureImporterType.Default;
        ti.wrapMode = TextureWrapMode.Clamp;
        ti.filterMode = FilterMode.Bilinear;
        ti.mipmapEnabled = false;
        ti.textureCompression = TextureImporterCompression.CompressedHQ;
        ti.compressionQuality = 100;
        ClampTextureSize(ti, 256);
    }
    
    private static void PreprocessFxTexture(TextureImporter ti, string folder)
    {
        ti.textureType = TextureImporterType.Default;
        ti.filterMode = FilterMode.Bilinear;
        ti.textureCompression = TextureImporterCompression.CompressedLQ;
        ti.compressionQuality = 100;
        ClampTextureSize(ti, 128);
    }

    private static Dictionary<string, DelegateTextureImport> dictTextureImportActions = new Dictionary<string, DelegateTextureImport>() {
        { "Assets/Artwork/Models", PreprocessModelTexture },
        { "Assets/RefAssets/CATEGORY/Shared/FX", PreprocessFxTexture },
        { "Assets/RefAssets/CATEGORY/FX", PreprocessFxTexture },
        { "Assets/Artwork/Atlas", PreprocessUITexture },
        { "Assets/Artwork/UI", PreprocessUITexture },
        { "Assets/RefAssets/RawImage", PreprocessRawTexture },
        { "Assets/RefAssets/OBO/Body", PreprocessRoleBodyTexture },
        { "Assets/RefAssets/OBO/Feet", PreprocessRoleFeetTexture },
        { "Assets/RefAssets/OBO/Head", PreprocessRoleHeadTexture },
        { "Assets/RefAssets/OBO/Hair", PreprocessRoleHairTexture },
        { "Assets/RefAssets/OBO/Legs", PreprocessRoleLegsTexture },
        { "Assets/RefAssets/CATEGORY/Skin", PreprocessRoleTexture },
    };

    private void OnPreprocessTexture()
    {
        var ti = assetImporter as TextureImporter;

        var assetName = Path.GetFileNameWithoutExtension(ti.assetPath);
        if (assetName.OrdinalIgnoreCaseEndsWith("_s")) return;

        // 规则
        var obj = AssetDatabase.LoadMainAssetAtPath(assetPath);
        var lbs = AssetDatabase.GetLabels(obj);
        foreach (var lb in lbs) {
            switch (lb) {
                case "Manual" : return;
                case "Readable": ti.isReadable = true; break;
                default: break;
            }
        }

        // 目录
        var parent = Path.GetDirectoryName(assetPath).Replace("\\", "/");
        var folder = Path.GetFileName(parent);
        foreach (var kv in dictTextureImportActions) {
            if (assetPath.Contains(kv.Key)) {
                kv.Value.Invoke(ti, folder);
                break;
            }
        }
    }

    #endregion


    #region 音频资源


    public static void PreprocessFxAudio(AudioImporter ai)
    {
        var settings = ai.defaultSampleSettings;
        settings.compressionFormat = AudioCompressionFormat.ADPCM;
        ai.defaultSampleSettings = settings;
    }

    private static Dictionary<string, DelegateAudioImport> dictAudioImportActions = new Dictionary<string, DelegateAudioImport>() {
        { "Assets/RefAssets/FX", PreprocessFxAudio },
    };

    private void OnPreprocessAudio()
    {
        foreach (var kv in dictAudioImportActions) {
            if (assetPath.Contains(kv.Key)) {
                kv.Value.Invoke(assetImporter as AudioImporter);
                break;
            }
        }
    }
    #endregion

    private void OnPostProcessGameObjectWithUserProperties(
        GameObject go,
        string[] propNames, System.Object[] values)
    {
        Debug.Log(go);
    }

    private void OnPreprocessAssetbundleNameChanged(string assetPath, string previousAssetBundleName, string newAssetBundleName)
    {

    }
}
