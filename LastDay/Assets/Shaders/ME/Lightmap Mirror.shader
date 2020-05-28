// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "ME/Lightmap Mirror" 
{
    Properties {
        _MainTex ("Texture", 2D) = "white" {}
        _Stength("Strength", Range(0,1)) = 0.5
        [HideInInspector] _ReflectionTex("", 2D) = "white" {}
    }
    
    SubShader {
        Tags{ "RenderType" = "Opaque" }
        LOD 200

        Pass {
            CGPROGRAM
			#pragma skip_variants LIGHTMAP_SHADOW_MIXING DIRLIGHTMAP_COMBINED SHADOWS_SHADOWMASK VERTEXLIGHT_ON
            #pragma vertex vert  
            #pragma fragment frag  
            #pragma multi_compile_fog  
            #pragma multi_compile LIGHTMAP_OFF LIGHTMAP_ON
            #include "UnityCG.cginc"  

            struct appdata_t {
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0;
                float2 texcoord1 : TEXCOORD1;
            };

            struct v2f {
                float4 vertex : SV_POSITION;
                half2 texcoord : TEXCOORD0;
#ifndef LIGHTMAP_OFF  
                half2 uvLM : TEXCOORD1;
#endif   
                float4 refl : TEXCOORD2;
                UNITY_FOG_COORDS(1)
            };

            sampler2D _MainTex;
            sampler2D _ReflectionTex;

            float4 _MainTex_ST;

            inline fixed4 Enlight(half3 clr, half alpha)
            {
                clr = clr * clr + clr;
                return fixed4(clr, alpha);
            }

            v2f vert(appdata_t v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.refl = ComputeScreenPos(o.vertex);

#ifndef LIGHTMAP_OFF  
                o.uvLM = v.texcoord1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
#endif                  
                UNITY_TRANSFER_FOG(o, o.vertex);
                return o;
            }

            fixed _Stength;

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.texcoord);
                
                UNITY_APPLY_FOG(i.fogCoord, col);
                UNITY_OPAQUE_ALPHA(col.a);
#ifndef LIGHTMAP_OFF  
                fixed3 lm = DecodeLightmap(UNITY_SAMPLE_TEX2D(unity_Lightmap, i.uvLM.xy));
                col.rgb *= lm;
                col = Enlight(col, col.a);
#endif

                fixed4 refl = tex2Dproj(_ReflectionTex, UNITY_PROJ_COORD(i.refl));
                refl *= _Stength;
                col += refl;
                return col;
                
            }
            ENDCG
        }
    }
    //Fallback "Diffuse"
}