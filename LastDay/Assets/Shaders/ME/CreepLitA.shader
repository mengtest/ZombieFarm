Shader "ME/Creep/LitA"
{
    Properties
    {
        [HideInInspector]_Color("Color", Color) = (0.6,0.6,0.6,1.0)
        [HideInInspector]_HColor("Highlight Color", Color) = (1.0,1.0,1.0,1.0)
        [HideInInspector]_SColor("Shadow Color", Color) = (0.2,0.2,0.2,1.0)

		[HideInInspector]_Ramp("Ramp Tex", 2D) = "gray" {}
        [HideInInspector]_RampThreshold("Ramp Threshold", Range(0,1)) = 0.5
        [HideInInspector]_RampSmooth("Ramp Smoothing", Range(0.01,1)) = 0.1

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

            Tags{ "LightMode"="ForwardBase" }
            Blend [_SrcBlend] [_DstBlend]

            CGPROGRAM
			#pragma skip_variants DYNAMICLIGHTMAP_ON LIGHTMAP_ON LIGHTMAP_SHADOW_MIXING LIGHTPROBE_SH SHADOWS_SHADOWMASK VERTEXLIGHT_ON
            #pragma multi_compile __ SET_GRAYSCALE
            #pragma multi_compile __ TOON_TRANSPARENT
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase
            #pragma fragmentoption ARB_precision_hint_fastest
            #pragma glsl
            #pragma target 3.0

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"
            #include "ME_Include.cginc"

			uniform sampler2D _CreepTex; uniform half4 _CreepTex_ST;
            uniform sampler2D _NoiseTex; uniform half4 _NoiseTex_ST;
            uniform half _Offset;
            uniform half _Amplitude;
            uniform half _TimeSpeed;

            toon_v2f vert(toon_a2v v)
            {
                toon_v2f o;

                half2 uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                half2 uv2 = TRANSFORM_TEX(v.texcoord2, _MainTex);

				half4 time = _Time.y;
                half4 Creep = tex2Dlod(_CreepTex,half4(TRANSFORM_TEX(uv, _CreepTex),0.0,0));
				half rad = 6.28318530718*_TimeSpeed*time;
                half creepValue = Creep.r * sin(rad);

                half4 Noise = tex2Dlod(_NoiseTex,half4(TRANSFORM_TEX(uv, _NoiseTex),0.0,0));
                half2 uv1 = (uv+(time*half2(_Offset,_Offset)));
                half4 Noise1 = tex2Dlod(_NoiseTex,half4(TRANSFORM_TEX(uv1, _NoiseTex),0.0,0));

                v.vertex.xyz += v.normal * (creepValue*(Noise.r*Noise1.r)) *_Amplitude;

				o.uv.xy = uv;
                o.uv.zw = uv2;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldNormal = normalize(mul(SCALED_NORMAL, (half3x3)unity_WorldToObject));
                o.lightDir = normalize(mul((half3x3)unity_ObjectToWorld, ObjSpaceLightDir(v.vertex)));
                o.viewDir = normalize(mul((half3x3)unity_ObjectToWorld, ObjSpaceViewDir(v.vertex)));
#ifdef TOON_SIMULATE_POINTLIT
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
#endif

#ifdef TOON_TRANSPARENT
                half4 screenPos = ComputeScreenPos(o.pos);
                screenPos.xy *= _ScreenParams.xy / 8;//此处不能先除w，会导致插值精度不够
                o.screenUv = screenPos;
#endif

                // 计算_LightCoord和_ShadowCoord
                TRANSFER_VERTEX_TO_FRAGMENT(o);
                return o;
            }

			fixed4 _Color;
			fixed4 _CreepColor;

            fixed4 frag(toon_v2f IN) : COLOR
            {
				fixed4 main = toon_frag(IN, _Color);

				half4 Creep = tex2Dlod(_CreepTex,half4(TRANSFORM_TEX(IN.uv, _CreepTex),0.0,0));
				half rad = 6.28318530718*_TimeSpeed*_Time.y;
                half creepValue = Creep.r * sin(rad);
				main.rgb += main.rgb * (_CreepColor.rgb * saturate(creepValue));
				main.a = _Color.a;

                return RampSmoothLight(main, IN.worldNormal, IN.lightDir, LIGHT_ATTENUATION(IN));
            }
            ENDCG
        }

		UsePass "Hidden/Toon/SHADOWCASTER"
    }

    //Fallback "Diffuse"
    CustomEditor "METoonShaderEditor"
}
