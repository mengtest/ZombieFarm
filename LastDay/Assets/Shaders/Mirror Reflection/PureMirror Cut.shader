// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "FX/PureMirror Cut"
{
	Properties
	{
        _Color("Color", Color) = (1.0,1.0,1.0,1.0)
		[HideInInspector] 
        _ReflectionTex ("", 2D) = "white" {}
	}
	SubShader
	{
		Tags{ "Queue"="Transparent" "RenderType"="Transparent"}
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
				half4 refl : TEXCOORD0;
				half4 pos : SV_POSITION;
			};
			
			v2f vert(half4 pos : POSITION)
			{
				v2f o;
				o.pos = UnityObjectToClipPos (pos);
				o.refl = ComputeScreenPos (o.pos);
				return o;
			}

			sampler2D _ReflectionTex;
            fixed4 _Color;

			fixed4 frag(v2f i) : SV_Target
			{
                fixed4 refl = tex2Dproj(_ReflectionTex, UNITY_PROJ_COORD(i.refl));
                clip(refl.r + refl.g + refl.b - 0.01);
				return refl * _Color;
			}
			ENDCG
	    }
	}
	//FallBack "Diffuse"
}