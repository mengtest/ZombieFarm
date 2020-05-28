// Upgrade NOTE: commented out 'float3 _WorldSpaceCameraPos', a built-in variable

Shader "Custom/372"
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
		Blend SrcAlpha OneMinusSrcAlpha

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
				u_xlat0.xy = u_xlat0.xz * _CloudShadowTex_ST.xy + (-u_xlat4.xz);
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


				u_xlat16_0.xy = i.vs_TEXCOORD1.xy / i.vs_TEXCOORD1.ww;
				u_xlat10_1.xy = 1;
				u_xlat13.x = u_xlat10_1.x + -0.00999999978;


				u_xlatb13 = u_xlat13.x<0.0;

				if((int(u_xlatb13) * int(0xffffffffu))!=0){discard;}
				u_xlat10_13.xy = tex2D(_DistortionMap, i.vs_TEXCOORD2.xy).xy;

				//return tex2D(_DistortionMap, i.vs_TEXCOORD2.xy);

				u_xlat16_0 = u_xlat10_13.xyxy * float4(2.0, 2.0, 2.0, 2.0) + float4(-1.0, -1.0, -1.0, -1.0);
				u_xlat16_0 = u_xlat16_0 * float4(_DistortionPower, _DistortionPower, _DistortionPower, _DistortionPower);
				u_xlat16_13.xy = u_xlat16_0.zw * float2(20.0, 20.0) + i.vs_COLOR0.ww;
				u_xlat13.xy = (-_Time.yy) * 0.2 + u_xlat16_13.xy;
				u_xlat2.xy = u_xlat13.xy + float2(0.5, 0.5);
				u_xlat10_13.x = tex2D(_FoamTex2, u_xlat13.xy).x;

				//return tex2D(_FoamTex2, u_xlat13.xy);

				u_xlat10_19 = tex2D(_FoamTex2, u_xlat2.xy).x;

				//return tex2D(_FoamTex2, u_xlat2.xy);

				u_xlat2.xy = u_xlat16_0.xy * float2(0.5, 0.5) + i.vs_TEXCOORD0.xy;
				u_xlat16_14.xy = float2(u_xlat16_0.z * float(20.0), u_xlat16_0.w * float(20.0));
				u_xlat10_2 = tex2D(_MainTex, u_xlat2.xy).x;

				//return tex2D(_MainTex, u_xlat2.xy);


				u_xlat16_3.x = (-u_xlat10_2) * 1.5 + 1.0;
				u_xlat16_2 = u_xlat10_2 * 1.5;
				u_xlat16_19 = u_xlat10_19 * u_xlat16_3.x;
				u_xlat16_13.x = u_xlat10_13.x * u_xlat16_2 + u_xlat16_19;
				u_xlat16_19 = i.vs_COLOR0.w - 0.200000003;
				u_xlat16_19 = u_xlat16_19 * 0.769230783;
				u_xlat16_19 = clamp(u_xlat16_19, 0.0, 1.0);
				u_xlat16_2 = u_xlat16_19 * u_xlat16_19;
				u_xlat16_19 = (-u_xlat16_19) * 2.0 + 3.0;
				u_xlat2.xy = float2(u_xlat16_2,u_xlat16_2) * float2(u_xlat16_19,u_xlat16_19) + u_xlat16_14.xy;
				u_xlat10_19 = tex2D(_FoamTex, u_xlat2.xy  * _FoamTex_ST.xy + _FoamTex_ST.zw).z;

				//return tex2D(_FoamTex, u_xlat2.xy  * _FoamTex_ST.xy + _FoamTex_ST.zw);

				u_xlat16_3.x = (-u_xlat10_19) + 1.0;
				u_xlat16_3.x = u_xlat16_13.x + u_xlat16_3.x;
				u_xlat16_3.x = u_xlat16_3.x * i.vs_COLOR0.w;

				//return float4(u_xlat16_3.x,u_xlat16_3.x,u_xlat16_3.x,1);

				u_xlat16_21 = dot(i.vs_TEXCOORD4.xyz, i.vs_TEXCOORD4.xyz);
				u_xlat16_21 = 1/sqrt(u_xlat16_21);
				u_xlat16_21 = u_xlat16_21 * i.vs_TEXCOORD4.y;
				u_xlat16_4.x = dot(i.vs_TEXCOORD3.xyz, i.vs_TEXCOORD3.xyz);
				u_xlat16_4.x = 1/sqrt(u_xlat16_4.x);
				u_xlat16_4.xyz = u_xlat16_4.xxx * i.vs_TEXCOORD3.xyz;
				u_xlat16_21 = dot(u_xlat16_4.xyz, float3(u_xlat16_21,u_xlat16_21,u_xlat16_21));
				u_xlat16_21 = max(u_xlat16_21, 0.0);
				u_xlat16_3.w = log2(u_xlat16_21);
				u_xlat16_3 = u_xlat16_3.xxxw * float4(0.479999989, 0.529999971, 0.200000003, 15.0);
				u_xlat16_21 = exp2(u_xlat16_3.w);
				u_xlat16_4.x = (-u_xlat16_21) + 1.0;
				u_xlat16_3.xyz = u_xlat16_3.xyz * u_xlat16_4.xxx;
				u_xlat16_3.xyz = u_xlat16_3.xyz * float3(0.5, 0.5, 0.5);


				//return float4(u_xlat16_3.xyz,1);

				u_xlat16_4.xyz = u_xlat10_1.yyy * float3(0.0199999809, -0.179999977, -0.300000012) + float3(0.400000006, 0.8, 0.8);
				u_xlat10_7 = tex2D(_LightMapDynamic, i.vs_TEXCOORD0.zw).z;
				u_xlat16_7 = (-u_xlat10_7) + 1.0;
				u_xlat16_5.xyz = i.vs_COLOR0.xyz * float3(u_xlat16_7,u_xlat16_7,u_xlat16_7) + _FogColor.xyz;
				u_xlat16_3.xyz = u_xlat16_4.xyz * u_xlat16_5.xyz + u_xlat16_3.xyz;
				u_xlat10_7 = tex2D(_CloudShadowTex, i.vs_TEXCOORD5.xy).x;
				u_xlat16_7 = (-u_xlat10_7) + 1.0;
				u_xlat16_7 = u_xlat16_7 * 0.1;
				u_xlat16_4.xyz = float3(u_xlat16_21,u_xlat16_21,u_xlat16_21) * float3(0.699999988, 0.699999988, 0.349999994) + (-float3(u_xlat16_7,u_xlat16_7,u_xlat16_7));

				//return float4(u_xlat16_3.xyz,1);
				//return float4(u_xlat16_4.xyz,1);

				u_xlat16_3.xyz = saturate(u_xlat16_3.xyz) + saturate(u_xlat16_4.xyz);
				//return float4(u_xlat16_3.xyz,1);
				//u_xlat16_3.xyz = u_xlat16_3.xyz + (_FogColor.xyz);
				u_xlat16_21 = i.vs_COLOR1;
				u_xlat16_21 = clamp(u_xlat16_21, 0.0, 1.0);

				SV_Target0.xyz = u_xlat16_3.xyz;
				u_xlat16_3.x = 1-i.vs_COLOR0.w;
				u_xlat16_7 = u_xlat16_3.x * 10.0;
				u_xlat16_7 = saturate(u_xlat16_7);
				u_xlat16_13.x = u_xlat16_7 * u_xlat16_7;
				u_xlat16_7 = (-u_xlat16_7) * 2.0 + 3.0;
				u_xlat16_7 = u_xlat16_7 * u_xlat16_13.x;
				u_xlat16_7 = u_xlat16_7 * u_xlat10_19;
				u_xlat16_1 = u_xlat10_1.x * u_xlat16_7;
				SV_Target0.a = saturate(u_xlat16_7);
				return SV_Target0;
			}
			ENDCG
		}
	}
}
