// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "ME/Pixelate"
{
    Properties {
        _PixelSize("Pixel Size", Float) = 0.01
    }

    SubShader {
        Tags{ "Queue" = "Transparent" "IgnoreProjector" = "True" }
        Blend Off
        Lighting Off
        Fog{ Mode Off }
        ZWrite Off
		ZTest Off
        LOD 200
        Cull Off

        GrabPass{ "_GrabTexture" }

        Pass
        {
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct v2f
            {
                half4 pos : SV_POSITION;
                half4 uv : TEXCOORD0;
            };

            half _PixelSize;

            v2f vert(appdata_base v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = ComputeGrabScreenPos(o.pos);
                return o;
            }

            sampler2D _GrabTexture;

            fixed4 frag(v2f IN) : COLOR
            {
                half2 steppedUV = IN.uv.xy / IN.uv.w;
                half2 scale = half2(_PixelSize, _PixelSize * _ScreenParams.x / _ScreenParams.y);
                steppedUV = round(steppedUV / scale) * scale;

                fixed4 color = tex2D(_GrabTexture, steppedUV);
                // color.rgb = Luminance(color.rgb);
                return color;
            }

            ENDCG
        }
    }
}