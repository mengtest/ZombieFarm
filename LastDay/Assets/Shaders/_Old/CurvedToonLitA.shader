Shader "ME/CurvedToon/LitA"
{
    Properties
    {
        [Header(Light Settings)]
        _Color("Color", Color) = (0.6,0.6,0.6,1.0)
        _HColor("Highlight Color", Color) = (1.0,1.0,1.0,1.0)
        _SColor("Shadow Color", Color) = (0.2,0.2,0.2,1.0)

		[Toggle(TOON_RAMP_TEX)] _RampTex("Ramp Texture?", Float) = 0
		_Ramp("Ramp Tex", 2D) = "gray" {}
        _RampThreshold("Ramp Threshold", Range(0,1)) = 0.5
        _RampSmooth("Ramp Smoothing", Range(0.01,1)) = 0.1

        [Header(Texture Settings)]
        _MainTex("Main Texture (RGB)", 2D) = "white" {}
        [Toggle(SET_GRAYSCALE)] _Grayscale("Grayscale?", Float) = 0
        _AlphaTex("Alpha (A)", 2D) = "white" {}
        _Cutoff("Alpha Cut", Range(0,1)) = 0.5
		_SkinTex("Skin (RGB)", 2D) = "black" {}
		_SkinCut("Skin Cut", Range(0,1)) = 0.1
		
		_AtlasUV("UV in Atlas", Vector) = (0, 0, 1, 1)
    }

    SubShader
    {
        Tags{ "RenderType"="Opaque" }
        LOD 200

        Pass {
            Name "BASE"

            Tags{ "LightMode"="ForwardBase" }

            CGPROGRAM
			#pragma skip_variants DYNAMICLIGHTMAP_ON LIGHTMAP_ON LIGHTMAP_SHADOW_MIXING LIGHTPROBE_SH SHADOWS_SHADOWMASK VERTEXLIGHT_ON
            #pragma multi_compile __ SET_GRAYSCALE
			#pragma multi_compile __ TOON_RAMP_TEX
			//#pragma multi_compile __ BLEND_SKIN_TEX
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase
            #pragma fragmentoption ARB_precision_hint_fastest
            #pragma glsl
            #pragma target 2.0

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"
            #include "ME_Include.cginc"
			#include "../../VacuumShaders/Curved World/Shaders/cginc/CurvedWorld_Base.cginc"

			fixed4 _Color;

			toon_v2f vert(toon_a2v v)
			{
				//CurvedWorld vertex transform
				V_CW_TransformPoint(v.vertex);

				return toon_vert(v);
			}

            fixed4 frag(toon_v2f IN) : COLOR
            {
				fixed4 main = toon_frag(IN, _Color);
                main.a = _Color.a;
				
                return RampSmoothLight(main, IN.worldNormal, IN.lightDir, LIGHT_ATTENUATION(IN));
            }
            ENDCG
        }

		Pass
		{
			Name "SHADOWCASTER"
			Tags { "LightMode" = "ShadowCaster" }

			Fog {Mode Off}
			ZWrite On ZTest Less Cull Off
			Offset 1, 1

			CGPROGRAM
			#pragma skip_variants SHADOWS_DEPTH SHADOWS_CUBE
			#pragma multi_compile __ NO_ALPHA_CLIP
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_shadowcaster
			#pragma fragmentoption ARB_precision_hint_fastest
			#include "UnityCG.cginc"
			#include "../../VacuumShaders/Curved World/Shaders/cginc/CurvedWorld_Base.cginc"

            sampler2D _AlphaTex;
            fixed _Cutoff;

			struct v2f {
				V2F_SHADOW_CASTER;
				half2 uv:TEXCOORD2;
			};

			v2f vert(appdata_base v)
			{
				V_CW_TransformPoint(v.vertex);

				v2f o;
				o.uv = v.texcoord;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET(o);
				return o;
			}

			uniform fixed4 _Color;

			inline half4 fragShadow(v2f i)
			{
				SHADOW_CASTER_FRAGMENT(i);
			}

			half4 frag(v2f i) : SV_Target
			{
#ifndef NO_ALPHA_CLIP
                fixed4 alpha = tex2D(_AlphaTex, i.uv);
                clip(alpha.r - _Cutoff);
#endif
				return fragShadow(i);
			}

			ENDCG
		}
    }

    //Fallback "Diffuse"
}
