// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "ME/Pure/UnlitB" {
	Properties {
        _Color("Color", Color) = (1.0,1.0,1.0,1.0)

        [Header(Texture Settings)]
        _MainTex("Main Texture (RGB) Spec/MatCap Mask (A) ", 2D) = "white" {}
        [Toggle(SET_GRAYSCALE)] _Grayscale("Grayscale?", Float) = 0
        _AlphaTex("Alpha (RGB)", 2D) = "white" {}
        _Cutoff("Alpha Cut", Range(0,1)) = 0.5
		_SkinTex("Skin (RGB)", 2D) = "black" {}
		_SkinCut("Skin Cut", Range(0,1)) = 0.1
	}

	SubShader {
        Tags{ "RenderType"="Transparent" "Queue"="Transparent" "IgnoreProjector"="true" }
        LOD 200

		Pass {
			Name "BASE"
            LOD 200

            Tags{ "LightMode"="ForwardBase" }
            Lighting off
            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
            #pragma multi_compile __ NO_ALPHA_CLIP
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_instancing
            #pragma fragmentoption ARB_precision_hint_fastest
            #pragma glsl
            #pragma target 2.0

            #include "UnityCG.cginc"

            sampler2D _AlphaTex;
            fixed _Cutoff;

            struct a2v
            {
                half4 vertex : POSITION;
                half2 texcoord : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                half4 pos : POSITION;
                half2 uv : TEXCOORD0;
            };

            v2f vert(a2v v)
            {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);

                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;
                return o;
            }

            fixed4 _Color;

            fixed4 frag(v2f IN) : COLOR
            {
#ifndef NO_ALPHA_CLIP
                fixed4 alpha = tex2D(_AlphaTex, IN.uv);
                clip(alpha.r - _Cutoff);
#endif
                return _Color;
            }
            ENDCG
        }
		//UsePass "Hidden/Toon/SHADOWCASTER"
	}
	//FallBack "Diffuse"
}
