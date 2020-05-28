// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "FX/Ripple"
{
	Properties  
    {  
		_Color("_Tint", Color) = (1,1,1,1)
        _MainTex("Texture", 2D) = "black" {}
		_Center("中心x2", Vector) = (0.25, 0.25, 0.75, 0.75)
        _Radius("半径",Range(0,1))=0
		_Freq("频率",Range(1,30))=10
        _Amplitude("振幅",Range(0.001,0.1))=0.01
		_Speed("速度", Range(1, 20))=1
		_Strength("强度", Range(0, 1))=0.1
		_Factor("Factor", Range(0, 1))=0.5
    }  
    SubShader  
    {  
        Pass  
        {  
			Name "FORWARD"
			Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM  
            #pragma vertex vert  
            #pragma fragment frag  
            #include "UnityCG.cginc"
  
            struct v2f{  
                half4 pos:POSITION;  
                half2 uv:TEXCOORD0;  
            };  
  
            v2f vert (appdata_base v)  
            {  
                v2f o;  
                o.pos = UnityObjectToClipPos(v.vertex);  
                o.uv = v.texcoord.xy;  
                return o;  
            }  
			
			fixed4 _Color;
			sampler2D _MainTex;  
			fixed4 _Center;
            half _Radius;
			half _Freq;
            half _Amplitude;            
			half _Speed;
			half _Strength;
			half _Factor;

			half calc_ripper_scale(half2 uv, half2 center, half t)
			{
				half dis = distance(uv, center);
				half amplitude = _Amplitude * saturate(1 - dis / _Radius);
				dis -= lerp(0, _Radius, t);
				half rad = (-dis * _Freq - 1) * 3.1415;
				rad = clamp(rad, -6.283, 0);
				half offset = sin(rad);
                half scale = amplitude * offset;
				return scale;
			}

            fixed4 frag (v2f v) : COLOR  
            {
                //点击波纹效果
				//half time = _Time.x * _Speed;
                half2 uv = v.uv;
				half scale = calc_ripper_scale(uv, _Center.xy, _Factor) 
					+ calc_ripper_scale(uv, _Center.zw, _Factor);
                uv += uv * scale;  
                fixed4 col = tex2D(_MainTex, uv) * _Color + fixed4(1,1,1,1) * saturate(scale) * _Strength / _Amplitude;
                return col;  
            }  
            ENDCG  
        }  
    }  
}
