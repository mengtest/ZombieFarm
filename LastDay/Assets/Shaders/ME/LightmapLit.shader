Shader "ME/LightmapLit" 
{
	Properties {
        _MainTex ("Texture", 2D) = "white" {}
		_CutOff("Cut Off", float) = 0.5
		_Intensity("Intensity", float) = 2
    }

    SubShader {
        Tags{ "RenderType" = "Opaque" }
        LOD 200

        Pass {
            Name "FORWARD"

            Tags{ "LightMode"="ForwardBase" }
			
            CGPROGRAM
			#pragma skip_variants LIGHTMAP_SHADOW_MIXING DIRLIGHTMAP_COMBINED SHADOWS_SHADOWMASK VERTEXLIGHT_ON
			#pragma multi_compile LIGHTMAP_OFF LIGHTMAP_ON
            #pragma vertex vert 
            #pragma fragment frag
            #pragma multi_compile_fwdbase
            #pragma fragmentoption ARB_precision_hint_fastest
            #pragma glsl
            #pragma target 2.0

            #include "UnityCG.cginc"  
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            sampler2D _MainTex;
			fixed4 _MainTex_ST;
            fixed _CutOff;
			half _Intensity;

            struct a2v
            {
                half4 vertex : POSITION;
                half3 normal : NORMAL;
                half2 texcoord : TEXCOORD0;
                fixed4 color : COLOR;
#ifdef LIGHTMAP_ON
				half2 texcoord1 : TEXCOORD1;
#endif
            };

            struct v2f
            {
                half4 pos : POSITION;
                half2 uv : TEXCOORD0;
#ifdef LIGHTMAP_ON
				half2 uvLM : TEXCOORD1;
                fixed3 worldNormal : TEXCOORD2;
                fixed3 lightDir : TEXCOORD3;
                fixed3 viewDir : TEXCOORD4;

                // 声明_LightCoord和_ShadowCoord
                LIGHTING_COORDS(5, 6)
#else
                fixed3 worldNormal : TEXCOORD1;
                fixed3 lightDir : TEXCOORD2;
                fixed3 viewDir : TEXCOORD3;

                // 声明_LightCoord和_ShadowCoord
                LIGHTING_COORDS(4, 5)
#endif
            };
						
			inline fixed4 RampSmoothLight(fixed4 fcol, half3 worldNormal, half3 lightDir, half atten)
			{
				half ndl = max(0, dot(worldNormal, lightDir) * 0.5 + 0.5);
				
				fixed4 c;
				c.rgb = fcol.rgb * _LightColor0.rgb * atten * _Intensity;
				c.a = fcol.a;
				return c;
			}

            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
#ifdef LIGHTMAP_ON
				o.uvLM = v.texcoord1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
#endif
                o.worldNormal = normalize(mul(SCALED_NORMAL, (half3x3)unity_WorldToObject));
                o.lightDir = normalize(mul((half3x3)unity_ObjectToWorld, ObjSpaceLightDir(v.vertex)));
                o.viewDir = normalize(mul((half3x3)unity_ObjectToWorld, ObjSpaceViewDir(v.vertex)));

                // 计算_LightCoord和_ShadowCoord
                TRANSFER_VERTEX_TO_FRAGMENT(o);
                return o;
            }
			
            fixed4 frag(v2f IN) : COLOR
            {
                fixed4 main = tex2D(_MainTex, IN.uv);
				clip(main.a - _CutOff);

#ifdef LIGHTMAP_ON
				fixed3 lm = DecodeLightmap(UNITY_SAMPLE_TEX2D(unity_Lightmap, IN.uvLM.xy));
                main.rgb *= lm;
#endif

                return RampSmoothLight(main, IN.worldNormal, IN.lightDir, LIGHT_ATTENUATION(IN));
            }
            ENDCG
        }

		UsePass "Hidden/Toon/SHADOWCASTER"
    }
}