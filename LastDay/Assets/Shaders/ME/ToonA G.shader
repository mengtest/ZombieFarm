Shader "ME/Toon/UnlitA G" {
	Properties {
        [HideInInspector]_Color("Color", Color) = (1.0,1.0,1.0,1.0)

        [HideInInspector]_MainTex("Main (RGBA)", 2D) = "white" {}

        [HideInInspector]_AlphaTex("Alpha (RGB)", 2D) = "white" {}
        [HideInInspector]_Cutoff("Alpha Cut", Range(0,1)) = 0.5

		[HideInInspector]_SkinTex("Skin (RGB)", 2D) = "black" {}
		[HideInInspector]_SkinCut("Skin Cut", Range(0,1)) = 0.1

        [HideInInspector]_HairUV("Hair UV", Vector) = (0, 0, 0, 0)
        [HideInInspector]_HairColor("Hair Color", Color) = (1, 1, 1, 1)

        [HideInInspector]_AtlasUV("UV in Atlas", Vector) = (0, 0, 1, 1)

        [HideInInspector]_MatCap("MatCap (RGB)", 2D) = "black" {}
        [HideInInspector]_MColor("Matcap Color", Color) = (1.0,1.0,1.0,1.0)

        [HideInInspector]_AlphaGridTex("Alpha Grid", 2D) = "white" {}
        [HideInInspector][Enum(UnityEngine.Rendering.BlendMode)] _SrcBlend ("Src Blend", Int) = 1
        [HideInInspector][Enum(UnityEngine.Rendering.BlendMode)] _DstBlend ("Dst Blend", Int) = 0
        
        _StencilRef ("Stencil Ref", Int) = 0
        [Enum(UnityEngine.Rendering.CompareFunction)] _StencilComp ("Stencil Comp", Int) = 0
        [Enum(UnityEngine.Rendering.StencilOp)] _StencilPassOp ("Stencil Pass Op", Int) = 0
        [Enum(UnityEngine.Rendering.StencilOp)] _StencilZFailOp ("Stencil ZFail Op", Int) = 0
	}

    SubShader {
		Tags{ "RenderType"="Opaque" }
		LOD 200

		UsePass "Hidden/Toon/GHOST"
        UsePass "ME/Toon/UnlitA/BASE"
		UsePass "Hidden/Toon/SHADOWCASTER"
    }

    //Fallback "Diffuse"
    CustomEditor "METoonShaderEditor"
}
