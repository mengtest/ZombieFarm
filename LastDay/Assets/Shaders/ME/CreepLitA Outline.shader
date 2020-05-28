Shader "ME/Creep/LitA Outline"
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

        [HideInInspector]_AlphaTex("Alpha (A)", 2D) = "white" {}
        [HideInInspector]_Cutoff("Alpha Cut", Range(0,1)) = 0.5

		[HideInInspector]_SkinTex("Skin (RGB)", 2D) = "black" {}
		[HideInInspector]_SkinCut("Skin Cut", Range(0,1)) = 0.1

        [HideInInspector]_HairUV("Hair UV", Vector) = (0, 0, 0, 0)
        [HideInInspector]_HairColor("Hair Color", Color) = (1, 1, 1, 1)
        
        [HideInInspector]_AtlasUV("UV in Atlas", Vector) = (0, 0, 1, 1)
        
        [HideInInspector]_AlphaGridTex("Alpha Grid", 2D) = "white" {}
        
        [HideInInspector][Enum(UnityEngine.Rendering.BlendMode)] _SrcBlend ("Src Blend", Int) = 1
        [HideInInspector][Enum(UnityEngine.Rendering.BlendMode)] _DstBlend ("Dst Blend", Int) = 0

        [HideInInspector]_OutlineColor("Outline Color", Color) = (0.2, 0.2, 0.2, 1.0)
        [HideInInspector]_Outline("Outline Width", Float) = 1

		[Header(Creep Settings)]
		_CreepTex ("Creep", 2D) = "white" {}
		_CreepColor ("Creep Color", Color) = (1.0,1.0,1.0,1.0)
        _NoiseTex ("Noise Texture", 2D) = "white" {}
        _Offset ("Offset", Range(-5, 5)) = 0.1367521
        _Amplitude ("Amplitude", Range(0, 1)) = 0.1538462
        _TimeSpeed ("Time Speed", Range(0, 2)) = 0.7350427
    }

     SubShader
    {
        LOD 200
        
        UsePass "ME/Creep/LitA/BASE"
        UsePass "ME/Toon/Outline V3/CREEP_OUTLINE"
		UsePass "Hidden/Toon/SHADOWCASTER"
    }
    CustomEditor "METoonShaderEditor"
}
