Shader "ME/Shadow"
{
	Properties
	{
		 _Color("Color", Color) = (1.0,1.0,1.0,1.0)

		[Header(Texture Settings)]
        _MainTex("Main Texture (RGB) Spec/MatCap Mask (A) ", 2D) = "white" {}
        [Toggle(SET_GRAYSCALE)] _Grayscale("Grayscale?", Float) = 0
        _AlphaTex("Alpha (RGB)", 2D) = "white" {}
        _Cutoff("Alpha Cut", Range(0,1)) = 0.5
	}

	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass 
		{
			Name "SHADOWCOLLECTOR"
			Tags { "LightMode" = "ShadowCollector" }
       
			Fog {Mode Off}
			ZWrite On ZTest Less
 
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest
			#pragma multi_compile_shadowcollector
 
			#define SHADOW_COLLECTOR_PASS
			#include "UnityCG.cginc"
 
			struct appdata {
				half4 vertex : POSITION;
			};
 
			struct v2f {
				V2F_SHADOW_COLLECTOR;
			};
 
			v2f vert (appdata v)
			{
				v2f o;
				TRANSFER_SHADOW_COLLECTOR(o)
				return o;
			}
 
			fixed4 frag (v2f i) : COLOR
			{
				SHADOW_COLLECTOR_FRAGMENT(i)
			}
			ENDCG
 
	    }
	}
}
