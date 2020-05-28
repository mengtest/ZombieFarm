// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "FX/Lit Mirror"
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
            Tags { "LightMode" = "ForwardBase" }
            Fog { Mode Off }
            ColorMask RGB
            Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
            #pragma fragmentoption ARB_precision_hint_fastest
            #pragma multi_compile_fwdbase
            #pragma glsl
            #pragma target 2.0

			#include "UnityCG.cginc"  
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            struct a2v
            {
                half4 vertex : POSITION;
                half2 texcoord : TEXCOORD0;
            };

			struct v2f
			{
				half4 pos : SV_POSITION;
				half2 uv : TEXCOORD0;
				half4 refl : TEXCOORD1;

                LIGHTING_COORDS(2, 3)
			};
						
            sampler2D _MainTex;
            half4 _MainTex_ST;
            
			v2f vert(a2v v) //half4 pos : POSITION, half2 uv : TEXCOORD0)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.refl = ComputeScreenPos (o.pos);

                TRANSFER_VERTEX_TO_FRAGMENT(o);
				return o;
			}

			sampler2D _ReflectionTex;
            fixed4 _Color;
            fixed _Strength;

            inline fixed4 SampleLight(fixed4 fcol, half atten)
            {
                fixed4 c;
                c.rgb = fcol * _LightColor0.rgb * atten;
                c.a = fcol.a;
                return c;
            }

			fixed4 frag(v2f i) : SV_Target
			{
                fixed4 refl = tex2Dproj(_ReflectionTex, UNITY_PROJ_COORD(i.refl));
                fixed4 tex = tex2D(_MainTex, i.uv);
				half alpha = refl.a * _Strength;
                tex = tex * (1 - alpha) + refl * alpha;

                return SampleLight(tex * _Color, LIGHT_ATTENUATION(i));
			}
			ENDCG
	    }
	}
	//FallBack "Diffuse"
}