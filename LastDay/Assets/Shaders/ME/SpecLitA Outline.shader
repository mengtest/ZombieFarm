Shader "ME/Spec/LitA Outline"
{
    Properties
    {
        [HideInInspector]_Color("Color", Color) = (0.6,0.6,0.6,1.0)
        [HideInInspector]_HColor("Highlight Color", Color) = (1.0,1.0,1.0,1.0)
        [HideInInspector]_SColor("Shadow Color", Color) = (0.2,0.2,0.2,1.0)

        [HideInInspector]_Ramp("Ramp Tex", 2D) = "gray" {}
        [HideInInspector]_RampThreshold("Ramp Threshold", Range(0,1)) = 0.5
        [HideInInspector]_RampSmooth("Ramp Smoothing", Range(0.01,1)) = 0.1

        [HideInInspector]_MainTex("Main (RGBA)", 2D) = "white" {}
        [HideInInspector]_Cutoff("Alpha Cut", Range(0,1)) = 0.5

        [HideInInspector]_SkinTex("Skin (RGB)", 2D) = "black" {}
        [HideInInspector]_SkinCut("Skin Cut", Range(0,1)) = 0.1

		[HideInInspector]_AtlasUV("UV in Atlas", Vector) = (0, 0, 1, 1)

        [HideInInspector]_OutlineColor("Outline Color", Color) = (0.2, 0.2, 0.2, 1.0)
        [HideInInspector]_Outline("Outline Width", Float) = 1
        [HideInInspector]_ZSmooth("Z Correction", Range(-3.0,3.0)) = 0
        [HideInInspector]_Offset1("Z Offset 1", Float) = 0
        [HideInInspector]_Offset2("Z Offset 2", Float) = 0

        [HideInInspector]_SpecTex("Spec Texture", 2D) = "white" {}
		[HideInInspector]_Specular("Specular", Range(0, 10)) = 1
        [HideInInspector]_Shininess("Shininess", Range(0.01, 1)) = 0.5

        [HideInInspector]_AlphaGridTex ("Alpha Grid", 2D) = "white" {}

        [HideInInspector][Enum(UnityEngine.Rendering.BlendMode)] _SrcBlend ("Src Blend", Int) = 1
        [HideInInspector][Enum(UnityEngine.Rendering.BlendMode)] _DstBlend ("Dst Blend", Int) = 0
    }

    SubShader
    {
        Tags{ "RenderType" = "Opaque" }
        LOD 200

		UsePass "ME/Spec/LitA/BASE"
        UsePass "ME/Toon/Outline(Shader Model 2)/OUTLINE"
		UsePass "Hidden/Toon/SHADOWCASTER"
    }

    //Fallback "Diffuse"
    CustomEditor "METoonShaderEditor"
}
