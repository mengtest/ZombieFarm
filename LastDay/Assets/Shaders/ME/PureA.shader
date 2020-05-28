// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "ME/Pure/UnlitA" {
	Properties {
        _Color("Color", Color) = (1.0,1.0,1.0,1.0)

        [Header(Texture Settings)]
        [Toggle(SET_GRAYSCALE)] _Grayscale("Grayscale?", Float) = 0
        _AlphaTex("Alpha (RGB)", 2D) = "white" {}
        _Cutoff("Alpha Cut", Range(0,1)) = 0.5
		//[Enum(UnityEngine.Rendering.BlendMode)] _SourceBlend ("Source Blend Mode", Float) = 0
		//[Enum(UnityEngine.Rendering.BlendMode)] _DestBlend ("Dest Blend Mode", Float) = 0
	}

    SubShader {
        Tags{ "RenderType"="Opaque" }
        LOD 200
		//Blend [_SourceBlend] [_DestBlend]

		Pass {
			Name "BASE"
            LOD 200

            Lighting off			

            CGPROGRAM
			#pragma skip_variants DYNAMICLIGHTMAP_ON LIGHTMAP_ON LIGHTMAP_SHADOW_MIXING LIGHTPROBE_SH SHADOWS_SHADOWMASK VERTEXLIGHT_ON
            #pragma multi_compile __ NO_ALPHA_CLIP
            #pragma vertex vert 
            #pragma fragment frag
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
            };

            struct v2f
            {
                half4 pos : POSITION;
                half2 uv : TEXCOORD0;
            };

            v2f vert(a2v v)
            {
                v2f o;
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

		UsePass "Hidden/Toon/SHADOWCASTER"
    }

    //Fallback "Diffuse"
}
