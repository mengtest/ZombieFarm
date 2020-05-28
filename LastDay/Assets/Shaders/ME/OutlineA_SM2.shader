// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Toony Colors Pro+Mobile 2
// (c) 2014,2015 Jean Moreno

Shader "ME/Toon/Outline(Shader Model 2)"
{
	Properties
	{
        _Color("Color", Color) = (1.0,1.0,1.0,1.0)
        _MainTex("Main (RGBA)", 2D) = "white" {}
        _Cutoff("Alpha Cut", Range(0,1)) = 0.5

        _OutlineColor("Outline Color", Color) = (0.2, 0.2, 0.2, 1)
        _Outline ("Outline Width", Float) = 1
        [Toggle(CONST_WIDTH)] _ConstWidth("ConstWidth?", Float) = 0

        _ZSmooth("Z Correction", Range(-3.0,3.0)) = 0

		_Offset1 ("Z Offset 1", Float) = 0
		_Offset2 ("Z Offset 2", Float) = 0

		_AlphaGridTex ("Alpha Grid Texture", 2D) = "white" {}
		[Enum(UnityEngine.Rendering.BlendMode)] _SrcBlend ("Src Blend", Int) = 1
        [Enum(UnityEngine.Rendering.BlendMode)] _DstBlend ("Dst Blend", Int) = 0
	}

	SubShader
	{
		LOD 200

		//Outline Toony Colors 2
		Pass
		{
			Name "OUTLINE"

			Cull Front
            Lighting Off
            //ZWrite Off
			Offset [_Offset1],[_Offset2]
			Tags { "LightMode"="Always" "IgnoreProjector"="True" }
			Blend [_SrcBlend] [_DstBlend]

			CGPROGRAM

			#include "UnityCG.cginc"
			#pragma skip_variants DYNAMICLIGHTMAP_ON LIGHTMAP_ON LIGHTMAP_SHADOW_MIXING LIGHTPROBE_SH SHADOWS_SCREEN SHADOWS_SHADOWMASK VERTEXLIGHT_ON DIRECTIONAL
            #pragma multi_compile __ CONST_WIDTH
            #pragma multi_compile __ TOON_TRANSPARENT
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_instancing
            #pragma fragmentoption ARB_precision_hint_fastest
            #pragma glsl
            #pragma target 2.0

			struct a2v
			{
                half4 vertex : POSITION;
                half3 normal : NORMAL;
                half2 texcoord: TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct v2f
			{
                half4 pos : SV_POSITION;
                half2 uv : TEXCOORD0;
                #ifdef TOON_TRANSPARENT
                half4 screenUv : TEXCOORD1;
                #endif
			};

            uniform sampler2D _MainTex;
            uniform fixed4 _Color;
            uniform fixed _Outline;
            uniform fixed4 _OutlineColor;
            uniform half _ZSmooth;
            uniform fixed _Cutoff;
            uniform sampler2D _AlphaGridTex;

			v2f vert (a2v v)
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);

                half3 normal = v.normal;
                normal.z += _ZSmooth;
#ifdef CONST_WIDTH
                half dist = distance(_WorldSpaceCameraPos, mul(unity_ObjectToWorld, v.vertex));
                half3 pos = UnityObjectToViewPos(v.vertex + half4(normal, 0) * _Outline * 0.001 * dist); //mul(UNITY_MATRIX_MV, v.vertex + half4(normal, 0) * _Outline * 0.001 * dist);
#else
                half3 pos = UnityObjectToViewPos(v.vertex + half4(normal, 0) * _Outline * 0.01); //mul(UNITY_MATRIX_MV, v.vertex + half4(normal, 0) * _Outline * 0.01);
#endif
                o.pos = mul(UNITY_MATRIX_P, half4(pos, 1));
                o.pos.z -= 0.0002 * _Outline;
                o.uv = v.texcoord;

#ifdef TOON_TRANSPARENT
                half4 screenPos = ComputeScreenPos(o.pos);
                screenPos.xy *= _ScreenParams.xy / 8;
                o.screenUv = screenPos;
#endif

				return o;
			}

            fixed4 frag (v2f IN) : COLOR
			{
                fixed4 main = tex2D(_MainTex, IN.uv);
                clip(main.a - _Cutoff);

#ifdef TOON_TRANSPARENT
                half gridAlpha = tex2Dproj(_AlphaGridTex, IN.screenUv).r;
                clip(_Color.a - gridAlpha);
#endif

                _OutlineColor.a = _Color.a;
				return _OutlineColor;
			}

		    ENDCG
		}
	}
}
