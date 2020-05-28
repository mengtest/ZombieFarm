
Shader "ME/Toon/Lit Grass"
{
    Properties
    {
        [HideInInspector]_Color("Color", Color) = (0.6,0.6,0.6,1.0)
        [HideInInspector]_HColor("Highlight Color", Color) = (1.0,1.0,1.0,1.0)
        [HideInInspector]_SColor("Shadow Color", Color) = (0.2,0.2,0.2,1.0)

        [HideInInspector]_MainTex("Main (RGBA)", 2D) = "white" {}
        [HideInInspector]_Cutoff("Alpha Cut", Range(0,1)) = 0.5

        [HideInInspector]_AtlasUV("UV in Atlas", Vector) = (0, 0, 1, 1)

        [HideInInspector]_AlphaGridTex ("Alpha Grid", 2D) = "white" {}

        [HideInInspector][Enum(UnityEngine.Rendering.BlendMode)] _SrcBlend ("Src Blend", Int) = 1
        [HideInInspector][Enum(UnityEngine.Rendering.BlendMode)] _DstBlend ("Dst Blend", Int) = 0

        _TimeScale("Time Scale", Float) = 1.0
		_VOffset("UV Offset(V)", Range(0,1)) = 0
		_VScale("UV Scale(V)", Range(0,1)) = 1
        [Enum(UnityEngine.Rendering.DepthTest)] _DepthTest ("ZWrite", Int) = 1
        
        _StencilRef ("Stencil Ref", Int) = 0
        [Enum(UnityEngine.Rendering.CompareFunction)] _StencilComp ("Stencil Comp", Int) = 0
        [Enum(UnityEngine.Rendering.StencilOp)] _StencilPassOp ("Stencil Pass Op", Int) = 0
        [Enum(UnityEngine.Rendering.StencilOp)] _StencilZFailOp ("Stencil ZFail Op", Int) = 0
    }

    SubShader
    {
        Tags{ "RenderType"="Opaque" }
        LOD 200

        Pass {
            Name "BASE"

            Tags{ "LightMode"="ForwardBase" }
            Blend [_SrcBlend] [_DstBlend]
            ZWrite [_DepthTest]

            Stencil {
                Ref [_StencilRef]
                Comp [_StencilComp]
                Pass [_StencilPassOp]
                ZFail [_StencilZFailOp]
            }

            CGPROGRAM
			#pragma skip_variants DYNAMICLIGHTMAP_ON LIGHTMAP_ON LIGHTMAP_SHADOW_MIXING LIGHTPROBE_SH SHADOWS_SHADOWMASK VERTEXLIGHT_ON
            #pragma multi_compile __ TOON_SIMULATE_POINTLIT
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase
            #pragma multi_compile_instancing
            #pragma fragmentoption ARB_precision_hint_fastest
            #pragma glsl
            #pragma target 2.0

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"
            #include "ME_Include.cginc"

			fixed4 _Color;
			half _TimeScale;
			fixed _VOffset;
			fixed _VScale;

            toon_v2f vert(toon_a2v v)
            {
				float y = (v.texcoord.y - _VOffset) / _VScale;
                float x = _Time.y * clamp(y - 0.5, 0, 1);
                //v.vertex.x += sin(3.1416 * x) * _TimeScale;

                x = x % 2 - 1;
                x =  4 * (x - x * abs(x)) * _TimeScale;
                v.vertex.x += x;

                toon_v2f o = toon_vert(v);
                return o;
            }

            fixed4 frag(toon_v2f IN) : COLOR
            {
                fixed4 main = toon_frag(IN, _Color);
                main.a = _Color.a;

                return RampSmoothLight(main, IN.worldNormal, IN.lightDir, LIGHT_ATTENUATION(IN));
            }
            ENDCG
        }

		Pass {
            Name "SHADOWCASTER"
            Tags { "LightMode"="ShadowCaster"}

            Fog {Mode Off}
            ZWrite On ZTest Less Cull Off
            Offset 1, 1

            CGPROGRAM
            #pragma skip_variants SHADOWS_DEPTH SHADOWS_CUBE
            #pragma multi_compile __ TOON_TRANSPARENT
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_shadowcaster
            #pragma multi_compile_instancing
            #pragma fragmentoption ARB_precision_hint_fastest
            #include "UnityCG.cginc"

            sampler2D _MainTex;
            fixed _Cutoff;
            half _TimeScale;
            sampler3D _DitherMaskLOD;

            struct v2f {
                V2F_SHADOW_CASTER;
                half2 uv:TEXCOORD2;
            };

            v2f vert(appdata_base v)
            {
                v2f o;
                float x = _Time.y * clamp(v.texcoord.y - 0.5, 0, 1);
                //v.vertex.x += sin(3.1416 * x) * _TimeScale;

                x = x % 2 - 1;
                x =  4 * (x - x * abs(x)) * _TimeScale;
                v.vertex.x += x;

                UNITY_SETUP_INSTANCE_ID(v);

                o.uv = v.texcoord;
                TRANSFER_SHADOW_CASTER_NORMALOFFSET(o);
                return o;
            }

            uniform fixed4 _Color;

            inline half4 fragShadow(v2f i)
            {
                SHADOW_CASTER_FRAGMENT(i);
            }

            half4 frag(v2f i) : SV_Target
            {
                fixed4 main = tex2D(_MainTex, i.uv);
                clip(main.a - _Cutoff);

                half alphaRef = tex3D(_DitherMaskLOD, float3(i.pos.xy*0.25, _Color.a*0.9375)).a;
                clip(alphaRef - 0.01);

                return fragShadow(i);
            }

            ENDCG
        }
    }

    //Fallback "Diffuse"
    CustomEditor "METoonShaderEditor"
}
