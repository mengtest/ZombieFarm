// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// MatCap Shader, (c) 2015 Jean Moreno

Shader "Hidden/Toon"
{
	Properties
	{
		_Color("Color", Color) = (1.0,1.0,1.0,1.0)
        _MatCap("MatCap (RGB)", 2D) = "black" {}
        _MColor("Matcap Color", Color) = (1.0,1.0,1.0,1.0)
		_AlphaTex("Alpha (A)", 2D) = "white" {}
        _Cutoff("Alpha Cut", Range(0,1)) = 0.5
	}

	Subshader
	{
		PASS {
			Name "GHOST"
			Tags{ "Queue" = "Geometry+100" "IgnoreProjector" = "True" }
			//Cull Off
			Lighting Off
			ZWrite Off
			ZTest Greater
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			#pragma skip_variants DYNAMICLIGHTMAP_ON LIGHTMAP_ON LIGHTMAP_SHADOW_MIXING LIGHTPROBE_SH DIRECTIONAL SHADOWS_SCREEN SHADOWS_SHADOWMASK VERTEXLIGHT_ON
			#pragma vertex vert
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest

			#include "UnityCG.cginc"

			struct v2f
			{
                half4 pos : SV_POSITION;
                half2 cap : TEXCOORD0;
			};

			v2f vert(appdata_base v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);

                fixed3 worldNorm = normalize(unity_WorldToObject[0].xyz * v.normal.x + unity_WorldToObject[1].xyz * v.normal.y + unity_WorldToObject[2].xyz * v.normal.z);
				worldNorm = mul((fixed3x3)UNITY_MATRIX_V, worldNorm);
				o.cap.xy = worldNorm.xy * 0.5 + 0.5;

				return o;
			}

            uniform fixed4 _Color;
			uniform fixed4 _MColor;
			uniform sampler2D _MatCap;

            fixed4 frag(v2f i) : COLOR
			{
                fixed4 mc = tex2D(_MatCap, i.cap);

				fixed4 col = _MColor * mc * 2.0;
				col.a *= _Color.a;
				return col;
			}
			ENDCG
		}

		// 该Pass仅绘制深度，在半透明时滤掉内部模型
		Pass
		{
			Name "Z ONLY"

			Tags{ "RenderType"="Transparent" "Queue"="Transparent" }
			ColorMask 0

			CGPROGRAM
			#pragma skip_variants DYNAMICLIGHTMAP_ON LIGHTMAP_ON LIGHTMAP_SHADOW_MIXING LIGHTPROBE_SH DIRECTIONAL SHADOWS_SCREEN SHADOWS_SHADOWMASK VERTEXLIGHT_ON
			#pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase
            #pragma fragmentoption ARB_precision_hint_fastest
            #pragma glsl
            #pragma target 2.0

            sampler2D _MainTex;
            fixed _Cutoff;

            struct a2v
            {
                half4 vertex : POSITION;
                half2 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                half4 pos : POSITION;
				half2 uv : TEXCOORD0;
            };

            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = v.texcoord;

                return o;
            }

            fixed4 frag(v2f IN) : COLOR
            {
                fixed4 main = tex2D(_MainTex, IN.uv);
                clip(main.a - _Cutoff);

                return 0;
            }
            ENDCG
		}

		Pass
		{
			Name "SHADOWCASTER"
			Tags { "LightMode" = "ShadowCaster"}

			Fog {Mode Off}
			ZWrite On ZTest Less Cull Off
			Offset 1, 1

			CGPROGRAM
			#pragma skip_variants SHADOWS_DEPTH SHADOWS_CUBE
			#pragma multi_compile __ TOON_TRANSPARENT
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_shadowcaster
			#pragma multi_compile_instancing
			#pragma fragmentoption ARB_precision_hint_fastest
			#include "UnityCG.cginc"

			sampler2D _MainTex;
            fixed _Cutoff;

            sampler3D _DitherMaskLOD;

			struct v2f {
				V2F_SHADOW_CASTER;
				half2 uv:TEXCOORD2;
			};

			v2f vert(appdata_base v)
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);

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
                fixed4 main = tex2D(_MainTex, i.uv);
                clip(main.a - _Cutoff);

                half alphaRef = tex3D(_DitherMaskLOD, float3(i.pos.xy*0.25, _Color.a*0.9375)).a;
				clip(alphaRef - 0.01);

				return fragShadow(i);
			}

			ENDCG
		}

		Pass
		{
			Name "MESH SHADOW"
			Tags{ "RenderType"="Transparent" "Queue"="Transparent" }

			Stencil
			{
				Ref 1
				Comp NotEqual
				Pass Replace
				ReadMask 1
				WriteMask 1
			}
			Blend SrcAlpha OneMinusSrcAlpha
			ZWrite OFF

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"
			//#include "Lighting.cginc"
            //#include "AutoLight.cginc"

			struct appdata
			{
				half4 vertex : POSITION;
			};

			struct v2f
			{
				half4 vertex : SV_POSITION;
			};

			half _ShadowAlpha;
			half _GroundY;

			v2f vert (appdata v)
			{
				v2f o;

				half4 worldPos = mul(unity_ObjectToWorld, v.vertex);
				fixed3 lightDir = normalize(mul((half3x3)unity_ObjectToWorld, ObjSpaceLightDir(v.vertex)));
				half d = (_GroundY - worldPos.y) / lightDir.y;
				worldPos.xyz += d * lightDir;
				o.vertex = mul(UNITY_MATRIX_VP, worldPos);
				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				return fixed4(0, 0, 0, _ShadowAlpha);
			}
			ENDCG
		}
	}

	//Fallback "VertexLit"
}