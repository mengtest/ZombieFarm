// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "FX/Mirror"
{
	Properties
	{
		_MainTex ("Base (RGB)", 2D) = "white" {}
        _Color ("Color", Color) = (0.5,0.5,0.5,1.0)
        _Strength ("Strength", Range(0,1)) = 0.5
		[HideInInspector] _ReflectionTex ("", 2D) = "white" {}
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100
 
		Pass {
            Lighting off
            Fog{ Mode Off }
            ColorMask RGB

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
            #pragma fragmentoption ARB_precision_hint_fastest
            #pragma glsl
            #pragma target 2.0

			#include "UnityCG.cginc"
			
			struct v2f
			{
				half4 pos : SV_POSITION;
				half2 uv : TEXCOORD0;
				half4 refl : TEXCOORD1;				
			};
						
            sampler2D _MainTex;
            half4 _MainTex_ST;
            
			v2f vert(half4 pos : POSITION, half2 uv : TEXCOORD0)
			{
				v2f o;
				o.pos = UnityObjectToClipPos (pos);
				o.uv = TRANSFORM_TEX(uv, _MainTex);
				o.refl = ComputeScreenPos (o.pos);
				return o;
			}

			sampler2D _ReflectionTex;
            fixed4 _Color;
            fixed _Strength;

			fixed4 frag(v2f i) : SV_Target
			{
                fixed4 refl = tex2Dproj(_ReflectionTex, UNITY_PROJ_COORD(i.refl));
                fixed4 tex = tex2D(_MainTex, i.uv);
				half alpha = refl.a * _Strength;
                tex = tex * (1 - alpha) + refl * alpha;
                return tex * _Color;
			}
			ENDCG
	    }
	}
	//FallBack "Diffuse"
}