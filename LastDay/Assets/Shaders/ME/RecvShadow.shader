Shader "ME/Unlit/RecvShadow"
{
	Properties
    {
		_Color("Color", Color) = (0.6,0.6,0.6,1.0)
		_Cutoff("Alpha Cut", Range(0,1)) = 0.5
    }

    SubShader
    {
        Tags{ "RenderType"="Opaque" }
        LOD 200

        Pass {
            Name "BASE"

            Tags{ "LightMode"="ForwardBase" }
			Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase
            #pragma fragmentoption ARB_precision_hint_fastest
            #pragma glsl
            #pragma target 2.0

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

			struct a2v
			{
				half4 vertex : POSITION;
				half3 normal : NORMAL;
				half2 texcoord : TEXCOORD0;
			};

			struct v2f
			{
				half4 pos : POSITION;

				// 声明_LightCoord和_ShadowCoord
				LIGHTING_COORDS(0, 1)
			};

			fixed4 _Color;
			half _Cutoff;

			v2f vert(a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);

				// 计算_LightCoord和_ShadowCoord
				TRANSFER_VERTEX_TO_FRAGMENT(o);
				return o;
			}

            fixed4 frag(v2f IN) : COLOR
            {
				fixed4 c;
				half atten = LIGHT_ATTENUATION(IN);
				c.rgb = _Color.rgb * atten;
				c.a = _Color.a * (1 - atten);
				return c;
            }
            ENDCG
        }

		Pass
		{
			Name "SHADOWCASTER"
			Tags { "LightMode" = "ShadowCaster" }

			Fog {Mode Off}
			ZWrite On ZTest Less Cull Off
			Offset 1, 1

			CGPROGRAM
			#pragma skip_variants SHADOWS_DEPTH SHADOWS_CUBE
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_shadowcaster
            #pragma multi_compile_instancing
			#pragma fragmentoption ARB_precision_hint_fastest
			#include "UnityCG.cginc"

			struct v2f {
				V2F_SHADOW_CASTER;
			};

			v2f vert(appdata_base v)
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				TRANSFER_SHADOW_CASTER_NORMALOFFSET(o);
				return o;
			}

			inline half4 fragShadow(v2f i)
			{
				SHADOW_CASTER_FRAGMENT(i);
			}

			half4 frag(v2f i) : SV_Target
			{
				return fragShadow(i);
			}

			ENDCG
		}
	}
}
