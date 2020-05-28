Shader "ME/Toon/MatcapA"
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
        
        [Header(Matcap Settings)]
        _MatCap("MatCap (RGB)", 2D) = "black" {}
        _MColor("Matcap Color", Color) = (1.0,1.0,1.0,1.0)
    }

    SubShader
    {
        Tags{ "RenderType"="Opaque" "IgnoreProjector"="True" }
        LOD 200
        CGPROGRAM        
        #pragma multi_compile __ NO_ALPHA_CLIP
        #pragma multi_compile __ SET_GRAYSCALE
        #pragma surface surf RampSmooth vertex:vert noforwardadd interpolateview halfasview
        #pragma glsl
        #pragma target 2.0

        #include "ME_Light.cginc"
        //================================================================
        // VARIABLES

        struct Input
        {
            half2 uv_MainTex : TEXCOORD0;
            fixed2 matcap;
        };

		
		sampler2D _MainTex;
		sampler2D _AlphaTex;
		fixed _Cutoff;
        //================================================================
        // VERTEX FUNCTION

        void vert(inout appdata_full v, out Input o)
        {
            UNITY_INITIALIZE_OUTPUT(Input, o);
            //MATCAP
            fixed3 worldNorm = normalize(unity_WorldToObject[0].xyz * v.normal.x + unity_WorldToObject[1].xyz * v.normal.y + unity_WorldToObject[2].xyz * v.normal.z);
            worldNorm = mul((fixed3x3)UNITY_MATRIX_V, worldNorm);
            o.matcap.xy = worldNorm.xy * 0.5 + 0.5;
        }

        //================================================================
        // SURFACE FUNCTION

		fixed4 _Color;
        sampler2D _MatCap;
        fixed4 _MColor;

        void surf(Input IN, inout SurfaceOutput o)
        {
#ifndef NO_ALPHA_CLIP
            fixed4 alpha = tex2D(_AlphaTex, IN.uv_MainTex);
            clip(alpha.r - _Cutoff);
#endif
            fixed4 main = tex2D(_MainTex, IN.uv_MainTex);
#ifdef SET_GRAYSCALE
            o.Albedo = Luminance(main.rgb) * _Color.rgb;
#else
            o.Albedo = main.rgb * _Color.rgb;
#endif

            fixed3 matcap = tex2D(_MatCap, IN.matcap).rgb;
            o.Emission += matcap * _MColor * 2;
        }

        ENDCG

		UsePass "Hidden/Toon/SHADOWCASTER"
    }

    //Fallback "Diffuse"
}
