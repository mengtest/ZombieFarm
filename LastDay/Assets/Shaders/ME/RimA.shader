Shader "ME/Toon/RimA"
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
        _MainTex("Main Texture (RGB) Spec/MatCap Mask (A) ", 2D) = "white" {}
        [Toggle(SET_GRAYSCALE)] _Grayscale("Grayscale?", Float) = 0
        _AlphaTex("Alpha (RGB)", 2D) = "white" {}
        _Cutoff("Alpha Cut", Range(0,1)) = 0.5
        
        [Header(Rim Settings)]
        _RimColor("Rim Color", Color) = (0.8,0.8,0.8,0.6)
        _RimMin("Rim Min", Range(0,1)) = 0.5
        _RimMax("Rim Max", Range(0,1)) = 1.0
    }

    SubShader
    {
        Tags{ "RenderType"="Opaque" "IgnoreProjector" = "True" }
        LOD 200
        CGPROGRAM
		#pragma skip_variants DYNAMICLIGHTMAP_ON LIGHTMAP_ON LIGHTMAP_SHADOW_MIXING LIGHTPROBE_SH SHADOWS_SHADOWMASK VERTEXLIGHT_ON
        #pragma multi_compile __ NO_ALPHA_CLIP
        #pragma multi_compile __ SET_GRAYSCALE
        #pragma surface surf RampSmooth vertex:vert noforwardadd interpolateview halfasview
        #pragma glsl
        #pragma target 2.0

        #include "ME_Light.cginc"
        //================================================================
        // VARIABLES
				
		sampler2D _MainTex;
		sampler2D _AlphaTex;
		fixed _Cutoff;
        fixed4 _Color;
        
        fixed4 _RimColor;
        fixed _RimMin;
        fixed _RimMax;
        
        struct Input
        {
            half2 uv_MainTex : TEXCOORD0;
            fixed rim;
        };

        //================================================================
        // VERTEX FUNCTION

        void vert(inout appdata_full v, out Input o)
        {
            UNITY_INITIALIZE_OUTPUT(Input, o);
              
            fixed3 viewDir = normalize(ObjSpaceViewDir(v.vertex));

            fixed rim = 1.0f - saturate(dot(viewDir, v.normal));
            o.rim = smoothstep(_RimMin, _RimMax, rim) * _RimColor.a;
        }

        //================================================================
        // SURFACE FUNCTION

        void surf(Input IN, inout SurfaceOutput o)
        {
#ifndef NO_ALPHA_CLIP
            fixed4 alpha = tex2D(_AlphaTex, IN.uv_MainTex);
            clip(alpha.r - _Cutoff);
#endif
            fixed4 main = tex2D(_MainTex, IN.uv_MainTex);
#if SET_GRAYSCALE
            o.Albedo = Luminance(main.rgb) * _Color.rgb;
#else
            o.Albedo = main.rgb * _Color.rgb;
#endif

            o.Emission += IN.rim * _RimColor.rgb * 2;
        }

        ENDCG

		UsePass "Hidden/Toon/SHADOWCASTER"
    }

    //Fallback "Diffuse"
}
