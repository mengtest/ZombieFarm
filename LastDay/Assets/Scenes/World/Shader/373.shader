// Upgrade NOTE: commented out 'float3 _WorldSpaceCameraPos', a built-in variable

Shader "Custom/373"
{
	Properties
	{
        _GlobalMapMask ("GlobalMapMask", 2D) = "white" {}
        _DistortionMap ("DistortionMap", 2D) = "white" {}
        _LightMapDynamic ("LightMapDynamic", 2D) = "white" {}
        _MainTex ("MainTex", 2D) = "white" {}
        _FoamTex2 ("FoamTex2", 2D) = "white" {}
        _FoamTex ("FoamTex", 2D) = "white" {}
        _CloudShadowTex ("CloudShadowTex", 2D) = "white" {}
		_DistortionPower ("DistortionPower", float) = 1
	}
	SubShader
	{
		Tags { "RenderType"="Transparent" "RenderQueue"="Transparent"}
		LOD 100
		Blend  SrcAlpha OneMinusSrcAlpha

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 in_POSITION0 : POSITION;
                float4 in_COLOR0 : TEXCOORD0;
                float4 in_NORMAL0 : NORMAL;
			};

			struct v2f
			{
			    float4 vs_POSITION : SV_POSITION;
				float4 vs_TEXCOORD0 : TEXCOORD0;
                float4 vs_TEXCOORD1 : TEXCOORD1;
                float4 vs_TEXCOORD2 : TEXCOORD2;
                float4 vs_TEXCOORD3 : TEXCOORD3;
                float4 vs_TEXCOORD4 : TEXCOORD4;
                float4 vs_TEXCOORD5 : TEXCOORD5;
                float4 vs_COLOR0 : COLOR0;
                float  vs_COLOR1 : COLOR1;
                float2 vs_TEXCOORD6 : TEXCOORD6;
			};

			// float3 _WorldSpaceCameraPos;
			float4 _ObjectToWorld[4];
			float4 _WorldToObject[4];
			float4 _MatrixVP[4];
			float4 _shadowMatrix[4];
			float3 _SunLightData;
			float3 _SunLightColor;
			float _FogParamZ;
			float _FogParamW;
			float4 _MainTex_ST;
			float4 _DistortionMap_ST;
			float4 _FoamTex_ST;
			float4 _GlobalMapFogMatrix[4];
			 float4 _CloudShadowTex_ST;
			 float4 _FogColor;
			 float _DistortionPower = 10;
			 sampler2D _GlobalMapMask;
			 sampler2D _DistortionMap;
			 sampler2D _LightMapDynamic;
			 sampler2D _MainTex;
			 sampler2D _FoamTex2;
			 sampler2D _FoamTex;
			 sampler2D _CloudShadowTex;
			
			v2f vert (appdata v)
			{
				float4 u_xlat0;
				float4 u_xlat1;
				float2 u_xlat2;
				float u_xlat16_3;
				float3 u_xlat4;
				float u_xlat12;

				v2f o;
				u_xlat0 = mul(unity_ObjectToWorld, v.in_POSITION0);
                u_xlat1 = UnityObjectToClipPos(v.in_POSITION0);
				o.vs_POSITION = u_xlat1;
				o.vs_COLOR1 = u_xlat1.z * _FogParamZ + _FogParamW;
				u_xlat1.xy = u_xlat0.yy * _shadowMatrix[1].xy;
				u_xlat1.xy = _shadowMatrix[0].xy * u_xlat0.xx + u_xlat1.xy;
				u_xlat1.xy = _shadowMatrix[2].xy * u_xlat0.zz + u_xlat1.xy;
				u_xlat1.zw = _shadowMatrix[3].xy * u_xlat0.ww + u_xlat1.xy;
				u_xlat2.xy = float2(_Time.x * _MainTex_ST.z, _Time.x * _MainTex_ST.w);
				u_xlat2.xy = frac(u_xlat2.xy);
				u_xlat1.xy = u_xlat0.xz * _MainTex_ST.xy + u_xlat2.xy;
				o.vs_TEXCOORD0 = u_xlat1;
				u_xlat1 = u_xlat0.yyyy * _GlobalMapFogMatrix[1];
				u_xlat1 = _GlobalMapFogMatrix[0] * u_xlat0.xxxx + u_xlat1;
				u_xlat1 = _GlobalMapFogMatrix[2] * u_xlat0.zzzz + u_xlat1;
				u_xlat1 = _GlobalMapFogMatrix[3] * u_xlat0.wwww + u_xlat1;
				o.vs_TEXCOORD1 = u_xlat1;
				u_xlat1.xy = float2(_Time.x * _DistortionMap_ST.z, _Time.x * _DistortionMap_ST.w);
				u_xlat1.xy = frac(u_xlat1.xy);
				u_xlat1.xy = u_xlat0.xz * _DistortionMap_ST.xy + u_xlat1.xy;
				o.vs_TEXCOORD2.xy = u_xlat1.xy;
				u_xlat1.x = dot(v.in_NORMAL0.xyz, unity_WorldToObject[0].xyz);
				u_xlat1.y = dot(v.in_NORMAL0.xyz, unity_WorldToObject[1].xyz);
				u_xlat1.z = dot(v.in_NORMAL0.xyz, unity_WorldToObject[2].xyz);
				u_xlat12 = dot(u_xlat1.xyz, u_xlat1.xyz);
				u_xlat12 = 1/sqrt(u_xlat12);
				u_xlat1.xyz = float3(u_xlat12,u_xlat12,u_xlat12) * u_xlat1.xyz;
				o.vs_TEXCOORD3.xyz = u_xlat1.xyz;
				u_xlat16_3 = dot(u_xlat1.xyz, float3(_SunLightData.x, _SunLightData.y, _SunLightData.z));
				u_xlat16_3 = max(u_xlat16_3, 0.0);
				o.vs_COLOR0.xyz = 1;//float3(u_xlat16_3,u_xlat16_3,u_xlat16_3) * _SunLightColor.xyz;
				u_xlat1.xyz = (-u_xlat0.xyz) + _WorldSpaceCameraPos.xyz;
				o.vs_TEXCOORD4.xyz = u_xlat1.xyz;
				o.vs_COLOR0.w = v.in_COLOR0.x;
				u_xlat4.xz = float2(_Time.x * _CloudShadowTex_ST.z, _Time.x * _CloudShadowTex_ST.w);
				u_xlat4.xz = frac(u_xlat4.xz);
				u_xlat0.xy = u_xlat0.xz * _CloudShadowTex_ST.xy + (-u_xlat4.xz) + float2(-0.2, 0.1);
				o.vs_TEXCOORD5.xy = u_xlat0.xy;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				float4 SV_Target0;
				 float4 u_xlat16_0;
				 float u_xlat16_1;
				 float2 u_xlat10_1;
				float2 u_xlat2;
				 float u_xlat16_2;
				 float u_xlat10_2;
				 float4 u_xlat16_3;
				 float3 u_xlat16_4;
				 float3 u_xlat16_5;
				 float u_xlat16_7;
				 float u_xlat10_7;
				float2 u_xlat13;
				 float2 u_xlat16_13;
				 float2 u_xlat10_13;
				bool u_xlatb13;
				 float2 u_xlat16_14;
				 float u_xlat16_19;
				 float u_xlat10_19;
				 float u_xlat16_21;



				u_xlat10_7 = (1-tex2D(_CloudShadowTex, i.vs_TEXCOORD5.xy).x);
				return float4(1.1, 1.1, 1.1, u_xlat10_7);
			}
			ENDCG
		}
	}
}
