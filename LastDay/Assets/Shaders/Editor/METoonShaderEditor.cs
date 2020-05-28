using System.Collections;
using System.Collections.Generic;
using FMOD.Studio;
using UnityEngine;
using UnityEditor;
using UnityEngine.Rendering;
using ZFrame;

public class METoonShaderEditor : ShaderGUI
{
    public enum Blend
    {
        Opaque,
        Transparent,
        AlphaGrid,
    }
    
    private MaterialProperty m_MainTex, m_Color, m_HColor, m_SColor;
    private MaterialProperty m_Ramp, m_RampThreshold, m_RampSmooth;
    private MaterialProperty m_CutOff;
    private MaterialProperty m_SkinTex, m_SkinCut;
    private MaterialProperty m_HairUv, m_HairColor, m_HairSpecular, m_HairShininess;
    private MaterialProperty m_OutlineColor, m_Outline, m_ZSmooth, m_Offset1, m_Offset2;
    private MaterialProperty m_AlphaGridTex;
    private MaterialProperty m_MatCap, m_MColor;
    private MaterialProperty m_SpecTex, m_Specular, m_Shininess;
    private MaterialProperty m_AtlasUV;

    private void FindProperties(MaterialProperty[] props)
    {
        m_MainTex = FindProperty("_MainTex", props);
        m_Color = FindProperty("_Color", props);
        m_HColor = FindProperty("_HColor", props, false);
        m_SColor = FindProperty("_SColor", props, false);

        m_Ramp = FindProperty("_Ramp", props, false);
        m_RampThreshold = FindProperty("_RampThreshold", props, false);
        m_RampSmooth = FindProperty("_RampSmooth", props, false);

        m_CutOff = FindProperty("_Cutoff", props);

        m_SkinTex = FindProperty("_SkinTex", props, false);
        m_SkinCut = FindProperty("_SkinCut", props, false);

        m_HairUv = FindProperty("_HairUV", props, false);
        m_HairColor = FindProperty("_HairColor", props, false);
        m_HairShininess = FindProperty("_HairShininess", props, false);
        m_HairSpecular = FindProperty("_HairSpecular", props, false);

        m_OutlineColor = FindProperty("_OutlineColor", props, false);
        m_Outline = FindProperty("_Outline", props, false);
        m_ZSmooth = FindProperty("_ZSmooth", props, false);
        m_Offset1 = FindProperty("_Offset1", props, false);
        m_Offset2 = FindProperty("_Offset2", props, false);

        m_AlphaGridTex = FindProperty("_AlphaGridTex", props, false);
        
        m_MatCap = FindProperty("_MatCap", props, false);
        m_MColor = FindProperty("_MColor", props, false);
        
        m_SpecTex = FindProperty("_SpecTex", props, false);
        m_Specular = FindProperty("_Specular", props, false);
        m_Shininess = FindProperty("_Shininess", props, false);

        m_AtlasUV = FindProperty("_AtlasUV", props);
    }
    
    private static void DrawTexProp(MaterialEditor matEditor, MaterialProperty p1, 
        MaterialProperty p2 = null, MaterialProperty p3 = null)
    {
        if (p3 != null) {
            matEditor.TexturePropertySingleLine(new GUIContent(p1.displayName), p1, p2, p3);
        } else if (p2 != null) {
            matEditor.TexturePropertySingleLine(new GUIContent(p1.displayName), p1, p2);
        } else {
            matEditor.TexturePropertySingleLine(new GUIContent(p1.displayName), p1);
        }
    }

    public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
    {
        FindProperties(properties);
    
        //materialEditor.SetDefaultGUIWidths();
        var targetMat = (Material)materialEditor.target;
                
        var transparent = System.Array.IndexOf(targetMat.shaderKeywords, "TOON_TRANSPARENT") != -1;
        var skin = System.Array.IndexOf(targetMat.shaderKeywords, "BLEND_SKIN_TEX") != -1;
        var grayscale = System.Array.IndexOf(targetMat.shaderKeywords, "SET_GRAYSCALE") != -1;
        var addHair = System.Array.IndexOf(targetMat.shaderKeywords, "ADD_HAIR_COLOR") != -1;
        var pointlit = System.Array.IndexOf(targetMat.shaderKeywords, "TOON_SIMULATE_POINTLIT") != -1;

        var srcBlend = (BlendMode)targetMat.GetInt("_SrcBlend");
        var dstBlend = (BlendMode)targetMat.GetInt("_DstBlend");
        var blend = transparent ? Blend.AlphaGrid :
            srcBlend != BlendMode.One && dstBlend != BlendMode.Zero ? Blend.Transparent : Blend.Opaque;
        if ((blend == Blend.Opaque || blend == Blend.AlphaGrid) && (srcBlend != BlendMode.One || dstBlend != BlendMode.Zero)) {
            targetMat.SetInt("_SrcBlend", (int)BlendMode.One);
            targetMat.SetInt("_DstBlend", (int)BlendMode.Zero);
        }
        
        EditorGUI.BeginChangeCheck();
        blend = (Blend)EditorGUILayout.EnumPopup("Blend Type", blend, GUILayout.ExpandWidth(true));
        if (EditorGUI.EndChangeCheck()) {
            switch (blend) {
                case Blend.Opaque:
                    targetMat.SetKeyword("TOON_TRANSPARENT", false);
                    targetMat.SetInt("_SrcBlend", (int)BlendMode.One);
                    targetMat.SetInt("_DstBlend", (int)BlendMode.Zero);
                    break;
                case Blend.AlphaGrid:
                    targetMat.SetKeyword("TOON_TRANSPARENT", true);
                    targetMat.SetInt("_SrcBlend", (int)BlendMode.One);
                    targetMat.SetInt("_DstBlend", (int)BlendMode.Zero);
                    break;
                case Blend.Transparent:
                    targetMat.SetKeyword("TOON_TRANSPARENT", false);
                    targetMat.SetInt("_SrcBlend", (int)BlendMode.SrcAlpha);
                    targetMat.SetInt("_DstBlend", (int)BlendMode.OneMinusSrcAlpha);
                    break;
            }
        }

        EditorGUI.BeginDisabledGroup(blend != Blend.AlphaGrid);
        DrawTexProp(materialEditor, m_AlphaGridTex);
        EditorGUI.EndDisabledGroup();
        EditorGUILayout.Separator();
        
        // MainTex
        EditorGUILayout.BeginHorizontal();
        DrawTexProp(materialEditor, m_MainTex, m_Color);
        EditorUtil.KeywordCheck(targetMat, "Grayscale", "SET_GRAYSCALE", grayscale, true);
        EditorGUILayout.EndHorizontal();
        materialEditor.DrawProperty(m_AtlasUV);
        
        if (m_Ramp != null) {
            EditorGUILayout.LabelField("Light Settings", EditorStyles.boldLabel);
            EditorGUI.indentLevel++;
            materialEditor.DrawProperty(m_HColor);
            materialEditor.DrawProperty(m_SColor);
            var ramp = System.Array.IndexOf(targetMat.shaderKeywords, "TOON_RAMP_TEX") != -1;
            ramp = EditorUtil.KeywordCheck(targetMat, "Use Ramp Texture", "TOON_RAMP_TEX", ramp);
            EditorGUI.indentLevel++;
            if (ramp) {
                DrawTexProp(materialEditor, m_Ramp);
            } else {
                materialEditor.DrawProperty(m_RampThreshold, "Threshold");
                materialEditor.DrawProperty(m_RampSmooth, "Smoothing");
            }
            EditorGUI.indentLevel--;
            EditorGUI.indentLevel--;
            EditorGUILayout.Separator();
        }
    
        EditorGUILayout.LabelField("Blend Settings", EditorStyles.boldLabel);
        EditorGUI.indentLevel++;
        materialEditor.DrawProperty(m_CutOff, "Alpha Cutoff");

        skin = EditorUtil.KeywordCheck(targetMat, "Use Skin Texture", "BLEND_SKIN_TEX", skin);
        if (skin) {
            EditorGUI.indentLevel++;
            DrawTexProp(materialEditor, m_SkinTex, m_SkinCut);
            EditorGUI.indentLevel--;
            EditorGUILayout.Separator();
        }
        
        if (m_HairUv != null) {
            addHair = EditorUtil.KeywordCheck(targetMat, "Add Hair Color", "ADD_HAIR_COLOR", addHair);
            if (addHair) {
                EditorGUI.indentLevel++;
                materialEditor.DrawProperty(m_HairColor, "Hair Color");
                materialEditor.DrawProperty(m_HairUv, "Hair UV");
                materialEditor.DrawProperty(m_HairSpecular);
                materialEditor.DrawProperty(m_HairShininess);
                EditorGUI.indentLevel--;
            }
        }
        EditorGUI.indentLevel--;
        EditorGUILayout.Separator();

        EditorUtil.KeywordCheck(targetMat, "Pointlit", "TOON_SIMULATE_POINTLIT", pointlit);

        if (m_Outline != null) {
            var constWidth = System.Array.IndexOf(targetMat.shaderKeywords, "CONST_WIDTH") != -1;
            EditorGUILayout.LabelField("Outline Settings", EditorStyles.boldLabel);
            EditorGUI.indentLevel++;
            materialEditor.DrawProperty(m_OutlineColor);
            EditorGUILayout.BeginHorizontal();
            materialEditor.DrawProperty(m_Outline);
            EditorUtil.KeywordCheck(targetMat, "Const Width", "CONST_WIDTH", constWidth);
            EditorGUILayout.EndHorizontal();
            if (m_ZSmooth != null) materialEditor.DrawProperty(m_ZSmooth);
            if (m_Offset1 != null) materialEditor.DrawProperty(m_Offset1);
            if (m_Offset2 != null) materialEditor.DrawProperty(m_Offset2);
            EditorGUI.indentLevel--;
            EditorGUILayout.Separator();
        }

        if (m_MatCap != null) {
            DrawTexProp(materialEditor, m_MatCap, m_MColor);
            EditorGUILayout.Separator();
        }

        if (m_SpecTex != null) {
            EditorGUILayout.LabelField("Spec Settings", EditorStyles.boldLabel);
            EditorGUI.indentLevel++;
            DrawTexProp(materialEditor, m_SpecTex);
            materialEditor.DrawProperty(m_Specular);
            materialEditor.DrawProperty(m_Shininess);
            EditorGUI.indentLevel--;
        }

        base.OnGUI(materialEditor, properties);
        //materialEditor.RenderQueueField();
        //materialEditor.EnableInstancingField();
        //materialEditor.DoubleSidedGIField();

        const string PassName = "ShadowCaster";
        var passEnable = targetMat.GetShaderPassEnabled(PassName);
        if (passEnable != EditorGUILayout.Toggle(PassName, passEnable)) {
            targetMat.SetShaderPassEnabled(PassName, !passEnable);
        }

    }
}
