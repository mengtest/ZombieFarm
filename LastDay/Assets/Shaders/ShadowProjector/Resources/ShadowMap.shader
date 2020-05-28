// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_Projector' with 'unity_Projector'
// Upgrade NOTE: replaced '_ProjectorClip' with 'unity_ProjectorClip'

Shader "Projector/ShadowMap" {
    Properties{
        _ShadowTex("ShadowTex", 2D) = "gray" {}
        _FalloffTex("FallOff", 2D) = "white" {}
        _Bias("_Bias", Range(0, 0.01)) = 0
        _Strength("_Strength", Range(0, 1)) = 0.5
    }

    Subshader{
        Tags { "Queue" = "Transparent" }
        Pass {
            ZWrite Off
            Fog{ Mode Off }
            ColorMask RGB
            Blend SrcAlpha OneMinusSrcAlpha            
            Offset -1, -1

            CGPROGRAM
            #pragma vertex vert 
            #pragma fragment frag 
            #pragma fragmentoption ARB_precision_hint_fastest
            #include "UnityCG.cginc" 

            struct v2f {
                half4 uvShadow : TEXCOORD0;
                //half4 uvFalloff : TEXCOORD1;
                half4 pos : SV_POSITION;
            };

            uniform half4x4 ShadowMatrix;
            half4x4 unity_Projector;
            half4x4 unity_ProjectorClip;

            v2f vert(half4 vertex : POSITION)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(vertex);
                half4x4 matWVP = mul(ShadowMatrix, unity_ObjectToWorld);
                o.uvShadow = mul(matWVP, vertex);
                //o.uvFalloff = mul(matWVP, vertex);
                return o;
            }

            sampler2D _ShadowTex;
            sampler2D _FalloffTex;
            half _Bias;
            half _Strength;
            fixed4 frag(v2f i) : SV_Target
            {
                half2 uv = i.uvShadow.xy / i.uvShadow.w * 0.5 + 0.5;
#if UNITY_UV_STARTS_AT_TOP
                uv.y = 1 - uv.y;
#endif
                fixed4 texS = tex2D(_ShadowTex, uv);
                //fixed4 texM = tex2D(_FalloffTex, uv);
                //fixed4 falloff = tex2D(_FalloffTex, i.uvFalloff.xy);
                //c = lerp(fixed4(1,1,1,1), c, falloff.a);
                //c.a *= _Strength;
                texS = fixed4(0, 0, 0, texS.a * _Strength);
                return texS;

       
//                fixed4 res = fixed4(0, 0, 0, 0);
//                //float shadowz = i.uvShadow.z / i.uvShadow.w; 
//                half pad = 888;
//                fixed4 texS = tex2D(_ShadowTex, uv);
//                res.a += texS.a * _Strength;
////                if (texS.a > 0)
////                {
////                    res.a += _Strength;
////                }
//                //float3 kDecodeDot = float3(1.0, 1/255.0, 1/65025.0); 
//                //float z = dot(texS.gba, kDecodeDot); 
//                //float flag = 1; 
//                //if(texS.r == 1) 
//                //{ 
//                //    flag = -1; 
//                //} 
//                //if(shadowz - _Bias> z * flag) 
//                //{ 
//                //res.a += _Strength; 
//                //} 
////                texS = tex2D(_ShadowTex, uv + half2(-0.94201624 / pad, -0.39906216 / pad));
////                if (texS.a > 0)
////                {
////                    res.a += _Strength;
////                }
////
////                texS = tex2D(_ShadowTex, uv + half2(0.94558609 / pad, -0.76890725 / pad));
////                if (texS.a > 0)
////                {
////                    res.a += _Strength;
////                }
////
////                texS = tex2D(_ShadowTex, uv + half2(-0.094184101 / pad, -0.92938870 / pad));
////                if (texS.a > 0)
////                {
////                    res.a += _Strength;
////                }
////                texS = tex2D(_ShadowTex, uv + half2(0.34495938 / pad, 0.29387760 / pad));
////                if (texS.a > 0)
////                {
////                    res.a += _Strength;
////                }
//                return res;
            }
            ENDCG
        }
    }
}
