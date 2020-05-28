Shader "FX/AnimSequece"
{
	Properties
	{
		_Color ("颜色", Color) = (1,1,1,1)
		_MainTex ("贴图", 2D) = "white" {}		
		_Columns ("列数", int) = 2
		_Rows ("行数", int) = 2
		_UV ("偏移", int) = 0
	}
	SubShader
	{
		Tags { "RenderType"="Transparent" "Queue"="Transparent" }
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
			#pragma multi_compile_fwdbase
			
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
			half _UV;
			half _Columns;
			half _Rows;

			fixed4 frag (v2f i) : SV_Target
			{
				int index = _UV;
				int iRow = index / _Columns;
				int iCol = index - iRow * _Rows;

				half2 uv = i.uv;
				uv.x = (iCol + uv.x) / _Columns;
				uv.y = (iRow + uv.y) / _Rows;
				half4 c = tex2D(_MainTex, uv) * _Color;
				return half4(c.rgb * _Color.a, 1);
			}
			ENDCG
		}
	}
}
