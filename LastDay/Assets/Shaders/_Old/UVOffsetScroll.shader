Shader "FX/UVOffsetScroll"
{
	Properties
	{
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Texture", 2D) = "white" {}
		_SpeedX ("Speed X", float) = 1.0
		_SpeedY ("Speed Y", float) = 0.0
	}
	SubShader
	{
		Tags { "RenderType"="Transparent" "Queue"="Transparent" }
		LOD 100

		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}

			fixed4 _Color;
			half _SpeedX;
			half _SpeedY;
			
			fixed4 frag (v2f i) : SV_Target
			{
			    // 使用了_Time要注意精度问题，不要用half
				float2 uv = i.uv + float2(_SpeedX, _SpeedY) * _Time.y;
				fixed4 col = tex2D(_MainTex, uv);
				return col * _Color;
			}
			ENDCG
		}
	}
}
