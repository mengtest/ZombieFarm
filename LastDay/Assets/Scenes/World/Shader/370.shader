// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Custom/370"
{
	Properties
	{
		_GlobalMapMask ("GlobalMapMask", 2D) = "white" {} 
        _LightMapDynamic ("LightMapDynamic", 2D) = "white" {} 
        _CloudShadowTex ("CloudShadowTex", 2D) = "white" {} 
        _Mask ("Mask", 2D) = "white" {} 
        _MainTex ("MainTex", 2D) = "white" {} 
        _Tex2 ("Tex2", 2D) = "white" {} 
        _Tex3 ("Tex3", 2D) = "white" {} 
        _Tex4 ("Tex4", 2D) = "white" {} 
        _FogParamZ ("FogParamZ", float) = 1
        _FogParamW ("FogParamW", float) = 1
        _FogColor ("FogColor", Color) = (1, 1 ,1, 1)
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
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 in_POSITION0 : POSITION;
                float4 in_COLOR0 : TEXCOORD0;
                float4 in_NORMAL : NORMAL;
			};

			struct v2f
			{
			    float4 vs_POSITION : SV_POSITION;
				float4 vs_TEXCOORD0 : TEXCOORD0;
                float4 vs_TEXCOORD1 : TEXCOORD1;
                float4 vs_TEXCOORD2 : TEXCOORD2;
                float4 vs_TEXCOORD3 : TEXCOORD3;
                float4 vs_COLOR0 : COLOR0;
                float  vs_COLOR1 : COLOR1;
                float2 vs_TEXCOORD6 : TEXCOORD6;
			};

            float4 _MatrixVP[4];
            float4 _shadowMatrix[4];
            float3 _SunLightData;
            float3 _SunLightColor;
            float _FogParamZ;
            float _FogParamW;
            float4 _MainTex_ST;
            float4 _Tex2_ST;
            float4 _Tex3_ST;
            float4 _Tex4_ST;
            float4 _Mask_ST;
            float4 _GlobalMapFogMatrix[4];
            float4 _CloudShadowTex_ST;
            
            float4 _FogColor;
            sampler2D _GlobalMapMask;
            sampler2D _LightMapDynamic;
            sampler2D _CloudShadowTex;
            sampler2D _Mask;
            sampler2D _MainTex;
            sampler2D _Tex2;
            sampler2D _Tex3;
            sampler2D _Tex4;

			
			v2f vert (appdata v)
			{
				v2f o;
				
				float4 u_xlat0;
                float4 u_xlat1;
                float u_xlat16_2;
                float3 u_xlat3;
                    
				u_xlat0 = mul(unity_ObjectToWorld, v.in_POSITION0);
                u_xlat1 = UnityObjectToClipPos(v.in_POSITION0);
                o.vs_POSITION = u_xlat1;
                o.vs_COLOR1 = u_xlat1.z * _FogParamZ + _FogParamW;
                o.vs_TEXCOORD0.xy = u_xlat0.xz * _MainTex_ST.xy + _MainTex_ST.zw;
                o.vs_TEXCOORD0.zw = u_xlat0.xz * _Tex2_ST.xy + _Tex2_ST.zw;
                o.vs_TEXCOORD1.xy = u_xlat0.xz * _Tex3_ST.xy + _Tex3_ST.zw;
                o.vs_TEXCOORD1.zw = u_xlat0.xz * _Tex4_ST.xy + _Tex4_ST.zw;
                u_xlat1.xy = u_xlat0.yy * _shadowMatrix[1].xy;
                u_xlat1.xy = _shadowMatrix[0].xy * u_xlat0.xx + u_xlat1.xy;
                u_xlat1.xy = _shadowMatrix[2].xy * u_xlat0.zz + u_xlat1.xy;
                u_xlat1.xy = _shadowMatrix[3].xy * u_xlat0.ww + u_xlat1.xy;
                o.vs_TEXCOORD2.zw = u_xlat1.xy;
                o.vs_TEXCOORD2.xy = u_xlat0.xz * _Mask_ST.xy + _Mask_ST.zw;
                u_xlat1 = u_xlat0.yyyy * _GlobalMapFogMatrix[1];
                u_xlat1 = _GlobalMapFogMatrix[0] * u_xlat0.xxxx + u_xlat1;
                u_xlat1 = _GlobalMapFogMatrix[2] * u_xlat0.zzzz + u_xlat1;
                u_xlat1 = _GlobalMapFogMatrix[3] * u_xlat0.wwww + u_xlat1;
                o.vs_TEXCOORD3 = u_xlat1;
                o.vs_COLOR0.xyz = 1;
                o.vs_COLOR0.w = v.in_COLOR0.x;
                o.vs_COLOR1 = 0;
                u_xlat3.xz = float2(_Time.x * _CloudShadowTex_ST.z, _Time.x * _CloudShadowTex_ST.w);
                u_xlat3.xz = frac(u_xlat3.xz);
                u_xlat0.xy = u_xlat0.xz * _CloudShadowTex_ST.xy + (-u_xlat3.xz);
                o.vs_TEXCOORD6.xy = u_xlat0.xy;
                
                return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				float3 u_xlat16_0;
                float3 u_xlat16_1;
                float4 u_xlat10_1;
                float u_xlat16_2;
                float u_xlat10_2;
                float3 u_xlat16_3;
                float u_xlat16_5;
                float3 u_xlat10_6;
                float u_xlat9;
                float u_xlat16_9;
                float2 u_xlat10_9;
                bool u_xlatb9;
                float u_xlat16_12;
                float u_xlat16_13;
                float u_xlat10_13;
                fixed4 SV_Target0;
                
                //return i.vs_COLOR1;
                
                u_xlat16_0.xy = i.vs_TEXCOORD3.xy / i.vs_TEXCOORD3.ww;
                u_xlat10_1.xy = tex2D(_GlobalMapMask, i.vs_TEXCOORD0.zw + i.vs_TEXCOORD0.xy).xy;

                //return tex2D(_GlobalMapMask, u_xlat16_0.xy);
                //u_xlat10_1.xy = float2(1, 1);

                u_xlat9 = u_xlat10_1.x + -0.00999999978;
                u_xlatb9 = u_xlat9<0.0;
                if((int(u_xlatb9) * int(0xffffffffu))!=0){discard;}

                //return tex2D(_Mask, i.vs_TEXCOORD2.xy);

                u_xlat10_9.xy = tex2D(_Mask, i.vs_TEXCOORD2.xy).xz;

                //return tex2D(_Mask, i.vs_TEXCOORD2.xy);

                u_xlat16_0.xy = u_xlat10_9.yx + float2(-0.400000006, -0.200000003);
                u_xlat16_9 = (-u_xlat16_0.x) + u_xlat10_9.y;
                u_xlat16_13 = (-u_xlat16_0.x) + u_xlat10_1.y;
                u_xlat16_2 = (-u_xlat16_0.y) + i.vs_COLOR0.w;
                u_xlat16_2 = u_xlat16_2 * 2.5;
                u_xlat16_2 = clamp(u_xlat16_2, 0.0, 1.0);
                u_xlat16_9 = u_xlat16_13 / u_xlat16_9;
                u_xlat16_9 = clamp(u_xlat16_9, 0.0, 1.0);
                u_xlat16_13 = u_xlat16_9 * u_xlat16_9;
                u_xlat16_9 = (-u_xlat16_9) * 2.0 + 3.0;
                u_xlat16_9 = u_xlat16_9 * u_xlat16_13;
                u_xlat16_5 = min(u_xlat10_1.y, u_xlat16_9);

                //return float4(u_xlat16_9, u_xlat16_9, u_xlat16_9, 1);


                SV_Target0.w = 1-i.vs_COLOR0.w;
                u_xlat10_1.xzw = tex2D(_Tex4, i.vs_TEXCOORD1.zw).xyz;
                u_xlat10_6.xyz = tex2D(_Tex2, i.vs_TEXCOORD0.zw).xyz;

                //return tex2D(_Tex4, i.vs_TEXCOORD1.zw);
                //return tex2D(_Tex2, i.vs_TEXCOORD0.zw);

                u_xlat16_0.xyz = u_xlat10_1.xzw + u_xlat10_6.xyz;
                u_xlat16_0.xyz = float3(u_xlat16_5, u_xlat16_5, u_xlat16_5) * u_xlat16_0.xyz + u_xlat10_6.xyz;
                u_xlat10_1.xzw = tex2D(_Tex3, i.vs_TEXCOORD1.xy).xyz;


                u_xlat10_6.xyz = tex2D(_MainTex, i.vs_TEXCOORD0.xy).xyz;

                //return tex2D(_MainTex, i.vs_TEXCOORD0.xy);

                u_xlat16_3.xyz = u_xlat10_1.xzw + (-u_xlat10_6.xyz);
                u_xlat16_3.xyz = float3(u_xlat16_5, u_xlat16_5, u_xlat16_5) * u_xlat16_3.xyz + u_xlat10_6.xyz;
                u_xlat16_1.xyz = u_xlat16_0.xyz + (-u_xlat16_3.xyz);
                u_xlat16_13 = u_xlat16_2 * u_xlat16_2;
                u_xlat16_2 = (-u_xlat16_2) * 2.0 + 3.0;
                u_xlat16_13 = u_xlat16_13 * u_xlat16_2;
                u_xlat16_13 = min(u_xlat16_13, i.vs_COLOR0.w);
                u_xlat16_1.xyz = float3(u_xlat16_13, u_xlat16_13, u_xlat16_13) * u_xlat16_1.xyz + u_xlat16_3.xyz;
                u_xlat10_13 = 1;//tex2D(_LightMapDynamic, i.vs_TEXCOORD2.zw).z;

                //return float4(u_xlat16_1.xyz, 1);

                //return tex2D(_LightMapDynamic, i.vs_TEXCOORD2.zw);

                u_xlat16_13 = (-u_xlat10_13) + 1.0;
                u_xlat10_2 = tex2D(_CloudShadowTex, i.vs_TEXCOORD6.xy).x * 0.2;

                //return float4(u_xlat16_13, u_xlat16_13, u_xlat16_13, 1);
                //return tex2D(_CloudShadowTex, i.vs_TEXCOORD6.xy);

                u_xlat16_2 = u_xlat10_2 + 0.8;
                //u_xlat16_0.xyz = 1-saturate(u_xlat16_1.xyz * u_xlat16_0.xyz);

                //return float4(u_xlat10_2.xxx, 1);

                u_xlat16_12 = 1;
                u_xlat16_12 = clamp(u_xlat16_12, 0.0, 1.0);

                //return float4(u_xlat16_12.xxx*u_xlat16_0.xyz, 1);

                SV_Target0.xyz = u_xlat16_1 * u_xlat16_2;
                
                return SV_Target0;
			}
			ENDCG
		}
	}
}
