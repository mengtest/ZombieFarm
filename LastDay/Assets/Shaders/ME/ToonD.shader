
Shader "ME/Toon/UnlitD" {
	Properties {
        _Color("Color", Color) = (1.0,1.0,1.0,1.0)

        [Header(Texture Settings)]
        _MainTex("Main (RGBA)", 2D) = "white" {}
        [Toggle(SET_GRAYSCALE)] _Grayscale("Grayscale?", Float) = 0
        _AlphaTex("Alpha (RGB)", 2D) = "white" {}
        _Cutoff("Alpha Cut", Range(0,1)) = 0.5
		_SkinTex("Skin (RGB)", 2D) = "black" {}
		_SkinCut("Skin Cut", Range(0,1)) = 0.1
		_Radius("Radius", Range(0.01, 1)) = 1
	}

	SubShader {
        Tags{ "RenderType"="Opaque" }
        LOD 200

		Pass {
			Name "BASE"
            LOD 200

			Tags{ "LightMode"="ForwardBase" }
            Lighting off

            CGPROGRAM
            #pragma multi_compile __ SET_GRAYSCALE
            #pragma multi_compile __ BLEND_SKIN_TEX
            #pragma vertex vert
            #pragma fragment frag
            #pragma fragmentoption ARB_precision_hint_fastest
            #pragma glsl
            #pragma target 2.0

            #include "UnityCG.cginc"
			#include "ME_Toon.cginc"

            struct a2v
            {
                half4 vertex : POSITION;
				half3 normal : NORMAL;
                half2 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                half4 pos : POSITION;
                half2 uv : TEXCOORD0;
				fixed3 vlight : TEXCOORD1;
				half4 screenUv : TEXCOORD2;
				half3 worldPos : TEXCOORD3;
            };

            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);

				half3 worldNormal = mul((half3x3)unity_ObjectToWorld, SCALED_NORMAL);
				o.vlight = ShadeSH9 (half4(worldNormal, 1.0));

				half4 screenPos = ComputeScreenPos(o.pos);
                o.screenUv = screenPos / screenPos.w;

                return o;
            }

            fixed4 _Color;
			half _Radius;

            fixed4 frag(v2f IN) : COLOR
            {
				half2 d = abs(IN.screenUv.xy - half2(0.5, 0.5)) / _Radius;
				d.x *= _ScreenParams.x / _ScreenParams.y;
				d = saturate(d);
				half vfactor = 1 - pow(saturate(1.0 - dot(d, d)), 0.3);
				//clip(vfactor - 0.001);

				fixed4 main = ToonSkin(IN.uv, IN.uv, IN.worldPos, _Color);
				//main.a *= _Color.a;
				main.a *= _Color.a * vfactor;

				main.rgb *= IN.vlight;
                return main;
            }
            ENDCG
        }
		UsePass "ME/Toon/LitD/SHADOWCASTER"
	}
	//FallBack "Diffuse"
}
