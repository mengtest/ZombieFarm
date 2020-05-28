Shader "ME/Spec/LitA"
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

		[HideInInspector]_SpecTex("Spec Texture", 2D) = "white" {}
		[HideInInspector]_Specular("Specular", Range(0, 10)) = 1
        [HideInInspector]_Shininess("Shininess", Range(0.01, 1)) = 0.5

        [HideInInspector]_AlphaGridTex ("Alpha Grid", 2D) = "white" {}

        [HideInInspector][Enum(UnityEngine.Rendering.BlendMode)] _SrcBlend ("Src Blend", Int) = 1
        [HideInInspector][Enum(UnityEngine.Rendering.BlendMode)] _DstBlend ("Dst Blend", Int) = 0
    }

    SubShader
    {
        Tags{ "RenderType"="Opaque" }
        LOD 200

        Pass {
            Name "BASE"

            Tags{ "LightMode"="ForwardBase" }
            Blend [_SrcBlend] [_DstBlend]

            CGPROGRAM
			#pragma skip_variants DYNAMICLIGHTMAP_ON LIGHTMAP_ON LIGHTMAP_SHADOW_MIXING LIGHTPROBE_SH SHADOWS_SHADOWMASK VERTEXLIGHT_ON
            //#pragma multi_compile __ SET_GRAYSCALE
            #pragma multi_compile __ TOON_TRANSPARENT
			#pragma multi_compile __ TOON_RAMP_TEX
            //#pragma multi_compile __ BLEND_SKIN_TEX
            #pragma multi_compile __ TOON_SIMULATE_POINTLIT
            #pragma vertex toon_vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase
            #pragma fragmentoption ARB_precision_hint_fastest
            #pragma glsl
            #pragma target 2.0

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"
            #include "ME_Include.cginc"

			fixed4 _Color;
			fixed _Specular;
            fixed _Shininess;
			sampler2D _SpecTex;

            fixed4 frag(toon_v2f IN) : COLOR
            {
				fixed4 main = toon_frag(IN, _Color);

                fixed4 c = RampSmoothLight(main, IN.worldNormal, IN.lightDir, LIGHT_ATTENUATION(IN));

				fixed nh = saturate(dot(IN.worldNormal, normalize(IN.viewDir + IN.lightDir)));
				fixed4 spec = tex2D(_SpecTex, IN.uv);
				c.rgb += (spec * pow(nh, _Shininess * 128) * _Specular);
				c.a = _Color.a;

				return c;
            }
            ENDCG
        }

		UsePass "Hidden/Toon/SHADOWCASTER"
    }

    //Fallback "Diffuse"
    CustomEditor "METoonShaderEditor"
}
