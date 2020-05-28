Shader "Unlit/FogOfWarPannel"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		Tags { "RenderType"="Tranparent" "RenderQueue"="Transparent" "Queue"="Transparent+300"}
		LOD 100
		//Blend SrcAlpha OneMinusSrcAlpha
		Blend DstColor Zero
		ZTest Off

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog

			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _MixValue;
			float4 _FogColor;

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 tex = tex2D(_MainTex, i.uv);
				fixed visual = lerp(tex.b, tex.g, _MixValue);
				fixed2 lmin = step(i.uv, 0);
				fixed2 rmin = step(1, i.uv);
				fixed4 col;
				col.rgb = lerp(_FogColor.rgb, fixed3(1, 1, 1), tex.r*_FogColor.a);
				col.rgb = lerp(col.rgb, fixed3(1, 1, 1), visual);
                col.a = 1;
                return col;
			}
			ENDCG
		}
	}
}
