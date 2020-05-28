Shader "ME/Creep/UnlitA"
{
    Properties
    {
        [HideInInspector]_Color("Color", Color) = (1.0,1.0,1.0,1.0)

        [HideInInspector]_MainTex("Main (RGBA)", 2D) = "white" {}
        [HideInInspector]_Cutoff("Alpha Cut", Range(0,1)) = 0.5

		[HideInInspector]_SkinTex("Skin (RGB)", 2D) = "black" {}
		[HideInInspector]_SkinCut("Skin Cut", Range(0,1)) = 0.1

        [HideInInspector]_HairUV("Hair UV", Vector) = (0, 0, 0, 0)
        [HideInInspector]_HairColor("Hair Color", Color) = (1, 1, 1, 1)

        [HideInInspector]_AtlasUV("UV in Atlas", Vector) = (0, 0, 1, 1)

        [HideInInspector]_AlphaGridTex("Alpha Grid", 2D) = "white" {}
        [HideInInspector][Enum(UnityEngine.Rendering.BlendMode)] _SrcBlend ("Src Blend", Int) = 1
        [HideInInspector][Enum(UnityEngine.Rendering.BlendMode)] _DstBlend ("Dst Blend", Int) = 0

		[Header(Creep Settings)]
		_CreepTex ("Creep", 2D) = "white" {}
		_CreepColor ("Creep Color", Color) = (1.0,1.0,1.0,1.0)
        _NoiseTex ("Noise Texture", 2D) = "white" {}
        _Offset ("Offset", Range(-5, 5)) = 0.1367521
        _Amplitude ("Amplitude", Range(0, 1)) = 0.1538462
        _TimeSpeed ("Time Speed", Range(0, 2)) = 0.7350427
    }

    SubShader
    {
        Tags{ "RenderType"="Opaque" }
        LOD 200

        Pass {
            Name "BASE"
            LOD 200

			Tags{ "LightMode"="ForwardBase" }
			Blend [_SrcBlend] [_DstBlend]
            Lighting off

            CGPROGRAM
			#pragma skip_variants DYNAMICLIGHTMAP_ON LIGHTMAP_ON LIGHTMAP_SHADOW_MIXING LIGHTPROBE_SH SHADOWS_SHADOWMASK VERTEXLIGHT_ON
            //#pragma multi_compile __ SET_GRAYSCALE
            #pragma multi_compile __ TOON_TRANSPARENT
            #pragma multi_compile __ TOON_SIMULATE_POINTLIT
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase
            #pragma fragmentoption ARB_precision_hint_fastest
            #pragma glsl
            #pragma target 3.0

            #include "UnityCG.cginc"
			#include "ME_Toon.cginc"

			uniform sampler2D _CreepTex; uniform half4 _CreepTex_ST;
            uniform sampler2D _NoiseTex; uniform half4 _NoiseTex_ST;
            uniform half _Offset;
            uniform half _Amplitude;
            uniform half _TimeSpeed;

            toon_unlit_v2f vert(toon_a2v v)
            {
                toon_unlit_v2f o;

				o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.uv.zw = TRANSFORM_TEX(v.texcoord2, _MainTex);

				half4 time = _Time.y;
                half4 Creep = tex2Dlod(_CreepTex,half4(TRANSFORM_TEX(o.uv, _CreepTex),0.0,0));
				half rad = 6.28318530718*_TimeSpeed*time;
                half creepValue = Creep.r * sin(rad);

                half4 Noise = tex2Dlod(_NoiseTex,half4(TRANSFORM_TEX(o.uv, _NoiseTex),0.0,0));
                half2 uv1 = (o.uv+(time*half2(_Offset,_Offset)));
                half4 Noise1 = tex2Dlod(_NoiseTex,half4(TRANSFORM_TEX(uv1, _NoiseTex),0.0,0));

                v.vertex.xyz += v.normal * (creepValue*(Noise.r*Noise1.r)) *_Amplitude;

                o.pos = UnityObjectToClipPos(v.vertex);
#ifdef TOON_SIMULATE_POINTLIT
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
#endif

                half3 worldNormal = mul((half3x3)unity_ObjectToWorld, SCALED_NORMAL);

				o.vlight = ShadeSH9 (half4(worldNormal, 1.0));

                return o;
            }

			fixed4 _Color;
			fixed4 _CreepColor;

            fixed4 frag(toon_unlit_v2f IN) : COLOR
            {
				fixed4 main = toon_unlit_frag(IN, _Color);
				half4 Creep = tex2Dlod(_CreepTex,half4(TRANSFORM_TEX(IN.uv, _CreepTex),0.0,0));
				half rad = 6.28318530718*_TimeSpeed*_Time.y;
                half creepValue = Creep.r * sin(rad);
				main.rgb += main.rgb * (_CreepColor.rgb * saturate(creepValue));
				main.rgb *= IN.vlight;
				main.a = _Color.a;

                return main;
            }
            ENDCG
        }

		UsePass "Hidden/Toon/SHADOWCASTER"
    }

    //Fallback "Diffuse"
    CustomEditor "METoonShaderEditor"
}
