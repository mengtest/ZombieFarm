Shader "ME/CurvedToon/LitA Outline"
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

		 [Header(Outline Settings)]
        _OutlineColor("Outline Color", Color) = (0.2, 0.2, 0.2, 1.0)
        _Outline("Outline Width", Float) = 1
        [Toggle(CONST_WIDTH)] _ConstWidth("ConstWidth?", Float) = 0

        _ZSmooth("Z Correction", Range(-3.0,3.0)) = 0

        //Z Offset
        _Offset1("Z Offset 1", Float) = 0
        _Offset2("Z Offset 2", Float) = 0
    }

    SubShader
    {
        Tags{ "RenderType"="Opaque" }
        LOD 200

        UsePass "ME/CurvedToon/LitA/BASE"
        
		Pass
		{
			Name "OUTLINE"
			
			Cull Front
            Lighting Off
            //ZWrite Off
			Offset [_Offset1],[_Offset2]
			Tags { "LightMode"="ForwardBase" "IgnoreProjector"="True" }
			
			CGPROGRAM
			
			#pragma skip_variants DYNAMICLIGHTMAP_ON LIGHTMAP_ON LIGHTMAP_SHADOW_MIXING LIGHTPROBE_SH SHADOWS_SCREEN SHADOWS_SHADOWMASK VERTEXLIGHT_ON DIRECTIONAL
            #pragma multi_compile __ CONST_WIDTH
			#pragma vertex vert
			#pragma fragment frag
            #pragma fragmentoption ARB_precision_hint_fastest
            #pragma glsl
            #pragma target 2.0

			#include "UnityCG.cginc"
			#include "../../VacuumShaders/Curved World/Shaders/cginc/CurvedWorld_Base.cginc"

			struct a2v
			{
                half4 vertex : POSITION;
                half3 normal : NORMAL;
                half2 texcoord: TEXCOORD0;
			}; 
			
			struct v2f
			{
                half4 pos : SV_POSITION;
                half2 uv : TEXCOORD0;
			};

            uniform sampler2D _AlphaTex;            
            uniform fixed _Outline;
            uniform fixed4 _OutlineColor;
            uniform half _ZSmooth;
            uniform fixed _Cutoff;
			
			v2f vert (a2v v)
			{
				V_CW_TransformPoint(v.vertex);

				v2f o;
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

				return o;
			}
			
            fixed4 frag (v2f IN) : COLOR
			{
                fixed4 c = tex2D(_AlphaTex, IN.uv);
                clip(c.r - _Cutoff);
				return _OutlineColor;
			}

		    ENDCG
		}

		UsePass "ME/CurvedToon/LitA/SHADOWCASTER"
    }
	
    //Fallback "Diffuse"
}
