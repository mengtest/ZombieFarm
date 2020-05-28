Shader "FX/UVSequece Distort"
{
	Properties
	{
		_Color ("颜色", Color) = (1,1,1,1)
		_MainTex ("贴图", 2D) = "white" {}
		_Columns ("列数", float) = 2.0
		_Rows ("行数", float) = 2.0
		_Speed ("速度", float) = 10.0
				
		_Distort ("扭曲贴图", 2D) = "white" {}
		_DistortX ("扭曲速度X", float) = 1.0
		_DistortY ("扭曲速度Y", float) = 1.0
		_Strength ("强度", range(0, 10)) = 1.0
	}
	SubShader
	{
		Tags { "RenderType"="Transparent" }
		LOD 100

		Pass
		{
			Name "FORWARD"
            Blend One One
            Cull Off
            ZWrite Off

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag			
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"

			struct appdata
			{
				half4 vertex : POSITION;
				half2 uv : TEXCOORD0;
			};

			struct v2f
			{				
				half4 vertex : SV_POSITION;
				half2 uv : TEXCOORD0;
			};

			sampler2D _MainTex;
			fixed4 _MainTex_ST;
						
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}
			
			fixed4 _Color;
			half _Speed;
			half _Columns;
			half _Rows;

			sampler2D _Distort;
			half _DistortX;
			half _DistortY;
			half _Strength;

			fixed4 frag (v2f i) : SV_Target
			{	
				int index = floor(_Time.y * _Speed);
				int iRow = index / _Columns;
				int iCol = index - iRow * _Rows;

				half2 uv = i.uv;
				uv.x = (iCol + uv.x) / _Columns;
				uv.y = (iRow + uv.y) / _Rows;

				fixed4 col = tex2D(_Distort, i.uv + half2(_DistortX, _DistortY) * _Time.y);
				half multi = saturate(1 - step(col.r * _Strength, 0.3));
				return tex2D(_MainTex, uv) * _Color * multi;
			}
			ENDCG
		}
	}
}
