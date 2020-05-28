Shader "ME/Lightmap Outline"
{
	 Properties {
        _MainTex ("Texture", 2D) = "white" {}
		_CutOff("Cut Off", float) = 0.5

		[Header(Outline Settings)]
        _OutlineColor("Outline Color", Color) = (0.2, 0.2, 0.2, 1.0)
        _Outline("Outline Width", Float) = 1
        [Toggle(CONST_WIDTH)] _ConstWidth("ConstWidth?", Float) = 0

        _ZSmooth("Z Correction", Range(-3.0,3.0)) = 0

        _Offset1("Z Offset 1", Float) = 0
        _Offset2("Z Offset 2", Float) = 0
    }
    SubShader {
		Tags{ "RenderType" = "Opaque" }
		LOD 200

		UsePass "ME/Lightmap/FORWARD"
		UsePass "ME/Toon/Outline(Shader Model 2)/OUTLINE"
		UsePass "ME/Unlit/RecvShadow/SHADOWCASTER"
    }
}
