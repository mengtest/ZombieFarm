Shader "ME/Pure/LitA Outline"
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

        [Header(Outline Settings)]
        _OutlineColor("Outline Color", Color) = (0.2, 0.2, 0.2, 1.0)
        _Outline("Outline Width", Float) = 1
        [Toggle(CONST_WIDTH)] _ConstWidth("ConstWidth?", Float) = 0
        
        _ZSmooth("Z Correction", Range(-3.0,3.0)) = 0

        //Z Offset
        _Offset1("Z Offset 1", Float) = 0
        _Offset2("Z Offset 2", Float) = 0
    }

    SubShader
    {
        LOD 200
        
        UsePass "ME/Pure/LitA/FORWARD"
        UsePass "ME/Toon/Outline(Shader Model 2)/OUTLINE"
		UsePass "Hidden/Toon/SHADOWCASTER"
    }

    //Fallback "Diffuse"
}
