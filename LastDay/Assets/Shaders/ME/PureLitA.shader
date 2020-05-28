Shader "ME/Pure/LitA"
{
    Properties
    {
        [Header(Light Settings)]
        _Color("Color", Color) = (0.6,0.6,0.6,1.0)
        _HColor("Highlight Color", Color) = (1.0,1.0,1.0,1.0)
        _SColor("Shadow Color", Color) = (0.2,0.2,0.2,1.0)

        _RampThreshold("Ramp Threshold", Range(0,1)) = 0.5
        _RampSmooth("Ramp Smoothing", Range(0.01,1)) = 0.1

        [Header(Texture Settings)]
        _AlphaTex("Alpha (RGB)", 2D) = "white" {}
        _Cutoff("Alpha Cut", Range(0,1)) = 0.5        
    }

    SubShader
    {
        Tags{ "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
		#pragma skip_variants DYNAMICLIGHTMAP_ON LIGHTMAP_ON LIGHTMAP_SHADOW_MIXING LIGHTPROBE_SH SHADOWS_SHADOWMASK VERTEXLIGHT_ON
        #pragma multi_compile __ NO_ALPHA_CLIP
        #pragma surface surf RampSmooth noforwardadd interpolateview halfasview
        #pragma glsl
        #pragma target 2.0
            
        #include "ME_Light.cginc"
        //================================================================
        // VARIABLES
		
		sampler2D _MainTex;
		sampler2D _AlphaTex;
		fixed _Cutoff;
        fixed4 _Color;

        struct Input
        {
            half2 uv_MainTex : TEXCOORD0;
        };

        //================================================================
        // SURFACE FUNCTION

        void surf(Input IN, inout SurfaceOutput o)
        {
#ifndef NO_ALPHA_CLIP
            fixed4 alpha = tex2D(_AlphaTex, IN.uv_MainTex);
            clip(alpha.r - _Cutoff);
#endif
            o.Albedo = _Color.rgb;
        }
        ENDCG

		UsePass "Hidden/Toon/SHADOWCASTER"
    }

    //Fallback "Diffuse"
}
