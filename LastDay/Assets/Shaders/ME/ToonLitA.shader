
Shader "ME/Toon/LitA"
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

        [HideInInspector]_HairUV("Hair UV", Vector) = (0, 0, 0, 0)
        [HideInInspector]_HairColor("Hair Color", Color) = (1, 1, 1, 1)
        [HideInInspector]_HairSpecular("Hair Specular", Range(0, 10)) = 1
        [HideInInspector]_HairShininess("Hair Shininess", Range(0.01, 1)) = 0.5

        [HideInInspector]_AtlasUV("UV in Atlas", Vector) = (0, 0, 1, 1)

        [HideInInspector]_AlphaGridTex ("Alpha Grid", 2D) = "white" {}

        [HideInInspector][Enum(UnityEngine.Rendering.BlendMode)] _SrcBlend ("Src Blend", Int) = 1
        [HideInInspector][Enum(UnityEngine.Rendering.BlendMode)] _DstBlend ("Dst Blend", Int) = 0


        _StencilRef ("Stencil Ref", Int) = 0
        [Enum(UnityEngine.Rendering.CompareFunction)] _StencilComp ("Stencil Comp", Int) = 0
        [Enum(UnityEngine.Rendering.StencilOp)] _StencilPassOp ("Stencil Pass Op", Int) = 0
        [Enum(UnityEngine.Rendering.StencilOp)] _StencilZFailOp ("Stencil ZFail Op", Int) = 0
    }

    SubShader
    {
        Tags{ "RenderType"="Opaque" }
        LOD 200

        Pass {
            Name "BASE"

            Tags{ "LightMode"="ForwardBase" }
            Blend [_SrcBlend] [_DstBlend]

            Stencil {
                Ref [_StencilRef]
                Comp [_StencilComp]
                Pass [_StencilPassOp]
                ZFail [_StencilZFailOp]
            }

            CGPROGRAM
			#pragma skip_variants DYNAMICLIGHTMAP_ON LIGHTMAP_ON LIGHTMAP_SHADOW_MIXING LIGHTPROBE_SH SHADOWS_SHADOWMASK VERTEXLIGHT_ON
            //#pragma multi_compile __ SET_GRAYSCALE
            #pragma multi_compile __ TOON_TRANSPARENT
			#pragma multi_compile __ TOON_RAMP_TEX
            #pragma multi_compile __ BLEND_SKIN_TEX
            #pragma multi_compile __ ADD_HAIR_COLOR
            #pragma multi_compile __ TOON_SIMULATE_POINTLIT
            #pragma vertex toon_vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase
            #pragma multi_compile_instancing
            #pragma fragmentoption ARB_precision_hint_fastest
            #pragma glsl
            #pragma target 2.0

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"
            #include "ME_Include.cginc"

			fixed4 _Color;

            fixed4 frag(toon_v2f IN) : COLOR
            {
                fixed4 main = toon_frag(IN, _Color);
                main.a *= _Color.a;

                return RampSmoothLight(main, IN.worldNormal, IN.lightDir, LIGHT_ATTENUATION(IN));
            }
            ENDCG
        }

		UsePass "Hidden/Toon/SHADOWCASTER"
    }

    //Fallback "Diffuse"
    CustomEditor "METoonShaderEditor"
}
