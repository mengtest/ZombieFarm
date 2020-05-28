Shader "FX/UVSequence"
{
	Properties
	{
		[Enum(UnityEngine.Rendering.BlendMode)] _SrcBlend ("Src Blend", int) = 1 // One
        [Enum(UnityEngine.Rendering.BlendMode)] _DstBlend ("Dst Blend", int) = 1 // One
		[Enum(UnityEngine.Rendering.DepthTest)] _DepthWrite ("ZWrite", int) = 0 // Off
		[Enum(UnityEngine.Rendering.CompareFunction)] _DepthTest ("ZTest", int) = 4 // LessEqual
		[Enum(UnityEngine.Rendering.CullMode)] _CullMode ("Cull", int) = 0 // Off

		_Color ("颜色", Color) = (1,1,1,1)
		_MainTex ("贴图", 2D) = "white" {}
		_Columns ("列数", int) = 2.0
		_Rows ("行数", int) = 2.0

		[HideInInspector]_Time_Speed ("速度", float) = 10.0
        [HideInInspector]_NTime_Index ("帧索引", int) = 0

		[HideInInspector]_Distort ("扭曲贴图", 2D) = "white" {}
		[HideInInspector]_DistortX ("扭曲速度X", float) = 1.0
		[HideInInspector]_DistortY ("扭曲速度Y", float) = 1.0
		[HideInInspector]_DistortStrength ("强度", range(0, 10)) = 1.0
	}
	SubShader
	{
		Tags { "RenderType"="Transparent"}
		LOD 100

		Pass
		{
			Name "FORWARD"
            Blend [_SrcBlend] [_DstBlend]
            ZWrite [_DepthWrite]
            ZTest [_DepthTest]
            Cull [_CullMode]

			CGPROGRAM
			#pragma multi_compile __ USING_TIME
			#pragma shader_feature TEX_DISTORT
			#pragma vertex vert
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest
            #pragma glsl
			//#pragma multi_compile_fog

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

			half _Columns;
			half _Rows;

#ifdef USING_TIME
            half _Time_Speed;
#else
            int _NTime_Index;
#endif

#ifdef TEX_DISTORT
			sampler2D _Distort;
			half _DistortX;
			half _DistortY;
			half _DistortStrength;
#endif

			fixed4 frag (v2f i) : SV_Target
			{
#ifdef USING_TIME
				int index = floor(_Time.y * _Time_Speed);
#else
                int index = _NTime_Index;
#endif
				int iRow = index / _Columns;
				int iCol = index - iRow * _Rows;

				half2 uv = i.uv;
				uv.x = (iCol + uv.x) / _Columns;
				uv.y = (iRow + uv.y) / _Rows;

#ifdef TEX_DISTORT
				fixed4 col = tex2D(_Distort, i.uv + half2(_DistortX, _DistortY) * _Time.y);
				half multi = saturate(1 - step(col.r * _DistortStrength, 0.3));
				return tex2D(_MainTex, uv) * _Color * multi;
#else
				return tex2D(_MainTex, uv) * _Color;
#endif
			}
			ENDCG
		}
	}
	CustomEditor "FXShaderEditor"
}
