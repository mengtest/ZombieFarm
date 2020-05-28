// NO utf8 BOM here!
#ifndef ME_SIMULATE_POINT_LIGHT
#define ME_SIMULATE_POINT_LIGHT

half4 CenterPos;
fixed4 CenterColor = fixed4(1, 1, 1, 1);

fixed3 CircleLighten(half3 worldPos, fixed3 c, half atten)
{
	half d = distance(worldPos, CenterPos.xyz) / CenterPos.w;
	//d = 2 - saturate(d); // [1, 2]
	//return c * pow(d, CenterColor.rgb * atten);
    return c * (1 + (1 - saturate(d)) * CenterColor.rgb * atten);
}

#endif