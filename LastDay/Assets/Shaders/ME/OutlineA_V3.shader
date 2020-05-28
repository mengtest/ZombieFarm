Shader "ME/Toon/Outline V3"
{
    Properties {
        _Color ("Color", Color) = (0.4191176,0,0,1)
		_MainTex("Alpha (RGB)", 2D) = "white" {}
        _Cutoff("Alpha Cut", Range(0,1)) = 0.5

		_OutlineColor("Outline Color", Color) = (0.2, 0.2, 0.2, 1)
        _Outline ("Outline Width", float) = 1

        _CreepTex ("Texture", 2D) = "white" {}
        _NoiseTex ("Noise Texture", 2D) = "white" {}
        _Offset ("Offset", Range(-5, 5)) = 0.1367521
        _Amplitude ("Amplitude", Range(0, 1)) = 0.1538462
        _TimeSpeed ("Time Speed", Range(0, 2)) = 0.7350427
        
        _AlphaGridTex ("Alpha Grid Texture", 2D) = "white" {}
		[Enum(UnityEngine.Rendering.BlendMode)] _SrcBlend ("Src Blend", Int) = 1
        [Enum(UnityEngine.Rendering.BlendMode)] _DstBlend ("Dst Blend", Int) = 0
    }
    SubShader {
        Tags {
            "RenderType"="Opaque"
        }
        Pass {
            Name "CREEP_OUTLINE"
            Tags { "LightMode"="ForwardBase" "IgnoreProjector"="True" }
            Blend [_SrcBlend] [_DstBlend]
            Cull Front
            Lighting Off

            CGPROGRAM
			#include "UnityCG.cginc"
			#pragma skip_variants DYNAMICLIGHTMAP_ON LIGHTMAP_ON LIGHTMAP_SHADOW_MIXING LIGHTPROBE_SH SHADOWS_SCREEN SHADOWS_SHADOWMASK VERTEXLIGHT_ON DIRECTIONAL
			#pragma multi_compile __ TOON_TRANSPARENT
            #pragma vertex vert
            #pragma fragment frag            
            #pragma fragmentoption ARB_precision_hint_fastest
            #pragma target 3.0
			            
			struct VertexInput {
                half4 vertex : POSITION;
                half3 normal : NORMAL;
                half2 texcoord0 : TEXCOORD0;
            };
            
			struct VertexOutput {
                half4 pos : SV_POSITION;
                half2 uv0 : TEXCOORD0;
                half3 normalDir : TEXCOORD1;
                #ifdef TOON_TRANSPARENT
                half4 screenUv : TEXCOORD2;
                #endif
            };
						
            uniform sampler2D _CreepTex; uniform half4 _CreepTex_ST;
            uniform sampler2D _NoiseTex; uniform half4 _NoiseTex_ST;
            uniform half _Offset;
            uniform half _Amplitude;
            uniform half _TimeSpeed;
            uniform half _Outline;

            VertexOutput vert (VertexInput v) 
			{
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.normalDir = UnityObjectToWorldNormal(v.normal);

				half4 time = _Time.y;
                half4 Creep = tex2Dlod(_CreepTex,half4(TRANSFORM_TEX(o.uv0, _CreepTex),0.0,0));                
				half rad = 6.28318530718*_TimeSpeed*time;
                half creepValue = Creep.r * sin(rad);

                half4 Noise = tex2Dlod(_NoiseTex,half4(TRANSFORM_TEX(o.uv0, _NoiseTex),0.0,0));
                half2 uv1 = (o.uv0+(time*half2(_Offset,_Offset)));
                half4 Noise1 = tex2Dlod(_NoiseTex,half4(TRANSFORM_TEX(uv1, _NoiseTex),0.0,0));

                v.vertex.xyz += v.normal * (creepValue*(Noise.r*Noise1.r)) *_Amplitude;
                o.pos = UnityObjectToClipPos( half4(v.vertex.xyz + v.normal*_Outline/100,1) );
                
#ifdef TOON_TRANSPARENT
                half4 screenPos = ComputeScreenPos(o.pos);
                screenPos.xy *= _ScreenParams.xy / 8;
                o.screenUv = screenPos;
#endif
                
                return o;
            }
			
			sampler2D _MainTex;
			sampler2D _AlphaGridTex;
			half _Cutoff;
			fixed4 _Color;
			fixed4 _OutlineColor;

            half4 frag(VertexOutput i) : COLOR 
			{
				fixed4 c = tex2D(_MainTex, i.uv0);
                clip(c.a - _Cutoff);
                
#ifdef TOON_TRANSPARENT
                half gridAlpha = tex2Dproj(_AlphaGridTex, i.screenUv).r;
                clip(_Color.a - gridAlpha);
#endif

                i.normalDir = normalize(i.normalDir);
                _OutlineColor.a = _Color.a;
                return _OutlineColor;
            }
            ENDCG
        }

        Pass {
            Name "CREEP_OUTLINE TRANSPARENT"
            Tags {
            }
            Cull Front
            Lighting Off
            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
            #include "UnityCG.cginc"
			#pragma skip_variants DYNAMICLIGHTMAP_ON LIGHTMAP_ON LIGHTMAP_SHADOW_MIXING LIGHTPROBE_SH SHADOWS_SCREEN SHADOWS_SHADOWMASK VERTEXLIGHT_ON DIRECTIONAL
            #pragma vertex vert
            #pragma fragment frag
            #pragma fragmentoption ARB_precision_hint_fastest
            #pragma target 3.0
                        
            struct VertexInput {
                half4 vertex : POSITION;
                half3 normal : NORMAL;
                half2 texcoord0 : TEXCOORD0;
            };
            
            struct VertexOutput {
                half4 pos : SV_POSITION;
                half2 uv0 : TEXCOORD0;
                half3 normalDir : TEXCOORD1;
            };
                        
            uniform sampler2D _CreepTex; uniform half4 _CreepTex_ST;
            uniform sampler2D _NoiseTex; uniform half4 _NoiseTex_ST;
            uniform half _Offset;
            uniform half _Amplitude;
            uniform half _TimeSpeed;
            uniform half _Outline;

            VertexOutput vert (VertexInput v) 
            {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.normalDir = UnityObjectToWorldNormal(v.normal);

                half4 time = _Time.y;
                half4 Creep = tex2Dlod(_CreepTex,half4(TRANSFORM_TEX(o.uv0, _CreepTex),0.0,0));                
                half rad = 6.28318530718*_TimeSpeed*time;
                half creepValue = Creep.r * sin(rad);

                half4 Noise = tex2Dlod(_NoiseTex,half4(TRANSFORM_TEX(o.uv0, _NoiseTex),0.0,0));
                half2 uv1 = (o.uv0+(time*half2(_Offset,_Offset)));
                half4 Noise1 = tex2Dlod(_NoiseTex,half4(TRANSFORM_TEX(uv1, _NoiseTex),0.0,0));

                v.vertex.xyz += v.normal * (creepValue*(Noise.r*Noise1.r)) *_Amplitude;
                o.pos = UnityObjectToClipPos( half4(v.vertex.xyz + v.normal*_Outline/100,1) );
                return o;
            }

            uniform fixed4 _Color;
            sampler2D _AlphaTex;
            half _Cutoff;
            fixed4 _OutlineColor;

            half4 frag(VertexOutput i) : COLOR 
            {
                fixed4 c = tex2D(_AlphaTex, i.uv0);
                clip(c.r - _Cutoff);
                _OutlineColor.a = c.r * _Color.a;

                i.normalDir = normalize(i.normalDir);
                return _OutlineColor;
            }
            ENDCG
        }
    }
}
