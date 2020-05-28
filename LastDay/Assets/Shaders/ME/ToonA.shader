
Shader "ME/Toon/UnlitA" {
	Properties {
        [HideInInspector]_Color("Color", Color) = (1.0,1.0,1.0,1.0)
        [HideInInspector]_MainTex("Main (RGBA)", 2D) = "white" {}
        [HideInInspector]_Cutoff("Alpha Cut", Range(0,1)) = 0.5

		[HideInInspector]_SkinTex("Skin (RGB)", 2D) = "black" {}
		[HideInInspector]_SkinCut("Skin Cut", Range(0,1)) = 0.1

        [HideInInspector]_HairUV("Hair UV", Vector) = (0, 0, 0, 0)
        [HideInInspector]_HairColor("Hair Color", Color) = (1, 1, 1, 1)

        [HideInInspector]_AtlasUV("UV in Atlas", Vector) = (0, 0, 1, 1)

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

		Pass {
			Name "BASE"
            LOD 200

			Tags{ "LightMode"="ForwardBase" }
			Blend [_SrcBlend] [_DstBlend]
            Lighting off
            
            Stencil {
                Ref [_StencilRef]
                Comp [_StencilComp]
                Pass [_StencilPassOp]
                ZFail [_StencilZFailOp]
            }

            CGPROGRAM
            //#pragma multi_compile __ SET_GRAYSCALE
            #pragma multi_compile __ TOON_TRANSPARENT
            #pragma multi_compile __ BLEND_SKIN_TEX
            #pragma multi_compile __ ADD_HAIR_COLOR
            #pragma multi_compile __ TOON_SIMULATE_POINTLIT
            #pragma vertex toon_unlit_vert
            #pragma fragment frag
            #pragma multi_compile_instancing
            #pragma fragmentoption ARB_precision_hint_fastest
            #pragma glsl
            #pragma target 2.0

            #include "UnityCG.cginc"
			#include "ME_Toon.cginc"

            fixed4 _Color;

            fixed4 frag(toon_unlit_v2f IN) : COLOR
            {
				fixed4 main = toon_unlit_frag(IN, _Color);
				main.rgb *= IN.vlight;
				main.a = _Color.a;
                return main;
            }
            ENDCG
        }
		UsePass "Hidden/Toon/SHADOWCASTER"
	}
	//FallBack "Diffuse"
	CustomEditor "METoonShaderEditor"
}
