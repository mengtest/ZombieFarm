// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// 支持穿透卡通shader(屏幕)

Shader "ME/Toon/LitD"
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
		_Radius("Radius", Range(0.01, 1)) = 1
    }

    SubShader
    {
        Tags{ "RenderType"="Opaque" }
        LOD 200

        Pass {
            Name "BASE"

            Tags{ "LightMode"="ForwardBase" }

            //Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
			#pragma skip_variants DYNAMICLIGHTMAP_ON LIGHTMAP_ON LIGHTMAP_SHADOW_MIXING LIGHTPROBE_SH SHADOWS_SHADOWMASK VERTEXLIGHT_ON
            #pragma multi_compile __ SET_GRAYSCALE
            #pragma multi_compile __ TOON_RAMP_TEX
            #pragma multi_compile __ BLEND_SKIN_TEX
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

            struct v2f
            {
                half4 pos : POSITION;
                half2 uv : TEXCOORD0;
                fixed3 worldNormal : TEXCOORD1;
                fixed3 lightDir : TEXCOORD2;
                fixed3 viewDir : TEXCOORD3;

                // 声明_LightCoord和_ShadowCoord
                LIGHTING_COORDS(4, 5)
				half4 screenPos : TEXCOORD6;
				half3 worldPos : TEXCOORD7;
            };

            v2f vert(toon_a2v v)
            {
                //toon_v2f to = toon_vert(v);
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.worldNormal = normalize(mul(SCALED_NORMAL, (half3x3)unity_WorldToObject));
                o.lightDir = normalize(mul((half3x3)unity_ObjectToWorld, ObjSpaceLightDir(v.vertex)));
                o.viewDir = normalize(mul((half3x3)unity_ObjectToWorld, ObjSpaceViewDir(v.vertex)));
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);

//                o.pos = to.pos;
//                o.uv = to.uv;
//                o.worldNormal = to.worldNormal;
//                o.lightDir = to.lightDir;
//                o.viewDir = to.viewDir;
//                o.worldPos = to.worldPos;

				o.screenPos = ComputeScreenPos(o.pos);
				//o.screenUv = screenPos / screenPos.w;

                // 计算_LightCoord和_ShadowCoord
                TRANSFER_VERTEX_TO_FRAGMENT(o);
                return o;
            }

            fixed4 _Color;
			half _Radius;
			sampler3D _DitherMaskLOD;
			half4 PlayerScreenPos;

            fixed4 frag(v2f IN) : COLOR
            {
                if (PlayerScreenPos.z > IN.screenPos.z) {
//                    half d = distance(PlayerScreenPos.xy, IN.screenPos.xy);
//                    half vfactor = d < 300 ? 0 : 1;
                    IN.screenPos /= IN.screenPos.w;
                    half2 d = abs(IN.screenPos.xy - half2(0.5, 0.5)) / _Radius;
                    d.x *= _ScreenParams.x / _ScreenParams.y;
                    d = saturate(d);
                    half vfactor = 1 - pow(saturate(1.0 - dot(d, d)), 0.3);
                    //clip(vfactor - 0.001);
                    half alphaRef = tex3D(_DitherMaskLOD, float3(IN.pos.xy*0.25, vfactor *0.9375)).a;
				    clip(alphaRef - 0.01);
				}
				fixed4 main = ToonSkin(IN.uv, IN.uv, IN.worldPos, _Color);

                return RampSmoothLight(main, IN.worldNormal, IN.lightDir, LIGHT_ATTENUATION(IN));
            }
            ENDCG
        }

		UsePass "Hidden/Toon/SHADOWCASTER"
		/*
		Pass
		{
			Name "SHADOWCASTER"
			Tags { "LightMode" = "ShadowCaster" }

			Fog {Mode Off}
			ZWrite On ZTest Less Cull Off
			Offset 1, 1

			CGPROGRAM
			#pragma multi_compile __ NO_ALPHA_CLIP
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_shadowcaster
			#pragma fragmentoption ARB_precision_hint_fastest
			#include "UnityCG.cginc"

            sampler2D _AlphaTex;
            fixed _Cutoff;

			struct v2f {
				V2F_SHADOW_CASTER;
				half2 uv : TEXCOORD2;
				half4 screenUv : TEXCOORD3;
			};

			v2f vert(appdata_base v)
			{
				v2f o;
				o.uv = v.texcoord;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET(o);

				half4 pos = UnityObjectToClipPos(v.vertex);
				half4 screenPos = ComputeScreenPos(pos);
				o.screenUv = screenPos / screenPos.w;

				return o;
			}

			half _Radius;
			sampler3D _DitherMaskLOD;

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
				half2 d = abs(i.screenUv.xy - half2(0.5, 0.5)) / _Radius;
				d.x *= _ScreenParams.x / _ScreenParams.y;
				d = saturate(d);
				half vfactor = 1 - pow(saturate(1.0 - dot(d, d)), 0.5);

				half alphaRef = tex3D(_DitherMaskLOD, float3(i.pos.xy*0.25, vfactor * 0.9375)).a;
				clip(alphaRef - 0.01);

				return fragShadow(i);
			}

			ENDCG
		}
		*/
    }

    //Fallback "Diffuse"
}
