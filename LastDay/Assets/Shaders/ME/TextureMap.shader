// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_Projector' with 'unity_Projector'

Shader "ME/Projector/TextureMap" {
    Properties{
        _ShadowTex("Projected Image", 2D) = "white" {}
        _Color("Main Color", Color) = (0.5,0.5,0.5,1)
        //_Strength("_Strength", Range(0, 2)) = 0.5
        [Enum(UnityEngine.Rendering.BlendMode)] _SrcBlend ("Src Blend", Int) = 1
        [Enum(UnityEngine.Rendering.BlendMode)] _DstBlend ("Dst Blend", Int) = 1
    }

    SubShader {
        Pass {
            Blend [_SrcBlend] [_DstBlend] //影子与原色按1:1混合颜色
            ZWrite Off // 不写入深度缓存
            Offset -1, -1 // 防止zbuff冲突，做的偏移

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            uniform sampler2D _ShadowTex;

            // Projector组件传入的从模型空间到投影空间的矩阵
            uniform float4x4 unity_Projector;

            struct vertexInput {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct vertexOutput {
                float4 pos : SV_POSITION;
                float4 posProj : TEXCOORD0; //投影空间的坐标值
            };

            vertexOutput vert(vertexInput input)
            {
                vertexOutput output;

                output.posProj = mul(unity_Projector, input.vertex);
                output.pos = UnityObjectToClipPos(input.vertex);
                return output;
            }

            //float _Strength;
            uniform fixed4 _Color;

            float4 frag(vertexOutput input) : COLOR
            {
                return tex2Dproj(_ShadowTex, input.posProj) * _Color;
                //return tex2D(_ShadowTex, input.posProj.xy / input.posProj.w) * _Strength;
                //if (input.posProj.w > 0.0) // 在投影物前方
                //{
                //    //最后那个0.1可以用来调节投影在最终效果中所占的比重
                //    return tex2D(_ShadowTex ,
                //        input.posProj.xy / input.posProj.w) * 0.1;
                //    // 或者使用: return tex2Dproj(
                //    //    _ShadowTex, input.posProj);
                //}
                //else // 投影物体后方
                //{
                //    return float4(0.0, 0.0, 0.0, 0.0);
                //}
            }
            ENDCG
        }
    }
    Fallback "Projector/Light"
}